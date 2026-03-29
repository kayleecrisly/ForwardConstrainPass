//===- tool_main.cpp - QEMU Passes Driver ---------------------------------===//
//
// Driver for QEMU conversion passes:
// 1. clock-signal-detection - Detect and mark clock signals (two-level)
// 2. drv-classification - Classify drv operations
// 3. CSE (MLIR builtin) - Common subexpression elimination for deduplication
// 4. clock-drv-removal - Remove filterable clock topology
// 5. dff-demo - APB control signal inference and optimization
// 6. comb-logic-extract - Extract combinational logic for QEMU update_state()
// 7. qemu-emit-c - Emit QEMU device C code from annotated IR
//
// Usage:
//   qemu-passes input.mlir --clock-signal-detection
//   qemu-passes input.mlir --drv-classification
//   qemu-passes input.mlir --clock-drv-removal
//   qemu-passes input.mlir --dff-demo
//   qemu-passes input.mlir --comb-logic-extract
//   qemu-passes input.mlir --qemu-emit-c
//   qemu-passes input.mlir --all-passes -o output.mlir
//
//===----------------------------------------------------------------------===//

#include "mlir/IR/MLIRContext.h"
#include "mlir/IR/BuiltinOps.h"
#include "mlir/IR/DialectRegistry.h"
#include "mlir/Pass/Pass.h"
#include "mlir/Pass/PassManager.h"
#include "mlir/Parser/Parser.h"
#include "mlir/Support/LogicalResult.h"
#include "mlir/Dialect/ControlFlow/IR/ControlFlow.h"
#include "mlir/Dialect/Func/IR/FuncOps.h"
#include "mlir/Dialect/SCF/IR/SCF.h"
#include "mlir/Transforms/Passes.h"  // For CSE pass

#include "llvm/Support/InitLLVM.h"
#include "llvm/Support/CommandLine.h"
#include "llvm/Support/WithColor.h"
#include "llvm/Support/FileSystem.h"
#include "llvm/Support/raw_ostream.h"

// CIRCT Dialects
#include "circt/Dialect/HW/HWDialect.h"
#include "circt/Dialect/SV/SVDialect.h"
#include "circt/Dialect/Comb/CombDialect.h"
#include "circt/Dialect/Seq/SeqDialect.h"
#include "circt/Dialect/LLHD/IR/LLHDDialect.h"

// TableGen 生成的 Pass 声明
#define GEN_PASS_DECL_CLOCKSIGNALDETECTION
#define GEN_PASS_DECL_DRVCLASSIFICATION
#define GEN_PASS_DECL_CLOCKDRVREMOVAL
#define GEN_PASS_DECL_DFFDEMO
#define GEN_PASS_DECL_FORWARDCONSTRAIN
#define GEN_PASS_DECL_SIGNALFLOWANALYSIS
#define GEN_PASS_DECL_COMBLOGICEXTRACT
#define GEN_PASS_DECL_QEMUEMITC
#include "Passes.h.inc"

using namespace mlir;

//===----------------------------------------------------------------------===//
// Command line options
//===----------------------------------------------------------------------===//

static llvm::cl::opt<std::string> inputFilename(
    llvm::cl::Positional,
    llvm::cl::desc("<input .mlir>"),
    llvm::cl::Required);

static llvm::cl::opt<std::string> outputFilename(
    "o",
    llvm::cl::desc("Output file (default: stdout)"),
    llvm::cl::value_desc("filename"),
    llvm::cl::init("-"));

static llvm::cl::opt<bool> runClockDetection(
    "clock-signal-detection",
    llvm::cl::desc("Run clock signal detection pass"),
    llvm::cl::init(false));

static llvm::cl::opt<bool> runDrvClassification(
    "drv-classification",
    llvm::cl::desc("Run drv classification pass"),
    llvm::cl::init(false));

static llvm::cl::opt<bool> runClockDrvRemoval(
    "clock-drv-removal",
    llvm::cl::desc("Run clock drv removal pass"),
    llvm::cl::init(false));

static llvm::cl::opt<bool> runDffDemo(
    "dff-demo",
    llvm::cl::desc("Run APB control signal inference and optimization pass"),
    llvm::cl::init(false));

// DffDemo signal configuration options
static llvm::cl::opt<std::string> dffRwSignal(
    "rw-signal",
    llvm::cl::desc("Combined read/write signal for single-signal protocols (write=1, read=0)"),
    llvm::cl::value_desc("signal"),
    llvm::cl::init("pwrite"));

