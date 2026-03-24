#include "mlir/Pass/Pass.h"
#include "circt/Dialect/Comb/CombOps.h"
#include "circt/Dialect/HW/HWOpInterfaces.h"
#include "circt/Dialect/HW/HWOps.h"
#include "circt/Dialect/LLHD/IR/LLHDOps.h"
#include "mlir/Dialect/ControlFlow/IR/ControlFlowOps.h"
#include "mlir/IR/Builders.h"
#include "mlir/IR/BuiltinOps.h"
#include "mlir/IR/Operation.h"
#include "mlir/Support/LLVM.h"
#include "llvm/ADT/DenseMap.h"
#include "llvm/ADT/SmallPtrSet.h"
#include "llvm/ADT/StringExtras.h"
#include "llvm/Support/Debug.h"
#include "llvm/Support/FormatVariadic.h"

// Generate Pass Declarations
#define GEN_PASS_DECL_FORWARDCONSTRAIN
#define GEN_PASS_DEF_FORWARDCONSTRAIN
#include "Passes.h.inc"

#define DEBUG_TYPE "forward-constrain"

using namespace mlir;
using namespace circt;

namespace {

/// Represents the state of a single path tracing execution.
struct TraceContext {
  /// The operations visited along this specific path
  SmallVector<Operation *, 8> paths;
  
  /// The required constants for other signals to sensitize this path
  /// Map of Value -> Required Constant (0 or 1)
  DenseMap<Value, int> constraints;

  /// The expected polarity of the main traced signal at this point.
  /// Starts at targetActiveValue. Flips if passing through a NOT gate.
  int expectedPolarity;

  /// When the traced signal has been packed into an hw.struct, this records
  /// which field name it corresponds to. Reset to std::nullopt once the
  /// field is extracted again via hw.struct_extract.
  std::optional<std::string> trackedFieldName;

  TraceContext(int initialPolarity) : expectedPolarity(initialPolarity) {}
  
  /// Clone constructor for branching
  TraceContext(const TraceContext &other) 
    : paths(other.paths), 
      constraints(other.constraints),
      expectedPolarity(other.expectedPolarity),
      trackedFieldName(other.trackedFieldName) {}
};

struct ForwardConstrainPass : public ::impl::ForwardConstrainBase<ForwardConstrainPass> {
  using ForwardConstrainBase::ForwardConstrainBase; // Inherit constructors

  void runOnOperation() override;

private:
  void findTracingRoots(hw::HWModuleOp module, StringRef targetName);
  void processTracingRoot(Value rootValue);
  void propagateConstraint(Value currentVal, TraceContext ctx);
  void resolveConstraintNames(const DenseMap<Value, int> &constraints, llvm::raw_string_ostream &os);
  void reportPathSatisfiability(Operation *terminator, const TraceContext &ctx, llvm::StringSet<> &busWhitelist);
  
  // Helper for tracking visited nodes to prevent infinite loops in combinational cycles
  SmallPtrSet<Operation *, 16> globalVisited;
  
