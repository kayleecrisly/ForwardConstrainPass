include "mlir/Pass/PassBase.td"

//===----------------------------------------------------------------------===//
// Pass 1: 检测时钟信号
//===----------------------------------------------------------------------===//

def ClockSignalDetection : Pass<"clock-signal-detection", "mlir::ModuleOp"> {
  let summary = "Detect and mark clock signals in LLHD IR";
  let description = [{
    Analyzes LLHD signals using two-level detection:
    1. Structural: 1-bit, in wait sensitivity list, no logic drv
    2. Trigger effect: all triggered drvs are hold mode (reg = prb reg)

    Marks clock signals with `qemu.is_clock` attribute.
    Marks clock-triggered processes with `qemu.clock_triggered` attribute.
  }];
}

//===----------------------------------------------------------------------===//
// Pass 2: 分类 drv 操作
//===----------------------------------------------------------------------===//

def DrvClassification : Pass<"drv-classification", "mlir::ModuleOp"> {
  let summary = "Classify drv operations in LLHD IR";
  let description = [{
    Classifies each llhd.drv operation into one of:
    - UNCHANGED: State unchanged (hold or not self-dependent)
    - ACCUMULATE: State accumulation (counter++/counter--)
    - LOOP_ITER: Loop iterator (single-cycle for loop)
    - COMPLEX: Complex state change

    Adds `qemu.drv_class` attribute to each drv operation.
    For ACCUMULATE, also adds `qemu.step` attribute.
  }];
}

//===----------------------------------------------------------------------===//
// Pass 3: 删除时钟拓扑链（对齐旧框架 SignalTracing.h）
//===----------------------------------------------------------------------===//

def ClockDrvRemoval : Pass<"clock-drv-removal", "mlir::ModuleOp"> {
  let summary = "Remove filterable clock topology from LLHD IR";
  let description = [{
    Removes clock signal topology from clock-triggered processes:

    1. Remove clock edge terms from trigger OR conditions
       (minimal rewrite - preserves reset edge terms and enable guards)
    2. Remove clock probes from wait observed lists
       (prevents empty wait - keeps one if all would be removed)
    3. Run safe DCE to remove dead clock-related operations
       (uses MLIR MemoryEffectOpInterface + explicit whitelist)
    4. Remove clock port connection drvs (only BlockArgument values)
    5. Remove dead clock signal definitions (llhd.sig with qemu.is_clock)

    Key design decisions (aligned with old framework SignalTracing.h):
    - Uses waitBlocks concept for stable idle/body branch detection
    - Strict edge detection: requires both direct prb AND inverted prb
    - Only processes marked with `qemu.clock_triggered` are modified
    - Reset disambiguation branches are preserved

    Prerequisites:
    - Must run after `clock-signal-detection` pass
    - Optionally run after `drv-classification` pass
  }];
}

//===----------------------------------------------------------------------===//
// Pass 4: APB 控制信号分析与优化
//===----------------------------------------------------------------------===//

def DffDemo : Pass<"dff-demo", "mlir::ModuleOp"> {
  let summary = "Protocol-agnostic control signal inference and optimization";
  let description = [{
    Analyzes control signals in LLHD IR for various bus protocols:

    1. Traces AND conditions to find trigger paths based on configurable signals
    2. Classifies paths as read or write based on control signal values
    3. Identifies phase-agnostic signals (constant across all paths)
    4. Replaces redundant signal probes with constants
    5. Performs iterative DCE to remove dead probes, XORs, and signals

    Supports two modes:
    - Single-signal mode: APB (pwrite), Wishbone (we), etc.
    - Dual-signal mode: AXI (awvalid + arvalid), etc.

    Output:
    - Reports trigger conditions and their control signal requirements
    - Reports branch-controlled state transitions
    - Reports optimization statistics
  }];

  let options = [
    Option<"rwSignal", "rw-signal", "std::string", /*default=*/"\"pwrite\"",
           "Combined read/write signal for single-signal protocols (write=1, read=0)">,
    Option<"writeSignal", "write-signal", "std::string", /*default=*/"\"\"",
           "Write path control signal for dual-signal protocols">,
    Option<"readSignal", "read-signal", "std::string", /*default=*/"\"\"",
           "Read path control signal for dual-signal protocols">,
    Option<"writeVal", "write-val", "uint64_t", /*default=*/"1",
           "Target value for write signal (default: 1)">,
    Option<"readVal", "read-val", "uint64_t", /*default=*/"1",
           "Target value for read signal (default: 1)">,
  ];
}

