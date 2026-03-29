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

  /// The original signal that this trace started from.
  /// Used by traceIntoBlock to determine value vs control-flow influence.
  Value rootValue;

  /// True when the root signal is wider than 1 bit.
  /// In this case expectedPolarity carries no semantic meaning and is
  /// suppressed in output.
  bool isMultiBit = false;

  TraceContext(int initialPolarity) : expectedPolarity(initialPolarity) {}

  /// Clone constructor for branching
  TraceContext(const TraceContext &other)
    : paths(other.paths),
      constraints(other.constraints),
      expectedPolarity(other.expectedPolarity),
      trackedFieldName(other.trackedFieldName),
      rootValue(other.rootValue),
      isMultiBit(other.isMultiBit) {}
};

struct ForwardConstrainPass : public ::impl::ForwardConstrainBase<ForwardConstrainPass> {
  using ForwardConstrainBase::ForwardConstrainBase; // Inherit constructors

  void runOnOperation() override;

private:
  void findTracingRoots(hw::HWModuleOp module, StringRef targetName);
  void processTracingRoot(Value rootValue);
  void propagateConstraint(Value currentVal, TraceContext ctx);
  void traceIntoBlock(Block *block, TraceContext ctx,
                      SmallPtrSet<Block *, 8> &visitedBlocks);
  void resolveConstraintNames(const DenseMap<Value, int> &constraints, llvm::raw_string_ostream &os);
  void reportPathSatisfiability(Operation *terminator, const TraceContext &ctx, llvm::StringSet<> &busWhitelist);
  void reportControlFlowInfluencedDrive(Operation *drvOp, const TraceContext &ctx);

  // Helper for tracking visited nodes to prevent infinite loops in combinational cycles
  SmallPtrSet<Operation *, 16> globalVisited;

  // Tracks root Values already being traced to avoid duplicate tracing when the
  // same signal appears as a port in multiple modules (e.g. after cross-module
  // propagation via hw.instance).
  DenseSet<Value> tracedRoots;

  // Whitelist of bus signals for mutation
  llvm::StringSet<> parsedBusSignalsWhitelist;
};

void ForwardConstrainPass::runOnOperation() {
  ModuleOp topModule = getOperation();
  StringRef targetName = targetSignal;
  
  LLVM_DEBUG(llvm::dbgs() << "Starting ForwardConstrainPass targeting signal: "
                          << targetName << "\n");

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
  tracedRoots.clear();

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
  // Deduplicate: skip if this Value is already being traced (happens when the
  // same port appears in multiple modules and hw.instance cross-propagation
  // would cause the inner module port to be re-traced independently).
  if (!tracedRoots.insert(rootValue).second)
    return;

  // Initial polarity is 1 (active-high). For multi-bit signals polarity is
  // not meaningful but is kept for uniform handling through 1-bit gate logic.
  TraceContext initialCtx(1);
  initialCtx.rootValue = rootValue;

  // Mark multi-bit signals so polarity output is suppressed.
  if (auto intType = dyn_cast<IntegerType>(rootValue.getType()))
    initialCtx.isMultiBit = (intType.getWidth() > 1);

  propagateConstraint(rootValue, initialCtx);
}

// Forward declaration (defined below alongside resolveConstraintsBackward)
static std::string findNamedSignalBackward(Value val);