  // Whitelist of bus signals for mutation
  llvm::StringSet<> parsedBusSignalsWhitelist;
};

void ForwardConstrainPass::runOnOperation() {
  ModuleOp topModule = getOperation();
  StringRef targetName = targetSignal;
  
  LLVM_DEBUG(llvm::dbgs() << "Starting ForwardConstrainPass targeting signal: " 
                          << targetName << " with active value " << targetActiveValue << "\n");

  parsedBusSignalsWhitelist.clear();
  if (!busSignals.empty()) {
    SmallVector<StringRef, 4> sigs;
    StringRef(busSignals).split(sigs, ',', -1, false);
    for (auto s : sigs) {
      if (!s.trim().empty()) {
        parsedBusSignalsWhitelist.insert(s.trim());
      }
    }
  }

  // Reset global visited set per generic run
  globalVisited.clear();

  // Find all HW modules
  for (auto hwModule : topModule.getOps<hw::HWModuleOp>()) {
    findTracingRoots(hwModule, targetName);
  }
}

void ForwardConstrainPass::findTracingRoots(hw::HWModuleOp module, StringRef targetName) {
  // 1. Search module input ports (BlockArguments)
  for (unsigned i = 0, e = module.getNumInputPorts(); i < e; ++i) {
    if (module.getInputNameAttr(i).getValue() == targetName) {
      Value portVal = module.getBodyBlock()->getArgument(i);
      LLVM_DEBUG(llvm::dbgs() << "Found Root [Port]: " << targetName << " in module " << module.getName() << "\n");
      processTracingRoot(portVal);
    }
  }

  // 2. Search internal operations (llhd.sig and hw.struct_extract)
  module.walk([&](Operation *op) {
    if (auto sigOp = dyn_cast<llhd::SignalOp>(op)) {
      if (sigOp.getName() == targetName) {
        LLVM_DEBUG(llvm::dbgs() << "Found Root [SignalOp]: " << targetName << " in module " << module.getName() << "\n");
        // For llhd.sig, the actual value used in logic is the result of llhd.prb
        for (Operation *user : sigOp.getResult().getUsers()) {
          if (auto prbOp = dyn_cast<llhd::PrbOp>(user)) {
            processTracingRoot(prbOp.getResult());
          }
        }
      }
    } else if (auto extractOp = dyn_cast<hw::StructExtractOp>(op)) {
      if (extractOp.getFieldNameAttr().getValue() == targetName) {
        LLVM_DEBUG(llvm::dbgs() << "Found Root [StructExtract]: " << targetName << " in module " << module.getName() << "\n");
        processTracingRoot(extractOp.getResult());
      }
    } else if (auto unionExtractOp = dyn_cast<hw::UnionExtractOp>(op)) {
      if (unionExtractOp.getFieldNameAttr().getValue() == targetName) {
        LLVM_DEBUG(llvm::dbgs() << "Found Root [UnionExtract]: " << targetName << " in module " << module.getName() << "\n");
        processTracingRoot(unionExtractOp.getResult());
      }
    } else if (auto wireOp = dyn_cast<hw::WireOp>(op)) {
      if (wireOp.getName() == targetName) {
        LLVM_DEBUG(llvm::dbgs() << "Found Root [WireOp]: " << targetName << " in module " << module.getName() << "\n");
        processTracingRoot(wireOp.getResult());
      }
    }
  });
}

void ForwardConstrainPass::processTracingRoot(Value rootValue) {
  TraceContext initialCtx(targetActiveValue);
  propagateConstraint(rootValue, initialCtx);
}

void ForwardConstrainPass::propagateConstraint(Value currentVal, TraceContext ctx) {
  // Trace through all users of the current value
  for (Operation *user : currentVal.getUsers()) {
    // Basic cycle detection to prevent infinite loops in combinational cycles
    if (std::find(ctx.paths.begin(), ctx.paths.end(), user) != ctx.paths.end())
      continue;

    TraceContext nextCtx = ctx;
    nextCtx.paths.push_back(user);

    if (auto extractOp = dyn_cast<hw::StructExtractOp>(user)) {
      // If we are tracking a specific struct field (after a struct_create),
      // only follow the struct_extract that extracts our field; skip others.
      if (ctx.trackedFieldName &&
          extractOp.getFieldNameAttr().getValue() != *ctx.trackedFieldName)
        continue;
      TraceContext extractCtx = nextCtx;
      extractCtx.trackedFieldName = std::nullopt; // field has been unpacked
      propagateConstraint(extractOp.getResult(), extractCtx);
    } else if (auto structCreateOp = dyn_cast<hw::StructCreateOp>(user)) {
      // The signal is being packed into a struct. Record which field it becomes
      // so that downstream consumers can filter correctly.
      if (auto structType =
              dyn_cast<hw::StructType>(structCreateOp.getResult().getType())) {
        auto elements = structType.getElements();
        for (unsigned i = 0; i < (unsigned)structCreateOp.getNumOperands() &&
                             i < (unsigned)elements.size(); ++i) {
          if (structCreateOp.getOperand(i) == currentVal) {
            TraceContext fieldCtx = nextCtx;
            fieldCtx.trackedFieldName = elements[i].name.str();
            propagateConstraint(structCreateOp.getResult(), fieldCtx);
            break;
          }
        }
      }
    } else if (auto unionExtractOp = dyn_cast<hw::UnionExtractOp>(user)) {
      propagateConstraint(unionExtractOp.getResult(), nextCtx);
    } else if (auto unionCreateOp = dyn_cast<hw::UnionCreateOp>(user)) {
      propagateConstraint(unionCreateOp.getResult(), nextCtx);
    } else if (auto sigExtractOp = dyn_cast<llhd::SigExtractOp>(user)) {
      propagateConstraint(sigExtractOp.getResult(), nextCtx);
    } else if (auto andOp = dyn_cast<comb::AndOp>(user)) {
      // Sensitize AND gate: all other inputs must be 1 to pass the signal
      for (Value opnd : andOp.getOperands()) {
        if (opnd != currentVal) {
          nextCtx.constraints[opnd] = 1;
        }
      }
      propagateConstraint(andOp.getResult(), nextCtx);
    } else if (auto orOp = dyn_cast<comb::OrOp>(user)) {
      // Sensitize OR gate: all other inputs must be 0 to pass the signal
      for (Value opnd : orOp.getOperands()) {
        if (opnd != currentVal) {
          nextCtx.constraints[opnd] = 0;
        }
      }
      propagateConstraint(orOp.getResult(), nextCtx);
    } else if (auto xorOp = dyn_cast<comb::XorOp>(user)) {
      // Check if it's acting as a NOT gate (XOR with all 1s)
      bool hasConstTrue = false;
      for (Value opnd : xorOp.getOperands()) {
        if (opnd != currentVal) {
          if (auto constOp = dyn_cast_or_null<hw::ConstantOp>(opnd.getDefiningOp())) {
            if (constOp.getValue().isAllOnes()) hasConstTrue = true;
          } else {
            // Sensitize XOR gate without inversion: other input must be 0
            nextCtx.constraints[opnd] = 0;
          }
        }
      }
      if (hasConstTrue) {
        nextCtx.expectedPolarity = 1 - nextCtx.expectedPolarity; // Flip polarity
      }
      propagateConstraint(xorOp.getResult(), nextCtx);
    } else if (auto muxOp = dyn_cast<comb::MuxOp>(user)) {
      if (currentVal == muxOp.getCond()) {
        // The traced signal is the condition itself. We keep tracing the output.
        // We might need to split paths here if we wanted both true and false paths,
        // but typically a control signal will just drive logic forward.
        propagateConstraint(muxOp.getResult(), nextCtx);
      } else if (currentVal == muxOp.getTrueValue()) {
        nextCtx.constraints[muxOp.getCond()] = 1;
        propagateConstraint(muxOp.getResult(), nextCtx);
      } else if (currentVal == muxOp.getFalseValue()) {
        nextCtx.constraints[muxOp.getCond()] = 0;
        propagateConstraint(muxOp.getResult(), nextCtx);
      }
    } else if (auto icmpOp = dyn_cast<comb::ICmpOp>(user)) {
      // For equality/inequality checks against constants
      if (icmpOp.getPredicate() == comb::ICmpPredicate::eq) {
        for (Value opnd : icmpOp.getOperands()) {
          if (opnd != currentVal) {
            if (auto constOp = dyn_cast_or_null<hw::ConstantOp>(opnd.getDefiningOp())) {
              if (constOp.getValue().isAllOnes()) {
                // Testing if signal == 1. Output passes it through directly.
              } else if (constOp.getValue().isZero()) {
                // Testing if signal == 0. Output is NOT signal.
                nextCtx.expectedPolarity = 1 - nextCtx.expectedPolarity;
              }
            }
          }
        }
      } else if (icmpOp.getPredicate() == comb::ICmpPredicate::ne) {
        for (Value opnd : icmpOp.getOperands()) {
          if (opnd != currentVal) {
            if (auto constOp = dyn_cast_or_null<hw::ConstantOp>(opnd.getDefiningOp())) {
              if (constOp.getValue().isAllOnes()) {
                // ne 1 -> NOT
                nextCtx.expectedPolarity = 1 - nextCtx.expectedPolarity;
              } else if (constOp.getValue().isZero()) {
                // ne 0 -> passes through
              }
            }
          }
        }
      }
      propagateConstraint(icmpOp.getResult(), nextCtx);
    } else if (auto drvOp = dyn_cast<llhd::DrvOp>(user)) {
      // Reached an endpoint (driving a wire or register)
      reportPathSatisfiability(drvOp, nextCtx, parsedBusSignalsWhitelist);
      
      // If it drives a signal used combinatorially elsewhere, continue tracing
      Value sigVal = drvOp.getSignal();
      for (Operation *sigUser : sigVal.getUsers()) {
        if (auto prbOp = dyn_cast<llhd::PrbOp>(sigUser)) {
          propagateConstraint(prbOp.getResult(), nextCtx);
        }
      }
    } else if (auto condBrOp = dyn_cast<cf::CondBranchOp>(user)) {
      // Reached control flow boundary
      reportPathSatisfiability(condBrOp, nextCtx, parsedBusSignalsWhitelist);
    } else if (auto instOp = dyn_cast<hw::InstanceOp>(user)) {
      // Cross-module propagation
      for (unsigned i = 0; i < instOp.getNumOperands(); ++i) {
        if (instOp.getOperand(i) == currentVal) {
          auto targetMod = dyn_cast_or_null<hw::HWModuleOp>(
              SymbolTable::lookupNearestSymbolFrom(instOp, instOp.getModuleNameAttr()));
          if (targetMod) {
            Value portVal = targetMod.getBodyBlock()->getArgument(i);
            propagateConstraint(portVal, nextCtx);
          }
        }
      }
    } else {
      // Fallback: passively propagate through other elements (e.g. llhd.prb, etc.)
      for (Value res : user->getResults()) {
        propagateConstraint(res, nextCtx);
      }
    }
  }
}

static std::string getSSAValueName(Value val) {
  if (!val) return "";
  if (auto opResult = dyn_cast<OpResult>(val)) {
    Operation *defOp = opResult.getDefiningOp();
    if (!defOp) return "";
    std::string opStr;
    llvm::raw_string_ostream os(opStr);
    defOp->print(os, OpPrintingFlags().useLocalScope());
    os.flush();
    if (defOp->getNumResults() == 1) {
      size_t eqPos = opStr.find(" = ");
      if (eqPos != std::string::npos && opStr.length() > 1 && opStr[0] == '%') {
        std::string name = opStr.substr(1, eqPos - 1);
        if (!name.empty() && !std::all_of(name.begin(), name.end(), ::isdigit)) {
          return name;
        }
      }
    }
  }
  return "";
}

static void resolveConstraintsBackward(Value val, int reqVal, SmallVectorImpl<std::pair<std::string, int>> &result) {
  if (!val) return;

  if (auto arg = dyn_cast<BlockArgument>(val)) {
    if (auto hwMod = dyn_cast<hw::HWModuleOp>(arg.getParentRegion()->getParentOp())) {
      if (arg.getArgNumber() < hwMod.getNumInputPorts()) {
        result.push_back({hwMod.getInputNameAttr(arg.getArgNumber()).getValue().str(), reqVal});
        return;
      }
    }
  }
  
  Operation *defOp = val.getDefiningOp();
  if (!defOp) {
    result.push_back({"anonymous", reqVal});
    return;
  }

  if (auto wireOp = dyn_cast<hw::WireOp>(defOp)) {
    if (auto name = wireOp.getName()) {
      result.push_back({name->str(), reqVal});
      return;
    }
  }
  if (auto sigOp = dyn_cast<llhd::SignalOp>(defOp)) {
    if (auto name = sigOp.getName()) {
      result.push_back({name->str(), reqVal});
      return;
    }
  }
  if (auto prbOp = dyn_cast<llhd::PrbOp>(defOp)) {
    resolveConstraintsBackward(prbOp.getSignal(), reqVal, result);
    return;
  }
  if (auto extractOp = dyn_cast<hw::StructExtractOp>(defOp)) {
    result.push_back({extractOp.getFieldNameAttr().getValue().str(), reqVal});
    return;
  }
  if (auto unionExtractOp = dyn_cast<hw::UnionExtractOp>(defOp)) {
    result.push_back({unionExtractOp.getFieldNameAttr().getValue().str(), reqVal});
    return;
  }
  if (auto unionCreateOp = dyn_cast<hw::UnionCreateOp>(defOp)) {
    resolveConstraintsBackward(unionCreateOp.getInput(), reqVal, result);
    return;
  }
  if (auto ex = dyn_cast<llhd::SigExtractOp>(defOp)) {
    resolveConstraintsBackward(ex.getInput(), reqVal, result);
    return;
  }

  // --- Recursive Combinational Logic Expansion ---
  if (auto andOp = dyn_cast<comb::AndOp>(defOp)) {
    // To force an AND gate to 1, ALL inputs must be 1.
    if (reqVal == 1) {
      for (Value opnd : andOp.getOperands()) {
        resolveConstraintsBackward(opnd, 1, result);
      }
      return;
    }
  }
  if (auto orOp = dyn_cast<comb::OrOp>(defOp)) {
    // To force an OR gate to 0, ALL inputs must be 0.
    if (reqVal == 0) {
      for (Value opnd : orOp.getOperands()) {
        resolveConstraintsBackward(opnd, 0, result);
      }
      return;
    }
  }
  if (auto icmpOp = dyn_cast<comb::ICmpOp>(defOp)) {
    Value lhs = icmpOp.getLhs();
    Value rhs = icmpOp.getRhs();
    
    // Look for a constant on either side
    auto lhsConst = dyn_cast_or_null<hw::ConstantOp>(lhs.getDefiningOp());
    auto rhsConst = dyn_cast_or_null<hw::ConstantOp>(rhs.getDefiningOp());
    
    if (lhsConst || rhsConst) {
      Value varOpnd = lhsConst ? rhs : lhs;
      hw::ConstantOp constOp = lhsConst ? lhsConst : rhsConst;
      
      // Extract the integer value being compared against
      int targetVal = constOp.getValue().getSExtValue();
      
      if (reqVal == 1) {
        switch (icmpOp.getPredicate()) {
          case comb::ICmpPredicate::eq:
          case comb::ICmpPredicate::ceq:
          case comb::ICmpPredicate::weq:
            resolveConstraintsBackward(varOpnd, targetVal, result);
            return;
          case comb::ICmpPredicate::ne:
          case comb::ICmpPredicate::cne:
          case comb::ICmpPredicate::wne:
            // Could technically resolve `!=` as NOT targetVal
            break;
          default:
            break;
        }
      } else if (reqVal == 0) {
        // If the eq condition must be false
        switch (icmpOp.getPredicate()) {
          case comb::ICmpPredicate::eq:
          case comb::ICmpPredicate::ceq:
          case comb::ICmpPredicate::weq: {
            // It means varOpnd != targetVal.
            // We can't easily express this in a simple int constraint map without changing the type.
            // But we shouldn't emit "anonymous = 0".
            // For now, let's just resolve the name of the variable so we at least know what's restricted.
            // E.g "a_opcode_neq_0" = 1? Or just skip it. Let's just resolve its name and append "_neq"
            SmallVector<std::pair<std::string, int>, 1> dummy;
            resolveConstraintsBackward(varOpnd, targetVal, dummy);
            if (!dummy.empty()) {
              result.push_back({dummy[0].first + "_neq", targetVal});
              return;
            }
            break;
          }
          default:
            break;
        }
      }
    }
  }
  if (auto xorOp = dyn_cast<comb::XorOp>(defOp)) {
    // Handle NOT gates (XOR with all ones)
    Value otherOpnd = nullptr;
    bool isNot = false;
    for (Value opnd : xorOp.getOperands()) {
      if (auto constOp = dyn_cast_or_null<hw::ConstantOp>(opnd.getDefiningOp())) {
        if (constOp.getValue().isAllOnes()) {
          isNot = true;
          continue;
        }
      }
      otherOpnd = opnd;
    }
    if (isNot && otherOpnd) {
      resolveConstraintsBackward(otherOpnd, 1 - reqVal, result); // Invert requirement
      return;
    }
  }
  
  std::string parsedName = getSSAValueName(val);
  if (!parsedName.empty()) {
    result.push_back({parsedName, reqVal});
    return;
  }
  
  LLVM_DEBUG(llvm::dbgs() << "Failed to resolve name for: " << val << "\n");
  result.push_back({"anonymous", reqVal});
}

static std::string findNamedSignalBackward(Value val) {
  SmallVector<std::pair<std::string, int>, 1> dummy;
  resolveConstraintsBackward(val, 0, dummy);
  if (!dummy.empty()) return dummy[0].first;
  return "anonymous";
}

void ForwardConstrainPass::resolveConstraintNames(const DenseMap<Value, int> &constraints, llvm::raw_string_ostream &os) {
  SmallVector<std::pair<std::string, int>, 8> flattened;
  for (const auto &pair : constraints) {
    resolveConstraintsBackward(pair.first, pair.second, flattened);
  }

  // Deduplicate and sort conceptually
  llvm::StringSet<> seen;
  bool first = true;
  for (const auto &item : flattened) {
    std::string key = item.first + "=" + std::to_string(item.second);
    if (seen.insert(key).second) {
      if (!first) os << ", ";
      os << item.first << " = " << item.second;
      first = false;
    }
  }
}

// Helper to check topological auto-detect rule mapping back to external inputs
static bool isTopologicalBusSignal(Value val) {
  if (isa<BlockArgument>(val)) return true;
  if (auto opResult = dyn_cast<OpResult>(val)) {
    Operation *defOp = opResult.getDefiningOp();
    if (auto ext = dyn_cast<hw::StructExtractOp>(defOp)) {
      return isa<BlockArgument>(ext.getInput());
    }
    if (auto uExt = dyn_cast<hw::UnionExtractOp>(defOp)) {
      return isa<BlockArgument>(uExt.getInput());
    }
    if (auto sigExt = dyn_cast<llhd::SigExtractOp>(defOp)) {
      return isa<BlockArgument>(sigExt.getInput());
    }
    if (auto prb = dyn_cast<llhd::PrbOp>(defOp)) {
      if (auto sigOp = dyn_cast_or_null<llhd::SignalOp>(prb.getSignal().getDefiningOp())) {
        // Just a local signal, probably not directly external bus unless mapped to port
        return false;
      }
    }
  }
  return false;
}

void ForwardConstrainPass::reportPathSatisfiability(Operation *terminator, const TraceContext &ctx, llvm::StringSet<> &busWhitelist) {
  std::string constraintsStr;
  llvm::raw_string_ostream os(constraintsStr);
  resolveConstraintNames(ctx.constraints, os);
  
  std::string targetMsg;
  if (auto drvOp = dyn_cast<llhd::DrvOp>(terminator)) {
    targetMsg = "Hits register/wire drive: " + findNamedSignalBackward(drvOp.getSignal());
  } else if (auto condBrOp = dyn_cast<cf::CondBranchOp>(terminator)) {
    targetMsg = "Hits control flow branch at " + condBrOp->getBlock()->getParentOp()->getName().getStringRef().str();
  } else {
    targetMsg = "Hits unknown endpoint";
  }

  llvm::outs() << "Path sensitized to polarity " << ctx.expectedPolarity << " -> " << targetMsg << "\n";
  if (!constraintsStr.empty()) {
    llvm::outs() << "  Requires Constraints: [" << constraintsStr << "]\n";
  } else {
    llvm::outs() << "  No additional constraints required.\n";
  }

  if (applyConstraints) {
    Builder builder(terminator->getContext());
    for (const auto &pair : ctx.constraints) {
      Value constraintVal = pair.first;
      int reqValue = pair.second;
      
      std::string valName = getSSAValueName(constraintVal);
      if (valName.empty()) {
        SmallVector<std::pair<std::string, int>, 1> fallbackName;
        resolveConstraintsBackward(constraintVal, reqValue, fallbackName);
        if (!fallbackName.empty()) {
          valName = fallbackName[0].first;
        }
      }
      
      bool allowedToMutate = false;
      if (!busWhitelist.empty()) {
        // Track 1: Whitelist Enforcement
        if (busWhitelist.contains(valName)) {
          allowedToMutate = true;
        }
      } else {
        // Track 2: Topological Auto-Detection
        if (isTopologicalBusSignal(constraintVal)) {
          allowedToMutate = true;
        }
      }

      if (allowedToMutate) {
        if (auto opResult = dyn_cast<OpResult>(constraintVal)) {
          Operation *defOp = opResult.getDefiningOp();
          OpBuilder ob(defOp);
          // Insert constant AFTER the defining op so it's valid
          ob.setInsertionPointAfter(defOp);
          auto type = constraintVal.getType();
          if (auto intType = dyn_cast<IntegerType>(type)) {
            auto constOp = ob.create<hw::ConstantOp>(defOp->getLoc(), intType, reqValue);
            constraintVal.replaceAllUsesWith(constOp.getResult());
            llvm::outs() << "    [Mutation] Replaced '" << valName << "' w/ hw.constant " << reqValue << " (Width: " << intType.getWidth() << ")\n";
          }
        } else if (auto blkArg = dyn_cast<BlockArgument>(constraintVal)) {
          Block *block = blkArg.getOwner();
          OpBuilder ob(block, block->begin());
          auto type = constraintVal.getType();
          if (auto intType = dyn_cast<IntegerType>(type)) {
            auto constOp = ob.create<hw::ConstantOp>(builder.getUnknownLoc(), intType, reqValue);
            constraintVal.replaceAllUsesWith(constOp.getResult());
            llvm::outs() << "    [Mutation] Replaced ViewPort '" << valName << "' w/ hw.constant " << reqValue << "\n";
          }
        }
      } else if (!valName.empty()) {
          llvm::outs() << "    [Mutation skipped] '" << valName << "' (Not in whitelist / not auto-detected as external bus)\n";
      }
    }
  }
}

} // end anonymous namespace