//===----------------------------------------------------------------------===//
// Pass 4b: Signal Flow Analysis (Data Flow Based)
//===----------------------------------------------------------------------===//

def SignalFlowAnalysis : Pass<"signal-flow-analysis", "mlir::ModuleOp"> {
  let summary = "Trace CPU read/write signals through data flow propagation";
  let description = [{
    Analyzes control signals using data flow tracking instead of condition
    branch matching. Suitable for designs where control signals are used in
    combinational logic (comb.and, comb.or, etc.) rather than directly in
    conditional branches.

    Analysis steps:
    1. Find the target signal definition (llhd.sig)
    2. Find all probes (llhd.prb) of this signal
    3. Trace data flow from each probe through combinational logic
    4. Report all signals driven by this control signal
    5. Report module instances that receive this signal

    Use cases:
    - OpenTitan TL-UL (reg_we/reg_re used in comb logic)
    - AXI (awvalid/arvalid through complex logic)
    - Any design with hierarchical register structure (prim_subreg)

    Output:
    - Propagation path diagram
    - List of driven signals when control signal is active
    - List of module instances receiving the signal
  }];

  let options = [
    Option<"rwSignal", "rw-signal", "std::string", /*default=*/"\"\"",
           "Combined read/write signal for single-signal protocols">,
    Option<"writeSignal", "write-signal", "std::string", /*default=*/"\"\"",
           "Write path control signal to trace">,
    Option<"readSignal", "read-signal", "std::string", /*default=*/"\"\"",
           "Read path control signal to trace">,
  ];
}

//===----------------------------------------------------------------------===//
// Pass 4c: Forward Constraint Extraction (Path Sensitization)
//===----------------------------------------------------------------------===//

def ForwardConstrain : Pass<"forward-constrain", "mlir::ModuleOp"> {
  let summary = "Extract path sensitization constraints and simplify bus signals";
  let description = [{
    Three-phase pass for bus signal simplification in the LLHD-to-QEMU pipeline.

    == Phase 1: Constraint Collection (always runs) ==

    Performs forward data-flow analysis starting from a target signal (e.g.,
    'pwrite') to extract the necessary constant values of other control signals
    (e.g., 'psel', 'penable') required to sensitize each path down to a
    side-effecting endpoint (register driver or control flow branch).

    Traversal covers:
    - Signal decodings: llhd.sig -> llhd.prb
    - Struct unpacking: hw.struct_extract / hw.struct_create
    - Cross-module tracing: hw.instance port forwarding
    - Combinational logic: AND (constrain to 1), OR (constrain to 0),
      XOR/NOT (flip polarity), MUX (constrain select), ICMP (match constant)
    - Control flow: cf.cond_br (split into true/false paths)

    Output: per-path list of {target register, signal constraints} and a
    signal summary showing which signals are uniform across all paths.

    == Phase 2: User Decision (external) ==

    The user inspects the Phase 1 output (Signal Constraint Summary) and
    decides which signals are irrelevant bus signals. Only signal names are
    needed — the pass already knows the required constant per path.

    Signals that show a single uniform value across all paths (e.g.,
    'psel: values = {1}') are prime candidates for replacement.

    == Phase 3: Constant Replacement (runs when --fc-apply-constraints) ==

    For each signal name in --fc-bus-signals:
    1. Verify the signal has a uniform value across all collected paths.
       If values differ across paths, warn and skip (the signal is likely
       not truly irrelevant).
    2. Locate the SSA Value(s) in each hw.module (port BlockArguments,
       llhd.sig+prb, struct_extract, wire).
    3. Replace all uses with hw.constant of the determined value.
    4. Run MLIR built-in canonicalization + DCE to fold constants
       (e.g., and(1,x)->x, icmp(c,c)->true, cond_br(true)->br)
       and eliminate dead branches.

    Usage:
      # Phase 1 only: analyze and print constraints
      --forward-constrain --target-signal="pwrite"

      # Phase 1 + Phase 3: analyze, replace, and simplify
      --forward-constrain --target-signal="pwrite" \
        --fc-apply-constraints --fc-bus-signals="psel,pready"
  }];

  let options = [
    Option<"targetSignal", "target-signal", "std::string", /*default=*/"\"pwrite\"",
           "The originating control signal to trace forward">,
    Option<"applyConstraints", "fc-apply-constraints", "bool", /*default=*/"false",
           "If true, mutate the IR by replacing identified bus signals with constants">,
    Option<"busSignals", "fc-bus-signals", "std::string", /*default=*/"\"\"",
           "Comma-separated list of irrelevant bus signal names to replace "
           "with constants derived from Phase 1 analysis">,
  ];
}