/// Backward def-use reachability: can we trace from `target` back to `source`?
/// Correctly follows SSA block arguments (phi nodes) through predecessor
/// terminators, so values threaded via cf.cond_br block args are handled.
static bool isDefUseReachable(Value target, Value source,
                               SmallPtrSet<Value, 16> &visited) {
  if (target == source) return true;
  if (!visited.insert(target).second) return false;

  // Handle SSA block arguments (phi nodes): trace each predecessor's
  // corresponding operand. This covers values passed through cf.br /
  // cf.cond_br block argument lists rather than computed by an op.
  if (auto blockArg = dyn_cast<BlockArgument>(target)) {
    Block *block = blockArg.getOwner();
    unsigned argIdx = blockArg.getArgNumber();
    for (Block *pred : block->getPredecessors()) {
      Operation *term = pred->getTerminator();
      if (auto brOp = dyn_cast<cf::BranchOp>(term)) {
        if (argIdx < brOp.getDestOperands().size())
          if (isDefUseReachable(brOp.getDestOperands()[argIdx], source, visited))
            return true;
      } else if (auto condBrOp = dyn_cast<cf::CondBranchOp>(term)) {
        if (condBrOp.getTrueDest() == block &&
            argIdx < condBrOp.getTrueDestOperands().size())
          if (isDefUseReachable(condBrOp.getTrueDestOperands()[argIdx], source, visited))
            return true;
        if (condBrOp.getFalseDest() == block &&
            argIdx < condBrOp.getFalseDestOperands().size())
          if (isDefUseReachable(condBrOp.getFalseDestOperands()[argIdx], source, visited))
            return true;
      }
    }
    return false;
  }

  Operation *defOp = target.getDefiningOp();
  if (!defOp) return false;

  for (Value operand : defOp->getOperands())
    if (isDefUseReachable(operand, source, visited))
      return true;

  return false;
}

void ForwardConstrainPass::reportControlFlowInfluencedDrive(
    Operation *drvOp, const TraceContext &ctx) {
  std::string constraintsStr;
  llvm::raw_string_ostream os(constraintsStr);
  resolveConstraintNames(ctx.constraints, os);

  std::string sigName = findNamedSignalBackward(
      cast<llhd::DrvOp>(drvOp).getSignal());

  if (ctx.isMultiBit)
    llvm::outs() << "Path -> Hits register/wire drive [ctrl-flow]: " << sigName << "\n";
  else
    llvm::outs() << "Path sensitized to polarity " << ctx.expectedPolarity
                 << " -> Hits register/wire drive [ctrl-flow]: " << sigName << "\n";
  if (!constraintsStr.empty())
    llvm::outs() << "  Requires Constraints: [" << constraintsStr << "]\n";
  else
    llvm::outs() << "  No additional constraints required.\n";
  llvm::outs() << "  Note: driven value does not depend on traced signal\n";
}