static llvm::cl::opt<std::string> dffWriteSignal(
    "write-signal",
    llvm::cl::desc("Write path control signal for dual-signal protocols"),
    llvm::cl::value_desc("signal"),
    llvm::cl::init(""));

static llvm::cl::opt<std::string> dffReadSignal(
    "read-signal",
    llvm::cl::desc("Read path control signal for dual-signal protocols"),
    llvm::cl::value_desc("signal"),
    llvm::cl::init(""));

static llvm::cl::opt<unsigned long long> dffWriteVal(
    "write-val",
    llvm::cl::desc("Target value for write signal (default: 1)"),
    llvm::cl::value_desc("value"),
    llvm::cl::init(1));

static llvm::cl::opt<unsigned long long> dffReadVal(
    "read-val",
    llvm::cl::desc("Target value for read signal (default: 1)"),
    llvm::cl::value_desc("value"),
    llvm::cl::init(1));

static llvm::cl::opt<bool> runSignalFlowAnalysis(
    "signal-flow-analysis",
    llvm::cl::desc("Run signal flow analysis pass (data flow based)"),
    llvm::cl::init(false));

static llvm::cl::opt<bool> runForwardConstrain(
    "forward-constrain",
    llvm::cl::desc("Run forward constrain pass"),
    llvm::cl::init(false));

static llvm::cl::opt<std::string> fcTargetSignal(
    "fc-target-signal",
    llvm::cl::desc("Target signal for forward constrain pass (default: pwrite)"),
    llvm::cl::value_desc("signal"),
    llvm::cl::init("pwrite"));


static llvm::cl::opt<bool> runCombLogicExtract(
    "comb-logic-extract",
    llvm::cl::desc("Run combinational logic extraction pass"),
    llvm::cl::init(false));

static llvm::cl::opt<bool> runQEMUEmitC(
    "qemu-emit-c",
    llvm::cl::desc("Run QEMU C code emission pass"),
    llvm::cl::init(false));

static llvm::cl::opt<std::string> qemuOutputDir(
    "qemu-output-dir",
    llvm::cl::desc("Output directory for generated QEMU C files"),
    llvm::cl::value_desc("dir"),
    llvm::cl::init("qemu-output"));

static llvm::cl::opt<bool> runAllPasses(
    "all-passes",
    llvm::cl::desc("Run all six passes in order (includes CSE)"),
    llvm::cl::init(false));

static llvm::cl::opt<bool> emitOutput(
    "emit-output",
    llvm::cl::desc("Emit the transformed MLIR output"),
    llvm::cl::init(false));

//===----------------------------------------------------------------------===//
// Main
//===----------------------------------------------------------------------===//