//===----------------------------------------------------------------------===//
// Pass 5: Combinational Logic Extraction
//===----------------------------------------------------------------------===//

def CombLogicExtract : Pass<"comb-logic-extract", "mlir::ModuleOp"> {
  let summary = "Extract combinational logic for QEMU update_state()";
  let description = [{
    Extracts combinational logic (llhd.drv outside of llhd.process) and
    translates it to C expressions for QEMU update_state().

    Design aligns with qemu-output/src/lib/ClkAnalysisResult.cpp:
    1. Walk all llhd.drv in hw.module
    2. Filter out drv inside llhd.process (sequential logic)
    3. Filter out module ports
    4. Generate C expressions using CombTranslator

    Output:
    - JSON file with combinational assignments (target, expression, bitWidth)
    - Module attribute qemu.comb_logic with the same data
    - Console report of extracted assignments

    Prerequisites:
    - Should run after clock removal and APB optimization passes
    - Input IR should be simplified for best expression generation
  }];
}

//===----------------------------------------------------------------------===//
// Pass 6: QEMU C Code Emission
//===----------------------------------------------------------------------===//

def QEMUEmitC : Pass<"qemu-emit-c", "mlir::ModuleOp"> {
  let summary = "Emit QEMU device C code from annotated LLHD IR";
  let description = [{
    Final pass in the LLHD-to-QEMU conversion pipeline. Reads qemu.* metadata
    from the IR and emits QEMU-compatible C code using QEMUCodeGen.

    Input metadata consumed:
    - qemu.comb_logic on hw.module: combinational logic expressions
    - qemu.clock_triggered on llhd.process: sequential process markers
    - qemu.drv_class on llhd.drv: drive operation classifications

    Output:
    - <device>.c: QEMU device implementation
    - <device>.h: QEMU device header

    Design:
    - Generates ONE QEMU device for the public top hw.module
    - Flattens comb logic from all submodules into top device
    - update_state() emits only metadata-driven assignments (no hardcoded IRQ)
    - All signal names are sanitized with collision detection

    Prerequisites:
    - Must run after comb-logic-extract pass
    - Input IR should have all qemu.* annotations
  }];

  let options = [
    Option<"outputDir", "output-dir", "std::string", /*default=*/"\"qemu-output\"",
           "Output directory for generated C files">,
    Option<"deviceName", "device-name", "std::string", /*default=*/"\"\"",
           "Override device name (default: use top module name)">
  ];
}
