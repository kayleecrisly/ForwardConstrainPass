#include "mlir/IR/PatternMatch.h"
#include "mlir/IR/Builders.h"
#include "llvm/Support/raw_ostream.h"
#include "llvm/ADT/SmallPtrSet.h"
#include "llvm/ADT/DenseMap.h"
#include "mlir/Pass/Pass.h"
#include "mlir/Transforms/GreedyPatternRewriteDriver.h"
#include "circt/Dialect/HW/HWOps.h"
#include "circt/Dialect/SV/SVOps.h"
#include "circt/Dialect/Seq/SeqOps.h"
#include "circt/Dialect/LLHD/IR/LLHDOps.h"
#include "circt/Dialect/Comb/CombOps.h"
#include "mlir/Dialect/ControlFlow/IR/ControlFlowOps.h"

// 只生成 per-pass 的声明/定义；不要手写 create/注册函数
#define GEN_PASS_DECL_DFFDEMO
#define GEN_PASS_DEF_DFFDEMO
#include "Passes.h.inc"

using namespace mlir;
using namespace circt;

namespace {

// Helper: unwrap llhd.sig.extract chains to get base signal
static Value unwrapSigExtract(Value sig) {
  while (auto ex = sig.getDefiningOp<llhd::SigExtractOp>()) {
    sig = ex.getInput();
  }
  return sig;
}

// Helper: Extract SSA value name by printing the defining op and parsing result
// This allows us to match internal signals like %reg_we that don't have a name attribute
static std::string getSSAValueName(Value val) {
  if (!val) return "";
  
  // For OpResult, print the defining op and extract the result name
  if (auto opResult = dyn_cast<OpResult>(val)) {
    Operation *defOp = opResult.getDefiningOp();
    if (!defOp) return "";
    
    // Print the operation to a string
    std::string opStr;
    llvm::raw_string_ostream os(opStr);
    defOp->print(os, OpPrintingFlags().useLocalScope());
    os.flush();
    
    // Parse out the SSA value name from the printed string
    // Format: "%name = op ..." or "%0 = op ..."
    size_t resultIdx = opResult.getResultNumber();
    
    // For single result, look for "%name ="
    if (defOp->getNumResults() == 1) {
      size_t eqPos = opStr.find(" = ");
      if (eqPos != std::string::npos && opStr.length() > 1 && opStr[0] == '%') {
        std::string name = opStr.substr(1, eqPos - 1);
        // Check if it's a meaningful name (not just a number)
        if (!name.empty() && !std::all_of(name.begin(), name.end(), ::isdigit)) {
          return name;
        }
      }
    }
    // For multiple results, look for "%name#idx" pattern
    else {
      size_t commaPos = opStr.find(", ");
      size_t eqPos = opStr.find(" = ");
      if (commaPos == std::string::npos) commaPos = eqPos;
      if (commaPos != std::string::npos && opStr.length() > 1 && opStr[0] == '%') {
        std::string allResults = opStr.substr(1, commaPos - 1);
        // Split by ", " and get the specific result
        // This is a simplified approach - just return the first name for now
        size_t hashPos = allResults.find('#');
        if (hashPos != std::string::npos) {
          std::string baseName = allResults.substr(0, hashPos);
          if (!baseName.empty() && !std::all_of(baseName.begin(), baseName.end(), ::isdigit)) {
            return baseName;
          }
        }
      }
    }
  }
  
  return "";
}

// Enhanced traceSignal: supports multi-layer NOT (xor, icmp) + SigExtract
// Returns (signalName, isInverted)
// - isInverted tracks odd/even NOT parity
// - Supports: comb.xor(x, allones), comb.icmp eq/ne with 0/1 constants
// - Limitation: seen map in caller doesn't handle complex inversion combinations
// Enhanced traceSignal: supports multi-layer NOT (xor, icmp) + SigExtract
// Returns (signalName, isInverted)
// - isInverted tracks odd/even NOT parity
std::pair<std::string, bool> traceSignal(Value val) {
  bool invertParity = false;
  Value cur = val;

  // Loop to peel multi-layer NOT operations (max depth 32 to prevent infinite loops)
  for (int depth = 0; depth < 32; ++depth) {
    // 1. Handle comb.xor(x, allones) or comb.xor(allones, x)
    if (auto xorOp = cur.getDefiningOp<comb::XorOp>()) {
      if (xorOp.getNumOperands() == 2) {
        Value lhs = xorOp.getOperand(0);
        Value rhs = xorOp.getOperand(1);

        // Check RHS is allones constant
        if (auto constOp = rhs.getDefiningOp<hw::ConstantOp>()) {
          if (constOp.getValue().isAllOnes()) {
            invertParity = !invertParity;
            cur = lhs;
            continue;
          }
        }

        // Check LHS is allones constant
        if (auto constOp = lhs.getDefiningOp<hw::ConstantOp>()) {
          if (constOp.getValue().isAllOnes()) {
            invertParity = !invertParity;
            cur = rhs;
            continue;
          }
        }
      }
    }

    // 2. Handle comb.extract (Just pass through)
    if (auto extractOp = cur.getDefiningOp<comb::ExtractOp>()) {
        cur = extractOp.getInput();
        continue;
    }

    // 3. Handle comb.icmp for i1 NOT patterns
    if (auto icmpOp = cur.getDefiningOp<comb::ICmpOp>()) {
      Value lhs = icmpOp.getLhs();
      Value rhs = icmpOp.getRhs();
      auto pred = icmpOp.getPredicate();

      // Try to match: cmp(x, const) or cmp(const, x)
      Value nonConst;
      APInt constVal;
      bool constOnLeft = false;

      if (auto constOp = rhs.getDefiningOp<hw::ConstantOp>()) {
        nonConst = lhs;
        constVal = constOp.getValue();
      } else if (auto constOp = lhs.getDefiningOp<hw::ConstantOp>()) {
        nonConst = rhs;
        constVal = constOp.getValue();
        constOnLeft = true;
      }

      if (nonConst) {
        // Only handle i1 comparisons with 0/1
        if (constVal.getBitWidth() == 1) {
          bool constIsZero = constVal.isZero();
          bool constIsOne = constVal.isOne();

          if (constIsZero || constIsOne) {
            // Normalize predicate if constant is on left
            auto effectivePred = pred;
            if (constOnLeft) {
              // Swap predicate: const cmp x -> x cmp_rev const
              if (pred == comb::ICmpPredicate::eq) effectivePred = comb::ICmpPredicate::eq;
              else if (pred == comb::ICmpPredicate::ne) effectivePred = comb::ICmpPredicate::ne;
              // For eq/ne, swap doesn't change semantics
            }

            // i1 semantics:
            // x == 0 -> !x  (invert)
            // x != 0 -> x   (no change)
            // x == 1 -> x   (no change)
            // x != 1 -> !x  (invert)
            if (effectivePred == comb::ICmpPredicate::eq && constIsZero) {
              invertParity = !invertParity;
              cur = nonConst;
              continue;
            } else if (effectivePred == comb::ICmpPredicate::ne && constIsZero) {
              // x != 0 is identity for i1
              cur = nonConst;
              continue;
            } else if (effectivePred == comb::ICmpPredicate::eq && constIsOne) {
              // x == 1 is identity for i1
              cur = nonConst;
              continue;
            } else if (effectivePred == comb::ICmpPredicate::ne && constIsOne) {
              invertParity = !invertParity;
              cur = nonConst;
              continue;
            }
          }
        }
      }
    }

    // No more NOT layers to peel
    break;
  }


  // Now try to extract signal name from llhd.prb
  if (auto prbOp = cur.getDefiningOp<llhd::PrbOp>()) {
    Value sig = prbOp.getSignal();

    // Unwrap SigExtract chains
    sig = unwrapSigExtract(sig);

    // Try to get name from llhd.sig (SignalOp)
    if (auto sigOp = sig.getDefiningOp<llhd::SignalOp>()) {
      if (auto nameAttr = sigOp.getNameAttr()) {
        return {nameAttr.getValue().str(), invertParity};
      }
      // Fallback: try to get SSA value name (e.g., %reg_we)
      std::string ssaName = getSSAValueName(sig);
      if (!ssaName.empty()) {
        return {ssaName, invertParity};
      }
    }

    // Also support BlockArgument (module port) - try to get name from hw.module
    if (auto blockArg = dyn_cast<BlockArgument>(sig)) {
      Operation *parentOp = blockArg.getOwner()->getParentOp();

      // Try hw.module
      if (auto hwMod = dyn_cast<hw::HWModuleOp>(parentOp)) {
        unsigned idx = blockArg.getArgNumber();
        StringRef argName = hwMod.getArgName(idx);
        if (!argName.empty()) {
          return {argName.str(), invertParity};
        }
      }
    }
  }
  
  // Directly Check BlockArgument logic (in case proper llhd.prb wasn't used logic or direct wire)
  if (auto blockArg = dyn_cast<BlockArgument>(cur)) {
      Operation *parentOp = blockArg.getOwner()->getParentOp();
      if (auto hwMod = dyn_cast<hw::HWModuleOp>(parentOp)) {
        unsigned idx = blockArg.getArgNumber();
        StringRef argName = hwMod.getArgName(idx);
        if (!argName.empty()) {
            return {argName.str(), invertParity};
        }
      }
  }

  return {std::string(), false};
}

//===----------------------------------------------------------------------===//
// Method B: Control Flow Backtracking Analysis
// Recursively analyze condition tree from cf::CondBranchOp
//===----------------------------------------------------------------------===//

// Signal requirement: what value a signal needs to be for the condition to be true
// Signal requirement: what value a signal needs to be for the condition to be true
struct SignalRequirement {
  std::string signalName;
  uint64_t requiredValue;  // Specific value requirement
};

// Result of condition tree analysis
struct ConditionInfo {
  SmallVector<SignalRequirement> requirements;
  SmallVector<Operation*> unknownOps;  // Operations that couldn't be analyzed
  bool hasAlternatives = false;        // True if OR created multiple paths
};

// Forward declaration
static void analyzeConditionRecursive(Value val, bool wantTrue, ConditionInfo &info, int depth);

// Helper: check if a constant is all-ones
static bool isAllOnesConstant(Value val) {
  if (auto constOp = val.getDefiningOp<hw::ConstantOp>()) {
    return constOp.getValue().isAllOnes();
  }
  return false;
}

// Helper: check if a constant is zero
static bool isZeroConstant(Value val) {
  if (auto constOp = val.getDefiningOp<hw::ConstantOp>()) {
    return constOp.getValue().isZero();
  }
  return false;
}

// Helper: get signal name from llhd.prb operation
// Returns empty string if no name can be determined
static std::string getSignalNameFromProbe(llhd::PrbOp prbOp) {
  Value sig = prbOp.getSignal();
  sig = unwrapSigExtract(sig);
  
  if (auto sigOp = sig.getDefiningOp<llhd::SignalOp>()) {
    if (auto nameAttr = sigOp.getNameAttr()) {
      return nameAttr.getValue().str();
    }
    // Fallback: try to get SSA value name (e.g., %reg_we)
    std::string ssaName = getSSAValueName(sig);
    if (!ssaName.empty()) {
      return ssaName;
    }
  }
  
  if (auto blockArg = dyn_cast<BlockArgument>(sig)) {
    Operation *parentOp = blockArg.getOwner()->getParentOp();
    if (auto hwMod = dyn_cast<hw::HWModuleOp>(parentOp)) {
      unsigned idx = blockArg.getArgNumber();
      StringRef argName = hwMod.getArgName(idx);
      if (!argName.empty()) {
        return argName.str();
      }
    }
  }
  
  return "";
}

// Main recursive analysis function
static void analyzeConditionRecursive(Value val, bool wantTrue, ConditionInfo &info, int depth) {
  // Prevent infinite recursion
  if (depth > 32) return;
  
  // Handle BlockArgument (module port)
  if (auto blockArg = dyn_cast<BlockArgument>(val)) {
    Operation *parentOp = blockArg.getOwner()->getParentOp();
    if (auto hwMod = dyn_cast<hw::HWModuleOp>(parentOp)) {
      unsigned idx = blockArg.getArgNumber();
      StringRef name = hwMod.getArgName(idx);
      if (!name.empty()) {
        info.requirements.push_back({name.str(), wantTrue ? 1UL : 0UL});
      }
    }
    return;
  }
  
  Operation *defOp = val.getDefiningOp();
  if (!defOp) return;
  
  // Handle constants - no requirements needed
  if (isa<hw::ConstantOp>(defOp)) {
    return;
  }
  
  // Handle comb.and
  if (auto andOp = dyn_cast<comb::AndOp>(defOp)) {
    if (wantTrue) {
      // To make AND true, ALL operands must be true
      for (Value operand : andOp.getOperands()) {
        analyzeConditionRecursive(operand, true, info, depth + 1);
      }
    } else {
      // To make AND false, at least ONE operand must be false
      // This creates alternatives - for simplicity, we skip this case
      info.hasAlternatives = true;
    }
    return;
  }
  
  // Handle comb.or
  if (auto orOp = dyn_cast<comb::OrOp>(defOp)) {
    if (wantTrue) {
      // To make OR true, at least ONE operand must be true
      // This creates alternatives - for simplicity, we analyze first operand only
      info.hasAlternatives = true;
      if (orOp.getNumOperands() > 0) {
        analyzeConditionRecursive(orOp.getOperand(0), true, info, depth + 1);
      }
    } else {
      // To make OR false, ALL operands must be false
      for (Value operand : orOp.getOperands()) {
        analyzeConditionRecursive(operand, false, info, depth + 1);
      }
    }
    return;
  }
  
  // Handle comb.xor (detect NOT pattern: xor(x, all-ones))
  if (auto xorOp = dyn_cast<comb::XorOp>(defOp)) {
    if (xorOp.getNumOperands() == 2) {
      Value lhs = xorOp.getOperand(0);
      Value rhs = xorOp.getOperand(1);
      
      if (isAllOnesConstant(rhs)) {
        // xor(x, all-ones) = NOT(x)
        analyzeConditionRecursive(lhs, !wantTrue, info, depth + 1);
        return;
      }
      if (isAllOnesConstant(lhs)) {
        // xor(all-ones, x) = NOT(x)
        analyzeConditionRecursive(rhs, !wantTrue, info, depth + 1);
        return;
      }
    }
    // Other XOR patterns - cannot analyze
    info.unknownOps.push_back(defOp);
    return;
  }
  
  // Handle comb.icmp (detect NOT patterns for i1)
  if (auto icmpOp = dyn_cast<comb::ICmpOp>(defOp)) {
    Value lhs = icmpOp.getLhs();
    Value rhs = icmpOp.getRhs();
    auto pred = icmpOp.getPredicate();
    
    // Check for comparison with constant
    Value signalVal;
    APInt constVal;
    bool constOnLeft = false;
    
    if (auto constOp = rhs.getDefiningOp<hw::ConstantOp>()) {
      signalVal = lhs;
      constVal = constOp.getValue();
    } else if (auto constOp = lhs.getDefiningOp<hw::ConstantOp>()) {
      signalVal = rhs;
      constVal = constOp.getValue();
      constOnLeft = true;
    }
    
    if (signalVal) {
       // Support EQ comparison with specific value
       if (pred == comb::ICmpPredicate::eq) {
           // If we want TRUE, then signal MUST EQUAL constVal
           if (wantTrue) {
               // Logic handled by traceSignal check below
           }
       }
    }

    // Simplified Logic: Direct Signal Tracing + Value Check
    // If we have (signal == const) and wantTrue=true -> req: signal = const
    if (signalVal && pred == comb::ICmpPredicate::eq && wantTrue) {
         auto [name, inv] = traceSignal(signalVal);
         if (!name.empty() && !inv) {
             // Only support non-inverted signal trace for direct value match for now
             uint64_t intVal = constVal.getLimitedValue();
             info.requirements.push_back({name, intVal});
             return;
         }
    }
    
    // Existing 1-bit logic fallback for legacy support or boolean signals
    bool isCompareWithZero = (constVal.isZero());
    bool isCompareWithOne = (constVal.getBitWidth() == 1 && constVal.isOne());

    if (signalVal && (isCompareWithZero || isCompareWithOne)) {
      bool invertRequired = false;
      
      // x == 0 means !x, x != 0 means x
      // x == 1 means x, x != 1 means !x
      if (pred == comb::ICmpPredicate::eq && isCompareWithZero) {
        invertRequired = true;  // x == 0 -> need !x
      } else if (pred == comb::ICmpPredicate::ne && isCompareWithOne) {
        invertRequired = true;  // x != 1 -> need !x
      }
      
      bool effectiveWant = invertRequired ? !wantTrue : wantTrue;
      // map bool back to 1/0
      uint64_t target = effectiveWant ? 1 : 0;
      
      // Use recursion to find signal name, but we need to intercept to set value
      // This is getting complicated mixing bool/int logic.
      // Let's resolve the name directly.
      auto [name, inv] = traceSignal(signalVal);
      if (!name.empty()) {
          uint64_t finalVal = target;
          if (inv) finalVal = (target == 1) ? 0 : 1;
          info.requirements.push_back({name, finalVal});
          return;
      }
    }
    
    // Other icmp patterns - cannot analyze
    info.unknownOps.push_back(defOp);
    return;
  }
  
  // Handle llhd.prb (signal probe) - leaf node
  if (auto prbOp = dyn_cast<llhd::PrbOp>(defOp)) {
    StringRef signalName = getSignalNameFromProbe(prbOp);
    if (!signalName.empty()) {
      info.requirements.push_back({signalName.str(), wantTrue ? 1UL : 0UL});
    }
    return;
  }
  
  // Handle comb.extract - continue tracing the source
  if (auto extractOp = dyn_cast<comb::ExtractOp>(defOp)) {
    analyzeConditionRecursive(extractOp.getInput(), wantTrue, info, depth + 1);
    return;
  }

  
  // Generic Fallback: Try traceSignal
  // This handles comb.xor (NOT), complex extracts, etc.
  auto [name, inv] = traceSignal(val);
  if (!name.empty()) {
      bool effectiveWant = inv ? !wantTrue : wantTrue;
      info.requirements.push_back({name, effectiveWant ? 1UL : 0UL});
      return;
  }

  // Unknown operation - record it
  info.unknownOps.push_back(defOp);
}

// Analyze a condition tree starting from a value
static ConditionInfo analyzeConditionTree(Value condition) {
  ConditionInfo info;
  analyzeConditionRecursive(condition, /*wantTrue=*/true, info, /*depth=*/0);
  return info;
}

struct DffDemoPass : public ::impl::DffDemoBase<DffDemoPass> {
  using DffDemoBase::DffDemoBase;  // Inherit constructors from base
  