int main(int argc, char **argv) {
  llvm::InitLLVM y(argc, argv);

  llvm::cl::ParseCommandLineOptions(argc, argv,
      "QEMU Conversion Passes for LLHD IR\n\n"
      "Usage:\n"
      "  qemu-passes <input.mlir> --clock-signal-detection\n"
      "  qemu-passes <input.mlir> --drv-classification\n"
      "  qemu-passes <input.mlir> --clock-drv-removal\n"
      "  qemu-passes <input.mlir> --dff-demo\n"
      "  qemu-passes <input.mlir> --comb-logic-extract\n"
      "  qemu-passes <input.mlir> --all-passes -o output.mlir\n"
  );

  // Create MLIR context and register dialects
  MLIRContext context;
  DialectRegistry registry;
  registry.insert<
    circt::hw::HWDialect,
    circt::sv::SVDialect,
    circt::comb::CombDialect,
    circt::seq::SeqDialect,
    circt::llhd::LLHDDialect,
    mlir::cf::ControlFlowDialect,
    mlir::func::FuncDialect,
    mlir::scf::SCFDialect
  >();
  context.appendDialectRegistry(registry);
  context.loadAllAvailableDialects();

  // Parse input file
  OwningOpRef<ModuleOp> module = parseSourceFile<ModuleOp>(inputFilename, &context);
  if (!module) {
    llvm::WithColor::error() << "Failed to parse input MLIR: " << inputFilename << "\n";
    return 1;
  }

  // Create PassManager
  PassManager pm(&context);
  pm.enableVerifier(true);

  // Add passes based on command line options
  if (runAllPasses) {
    pm.addPass(createClockSignalDetection());
    pm.addPass(createDrvClassification());
    pm.addPass(createCSEPass());  // CSE before clock removal for deduplication
    pm.addPass(createClockDrvRemoval());
    {
      DffDemoOptions opts;
      opts.rwSignal = dffRwSignal;
      opts.writeSignal = dffWriteSignal;
      opts.readSignal = dffReadSignal;
      opts.writeVal = dffWriteVal;
      opts.readVal = dffReadVal;
      pm.addPass(createDffDemo(opts));
    }
    pm.addPass(createCombLogicExtract());
  } else {
    if (runClockDetection) {
      pm.addPass(createClockSignalDetection());
    }
    if (runDrvClassification) {
      pm.addPass(createDrvClassification());
    }
    if (runClockDrvRemoval) {
      pm.addPass(createClockDrvRemoval());
    }
    if (runDffDemo) {
      DffDemoOptions opts;
      opts.rwSignal = dffRwSignal;
      opts.writeSignal = dffWriteSignal;
      opts.readSignal = dffReadSignal;
      opts.writeVal = dffWriteVal;
      opts.readVal = dffReadVal;
      pm.addPass(createDffDemo(opts));
    }
    if (runSignalFlowAnalysis) {
      SignalFlowAnalysisOptions opts;
      opts.rwSignal = dffRwSignal;
      opts.writeSignal = dffWriteSignal;
      opts.readSignal = dffReadSignal;
      pm.addPass(createSignalFlowAnalysis(opts));
    }
    if (runForwardConstrain) {
      ForwardConstrainOptions opts;
      opts.targetSignal = fcTargetSignal;
      pm.addPass(createForwardConstrain(opts));
    }
    if (runCombLogicExtract) {
      pm.addPass(createCombLogicExtract());
    }
    if (runQEMUEmitC) {
      QEMUEmitCOptions opts;
      opts.outputDir = qemuOutputDir;
      pm.addPass(createQEMUEmitC(opts));
    }
  }

  // Check if any pass was specified
  if (!runClockDetection && !runDrvClassification &&
      !runClockDrvRemoval && !runDffDemo && !runSignalFlowAnalysis && !runCombLogicExtract &&
      !runForwardConstrain && !runQEMUEmitC && !runAllPasses) {
    llvm::outs() << "No pass specified. Available passes:\n";
    llvm::outs() << "  --clock-signal-detection  Detect and mark clock signals\n";
    llvm::outs() << "  --drv-classification      Classify drv operations\n";
    llvm::outs() << "  --clock-drv-removal       Remove clock-related drvs\n";
    llvm::outs() << "  --dff-demo                APB control signal inference\n";
    llvm::outs() << "  --forward-constrain       Forward constrain extraction\n";
    llvm::outs() << "  --signal-flow-analysis    Signal flow analysis (data flow based)\n";
    llvm::outs() << "  --comb-logic-extract      Extract combinational logic\n";
    llvm::outs() << "  --qemu-emit-c             Emit QEMU C code from IR\n";
    llvm::outs() << "  --all-passes              Run all passes in order\n";
    llvm::outs() << "\nRunning all passes by default...\n\n";
    pm.addPass(createClockSignalDetection());
    pm.addPass(createDrvClassification());
    pm.addPass(createCSEPass());  // CSE before clock removal
    pm.addPass(createClockDrvRemoval());
    {
      DffDemoOptions opts;
      opts.rwSignal = dffRwSignal;
      opts.writeSignal = dffWriteSignal;
      opts.readSignal = dffReadSignal;
      opts.writeVal = dffWriteVal;
      opts.readVal = dffReadVal;
      pm.addPass(createDffDemo(opts));
    }
    pm.addPass(createCombLogicExtract());
    // Note: qemu-emit-c not included in default - run explicitly with --qemu-emit-c
  }

  // Run passes
  if (failed(pm.run(*module))) {
    llvm::WithColor::error() << "Pass execution failed\n";
    return 1;
  }

  // Output the result
  if (emitOutput || outputFilename != "-") {
    if (outputFilename != "-") {
      std::error_code ec;
      llvm::raw_fd_ostream os(outputFilename, ec, llvm::sys::fs::OF_Text);
      if (ec) {
        llvm::WithColor::error() << "Could not open output file: " << ec.message() << "\n";
        return 1;
      }
      module->print(os);
      llvm::outs() << "\nOutput written to: " << outputFilename << "\n";
    } else {
      llvm::outs() << "\n========================================\n";
      llvm::outs() << "Transformed LLHD IR:\n";
      llvm::outs() << "========================================\n\n";
      module->print(llvm::outs());
    }
  }

  return 0;
}