void ForwardConstrainPass::traceIntoBlock(
    Block *block, TraceContext ctx,
    SmallPtrSet<Block *, 8> &visitedBlocks) {
  if (!visitedBlocks.insert(block).second) return;

  for (Operation &op : *block) {
    if (auto drvOp = dyn_cast<llhd::DrvOp>(&op)) {
      Value drivenVal = drvOp.getValue();
      SmallPtrSet<Value, 16> reachVisited;
      bool valueFromRoot =
          ctx.rootValue && isDefUseReachable(drivenVal, ctx.rootValue, reachVisited);

      if (valueFromRoot) {
        // Driven value directly depends on the traced signal: real causal write.
        reportPathSatisfiability(drvOp, ctx, parsedBusSignalsWhitelist);
      } else {
        // Driven value does NOT depend on the traced signal.
        // Determine whether the driven value is a zero/false constant:
        // such drives are "register reset to default" appearing in false branches
        // of inactive conditions and carry no information about the traced path.
        bool isZeroConst = false;
        if (auto constOp =
                dyn_cast_or_null<hw::ConstantOp>(drivenVal.getDefiningOp()))
          isZeroConst = constOp.getValue().isZero();

        if (!isZeroConst) {
          // Non-zero ctrl-flow drive: the traced signal controls WHETHER this
          // register is written (even though the data doesn't come from it).
          reportControlFlowInfluencedDrive(drvOp, ctx);

          // Two-phase write-enable pattern: when the traced signal asserts a 1-bit
          // write-enable wire to constant-true, follow its probes into the
          // downstream register-update process.
          // Example: gpio_sw_data_wen = 1'b1  →  (separate process)  →  gpio_sw_data = pwdata
          //
          // We require the driven value to be constant-true (all-ones).  This
          // distinguishes genuine write-enable assertions from actual 1-bit data
          // writes (e.g. gpio_int_level_sync driven by pwdata[0]) — those are NOT
          // write-enables and following their probes would produce false positives.
          //
          // AXI4/AHB buses do NOT use this two-phase pattern: their write-enable
          // conditions (wvalid AND wready, HWRITE AND HSEL) feed directly into
          // the driven value via combinational logic, so isDefUseReachable catches
          // them as direct data-flow paths without needing probe-following.
          auto inoutTy = dyn_cast<hw::InOutType>(drvOp.getSignal().getType());
          bool isConstTrue = false;
          if (auto constOp =
                  dyn_cast_or_null<hw::ConstantOp>(drivenVal.getDefiningOp()))
            isConstTrue = constOp.getValue().isAllOnes();
          if (inoutTy && inoutTy.getElementType().isInteger(1) && isConstTrue) {
            Value sigVal = drvOp.getSignal();
            for (Operation *sigUser : sigVal.getUsers()) {
              if (auto prbOp = dyn_cast<llhd::PrbOp>(sigUser))
                propagateConstraint(prbOp.getResult(), ctx);
            }
          }
        }
        // Zero-const drives (e.g. gpio_sw_data_wen=false in inactive branch)
        // are silently suppressed — they are structural noise, not causal paths.
      }

    } else if (auto brOp = dyn_cast<cf::BranchOp>(&op)) {
      // Unconditional branch: follow into successor
      traceIntoBlock(brOp.getDest(), ctx, visitedBlocks);

    } else if (auto innerCondBr = dyn_cast<cf::CondBranchOp>(&op)) {
      SmallPtrSet<Value, 16> visited;
      if (ctx.rootValue &&
          isDefUseReachable(innerCondBr.getCondition(), ctx.rootValue, visited)) {
        // Nested branch also controlled by rootValue: split polarity
        TraceContext falseCtx = ctx;
        falseCtx.expectedPolarity = 1 - falseCtx.expectedPolarity;
        traceIntoBlock(innerCondBr.getTrueDest(),  ctx,      visitedBlocks);
        traceIntoBlock(innerCondBr.getFalseDest(), falseCtx, visitedBlocks);
      } else {
        // Nested branch whose condition is NOT derived from the traced signal
        // (e.g. address decode: addr==X?).  Follow BOTH successors with the
        // same context — the branch just selects between different registers,
        // it does not change the sensitization conditions of the traced signal.
        traceIntoBlock(innerCondBr.getTrueDest(),  ctx, visitedBlocks);
        traceIntoBlock(innerCondBr.getFalseDest(), ctx, visitedBlocks);
      }
    }
    // llhd.wait and other terminators: do not follow (prevents loop-header re-entry)
  }
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
      // Sensitize AND gate: all other inputs must be all-ones to pass the signal.
      // For i1 signals all-ones = 1; for wider signals use -1 (two's complement
      // all-ones) so the display value matches the actual bit width.
      for (Value opnd : andOp.getOperands()) {
        if (opnd != currentVal) {
          auto intType = dyn_cast<IntegerType>(opnd.getType());
          nextCtx.constraints[opnd] =
              (intType && intType.getWidth() == 1) ? 1 : -1;
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
      // XOR with all-ones is a NOT gate only for 1-bit signals.
      // For multi-bit signals XOR with all-ones is bitwise inversion, which does
      // not map to a simple polarity flip, so we skip the flip in that case.
      bool isOneBit = currentVal.getType().isInteger(1);
      bool hasConstAllOnes = false;
      for (Value opnd : xorOp.getOperands()) {
        if (opnd != currentVal) {
          if (auto constOp = dyn_cast_or_null<hw::ConstantOp>(opnd.getDefiningOp())) {
            if (constOp.getValue().isAllOnes()) hasConstAllOnes = true;
          } else {
            // Sensitize XOR gate without inversion: other input must be 0
            nextCtx.constraints[opnd] = 0;
          }
        }
      }
      if (isOneBit && hasConstAllOnes)
        nextCtx.expectedPolarity = 1 - nextCtx.expectedPolarity;
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
      // For equality/inequality checks against constants.
      // Always record the positive constraint "currentVal = constVal" so that
      // multi-bit enum signals (e.g. a_opcode) carry their exact required value
      // through the path, rather than only surfacing negative (_neq) constraints
      // from downstream OR/AND gate sensitization.
      if (icmpOp.getPredicate() == comb::ICmpPredicate::eq ||
          icmpOp.getPredicate() == comb::ICmpPredicate::ceq ||
          icmpOp.getPredicate() == comb::ICmpPredicate::weq) {
        for (Value opnd : icmpOp.getOperands()) {
          if (opnd != currentVal) {
            if (auto constOp = dyn_cast_or_null<hw::ConstantOp>(opnd.getDefiningOp())) {
              int64_t constVal = constOp.getValue().getSExtValue();
              // Polarity: icmp eq x, 0  acts as NOT for 1-bit signals.
              // For multi-bit signals the polarity flip is kept for consistency.
              if (constOp.getValue().isZero())
                nextCtx.expectedPolarity = 1 - nextCtx.expectedPolarity;
              // Record the exact required value of the traced signal.
              nextCtx.constraints[currentVal] = constVal;
            }
          }
        }
      } else if (icmpOp.getPredicate() == comb::ICmpPredicate::ne ||
                 icmpOp.getPredicate() == comb::ICmpPredicate::cne ||
                 icmpOp.getPredicate() == comb::ICmpPredicate::wne) {
        for (Value opnd : icmpOp.getOperands()) {
          if (opnd != currentVal) {
            if (auto constOp = dyn_cast_or_null<hw::ConstantOp>(opnd.getDefiningOp())) {
              if (constOp.getValue().isAllOnes())
                nextCtx.expectedPolarity = 1 - nextCtx.expectedPolarity;
              // ne does not pin the signal to a single value, so no positive
              // constraint is added here.
            }
          }
        }
      }
      propagateConstraint(icmpOp.getResult(), nextCtx);
    } else if (auto drvOp = dyn_cast<llhd::DrvOp>(user)) {
      // Reached a drive endpoint.  Check whether the driven VALUE actually
      // depends on the root signal (data-flow path) or merely whether the
      // root controls WHEN this drive happens (control-flow path).
      Value drivenVal = drvOp.getValue();
      SmallPtrSet<Value, 16> reachVisited;
      bool valueFromRoot =
          nextCtx.rootValue &&
          isDefUseReachable(drivenVal, nextCtx.rootValue, reachVisited);

      if (valueFromRoot) {
        reportPathSatisfiability(drvOp, nextCtx, parsedBusSignalsWhitelist);
        // Direct data-flow drive: always follow probes so the signal's value
        // can continue flowing through the rest of the design.
        Value sigVal = drvOp.getSignal();
        for (Operation *sigUser : sigVal.getUsers()) {
          if (auto prbOp = dyn_cast<llhd::PrbOp>(sigUser)) {
            tracedRoots.insert(prbOp.getResult());
            propagateConstraint(prbOp.getResult(), nextCtx);
          }
        }
      } else {
        // Driven value does not come from the traced signal (ctrl-flow path).
        // Suppress zero-constant drives (register resets in inactive branches).
        bool isZeroConst = false;
        if (auto constOp =
                dyn_cast_or_null<hw::ConstantOp>(drivenVal.getDefiningOp()))
          isZeroConst = constOp.getValue().isZero();

        if (!isZeroConst) {
          reportControlFlowInfluencedDrive(drvOp, nextCtx);
          // Two-phase write-enable: only follow probes when the signal is a
          // 1-bit write-enable being driven with constant true.
          // See the same guard in traceIntoBlock for the detailed rationale.
          auto inoutTy = dyn_cast<hw::InOutType>(drvOp.getSignal().getType());
          bool isConstTrue = false;
          if (auto constOp =
                  dyn_cast_or_null<hw::ConstantOp>(drivenVal.getDefiningOp()))
            isConstTrue = constOp.getValue().isAllOnes();
          if (inoutTy && inoutTy.getElementType().isInteger(1) && isConstTrue) {
            Value sigVal = drvOp.getSignal();
            for (Operation *sigUser : sigVal.getUsers()) {
              if (auto prbOp = dyn_cast<llhd::PrbOp>(sigUser)) {
                tracedRoots.insert(prbOp.getResult());
                propagateConstraint(prbOp.getResult(), nextCtx);
              }
            }
          }
        }
      }
    } else if (auto condBrOp = dyn_cast<cf::CondBranchOp>(user)) {
      if (currentVal == condBrOp.getCondition()) {
        // Case 1: traced value is the branch condition.
        // Scan both successor blocks for downstream drives/branches.
        // We do NOT report the branch itself as an endpoint here since
        // traceIntoBlock will find the real endpoints in the successor blocks.
        SmallPtrSet<Block *, 8> visitedBlocks;
        TraceContext falseCtx = nextCtx;
        falseCtx.expectedPolarity = 1 - falseCtx.expectedPolarity;
        traceIntoBlock(condBrOp.getTrueDest(),  nextCtx,  visitedBlocks);
        traceIntoBlock(condBrOp.getFalseDest(), falseCtx, visitedBlocks);
      } else {
        // Case 2: traced value is passed as a block argument.
        // Follow the corresponding block argument in the successor.
        auto trueOps  = condBrOp.getTrueDestOperands();
        auto falseOps = condBrOp.getFalseDestOperands();

        for (unsigned i = 0; i < trueOps.size(); ++i)
          if (trueOps[i] == currentVal)
            propagateConstraint(condBrOp.getTrueDest()->getArgument(i), nextCtx);

        for (unsigned i = 0; i < falseOps.size(); ++i)
          if (falseOps[i] == currentVal)
            propagateConstraint(condBrOp.getFalseDest()->getArgument(i), nextCtx);
      }
    } else if (auto extractOp = dyn_cast<comb::ExtractOp>(user)) {
      // Bit extraction: the traced signal (or some of its bits) flows into a
      // narrower value. Update isMultiBit to reflect the result width so
      // polarity output is correct for 1-bit extracts.
      TraceContext extractCtx = nextCtx;
      if (auto resultType = dyn_cast<IntegerType>(extractOp.getResult().getType()))
        extractCtx.isMultiBit = (resultType.getWidth() > 1);
      propagateConstraint(extractOp.getResult(), extractCtx);
    } else if (auto concatOp = dyn_cast<comb::ConcatOp>(user)) {
      // Bit concatenation: the traced signal becomes part of a wider value.
      // Mark as multi-bit because individual bit polarity is no longer
      // meaningful for the concatenated result.
      TraceContext concatCtx = nextCtx;
      if (auto resultType = dyn_cast<IntegerType>(concatOp.getResult().getType()))
        concatCtx.isMultiBit = (resultType.getWidth() > 1);
      propagateConstraint(concatOp.getResult(), concatCtx);
    } else if (auto instOp = dyn_cast<hw::InstanceOp>(user)) {
      // Cross-module propagation
      for (unsigned i = 0; i < instOp.getNumOperands(); ++i) {
        if (instOp.getOperand(i) == currentVal) {
          auto targetMod = dyn_cast_or_null<hw::HWModuleOp>(
              SymbolTable::lookupNearestSymbolFrom(instOp, instOp.getModuleNameAttr()));
          if (targetMod) {
            Value portVal = targetMod.getBodyBlock()->getArgument(i);
            // Only trace into the inner module if it hasn't been traced yet.
            // This prevents duplicate output when the same signal appears as
            // a port in multiple modules (e.g. gpio_top → gpio_apbif → gpio0)
            // and findTracingRoots would independently trace each one.
            if (!tracedRoots.insert(portVal).second)
              continue;
            // Update rootValue to the inner module's port so that
            // isDefUseReachable checks inside the inner module compare
            // against the correct local BlockArgument (not the outer port).
            TraceContext innerCtx = nextCtx;
            innerCtx.rootValue = portVal;
            propagateConstraint(portVal, innerCtx);
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

  // Collect positive constraints (name → value) for redundancy elimination.
  // e.g. "a_opcode = 1" makes "a_opcode_neq = 0" redundant.
  llvm::StringMap<int> positiveConstraints;
  for (const auto &item : flattened) {
    if (item.first.find("_neq") == std::string::npos)
      positiveConstraints[item.first] = item.second;
  }

  // Deduplicate and filter redundant _neq entries.
  llvm::StringSet<> seen;
  bool first = true;
  for (const auto &item : flattened) {
    const std::string &name = item.first;
    int val = item.second;

    // Drop "signal_neq = Y" when a positive "signal = X" already exists (X ≠ Y).
    if (name.size() > 4 && name.substr(name.size() - 4) == "_neq") {
      std::string baseName = name.substr(0, name.size() - 4);
      auto it = positiveConstraints.find(baseName);
      if (it != positiveConstraints.end() && it->second != val)
        continue;
    }

    std::string key = name + "=" + std::to_string(val);
    if (seen.insert(key).second) {
      if (!first) os << ", ";
      os << name << " = " << val;
      first = false;
    }
  }
}

/// Returns true if the port name looks like a clock or reset signal that must
/// never be replaced by a constant during mutation.
static bool isClockOrResetPortName(StringRef name) {
  // Common naming conventions across APB, AXI, AHB, TL-UL, etc.
  return name == "clk" || name == "clk_i" || name == "clock" ||
         name == "rst" || name == "rst_n" || name == "rst_ni" ||
         name == "reset" || name == "reset_n" || name == "aresetn" ||
         name == "aclk" || name.starts_with("clk_") ||
         name.starts_with("clock_") || name.ends_with("_clk") ||
         name.ends_with("_clock") || name.ends_with("_rst") ||
         name.ends_with("_rst_n") || name.ends_with("_reset");
}

// Helper to check topological auto-detect rule mapping back to external inputs.
// Returns false for clock/reset ports — mutating those would destroy the design.
static bool isTopologicalBusSignal(Value val) {
  if (auto arg = dyn_cast<BlockArgument>(val)) {
    // Check the port name before allowing mutation
    if (auto hwMod = dyn_cast<hw::HWModuleOp>(
            arg.getParentRegion()->getParentOp())) {
      if (arg.getArgNumber() < hwMod.getNumInputPorts()) {
        StringRef portName =
            hwMod.getInputNameAttr(arg.getArgNumber()).getValue();
        if (isClockOrResetPortName(portName))
          return false; // Never mutate clock/reset
      }
    }
    return true;
  }
  if (auto opResult = dyn_cast<OpResult>(val)) {
    Operation *defOp = opResult.getDefiningOp();
    if (auto ext = dyn_cast<hw::StructExtractOp>(defOp)) {
      // Also guard struct fields named like clocks/resets
      if (isClockOrResetPortName(ext.getFieldNameAttr().getValue()))
        return false;
      return isa<BlockArgument>(ext.getInput());
    }
    if (auto uExt = dyn_cast<hw::UnionExtractOp>(defOp)) {
      if (isClockOrResetPortName(uExt.getFieldNameAttr().getValue()))
        return false;
      return isa<BlockArgument>(uExt.getInput());
    }
    if (auto sigExt = dyn_cast<llhd::SigExtractOp>(defOp)) {
      return isa<BlockArgument>(sigExt.getInput());
    }
    if (auto prb = dyn_cast<llhd::PrbOp>(defOp)) {
      if (dyn_cast_or_null<llhd::SignalOp>(prb.getSignal().getDefiningOp()))
        return false; // Local signal, not a direct bus port
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

  if (ctx.isMultiBit)
    llvm::outs() << "Path -> " << targetMsg << "\n";
  else
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