  void runOnOperation() override {
    ModuleOp mod = getOperation();
    
    // 检测模式：双信号模式 vs 单信号模式
    bool isDualSignalMode = !writeSignal.empty() && !readSignal.empty();
    
    if (isDualSignalMode) {
      llvm::errs() << "[Analysis] Starting Control Signal Inference (Dual-Signal Mode)...\n";
      llvm::errs() << "  Write signal: " << writeSignal << "\n";
      llvm::errs() << "  Read signal: " << readSignal << "\n";
    } else {
      llvm::errs() << "[Analysis] Starting Control Signal Inference (Single-Signal Mode)...\n";
      llvm::errs() << "  R/W signal: " << rwSignal << " (write=1, read=0)\n";
    }

    // 收集路径信息 - Method B: Start from cf::CondBranchOp
    struct PathInfo {
      SmallVector<std::pair<std::string, uint64_t>> controls;
      bool isWrite;
      cf::CondBranchOp branchOp;  // Changed from comb::AndOp
    };
    SmallVector<PathInfo, 8> allPaths;

    // Method B: Traverse from control flow branch points
    mod.walk([&](cf::CondBranchOp brOp) {
      Value condition = brOp.getCondition();
      
      // Use the new recursive condition tree analysis
      ConditionInfo condInfo = analyzeConditionTree(condition);
      
      if (condInfo.requirements.empty())
        return;
      
      // Deduplicate requirements
      llvm::SmallDenseMap<StringRef, uint64_t> seen;
      SmallVector<std::pair<std::string, uint64_t>> controls;
      
      bool hasRwSignal = false;
      bool isWritePath = false;
      bool isReadPath = false;
      
      for (const auto &req : condInfo.requirements) {
        if (req.signalName.empty())
          continue;
        
        if (isDualSignalMode) {
          // 双信号模式：分别检查写信号和读信号
          // Use values from options
          if (req.signalName == writeSignal && req.requiredValue == writeVal) {
            hasRwSignal = true;
            isWritePath = true;
            seen.insert({req.signalName, req.requiredValue});
            continue;
          }
          if (req.signalName == readSignal && req.requiredValue == readVal) {
            hasRwSignal = true;
            isReadPath = true;
            seen.insert({req.signalName, req.requiredValue});
            continue;
          }
        } else {
          // 单信号模式：信号=1是写，信号=0是读
          if (req.signalName == rwSignal) {
            hasRwSignal = true;
            // Legacy assumption for single signal: 1=write, 0=read
            // Could strictly use writeVal/readVal here too if configured
            isWritePath = (req.requiredValue == 1);
            isReadPath = (req.requiredValue == 0);
            seen.insert({req.signalName, req.requiredValue});
            continue;
          }
        }
        
        controls.push_back({req.signalName, req.requiredValue});
        seen.insert({req.signalName, req.requiredValue});
      }
      
      if (!hasRwSignal)
        return;
      
      llvm::errs() << "\n[Found Trigger Condition] at " << brOp.getLoc() << "\n";
      if (isDualSignalMode) {
        if (isWritePath)
          llvm::errs() << "  Path type: Write (" << writeSignal << "=" << writeVal << ")\n";
        else if (isReadPath)
          llvm::errs() << "  Path type: Read (" << readSignal << "=" << readVal << ")\n";
      } else {
        llvm::errs() << "  Path type: " << (isWritePath ? "Write" : "Read") 
                     << " (" << rwSignal << "=" << (isWritePath ? "1" : "0") << ")\n";
      }
      
      // Report unknown operations if any
      if (!condInfo.unknownOps.empty()) {
        llvm::errs() << "  Warning: " << condInfo.unknownOps.size() 
                     << " operation(s) could not be analyzed\n";
      }
      if (condInfo.hasAlternatives) {
        llvm::errs() << "  Note: Condition has OR alternatives (partial analysis)\n";
      }
      
      llvm::errs() << "  To activate this path, set:\n";
      if (isDualSignalMode) {
        if (isWritePath)
          llvm::errs() << "    " << writeSignal << " = " << writeVal << "\n";
        else if (isReadPath)
          llvm::errs() << "    " << readSignal << " = " << readVal << "\n";
      } else {
        llvm::errs() << "    " << rwSignal << " = " << (isWritePath ? "1" : "0") << "\n";
      }
      for (auto [n, v] : controls)
        llvm::errs() << "    " << n << " = " << v << "\n";
      
      // 保存路径信息
      PathInfo info;
      info.controls = controls;
      info.isWrite = isWritePath;
      info.branchOp = brOp;
      allPaths.push_back(info);
      
      // Analyze the true branch for actions
      llvm::errs() << "  -> Controls a branch (State Transition)\n";
      
      Block *trueBlock = brOp.getTrueDest();
      std::vector<Block *> worklist;
      worklist.push_back(trueBlock);
      llvm::SmallPtrSet<Block *, 8> visited;
      
      while (!worklist.empty()) {
        Block *bb = worklist.back();
        worklist.pop_back();
        if (!visited.insert(bb).second)
          continue;
        
        for (Operation &op : *bb) {
          if (auto drv = dyn_cast<llhd::DrvOp>(&op)) {
            Value target = drv.getSignal();
            Value value = drv.getValue();
            
            StringRef signalName = "(unnamed)";
            if (auto sigOp = target.getDefiningOp()) {
              if (auto nameAttr = sigOp->getAttrOfType<StringAttr>("name"))
                signalName = nameAttr.getValue();
            }
            
            llvm::errs() << "     [Action] Drives Signal: " << signalName;
            if (auto constOp = value.getDefiningOp<hw::ConstantOp>()) {
              if (constOp.getValue().isAllOnes())
                llvm::errs() << " to TRUE (Active)\n";
              else if (constOp.getValue().isZero())
                llvm::errs() << " to FALSE (Inactive)\n";
              else
                llvm::errs() << " to Constant " << constOp.getValue() << "\n";
            } else {
              llvm::errs() << " to Dynamic Value\n";
            }
          }
          
          if (auto br = dyn_cast<cf::BranchOp>(op))
            worklist.push_back(br.getDest());
          if (auto condBr = dyn_cast<cf::CondBranchOp>(op)) {
            worklist.push_back(condBr.getTrueDest());
            worklist.push_back(condBr.getFalseDest());
          }
        }
        
        if (visited.size() > 5)
          break;
      }
    });

    // Method C: Traverse Combinational Drivers (llhd.drv)
    // This catches cases where opcode directly drives an Enable signal without a branch
    mod.walk([&](llhd::DrvOp drvOp) {
       Value drivingVal = drvOp.getValue();
       
       // Only care about 1-bit enable signals for now
       Type valType = drivingVal.getType();
       if (!valType.isIntOrFloat() || valType.getIntOrFloatBitWidth() != 1)
         return;

       // Reuse the condition analysis!
       // If "drivingVal" is true, what requirements must be met?
       ConditionInfo condInfo = analyzeConditionTree(drivingVal);
       
       if (condInfo.requirements.empty())
         return;

       // Check if our target signals control this driver
       bool isWritePath = false;
       bool isReadPath = false;
       SmallVector<std::pair<std::string, uint64_t>> controls;
       
       for (const auto &req : condInfo.requirements) {
        if (req.signalName.empty()) continue;
        
        if (isDualSignalMode) {
          // Check for Match
          if (req.signalName == writeSignal && req.requiredValue == writeVal) {
            isWritePath = true;
          }
          if (req.signalName == readSignal && req.requiredValue == readVal) {
            isReadPath = true;
          }
          
          // Even if it matches read/write, we still add it to controls for reporting context
          controls.push_back({req.signalName, req.requiredValue});
          
        } else {
             // Single mode logic...
        }
       }

       if (isWritePath || isReadPath) {
           std::string drvName = "output";
           Value target = drvOp.getSignal();
           // Unwrap signal extracts
           while (auto ex = target.getDefiningOp<llhd::SigExtractOp>()) {
               target = ex.getInput();
           }
           if (auto sigOp = target.getDefiningOp<llhd::SignalOp>()) {
               if (auto attr = sigOp.getNameAttr()) drvName = attr.getValue().str();
           }

           llvm::errs() << "\n[Found Combinational Control] at " << drvOp.getLoc() << "\n";
           if (isWritePath) 
               llvm::errs() << "  Type: Write Control (Driver: " << drvName << ")\n";
           else if (isReadPath)
               llvm::errs() << "  Type: Read Control (Driver: " << drvName << ")\n";
               
            for (auto [n, v] : controls)
                llvm::errs() << "    Dependent on: " << n << " = " << v << "\n";
       }
    });

    // === 优化部分 ===
    llvm::errs() << "\n[Optimization] Analyzing phase-agnostic signals...\n";

    // 统计每个信号在读/写路径中的取值
    llvm::DenseMap<StringRef, std::pair<int, int>> writeSignalVals;
    llvm::DenseMap<StringRef, std::pair<int, int>> readSignalVals;

    for (auto &path : allPaths) {
      auto &targetMap = path.isWrite ? writeSignalVals : readSignalVals;
      for (auto [name, val] : path.controls) {
        auto &counts = targetMap[name]; // Implicit std::string -> StringRef
        if (val) // Treat any non-zero as "active" for simple counting, though this map logic might need update for full multi-bit support
          counts.first++;
        else
          counts.second++;
      }
    }

    // 找出恒定信号
    llvm::DenseMap<StringRef, bool> writeConstSignals;
    llvm::DenseMap<StringRef, bool> readConstSignals;

    for (auto &[name, counts] : writeSignalVals) {
      if (counts.first > 0 && counts.second == 0)
        writeConstSignals[name] = true;
      else if (counts.first == 0 && counts.second > 0)
        writeConstSignals[name] = false;
    }

    for (auto &[name, counts] : readSignalVals) {
      if (counts.first > 0 && counts.second == 0)
        readConstSignals[name] = true;
      else if (counts.first == 0 && counts.second > 0)
        readConstSignals[name] = false;
    }

    if (!writeConstSignals.empty()) {
      llvm::errs() << "\n  [Write Path] Phase-agnostic signals:\n";
      for (auto &[name, val] : writeConstSignals)
        llvm::errs() << "    " << name << " = " << (val ? "1" : "0") << "\n";
    }

    if (!readConstSignals.empty()) {
      llvm::errs() << "\n  [Read Path] Phase-agnostic signals:\n";
      for (auto &[name, val] : readConstSignals)
        llvm::errs() << "    " << name << " = " << (val ? "1" : "0") << "\n";
    }

    // 执行替换
    int optimizedCount = 0;
    OpBuilder builder(mod);

    for (auto &path : allPaths) {
      auto &constMap = path.isWrite ? writeConstSignals : readConstSignals;
      if (constMap.empty())
        continue;

      // Get the condition from the branch op and find the AND operation
      Value condition = path.branchOp.getCondition();
      auto andOp = condition.getDefiningOp<comb::AndOp>();
      if (!andOp)
        continue;

      builder.setInsertionPoint(andOp);
      SmallVector<Value, 4> newOperands;
      bool changed = false;

      for (Value operand : andOp.getOperands()) {
        auto [name, isInv] = traceSignal(operand);

        if (!name.empty() && constMap.count(name)) {
          bool constVal = constMap[name];
          bool finalVal = isInv ? !constVal : constVal;

          auto constOp = builder.create<hw::ConstantOp>(
            andOp.getLoc(),
            APInt(1, finalVal ? 1 : 0)
          );
          newOperands.push_back(constOp);
          changed = true;
          optimizedCount++;
        } else {
          newOperands.push_back(operand);
        }
      }

      if (changed) {
        auto newAnd = builder.create<comb::AndOp>(
          andOp.getLoc(),
          newOperands,
          false
        );
        andOp.getResult().replaceAllUsesWith(newAnd.getResult());
        andOp.erase();
      }
    }

    if (optimizedCount > 0)
      llvm::errs() << "\n[Optimization] ✓ Replaced " << optimizedCount
                   << " signal(s) with constants\n";
    else
      llvm::errs() << "\n[Optimization] No optimization needed\n";

    // === 死代码消除（DCE）部分 - 迭代执行 ===
    llvm::errs() << "\n[DCE] Removing dead code...\n";

    int totalRemovedProbes = 0;
    int totalRemovedXors = 0;
    int totalRemovedSignals = 0;
    int iteration = 0;
    bool madeProgress = true;

    while (madeProgress && iteration < 10) {
      madeProgress = false;
      iteration++;

      // 移除未使用的 XOR 操作
      SmallVector<Operation*, 8> deadXors;
      mod.walk([&](comb::XorOp xorOp) {
        if (xorOp.getResult().use_empty()) {
          deadXors.push_back(xorOp);
        }
      });

      for (Operation* op : deadXors) {
        op->erase();
        totalRemovedXors++;
        madeProgress = true;
      }

      // 移除未使用的 probe 操作
      SmallVector<Operation*, 8> deadProbes;
      mod.walk([&](llhd::PrbOp prbOp) {
        if (prbOp.getResult().use_empty()) {
          deadProbes.push_back(prbOp);
        }
      });

      for (Operation* op : deadProbes) {
        op->erase();
        totalRemovedProbes++;
        madeProgress = true;
      }

      // 移除未使用的信号定义
      SmallVector<Operation*, 8> deadSignals;
      mod.walk([&](Operation* op) {
        if (op->getName().getStringRef() == "llhd.sig") {
          if (op->getResult(0).use_empty()) {
            deadSignals.push_back(op);
          }
        }
      });

      for (Operation* op : deadSignals) {
        op->erase();
        totalRemovedSignals++;
        madeProgress = true;
      }
    }

    if (totalRemovedProbes > 0 || totalRemovedXors > 0 || totalRemovedSignals > 0) {
      llvm::errs() << "[DCE] ✓ Removed " << totalRemovedProbes << " dead probe(s), "
                   << totalRemovedXors << " dead XOR(s), and "
                   << totalRemovedSignals << " dead signal(s) in "
                   << iteration << " iteration(s)\n";
    } else {
      llvm::errs() << "[DCE] No dead code found\n";
    }
  }
};

} // namespace
