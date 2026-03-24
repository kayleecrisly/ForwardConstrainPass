#include "mlir/IR/PatternMatch.h"
#include "mlir/IR/Builders.h"
#include "llvm/Support/raw_ostream.h"
#include "llvm/ADT/SmallPtrSet.h"
#include "llvm/ADT/DenseMap.h"
#include "llvm/ADT/SetVector.h"
#include "mlir/Pass/Pass.h"
#include "circt/Dialect/HW/HWOps.h"
#include "circt/Dialect/LLHD/IR/LLHDOps.h"
#include "circt/Dialect/Comb/CombOps.h"

#define GEN_PASS_DECL_SIGNALFLOWANALYSIS
#define GEN_PASS_DEF_SIGNALFLOWANALYSIS
#include "Passes.h.inc"

using namespace mlir;
using namespace circt;

// Use explicit namespace to avoid ambiguity with mlir::impl
namespace qemu_passes {
namespace impl = ::impl;
} // namespace qemu_passes

namespace {

//===----------------------------------------------------------------------===//
// Signal Flow Analysis Pass
//
// Purpose: Track CPU read/write control signals (e.g., reg_we, reg_re) and
// analyze their data flow propagation through the design.
//
// This pass uses data flow analysis instead of condition branch matching,
// making it suitable for designs where control signals are used in
// combinational logic rather than directly in conditional branches.
//===----------------------------------------------------------------------===//

// Helper: Extract SSA value name by printing the defining op
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

// Helper: Get signal name from llhd.sig operation
static std::string getSignalName(llhd::SignalOp sigOp) {
  if (auto nameAttr = sigOp.getNameAttr()) {
    return nameAttr.getValue().str();
  }
  // Fallback to SSA value name
  return getSSAValueName(sigOp.getResult());
}

// Represents a node in the signal flow graph
struct SignalFlowNode {
  Value value;
  std::string name;
  std::string opType;
  SmallVector<SignalFlowNode*, 4> uses;
  Operation *defOp = nullptr;
  
  // For module instance connections
  std::string instanceName;
  std::string portName;
};

// Main analysis class
class SignalFlowAnalyzer {
public:
  SignalFlowAnalyzer(ModuleOp module, StringRef targetSignal)
      : moduleOp(module), targetSignalName(targetSignal.str()) {}
  
  // Run the analysis
  void analyze() {
    llvm::errs() << "\n[Signal Flow Analysis] Tracing signal: " << targetSignalName << "\n\n";
    
    // Step 1: Find the target signal definition
    if (!findTargetSignal()) {
      llvm::errs() << "  ERROR: Signal '" << targetSignalName << "' not found\n";
      return;
    }
    
    llvm::errs() << "  Found signal: " << targetSignalName << "\n";
    if (targetDefOp) {
      llvm::errs() << "  Definition: ";
      targetDefOp->print(llvm::errs());
      llvm::errs() << "\n\n";
    }
    
    // Step 2: Find all probes of this signal
    findAllProbes();
    
    // Step 3: Trace data flow from each probe
    llvm::errs() << "  Propagation paths:\n";
    llvm::errs() << "  ─────────────────\n";
    
    for (auto &source : flowSources) {
      traceUse(nullptr, source, 2, targetSignalName); // Start tracing directly from source value
    }
    
    // Step 4: Report driven signals
    llvm::errs() << "\n  Driven signals (when " << targetSignalName << "=1):\n";
    llvm::errs() << "  ─────────────────────────────────────────\n";
    
    for (auto &driven : drivenSignals) {
      llvm::errs() << "    - " << driven.first();
      if (!driven.second.empty()) {
        llvm::errs() << " (via " << driven.second << ")";
      }
      llvm::errs() << "\n";
    }
    
    // Step 5: Report module instances that receive this signal
    llvm::errs() << "\n  Module instances receiving this signal:\n";
    llvm::errs() << "  ─────────────────────────────────────────\n";
    
    for (auto &inst : instanceConnections) {
      llvm::errs() << "    - " << inst.first << " (port: " << inst.second << ")\n";
    }
    
    llvm::errs() << "\n";
  }
  
private:
  ModuleOp moduleOp;
  std::string targetSignalName;
  Operation *targetDefOp = nullptr;
  Value targetSignal;
  std::string structBaseName; // "tl_i"
  std::string structFieldName; // "a_opcode"
  
  SmallVector<llhd::PrbOp, 8> probeOps;
  SmallVector<Value, 8> flowSources; // Starting points for flow tracing (prb results or extract results)
  llvm::StringMap<std::string> drivenSignals;  // signal -> path description
  SmallVector<std::pair<std::string, std::string>, 8> instanceConnections;  // instance -> port
  
