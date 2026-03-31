**测试样例**

opentitan：```/QEMU-OUT-frame/test/i2c1.mlir```(读写信号：pwrite)
wujian100:```/QEMU-OUT-frame/test/rv_timer1_deseq.mlir ```（读写信号：a_opcode）

**测试指令**
```
/home/kaylee/circt-workspace/circt/workspace/QEMU-OUT-frame/build/qemu-passes \
/home/kaylee/circt-workspace/circt/workspace/wujian100_open/out-mlir/deseq/out_gpio_deseq.mlir \
--forward-constrain --fc-target-signal=pwrite
```
```
/home/kaylee/circt-workspace/circt/workspace/QEMU-OUT-frame/build/qemu-passes \
/home/kaylee/circt-workspace/circt/workspace/opentitan/mlir_output/i2c/i2c1.mlir \
--forward-constrain --fc-target-signal=a_opcode
```
**编译指令**
```./qemu-passes \
  /home/kaylee/circt-workspace/circt/workspace/wujian100_open/out-mlir/deseq/out_gpio_deseq.mlir \
  --forward-constrain --fc-target-signal=pwrite \
  --fc-apply-constraints --fc-bus-signals=psel
cd /home/kaylee/circt-workspace/circt/workspace/QEMU-OUT-frame/build
```
```
ninja -j$(nproc)
```
**常值替换指令**
```
/home/kaylee/circt-workspace/circt/workspace/QEMU-OUT-frame/build/qemu-passes /home/kaylee/circt-workspace/circt/workspace/opentitan/mlir_output/i2c/i2c1.mlir --forward-constrain --fc-target-signal=a_opcode --fc-apply-constraints --fc-bus-signals=a_ack -o /home/kaylee/circt-workspace/circt/workspace/opentitan/mlir_output/i2c/i2c_output.mlir
```
```
/home/kaylee/circt-workspace/circt/workspace/QEMU-OUT-frame/build/qemu-passes   /home/kaylee/circt-workspace/circt/workspace/wujian100_open/out-mlir/deseq/out_gpio_deseq.mlir   --forward-constrain --fc-target-signal=pwrite   --fc-apply-constraints --fc-bus-signals=psel
```