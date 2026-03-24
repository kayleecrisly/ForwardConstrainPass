# QEMU-OUT-frame 开发日志 (DEVLOG)

> LLHD IR → QEMU Device C Code 转换框架的开发日志  
> 记录关键改进、可复现指令和使用方法

---

## 目录

- [项目概览](#项目概览)
- [环境配置与构建](#环境配置与构建)
- [使用方法](#使用方法)
- [Pass 详细说明](#pass-详细说明)
- [开发日志](#开发日志)
- [常见问题与排错](#常见问题与排错)

---

## 项目概览

将 SystemVerilog 硬件设计通过 CIRCT/LLHD IR 转换为 QEMU 设备模拟 C 代码。

**完整 Pipeline:**
```
SystemVerilog → (firtool) → LLHD IR (.mlir)
  → clock-signal-detection
  → drv-classification
  → CSE
  → clock-drv-removal
  → dff-demo / signal-flow-analysis / forward-constrain
  → comb-logic-extract
  → qemu-emit-c
  → QEMU C/H files
```

**目录结构:**
```
QEMU-OUT-frame/
├── CMakeLists.txt          # 构建配置
├── tool_main.cpp           # 主驱动程序
├── include/
│   └── Passes.td           # TableGen Pass 定义
├── lib/
│   ├── Passes.cpp          # Pass 1-3: 时钟检测、分类、移除
│   ├── DffDemoPass.cpp     # Pass 4a: APB 控制信号推断优化
│   ├── SignalFlowAnalysisPass.cpp  # Pass 4b: 数据流分析
│   ├── ForwardConstrainPass.cpp    # Pass 4c: 前向约束提取
│   ├── CombLogicExtractPass.cpp    # Pass 5: 组合逻辑提取
│   ├── QEMUEmitCPass.cpp   # Pass 6: QEMU C 代码生成
│   ├── ClockAnalysis.h     # 时钟分析工具
│   ├── CombTranslator.h    # LLHD→C 表达式翻译器
│   └── QEMUCodeGen.h       # QEMU 代码生成器
├── test/                   # 测试用例 (.mlir)
├── results/                # 运行结果输出
├── scripts/                # 辅助脚本
└── build/                  # 构建目录
```

---

## 环境配置与构建

### 前置依赖

- CIRCT (含 HW, Comb, Seq, LLHD dialects)
- MLIR
- LLVM
- CMake ≥ 3.20
- C++17 compiler

### 当前环境实际路径

| 组件 | 路径 |
|------|------|
| **项目根目录** | `/home/kaylee/circt-workspace/circt/workspace/QEMU-OUT-frame` |
| **CIRCT cmake** | `/home/kaylee/circt-workspace/circt/build/Release/lib/cmake/circt` |
| **MLIR cmake** | `/home/kaylee/circt-workspace/circt/llvm/build/Release/lib/cmake/mlir` |
| **LLVM cmake** | `/home/kaylee/circt-workspace/circt/llvm/build/Release/lib/cmake/llvm` |
| **构建产物** | `build/qemu-passes` |
| **MLIR 输入文件** | `../opentitan/mlir_output/` 或 `test/` |
| **工具路径** | `/home/user/circt/build/Release/bin/circt-verilog` |


### 编译指令（可直接复制执行）

**首次构建 (cmake + make):**

```bash
cd /home/kaylee/circt-workspace/circt/workspace/QEMU-OUT-frame
mkdir -p build && cd build

cmake .. \
  -DCIRCT_DIR=/home/kaylee/circt-workspace/circt/build/Release/lib/cmake/circt \
  -DMLIR_DIR=/home/kaylee/circt-workspace/circt/llvm/build/Release/lib/cmake/mlir \
  -DLLVM_DIR=/home/kaylee/circt-workspace/circt/llvm/build/Release/lib/cmake/llvm

make -j$(nproc)
```

**修改代码后重新编译 (只需 make):**

```bash
cd /home/kaylee/circt-workspace/circt/workspace/QEMU-OUT-frame/build
make -j$(nproc)
```

**修改了 Passes.td 后 (需要重新 cmake):**

```bash
cd /home/kaylee/circt-workspace/circt/workspace/QEMU-OUT-frame/build
cmake .. \
  -DCIRCT_DIR=/home/kaylee/circt-workspace/circt/build/Release/lib/cmake/circt \
  -DMLIR_DIR=/home/kaylee/circt-workspace/circt/llvm/build/Release/lib/cmake/mlir \
  -DLLVM_DIR=/home/kaylee/circt-workspace/circt/llvm/build/Release/lib/cmake/llvm
make -j$(nproc)
```

**验证构建成功:**

```bash
./build/qemu-passes --help
# 不带任何 pass 参数运行会打印所有可用 pass 列表
./build/qemu-passes test/gpio0_llhd.mlir
```

---

## 使用方法

> **约定**: 以下所有命令均从项目根目录执行  
> `cd /home/kaylee/circt-workspace/circt/workspace/QEMU-OUT-frame`

### 1. 运行单个 Pass

```bash
# ── Pass 1: 时钟信号检测 ──
./build/qemu-passes input.mlir --clock-signal-detection

# ── Pass 2: drv 分类 ──
./build/qemu-passes input.mlir --drv-classification

# ── Pass 3: 时钟拓扑移除 ──
./build/qemu-passes input.mlir --clock-drv-removal

# ── Pass 4a: DffDemo 控制信号推断优化 ──
# 默认 rw-signal=pwrite (APB 协议)
./build/qemu-passes input.mlir --dff-demo
# 指定 Wishbone 协议的 we 信号:
./build/qemu-passes input.mlir --dff-demo --rw-signal=we
# 双信号模式 (AXI):
./build/qemu-passes input.mlir --dff-demo --write-signal=awvalid --read-signal=arvalid

# ── Pass 4b: SignalFlowAnalysis 数据流分析 ──
# 单信号模式:
./build/qemu-passes input.mlir --signal-flow-analysis --rw-signal=reg_we
# 双信号模式:
./build/qemu-passes input.mlir --signal-flow-analysis --write-signal=reg_we --read-signal=reg_re

# ── Pass 4c: ForwardConstrain 前向约束提取 ──
# 基本分析 (默认 target=pwrite, active=1):
./build/qemu-passes input.mlir --forward-constrain
# 指定目标信号:
./build/qemu-passes input.mlir --forward-constrain \
  --fc-target-signal=pwrite --fc-target-active-val=1
# 应用约束，修改 IR:
./build/qemu-passes input.mlir --forward-constrain \
  --fc-target-signal=pwrite --fc-target-active-val=1 \
  --fc-apply-constraints --fc-bus-signals="psel,penable"

# ── Pass 5: 组合逻辑提取 ──
./build/qemu-passes input.mlir --comb-logic-extract

# ── Pass 6: QEMU C 代码生成 ──
./build/qemu-passes input.mlir --qemu-emit-c --qemu-output-dir=./generated
```

### 2. 运行完整 Pipeline

```bash
# 完整 pipeline (Pass 1~5, 不含 C 代码生成), 输出修改后的 IR:
./build/qemu-passes input.mlir --all-passes -o output.mlir

# 然后单独生成 C 代码:
./build/qemu-passes output.mlir --qemu-emit-c --qemu-output-dir=./generated
```

### 3. 典型工作流示例

```bash
# ── 示例 1: GPIO0 完整流程 ──
./build/qemu-passes test/gpio0_llhd.mlir --all-passes -o results/gpio0_optimized.mlir
./build/qemu-passes results/gpio0_optimized.mlir --qemu-emit-c --qemu-output-dir=./generated

# ── 示例 2: OpenTitan UART 前向分析 ──
./build/qemu-passes ../opentitan/mlir_output/uart/uart_full.mlir \
  --forward-constrain --fc-target-signal=pwrite --fc-target-active-val=1

# ── 示例 3: 只看分析结果，不输出 IR ──
./build/qemu-passes test/gpio0_llhd.mlir --dff-demo

# ── 示例 4: 分析后输出修改的 IR 到文件 ──
./build/qemu-passes test/gpio0_llhd.mlir --dff-demo -o results/gpio0_dff.mlir
# 或打印到 stdout:
./build/qemu-passes test/gpio0_llhd.mlir --dff-demo --emit-output
```

### 4. 运行测试用例

```bash
# 双 XOR 消除测试
./build/qemu-passes test/test_double_xor.mlir --dff-demo

# GPIO0 完整测试
./build/qemu-passes test/gpio0_llhd.mlir --dff-demo

# 时钟检测测试
./build/qemu-passes test/clock_only_process.mlir --clock-signal-detection
./build/qemu-passes test/clock_and_enable.mlir --clock-signal-detection

# traceSignal 增强测试
./build/qemu-passes test/trace_signal_multi_not.mlir --dff-demo
./build/qemu-passes test/trace_signal_icmp.mlir --dff-demo
./build/qemu-passes test/trace_signal_sigextract.mlir --dff-demo
```

### 5. 完整 CLI 参数速查

| 参数 | 默认值 | 说明 |
|------|--------|------|
| `--clock-signal-detection` | false | 运行 Pass 1 |
| `--drv-classification` | false | 运行 Pass 2 |
| `--clock-drv-removal` | false | 运行 Pass 3 |
| `--dff-demo` | false | 运行 Pass 4a |
| `--signal-flow-analysis` | false | 运行 Pass 4b |
| `--forward-constrain` | false | 运行 Pass 4c |
| `--comb-logic-extract` | false | 运行 Pass 5 |
| `--qemu-emit-c` | false | 运行 Pass 6 |
| `--all-passes` | false | 运行 Pass 1~5 全部 |
| `-o <file>` | stdout | 输出文件路径 |
| `--emit-output` | false | 打印变换后 IR 到 stdout |
| `--rw-signal=<name>` | `pwrite` | DffDemo/SignalFlow 单信号模式 |
| `--write-signal=<name>` | `""` | DffDemo/SignalFlow 写信号 (双信号模式) |
| `--read-signal=<name>` | `""` | DffDemo/SignalFlow 读信号 (双信号模式) |
| `--write-val=<n>` | `1` | 写信号激活值 |
| `--read-val=<n>` | `1` | 读信号激活值 |
| `--fc-target-signal=<name>` | `pwrite` | ForwardConstrain 目标信号 |
| `--fc-target-active-val=<n>` | `1` | ForwardConstrain 目标激活值 |
| `--fc-apply-constraints` | false | ForwardConstrain 是否注入约束到 IR |
| `--fc-bus-signals=<list>` | `""` | ForwardConstrain 可替换的总线信号 (逗号分隔) |
| `--qemu-output-dir=<dir>` | `qemu-output` | QEMUEmitC 输出目录 |

---

## Pass 详细说明

| Pass | CLI 参数 | 功能 | 适用场景 |
|------|---------|------|---------|
| ClockSignalDetection | `--clock-signal-detection` | 两级时钟信号检测 | 所有设计 |
| DrvClassification | `--drv-classification` | drv 操作分类 | 所有设计 |
| ClockDrvRemoval | `--clock-drv-removal` | 移除时钟拓扑 | 所有时钟设计 |
| DffDemo | `--dff-demo` | 控制信号推断优化 | APB/Wishbone (条件分支) |
| SignalFlowAnalysis | `--signal-flow-analysis` | 数据流传播分析 | TL-UL/AXI (组合逻辑) |
| ForwardConstrain | `--forward-constrain` | 前向约束路径敏化 | 通用 (三层设计) |
| CombLogicExtract | `--comb-logic-extract` | 组合逻辑提取 | C 代码生成前 |
| QEMUEmitC | `--qemu-emit-c` | 生成 QEMU C 代码 | 最终输出 |

### Pass 4 三种变体的选择指南

- **DffDemo (4a)**: 控制信号直接出现在 `cf.cond_br` 条件分支中 → 选此 Pass
- **SignalFlowAnalysis (4b)**: 控制信号通过组合逻辑传播 (如 TL-UL 的 `reg_we`) → 选此 Pass
- **ForwardConstrain (4c)**: 通用的前向追踪，支持跨模块边界、自动约束提取 → 最新最通用

---

## 开发日志

### [2026-01-09] 初始提交 — 完整 Pipeline 建立

**提交**: `5c1b723` Initial commit

- 建立了 6 个 Pass 的完整流水线
- 实现 ClockSignalDetection 两级分析
- 实现 DrvClassification 四类分类
- 实现 ClockDrvRemoval 对齐旧框架
- 实现 DffDemo APB 控制信号推断
- 实现 CombLogicExtract 组合逻辑提取
- 实现 QEMUEmitC QEMU C 代码生成

---

### [2026-01-09] Pass 3 审计修复 — 对齐旧框架 SignalTracing.h

**提交**: `dcedf7d`, `bc82b66`, `31382a9`

**改进**:
- ClockDrvRemoval 严格边缘检测: 同时要求 direct prb 和 inverted prb
- 使用 waitBlocks 概念进行稳定 idle/body 分支检测
- 保留 reset 消歧分支

---

### [2026-01-09] traceSignal() 增强

**详见**: `CHANGELOG_TRACE_SIGNAL.md`

**改进**:
- 支持多层 NOT (comb.xor 链, 奇偶校验追踪, 最多 32 层)
- ICmp-based NOT (i1 与 0/1 常量比较)
- SigExtract 解包 (穿透 llhd.sig.extract 链)
- 基于类型的信号检测 (用 `llhd::SignalOp` 替代字符串比较)
- BlockArgument 支持 (从 hw.module 端口提取名称)

**验证**:
```bash
./build/qemu-passes test/test_double_xor.mlir --dff-demo
# ✅ 正确检测 pwrite=1 (双反相消除)
```

---

### [2026-01-09] QEMUEmitCPass 修复

**提交**: `80b045a`

**改进**:
- 修正扁平化命名: `<ModuleName>__<signalName>`
- 修正 APB 映射

---

### [2026-03-10] SignalFlowAnalysis Pass 新增

**改进**:
- 新增 Pass 4b，支持数据流传播分析
- 适配 OpenTitan TL-UL 协议 (reg_we/reg_re 通过组合逻辑传播)
- 支持 AXI (awvalid/arvalid)

---

### [2026-03-10~12] ForwardConstrainPass 新增 — 三层通用设计

**改进**:
- 新增 Pass 4c: 前向约束提取（路径敏化分析）
- **三层设计架构**:
  1. **信号定位层**: 自动定位 llhd.sig → llhd.prb，支持 struct_extract 解包
  2. **算子语义层**: 覆盖 AND(约束其他输入为1)、OR(约束为0)、XOR/NOT(翻转极性)、MUX(分支或约束 select)、ICMP
  3. **端点识别层**: 识别 llhd.drv (寄存器驱动) 和 cf.cond_br (控制流分支) 作为终止点
- 支持跨 `hw.instance` 模块边界追踪
- 支持 `--fc-apply-constraints` 将约束注入 IR
- 支持 `--fc-bus-signals` 指定可替换的总线信号

**复现指令**:
```bash
# 基本前向约束分析
./build/qemu-passes input.mlir --forward-constrain \
  --fc-target-signal=pwrite --fc-target-active-val=1

# 应用约束修改 IR
./build/qemu-passes input.mlir --forward-constrain \
  --fc-target-signal=pwrite --fc-target-active-val=1 \
  --fc-apply-constraints --fc-bus-signals="psel,penable"
```

---

## 常见问题与排错

### Q1: 构建错误 — 找不到 CIRCT/MLIR

```
Could not find a package configuration file provided by "CIRCT"
```

**解决**: 检查 `CMAKE_PREFIX_PATH` 是否正确指向 CIRCT/MLIR/LLVM 的 cmake 目录。

### Q2: 运行时报 "no public top hw.module found"

**原因**: 输入 MLIR 中没有非 private 的 hw.module。  
**解决**: 确保输入文件包含顶层模块。

### Q3: Pass 输出为空

**原因**: 可能 Pass 依赖关系未满足。  
**解决**: 按照 Pipeline 顺序运行，或使用 `--all-passes`。

### Q4: 如何添加新 Pass

1. 在 `include/Passes.td` 中添加 TableGen 定义
2. 在 `lib/` 中创建实现文件 `NewPass.cpp`
3. 在 `CMakeLists.txt` 中添加源文件
4. 在 `tool_main.cpp` 中注册 Pass 并添加 CLI 选项
5. 重新构建

---

## 备注

- 本项目与 `opentitan/mlir_output/` 配合使用，MLIR 文件从该目录读取
- ForwardConstrainPass 是目前最通用的控制信号分析方案，推荐优先使用
- 所有 Pass 支持 `-o output.mlir` 输出修改后的 IR 供下游使用

---

*最后更新: 2026-03-15*