  // Find the target signal definition
  bool findTargetSignal() {
    bool found = false;
    
    moduleOp.walk([&](llhd::SignalOp sigOp) {
      std::string name = getSignalName(sigOp);
      
      // Check for exact match
      if (name == targetSignalName) {
        targetDefOp = sigOp.getOperation();
        targetSignal = sigOp.getResult();
        found = true;
        return WalkResult::interrupt();
      }
      
      // Check for struct match "tl_i.a_opcode" -> find "tl_i"
      if (targetSignalName.find('.') != std::string::npos) {
         size_t dotPos = targetSignalName.find('.');
         structBaseName = targetSignalName.substr(0, dotPos);
         structFieldName = targetSignalName.substr(dotPos + 1);
         
         if (name == structBaseName) {
            targetDefOp = sigOp.getOperation();
            targetSignal = sigOp.getResult();
            found = true;
            return WalkResult::interrupt();
         }
      }
      
      return WalkResult::advance();
    });
    
    return found;
  }
  
  // Find all probes of the target signal
  void findAllProbes() {
    moduleOp.walk([&](llhd::PrbOp prbOp) {
      Value sig = prbOp.getSignal();
      
      // Unwrap sig.extract chains
      while (auto ex = sig.getDefiningOp<llhd::SigExtractOp>()) {
        sig = ex.getInput();
      }
      
      if (sig == targetSignal) {
        probeOps.push_back(prbOp);
        
        // If we are looking for a struct field, we need to find where it is extracted
        if (!structFieldName.empty()) {
            Value probedVal = prbOp.getResult();
            for (Operation *user : probedVal.getUsers()) {
                if (auto extOp = dyn_cast<hw::StructExtractOp>(user)) {
                    if (extOp.getFieldName() == structFieldName) {
                        flowSources.push_back(extOp.getResult());
                    }
                }
            }
        } else {
            // Normal signal
            flowSources.push_back(prbOp.getResult());
        }
      }
    });
    
    llvm::errs() << "  Found " << flowSources.size() << " source(s) for tracing (probes or extractions)\n\n";
  }
  
  // Trace helper (Removed traceFromProbe as we now use generic traceUse)
  
  // Recursively trace the use of a value
  void traceUse(Operation *user, Value usedValue, int indent, std::string path) {
    // If user is null (entry point), we iterate over users of usedValue
    if (!user) {
        for (Operation *u : usedValue.getUsers()) {
            traceUse(u, usedValue, indent, path);
        }
        return;
    }
    std::string indentStr(indent, ' ');
    
    // Handle comb.and - signal is ANDed with something
    if (auto andOp = dyn_cast<comb::AndOp>(user)) {
      std::string newName = getSSAValueName(andOp.getResult());
      llvm::errs() << indentStr << "├─ comb.and → " << (newName.empty() ? "<unnamed>" : newName) << "\n";
      
      // Continue tracing the result
      for (Operation *nextUser : andOp.getResult().getUsers()) {
        traceUse(nextUser, andOp.getResult(), indent + 3, path + " → " + newName);
      }
    }
    // Handle comb.or
    else if (auto orOp = dyn_cast<comb::OrOp>(user)) {
      std::string newName = getSSAValueName(orOp.getResult());
      llvm::errs() << indentStr << "├─ comb.or → " << (newName.empty() ? "<unnamed>" : newName) << "\n";
      
      for (Operation *nextUser : orOp.getResult().getUsers()) {
        traceUse(nextUser, orOp.getResult(), indent + 3, path + " → " + newName);
      }
    }
    // Handle comb.xor (often used for inversion)
    else if (auto xorOp = dyn_cast<comb::XorOp>(user)) {
      std::string newName = getSSAValueName(xorOp.getResult());
      llvm::errs() << indentStr << "├─ comb.xor → " << (newName.empty() ? "<unnamed>" : newName) << "\n";
      
      for (Operation *nextUser : xorOp.getResult().getUsers()) {
        traceUse(nextUser, xorOp.getResult(), indent + 3, path + " → " + newName);
      }
      for (Operation *nextUser : xorOp.getResult().getUsers()) {
        traceUse(nextUser, xorOp.getResult(), indent + 3, path + " → " + newName);
      }
    }
    // Handle comb.icmp - tracing the result of comparison
    else if (auto icmpOp = dyn_cast<comb::ICmpOp>(user)) {
      std::string newName = getSSAValueName(icmpOp.getResult());
      llvm::errs() << indentStr << "├─ comb.icmp → " << (newName.empty() ? "<unnamed>" : newName) << "\n";
      
      for (Operation *nextUser : icmpOp.getResult().getUsers()) {
        traceUse(nextUser, icmpOp.getResult(), indent + 3, path + " → " + newName);
      }
    }
    // Handle llhd.drv - signal is driving another signal
    else if (auto drvOp = dyn_cast<llhd::DrvOp>(user)) {
      Value drivenSig = drvOp.getSignal();
      std::string drivenName;
      
      if (auto sigOp = drivenSig.getDefiningOp<llhd::SignalOp>()) {
        drivenName = getSignalName(sigOp);
      } else {
        drivenName = getSSAValueName(drivenSig);
      }
      
      llvm::errs() << indentStr << "└─ llhd.drv → " << drivenName << " ✓\n";
      drivenSignals[drivenName] = path;
    }
    // Handle hw.instance - passed to a submodule
    else if (auto instOp = dyn_cast<hw::InstanceOp>(user)) {
      std::string instName = instOp.getInstanceName().str();
      std::string moduleName = instOp.getModuleName().str();
      
      // Find which port this value is connected to
      for (unsigned i = 0; i < instOp.getNumOperands(); i++) {
        if (instOp.getOperand(i) == usedValue) {
          std::string portName = instOp.getInputName(i).str();
          llvm::errs() << indentStr << "└─ hw.instance \"" << instName 
                       << "\" @" << moduleName << " (port: " << portName << ") ●\n";
          instanceConnections.push_back({instName + " @" + moduleName, portName});
          break;
        }
      }
    }
    else if (auto muxOp = dyn_cast<comb::MuxOp>(user)) {
      std::string newName = getSSAValueName(muxOp.getResult());
      llvm::errs() << indentStr << "├─ comb.mux → " << (newName.empty() ? "<unnamed>" : newName) << "\n";
      
      for (Operation *nextUser : muxOp.getResult().getUsers()) {
        traceUse(nextUser, muxOp.getResult(), indent + 3, path + " → " + newName);
      }
    }
    else if (auto extractOp = dyn_cast<hw::StructExtractOp>(user)) {
       // Just pass through struct extraction if it wasn't the starting point
       std::string fieldName = extractOp.getFieldName().str();
       if (fieldName != structFieldName) {
          // Tracing a different field? Only if we are tracing the whole struct
          if (structFieldName.empty()) {
             llvm::errs() << indentStr << "├─ hw.struct_extract \"" << fieldName << "\"\n";
             for (Operation *nextUser : extractOp.getResult().getUsers()) {
                traceUse(nextUser, extractOp.getResult(), indent + 3, path + "." + fieldName);
             }
          }
       }
    }
    // Other operations
    else {
      llvm::errs() << indentStr << "├─ " << user->getName().getStringRef() << "\n";
    }
  }
};

//===----------------------------------------------------------------------===//
// Pass Implementation
//===----------------------------------------------------------------------===//

struct SignalFlowAnalysisPass
    : public qemu_passes::impl::SignalFlowAnalysisBase<SignalFlowAnalysisPass> {
  
  SignalFlowAnalysisPass() = default;
  SignalFlowAnalysisPass(const SignalFlowAnalysisOptions &opts) {
    rwSignal = opts.rwSignal;
    writeSignal = opts.writeSignal;
    readSignal = opts.readSignal;
  }
  
  void runOnOperation() override {
    ModuleOp moduleOp = getOperation();
    
    // Determine which signals to trace
    std::vector<std::string> signalsToTrace;
    
    // If both write and read signals are specified, trace both
    if (!writeSignal.empty()) {
      signalsToTrace.push_back(writeSignal);
    }
    if (!readSignal.empty()) {
      signalsToTrace.push_back(readSignal);
    }
    // Otherwise use the combined rw signal
    if (signalsToTrace.empty() && !rwSignal.empty()) {
      signalsToTrace.push_back(rwSignal);
    }
    
    if (signalsToTrace.empty()) {
      llvm::errs() << "[Signal Flow Analysis] No signals specified to trace\n";
      llvm::errs() << "  Use --rw-signal=<name> or --write-signal=<name> --read-signal=<name>\n";
      return;
    }
    
    llvm::errs() << std::string(60, '=') << "\n";
    llvm::errs() << "SIGNAL FLOW ANALYSIS\n";
    llvm::errs() << std::string(60, '=') << "\n";
    
    // Run analysis for each signal
    for (const auto &sigName : signalsToTrace) {
      SignalFlowAnalyzer analyzer(moduleOp, sigName);
      analyzer.analyze();
    }
    
    llvm::errs() << std::string(60, '=') << "\n";
  }
};

} // namespace
