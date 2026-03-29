module {
  func.func private @"prim_mubi_pkg::mubi4_test_invalid"(%arg0: i4) -> i1 {
    %true = hw.constant true
    %c-7_i4 = hw.constant -7 : i4
    %c6_i4 = hw.constant 6 : i4
    %0 = comb.icmp weq %arg0, %c6_i4 : i4
    %1 = comb.icmp weq %arg0, %c-7_i4 : i4
    %2 = comb.or %0, %1 : i1
    %3 = comb.xor %2, %true : i1
    return %3 : i1
  }
  func.func private @"prim_mubi_pkg::mubi4_test_true_strict"(%arg0: i4) -> i1 {
    %c6_i4 = hw.constant 6 : i4
    %0 = comb.icmp eq %arg0, %c6_i4 : i4
    return %0 : i1
  }
  func.func private @"prim_mubi_pkg::mubi4_test_false_loose"(%arg0: i4) -> i1 {
    %c6_i4 = hw.constant 6 : i4
    %0 = comb.icmp ne %arg0, %c6_i4 : i4
    return %0 : i1
  }
  func.func private @"tlul_pkg::extract_h2d_cmd_intg"(%arg0: !hw.struct<a_valid: i1, a_opcode: i3, a_param: i3, a_size: i2, a_source: i8, a_address: i32, a_mask: i4, a_data: i32, a_user: !hw.struct<rsvd: i5, instr_type: i4, cmd_intg: i7, data_intg: i7>, d_ready: i1>) -> !hw.struct<instr_type: i4, addr: i32, opcode: i3, mask: i4> {
    %0 = llhd.constant_time <0ns, 0d, 1e>
    %c0_i43 = hw.constant 0 : i43
    %1 = hw.bitcast %c0_i43 : (i43) -> !hw.struct<instr_type: i4, addr: i32, opcode: i3, mask: i4>
    %payload = llhd.sig %1 : !hw.struct<instr_type: i4, addr: i32, opcode: i3, mask: i4>
    %2 = llhd.sig.struct_extract %payload["addr"] : !hw.inout<struct<instr_type: i4, addr: i32, opcode: i3, mask: i4>>
    %a_address = hw.struct_extract %arg0["a_address"] : !hw.struct<a_valid: i1, a_opcode: i3, a_param: i3, a_size: i2, a_source: i8, a_address: i32, a_mask: i4, a_data: i32, a_user: !hw.struct<rsvd: i5, instr_type: i4, cmd_intg: i7, data_intg: i7>, d_ready: i1>
    llhd.drv %2, %a_address after %0 : !hw.inout<i32>
    %3 = llhd.sig.struct_extract %payload["opcode"] : !hw.inout<struct<instr_type: i4, addr: i32, opcode: i3, mask: i4>>
    %a_opcode = hw.struct_extract %arg0["a_opcode"] : !hw.struct<a_valid: i1, a_opcode: i3, a_param: i3, a_size: i2, a_source: i8, a_address: i32, a_mask: i4, a_data: i32, a_user: !hw.struct<rsvd: i5, instr_type: i4, cmd_intg: i7, data_intg: i7>, d_ready: i1>
    llhd.drv %3, %a_opcode after %0 : !hw.inout<i3>
    %4 = llhd.sig.struct_extract %payload["mask"] : !hw.inout<struct<instr_type: i4, addr: i32, opcode: i3, mask: i4>>
    %a_mask = hw.struct_extract %arg0["a_mask"] : !hw.struct<a_valid: i1, a_opcode: i3, a_param: i3, a_size: i2, a_source: i8, a_address: i32, a_mask: i4, a_data: i32, a_user: !hw.struct<rsvd: i5, instr_type: i4, cmd_intg: i7, data_intg: i7>, d_ready: i1>
    llhd.drv %4, %a_mask after %0 : !hw.inout<i4>
    %5 = llhd.sig.struct_extract %payload["instr_type"] : !hw.inout<struct<instr_type: i4, addr: i32, opcode: i3, mask: i4>>
    %a_user = hw.struct_extract %arg0["a_user"] : !hw.struct<a_valid: i1, a_opcode: i3, a_param: i3, a_size: i2, a_source: i8, a_address: i32, a_mask: i4, a_data: i32, a_user: !hw.struct<rsvd: i5, instr_type: i4, cmd_intg: i7, data_intg: i7>, d_ready: i1>
    %instr_type = hw.struct_extract %a_user["instr_type"] : !hw.struct<rsvd: i5, instr_type: i4, cmd_intg: i7, data_intg: i7>
    llhd.drv %5, %instr_type after %0 : !hw.inout<i4>
    %6 = llhd.prb %payload : !hw.inout<struct<instr_type: i4, addr: i32, opcode: i3, mask: i4>>
    return %6 : !hw.struct<instr_type: i4, addr: i32, opcode: i3, mask: i4>
  }
  func.func private @"tlul_pkg::extract_d2h_rsp_intg"(%arg0: !hw.struct<d_valid: i1, d_opcode: i3, d_param: i3, d_size: i2, d_source: i8, d_sink: i1, d_data: i32, d_user: !hw.struct<rsp_intg: i7, data_intg: i7>, d_error: i1, a_ready: i1>) -> !hw.struct<opcode: i3, size: i2, error: i1> {
    %0 = llhd.constant_time <0ns, 0d, 1e>
    %c0_i6 = hw.constant 0 : i6
    %1 = hw.bitcast %c0_i6 : (i6) -> !hw.struct<opcode: i3, size: i2, error: i1>
    %payload = llhd.sig %1 : !hw.struct<opcode: i3, size: i2, error: i1>
    %2 = llhd.sig.struct_extract %payload["opcode"] : !hw.inout<struct<opcode: i3, size: i2, error: i1>>
    %d_opcode = hw.struct_extract %arg0["d_opcode"] : !hw.struct<d_valid: i1, d_opcode: i3, d_param: i3, d_size: i2, d_source: i8, d_sink: i1, d_data: i32, d_user: !hw.struct<rsp_intg: i7, data_intg: i7>, d_error: i1, a_ready: i1>
    llhd.drv %2, %d_opcode after %0 : !hw.inout<i3>
    %3 = llhd.sig.struct_extract %payload["size"] : !hw.inout<struct<opcode: i3, size: i2, error: i1>>
    %d_size = hw.struct_extract %arg0["d_size"] : !hw.struct<d_valid: i1, d_opcode: i3, d_param: i3, d_size: i2, d_source: i8, d_sink: i1, d_data: i32, d_user: !hw.struct<rsp_intg: i7, data_intg: i7>, d_error: i1, a_ready: i1>
    llhd.drv %3, %d_size after %0 : !hw.inout<i2>
    %4 = llhd.sig.struct_extract %payload["error"] : !hw.inout<struct<opcode: i3, size: i2, error: i1>>
    %d_error = hw.struct_extract %arg0["d_error"] : !hw.struct<d_valid: i1, d_opcode: i3, d_param: i3, d_size: i2, d_source: i8, d_sink: i1, d_data: i32, d_user: !hw.struct<rsp_intg: i7, data_intg: i7>, d_error: i1, a_ready: i1>
    llhd.drv %4, %d_error after %0 : !hw.inout<i1>
    %5 = llhd.prb %payload : !hw.inout<struct<opcode: i3, size: i2, error: i1>>
    return %5 : !hw.struct<opcode: i3, size: i2, error: i1>
  }
  hw.module private @prim_subreg(in %clk_i : i1, in %rst_ni : i1, in %we : i1, in %wd : i1, in %de : i1, in %d : i1, out qe : i1, out q : i1, out ds : i1, out qs : i1) {
    %0 = llhd.constant_time <0ns, 1d, 0e>
    %true = hw.constant true
    %1 = llhd.constant_time <0ns, 0d, 1e>
    %false = hw.constant false
    %clk_i_0 = llhd.sig name "clk_i" %false : i1
    %2 = llhd.prb %clk_i_0 : !hw.inout<i1>
    %rst_ni_1 = llhd.sig name "rst_ni" %false : i1
    %3 = llhd.prb %rst_ni_1 : !hw.inout<i1>
    %q = llhd.sig %false : i1
    %qs = llhd.sig %false : i1
    %wr_en = llhd.sig %false : i1
    %wr_data = llhd.sig %false : i1
    %4 = llhd.prb %q : !hw.inout<i1>
    %wr_en_data_arb.wr_en, %wr_en_data_arb.wr_data = hw.instance "wr_en_data_arb" @prim_subreg_arb(we: %we: i1, wd: %wd: i1, de: %de: i1, d: %d: i1, q: %4: i1) -> (wr_en: i1, wr_data: i1)
    llhd.drv %wr_en, %wr_en_data_arb.wr_en after %1 : !hw.inout<i1>
    llhd.drv %wr_data, %wr_en_data_arb.wr_data after %1 : !hw.inout<i1>
    llhd.process {
      cf.br ^bb1
    ^bb1:  // 5 preds: ^bb0, ^bb2, ^bb4, ^bb5, ^bb6
      %9 = llhd.prb %clk_i_0 : !hw.inout<i1>
      %10 = llhd.prb %rst_ni_1 : !hw.inout<i1>
      llhd.wait (%2, %3 : i1, i1), ^bb2
    ^bb2:  // pred: ^bb1
      %11 = llhd.prb %clk_i_0 : !hw.inout<i1>
      %12 = comb.xor bin %9, %true : i1
      %13 = comb.and bin %12, %11 : i1
      %14 = llhd.prb %rst_ni_1 : !hw.inout<i1>
      %15 = comb.xor bin %14, %true : i1
      %16 = comb.and bin %10, %15 : i1
      %17 = comb.or bin %13, %16 : i1
      cf.cond_br %17, ^bb3, ^bb1
    ^bb3:  // pred: ^bb2
      %18 = llhd.prb %rst_ni_1 : !hw.inout<i1>
      %19 = comb.xor %18, %true : i1
      cf.cond_br %19, ^bb4, ^bb5
    ^bb4:  // pred: ^bb3
      llhd.drv %q, %false after %0 : !hw.inout<i1>
      cf.br ^bb1
    ^bb5:  // pred: ^bb3
      %20 = llhd.prb %wr_en : !hw.inout<i1>
      cf.cond_br %20, ^bb6, ^bb1
    ^bb6:  // pred: ^bb5
      %21 = llhd.prb %wr_data : !hw.inout<i1>
      llhd.drv %q, %21 after %0 : !hw.inout<i1>
      cf.br ^bb1
    }
    %5 = llhd.prb %wr_en : !hw.inout<i1>
    %6 = llhd.prb %wr_data : !hw.inout<i1>
    %7 = llhd.prb %qs : !hw.inout<i1>
    %8 = comb.mux %5, %6, %7 : i1
    llhd.drv %qs, %4 after %1 : !hw.inout<i1>
    llhd.drv %clk_i_0, %clk_i after %1 : !hw.inout<i1>
    llhd.drv %rst_ni_1, %rst_ni after %1 : !hw.inout<i1>
    hw.output %we, %4, %8, %7 : i1, i1, i1, i1
  }
  hw.module private @prim_subreg_0(in %clk_i : i1, in %rst_ni : i1, in %we : i1, in %wd : i1, in %de : i1, in %d : i1, out qe : i1, out q : i1, out ds : i1, out qs : i1) {
    %0 = llhd.constant_time <0ns, 1d, 0e>
    %true = hw.constant true
    %1 = llhd.constant_time <0ns, 0d, 1e>
    %false = hw.constant false
    %clk_i_0 = llhd.sig name "clk_i" %false : i1
    %2 = llhd.prb %clk_i_0 : !hw.inout<i1>
    %rst_ni_1 = llhd.sig name "rst_ni" %false : i1
    %3 = llhd.prb %rst_ni_1 : !hw.inout<i1>
    %q = llhd.sig %false : i1
    %qs = llhd.sig %false : i1
    %wr_en = llhd.sig %false : i1
    %wr_data = llhd.sig %false : i1
    %4 = llhd.prb %q : !hw.inout<i1>
    %wr_en_data_arb.wr_en, %wr_en_data_arb.wr_data = hw.instance "wr_en_data_arb" @prim_subreg_arb_7(we: %we: i1, wd: %wd: i1, de: %de: i1, d: %d: i1, q: %4: i1) -> (wr_en: i1, wr_data: i1)
    llhd.drv %wr_en, %wr_en_data_arb.wr_en after %1 : !hw.inout<i1>
    llhd.drv %wr_data, %wr_en_data_arb.wr_data after %1 : !hw.inout<i1>
    llhd.process {
      cf.br ^bb1
    ^bb1:  // 5 preds: ^bb0, ^bb2, ^bb4, ^bb5, ^bb6
      %9 = llhd.prb %clk_i_0 : !hw.inout<i1>
      %10 = llhd.prb %rst_ni_1 : !hw.inout<i1>
      llhd.wait (%2, %3 : i1, i1), ^bb2
    ^bb2:  // pred: ^bb1
      %11 = llhd.prb %clk_i_0 : !hw.inout<i1>
      %12 = comb.xor bin %9, %true : i1
      %13 = comb.and bin %12, %11 : i1
      %14 = llhd.prb %rst_ni_1 : !hw.inout<i1>
      %15 = comb.xor bin %14, %true : i1
      %16 = comb.and bin %10, %15 : i1
      %17 = comb.or bin %13, %16 : i1
      cf.cond_br %17, ^bb3, ^bb1
    ^bb3:  // pred: ^bb2
      %18 = llhd.prb %rst_ni_1 : !hw.inout<i1>
      %19 = comb.xor %18, %true : i1
      cf.cond_br %19, ^bb4, ^bb5
    ^bb4:  // pred: ^bb3
      llhd.drv %q, %false after %0 : !hw.inout<i1>
      cf.br ^bb1
    ^bb5:  // pred: ^bb3
      %20 = llhd.prb %wr_en : !hw.inout<i1>
      cf.cond_br %20, ^bb6, ^bb1
    ^bb6:  // pred: ^bb5
      %21 = llhd.prb %wr_data : !hw.inout<i1>
      llhd.drv %q, %21 after %0 : !hw.inout<i1>
      cf.br ^bb1
    }
    %5 = llhd.prb %wr_en : !hw.inout<i1>
    %6 = llhd.prb %wr_data : !hw.inout<i1>
    %7 = llhd.prb %qs : !hw.inout<i1>
    %8 = comb.mux %5, %6, %7 : i1
    llhd.drv %qs, %4 after %1 : !hw.inout<i1>
    llhd.drv %clk_i_0, %clk_i after %1 : !hw.inout<i1>
    llhd.drv %rst_ni_1, %rst_ni after %1 : !hw.inout<i1>
    hw.output %we, %4, %8, %7 : i1, i1, i1, i1
  }
  hw.module private @prim_subreg_1(in %clk_i : i1, in %rst_ni : i1, in %we : i1, in %wd : i12, in %de : i1, in %d : i12, out qe : i1, out q : i12, out ds : i12, out qs : i12) {
    %0 = llhd.constant_time <0ns, 1d, 0e>
    %true = hw.constant true
    %1 = llhd.constant_time <0ns, 0d, 1e>
    %c0_i12 = hw.constant 0 : i12
    %false = hw.constant false
    %clk_i_0 = llhd.sig name "clk_i" %false : i1
    %2 = llhd.prb %clk_i_0 : !hw.inout<i1>
    %rst_ni_1 = llhd.sig name "rst_ni" %false : i1
    %3 = llhd.prb %rst_ni_1 : !hw.inout<i1>
    %q = llhd.sig %c0_i12 : i12
    %qs = llhd.sig %c0_i12 : i12
    %wr_en = llhd.sig %false : i1
    %wr_data = llhd.sig %c0_i12 : i12
    %4 = llhd.prb %q : !hw.inout<i12>
    %wr_en_data_arb.wr_en, %wr_en_data_arb.wr_data = hw.instance "wr_en_data_arb" @prim_subreg_arb_8(we: %we: i1, wd: %wd: i12, de: %de: i1, d: %d: i12, q: %4: i12) -> (wr_en: i1, wr_data: i12)
    llhd.drv %wr_en, %wr_en_data_arb.wr_en after %1 : !hw.inout<i1>
    llhd.drv %wr_data, %wr_en_data_arb.wr_data after %1 : !hw.inout<i12>
    llhd.process {
      cf.br ^bb1
    ^bb1:  // 5 preds: ^bb0, ^bb2, ^bb4, ^bb5, ^bb6
      %9 = llhd.prb %clk_i_0 : !hw.inout<i1>
      %10 = llhd.prb %rst_ni_1 : !hw.inout<i1>
      llhd.wait (%2, %3 : i1, i1), ^bb2
    ^bb2:  // pred: ^bb1
      %11 = llhd.prb %clk_i_0 : !hw.inout<i1>
      %12 = comb.xor bin %9, %true : i1
      %13 = comb.and bin %12, %11 : i1
      %14 = llhd.prb %rst_ni_1 : !hw.inout<i1>
      %15 = comb.xor bin %14, %true : i1
      %16 = comb.and bin %10, %15 : i1
      %17 = comb.or bin %13, %16 : i1
      cf.cond_br %17, ^bb3, ^bb1
    ^bb3:  // pred: ^bb2
      %18 = llhd.prb %rst_ni_1 : !hw.inout<i1>
      %19 = comb.xor %18, %true : i1
      cf.cond_br %19, ^bb4, ^bb5
    ^bb4:  // pred: ^bb3
      llhd.drv %q, %c0_i12 after %0 : !hw.inout<i12>
      cf.br ^bb1
    ^bb5:  // pred: ^bb3
      %20 = llhd.prb %wr_en : !hw.inout<i1>
      cf.cond_br %20, ^bb6, ^bb1
    ^bb6:  // pred: ^bb5
      %21 = llhd.prb %wr_data : !hw.inout<i12>
      llhd.drv %q, %21 after %0 : !hw.inout<i12>
      cf.br ^bb1
    }
    %5 = llhd.prb %wr_en : !hw.inout<i1>
    %6 = llhd.prb %wr_data : !hw.inout<i12>
    %7 = llhd.prb %qs : !hw.inout<i12>
    %8 = comb.mux %5, %6, %7 : i12
    llhd.drv %qs, %4 after %1 : !hw.inout<i12>
    llhd.drv %clk_i_0, %clk_i after %1 : !hw.inout<i1>
    llhd.drv %rst_ni_1, %rst_ni after %1 : !hw.inout<i1>
    hw.output %we, %4, %8, %7 : i1, i12, i12, i12
  }
  hw.module private @prim_subreg_2(in %clk_i : i1, in %rst_ni : i1, in %we : i1, in %wd : i8, in %de : i1, in %d : i8, out qe : i1, out q : i8, out ds : i8, out qs : i8) {
    %0 = llhd.constant_time <0ns, 1d, 0e>
    %true = hw.constant true
    %1 = llhd.constant_time <0ns, 0d, 1e>
    %c0_i8 = hw.constant 0 : i8
    %c1_i8 = hw.constant 1 : i8
    %false = hw.constant false
    %clk_i_0 = llhd.sig name "clk_i" %false : i1
    %2 = llhd.prb %clk_i_0 : !hw.inout<i1>
    %rst_ni_1 = llhd.sig name "rst_ni" %false : i1
    %3 = llhd.prb %rst_ni_1 : !hw.inout<i1>
    %q = llhd.sig %c0_i8 : i8
    %qs = llhd.sig %c0_i8 : i8
    %wr_en = llhd.sig %false : i1
    %wr_data = llhd.sig %c0_i8 : i8
    %4 = llhd.prb %q : !hw.inout<i8>
    %wr_en_data_arb.wr_en, %wr_en_data_arb.wr_data = hw.instance "wr_en_data_arb" @prim_subreg_arb_9(we: %we: i1, wd: %wd: i8, de: %de: i1, d: %d: i8, q: %4: i8) -> (wr_en: i1, wr_data: i8)
    llhd.drv %wr_en, %wr_en_data_arb.wr_en after %1 : !hw.inout<i1>
    llhd.drv %wr_data, %wr_en_data_arb.wr_data after %1 : !hw.inout<i8>
    llhd.process {
      cf.br ^bb1
    ^bb1:  // 5 preds: ^bb0, ^bb2, ^bb4, ^bb5, ^bb6
      %9 = llhd.prb %clk_i_0 : !hw.inout<i1>
      %10 = llhd.prb %rst_ni_1 : !hw.inout<i1>
      llhd.wait (%2, %3 : i1, i1), ^bb2
    ^bb2:  // pred: ^bb1
      %11 = llhd.prb %clk_i_0 : !hw.inout<i1>
      %12 = comb.xor bin %9, %true : i1
      %13 = comb.and bin %12, %11 : i1
      %14 = llhd.prb %rst_ni_1 : !hw.inout<i1>
      %15 = comb.xor bin %14, %true : i1
      %16 = comb.and bin %10, %15 : i1
      %17 = comb.or bin %13, %16 : i1
      cf.cond_br %17, ^bb3, ^bb1
    ^bb3:  // pred: ^bb2
      %18 = llhd.prb %rst_ni_1 : !hw.inout<i1>
      %19 = comb.xor %18, %true : i1
      cf.cond_br %19, ^bb4, ^bb5
    ^bb4:  // pred: ^bb3
      llhd.drv %q, %c1_i8 after %0 : !hw.inout<i8>
      cf.br ^bb1
    ^bb5:  // pred: ^bb3
      %20 = llhd.prb %wr_en : !hw.inout<i1>
      cf.cond_br %20, ^bb6, ^bb1
    ^bb6:  // pred: ^bb5
      %21 = llhd.prb %wr_data : !hw.inout<i8>
      llhd.drv %q, %21 after %0 : !hw.inout<i8>
      cf.br ^bb1
    }
    %5 = llhd.prb %wr_en : !hw.inout<i1>
    %6 = llhd.prb %wr_data : !hw.inout<i8>
    %7 = llhd.prb %qs : !hw.inout<i8>
    %8 = comb.mux %5, %6, %7 : i8
    llhd.drv %qs, %4 after %1 : !hw.inout<i8>
    llhd.drv %clk_i_0, %clk_i after %1 : !hw.inout<i1>
    llhd.drv %rst_ni_1, %rst_ni after %1 : !hw.inout<i1>
    hw.output %we, %4, %8, %7 : i1, i8, i8, i8
  }
  hw.module private @prim_subreg_3(in %clk_i : i1, in %rst_ni : i1, in %we : i1, in %wd : i32, in %de : i1, in %d : i32, out qe : i1, out q : i32, out ds : i32, out qs : i32) {
    %0 = llhd.constant_time <0ns, 1d, 0e>
    %true = hw.constant true
    %1 = llhd.constant_time <0ns, 0d, 1e>
    %c0_i32 = hw.constant 0 : i32
    %false = hw.constant false
    %clk_i_0 = llhd.sig name "clk_i" %false : i1
    %2 = llhd.prb %clk_i_0 : !hw.inout<i1>
    %rst_ni_1 = llhd.sig name "rst_ni" %false : i1
    %3 = llhd.prb %rst_ni_1 : !hw.inout<i1>
    %q = llhd.sig %c0_i32 : i32
    %qs = llhd.sig %c0_i32 : i32
    %wr_en = llhd.sig %false : i1
    %wr_data = llhd.sig %c0_i32 : i32
    %4 = llhd.prb %q : !hw.inout<i32>
    %wr_en_data_arb.wr_en, %wr_en_data_arb.wr_data = hw.instance "wr_en_data_arb" @prim_subreg_arb_10(we: %we: i1, wd: %wd: i32, de: %de: i1, d: %d: i32, q: %4: i32) -> (wr_en: i1, wr_data: i32)
    llhd.drv %wr_en, %wr_en_data_arb.wr_en after %1 : !hw.inout<i1>
    llhd.drv %wr_data, %wr_en_data_arb.wr_data after %1 : !hw.inout<i32>
    llhd.process {
      cf.br ^bb1
    ^bb1:  // 5 preds: ^bb0, ^bb2, ^bb4, ^bb5, ^bb6
      %9 = llhd.prb %clk_i_0 : !hw.inout<i1>
      %10 = llhd.prb %rst_ni_1 : !hw.inout<i1>
      llhd.wait (%2, %3 : i1, i1), ^bb2
    ^bb2:  // pred: ^bb1
      %11 = llhd.prb %clk_i_0 : !hw.inout<i1>
      %12 = comb.xor bin %9, %true : i1
      %13 = comb.and bin %12, %11 : i1
      %14 = llhd.prb %rst_ni_1 : !hw.inout<i1>
      %15 = comb.xor bin %14, %true : i1
      %16 = comb.and bin %10, %15 : i1
      %17 = comb.or bin %13, %16 : i1
      cf.cond_br %17, ^bb3, ^bb1
    ^bb3:  // pred: ^bb2
      %18 = llhd.prb %rst_ni_1 : !hw.inout<i1>
      %19 = comb.xor %18, %true : i1
      cf.cond_br %19, ^bb4, ^bb5
    ^bb4:  // pred: ^bb3
      llhd.drv %q, %c0_i32 after %0 : !hw.inout<i32>
      cf.br ^bb1
    ^bb5:  // pred: ^bb3
      %20 = llhd.prb %wr_en : !hw.inout<i1>
      cf.cond_br %20, ^bb6, ^bb1
    ^bb6:  // pred: ^bb5
      %21 = llhd.prb %wr_data : !hw.inout<i32>
      llhd.drv %q, %21 after %0 : !hw.inout<i32>
      cf.br ^bb1
    }
    %5 = llhd.prb %wr_en : !hw.inout<i1>
    %6 = llhd.prb %wr_data : !hw.inout<i32>
    %7 = llhd.prb %qs : !hw.inout<i32>
    %8 = comb.mux %5, %6, %7 : i32
    llhd.drv %qs, %4 after %1 : !hw.inout<i32>
    llhd.drv %clk_i_0, %clk_i after %1 : !hw.inout<i1>
    llhd.drv %rst_ni_1, %rst_ni after %1 : !hw.inout<i1>
    hw.output %we, %4, %8, %7 : i1, i32, i32, i32
  }
  hw.module private @prim_subreg_4(in %clk_i : i1, in %rst_ni : i1, in %we : i1, in %wd : i32, in %de : i1, in %d : i32, out qe : i1, out q : i32, out ds : i32, out qs : i32) {
    %0 = llhd.constant_time <0ns, 1d, 0e>
    %true = hw.constant true
    %1 = llhd.constant_time <0ns, 0d, 1e>
    %c0_i32 = hw.constant 0 : i32
    %c-1_i32 = hw.constant -1 : i32
    %false = hw.constant false
    %clk_i_0 = llhd.sig name "clk_i" %false : i1
    %2 = llhd.prb %clk_i_0 : !hw.inout<i1>
    %rst_ni_1 = llhd.sig name "rst_ni" %false : i1
    %3 = llhd.prb %rst_ni_1 : !hw.inout<i1>
    %q = llhd.sig %c0_i32 : i32
    %qs = llhd.sig %c0_i32 : i32
    %wr_en = llhd.sig %false : i1
    %wr_data = llhd.sig %c0_i32 : i32
    %4 = llhd.prb %q : !hw.inout<i32>
    %wr_en_data_arb.wr_en, %wr_en_data_arb.wr_data = hw.instance "wr_en_data_arb" @prim_subreg_arb_10(we: %we: i1, wd: %wd: i32, de: %de: i1, d: %d: i32, q: %4: i32) -> (wr_en: i1, wr_data: i32)
    llhd.drv %wr_en, %wr_en_data_arb.wr_en after %1 : !hw.inout<i1>
    llhd.drv %wr_data, %wr_en_data_arb.wr_data after %1 : !hw.inout<i32>
    llhd.process {
      cf.br ^bb1
    ^bb1:  // 5 preds: ^bb0, ^bb2, ^bb4, ^bb5, ^bb6
      %9 = llhd.prb %clk_i_0 : !hw.inout<i1>
      %10 = llhd.prb %rst_ni_1 : !hw.inout<i1>
      llhd.wait (%2, %3 : i1, i1), ^bb2
    ^bb2:  // pred: ^bb1
      %11 = llhd.prb %clk_i_0 : !hw.inout<i1>
      %12 = comb.xor bin %9, %true : i1
      %13 = comb.and bin %12, %11 : i1
      %14 = llhd.prb %rst_ni_1 : !hw.inout<i1>
      %15 = comb.xor bin %14, %true : i1
      %16 = comb.and bin %10, %15 : i1
      %17 = comb.or bin %13, %16 : i1
      cf.cond_br %17, ^bb3, ^bb1
    ^bb3:  // pred: ^bb2
      %18 = llhd.prb %rst_ni_1 : !hw.inout<i1>
      %19 = comb.xor %18, %true : i1
      cf.cond_br %19, ^bb4, ^bb5
    ^bb4:  // pred: ^bb3
      llhd.drv %q, %c-1_i32 after %0 : !hw.inout<i32>
      cf.br ^bb1
    ^bb5:  // pred: ^bb3
      %20 = llhd.prb %wr_en : !hw.inout<i1>
      cf.cond_br %20, ^bb6, ^bb1
    ^bb6:  // pred: ^bb5
      %21 = llhd.prb %wr_data : !hw.inout<i32>
      llhd.drv %q, %21 after %0 : !hw.inout<i32>
      cf.br ^bb1
    }
    %5 = llhd.prb %wr_en : !hw.inout<i1>
    %6 = llhd.prb %wr_data : !hw.inout<i32>
    %7 = llhd.prb %qs : !hw.inout<i32>
    %8 = comb.mux %5, %6, %7 : i32
    llhd.drv %qs, %4 after %1 : !hw.inout<i32>
    llhd.drv %clk_i_0, %clk_i after %1 : !hw.inout<i1>
    llhd.drv %rst_ni_1, %rst_ni after %1 : !hw.inout<i1>
    hw.output %we, %4, %8, %7 : i1, i32, i32, i32
  }
  hw.module private @prim_subreg_ext(in %re : i1, in %we : i1, in %wd : i1, in %d : i1, out qe : i1, out qre : i1, out q : i1, out ds : i1, out qs : i1) {
    hw.output %we, %re, %wd, %d, %d : i1, i1, i1, i1, i1
  }
  hw.module private @prim_reg_we_check(in %clk_i : i1, in %rst_ni : i1, in %oh_i : i10, in %en_i : i1, out err_o : i1) {
    %c0_i4 = hw.constant 0 : i4
    %u_prim_buf.out_o = hw.instance "u_prim_buf" @prim_buf(in_i: %oh_i: i10) -> (out_o: i10) {sv.namehint = "oh_buf"}
    %u_prim_onehot_check.err_o = hw.instance "u_prim_onehot_check" @prim_onehot_check(clk_i: %clk_i: i1, rst_ni: %rst_ni: i1, oh_i: %u_prim_buf.out_o: i10, addr_i: %c0_i4: i4, en_i: %en_i: i1) -> (err_o: i1)
    hw.output %u_prim_onehot_check.err_o : i1
  }
  hw.module private @prim_subreg_arb(in %we : i1, in %wd : i1, in %de : i1, in %d : i1, in %q : i1, out wr_en : i1, out wr_data : i1) {
    %0 = llhd.constant_time <0ns, 0d, 1e>
    %false = hw.constant false
    %wd_0 = llhd.sig name "wd" %false : i1
    %d_1 = llhd.sig name "d" %false : i1
    %1 = comb.or %we, %de : i1
    %2 = llhd.prb %wd_0 : !hw.inout<i1>
    %3 = llhd.prb %d_1 : !hw.inout<i1>
    %4 = comb.mux %we, %2, %3 : i1
    llhd.drv %wd_0, %wd after %0 : !hw.inout<i1>
    llhd.drv %d_1, %d after %0 : !hw.inout<i1>
    hw.output %1, %4 : i1, i1
  }
  hw.module private @prim_subreg_arb_7(in %we : i1, in %wd : i1, in %de : i1, in %d : i1, in %q : i1, out wr_en : i1, out wr_data : i1) {
    %0 = llhd.constant_time <0ns, 0d, 1e>
    %true = hw.constant true
    %false = hw.constant false
    %wd_0 = llhd.sig name "wd" %false : i1
    %d_1 = llhd.sig name "d" %false : i1
    %q_2 = llhd.sig name "q" %false : i1
    %1 = comb.or %we, %de : i1
    %2 = llhd.prb %d_1 : !hw.inout<i1>
    %3 = llhd.prb %q_2 : !hw.inout<i1>
    %4 = comb.mux %de, %2, %3 : i1
    %5 = llhd.prb %wd_0 : !hw.inout<i1>
    %6 = comb.xor %5, %true : i1
    %7 = comb.xor %we, %true : i1
    %8 = comb.or %7, %6 : i1
    %9 = comb.and %4, %8 : i1
    llhd.drv %wd_0, %wd after %0 : !hw.inout<i1>
    llhd.drv %d_1, %d after %0 : !hw.inout<i1>
    llhd.drv %q_2, %q after %0 : !hw.inout<i1>
    hw.output %1, %9 : i1, i1
  }
  hw.module private @prim_subreg_arb_8(in %we : i1, in %wd : i12, in %de : i1, in %d : i12, in %q : i12, out wr_en : i1, out wr_data : i12) {
    %0 = llhd.constant_time <0ns, 0d, 1e>
    %c0_i12 = hw.constant 0 : i12
    %wd_0 = llhd.sig name "wd" %c0_i12 : i12
    %d_1 = llhd.sig name "d" %c0_i12 : i12
    %1 = comb.or %we, %de : i1
    %2 = llhd.prb %wd_0 : !hw.inout<i12>
    %3 = llhd.prb %d_1 : !hw.inout<i12>
    %4 = comb.mux %we, %2, %3 : i12
    llhd.drv %wd_0, %wd after %0 : !hw.inout<i12>
    llhd.drv %d_1, %d after %0 : !hw.inout<i12>
    hw.output %1, %4 : i1, i12
  }
  hw.module private @prim_subreg_arb_9(in %we : i1, in %wd : i8, in %de : i1, in %d : i8, in %q : i8, out wr_en : i1, out wr_data : i8) {
    %0 = llhd.constant_time <0ns, 0d, 1e>
    %c0_i8 = hw.constant 0 : i8
    %wd_0 = llhd.sig name "wd" %c0_i8 : i8
    %d_1 = llhd.sig name "d" %c0_i8 : i8
    %1 = comb.or %we, %de : i1
    %2 = llhd.prb %wd_0 : !hw.inout<i8>
    %3 = llhd.prb %d_1 : !hw.inout<i8>
    %4 = comb.mux %we, %2, %3 : i8
    llhd.drv %wd_0, %wd after %0 : !hw.inout<i8>
    llhd.drv %d_1, %d after %0 : !hw.inout<i8>
    hw.output %1, %4 : i1, i8
  }
  hw.module private @prim_subreg_arb_10(in %we : i1, in %wd : i32, in %de : i1, in %d : i32, in %q : i32, out wr_en : i1, out wr_data : i32) {
    %0 = llhd.constant_time <0ns, 0d, 1e>
    %c0_i32 = hw.constant 0 : i32
    %wd_0 = llhd.sig name "wd" %c0_i32 : i32
    %d_1 = llhd.sig name "d" %c0_i32 : i32
    %1 = comb.or %we, %de : i1
    %2 = llhd.prb %wd_0 : !hw.inout<i32>
    %3 = llhd.prb %d_1 : !hw.inout<i32>
    %4 = comb.mux %we, %2, %3 : i32
    llhd.drv %wd_0, %wd after %0 : !hw.inout<i32>
    llhd.drv %d_1, %d after %0 : !hw.inout<i32>
    hw.output %1, %4 : i1, i32
  }
  hw.module private @prim_buf(in %in_i : i10, out out_o : i10) {
    hw.output %in_i : i10
  }
  hw.module private @prim_buf_11(in %in_i : i2, out out_o : i2) {
    hw.output %in_i : i2
  }
  hw.module private @prim_buf_13(in %in_i : i1, out out_o : i1) {
    hw.output %in_i : i1
  }
  hw.module private @prim_onehot_check(in %clk_i : i1, in %rst_ni : i1, in %oh_i : i10, in %addr_i : i4, in %en_i : i1, out err_o : i1) {
    %c-2_i5 = hw.constant -2 : i5
    %c-3_i5 = hw.constant -3 : i5
    %c-4_i5 = hw.constant -4 : i5
    %c-5_i5 = hw.constant -5 : i5
    %c-6_i5 = hw.constant -6 : i5
    %c-7_i5 = hw.constant -7 : i5
    %c-8_i5 = hw.constant -8 : i5
    %c-9_i5 = hw.constant -9 : i5
    %c-10_i5 = hw.constant -10 : i5
    %c-11_i5 = hw.constant -11 : i5
    %c-12_i5 = hw.constant -12 : i5
    %c-13_i5 = hw.constant -13 : i5
    %c-14_i5 = hw.constant -14 : i5
    %c-15_i5 = hw.constant -15 : i5
    %c-16_i5 = hw.constant -16 : i5
    %c15_i5 = hw.constant 15 : i5
    %c14_i5 = hw.constant 14 : i5
    %c13_i5 = hw.constant 13 : i5
    %c12_i5 = hw.constant 12 : i5
    %c11_i5 = hw.constant 11 : i5
    %c10_i5 = hw.constant 10 : i5
    %c9_i5 = hw.constant 9 : i5
    %c8_i5 = hw.constant 8 : i5
    %c7_i5 = hw.constant 7 : i5
    %c6_i5 = hw.constant 6 : i5
    %c5_i5 = hw.constant 5 : i5
    %c4_i5 = hw.constant 4 : i5
    %c3_i5 = hw.constant 3 : i5
    %c2_i5 = hw.constant 2 : i5
    %c1_i5 = hw.constant 1 : i5
    %true = hw.constant true
    %0 = llhd.constant_time <0ns, 0d, 1e>
    %c0_i5 = hw.constant 0 : i5
    %false = hw.constant false {sv.namehint = "addr_err"}
    %c0_i31 = hw.constant 0 : i31
    %or_tree = llhd.sig %c0_i31 : i31
    %and_tree = llhd.sig %c0_i31 : i31
    %err_tree = llhd.sig %c0_i31 : i31
    %1 = llhd.sig.extract %or_tree from %c0_i5 : (!hw.inout<i31>) -> !hw.inout<i1>
    %2 = llhd.prb %or_tree : !hw.inout<i31>
    %3 = comb.extract %2 from 1 : (i31) -> i1
    %4 = comb.extract %2 from 2 : (i31) -> i1
    %5 = comb.or %3, %4 : i1
    llhd.drv %1, %5 after %0 : !hw.inout<i1>
    %6 = llhd.sig.extract %and_tree from %c0_i5 : (!hw.inout<i31>) -> !hw.inout<i1>
    %7 = comb.extract %addr_i from 3 : (i4) -> i1
    %8 = comb.xor %7, %true : i1
    %9 = llhd.prb %and_tree : !hw.inout<i31>
    %10 = comb.extract %9 from 1 : (i31) -> i1
    %11 = comb.and %8, %10 : i1
    %12 = comb.extract %9 from 2 : (i31) -> i1
    %13 = comb.and %7, %12 : i1
    %14 = comb.or %11, %13 : i1
    llhd.drv %6, %14 after %0 : !hw.inout<i1>
    %15 = llhd.sig.extract %err_tree from %c0_i5 : (!hw.inout<i31>) -> !hw.inout<i1>
    %16 = comb.and %3, %4 : i1
    %17 = llhd.prb %err_tree : !hw.inout<i31>
    %18 = comb.extract %17 from 1 : (i31) -> i1
    %19 = comb.extract %17 from 2 : (i31) -> i1
    %20 = comb.or %16, %18, %19 : i1
    llhd.drv %15, %20 after %0 : !hw.inout<i1>
    %21 = llhd.sig.extract %or_tree from %c1_i5 : (!hw.inout<i31>) -> !hw.inout<i1>
    %22 = comb.extract %2 from 3 : (i31) -> i1
    %23 = comb.extract %2 from 4 : (i31) -> i1
    %24 = comb.or %22, %23 : i1
    llhd.drv %21, %24 after %0 : !hw.inout<i1>
    %25 = llhd.sig.extract %and_tree from %c1_i5 : (!hw.inout<i31>) -> !hw.inout<i1>
    %26 = comb.extract %addr_i from 2 : (i4) -> i1
    %27 = comb.xor %26, %true : i1
    %28 = comb.extract %9 from 3 : (i31) -> i1
    %29 = comb.and %27, %28 : i1
    %30 = comb.extract %9 from 4 : (i31) -> i1
    %31 = comb.and %26, %30 : i1
    %32 = comb.or %29, %31 : i1
    llhd.drv %25, %32 after %0 : !hw.inout<i1>
    %33 = llhd.sig.extract %err_tree from %c1_i5 : (!hw.inout<i31>) -> !hw.inout<i1>
    %34 = comb.and %22, %23 : i1
    %35 = comb.extract %17 from 3 : (i31) -> i1
    %36 = comb.extract %17 from 4 : (i31) -> i1
    %37 = comb.or %34, %35, %36 : i1
    llhd.drv %33, %37 after %0 : !hw.inout<i1>
    %38 = llhd.sig.extract %or_tree from %c2_i5 : (!hw.inout<i31>) -> !hw.inout<i1>
    %39 = comb.extract %2 from 5 : (i31) -> i1
    %40 = comb.extract %2 from 6 : (i31) -> i1
    %41 = comb.or %39, %40 : i1
    llhd.drv %38, %41 after %0 : !hw.inout<i1>
    %42 = llhd.sig.extract %and_tree from %c2_i5 : (!hw.inout<i31>) -> !hw.inout<i1>
    %43 = comb.extract %9 from 5 : (i31) -> i1
    %44 = comb.and %27, %43 : i1
    %45 = comb.extract %9 from 6 : (i31) -> i1
    %46 = comb.and %26, %45 : i1
    %47 = comb.or %44, %46 : i1
    llhd.drv %42, %47 after %0 : !hw.inout<i1>
    %48 = llhd.sig.extract %err_tree from %c2_i5 : (!hw.inout<i31>) -> !hw.inout<i1>
    %49 = comb.and %39, %40 : i1
    %50 = comb.extract %17 from 5 : (i31) -> i1
    %51 = comb.extract %17 from 6 : (i31) -> i1
    %52 = comb.or %49, %50, %51 : i1
    llhd.drv %48, %52 after %0 : !hw.inout<i1>
    %53 = llhd.sig.extract %or_tree from %c3_i5 : (!hw.inout<i31>) -> !hw.inout<i1>
    %54 = comb.extract %2 from 7 : (i31) -> i1
    %55 = comb.extract %2 from 8 : (i31) -> i1
    %56 = comb.or %54, %55 : i1
    llhd.drv %53, %56 after %0 : !hw.inout<i1>
    %57 = llhd.sig.extract %and_tree from %c3_i5 : (!hw.inout<i31>) -> !hw.inout<i1>
    %58 = comb.extract %addr_i from 1 : (i4) -> i1
    %59 = comb.xor %58, %true : i1
    %60 = comb.extract %9 from 7 : (i31) -> i1
    %61 = comb.and %59, %60 : i1
    %62 = comb.extract %9 from 8 : (i31) -> i1
    %63 = comb.and %58, %62 : i1
    %64 = comb.or %61, %63 : i1
    llhd.drv %57, %64 after %0 : !hw.inout<i1>
    %65 = llhd.sig.extract %err_tree from %c3_i5 : (!hw.inout<i31>) -> !hw.inout<i1>
    %66 = comb.and %54, %55 : i1
    %67 = comb.extract %17 from 7 : (i31) -> i1
    %68 = comb.extract %17 from 8 : (i31) -> i1
    %69 = comb.or %66, %67, %68 : i1
    llhd.drv %65, %69 after %0 : !hw.inout<i1>
    %70 = llhd.sig.extract %or_tree from %c4_i5 : (!hw.inout<i31>) -> !hw.inout<i1>
    %71 = comb.extract %2 from 9 : (i31) -> i1
    %72 = comb.extract %2 from 10 : (i31) -> i1
    %73 = comb.or %71, %72 : i1
    llhd.drv %70, %73 after %0 : !hw.inout<i1>
    %74 = llhd.sig.extract %and_tree from %c4_i5 : (!hw.inout<i31>) -> !hw.inout<i1>
    %75 = comb.extract %9 from 9 : (i31) -> i1
    %76 = comb.and %59, %75 : i1
    %77 = comb.extract %9 from 10 : (i31) -> i1
    %78 = comb.and %58, %77 : i1
    %79 = comb.or %76, %78 : i1
    llhd.drv %74, %79 after %0 : !hw.inout<i1>
    %80 = llhd.sig.extract %err_tree from %c4_i5 : (!hw.inout<i31>) -> !hw.inout<i1>
    %81 = comb.and %71, %72 : i1
    %82 = comb.extract %17 from 9 : (i31) -> i1
    %83 = comb.extract %17 from 10 : (i31) -> i1
    %84 = comb.or %81, %82, %83 : i1
    llhd.drv %80, %84 after %0 : !hw.inout<i1>
    %85 = llhd.sig.extract %or_tree from %c5_i5 : (!hw.inout<i31>) -> !hw.inout<i1>
    %86 = comb.extract %2 from 11 : (i31) -> i1
    %87 = comb.extract %2 from 12 : (i31) -> i1
    %88 = comb.or %86, %87 : i1
    llhd.drv %85, %88 after %0 : !hw.inout<i1>
    %89 = llhd.sig.extract %and_tree from %c5_i5 : (!hw.inout<i31>) -> !hw.inout<i1>
    %90 = comb.extract %9 from 11 : (i31) -> i1
    %91 = comb.and %59, %90 : i1
    %92 = comb.extract %9 from 12 : (i31) -> i1
    %93 = comb.and %58, %92 : i1
    %94 = comb.or %91, %93 : i1
    llhd.drv %89, %94 after %0 : !hw.inout<i1>
    %95 = llhd.sig.extract %err_tree from %c5_i5 : (!hw.inout<i31>) -> !hw.inout<i1>
    %96 = comb.and %86, %87 : i1
    %97 = comb.extract %17 from 11 : (i31) -> i1
    %98 = comb.extract %17 from 12 : (i31) -> i1
    %99 = comb.or %96, %97, %98 : i1
    llhd.drv %95, %99 after %0 : !hw.inout<i1>
    %100 = llhd.sig.extract %or_tree from %c6_i5 : (!hw.inout<i31>) -> !hw.inout<i1>
    %101 = comb.extract %2 from 13 : (i31) -> i1
    %102 = comb.extract %2 from 14 : (i31) -> i1
    %103 = comb.or %101, %102 : i1
    llhd.drv %100, %103 after %0 : !hw.inout<i1>
    %104 = llhd.sig.extract %and_tree from %c6_i5 : (!hw.inout<i31>) -> !hw.inout<i1>
    %105 = comb.extract %9 from 13 : (i31) -> i1
    %106 = comb.and %59, %105 : i1
    %107 = comb.extract %9 from 14 : (i31) -> i1
    %108 = comb.and %58, %107 : i1
    %109 = comb.or %106, %108 : i1
    llhd.drv %104, %109 after %0 : !hw.inout<i1>
    %110 = llhd.sig.extract %err_tree from %c6_i5 : (!hw.inout<i31>) -> !hw.inout<i1>
    %111 = comb.and %101, %102 : i1
    %112 = comb.extract %17 from 13 : (i31) -> i1
    %113 = comb.extract %17 from 14 : (i31) -> i1
    %114 = comb.or %111, %112, %113 : i1
    llhd.drv %110, %114 after %0 : !hw.inout<i1>
    %115 = llhd.sig.extract %or_tree from %c7_i5 : (!hw.inout<i31>) -> !hw.inout<i1>
    %116 = comb.extract %2 from 15 : (i31) -> i1
    %117 = comb.extract %2 from 16 : (i31) -> i1
    %118 = comb.or %116, %117 : i1
    llhd.drv %115, %118 after %0 : !hw.inout<i1>
    %119 = llhd.sig.extract %and_tree from %c7_i5 : (!hw.inout<i31>) -> !hw.inout<i1>
    %120 = comb.extract %addr_i from 0 : (i4) -> i1
    %121 = comb.xor %120, %true : i1
    %122 = comb.extract %9 from 15 : (i31) -> i1
    %123 = comb.and %121, %122 : i1
    %124 = comb.extract %9 from 16 : (i31) -> i1
    %125 = comb.and %120, %124 : i1
    %126 = comb.or %123, %125 : i1
    llhd.drv %119, %126 after %0 : !hw.inout<i1>
    %127 = llhd.sig.extract %err_tree from %c7_i5 : (!hw.inout<i31>) -> !hw.inout<i1>
    %128 = comb.and %116, %117 : i1
    %129 = comb.extract %17 from 15 : (i31) -> i1
    %130 = comb.extract %17 from 16 : (i31) -> i1
    %131 = comb.or %128, %129, %130 : i1
    llhd.drv %127, %131 after %0 : !hw.inout<i1>
    %132 = llhd.sig.extract %or_tree from %c8_i5 : (!hw.inout<i31>) -> !hw.inout<i1>
    %133 = comb.extract %2 from 17 : (i31) -> i1
    %134 = comb.extract %2 from 18 : (i31) -> i1
    %135 = comb.or %133, %134 : i1
    llhd.drv %132, %135 after %0 : !hw.inout<i1>
    %136 = llhd.sig.extract %and_tree from %c8_i5 : (!hw.inout<i31>) -> !hw.inout<i1>
    %137 = comb.extract %9 from 17 : (i31) -> i1
    %138 = comb.and %121, %137 : i1
    %139 = comb.extract %9 from 18 : (i31) -> i1
    %140 = comb.and %120, %139 : i1
    %141 = comb.or %138, %140 : i1
    llhd.drv %136, %141 after %0 : !hw.inout<i1>
    %142 = llhd.sig.extract %err_tree from %c8_i5 : (!hw.inout<i31>) -> !hw.inout<i1>
    %143 = comb.and %133, %134 : i1
    %144 = comb.extract %17 from 17 : (i31) -> i1
    %145 = comb.extract %17 from 18 : (i31) -> i1
    %146 = comb.or %143, %144, %145 : i1
    llhd.drv %142, %146 after %0 : !hw.inout<i1>
    %147 = llhd.sig.extract %or_tree from %c9_i5 : (!hw.inout<i31>) -> !hw.inout<i1>
    %148 = comb.extract %2 from 19 : (i31) -> i1
    %149 = comb.extract %2 from 20 : (i31) -> i1
    %150 = comb.or %148, %149 : i1
    llhd.drv %147, %150 after %0 : !hw.inout<i1>
    %151 = llhd.sig.extract %and_tree from %c9_i5 : (!hw.inout<i31>) -> !hw.inout<i1>
    %152 = comb.extract %9 from 19 : (i31) -> i1
    %153 = comb.and %121, %152 : i1
    %154 = comb.extract %9 from 20 : (i31) -> i1
    %155 = comb.and %120, %154 : i1
    %156 = comb.or %153, %155 : i1
    llhd.drv %151, %156 after %0 : !hw.inout<i1>
    %157 = llhd.sig.extract %err_tree from %c9_i5 : (!hw.inout<i31>) -> !hw.inout<i1>
    %158 = comb.and %148, %149 : i1
    %159 = comb.extract %17 from 19 : (i31) -> i1
    %160 = comb.extract %17 from 20 : (i31) -> i1
    %161 = comb.or %158, %159, %160 : i1
    llhd.drv %157, %161 after %0 : !hw.inout<i1>
    %162 = llhd.sig.extract %or_tree from %c10_i5 : (!hw.inout<i31>) -> !hw.inout<i1>
    %163 = comb.extract %2 from 21 : (i31) -> i1
    %164 = comb.extract %2 from 22 : (i31) -> i1
    %165 = comb.or %163, %164 : i1
    llhd.drv %162, %165 after %0 : !hw.inout<i1>
    %166 = llhd.sig.extract %and_tree from %c10_i5 : (!hw.inout<i31>) -> !hw.inout<i1>
    %167 = comb.extract %9 from 21 : (i31) -> i1
    %168 = comb.and %121, %167 : i1
    %169 = comb.extract %9 from 22 : (i31) -> i1
    %170 = comb.and %120, %169 : i1
    %171 = comb.or %168, %170 : i1
    llhd.drv %166, %171 after %0 : !hw.inout<i1>
    %172 = llhd.sig.extract %err_tree from %c10_i5 : (!hw.inout<i31>) -> !hw.inout<i1>
    %173 = comb.and %163, %164 : i1
    %174 = comb.extract %17 from 21 : (i31) -> i1
    %175 = comb.extract %17 from 22 : (i31) -> i1
    %176 = comb.or %173, %174, %175 : i1
    llhd.drv %172, %176 after %0 : !hw.inout<i1>
    %177 = llhd.sig.extract %or_tree from %c11_i5 : (!hw.inout<i31>) -> !hw.inout<i1>
    %178 = comb.extract %2 from 23 : (i31) -> i1
    %179 = comb.extract %2 from 24 : (i31) -> i1
    %180 = comb.or %178, %179 : i1
    llhd.drv %177, %180 after %0 : !hw.inout<i1>
    %181 = llhd.sig.extract %and_tree from %c11_i5 : (!hw.inout<i31>) -> !hw.inout<i1>
    %182 = comb.extract %9 from 23 : (i31) -> i1
    %183 = comb.and %121, %182 : i1
    %184 = comb.extract %9 from 24 : (i31) -> i1
    %185 = comb.and %120, %184 : i1
    %186 = comb.or %183, %185 : i1
    llhd.drv %181, %186 after %0 : !hw.inout<i1>
    %187 = llhd.sig.extract %err_tree from %c11_i5 : (!hw.inout<i31>) -> !hw.inout<i1>
    %188 = comb.and %178, %179 : i1
    %189 = comb.extract %17 from 23 : (i31) -> i1
    %190 = comb.extract %17 from 24 : (i31) -> i1
    %191 = comb.or %188, %189, %190 : i1
    llhd.drv %187, %191 after %0 : !hw.inout<i1>
    %192 = llhd.sig.extract %or_tree from %c12_i5 : (!hw.inout<i31>) -> !hw.inout<i1>
    %193 = comb.extract %2 from 25 : (i31) -> i1
    %194 = comb.extract %2 from 26 : (i31) -> i1
    %195 = comb.or %193, %194 : i1
    llhd.drv %192, %195 after %0 : !hw.inout<i1>
    %196 = llhd.sig.extract %and_tree from %c12_i5 : (!hw.inout<i31>) -> !hw.inout<i1>
    %197 = comb.extract %9 from 25 : (i31) -> i1
    %198 = comb.and %121, %197 : i1
    %199 = comb.extract %9 from 26 : (i31) -> i1
    %200 = comb.and %120, %199 : i1
    %201 = comb.or %198, %200 : i1
    llhd.drv %196, %201 after %0 : !hw.inout<i1>
    %202 = llhd.sig.extract %err_tree from %c12_i5 : (!hw.inout<i31>) -> !hw.inout<i1>
    %203 = comb.and %193, %194 : i1
    %204 = comb.extract %17 from 25 : (i31) -> i1
    %205 = comb.extract %17 from 26 : (i31) -> i1
    %206 = comb.or %203, %204, %205 : i1
    llhd.drv %202, %206 after %0 : !hw.inout<i1>
    %207 = llhd.sig.extract %or_tree from %c13_i5 : (!hw.inout<i31>) -> !hw.inout<i1>
    %208 = comb.extract %2 from 27 : (i31) -> i1
    %209 = comb.extract %2 from 28 : (i31) -> i1
    %210 = comb.or %208, %209 : i1
    llhd.drv %207, %210 after %0 : !hw.inout<i1>
    %211 = llhd.sig.extract %and_tree from %c13_i5 : (!hw.inout<i31>) -> !hw.inout<i1>
    %212 = comb.extract %9 from 27 : (i31) -> i1
    %213 = comb.and %121, %212 : i1
    %214 = comb.extract %9 from 28 : (i31) -> i1
    %215 = comb.and %120, %214 : i1
    %216 = comb.or %213, %215 : i1
    llhd.drv %211, %216 after %0 : !hw.inout<i1>
    %217 = llhd.sig.extract %err_tree from %c13_i5 : (!hw.inout<i31>) -> !hw.inout<i1>
    %218 = comb.and %208, %209 : i1
    %219 = comb.extract %17 from 27 : (i31) -> i1
    %220 = comb.extract %17 from 28 : (i31) -> i1
    %221 = comb.or %218, %219, %220 : i1
    llhd.drv %217, %221 after %0 : !hw.inout<i1>
    %222 = llhd.sig.extract %or_tree from %c14_i5 : (!hw.inout<i31>) -> !hw.inout<i1>
    %223 = comb.extract %2 from 29 : (i31) -> i1
    %224 = comb.extract %2 from 30 : (i31) -> i1
    %225 = comb.or %223, %224 : i1
    llhd.drv %222, %225 after %0 : !hw.inout<i1>
    %226 = llhd.sig.extract %and_tree from %c14_i5 : (!hw.inout<i31>) -> !hw.inout<i1>
    %227 = comb.extract %9 from 29 : (i31) -> i1
    %228 = comb.and %121, %227 : i1
    %229 = comb.extract %9 from 30 : (i31) -> i1
    %230 = comb.and %120, %229 : i1
    %231 = comb.or %228, %230 : i1
    llhd.drv %226, %231 after %0 : !hw.inout<i1>
    %232 = llhd.sig.extract %err_tree from %c14_i5 : (!hw.inout<i31>) -> !hw.inout<i1>
    %233 = comb.and %223, %224 : i1
    %234 = comb.extract %17 from 29 : (i31) -> i1
    %235 = comb.extract %17 from 30 : (i31) -> i1
    %236 = comb.or %233, %234, %235 : i1
    llhd.drv %232, %236 after %0 : !hw.inout<i1>
    %237 = llhd.sig.extract %or_tree from %c15_i5 : (!hw.inout<i31>) -> !hw.inout<i1>
    %238 = comb.extract %oh_i from 0 : (i10) -> i1
    llhd.drv %237, %238 after %0 : !hw.inout<i1>
    %239 = llhd.sig.extract %and_tree from %c15_i5 : (!hw.inout<i31>) -> !hw.inout<i1>
    llhd.drv %239, %238 after %0 : !hw.inout<i1>
    %240 = llhd.sig.extract %err_tree from %c15_i5 : (!hw.inout<i31>) -> !hw.inout<i1>
    llhd.drv %240, %false after %0 : !hw.inout<i1>
    %241 = llhd.sig.extract %or_tree from %c-16_i5 : (!hw.inout<i31>) -> !hw.inout<i1>
    %242 = comb.extract %oh_i from 1 : (i10) -> i1
    llhd.drv %241, %242 after %0 : !hw.inout<i1>
    %243 = llhd.sig.extract %and_tree from %c-16_i5 : (!hw.inout<i31>) -> !hw.inout<i1>
    llhd.drv %243, %242 after %0 : !hw.inout<i1>
    %244 = llhd.sig.extract %err_tree from %c-16_i5 : (!hw.inout<i31>) -> !hw.inout<i1>
    llhd.drv %244, %false after %0 : !hw.inout<i1>
    %245 = llhd.sig.extract %or_tree from %c-15_i5 : (!hw.inout<i31>) -> !hw.inout<i1>
    %246 = comb.extract %oh_i from 2 : (i10) -> i1
    llhd.drv %245, %246 after %0 : !hw.inout<i1>
    %247 = llhd.sig.extract %and_tree from %c-15_i5 : (!hw.inout<i31>) -> !hw.inout<i1>
    llhd.drv %247, %246 after %0 : !hw.inout<i1>
    %248 = llhd.sig.extract %err_tree from %c-15_i5 : (!hw.inout<i31>) -> !hw.inout<i1>
    llhd.drv %248, %false after %0 : !hw.inout<i1>
    %249 = llhd.sig.extract %or_tree from %c-14_i5 : (!hw.inout<i31>) -> !hw.inout<i1>
    %250 = comb.extract %oh_i from 3 : (i10) -> i1
    llhd.drv %249, %250 after %0 : !hw.inout<i1>
    %251 = llhd.sig.extract %and_tree from %c-14_i5 : (!hw.inout<i31>) -> !hw.inout<i1>
    llhd.drv %251, %250 after %0 : !hw.inout<i1>
    %252 = llhd.sig.extract %err_tree from %c-14_i5 : (!hw.inout<i31>) -> !hw.inout<i1>
    llhd.drv %252, %false after %0 : !hw.inout<i1>
    %253 = llhd.sig.extract %or_tree from %c-13_i5 : (!hw.inout<i31>) -> !hw.inout<i1>
    %254 = comb.extract %oh_i from 4 : (i10) -> i1
    llhd.drv %253, %254 after %0 : !hw.inout<i1>
    %255 = llhd.sig.extract %and_tree from %c-13_i5 : (!hw.inout<i31>) -> !hw.inout<i1>
    llhd.drv %255, %254 after %0 : !hw.inout<i1>
    %256 = llhd.sig.extract %err_tree from %c-13_i5 : (!hw.inout<i31>) -> !hw.inout<i1>
    llhd.drv %256, %false after %0 : !hw.inout<i1>
    %257 = llhd.sig.extract %or_tree from %c-12_i5 : (!hw.inout<i31>) -> !hw.inout<i1>
    %258 = comb.extract %oh_i from 5 : (i10) -> i1
    llhd.drv %257, %258 after %0 : !hw.inout<i1>
    %259 = llhd.sig.extract %and_tree from %c-12_i5 : (!hw.inout<i31>) -> !hw.inout<i1>
    llhd.drv %259, %258 after %0 : !hw.inout<i1>
    %260 = llhd.sig.extract %err_tree from %c-12_i5 : (!hw.inout<i31>) -> !hw.inout<i1>
    llhd.drv %260, %false after %0 : !hw.inout<i1>
    %261 = llhd.sig.extract %or_tree from %c-11_i5 : (!hw.inout<i31>) -> !hw.inout<i1>
    %262 = comb.extract %oh_i from 6 : (i10) -> i1
    llhd.drv %261, %262 after %0 : !hw.inout<i1>
    %263 = llhd.sig.extract %and_tree from %c-11_i5 : (!hw.inout<i31>) -> !hw.inout<i1>
    llhd.drv %263, %262 after %0 : !hw.inout<i1>
    %264 = llhd.sig.extract %err_tree from %c-11_i5 : (!hw.inout<i31>) -> !hw.inout<i1>
    llhd.drv %264, %false after %0 : !hw.inout<i1>
    %265 = llhd.sig.extract %or_tree from %c-10_i5 : (!hw.inout<i31>) -> !hw.inout<i1>
    %266 = comb.extract %oh_i from 7 : (i10) -> i1
    llhd.drv %265, %266 after %0 : !hw.inout<i1>
    %267 = llhd.sig.extract %and_tree from %c-10_i5 : (!hw.inout<i31>) -> !hw.inout<i1>
    llhd.drv %267, %266 after %0 : !hw.inout<i1>
    %268 = llhd.sig.extract %err_tree from %c-10_i5 : (!hw.inout<i31>) -> !hw.inout<i1>
    llhd.drv %268, %false after %0 : !hw.inout<i1>
    %269 = llhd.sig.extract %or_tree from %c-9_i5 : (!hw.inout<i31>) -> !hw.inout<i1>
    %270 = comb.extract %oh_i from 8 : (i10) -> i1
    llhd.drv %269, %270 after %0 : !hw.inout<i1>
    %271 = llhd.sig.extract %and_tree from %c-9_i5 : (!hw.inout<i31>) -> !hw.inout<i1>
    llhd.drv %271, %270 after %0 : !hw.inout<i1>
    %272 = llhd.sig.extract %err_tree from %c-9_i5 : (!hw.inout<i31>) -> !hw.inout<i1>
    llhd.drv %272, %false after %0 : !hw.inout<i1>
    %273 = llhd.sig.extract %or_tree from %c-8_i5 : (!hw.inout<i31>) -> !hw.inout<i1>
    %274 = comb.extract %oh_i from 9 : (i10) -> i1
    llhd.drv %273, %274 after %0 : !hw.inout<i1>
    %275 = llhd.sig.extract %and_tree from %c-8_i5 : (!hw.inout<i31>) -> !hw.inout<i1>
    llhd.drv %275, %274 after %0 : !hw.inout<i1>
    %276 = llhd.sig.extract %err_tree from %c-8_i5 : (!hw.inout<i31>) -> !hw.inout<i1>
    llhd.drv %276, %false after %0 : !hw.inout<i1>
    %277 = llhd.sig.extract %or_tree from %c-7_i5 : (!hw.inout<i31>) -> !hw.inout<i1>
    llhd.drv %277, %false after %0 : !hw.inout<i1>
    %278 = llhd.sig.extract %and_tree from %c-7_i5 : (!hw.inout<i31>) -> !hw.inout<i1>
    llhd.drv %278, %false after %0 : !hw.inout<i1>
    %279 = llhd.sig.extract %err_tree from %c-7_i5 : (!hw.inout<i31>) -> !hw.inout<i1>
    llhd.drv %279, %false after %0 : !hw.inout<i1>
    %280 = llhd.sig.extract %or_tree from %c-6_i5 : (!hw.inout<i31>) -> !hw.inout<i1>
    llhd.drv %280, %false after %0 : !hw.inout<i1>
    %281 = llhd.sig.extract %and_tree from %c-6_i5 : (!hw.inout<i31>) -> !hw.inout<i1>
    llhd.drv %281, %false after %0 : !hw.inout<i1>
    %282 = llhd.sig.extract %err_tree from %c-6_i5 : (!hw.inout<i31>) -> !hw.inout<i1>
    llhd.drv %282, %false after %0 : !hw.inout<i1>
    %283 = llhd.sig.extract %or_tree from %c-5_i5 : (!hw.inout<i31>) -> !hw.inout<i1>
    llhd.drv %283, %false after %0 : !hw.inout<i1>
    %284 = llhd.sig.extract %and_tree from %c-5_i5 : (!hw.inout<i31>) -> !hw.inout<i1>
    llhd.drv %284, %false after %0 : !hw.inout<i1>
    %285 = llhd.sig.extract %err_tree from %c-5_i5 : (!hw.inout<i31>) -> !hw.inout<i1>
    llhd.drv %285, %false after %0 : !hw.inout<i1>
    %286 = llhd.sig.extract %or_tree from %c-4_i5 : (!hw.inout<i31>) -> !hw.inout<i1>
    llhd.drv %286, %false after %0 : !hw.inout<i1>
    %287 = llhd.sig.extract %and_tree from %c-4_i5 : (!hw.inout<i31>) -> !hw.inout<i1>
    llhd.drv %287, %false after %0 : !hw.inout<i1>
    %288 = llhd.sig.extract %err_tree from %c-4_i5 : (!hw.inout<i31>) -> !hw.inout<i1>
    llhd.drv %288, %false after %0 : !hw.inout<i1>
    %289 = llhd.sig.extract %or_tree from %c-3_i5 : (!hw.inout<i31>) -> !hw.inout<i1>
    llhd.drv %289, %false after %0 : !hw.inout<i1>
    %290 = llhd.sig.extract %and_tree from %c-3_i5 : (!hw.inout<i31>) -> !hw.inout<i1>
    llhd.drv %290, %false after %0 : !hw.inout<i1>
    %291 = llhd.sig.extract %err_tree from %c-3_i5 : (!hw.inout<i31>) -> !hw.inout<i1>
    llhd.drv %291, %false after %0 : !hw.inout<i1>
    %292 = llhd.sig.extract %or_tree from %c-2_i5 : (!hw.inout<i31>) -> !hw.inout<i1>
    llhd.drv %292, %false after %0 : !hw.inout<i1>
    %293 = llhd.sig.extract %and_tree from %c-2_i5 : (!hw.inout<i31>) -> !hw.inout<i1>
    llhd.drv %293, %false after %0 : !hw.inout<i1>
    %294 = llhd.sig.extract %err_tree from %c-2_i5 : (!hw.inout<i31>) -> !hw.inout<i1>
    llhd.drv %294, %false after %0 : !hw.inout<i1>
    %295 = comb.or %296, %299 : i1
    %296 = comb.extract %17 from 0 {sv.namehint = "oh0_err"} : (i31) -> i1
    %297 = comb.xor %en_i, %true : i1
    %298 = comb.extract %2 from 0 : (i31) -> i1
    %299 = comb.and %297, %298 {sv.namehint = "enable_err"} : i1
    hw.output %295 : i1
  }
  hw.module private @prim_flop(in %clk_i : i1, in %rst_ni : i1, in %d_i : i1, out q_o : i1) {
    %0 = llhd.constant_time <0ns, 0d, 1e>
    %1 = llhd.constant_time <0ns, 1d, 0e>
    %true = hw.constant true
    %false = hw.constant false
    %clk_i_0 = llhd.sig name "clk_i" %false : i1
    %2 = llhd.prb %clk_i_0 : !hw.inout<i1>
    %rst_ni_1 = llhd.sig name "rst_ni" %false : i1
    %3 = llhd.prb %rst_ni_1 : !hw.inout<i1>
    %d_i_2 = llhd.sig name "d_i" %false : i1
    %q_o = llhd.sig %false : i1
    llhd.process {
      cf.br ^bb1
    ^bb1:  // 4 preds: ^bb0, ^bb2, ^bb4, ^bb5
      %5 = llhd.prb %clk_i_0 : !hw.inout<i1>
      %6 = llhd.prb %rst_ni_1 : !hw.inout<i1>
      llhd.wait (%2, %3 : i1, i1), ^bb2
    ^bb2:  // pred: ^bb1
      %7 = llhd.prb %clk_i_0 : !hw.inout<i1>
      %8 = comb.xor bin %5, %true : i1
      %9 = comb.and bin %8, %7 : i1
      %10 = llhd.prb %rst_ni_1 : !hw.inout<i1>
      %11 = comb.xor bin %10, %true : i1
      %12 = comb.and bin %6, %11 : i1
      %13 = comb.or bin %9, %12 : i1
      cf.cond_br %13, ^bb3, ^bb1
    ^bb3:  // pred: ^bb2
      %14 = llhd.prb %rst_ni_1 : !hw.inout<i1>
      %15 = comb.xor %14, %true : i1
      cf.cond_br %15, ^bb4, ^bb5
    ^bb4:  // pred: ^bb3
      llhd.drv %q_o, %false after %1 : !hw.inout<i1>
      cf.br ^bb1
    ^bb5:  // pred: ^bb3
      %16 = llhd.prb %d_i_2 : !hw.inout<i1>
      llhd.drv %q_o, %16 after %1 : !hw.inout<i1>
      cf.br ^bb1
    }
    llhd.drv %clk_i_0, %clk_i after %0 : !hw.inout<i1>
    llhd.drv %rst_ni_1, %rst_ni after %0 : !hw.inout<i1>
    llhd.drv %d_i_2, %d_i after %0 : !hw.inout<i1>
    %4 = llhd.prb %q_o : !hw.inout<i1>
    hw.output %4 : i1
  }
  hw.module private @prim_flop_14(in %clk_i : i1, in %rst_ni : i1, in %d_i : i2, out q_o : i2) {
    %0 = llhd.constant_time <0ns, 0d, 1e>
    %1 = llhd.constant_time <0ns, 1d, 0e>
    %true = hw.constant true
    %c0_i2 = hw.constant 0 : i2
    %c-2_i2 = hw.constant -2 : i2
    %false = hw.constant false
    %clk_i_0 = llhd.sig name "clk_i" %false : i1
    %2 = llhd.prb %clk_i_0 : !hw.inout<i1>
    %rst_ni_1 = llhd.sig name "rst_ni" %false : i1
    %3 = llhd.prb %rst_ni_1 : !hw.inout<i1>
    %d_i_2 = llhd.sig name "d_i" %c0_i2 : i2
    %q_o = llhd.sig %c0_i2 : i2
    llhd.process {
      cf.br ^bb1
    ^bb1:  // 4 preds: ^bb0, ^bb2, ^bb4, ^bb5
      %5 = llhd.prb %clk_i_0 : !hw.inout<i1>
      %6 = llhd.prb %rst_ni_1 : !hw.inout<i1>
      llhd.wait (%2, %3 : i1, i1), ^bb2
    ^bb2:  // pred: ^bb1
      %7 = llhd.prb %clk_i_0 : !hw.inout<i1>
      %8 = comb.xor bin %5, %true : i1
      %9 = comb.and bin %8, %7 : i1
      %10 = llhd.prb %rst_ni_1 : !hw.inout<i1>
      %11 = comb.xor bin %10, %true : i1
      %12 = comb.and bin %6, %11 : i1
      %13 = comb.or bin %9, %12 : i1
      cf.cond_br %13, ^bb3, ^bb1
    ^bb3:  // pred: ^bb2
      %14 = llhd.prb %rst_ni_1 : !hw.inout<i1>
      %15 = comb.xor %14, %true : i1
      cf.cond_br %15, ^bb4, ^bb5
    ^bb4:  // pred: ^bb3
      llhd.drv %q_o, %c-2_i2 after %1 : !hw.inout<i2>
      cf.br ^bb1
    ^bb5:  // pred: ^bb3
      %16 = llhd.prb %d_i_2 : !hw.inout<i2>
      llhd.drv %q_o, %16 after %1 : !hw.inout<i2>
      cf.br ^bb1
    }
    llhd.drv %clk_i_0, %clk_i after %0 : !hw.inout<i1>
    llhd.drv %rst_ni_1, %rst_ni after %0 : !hw.inout<i1>
    llhd.drv %d_i_2, %d_i after %0 : !hw.inout<i2>
    %4 = llhd.prb %q_o : !hw.inout<i2>
    hw.output %4 : i2
  }
  hw.module private @prim_flop_15(in %clk_i : i1, in %rst_ni : i1, in %d_i : i1, out q_o : i1) {
    %0 = llhd.constant_time <0ns, 0d, 1e>
    %1 = llhd.constant_time <0ns, 1d, 0e>
    %true = hw.constant true
    %false = hw.constant false
    %clk_i_0 = llhd.sig name "clk_i" %false : i1
    %2 = llhd.prb %clk_i_0 : !hw.inout<i1>
    %rst_ni_1 = llhd.sig name "rst_ni" %false : i1
    %3 = llhd.prb %rst_ni_1 : !hw.inout<i1>
    %d_i_2 = llhd.sig name "d_i" %false : i1
    %q_o = llhd.sig %false : i1
    llhd.process {
      cf.br ^bb1
    ^bb1:  // 4 preds: ^bb0, ^bb2, ^bb4, ^bb5
      %5 = llhd.prb %clk_i_0 : !hw.inout<i1>
      %6 = llhd.prb %rst_ni_1 : !hw.inout<i1>
      llhd.wait (%2, %3 : i1, i1), ^bb2
    ^bb2:  // pred: ^bb1
      %7 = llhd.prb %clk_i_0 : !hw.inout<i1>
      %8 = comb.xor bin %5, %true : i1
      %9 = comb.and bin %8, %7 : i1
      %10 = llhd.prb %rst_ni_1 : !hw.inout<i1>
      %11 = comb.xor bin %10, %true : i1
      %12 = comb.and bin %6, %11 : i1
      %13 = comb.or bin %9, %12 : i1
      cf.cond_br %13, ^bb3, ^bb1
    ^bb3:  // pred: ^bb2
      %14 = llhd.prb %rst_ni_1 : !hw.inout<i1>
      %15 = comb.xor %14, %true : i1
      cf.cond_br %15, ^bb4, ^bb5
    ^bb4:  // pred: ^bb3
      llhd.drv %q_o, %true after %1 : !hw.inout<i1>
      cf.br ^bb1
    ^bb5:  // pred: ^bb3
      %16 = llhd.prb %d_i_2 : !hw.inout<i1>
      llhd.drv %q_o, %16 after %1 : !hw.inout<i1>
      cf.br ^bb1
    }
    llhd.drv %clk_i_0, %clk_i after %0 : !hw.inout<i1>
    llhd.drv %rst_ni_1, %rst_ni after %0 : !hw.inout<i1>
    llhd.drv %d_i_2, %d_i after %0 : !hw.inout<i1>
    %4 = llhd.prb %q_o : !hw.inout<i1>
    hw.output %4 : i1
  }
  hw.module private @prim_flop_2sync(in %clk_i : i1, in %rst_ni : i1, in %d_i : i1, out q_o : i1) {
    %0 = llhd.constant_time <0ns, 0d, 1e>
    %false = hw.constant false
    %d_i_0 = llhd.sig name "d_i" %false : i1
    %d_o = llhd.sig %false : i1
    %1 = llhd.prb %d_i_0 : !hw.inout<i1>
    %2 = llhd.prb %d_o : !hw.inout<i1>
    llhd.process {
      cf.br ^bb1
    ^bb1:  // 2 preds: ^bb0, ^bb1
      %3 = llhd.prb %d_i_0 : !hw.inout<i1>
      llhd.drv %d_o, %3 after %0 : !hw.inout<i1>
      llhd.wait (%1, %2 : i1, i1), ^bb1
    }
    %u_sync_1.q_o = hw.instance "u_sync_1" @prim_flop(clk_i: %clk_i: i1, rst_ni: %rst_ni: i1, d_i: %2: i1) -> (q_o: i1) {sv.namehint = "intq"}
    %u_sync_2.q_o = hw.instance "u_sync_2" @prim_flop(clk_i: %clk_i: i1, rst_ni: %rst_ni: i1, d_i: %u_sync_1.q_o: i1) -> (q_o: i1)
    llhd.drv %d_i_0, %d_i after %0 : !hw.inout<i1>
    hw.output %u_sync_2.q_o : i1
  }
  hw.module private @prim_flop_2sync_12(in %clk_i : i1, in %rst_ni : i1, in %d_i : i1, out q_o : i1) {
    %0 = llhd.constant_time <0ns, 0d, 1e>
    %false = hw.constant false
    %d_i_0 = llhd.sig name "d_i" %false : i1
    %d_o = llhd.sig %false : i1
    %1 = llhd.prb %d_i_0 : !hw.inout<i1>
    %2 = llhd.prb %d_o : !hw.inout<i1>
    llhd.process {
      cf.br ^bb1
    ^bb1:  // 2 preds: ^bb0, ^bb1
      %3 = llhd.prb %d_i_0 : !hw.inout<i1>
      llhd.drv %d_o, %3 after %0 : !hw.inout<i1>
      llhd.wait (%1, %2 : i1, i1), ^bb1
    }
    %u_sync_1.q_o = hw.instance "u_sync_1" @prim_flop_15(clk_i: %clk_i: i1, rst_ni: %rst_ni: i1, d_i: %2: i1) -> (q_o: i1) {sv.namehint = "intq"}
    %u_sync_2.q_o = hw.instance "u_sync_2" @prim_flop_15(clk_i: %clk_i: i1, rst_ni: %rst_ni: i1, d_i: %u_sync_1.q_o: i1) -> (q_o: i1)
    llhd.drv %d_i_0, %d_i after %0 : !hw.inout<i1>
    hw.output %u_sync_2.q_o : i1
  }
  hw.module private @prim_intr_hw(in %clk_i : i1, in %rst_ni : i1, in %event_intr_i : i1, in %reg2hw_intr_enable_q_i : i1, in %reg2hw_intr_test_q_i : i1, in %reg2hw_intr_test_qe_i : i1, in %reg2hw_intr_state_q_i : i1, out hw2reg_intr_state_de_o : i1, out hw2reg_intr_state_d_o : i1, out intr_o : i1) {
    %0 = llhd.constant_time <0ns, 1d, 0e>
    %true = hw.constant true
    %1 = llhd.constant_time <0ns, 0d, 1e>
    %false = hw.constant false
    %clk_i_0 = llhd.sig name "clk_i" %false : i1
    %2 = llhd.prb %clk_i_0 : !hw.inout<i1>
    %rst_ni_1 = llhd.sig name "rst_ni" %false : i1
    %3 = llhd.prb %rst_ni_1 : !hw.inout<i1>
    %reg2hw_intr_enable_q_i_2 = llhd.sig name "reg2hw_intr_enable_q_i" %false : i1
    %intr_o = llhd.sig %false : i1
    %status = llhd.sig %false : i1
    %4 = comb.and %reg2hw_intr_test_qe_i, %reg2hw_intr_test_q_i : i1
    %5 = comb.or %4, %event_intr_i {sv.namehint = "g_intr_event.new_event"} : i1
    %6 = comb.or %5, %reg2hw_intr_state_q_i : i1
    llhd.drv %status, %reg2hw_intr_state_q_i after %1 : !hw.inout<i1>
    llhd.process {
      cf.br ^bb1
    ^bb1:  // 4 preds: ^bb0, ^bb2, ^bb4, ^bb5
      %8 = llhd.prb %clk_i_0 : !hw.inout<i1>
      %9 = llhd.prb %rst_ni_1 : !hw.inout<i1>
      llhd.wait (%2, %3 : i1, i1), ^bb2
    ^bb2:  // pred: ^bb1
      %10 = llhd.prb %clk_i_0 : !hw.inout<i1>
      %11 = comb.xor bin %8, %true : i1
      %12 = comb.and bin %11, %10 : i1
      %13 = llhd.prb %rst_ni_1 : !hw.inout<i1>
      %14 = comb.xor bin %13, %true : i1
      %15 = comb.and bin %9, %14 : i1
      %16 = comb.or bin %12, %15 : i1
      cf.cond_br %16, ^bb3, ^bb1
    ^bb3:  // pred: ^bb2
      %17 = llhd.prb %rst_ni_1 : !hw.inout<i1>
      %18 = comb.xor %17, %true : i1
      cf.cond_br %18, ^bb4, ^bb5
    ^bb4:  // pred: ^bb3
      llhd.drv %intr_o, %false after %0 : !hw.inout<i1>
      cf.br ^bb1
    ^bb5:  // pred: ^bb3
      %19 = llhd.prb %status : !hw.inout<i1>
      %20 = llhd.prb %reg2hw_intr_enable_q_i_2 : !hw.inout<i1>
      %21 = comb.and %19, %20 : i1
      llhd.drv %intr_o, %21 after %0 : !hw.inout<i1>
      cf.br ^bb1
    }
    llhd.drv %clk_i_0, %clk_i after %1 : !hw.inout<i1>
    llhd.drv %rst_ni_1, %rst_ni after %1 : !hw.inout<i1>
    llhd.drv %reg2hw_intr_enable_q_i_2, %reg2hw_intr_enable_q_i after %1 : !hw.inout<i1>
    %7 = llhd.prb %intr_o : !hw.inout<i1>
    hw.output %5, %6, %7 : i1, i1, i1
  }
  hw.module private @prim_sec_anchor_buf(in %in_i : i2, out out_o : i2) {
    %u_secure_anchor_buf.out_o = hw.instance "u_secure_anchor_buf" @prim_buf_11(in_i: %in_i: i2) -> (out_o: i2)
    hw.output %u_secure_anchor_buf.out_o : i2
  }
  hw.module private @prim_sec_anchor_buf_5(in %in_i : i1, out out_o : i1) {
    %u_secure_anchor_buf.out_o = hw.instance "u_secure_anchor_buf" @prim_buf_13(in_i: %in_i: i1) -> (out_o: i1)
    hw.output %u_secure_anchor_buf.out_o : i1
  }
  hw.module private @prim_sec_anchor_flop(in %clk_i : i1, in %rst_ni : i1, in %d_i : i2, out q_o : i2) {
    %u_secure_anchor_flop.q_o = hw.instance "u_secure_anchor_flop" @prim_flop_14(clk_i: %clk_i: i1, rst_ni: %rst_ni: i1, d_i: %d_i: i2) -> (q_o: i2)
    hw.output %u_secure_anchor_flop.q_o : i2
  }
  hw.module private @prim_diff_decode(in %clk_i : i1, in %rst_ni : i1, in %diff_pi : i1, in %diff_ni : i1, out level_o : i1, out rise_o : i1, out fall_o : i1, out event_o : i1, out sigint_o : i1) {
    %0 = llhd.constant_time <0ns, 1d, 0e>
    %1 = llhd.constant_time <0ns, 0d, 1e>
    %c1_i2 = hw.constant 1 : i2
    %c-2_i2 = hw.constant -2 : i2
    %true = hw.constant true
    %c0_i2 = hw.constant 0 : i2
    %false = hw.constant false
    %clk_i_0 = llhd.sig name "clk_i" %false : i1
    %2 = llhd.prb %clk_i_0 : !hw.inout<i1>
    %rst_ni_1 = llhd.sig name "rst_ni" %false : i1
    %3 = llhd.prb %rst_ni_1 : !hw.inout<i1>
    %rise_o = llhd.sig %false : i1
    %fall_o = llhd.sig %false : i1
    %sigint_o = llhd.sig %false : i1
    %level_d = llhd.sig %false : i1
    %level_q = llhd.sig %false : i1
    %gen_async.state_d = llhd.sig %c0_i2 : i2
    %gen_async.state_q = llhd.sig %c0_i2 : i2
    %gen_async.diff_p_edge = llhd.sig %false : i1
    %gen_async.diff_n_edge = llhd.sig %false : i1
    %gen_async.diff_check_ok = llhd.sig %false : i1
    %gen_async.level = llhd.sig %false : i1
    %gen_async.diff_pq = llhd.sig %false : i1
    %gen_async.diff_nq = llhd.sig %false : i1
    %gen_async.diff_pd = llhd.sig %false : i1
    %gen_async.diff_nd = llhd.sig %false : i1
    %gen_async.skew_cnt_d = llhd.sig %false : i1
    %gen_async.skew_cnt_q = llhd.sig %false : i1
    %gen_async.i_sync_p.q_o = hw.instance "gen_async.i_sync_p" @prim_flop_2sync(clk_i: %2: i1, rst_ni: %3: i1, d_i: %diff_pi: i1) -> (q_o: i1)
    llhd.drv %gen_async.diff_pd, %gen_async.i_sync_p.q_o after %1 : !hw.inout<i1>
    %gen_async.i_sync_n.q_o = hw.instance "gen_async.i_sync_n" @prim_flop_2sync_12(clk_i: %2: i1, rst_ni: %3: i1, d_i: %diff_ni: i1) -> (q_o: i1)
    llhd.drv %gen_async.diff_nd, %gen_async.i_sync_n.q_o after %1 : !hw.inout<i1>
    %4 = llhd.prb %gen_async.diff_pq : !hw.inout<i1>
    %5 = llhd.prb %gen_async.diff_pd : !hw.inout<i1>
    %6 = comb.xor %4, %5 : i1
    llhd.drv %gen_async.diff_p_edge, %6 after %1 : !hw.inout<i1>
    %7 = llhd.prb %gen_async.diff_nq : !hw.inout<i1>
    %8 = llhd.prb %gen_async.diff_nd : !hw.inout<i1>
    %9 = comb.xor %7, %8 : i1
    llhd.drv %gen_async.diff_n_edge, %9 after %1 : !hw.inout<i1>
    %10 = comb.xor %5, %8 : i1
    llhd.drv %gen_async.diff_check_ok, %10 after %1 : !hw.inout<i1>
    llhd.drv %gen_async.level, %5 after %1 : !hw.inout<i1>
    %11 = llhd.prb %level_d : !hw.inout<i1>
    %12 = llhd.prb %rise_o : !hw.inout<i1>
    %13 = llhd.prb %fall_o : !hw.inout<i1>
    %14 = comb.or %12, %13 : i1
    %15 = llhd.prb %gen_async.state_q : !hw.inout<i2>
    %16 = llhd.prb %gen_async.state_d : !hw.inout<i2>
    %17 = llhd.prb %level_q : !hw.inout<i1>
    %18 = llhd.prb %gen_async.skew_cnt_q : !hw.inout<i1>
    %19 = llhd.prb %gen_async.skew_cnt_d : !hw.inout<i1>
    %20 = llhd.prb %sigint_o : !hw.inout<i1>
    %21 = llhd.prb %gen_async.diff_check_ok : !hw.inout<i1>
    %22 = llhd.prb %gen_async.level : !hw.inout<i1>
    %23 = llhd.prb %gen_async.diff_p_edge : !hw.inout<i1>
    %24 = llhd.prb %gen_async.diff_n_edge : !hw.inout<i1>
    llhd.process {
      cf.br ^bb1
    ^bb1:  // 2 preds: ^bb0, ^bb21
      %25 = llhd.prb %gen_async.state_q : !hw.inout<i2>
      llhd.drv %gen_async.state_d, %25 after %1 : !hw.inout<i2>
      %26 = llhd.prb %level_q : !hw.inout<i1>
      llhd.drv %level_d, %26 after %1 : !hw.inout<i1>
      %27 = llhd.prb %gen_async.skew_cnt_q : !hw.inout<i1>
      llhd.drv %gen_async.skew_cnt_d, %27 after %1 : !hw.inout<i1>
      llhd.drv %rise_o, %false after %1 : !hw.inout<i1>
      llhd.drv %fall_o, %false after %1 : !hw.inout<i1>
      llhd.drv %sigint_o, %false after %1 : !hw.inout<i1>
      %28 = llhd.prb %gen_async.state_q : !hw.inout<i2>
      %29 = comb.icmp ceq %28, %c0_i2 : i2
      cf.cond_br %29, ^bb2, ^bb8
    ^bb2:  // pred: ^bb1
      %30 = llhd.prb %gen_async.diff_check_ok : !hw.inout<i1>
      cf.cond_br %30, ^bb3, ^bb7
    ^bb3:  // pred: ^bb2
      %31 = llhd.prb %gen_async.level : !hw.inout<i1>
      llhd.drv %level_d, %31 after %1 : !hw.inout<i1>
      %32 = llhd.prb %gen_async.diff_p_edge : !hw.inout<i1>
      %33 = llhd.prb %gen_async.diff_n_edge : !hw.inout<i1>
      %34 = comb.and %32, %33 : i1
      cf.cond_br %34, ^bb4, ^bb21
    ^bb4:  // pred: ^bb3
      %35 = llhd.prb %gen_async.level : !hw.inout<i1>
      cf.cond_br %35, ^bb5, ^bb6
    ^bb5:  // pred: ^bb4
      llhd.drv %rise_o, %true after %1 : !hw.inout<i1>
      cf.br ^bb21
    ^bb6:  // pred: ^bb4
      llhd.drv %fall_o, %true after %1 : !hw.inout<i1>
      cf.br ^bb21
    ^bb7:  // pred: ^bb2
      llhd.drv %gen_async.state_d, %c1_i2 after %1 : !hw.inout<i2>
      llhd.drv %gen_async.skew_cnt_d, %true after %1 : !hw.inout<i1>
      cf.br ^bb21
    ^bb8:  // pred: ^bb1
      %36 = comb.icmp ceq %28, %c1_i2 : i2
      cf.cond_br %36, ^bb9, ^bb16
    ^bb9:  // pred: ^bb8
      %37 = llhd.prb %gen_async.diff_check_ok : !hw.inout<i1>
      cf.cond_br %37, ^bb10, ^bb13
    ^bb10:  // pred: ^bb9
      llhd.drv %gen_async.state_d, %c0_i2 after %1 : !hw.inout<i2>
      %38 = llhd.prb %gen_async.level : !hw.inout<i1>
      llhd.drv %level_d, %38 after %1 : !hw.inout<i1>
      llhd.drv %gen_async.skew_cnt_d, %false after %1 : !hw.inout<i1>
      %39 = llhd.prb %gen_async.level : !hw.inout<i1>
      cf.cond_br %39, ^bb11, ^bb12
    ^bb11:  // pred: ^bb10
      llhd.drv %rise_o, %true after %1 : !hw.inout<i1>
      cf.br ^bb21
    ^bb12:  // pred: ^bb10
      llhd.drv %fall_o, %true after %1 : !hw.inout<i1>
      cf.br ^bb21
    ^bb13:  // pred: ^bb9
      %40 = llhd.prb %gen_async.skew_cnt_q : !hw.inout<i1>
      %41 = comb.xor %40, %true : i1
      cf.cond_br %41, ^bb14, ^bb15
    ^bb14:  // pred: ^bb13
      %42 = llhd.prb %gen_async.skew_cnt_q : !hw.inout<i1>
      %43 = comb.add %42, %true : i1
      llhd.drv %gen_async.skew_cnt_d, %43 after %1 : !hw.inout<i1>
      cf.br ^bb21
    ^bb15:  // pred: ^bb13
      llhd.drv %gen_async.state_d, %c-2_i2 after %1 : !hw.inout<i2>
      llhd.drv %sigint_o, %true after %1 : !hw.inout<i1>
      llhd.drv %gen_async.skew_cnt_d, %false after %1 : !hw.inout<i1>
      cf.br ^bb21
    ^bb16:  // pred: ^bb8
      %44 = comb.icmp ceq %28, %c-2_i2 : i2
      cf.cond_br %44, ^bb17, ^bb21
    ^bb17:  // pred: ^bb16
      llhd.drv %sigint_o, %true after %1 : !hw.inout<i1>
      %45 = llhd.prb %gen_async.diff_check_ok : !hw.inout<i1>
      cf.cond_br %45, ^bb18, ^bb21
    ^bb18:  // pred: ^bb17
      llhd.drv %gen_async.state_d, %c0_i2 after %1 : !hw.inout<i2>
      llhd.drv %sigint_o, %false after %1 : !hw.inout<i1>
      %46 = llhd.prb %gen_async.level : !hw.inout<i1>
      llhd.drv %level_d, %46 after %1 : !hw.inout<i1>
      %47 = llhd.prb %gen_async.level : !hw.inout<i1>
      cf.cond_br %47, ^bb19, ^bb20
    ^bb19:  // pred: ^bb18
      llhd.drv %rise_o, %true after %1 : !hw.inout<i1>
      cf.br ^bb21
    ^bb20:  // pred: ^bb18
      llhd.drv %fall_o, %true after %1 : !hw.inout<i1>
      cf.br ^bb21
    ^bb21:  // 12 preds: ^bb3, ^bb5, ^bb6, ^bb7, ^bb11, ^bb12, ^bb14, ^bb15, ^bb16, ^bb17, ^bb19, ^bb20
      llhd.wait (%15, %16, %17, %11, %18, %19, %12, %13, %20, %21, %22, %23, %24 : i2, i2, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1), ^bb1
    }
    llhd.process {
      cf.br ^bb1
    ^bb1:  // 4 preds: ^bb0, ^bb2, ^bb4, ^bb5
      %25 = llhd.prb %clk_i_0 : !hw.inout<i1>
      %26 = llhd.prb %rst_ni_1 : !hw.inout<i1>
      llhd.wait (%2, %3 : i1, i1), ^bb2
    ^bb2:  // pred: ^bb1
      %27 = llhd.prb %clk_i_0 : !hw.inout<i1>
      %28 = comb.xor bin %25, %true : i1
      %29 = comb.and bin %28, %27 : i1
      %30 = llhd.prb %rst_ni_1 : !hw.inout<i1>
      %31 = comb.xor bin %30, %true : i1
      %32 = comb.and bin %26, %31 : i1
      %33 = comb.or bin %29, %32 : i1
      cf.cond_br %33, ^bb3, ^bb1
    ^bb3:  // pred: ^bb2
      %34 = llhd.prb %rst_ni_1 : !hw.inout<i1>
      %35 = comb.xor %34, %true : i1
      cf.cond_br %35, ^bb4, ^bb5
    ^bb4:  // pred: ^bb3
      llhd.drv %gen_async.state_q, %c0_i2 after %0 : !hw.inout<i2>
      llhd.drv %gen_async.diff_pq, %false after %0 : !hw.inout<i1>
      llhd.drv %gen_async.diff_nq, %true after %0 : !hw.inout<i1>
      llhd.drv %level_q, %false after %0 : !hw.inout<i1>
      llhd.drv %gen_async.skew_cnt_q, %false after %0 : !hw.inout<i1>
      cf.br ^bb1
    ^bb5:  // pred: ^bb3
      %36 = llhd.prb %gen_async.state_d : !hw.inout<i2>
      llhd.drv %gen_async.state_q, %36 after %0 : !hw.inout<i2>
      %37 = llhd.prb %gen_async.diff_pd : !hw.inout<i1>
      llhd.drv %gen_async.diff_pq, %37 after %0 : !hw.inout<i1>
      %38 = llhd.prb %gen_async.diff_nd : !hw.inout<i1>
      llhd.drv %gen_async.diff_nq, %38 after %0 : !hw.inout<i1>
      %39 = llhd.prb %level_d : !hw.inout<i1>
      llhd.drv %level_q, %39 after %0 : !hw.inout<i1>
      %40 = llhd.prb %gen_async.skew_cnt_d : !hw.inout<i1>
      llhd.drv %gen_async.skew_cnt_q, %40 after %0 : !hw.inout<i1>
      cf.br ^bb1
    }
    llhd.drv %clk_i_0, %clk_i after %1 : !hw.inout<i1>
    llhd.drv %rst_ni_1, %rst_ni after %1 : !hw.inout<i1>
    hw.output %11, %12, %13, %14, %20 : i1, i1, i1, i1, i1
  }
  hw.module private @prim_secded_inv_39_32_dec(in %data_i : i39, out data_o : i32, out syndrome_o : i7, out err_o : i2) {
    %c-136161252669_i38 = hw.constant -136161252669 : i38
    %c90194313216_i38 = hw.constant 90194313216 : i38
    %c-34167646061_i36 = hw.constant -34167646061 : i36
    %c-23622320128_i36 = hw.constant -23622320128 : i36
    %c-65452035525_i37 = hw.constant -65452035525 : i37
    %c42949672960_i37 = hw.constant 42949672960 : i37
    %c-33535340847_i36 = hw.constant -33535340847 : i36
    %c-25769803776_i36 = hw.constant -25769803776 : i36
    %c-8042658603_i34 = hw.constant -8042658603 : i34
    %c4294967296_i34 = hw.constant 4294967296 : i34
    %c0_i4 = hw.constant 0 : i4
    %c-303323131_i30 = hw.constant -303323131 : i30
    %c-536870912_i30 = hw.constant -536870912 : i30
    %c0_i6 = hw.constant 0 : i6
    %c-3656991451_i33 = hw.constant -3656991451 : i33
    %true = hw.constant true
    %false = hw.constant false
    %c-1_i5 = hw.constant -1 : i5
    %c-2_i5 = hw.constant -2 : i5
    %c-3_i5 = hw.constant -3 : i5
    %c-4_i5 = hw.constant -4 : i5
    %c-5_i5 = hw.constant -5 : i5
    %c-6_i5 = hw.constant -6 : i5
    %c-7_i5 = hw.constant -7 : i5
    %c-8_i5 = hw.constant -8 : i5
    %c-9_i5 = hw.constant -9 : i5
    %c-10_i5 = hw.constant -10 : i5
    %c-11_i5 = hw.constant -11 : i5
    %c-12_i5 = hw.constant -12 : i5
    %c-13_i5 = hw.constant -13 : i5
    %c-14_i5 = hw.constant -14 : i5
    %c-15_i5 = hw.constant -15 : i5
    %c-16_i5 = hw.constant -16 : i5
    %c15_i5 = hw.constant 15 : i5
    %c14_i5 = hw.constant 14 : i5
    %c13_i5 = hw.constant 13 : i5
    %c12_i5 = hw.constant 12 : i5
    %c11_i5 = hw.constant 11 : i5
    %c10_i5 = hw.constant 10 : i5
    %c9_i5 = hw.constant 9 : i5
    %c8_i5 = hw.constant 8 : i5
    %c7_i5 = hw.constant 7 : i5
    %c6_i5 = hw.constant 6 : i5
    %c5_i5 = hw.constant 5 : i5
    %c4_i5 = hw.constant 4 : i5
    %c3_i5 = hw.constant 3 : i5
    %c2_i5 = hw.constant 2 : i5
    %c1_i5 = hw.constant 1 : i5
    %c0_i5 = hw.constant 0 : i5
    %c-2_i3 = hw.constant -2 : i3
    %c-3_i3 = hw.constant -3 : i3
    %c-4_i3 = hw.constant -4 : i3
    %c3_i3 = hw.constant 3 : i3
    %c2_i3 = hw.constant 2 : i3
    %c1_i3 = hw.constant 1 : i3
    %0 = llhd.constant_time <0ns, 0d, 1e>
    %c0_i3 = hw.constant 0 : i3
    %c0_i2 = hw.constant 0 : i2
    %c0_i7 = hw.constant 0 : i7
    %c0_i32 = hw.constant 0 : i32
    %c-46_i7 = hw.constant -46 : i7
    %c22_i7 = hw.constant 22 : i7
    %c41_i7 = hw.constant 41 : i7
    %c-54_i7 = hw.constant -54 : i7
    %c-30_i7 = hw.constant -30 : i7
    %c35_i7 = hw.constant 35 : i7
    %c19_i7 = hw.constant 19 : i7
    %c44_i7 = hw.constant 44 : i7
    %c50_i7 = hw.constant 50 : i7
    %c-16_i7 = hw.constant -16 : i7
    %c14_i7 = hw.constant 14 : i7
    %c-58_i7 = hw.constant -58 : i7
    %c38_i7 = hw.constant 38 : i7
    %c37_i7 = hw.constant 37 : i7
    %c11_i7 = hw.constant 11 : i7
    %c28_i7 = hw.constant 28 : i7
    %c7_i7 = hw.constant 7 : i7
    %c-24_i7 = hw.constant -24 : i7
    %c49_i7 = hw.constant 49 : i7
    %c-47_i7 = hw.constant -47 : i7
    %c13_i7 = hw.constant 13 : i7
    %c-55_i7 = hw.constant -55 : i7
    %c56_i7 = hw.constant 56 : i7
    %c-59_i7 = hw.constant -59 : i7
    %c-52_i7 = hw.constant -52 : i7
    %c42_i7 = hw.constant 42 : i7
    %c21_i7 = hw.constant 21 : i7
    %c26_i7 = hw.constant 26 : i7
    %c52_i7 = hw.constant 52 : i7
    %c-31_i7 = hw.constant -31 : i7
    %c-44_i7 = hw.constant -44 : i7
    %c25_i7 = hw.constant 25 : i7
    %c0_i39 = hw.constant 0 : i39
    %data_i_0 = llhd.sig name "data_i" %c0_i39 : i39
    %data_o = llhd.sig %c0_i32 : i32
    %syndrome_o = llhd.sig %c0_i7 : i7
    %err_o = llhd.sig %c0_i2 : i2
    %1 = llhd.prb %syndrome_o : !hw.inout<i7>
    %2 = llhd.prb %data_i_0 : !hw.inout<i39>
    %3 = llhd.prb %data_o : !hw.inout<i32>
    %4 = llhd.prb %err_o : !hw.inout<i2>
    llhd.process {
      cf.br ^bb1
    ^bb1:  // 2 preds: ^bb0, ^bb1
      %5 = llhd.sig.extract %syndrome_o from %c0_i3 : (!hw.inout<i7>) -> !hw.inout<i1>
      %6 = llhd.prb %data_i_0 : !hw.inout<i39>
      %7 = comb.extract %6 from 0 : (i39) -> i33
      %8 = comb.and %7, %c-3656991451_i33 : i33
      %9 = comb.concat %c0_i6, %8 : i6, i33
      %10 = comb.parity %9 : i39
      llhd.drv %5, %10 after %0 : !hw.inout<i1>
      %11 = llhd.sig.extract %syndrome_o from %c1_i3 : (!hw.inout<i7>) -> !hw.inout<i1>
      %12 = llhd.prb %data_i_0 : !hw.inout<i39>
      %13 = comb.extract %12 from 4 : (i39) -> i30
      %14 = comb.xor %13, %c-536870912_i30 : i30
      %15 = comb.and %14, %c-303323131_i30 : i30
      %16 = comb.concat %c0_i5, %15, %c0_i4 : i5, i30, i4
      %17 = comb.parity %16 : i39
      llhd.drv %11, %17 after %0 : !hw.inout<i1>
      %18 = llhd.sig.extract %syndrome_o from %c2_i3 : (!hw.inout<i7>) -> !hw.inout<i1>
      %19 = llhd.prb %data_i_0 : !hw.inout<i39>
      %20 = comb.extract %19 from 1 : (i39) -> i34
      %21 = comb.xor %20, %c4294967296_i34 : i34
      %22 = comb.and %21, %c-8042658603_i34 : i34
      %23 = comb.concat %c0_i4, %22, %false : i4, i34, i1
      %24 = comb.parity %23 : i39
      llhd.drv %18, %24 after %0 : !hw.inout<i1>
      %25 = llhd.sig.extract %syndrome_o from %c3_i3 : (!hw.inout<i7>) -> !hw.inout<i1>
      %26 = llhd.prb %data_i_0 : !hw.inout<i39>
      %27 = comb.extract %26 from 0 : (i39) -> i36
      %28 = comb.xor %27, %c-25769803776_i36 : i36
      %29 = comb.and %28, %c-33535340847_i36 : i36
      %30 = comb.concat %c0_i3, %29 : i3, i36
      %31 = comb.parity %30 : i39
      llhd.drv %25, %31 after %0 : !hw.inout<i1>
      %32 = llhd.sig.extract %syndrome_o from %c-4_i3 : (!hw.inout<i7>) -> !hw.inout<i1>
      %33 = llhd.prb %data_i_0 : !hw.inout<i39>
      %34 = comb.extract %33 from 0 : (i39) -> i37
      %35 = comb.xor %34, %c42949672960_i37 : i37
      %36 = comb.and %35, %c-65452035525_i37 : i37
      %37 = comb.concat %c0_i2, %36 : i2, i37
      %38 = comb.parity %37 : i39
      llhd.drv %32, %38 after %0 : !hw.inout<i1>
      %39 = llhd.sig.extract %syndrome_o from %c-3_i3 : (!hw.inout<i7>) -> !hw.inout<i1>
      %40 = llhd.prb %data_i_0 : !hw.inout<i39>
      %41 = comb.extract %40 from 2 : (i39) -> i36
      %42 = comb.xor %41, %c-23622320128_i36 : i36
      %43 = comb.and %42, %c-34167646061_i36 : i36
      %44 = comb.concat %false, %43, %c0_i2 : i1, i36, i2
      %45 = comb.parity %44 : i39
      llhd.drv %39, %45 after %0 : !hw.inout<i1>
      %46 = llhd.sig.extract %syndrome_o from %c-2_i3 : (!hw.inout<i7>) -> !hw.inout<i1>
      %47 = llhd.prb %data_i_0 : !hw.inout<i39>
      %48 = comb.extract %47 from 1 : (i39) -> i38
      %49 = comb.xor %48, %c90194313216_i38 : i38
      %50 = comb.and %49, %c-136161252669_i38 : i38
      %51 = comb.concat %50, %false : i38, i1
      %52 = comb.parity %51 : i39
      llhd.drv %46, %52 after %0 : !hw.inout<i1>
      %53 = llhd.sig.extract %data_o from %c0_i5 : (!hw.inout<i32>) -> !hw.inout<i1>
      %54 = llhd.prb %syndrome_o : !hw.inout<i7>
      %55 = comb.icmp eq %54, %c25_i7 : i7
      %56 = llhd.prb %data_i_0 : !hw.inout<i39>
      %57 = comb.extract %56 from 0 : (i39) -> i1
      %58 = comb.xor %55, %57 : i1
      llhd.drv %53, %58 after %0 : !hw.inout<i1>
      %59 = llhd.sig.extract %data_o from %c1_i5 : (!hw.inout<i32>) -> !hw.inout<i1>
      %60 = llhd.prb %syndrome_o : !hw.inout<i7>
      %61 = comb.icmp eq %60, %c-44_i7 : i7
      %62 = llhd.prb %data_i_0 : !hw.inout<i39>
      %63 = comb.extract %62 from 1 : (i39) -> i1
      %64 = comb.xor %61, %63 : i1
      llhd.drv %59, %64 after %0 : !hw.inout<i1>
      %65 = llhd.sig.extract %data_o from %c2_i5 : (!hw.inout<i32>) -> !hw.inout<i1>
      %66 = llhd.prb %syndrome_o : !hw.inout<i7>
      %67 = comb.icmp eq %66, %c-31_i7 : i7
      %68 = llhd.prb %data_i_0 : !hw.inout<i39>
      %69 = comb.extract %68 from 2 : (i39) -> i1
      %70 = comb.xor %67, %69 : i1
      llhd.drv %65, %70 after %0 : !hw.inout<i1>
      %71 = llhd.sig.extract %data_o from %c3_i5 : (!hw.inout<i32>) -> !hw.inout<i1>
      %72 = llhd.prb %syndrome_o : !hw.inout<i7>
      %73 = comb.icmp eq %72, %c52_i7 : i7
      %74 = llhd.prb %data_i_0 : !hw.inout<i39>
      %75 = comb.extract %74 from 3 : (i39) -> i1
      %76 = comb.xor %73, %75 : i1
      llhd.drv %71, %76 after %0 : !hw.inout<i1>
      %77 = llhd.sig.extract %data_o from %c4_i5 : (!hw.inout<i32>) -> !hw.inout<i1>
      %78 = llhd.prb %syndrome_o : !hw.inout<i7>
      %79 = comb.icmp eq %78, %c26_i7 : i7
      %80 = llhd.prb %data_i_0 : !hw.inout<i39>
      %81 = comb.extract %80 from 4 : (i39) -> i1
      %82 = comb.xor %79, %81 : i1
      llhd.drv %77, %82 after %0 : !hw.inout<i1>
      %83 = llhd.sig.extract %data_o from %c5_i5 : (!hw.inout<i32>) -> !hw.inout<i1>
      %84 = llhd.prb %syndrome_o : !hw.inout<i7>
      %85 = comb.icmp eq %84, %c21_i7 : i7
      %86 = llhd.prb %data_i_0 : !hw.inout<i39>
      %87 = comb.extract %86 from 5 : (i39) -> i1
      %88 = comb.xor %85, %87 : i1
      llhd.drv %83, %88 after %0 : !hw.inout<i1>
      %89 = llhd.sig.extract %data_o from %c6_i5 : (!hw.inout<i32>) -> !hw.inout<i1>
      %90 = llhd.prb %syndrome_o : !hw.inout<i7>
      %91 = comb.icmp eq %90, %c42_i7 : i7
      %92 = llhd.prb %data_i_0 : !hw.inout<i39>
      %93 = comb.extract %92 from 6 : (i39) -> i1
      %94 = comb.xor %91, %93 : i1
      llhd.drv %89, %94 after %0 : !hw.inout<i1>
      %95 = llhd.sig.extract %data_o from %c7_i5 : (!hw.inout<i32>) -> !hw.inout<i1>
      %96 = llhd.prb %syndrome_o : !hw.inout<i7>
      %97 = comb.icmp eq %96, %c-52_i7 : i7
      %98 = llhd.prb %data_i_0 : !hw.inout<i39>
      %99 = comb.extract %98 from 7 : (i39) -> i1
      %100 = comb.xor %97, %99 : i1
      llhd.drv %95, %100 after %0 : !hw.inout<i1>
      %101 = llhd.sig.extract %data_o from %c8_i5 : (!hw.inout<i32>) -> !hw.inout<i1>
      %102 = llhd.prb %syndrome_o : !hw.inout<i7>
      %103 = comb.icmp eq %102, %c-59_i7 : i7
      %104 = llhd.prb %data_i_0 : !hw.inout<i39>
      %105 = comb.extract %104 from 8 : (i39) -> i1
      %106 = comb.xor %103, %105 : i1
      llhd.drv %101, %106 after %0 : !hw.inout<i1>
      %107 = llhd.sig.extract %data_o from %c9_i5 : (!hw.inout<i32>) -> !hw.inout<i1>
      %108 = llhd.prb %syndrome_o : !hw.inout<i7>
      %109 = comb.icmp eq %108, %c56_i7 : i7
      %110 = llhd.prb %data_i_0 : !hw.inout<i39>
      %111 = comb.extract %110 from 9 : (i39) -> i1
      %112 = comb.xor %109, %111 : i1
      llhd.drv %107, %112 after %0 : !hw.inout<i1>
      %113 = llhd.sig.extract %data_o from %c10_i5 : (!hw.inout<i32>) -> !hw.inout<i1>
      %114 = llhd.prb %syndrome_o : !hw.inout<i7>
      %115 = comb.icmp eq %114, %c-55_i7 : i7
      %116 = llhd.prb %data_i_0 : !hw.inout<i39>
      %117 = comb.extract %116 from 10 : (i39) -> i1
      %118 = comb.xor %115, %117 : i1
      llhd.drv %113, %118 after %0 : !hw.inout<i1>
      %119 = llhd.sig.extract %data_o from %c11_i5 : (!hw.inout<i32>) -> !hw.inout<i1>
      %120 = llhd.prb %syndrome_o : !hw.inout<i7>
      %121 = comb.icmp eq %120, %c13_i7 : i7
      %122 = llhd.prb %data_i_0 : !hw.inout<i39>
      %123 = comb.extract %122 from 11 : (i39) -> i1
      %124 = comb.xor %121, %123 : i1
      llhd.drv %119, %124 after %0 : !hw.inout<i1>
      %125 = llhd.sig.extract %data_o from %c12_i5 : (!hw.inout<i32>) -> !hw.inout<i1>
      %126 = llhd.prb %syndrome_o : !hw.inout<i7>
      %127 = comb.icmp eq %126, %c-47_i7 : i7
      %128 = llhd.prb %data_i_0 : !hw.inout<i39>
      %129 = comb.extract %128 from 12 : (i39) -> i1
      %130 = comb.xor %127, %129 : i1
      llhd.drv %125, %130 after %0 : !hw.inout<i1>
      %131 = llhd.sig.extract %data_o from %c13_i5 : (!hw.inout<i32>) -> !hw.inout<i1>
      %132 = llhd.prb %syndrome_o : !hw.inout<i7>
      %133 = comb.icmp eq %132, %c49_i7 : i7
      %134 = llhd.prb %data_i_0 : !hw.inout<i39>
      %135 = comb.extract %134 from 13 : (i39) -> i1
      %136 = comb.xor %133, %135 : i1
      llhd.drv %131, %136 after %0 : !hw.inout<i1>
      %137 = llhd.sig.extract %data_o from %c14_i5 : (!hw.inout<i32>) -> !hw.inout<i1>
      %138 = llhd.prb %syndrome_o : !hw.inout<i7>
      %139 = comb.icmp eq %138, %c-24_i7 : i7
      %140 = llhd.prb %data_i_0 : !hw.inout<i39>
      %141 = comb.extract %140 from 14 : (i39) -> i1
      %142 = comb.xor %139, %141 : i1
      llhd.drv %137, %142 after %0 : !hw.inout<i1>
      %143 = llhd.sig.extract %data_o from %c15_i5 : (!hw.inout<i32>) -> !hw.inout<i1>
      %144 = llhd.prb %syndrome_o : !hw.inout<i7>
      %145 = comb.icmp eq %144, %c7_i7 : i7
      %146 = llhd.prb %data_i_0 : !hw.inout<i39>
      %147 = comb.extract %146 from 15 : (i39) -> i1
      %148 = comb.xor %145, %147 : i1
      llhd.drv %143, %148 after %0 : !hw.inout<i1>
      %149 = llhd.sig.extract %data_o from %c-16_i5 : (!hw.inout<i32>) -> !hw.inout<i1>
      %150 = llhd.prb %syndrome_o : !hw.inout<i7>
      %151 = comb.icmp eq %150, %c28_i7 : i7
      %152 = llhd.prb %data_i_0 : !hw.inout<i39>
      %153 = comb.extract %152 from 16 : (i39) -> i1
      %154 = comb.xor %151, %153 : i1
      llhd.drv %149, %154 after %0 : !hw.inout<i1>
      %155 = llhd.sig.extract %data_o from %c-15_i5 : (!hw.inout<i32>) -> !hw.inout<i1>
      %156 = llhd.prb %syndrome_o : !hw.inout<i7>
      %157 = comb.icmp eq %156, %c11_i7 : i7
      %158 = llhd.prb %data_i_0 : !hw.inout<i39>
      %159 = comb.extract %158 from 17 : (i39) -> i1
      %160 = comb.xor %157, %159 : i1
      llhd.drv %155, %160 after %0 : !hw.inout<i1>
      %161 = llhd.sig.extract %data_o from %c-14_i5 : (!hw.inout<i32>) -> !hw.inout<i1>
      %162 = llhd.prb %syndrome_o : !hw.inout<i7>
      %163 = comb.icmp eq %162, %c37_i7 : i7
      %164 = llhd.prb %data_i_0 : !hw.inout<i39>
      %165 = comb.extract %164 from 18 : (i39) -> i1
      %166 = comb.xor %163, %165 : i1
      llhd.drv %161, %166 after %0 : !hw.inout<i1>
      %167 = llhd.sig.extract %data_o from %c-13_i5 : (!hw.inout<i32>) -> !hw.inout<i1>
      %168 = llhd.prb %syndrome_o : !hw.inout<i7>
      %169 = comb.icmp eq %168, %c38_i7 : i7
      %170 = llhd.prb %data_i_0 : !hw.inout<i39>
      %171 = comb.extract %170 from 19 : (i39) -> i1
      %172 = comb.xor %169, %171 : i1
      llhd.drv %167, %172 after %0 : !hw.inout<i1>
      %173 = llhd.sig.extract %data_o from %c-12_i5 : (!hw.inout<i32>) -> !hw.inout<i1>
      %174 = llhd.prb %syndrome_o : !hw.inout<i7>
      %175 = comb.icmp eq %174, %c-58_i7 : i7
      %176 = llhd.prb %data_i_0 : !hw.inout<i39>
      %177 = comb.extract %176 from 20 : (i39) -> i1
      %178 = comb.xor %175, %177 : i1
      llhd.drv %173, %178 after %0 : !hw.inout<i1>
      %179 = llhd.sig.extract %data_o from %c-11_i5 : (!hw.inout<i32>) -> !hw.inout<i1>
      %180 = llhd.prb %syndrome_o : !hw.inout<i7>
      %181 = comb.icmp eq %180, %c14_i7 : i7
      %182 = llhd.prb %data_i_0 : !hw.inout<i39>
      %183 = comb.extract %182 from 21 : (i39) -> i1
      %184 = comb.xor %181, %183 : i1
      llhd.drv %179, %184 after %0 : !hw.inout<i1>
      %185 = llhd.sig.extract %data_o from %c-10_i5 : (!hw.inout<i32>) -> !hw.inout<i1>
      %186 = llhd.prb %syndrome_o : !hw.inout<i7>
      %187 = comb.icmp eq %186, %c-16_i7 : i7
      %188 = llhd.prb %data_i_0 : !hw.inout<i39>
      %189 = comb.extract %188 from 22 : (i39) -> i1
      %190 = comb.xor %187, %189 : i1
      llhd.drv %185, %190 after %0 : !hw.inout<i1>
      %191 = llhd.sig.extract %data_o from %c-9_i5 : (!hw.inout<i32>) -> !hw.inout<i1>
      %192 = llhd.prb %syndrome_o : !hw.inout<i7>
      %193 = comb.icmp eq %192, %c50_i7 : i7
      %194 = llhd.prb %data_i_0 : !hw.inout<i39>
      %195 = comb.extract %194 from 23 : (i39) -> i1
      %196 = comb.xor %193, %195 : i1
      llhd.drv %191, %196 after %0 : !hw.inout<i1>
      %197 = llhd.sig.extract %data_o from %c-8_i5 : (!hw.inout<i32>) -> !hw.inout<i1>
      %198 = llhd.prb %syndrome_o : !hw.inout<i7>
      %199 = comb.icmp eq %198, %c44_i7 : i7
      %200 = llhd.prb %data_i_0 : !hw.inout<i39>
      %201 = comb.extract %200 from 24 : (i39) -> i1
      %202 = comb.xor %199, %201 : i1
      llhd.drv %197, %202 after %0 : !hw.inout<i1>
      %203 = llhd.sig.extract %data_o from %c-7_i5 : (!hw.inout<i32>) -> !hw.inout<i1>
      %204 = llhd.prb %syndrome_o : !hw.inout<i7>
      %205 = comb.icmp eq %204, %c19_i7 : i7
      %206 = llhd.prb %data_i_0 : !hw.inout<i39>
      %207 = comb.extract %206 from 25 : (i39) -> i1
      %208 = comb.xor %205, %207 : i1
      llhd.drv %203, %208 after %0 : !hw.inout<i1>
      %209 = llhd.sig.extract %data_o from %c-6_i5 : (!hw.inout<i32>) -> !hw.inout<i1>
      %210 = llhd.prb %syndrome_o : !hw.inout<i7>
      %211 = comb.icmp eq %210, %c35_i7 : i7
      %212 = llhd.prb %data_i_0 : !hw.inout<i39>
      %213 = comb.extract %212 from 26 : (i39) -> i1
      %214 = comb.xor %211, %213 : i1
      llhd.drv %209, %214 after %0 : !hw.inout<i1>
      %215 = llhd.sig.extract %data_o from %c-5_i5 : (!hw.inout<i32>) -> !hw.inout<i1>
      %216 = llhd.prb %syndrome_o : !hw.inout<i7>
      %217 = comb.icmp eq %216, %c-30_i7 : i7
      %218 = llhd.prb %data_i_0 : !hw.inout<i39>
      %219 = comb.extract %218 from 27 : (i39) -> i1
      %220 = comb.xor %217, %219 : i1
      llhd.drv %215, %220 after %0 : !hw.inout<i1>
      %221 = llhd.sig.extract %data_o from %c-4_i5 : (!hw.inout<i32>) -> !hw.inout<i1>
      %222 = llhd.prb %syndrome_o : !hw.inout<i7>
      %223 = comb.icmp eq %222, %c-54_i7 : i7
      %224 = llhd.prb %data_i_0 : !hw.inout<i39>
      %225 = comb.extract %224 from 28 : (i39) -> i1
      %226 = comb.xor %223, %225 : i1
      llhd.drv %221, %226 after %0 : !hw.inout<i1>
      %227 = llhd.sig.extract %data_o from %c-3_i5 : (!hw.inout<i32>) -> !hw.inout<i1>
      %228 = llhd.prb %syndrome_o : !hw.inout<i7>
      %229 = comb.icmp eq %228, %c41_i7 : i7
      %230 = llhd.prb %data_i_0 : !hw.inout<i39>
      %231 = comb.extract %230 from 29 : (i39) -> i1
      %232 = comb.xor %229, %231 : i1
      llhd.drv %227, %232 after %0 : !hw.inout<i1>
      %233 = llhd.sig.extract %data_o from %c-2_i5 : (!hw.inout<i32>) -> !hw.inout<i1>
      %234 = llhd.prb %syndrome_o : !hw.inout<i7>
      %235 = comb.icmp eq %234, %c22_i7 : i7
      %236 = llhd.prb %data_i_0 : !hw.inout<i39>
      %237 = comb.extract %236 from 30 : (i39) -> i1
      %238 = comb.xor %235, %237 : i1
      llhd.drv %233, %238 after %0 : !hw.inout<i1>
      %239 = llhd.sig.extract %data_o from %c-1_i5 : (!hw.inout<i32>) -> !hw.inout<i1>
      %240 = llhd.prb %syndrome_o : !hw.inout<i7>
      %241 = comb.icmp eq %240, %c-46_i7 : i7
      %242 = llhd.prb %data_i_0 : !hw.inout<i39>
      %243 = comb.extract %242 from 31 : (i39) -> i1
      %244 = comb.xor %241, %243 : i1
      llhd.drv %239, %244 after %0 : !hw.inout<i1>
      %245 = llhd.sig.extract %err_o from %false : (!hw.inout<i2>) -> !hw.inout<i1>
      %246 = llhd.prb %syndrome_o : !hw.inout<i7>
      %247 = comb.parity %246 : i7
      llhd.drv %245, %247 after %0 : !hw.inout<i1>
      %248 = llhd.sig.extract %err_o from %true : (!hw.inout<i2>) -> !hw.inout<i1>
      %249 = llhd.prb %err_o : !hw.inout<i2>
      %250 = comb.extract %249 from 0 : (i2) -> i1
      %251 = comb.xor %250, %true : i1
      %252 = llhd.prb %syndrome_o : !hw.inout<i7>
      %253 = comb.icmp ne %252, %c0_i7 : i7
      %254 = comb.and %251, %253 : i1
      llhd.drv %248, %254 after %0 : !hw.inout<i1>
      llhd.wait (%1, %2, %3, %4 : i7, i39, i32, i2), ^bb1
    }
    llhd.drv %data_i_0, %data_i after %0 : !hw.inout<i39>
    hw.output %3, %1, %4 : i32, i7, i2
  }
  hw.module private @prim_secded_inv_39_32_enc(in %data_i : i32, out data_o : i39) {
    %c-869782845_i31 = hw.constant -869782845 : i31
    %c0_i2 = hw.constant 0 : i2
    %c-76343149_i28 = hw.constant -76343149 : i28
    %c-1027526085_i32 = hw.constant -1027526085 : i32
    %c-249344303_i30 = hw.constant -249344303 : i30
    %false = hw.constant false
    %c0_i8 = hw.constant 0 : i8
    %c-526465835_i30 = hw.constant -526465835 : i30
    %c0_i4 = hw.constant 0 : i4
    %c-34887675_i28 = hw.constant -34887675 : i28
    %c0_i9 = hw.constant 0 : i9
    %c-435765979_i30 = hw.constant -435765979 : i30
    %c-26_i6 = hw.constant -26 : i6
    %c-27_i6 = hw.constant -27 : i6
    %c-28_i6 = hw.constant -28 : i6
    %c-29_i6 = hw.constant -29 : i6
    %c-30_i6 = hw.constant -30 : i6
    %c-31_i6 = hw.constant -31 : i6
    %c-32_i6 = hw.constant -32 : i6
    %0 = llhd.constant_time <0ns, 0d, 1e>
    %c0_i7 = hw.constant 0 : i7
    %c0_i39 = hw.constant 0 : i39
    %c180388626432_i39 = hw.constant 180388626432 : i39
    %c0_i32 = hw.constant 0 : i32
    %data_i_0 = llhd.sig name "data_i" %c0_i32 : i32
    %data_o = llhd.sig %c0_i39 : i39
    %1 = llhd.prb %data_i_0 : !hw.inout<i32>
    %2 = llhd.prb %data_o : !hw.inout<i39>
    llhd.process {
      cf.br ^bb1
    ^bb1:  // 2 preds: ^bb0, ^bb1
      %3 = llhd.prb %data_i_0 : !hw.inout<i32>
      %4 = comb.concat %c0_i7, %3 : i7, i32
      llhd.drv %data_o, %4 after %0 : !hw.inout<i39>
      %5 = llhd.sig.extract %data_o from %c-32_i6 : (!hw.inout<i39>) -> !hw.inout<i1>
      %6 = llhd.prb %data_o : !hw.inout<i39>
      %7 = comb.extract %6 from 0 : (i39) -> i30
      %8 = comb.and %7, %c-435765979_i30 : i30
      %9 = comb.concat %c0_i9, %8 : i9, i30
      %10 = comb.parity %9 : i39
      llhd.drv %5, %10 after %0 : !hw.inout<i1>
      %11 = llhd.sig.extract %data_o from %c-31_i6 : (!hw.inout<i39>) -> !hw.inout<i1>
      %12 = llhd.prb %data_o : !hw.inout<i39>
      %13 = comb.extract %12 from 4 : (i39) -> i28
      %14 = comb.and %13, %c-34887675_i28 : i28
      %15 = comb.concat %c0_i7, %14, %c0_i4 : i7, i28, i4
      %16 = comb.parity %15 : i39
      llhd.drv %11, %16 after %0 : !hw.inout<i1>
      %17 = llhd.sig.extract %data_o from %c-30_i6 : (!hw.inout<i39>) -> !hw.inout<i1>
      %18 = llhd.prb %data_o : !hw.inout<i39>
      %19 = comb.extract %18 from 1 : (i39) -> i30
      %20 = comb.and %19, %c-526465835_i30 : i30
      %21 = comb.concat %c0_i8, %20, %false : i8, i30, i1
      %22 = comb.parity %21 : i39
      llhd.drv %17, %22 after %0 : !hw.inout<i1>
      %23 = llhd.sig.extract %data_o from %c-29_i6 : (!hw.inout<i39>) -> !hw.inout<i1>
      %24 = llhd.prb %data_o : !hw.inout<i39>
      %25 = comb.extract %24 from 0 : (i39) -> i30
      %26 = comb.and %25, %c-249344303_i30 : i30
      %27 = comb.concat %c0_i9, %26 : i9, i30
      %28 = comb.parity %27 : i39
      llhd.drv %23, %28 after %0 : !hw.inout<i1>
      %29 = llhd.sig.extract %data_o from %c-28_i6 : (!hw.inout<i39>) -> !hw.inout<i1>
      %30 = llhd.prb %data_o : !hw.inout<i39>
      %31 = comb.extract %30 from 0 : (i39) -> i32
      %32 = comb.and %31, %c-1027526085_i32 : i32
      %33 = comb.concat %c0_i7, %32 : i7, i32
      %34 = comb.parity %33 : i39
      llhd.drv %29, %34 after %0 : !hw.inout<i1>
      %35 = llhd.sig.extract %data_o from %c-27_i6 : (!hw.inout<i39>) -> !hw.inout<i1>
      %36 = llhd.prb %data_o : !hw.inout<i39>
      %37 = comb.extract %36 from 2 : (i39) -> i28
      %38 = comb.and %37, %c-76343149_i28 : i28
      %39 = comb.concat %c0_i9, %38, %c0_i2 : i9, i28, i2
      %40 = comb.parity %39 : i39
      llhd.drv %35, %40 after %0 : !hw.inout<i1>
      %41 = llhd.sig.extract %data_o from %c-26_i6 : (!hw.inout<i39>) -> !hw.inout<i1>
      %42 = llhd.prb %data_o : !hw.inout<i39>
      %43 = comb.extract %42 from 1 : (i39) -> i31
      %44 = comb.and %43, %c-869782845_i31 : i31
      %45 = comb.concat %c0_i7, %44, %false : i7, i31, i1
      %46 = comb.parity %45 : i39
      llhd.drv %41, %46 after %0 : !hw.inout<i1>
      %47 = llhd.prb %data_o : !hw.inout<i39>
      %48 = comb.xor %47, %c180388626432_i39 : i39
      llhd.drv %data_o, %48 after %0 : !hw.inout<i39>
      llhd.wait (%1, %2 : i32, i39), ^bb1
    }
    llhd.drv %data_i_0, %data_i after %0 : !hw.inout<i32>
    hw.output %2 : i39
  }
  hw.module private @prim_secded_inv_64_57_dec(in %data_i : i64, out data_o : i57, out syndrome_o : i7, out err_o : i2) {
    %c-567526282035050863_i60 = hw.constant -567526282035050863 : i60
    %c378302368699121664_i60 = hw.constant 378302368699121664 : i60
    %c-558737265440175471_i60 = hw.constant -558737265440175471 : i60
    %c-396316767208603648_i60 = hw.constant -396316767208603648 : i60
    %c-541595567475503983_i60 = hw.constant -541595567475503983 : i60
    %c360287970189639680_i60 = hw.constant 360287970189639680 : i60
    %c-509057263091300591_i60 = hw.constant -509057263091300591 : i60
    %c-432345564227567616_i60 = hw.constant -432345564227567616 : i60
    %c0_i4 = hw.constant 0 : i4
    %c-450955930284621343_i60 = hw.constant -450955930284621343 : i60
    %c288230376151711744_i60 = hw.constant 288230376151711744 : i60
    %c0_i5 = hw.constant 0 : i5
    %c-181234734955790305_i59 = hw.constant -181234734955790305 : i59
    %c-288230376151711744_i59 = hw.constant -288230376151711744 : i59
    %c-70931728490790913_i58 = hw.constant -70931728490790913 : i58
    %true = hw.constant true
    %false = hw.constant false
    %c-8_i6 = hw.constant -8 : i6
    %c-9_i6 = hw.constant -9 : i6
    %c-10_i6 = hw.constant -10 : i6
    %c-11_i6 = hw.constant -11 : i6
    %c-12_i6 = hw.constant -12 : i6
    %c-13_i6 = hw.constant -13 : i6
    %c-14_i6 = hw.constant -14 : i6
    %c-15_i6 = hw.constant -15 : i6
    %c-16_i6 = hw.constant -16 : i6
    %c-17_i6 = hw.constant -17 : i6
    %c-18_i6 = hw.constant -18 : i6
    %c-19_i6 = hw.constant -19 : i6
    %c-20_i6 = hw.constant -20 : i6
    %c-21_i6 = hw.constant -21 : i6
    %c-22_i6 = hw.constant -22 : i6
    %c-23_i6 = hw.constant -23 : i6
    %c-24_i6 = hw.constant -24 : i6
    %c-25_i6 = hw.constant -25 : i6
    %c-26_i6 = hw.constant -26 : i6
    %c-27_i6 = hw.constant -27 : i6
    %c-28_i6 = hw.constant -28 : i6
    %c-29_i6 = hw.constant -29 : i6
    %c-30_i6 = hw.constant -30 : i6
    %c-31_i6 = hw.constant -31 : i6
    %c-32_i6 = hw.constant -32 : i6
    %c31_i6 = hw.constant 31 : i6
    %c30_i6 = hw.constant 30 : i6
    %c29_i6 = hw.constant 29 : i6
    %c28_i6 = hw.constant 28 : i6
    %c27_i6 = hw.constant 27 : i6
    %c26_i6 = hw.constant 26 : i6
    %c25_i6 = hw.constant 25 : i6
    %c24_i6 = hw.constant 24 : i6
    %c23_i6 = hw.constant 23 : i6
    %c22_i6 = hw.constant 22 : i6
    %c21_i6 = hw.constant 21 : i6
    %c20_i6 = hw.constant 20 : i6
    %c19_i6 = hw.constant 19 : i6
    %c18_i6 = hw.constant 18 : i6
    %c17_i6 = hw.constant 17 : i6
    %c16_i6 = hw.constant 16 : i6
    %c15_i6 = hw.constant 15 : i6
    %c14_i6 = hw.constant 14 : i6
    %c13_i6 = hw.constant 13 : i6
    %c12_i6 = hw.constant 12 : i6
    %c11_i6 = hw.constant 11 : i6
    %c10_i6 = hw.constant 10 : i6
    %c9_i6 = hw.constant 9 : i6
    %c8_i6 = hw.constant 8 : i6
    %c7_i6 = hw.constant 7 : i6
    %c6_i6 = hw.constant 6 : i6
    %c5_i6 = hw.constant 5 : i6
    %c4_i6 = hw.constant 4 : i6
    %c3_i6 = hw.constant 3 : i6
    %c2_i6 = hw.constant 2 : i6
    %c1_i6 = hw.constant 1 : i6
    %c0_i6 = hw.constant 0 : i6
    %c-2_i3 = hw.constant -2 : i3
    %c-3_i3 = hw.constant -3 : i3
    %c-4_i3 = hw.constant -4 : i3
    %c3_i3 = hw.constant 3 : i3
    %c2_i3 = hw.constant 2 : i3
    %c1_i3 = hw.constant 1 : i3
    %0 = llhd.constant_time <0ns, 0d, 1e>
    %c0_i3 = hw.constant 0 : i3
    %c0_i2 = hw.constant 0 : i2
    %c0_i7 = hw.constant 0 : i7
    %c0_i57 = hw.constant 0 : i57
    %c-1_i7 = hw.constant -1 : i7
    %c-4_i7 = hw.constant -4 : i7
    %c-6_i7 = hw.constant -6 : i7
    %c-10_i7 = hw.constant -10 : i7
    %c-18_i7 = hw.constant -18 : i7
    %c-34_i7 = hw.constant -34 : i7
    %c62_i7 = hw.constant 62 : i7
    %c-7_i7 = hw.constant -7 : i7
    %c-11_i7 = hw.constant -11 : i7
    %c-19_i7 = hw.constant -19 : i7
    %c-35_i7 = hw.constant -35 : i7
    %c61_i7 = hw.constant 61 : i7
    %c-13_i7 = hw.constant -13 : i7
    %c-21_i7 = hw.constant -21 : i7
    %c-37_i7 = hw.constant -37 : i7
    %c59_i7 = hw.constant 59 : i7
    %c-25_i7 = hw.constant -25 : i7
    %c-41_i7 = hw.constant -41 : i7
    %c55_i7 = hw.constant 55 : i7
    %c-49_i7 = hw.constant -49 : i7
    %c47_i7 = hw.constant 47 : i7
    %c31_i7 = hw.constant 31 : i7
    %c-16_i7 = hw.constant -16 : i7
    %c-24_i7 = hw.constant -24 : i7
    %c-40_i7 = hw.constant -40 : i7
    %c56_i7 = hw.constant 56 : i7
    %c-28_i7 = hw.constant -28 : i7
    %c-44_i7 = hw.constant -44 : i7
    %c52_i7 = hw.constant 52 : i7
    %c-52_i7 = hw.constant -52 : i7
    %c44_i7 = hw.constant 44 : i7
    %c28_i7 = hw.constant 28 : i7
    %c-30_i7 = hw.constant -30 : i7
    %c-46_i7 = hw.constant -46 : i7
    %c50_i7 = hw.constant 50 : i7
    %c-54_i7 = hw.constant -54 : i7
    %c42_i7 = hw.constant 42 : i7
    %c26_i7 = hw.constant 26 : i7
    %c-58_i7 = hw.constant -58 : i7
    %c38_i7 = hw.constant 38 : i7
    %c22_i7 = hw.constant 22 : i7
    %c14_i7 = hw.constant 14 : i7
    %c-31_i7 = hw.constant -31 : i7
    %c-47_i7 = hw.constant -47 : i7
    %c49_i7 = hw.constant 49 : i7
    %c-55_i7 = hw.constant -55 : i7
    %c41_i7 = hw.constant 41 : i7
    %c25_i7 = hw.constant 25 : i7
    %c-59_i7 = hw.constant -59 : i7
    %c37_i7 = hw.constant 37 : i7
    %c21_i7 = hw.constant 21 : i7
    %c13_i7 = hw.constant 13 : i7
    %c-61_i7 = hw.constant -61 : i7
    %c35_i7 = hw.constant 35 : i7
    %c19_i7 = hw.constant 19 : i7
    %c11_i7 = hw.constant 11 : i7
    %c7_i7 = hw.constant 7 : i7
    %c0_i64 = hw.constant 0 : i64
    %data_i_0 = llhd.sig name "data_i" %c0_i64 : i64
    %data_o = llhd.sig %c0_i57 : i57
    %syndrome_o = llhd.sig %c0_i7 : i7
    %err_o = llhd.sig %c0_i2 : i2
    %1 = llhd.prb %syndrome_o : !hw.inout<i7>
    %2 = llhd.prb %data_i_0 : !hw.inout<i64>
    %3 = llhd.prb %data_o : !hw.inout<i57>
    %4 = llhd.prb %err_o : !hw.inout<i2>
    llhd.process {
      cf.br ^bb1
    ^bb1:  // 2 preds: ^bb0, ^bb1
      %5 = llhd.sig.extract %syndrome_o from %c0_i3 : (!hw.inout<i7>) -> !hw.inout<i1>
      %6 = llhd.prb %data_i_0 : !hw.inout<i64>
      %7 = comb.extract %6 from 0 : (i64) -> i58
      %8 = comb.and %7, %c-70931728490790913_i58 : i58
      %9 = comb.concat %c0_i6, %8 : i6, i58
      %10 = comb.parity %9 : i64
      llhd.drv %5, %10 after %0 : !hw.inout<i1>
      %11 = llhd.sig.extract %syndrome_o from %c1_i3 : (!hw.inout<i7>) -> !hw.inout<i1>
      %12 = llhd.prb %data_i_0 : !hw.inout<i64>
      %13 = comb.extract %12 from 0 : (i64) -> i59
      %14 = comb.xor %13, %c-288230376151711744_i59 : i59
      %15 = comb.and %14, %c-181234734955790305_i59 : i59
      %16 = comb.concat %c0_i5, %15 : i5, i59
      %17 = comb.parity %16 : i64
      llhd.drv %11, %17 after %0 : !hw.inout<i1>
      %18 = llhd.sig.extract %syndrome_o from %c2_i3 : (!hw.inout<i7>) -> !hw.inout<i1>
      %19 = llhd.prb %data_i_0 : !hw.inout<i64>
      %20 = comb.extract %19 from 0 : (i64) -> i60
      %21 = comb.xor %20, %c288230376151711744_i60 : i60
      %22 = comb.and %21, %c-450955930284621343_i60 : i60
      %23 = comb.concat %c0_i4, %22 : i4, i60
      %24 = comb.parity %23 : i64
      llhd.drv %18, %24 after %0 : !hw.inout<i1>
      %25 = llhd.sig.extract %syndrome_o from %c3_i3 : (!hw.inout<i7>) -> !hw.inout<i1>
      %26 = llhd.prb %data_i_0 : !hw.inout<i64>
      %27 = comb.extract %26 from 1 : (i64) -> i60
      %28 = comb.xor %27, %c-432345564227567616_i60 : i60
      %29 = comb.and %28, %c-509057263091300591_i60 : i60
      %30 = comb.concat %c0_i3, %29, %false : i3, i60, i1
      %31 = comb.parity %30 : i64
      llhd.drv %25, %31 after %0 : !hw.inout<i1>
      %32 = llhd.sig.extract %syndrome_o from %c-4_i3 : (!hw.inout<i7>) -> !hw.inout<i1>
      %33 = llhd.prb %data_i_0 : !hw.inout<i64>
      %34 = comb.extract %33 from 2 : (i64) -> i60
      %35 = comb.xor %34, %c360287970189639680_i60 : i60
      %36 = comb.and %35, %c-541595567475503983_i60 : i60
      %37 = comb.concat %c0_i2, %36, %c0_i2 : i2, i60, i2
      %38 = comb.parity %37 : i64
      llhd.drv %32, %38 after %0 : !hw.inout<i1>
      %39 = llhd.sig.extract %syndrome_o from %c-3_i3 : (!hw.inout<i7>) -> !hw.inout<i1>
      %40 = llhd.prb %data_i_0 : !hw.inout<i64>
      %41 = comb.extract %40 from 3 : (i64) -> i60
      %42 = comb.xor %41, %c-396316767208603648_i60 : i60
      %43 = comb.and %42, %c-558737265440175471_i60 : i60
      %44 = comb.concat %false, %43, %c0_i3 : i1, i60, i3
      %45 = comb.parity %44 : i64
      llhd.drv %39, %45 after %0 : !hw.inout<i1>
      %46 = llhd.sig.extract %syndrome_o from %c-2_i3 : (!hw.inout<i7>) -> !hw.inout<i1>
      %47 = llhd.prb %data_i_0 : !hw.inout<i64>
      %48 = comb.extract %47 from 4 : (i64) -> i60
      %49 = comb.xor %48, %c378302368699121664_i60 : i60
      %50 = comb.and %49, %c-567526282035050863_i60 : i60
      %51 = comb.concat %50, %c0_i4 : i60, i4
      %52 = comb.parity %51 : i64
      llhd.drv %46, %52 after %0 : !hw.inout<i1>
      %53 = llhd.sig.extract %data_o from %c0_i6 : (!hw.inout<i57>) -> !hw.inout<i1>
      %54 = llhd.prb %syndrome_o : !hw.inout<i7>
      %55 = comb.icmp eq %54, %c7_i7 : i7
      %56 = llhd.prb %data_i_0 : !hw.inout<i64>
      %57 = comb.extract %56 from 0 : (i64) -> i1
      %58 = comb.xor %55, %57 : i1
      llhd.drv %53, %58 after %0 : !hw.inout<i1>
      %59 = llhd.sig.extract %data_o from %c1_i6 : (!hw.inout<i57>) -> !hw.inout<i1>
      %60 = llhd.prb %syndrome_o : !hw.inout<i7>
      %61 = comb.icmp eq %60, %c11_i7 : i7
      %62 = llhd.prb %data_i_0 : !hw.inout<i64>
      %63 = comb.extract %62 from 1 : (i64) -> i1
      %64 = comb.xor %61, %63 : i1
      llhd.drv %59, %64 after %0 : !hw.inout<i1>
      %65 = llhd.sig.extract %data_o from %c2_i6 : (!hw.inout<i57>) -> !hw.inout<i1>
      %66 = llhd.prb %syndrome_o : !hw.inout<i7>
      %67 = comb.icmp eq %66, %c19_i7 : i7
      %68 = llhd.prb %data_i_0 : !hw.inout<i64>
      %69 = comb.extract %68 from 2 : (i64) -> i1
      %70 = comb.xor %67, %69 : i1
      llhd.drv %65, %70 after %0 : !hw.inout<i1>
      %71 = llhd.sig.extract %data_o from %c3_i6 : (!hw.inout<i57>) -> !hw.inout<i1>
      %72 = llhd.prb %syndrome_o : !hw.inout<i7>
      %73 = comb.icmp eq %72, %c35_i7 : i7
      %74 = llhd.prb %data_i_0 : !hw.inout<i64>
      %75 = comb.extract %74 from 3 : (i64) -> i1
      %76 = comb.xor %73, %75 : i1
      llhd.drv %71, %76 after %0 : !hw.inout<i1>
      %77 = llhd.sig.extract %data_o from %c4_i6 : (!hw.inout<i57>) -> !hw.inout<i1>
      %78 = llhd.prb %syndrome_o : !hw.inout<i7>
      %79 = comb.icmp eq %78, %c-61_i7 : i7
      %80 = llhd.prb %data_i_0 : !hw.inout<i64>
      %81 = comb.extract %80 from 4 : (i64) -> i1
      %82 = comb.xor %79, %81 : i1
      llhd.drv %77, %82 after %0 : !hw.inout<i1>
      %83 = llhd.sig.extract %data_o from %c5_i6 : (!hw.inout<i57>) -> !hw.inout<i1>
      %84 = llhd.prb %syndrome_o : !hw.inout<i7>
      %85 = comb.icmp eq %84, %c13_i7 : i7
      %86 = llhd.prb %data_i_0 : !hw.inout<i64>
      %87 = comb.extract %86 from 5 : (i64) -> i1
      %88 = comb.xor %85, %87 : i1
      llhd.drv %83, %88 after %0 : !hw.inout<i1>
      %89 = llhd.sig.extract %data_o from %c6_i6 : (!hw.inout<i57>) -> !hw.inout<i1>
      %90 = llhd.prb %syndrome_o : !hw.inout<i7>
      %91 = comb.icmp eq %90, %c21_i7 : i7
      %92 = llhd.prb %data_i_0 : !hw.inout<i64>
      %93 = comb.extract %92 from 6 : (i64) -> i1
      %94 = comb.xor %91, %93 : i1
      llhd.drv %89, %94 after %0 : !hw.inout<i1>
      %95 = llhd.sig.extract %data_o from %c7_i6 : (!hw.inout<i57>) -> !hw.inout<i1>
      %96 = llhd.prb %syndrome_o : !hw.inout<i7>
      %97 = comb.icmp eq %96, %c37_i7 : i7
      %98 = llhd.prb %data_i_0 : !hw.inout<i64>
      %99 = comb.extract %98 from 7 : (i64) -> i1
      %100 = comb.xor %97, %99 : i1
      llhd.drv %95, %100 after %0 : !hw.inout<i1>
      %101 = llhd.sig.extract %data_o from %c8_i6 : (!hw.inout<i57>) -> !hw.inout<i1>
      %102 = llhd.prb %syndrome_o : !hw.inout<i7>
      %103 = comb.icmp eq %102, %c-59_i7 : i7
      %104 = llhd.prb %data_i_0 : !hw.inout<i64>
      %105 = comb.extract %104 from 8 : (i64) -> i1
      %106 = comb.xor %103, %105 : i1
      llhd.drv %101, %106 after %0 : !hw.inout<i1>
      %107 = llhd.sig.extract %data_o from %c9_i6 : (!hw.inout<i57>) -> !hw.inout<i1>
      %108 = llhd.prb %syndrome_o : !hw.inout<i7>
      %109 = comb.icmp eq %108, %c25_i7 : i7
      %110 = llhd.prb %data_i_0 : !hw.inout<i64>
      %111 = comb.extract %110 from 9 : (i64) -> i1
      %112 = comb.xor %109, %111 : i1
      llhd.drv %107, %112 after %0 : !hw.inout<i1>
      %113 = llhd.sig.extract %data_o from %c10_i6 : (!hw.inout<i57>) -> !hw.inout<i1>
      %114 = llhd.prb %syndrome_o : !hw.inout<i7>
      %115 = comb.icmp eq %114, %c41_i7 : i7
      %116 = llhd.prb %data_i_0 : !hw.inout<i64>
      %117 = comb.extract %116 from 10 : (i64) -> i1
      %118 = comb.xor %115, %117 : i1
      llhd.drv %113, %118 after %0 : !hw.inout<i1>
      %119 = llhd.sig.extract %data_o from %c11_i6 : (!hw.inout<i57>) -> !hw.inout<i1>
      %120 = llhd.prb %syndrome_o : !hw.inout<i7>
      %121 = comb.icmp eq %120, %c-55_i7 : i7
      %122 = llhd.prb %data_i_0 : !hw.inout<i64>
      %123 = comb.extract %122 from 11 : (i64) -> i1
      %124 = comb.xor %121, %123 : i1
      llhd.drv %119, %124 after %0 : !hw.inout<i1>
      %125 = llhd.sig.extract %data_o from %c12_i6 : (!hw.inout<i57>) -> !hw.inout<i1>
      %126 = llhd.prb %syndrome_o : !hw.inout<i7>
      %127 = comb.icmp eq %126, %c49_i7 : i7
      %128 = llhd.prb %data_i_0 : !hw.inout<i64>
      %129 = comb.extract %128 from 12 : (i64) -> i1
      %130 = comb.xor %127, %129 : i1
      llhd.drv %125, %130 after %0 : !hw.inout<i1>
      %131 = llhd.sig.extract %data_o from %c13_i6 : (!hw.inout<i57>) -> !hw.inout<i1>
      %132 = llhd.prb %syndrome_o : !hw.inout<i7>
      %133 = comb.icmp eq %132, %c-47_i7 : i7
      %134 = llhd.prb %data_i_0 : !hw.inout<i64>
      %135 = comb.extract %134 from 13 : (i64) -> i1
      %136 = comb.xor %133, %135 : i1
      llhd.drv %131, %136 after %0 : !hw.inout<i1>
      %137 = llhd.sig.extract %data_o from %c14_i6 : (!hw.inout<i57>) -> !hw.inout<i1>
      %138 = llhd.prb %syndrome_o : !hw.inout<i7>
      %139 = comb.icmp eq %138, %c-31_i7 : i7
      %140 = llhd.prb %data_i_0 : !hw.inout<i64>
      %141 = comb.extract %140 from 14 : (i64) -> i1
      %142 = comb.xor %139, %141 : i1
      llhd.drv %137, %142 after %0 : !hw.inout<i1>
      %143 = llhd.sig.extract %data_o from %c15_i6 : (!hw.inout<i57>) -> !hw.inout<i1>
      %144 = llhd.prb %syndrome_o : !hw.inout<i7>
      %145 = comb.icmp eq %144, %c14_i7 : i7
      %146 = llhd.prb %data_i_0 : !hw.inout<i64>
      %147 = comb.extract %146 from 15 : (i64) -> i1
      %148 = comb.xor %145, %147 : i1
      llhd.drv %143, %148 after %0 : !hw.inout<i1>
      %149 = llhd.sig.extract %data_o from %c16_i6 : (!hw.inout<i57>) -> !hw.inout<i1>
      %150 = llhd.prb %syndrome_o : !hw.inout<i7>
      %151 = comb.icmp eq %150, %c22_i7 : i7
      %152 = llhd.prb %data_i_0 : !hw.inout<i64>
      %153 = comb.extract %152 from 16 : (i64) -> i1
      %154 = comb.xor %151, %153 : i1
      llhd.drv %149, %154 after %0 : !hw.inout<i1>
      %155 = llhd.sig.extract %data_o from %c17_i6 : (!hw.inout<i57>) -> !hw.inout<i1>
      %156 = llhd.prb %syndrome_o : !hw.inout<i7>
      %157 = comb.icmp eq %156, %c38_i7 : i7
      %158 = llhd.prb %data_i_0 : !hw.inout<i64>
      %159 = comb.extract %158 from 17 : (i64) -> i1
      %160 = comb.xor %157, %159 : i1
      llhd.drv %155, %160 after %0 : !hw.inout<i1>
      %161 = llhd.sig.extract %data_o from %c18_i6 : (!hw.inout<i57>) -> !hw.inout<i1>
      %162 = llhd.prb %syndrome_o : !hw.inout<i7>
      %163 = comb.icmp eq %162, %c-58_i7 : i7
      %164 = llhd.prb %data_i_0 : !hw.inout<i64>
      %165 = comb.extract %164 from 18 : (i64) -> i1
      %166 = comb.xor %163, %165 : i1
      llhd.drv %161, %166 after %0 : !hw.inout<i1>
      %167 = llhd.sig.extract %data_o from %c19_i6 : (!hw.inout<i57>) -> !hw.inout<i1>
      %168 = llhd.prb %syndrome_o : !hw.inout<i7>
      %169 = comb.icmp eq %168, %c26_i7 : i7
      %170 = llhd.prb %data_i_0 : !hw.inout<i64>
      %171 = comb.extract %170 from 19 : (i64) -> i1
      %172 = comb.xor %169, %171 : i1
      llhd.drv %167, %172 after %0 : !hw.inout<i1>
      %173 = llhd.sig.extract %data_o from %c20_i6 : (!hw.inout<i57>) -> !hw.inout<i1>
      %174 = llhd.prb %syndrome_o : !hw.inout<i7>
      %175 = comb.icmp eq %174, %c42_i7 : i7
      %176 = llhd.prb %data_i_0 : !hw.inout<i64>
      %177 = comb.extract %176 from 20 : (i64) -> i1
      %178 = comb.xor %175, %177 : i1
      llhd.drv %173, %178 after %0 : !hw.inout<i1>
      %179 = llhd.sig.extract %data_o from %c21_i6 : (!hw.inout<i57>) -> !hw.inout<i1>
      %180 = llhd.prb %syndrome_o : !hw.inout<i7>
      %181 = comb.icmp eq %180, %c-54_i7 : i7
      %182 = llhd.prb %data_i_0 : !hw.inout<i64>
      %183 = comb.extract %182 from 21 : (i64) -> i1
      %184 = comb.xor %181, %183 : i1
      llhd.drv %179, %184 after %0 : !hw.inout<i1>
      %185 = llhd.sig.extract %data_o from %c22_i6 : (!hw.inout<i57>) -> !hw.inout<i1>
      %186 = llhd.prb %syndrome_o : !hw.inout<i7>
      %187 = comb.icmp eq %186, %c50_i7 : i7
      %188 = llhd.prb %data_i_0 : !hw.inout<i64>
      %189 = comb.extract %188 from 22 : (i64) -> i1
      %190 = comb.xor %187, %189 : i1
      llhd.drv %185, %190 after %0 : !hw.inout<i1>
      %191 = llhd.sig.extract %data_o from %c23_i6 : (!hw.inout<i57>) -> !hw.inout<i1>
      %192 = llhd.prb %syndrome_o : !hw.inout<i7>
      %193 = comb.icmp eq %192, %c-46_i7 : i7
      %194 = llhd.prb %data_i_0 : !hw.inout<i64>
      %195 = comb.extract %194 from 23 : (i64) -> i1
      %196 = comb.xor %193, %195 : i1
      llhd.drv %191, %196 after %0 : !hw.inout<i1>
      %197 = llhd.sig.extract %data_o from %c24_i6 : (!hw.inout<i57>) -> !hw.inout<i1>
      %198 = llhd.prb %syndrome_o : !hw.inout<i7>
      %199 = comb.icmp eq %198, %c-30_i7 : i7
      %200 = llhd.prb %data_i_0 : !hw.inout<i64>
      %201 = comb.extract %200 from 24 : (i64) -> i1
      %202 = comb.xor %199, %201 : i1
      llhd.drv %197, %202 after %0 : !hw.inout<i1>
      %203 = llhd.sig.extract %data_o from %c25_i6 : (!hw.inout<i57>) -> !hw.inout<i1>
      %204 = llhd.prb %syndrome_o : !hw.inout<i7>
      %205 = comb.icmp eq %204, %c28_i7 : i7
      %206 = llhd.prb %data_i_0 : !hw.inout<i64>
      %207 = comb.extract %206 from 25 : (i64) -> i1
      %208 = comb.xor %205, %207 : i1
      llhd.drv %203, %208 after %0 : !hw.inout<i1>
      %209 = llhd.sig.extract %data_o from %c26_i6 : (!hw.inout<i57>) -> !hw.inout<i1>
      %210 = llhd.prb %syndrome_o : !hw.inout<i7>
      %211 = comb.icmp eq %210, %c44_i7 : i7
      %212 = llhd.prb %data_i_0 : !hw.inout<i64>
      %213 = comb.extract %212 from 26 : (i64) -> i1
      %214 = comb.xor %211, %213 : i1
      llhd.drv %209, %214 after %0 : !hw.inout<i1>
      %215 = llhd.sig.extract %data_o from %c27_i6 : (!hw.inout<i57>) -> !hw.inout<i1>
      %216 = llhd.prb %syndrome_o : !hw.inout<i7>
      %217 = comb.icmp eq %216, %c-52_i7 : i7
      %218 = llhd.prb %data_i_0 : !hw.inout<i64>
      %219 = comb.extract %218 from 27 : (i64) -> i1
      %220 = comb.xor %217, %219 : i1
      llhd.drv %215, %220 after %0 : !hw.inout<i1>
      %221 = llhd.sig.extract %data_o from %c28_i6 : (!hw.inout<i57>) -> !hw.inout<i1>
      %222 = llhd.prb %syndrome_o : !hw.inout<i7>
      %223 = comb.icmp eq %222, %c52_i7 : i7
      %224 = llhd.prb %data_i_0 : !hw.inout<i64>
      %225 = comb.extract %224 from 28 : (i64) -> i1
      %226 = comb.xor %223, %225 : i1
      llhd.drv %221, %226 after %0 : !hw.inout<i1>
      %227 = llhd.sig.extract %data_o from %c29_i6 : (!hw.inout<i57>) -> !hw.inout<i1>
      %228 = llhd.prb %syndrome_o : !hw.inout<i7>
      %229 = comb.icmp eq %228, %c-44_i7 : i7
      %230 = llhd.prb %data_i_0 : !hw.inout<i64>
      %231 = comb.extract %230 from 29 : (i64) -> i1
      %232 = comb.xor %229, %231 : i1
      llhd.drv %227, %232 after %0 : !hw.inout<i1>
      %233 = llhd.sig.extract %data_o from %c30_i6 : (!hw.inout<i57>) -> !hw.inout<i1>
      %234 = llhd.prb %syndrome_o : !hw.inout<i7>
      %235 = comb.icmp eq %234, %c-28_i7 : i7
      %236 = llhd.prb %data_i_0 : !hw.inout<i64>
      %237 = comb.extract %236 from 30 : (i64) -> i1
      %238 = comb.xor %235, %237 : i1
      llhd.drv %233, %238 after %0 : !hw.inout<i1>
      %239 = llhd.sig.extract %data_o from %c31_i6 : (!hw.inout<i57>) -> !hw.inout<i1>
      %240 = llhd.prb %syndrome_o : !hw.inout<i7>
      %241 = comb.icmp eq %240, %c56_i7 : i7
      %242 = llhd.prb %data_i_0 : !hw.inout<i64>
      %243 = comb.extract %242 from 31 : (i64) -> i1
      %244 = comb.xor %241, %243 : i1
      llhd.drv %239, %244 after %0 : !hw.inout<i1>
      %245 = llhd.sig.extract %data_o from %c-32_i6 : (!hw.inout<i57>) -> !hw.inout<i1>
      %246 = llhd.prb %syndrome_o : !hw.inout<i7>
      %247 = comb.icmp eq %246, %c-40_i7 : i7
      %248 = llhd.prb %data_i_0 : !hw.inout<i64>
      %249 = comb.extract %248 from 32 : (i64) -> i1
      %250 = comb.xor %247, %249 : i1
      llhd.drv %245, %250 after %0 : !hw.inout<i1>
      %251 = llhd.sig.extract %data_o from %c-31_i6 : (!hw.inout<i57>) -> !hw.inout<i1>
      %252 = llhd.prb %syndrome_o : !hw.inout<i7>
      %253 = comb.icmp eq %252, %c-24_i7 : i7
      %254 = llhd.prb %data_i_0 : !hw.inout<i64>
      %255 = comb.extract %254 from 33 : (i64) -> i1
      %256 = comb.xor %253, %255 : i1
      llhd.drv %251, %256 after %0 : !hw.inout<i1>
      %257 = llhd.sig.extract %data_o from %c-30_i6 : (!hw.inout<i57>) -> !hw.inout<i1>
      %258 = llhd.prb %syndrome_o : !hw.inout<i7>
      %259 = comb.icmp eq %258, %c-16_i7 : i7
      %260 = llhd.prb %data_i_0 : !hw.inout<i64>
      %261 = comb.extract %260 from 34 : (i64) -> i1
      %262 = comb.xor %259, %261 : i1
      llhd.drv %257, %262 after %0 : !hw.inout<i1>
      %263 = llhd.sig.extract %data_o from %c-29_i6 : (!hw.inout<i57>) -> !hw.inout<i1>
      %264 = llhd.prb %syndrome_o : !hw.inout<i7>
      %265 = comb.icmp eq %264, %c31_i7 : i7
      %266 = llhd.prb %data_i_0 : !hw.inout<i64>
      %267 = comb.extract %266 from 35 : (i64) -> i1
      %268 = comb.xor %265, %267 : i1
      llhd.drv %263, %268 after %0 : !hw.inout<i1>
      %269 = llhd.sig.extract %data_o from %c-28_i6 : (!hw.inout<i57>) -> !hw.inout<i1>
      %270 = llhd.prb %syndrome_o : !hw.inout<i7>
      %271 = comb.icmp eq %270, %c47_i7 : i7
      %272 = llhd.prb %data_i_0 : !hw.inout<i64>
      %273 = comb.extract %272 from 36 : (i64) -> i1
      %274 = comb.xor %271, %273 : i1
      llhd.drv %269, %274 after %0 : !hw.inout<i1>
      %275 = llhd.sig.extract %data_o from %c-27_i6 : (!hw.inout<i57>) -> !hw.inout<i1>
      %276 = llhd.prb %syndrome_o : !hw.inout<i7>
      %277 = comb.icmp eq %276, %c-49_i7 : i7
      %278 = llhd.prb %data_i_0 : !hw.inout<i64>
      %279 = comb.extract %278 from 37 : (i64) -> i1
      %280 = comb.xor %277, %279 : i1
      llhd.drv %275, %280 after %0 : !hw.inout<i1>
      %281 = llhd.sig.extract %data_o from %c-26_i6 : (!hw.inout<i57>) -> !hw.inout<i1>
      %282 = llhd.prb %syndrome_o : !hw.inout<i7>
      %283 = comb.icmp eq %282, %c55_i7 : i7
      %284 = llhd.prb %data_i_0 : !hw.inout<i64>
      %285 = comb.extract %284 from 38 : (i64) -> i1
      %286 = comb.xor %283, %285 : i1
      llhd.drv %281, %286 after %0 : !hw.inout<i1>
      %287 = llhd.sig.extract %data_o from %c-25_i6 : (!hw.inout<i57>) -> !hw.inout<i1>
      %288 = llhd.prb %syndrome_o : !hw.inout<i7>
      %289 = comb.icmp eq %288, %c-41_i7 : i7
      %290 = llhd.prb %data_i_0 : !hw.inout<i64>
      %291 = comb.extract %290 from 39 : (i64) -> i1
      %292 = comb.xor %289, %291 : i1
      llhd.drv %287, %292 after %0 : !hw.inout<i1>
      %293 = llhd.sig.extract %data_o from %c-24_i6 : (!hw.inout<i57>) -> !hw.inout<i1>
      %294 = llhd.prb %syndrome_o : !hw.inout<i7>
      %295 = comb.icmp eq %294, %c-25_i7 : i7
      %296 = llhd.prb %data_i_0 : !hw.inout<i64>
      %297 = comb.extract %296 from 40 : (i64) -> i1
      %298 = comb.xor %295, %297 : i1
      llhd.drv %293, %298 after %0 : !hw.inout<i1>
      %299 = llhd.sig.extract %data_o from %c-23_i6 : (!hw.inout<i57>) -> !hw.inout<i1>
      %300 = llhd.prb %syndrome_o : !hw.inout<i7>
      %301 = comb.icmp eq %300, %c59_i7 : i7
      %302 = llhd.prb %data_i_0 : !hw.inout<i64>
      %303 = comb.extract %302 from 41 : (i64) -> i1
      %304 = comb.xor %301, %303 : i1
      llhd.drv %299, %304 after %0 : !hw.inout<i1>
      %305 = llhd.sig.extract %data_o from %c-22_i6 : (!hw.inout<i57>) -> !hw.inout<i1>
      %306 = llhd.prb %syndrome_o : !hw.inout<i7>
      %307 = comb.icmp eq %306, %c-37_i7 : i7
      %308 = llhd.prb %data_i_0 : !hw.inout<i64>
      %309 = comb.extract %308 from 42 : (i64) -> i1
      %310 = comb.xor %307, %309 : i1
      llhd.drv %305, %310 after %0 : !hw.inout<i1>
      %311 = llhd.sig.extract %data_o from %c-21_i6 : (!hw.inout<i57>) -> !hw.inout<i1>
      %312 = llhd.prb %syndrome_o : !hw.inout<i7>
      %313 = comb.icmp eq %312, %c-21_i7 : i7
      %314 = llhd.prb %data_i_0 : !hw.inout<i64>
      %315 = comb.extract %314 from 43 : (i64) -> i1
      %316 = comb.xor %313, %315 : i1
      llhd.drv %311, %316 after %0 : !hw.inout<i1>
      %317 = llhd.sig.extract %data_o from %c-20_i6 : (!hw.inout<i57>) -> !hw.inout<i1>
      %318 = llhd.prb %syndrome_o : !hw.inout<i7>
      %319 = comb.icmp eq %318, %c-13_i7 : i7
      %320 = llhd.prb %data_i_0 : !hw.inout<i64>
      %321 = comb.extract %320 from 44 : (i64) -> i1
      %322 = comb.xor %319, %321 : i1
      llhd.drv %317, %322 after %0 : !hw.inout<i1>
      %323 = llhd.sig.extract %data_o from %c-19_i6 : (!hw.inout<i57>) -> !hw.inout<i1>
      %324 = llhd.prb %syndrome_o : !hw.inout<i7>
      %325 = comb.icmp eq %324, %c61_i7 : i7
      %326 = llhd.prb %data_i_0 : !hw.inout<i64>
      %327 = comb.extract %326 from 45 : (i64) -> i1
      %328 = comb.xor %325, %327 : i1
      llhd.drv %323, %328 after %0 : !hw.inout<i1>
      %329 = llhd.sig.extract %data_o from %c-18_i6 : (!hw.inout<i57>) -> !hw.inout<i1>
      %330 = llhd.prb %syndrome_o : !hw.inout<i7>
      %331 = comb.icmp eq %330, %c-35_i7 : i7
      %332 = llhd.prb %data_i_0 : !hw.inout<i64>
      %333 = comb.extract %332 from 46 : (i64) -> i1
      %334 = comb.xor %331, %333 : i1
      llhd.drv %329, %334 after %0 : !hw.inout<i1>
      %335 = llhd.sig.extract %data_o from %c-17_i6 : (!hw.inout<i57>) -> !hw.inout<i1>
      %336 = llhd.prb %syndrome_o : !hw.inout<i7>
      %337 = comb.icmp eq %336, %c-19_i7 : i7
      %338 = llhd.prb %data_i_0 : !hw.inout<i64>
      %339 = comb.extract %338 from 47 : (i64) -> i1
      %340 = comb.xor %337, %339 : i1
      llhd.drv %335, %340 after %0 : !hw.inout<i1>
      %341 = llhd.sig.extract %data_o from %c-16_i6 : (!hw.inout<i57>) -> !hw.inout<i1>
      %342 = llhd.prb %syndrome_o : !hw.inout<i7>
      %343 = comb.icmp eq %342, %c-11_i7 : i7
      %344 = llhd.prb %data_i_0 : !hw.inout<i64>
      %345 = comb.extract %344 from 48 : (i64) -> i1
      %346 = comb.xor %343, %345 : i1
      llhd.drv %341, %346 after %0 : !hw.inout<i1>
      %347 = llhd.sig.extract %data_o from %c-15_i6 : (!hw.inout<i57>) -> !hw.inout<i1>
      %348 = llhd.prb %syndrome_o : !hw.inout<i7>
      %349 = comb.icmp eq %348, %c-7_i7 : i7
      %350 = llhd.prb %data_i_0 : !hw.inout<i64>
      %351 = comb.extract %350 from 49 : (i64) -> i1
      %352 = comb.xor %349, %351 : i1
      llhd.drv %347, %352 after %0 : !hw.inout<i1>
      %353 = llhd.sig.extract %data_o from %c-14_i6 : (!hw.inout<i57>) -> !hw.inout<i1>
      %354 = llhd.prb %syndrome_o : !hw.inout<i7>
      %355 = comb.icmp eq %354, %c62_i7 : i7
      %356 = llhd.prb %data_i_0 : !hw.inout<i64>
      %357 = comb.extract %356 from 50 : (i64) -> i1
      %358 = comb.xor %355, %357 : i1
      llhd.drv %353, %358 after %0 : !hw.inout<i1>
      %359 = llhd.sig.extract %data_o from %c-13_i6 : (!hw.inout<i57>) -> !hw.inout<i1>
      %360 = llhd.prb %syndrome_o : !hw.inout<i7>
      %361 = comb.icmp eq %360, %c-34_i7 : i7
      %362 = llhd.prb %data_i_0 : !hw.inout<i64>
      %363 = comb.extract %362 from 51 : (i64) -> i1
      %364 = comb.xor %361, %363 : i1
      llhd.drv %359, %364 after %0 : !hw.inout<i1>
      %365 = llhd.sig.extract %data_o from %c-12_i6 : (!hw.inout<i57>) -> !hw.inout<i1>
      %366 = llhd.prb %syndrome_o : !hw.inout<i7>
      %367 = comb.icmp eq %366, %c-18_i7 : i7
      %368 = llhd.prb %data_i_0 : !hw.inout<i64>
      %369 = comb.extract %368 from 52 : (i64) -> i1
      %370 = comb.xor %367, %369 : i1
      llhd.drv %365, %370 after %0 : !hw.inout<i1>
      %371 = llhd.sig.extract %data_o from %c-11_i6 : (!hw.inout<i57>) -> !hw.inout<i1>
      %372 = llhd.prb %syndrome_o : !hw.inout<i7>
      %373 = comb.icmp eq %372, %c-10_i7 : i7
      %374 = llhd.prb %data_i_0 : !hw.inout<i64>
      %375 = comb.extract %374 from 53 : (i64) -> i1
      %376 = comb.xor %373, %375 : i1
      llhd.drv %371, %376 after %0 : !hw.inout<i1>
      %377 = llhd.sig.extract %data_o from %c-10_i6 : (!hw.inout<i57>) -> !hw.inout<i1>
      %378 = llhd.prb %syndrome_o : !hw.inout<i7>
      %379 = comb.icmp eq %378, %c-6_i7 : i7
      %380 = llhd.prb %data_i_0 : !hw.inout<i64>
      %381 = comb.extract %380 from 54 : (i64) -> i1
      %382 = comb.xor %379, %381 : i1
      llhd.drv %377, %382 after %0 : !hw.inout<i1>
      %383 = llhd.sig.extract %data_o from %c-9_i6 : (!hw.inout<i57>) -> !hw.inout<i1>
      %384 = llhd.prb %syndrome_o : !hw.inout<i7>
      %385 = comb.icmp eq %384, %c-4_i7 : i7
      %386 = llhd.prb %data_i_0 : !hw.inout<i64>
      %387 = comb.extract %386 from 55 : (i64) -> i1
      %388 = comb.xor %385, %387 : i1
      llhd.drv %383, %388 after %0 : !hw.inout<i1>
      %389 = llhd.sig.extract %data_o from %c-8_i6 : (!hw.inout<i57>) -> !hw.inout<i1>
      %390 = llhd.prb %syndrome_o : !hw.inout<i7>
      %391 = comb.icmp eq %390, %c-1_i7 : i7
      %392 = llhd.prb %data_i_0 : !hw.inout<i64>
      %393 = comb.extract %392 from 56 : (i64) -> i1
      %394 = comb.xor %391, %393 : i1
      llhd.drv %389, %394 after %0 : !hw.inout<i1>
      %395 = llhd.sig.extract %err_o from %false : (!hw.inout<i2>) -> !hw.inout<i1>
      %396 = llhd.prb %syndrome_o : !hw.inout<i7>
      %397 = comb.parity %396 : i7
      llhd.drv %395, %397 after %0 : !hw.inout<i1>
      %398 = llhd.sig.extract %err_o from %true : (!hw.inout<i2>) -> !hw.inout<i1>
      %399 = llhd.prb %err_o : !hw.inout<i2>
      %400 = comb.extract %399 from 0 : (i2) -> i1
      %401 = comb.xor %400, %true : i1
      %402 = llhd.prb %syndrome_o : !hw.inout<i7>
      %403 = comb.icmp ne %402, %c0_i7 : i7
      %404 = comb.and %401, %403 : i1
      llhd.drv %398, %404 after %0 : !hw.inout<i1>
      llhd.wait (%1, %2, %3, %4 : i7, i64, i57, i2), ^bb1
    }
    llhd.drv %data_i_0, %data_i after %0 : !hw.inout<i64>
    hw.output %3, %1, %4 : i57, i7, i2
  }
  hw.module private @prim_secded_inv_64_57_enc(in %data_i : i57, out data_o : i64) {
    %c0_i4 = hw.constant 0 : i4
    %c-72728986368367_i53 = hw.constant -72728986368367 : i53
    %c0_i3 = hw.constant 0 : i3
    %c-290911646233967_i54 = hw.constant -290911646233967 : i54
    %c0_i2 = hw.constant 0 : i2
    %c-1163612191044463_i55 = hw.constant -1163612191044463 : i55
    %false = hw.constant false
    %c-4654104825805039_i56 = hw.constant -4654104825805039 : i56
    %c-18610366057053727_i57 = hw.constant -18610366057053727 : i57
    %c-37119546879934433_i57 = hw.constant -37119546879934433 : i57
    %c-70931728490790913_i57 = hw.constant -70931728490790913 : i57
    %c-1_i6 = hw.constant -1 : i6
    %c-2_i6 = hw.constant -2 : i6
    %c-3_i6 = hw.constant -3 : i6
    %c-4_i6 = hw.constant -4 : i6
    %c-5_i6 = hw.constant -5 : i6
    %c-6_i6 = hw.constant -6 : i6
    %c-7_i6 = hw.constant -7 : i6
    %0 = llhd.constant_time <0ns, 0d, 1e>
    %c0_i7 = hw.constant 0 : i7
    %c0_i64 = hw.constant 0 : i64
    %c6052837899185946624_i64 = hw.constant 6052837899185946624 : i64
    %c0_i57 = hw.constant 0 : i57
    %data_i_0 = llhd.sig name "data_i" %c0_i57 : i57
    %data_o = llhd.sig %c0_i64 : i64
    %1 = llhd.prb %data_i_0 : !hw.inout<i57>
    %2 = llhd.prb %data_o : !hw.inout<i64>
    llhd.process {
      cf.br ^bb1
    ^bb1:  // 2 preds: ^bb0, ^bb1
      %3 = llhd.prb %data_i_0 : !hw.inout<i57>
      %4 = comb.concat %c0_i7, %3 : i7, i57
      llhd.drv %data_o, %4 after %0 : !hw.inout<i64>
      %5 = llhd.sig.extract %data_o from %c-7_i6 : (!hw.inout<i64>) -> !hw.inout<i1>
      %6 = llhd.prb %data_o : !hw.inout<i64>
      %7 = comb.extract %6 from 0 : (i64) -> i57
      %8 = comb.and %7, %c-70931728490790913_i57 : i57
      %9 = comb.concat %c0_i7, %8 : i7, i57
      %10 = comb.parity %9 : i64
      llhd.drv %5, %10 after %0 : !hw.inout<i1>
      %11 = llhd.sig.extract %data_o from %c-6_i6 : (!hw.inout<i64>) -> !hw.inout<i1>
      %12 = llhd.prb %data_o : !hw.inout<i64>
      %13 = comb.extract %12 from 0 : (i64) -> i57
      %14 = comb.and %13, %c-37119546879934433_i57 : i57
      %15 = comb.concat %c0_i7, %14 : i7, i57
      %16 = comb.parity %15 : i64
      llhd.drv %11, %16 after %0 : !hw.inout<i1>
      %17 = llhd.sig.extract %data_o from %c-5_i6 : (!hw.inout<i64>) -> !hw.inout<i1>
      %18 = llhd.prb %data_o : !hw.inout<i64>
      %19 = comb.extract %18 from 0 : (i64) -> i57
      %20 = comb.and %19, %c-18610366057053727_i57 : i57
      %21 = comb.concat %c0_i7, %20 : i7, i57
      %22 = comb.parity %21 : i64
      llhd.drv %17, %22 after %0 : !hw.inout<i1>
      %23 = llhd.sig.extract %data_o from %c-4_i6 : (!hw.inout<i64>) -> !hw.inout<i1>
      %24 = llhd.prb %data_o : !hw.inout<i64>
      %25 = comb.extract %24 from 1 : (i64) -> i56
      %26 = comb.and %25, %c-4654104825805039_i56 : i56
      %27 = comb.concat %c0_i7, %26, %false : i7, i56, i1
      %28 = comb.parity %27 : i64
      llhd.drv %23, %28 after %0 : !hw.inout<i1>
      %29 = llhd.sig.extract %data_o from %c-3_i6 : (!hw.inout<i64>) -> !hw.inout<i1>
      %30 = llhd.prb %data_o : !hw.inout<i64>
      %31 = comb.extract %30 from 2 : (i64) -> i55
      %32 = comb.and %31, %c-1163612191044463_i55 : i55
      %33 = comb.concat %c0_i7, %32, %c0_i2 : i7, i55, i2
      %34 = comb.parity %33 : i64
      llhd.drv %29, %34 after %0 : !hw.inout<i1>
      %35 = llhd.sig.extract %data_o from %c-2_i6 : (!hw.inout<i64>) -> !hw.inout<i1>
      %36 = llhd.prb %data_o : !hw.inout<i64>
      %37 = comb.extract %36 from 3 : (i64) -> i54
      %38 = comb.and %37, %c-290911646233967_i54 : i54
      %39 = comb.concat %c0_i7, %38, %c0_i3 : i7, i54, i3
      %40 = comb.parity %39 : i64
      llhd.drv %35, %40 after %0 : !hw.inout<i1>
      %41 = llhd.sig.extract %data_o from %c-1_i6 : (!hw.inout<i64>) -> !hw.inout<i1>
      %42 = llhd.prb %data_o : !hw.inout<i64>
      %43 = comb.extract %42 from 4 : (i64) -> i53
      %44 = comb.and %43, %c-72728986368367_i53 : i53
      %45 = comb.concat %c0_i7, %44, %c0_i4 : i7, i53, i4
      %46 = comb.parity %45 : i64
      llhd.drv %41, %46 after %0 : !hw.inout<i1>
      %47 = llhd.prb %data_o : !hw.inout<i64>
      %48 = comb.xor %47, %c6052837899185946624_i64 : i64
      llhd.drv %data_o, %48 after %0 : !hw.inout<i64>
      llhd.wait (%1, %2 : i57, i64), ^bb1
    }
    llhd.drv %data_i_0, %data_i after %0 : !hw.inout<i57>
    hw.output %2 : i64
  }
  hw.module private @prim_alert_sender(in %clk_i : i1, in %rst_ni : i1, in %alert_test_i : i1, in %alert_req_i : i1, out alert_ack_o : i1, out alert_state_o : i1, in %alert_rx_i : !hw.struct<ping_p: i1, ping_n: i1, ack_p: i1, ack_n: i1>, out alert_tx_o : !hw.struct<alert_p: i1, alert_n: i1>) {
    %0 = llhd.constant_time <0ns, 1d, 0e>
    %1 = llhd.constant_time <0ns, 0d, 1e>
    %c0_i2 = hw.constant 0 : i2
    %c-2_i3 = hw.constant -2 : i3
    %c-4_i3 = hw.constant -4 : i3
    %c-3_i3 = hw.constant -3 : i3
    %c2_i3 = hw.constant 2 : i3
    %c3_i3 = hw.constant 3 : i3
    %c1_i3 = hw.constant 1 : i3
    %c0_i3 = hw.constant 0 : i3
    %true = hw.constant true
    %false = hw.constant false
    %clk_i_0 = llhd.sig name "clk_i" %false : i1
    %2 = llhd.prb %clk_i_0 : !hw.inout<i1>
    %rst_ni_1 = llhd.sig name "rst_ni" %false : i1
    %3 = llhd.prb %rst_ni_1 : !hw.inout<i1>
    %4 = hw.bitcast %c0_i2 : (i2) -> !hw.struct<alert_p: i1, alert_n: i1>
    %alert_tx_o = llhd.sig %4 : !hw.struct<alert_p: i1, alert_n: i1>
    %ping_n = hw.struct_extract %alert_rx_i["ping_n"] : !hw.struct<ping_p: i1, ping_n: i1, ack_p: i1, ack_n: i1>
    %ping_p = hw.struct_extract %alert_rx_i["ping_p"] : !hw.struct<ping_p: i1, ping_n: i1, ack_p: i1, ack_n: i1>
    %5 = comb.concat %ping_n, %ping_p : i1, i1
    %u_prim_buf_ping.out_o = hw.instance "u_prim_buf_ping" @prim_sec_anchor_buf(in_i: %5: i2) -> (out_o: i2)
    %6 = comb.extract %u_prim_buf_ping.out_o from 1 {sv.namehint = "ping_n"} : (i2) -> i1
    %7 = comb.extract %u_prim_buf_ping.out_o from 0 {sv.namehint = "ping_p"} : (i2) -> i1
    %u_decode_ping.level_o, %u_decode_ping.rise_o, %u_decode_ping.fall_o, %u_decode_ping.event_o, %u_decode_ping.sigint_o = hw.instance "u_decode_ping" @prim_diff_decode(clk_i: %2: i1, rst_ni: %3: i1, diff_pi: %7: i1, diff_ni: %6: i1) -> (level_o: i1, rise_o: i1, fall_o: i1, event_o: i1, sigint_o: i1) {sv.namehint = "ping_event"}
    %ack_level = llhd.sig %false : i1
    %ack_n = hw.struct_extract %alert_rx_i["ack_n"] : !hw.struct<ping_p: i1, ping_n: i1, ack_p: i1, ack_n: i1>
    %ack_p = hw.struct_extract %alert_rx_i["ack_p"] : !hw.struct<ping_p: i1, ping_n: i1, ack_p: i1, ack_n: i1>
    %8 = comb.concat %ack_n, %ack_p : i1, i1
    %u_prim_buf_ack.out_o = hw.instance "u_prim_buf_ack" @prim_sec_anchor_buf(in_i: %8: i2) -> (out_o: i2)
    %9 = comb.extract %u_prim_buf_ack.out_o from 1 {sv.namehint = "ack_n"} : (i2) -> i1
    %10 = comb.extract %u_prim_buf_ack.out_o from 0 {sv.namehint = "ack_p"} : (i2) -> i1
    %u_decode_ack.level_o, %u_decode_ack.rise_o, %u_decode_ack.fall_o, %u_decode_ack.event_o, %u_decode_ack.sigint_o = hw.instance "u_decode_ack" @prim_diff_decode(clk_i: %2: i1, rst_ni: %3: i1, diff_pi: %10: i1, diff_ni: %9: i1) -> (level_o: i1, rise_o: i1, fall_o: i1, event_o: i1, sigint_o: i1) {sv.namehint = "ack_sigint"}
    llhd.drv %ack_level, %u_decode_ack.level_o after %1 : !hw.inout<i1>
    %state_d = llhd.sig %c0_i3 : i3
    %state_q = llhd.sig %c0_i3 : i3
    %alert_pd = llhd.sig %false : i1
    %alert_nd = llhd.sig %false : i1
    %sigint_detected = llhd.sig %false : i1
    %11 = comb.or %u_decode_ack.sigint_o, %u_decode_ping.sigint_o : i1
    llhd.drv %sigint_detected, %11 after %1 : !hw.inout<i1>
    %12 = llhd.sig.struct_extract %alert_tx_o["alert_p"] : !hw.inout<struct<alert_p: i1, alert_n: i1>>
    llhd.drv %12, %39 after %1 : !hw.inout<i1>
    %13 = llhd.sig.struct_extract %alert_tx_o["alert_n"] : !hw.inout<struct<alert_p: i1, alert_n: i1>>
    llhd.drv %13, %38 after %1 : !hw.inout<i1>
    %alert_set_d = llhd.sig %false : i1
    %alert_set_q = llhd.sig %false : i1
    %alert_clr = llhd.sig %false : i1
    %alert_test_set_d = llhd.sig %false : i1
    %alert_test_set_q = llhd.sig %false : i1
    %ping_set_d = llhd.sig %false : i1
    %ping_set_q = llhd.sig %false : i1
    %ping_clr = llhd.sig %false : i1
    %alert_test_trigger = llhd.sig %false : i1
    %ping_trigger = llhd.sig %false : i1
    %u_prim_buf_in_req.out_o = hw.instance "u_prim_buf_in_req" @prim_sec_anchor_buf_5(in_i: %alert_req_i: i1) -> (out_o: i1) {sv.namehint = "alert_req"}
    %14 = llhd.prb %alert_set_q : !hw.inout<i1>
    %15 = comb.or %u_prim_buf_in_req.out_o, %14 {sv.namehint = "alert_req_trigger"} : i1
    llhd.drv %alert_set_d, %15 after %1 : !hw.inout<i1>
    %16 = llhd.prb %alert_test_set_q : !hw.inout<i1>
    %17 = comb.or %alert_test_i, %16 : i1
    llhd.drv %alert_test_trigger, %17 after %1 : !hw.inout<i1>
    %18 = llhd.prb %alert_clr : !hw.inout<i1>
    %19 = llhd.prb %alert_test_trigger : !hw.inout<i1>
    %20 = comb.xor %18, %true : i1
    %21 = comb.and %20, %19 : i1
    llhd.drv %alert_test_set_d, %21 after %1 : !hw.inout<i1>
    %alert_trigger = llhd.sig %false : i1
    %22 = comb.or %15, %19 : i1
    llhd.drv %alert_trigger, %22 after %1 : !hw.inout<i1>
    %23 = llhd.prb %ping_set_q : !hw.inout<i1>
    %24 = comb.or %23, %u_decode_ping.event_o : i1
    llhd.drv %ping_trigger, %24 after %1 : !hw.inout<i1>
    %25 = llhd.prb %ping_clr : !hw.inout<i1>
    %26 = llhd.prb %ping_trigger : !hw.inout<i1>
    %27 = comb.xor %25, %true : i1
    %28 = comb.and %27, %26 : i1
    llhd.drv %ping_set_d, %28 after %1 : !hw.inout<i1>
    %29 = comb.and %18, %14 : i1
    %30 = llhd.prb %state_q : !hw.inout<i3>
    %31 = llhd.prb %state_d : !hw.inout<i3>
    %32 = llhd.prb %alert_pd : !hw.inout<i1>
    %33 = llhd.prb %alert_nd : !hw.inout<i1>
    %34 = llhd.prb %alert_trigger : !hw.inout<i1>
    %35 = llhd.prb %sigint_detected : !hw.inout<i1>
    %36 = llhd.prb %ack_level : !hw.inout<i1>
    llhd.process {
      cf.br ^bb1
    ^bb1:  // 2 preds: ^bb0, ^bb25
      %41 = llhd.prb %state_q : !hw.inout<i3>
      llhd.drv %state_d, %41 after %1 : !hw.inout<i3>
      llhd.drv %alert_pd, %false after %1 : !hw.inout<i1>
      llhd.drv %alert_nd, %true after %1 : !hw.inout<i1>
      llhd.drv %ping_clr, %false after %1 : !hw.inout<i1>
      llhd.drv %alert_clr, %false after %1 : !hw.inout<i1>
      %42 = llhd.prb %state_q : !hw.inout<i3>
      %43 = comb.icmp ceq %42, %c0_i3 : i3
      cf.cond_br %43, ^bb2, ^bb4
    ^bb2:  // pred: ^bb1
      %44 = llhd.prb %alert_trigger : !hw.inout<i1>
      %45 = llhd.prb %ping_trigger : !hw.inout<i1>
      %46 = comb.or %44, %45 : i1
      cf.cond_br %46, ^bb3, ^bb23
    ^bb3:  // pred: ^bb2
      %47 = llhd.prb %alert_trigger : !hw.inout<i1>
      %48 = comb.xor %47, %true : i1
      %49 = comb.concat %false, %48, %true : i1, i1, i1
      llhd.drv %state_d, %49 after %1 : !hw.inout<i3>
      llhd.drv %alert_pd, %true after %1 : !hw.inout<i1>
      llhd.drv %alert_nd, %false after %1 : !hw.inout<i1>
      cf.br ^bb23
    ^bb4:  // pred: ^bb1
      %50 = comb.icmp ceq %42, %c1_i3 : i3
      cf.cond_br %50, ^bb5, ^bb8
    ^bb5:  // pred: ^bb4
      %51 = llhd.prb %ack_level : !hw.inout<i1>
      cf.cond_br %51, ^bb6, ^bb7
    ^bb6:  // pred: ^bb5
      llhd.drv %state_d, %c2_i3 after %1 : !hw.inout<i3>
      cf.br ^bb23
    ^bb7:  // pred: ^bb5
      llhd.drv %alert_pd, %true after %1 : !hw.inout<i1>
      llhd.drv %alert_nd, %false after %1 : !hw.inout<i1>
      cf.br ^bb23
    ^bb8:  // pred: ^bb4
      %52 = comb.icmp ceq %42, %c2_i3 : i3
      cf.cond_br %52, ^bb9, ^bb11
    ^bb9:  // pred: ^bb8
      %53 = llhd.prb %ack_level : !hw.inout<i1>
      %54 = comb.xor %53, %true : i1
      cf.cond_br %54, ^bb10, ^bb23
    ^bb10:  // pred: ^bb9
      llhd.drv %state_d, %c-3_i3 after %1 : !hw.inout<i3>
      llhd.drv %alert_clr, %true after %1 : !hw.inout<i1>
      cf.br ^bb23
    ^bb11:  // pred: ^bb8
      %55 = comb.icmp ceq %42, %c3_i3 : i3
      cf.cond_br %55, ^bb12, ^bb15
    ^bb12:  // pred: ^bb11
      %56 = llhd.prb %ack_level : !hw.inout<i1>
      cf.cond_br %56, ^bb13, ^bb14
    ^bb13:  // pred: ^bb12
      llhd.drv %state_d, %c-4_i3 after %1 : !hw.inout<i3>
      cf.br ^bb23
    ^bb14:  // pred: ^bb12
      llhd.drv %alert_pd, %true after %1 : !hw.inout<i1>
      llhd.drv %alert_nd, %false after %1 : !hw.inout<i1>
      cf.br ^bb23
    ^bb15:  // pred: ^bb11
      %57 = comb.icmp ceq %42, %c-4_i3 : i3
      cf.cond_br %57, ^bb16, ^bb18
    ^bb16:  // pred: ^bb15
      %58 = llhd.prb %ack_level : !hw.inout<i1>
      %59 = comb.xor %58, %true : i1
      cf.cond_br %59, ^bb17, ^bb23
    ^bb17:  // pred: ^bb16
      llhd.drv %ping_clr, %true after %1 : !hw.inout<i1>
      llhd.drv %state_d, %c-3_i3 after %1 : !hw.inout<i3>
      cf.br ^bb23
    ^bb18:  // pred: ^bb15
      %60 = comb.icmp ceq %42, %c-3_i3 : i3
      cf.cond_br %60, ^bb19, ^bb20
    ^bb19:  // pred: ^bb18
      llhd.drv %state_d, %c-2_i3 after %1 : !hw.inout<i3>
      cf.br ^bb23
    ^bb20:  // pred: ^bb18
      %61 = comb.icmp ceq %42, %c-2_i3 : i3
      cf.cond_br %61, ^bb21, ^bb22
    ^bb21:  // pred: ^bb20
      llhd.drv %state_d, %c0_i3 after %1 : !hw.inout<i3>
      cf.br ^bb23
    ^bb22:  // pred: ^bb20
      llhd.drv %state_d, %c0_i3 after %1 : !hw.inout<i3>
      cf.br ^bb23
    ^bb23:  // 13 preds: ^bb2, ^bb3, ^bb6, ^bb7, ^bb9, ^bb10, ^bb13, ^bb14, ^bb16, ^bb17, ^bb19, ^bb21, ^bb22
      %62 = llhd.prb %sigint_detected : !hw.inout<i1>
      cf.cond_br %62, ^bb24, ^bb25
    ^bb24:  // pred: ^bb23
      llhd.drv %state_d, %c0_i3 after %1 : !hw.inout<i3>
      llhd.drv %alert_pd, %false after %1 : !hw.inout<i1>
      llhd.drv %alert_nd, %false after %1 : !hw.inout<i1>
      llhd.drv %ping_clr, %true after %1 : !hw.inout<i1>
      llhd.drv %alert_clr, %false after %1 : !hw.inout<i1>
      cf.br ^bb25
    ^bb25:  // 2 preds: ^bb23, ^bb24
      llhd.wait (%30, %31, %32, %33, %25, %18, %34, %26, %35, %36 : i3, i3, i1, i1, i1, i1, i1, i1, i1, i1), ^bb1
    }
    %37 = comb.concat %33, %32 : i1, i1
    %u_prim_flop_alert.q_o = hw.instance "u_prim_flop_alert" @prim_sec_anchor_flop(clk_i: %2: i1, rst_ni: %3: i1, d_i: %37: i2) -> (q_o: i2)
    %38 = comb.extract %u_prim_flop_alert.q_o from 1 {sv.namehint = "alert_nq"} : (i2) -> i1
    %39 = comb.extract %u_prim_flop_alert.q_o from 0 {sv.namehint = "alert_pq"} : (i2) -> i1
    llhd.process {
      cf.br ^bb1
    ^bb1:  // 4 preds: ^bb0, ^bb2, ^bb4, ^bb5
      %41 = llhd.prb %clk_i_0 : !hw.inout<i1>
      %42 = llhd.prb %rst_ni_1 : !hw.inout<i1>
      llhd.wait (%2, %3 : i1, i1), ^bb2
    ^bb2:  // pred: ^bb1
      %43 = llhd.prb %clk_i_0 : !hw.inout<i1>
      %44 = comb.xor bin %41, %true : i1
      %45 = comb.and bin %44, %43 : i1
      %46 = llhd.prb %rst_ni_1 : !hw.inout<i1>
      %47 = comb.xor bin %46, %true : i1
      %48 = comb.and bin %42, %47 : i1
      %49 = comb.or bin %45, %48 : i1
      cf.cond_br %49, ^bb3, ^bb1
    ^bb3:  // pred: ^bb2
      %50 = llhd.prb %rst_ni_1 : !hw.inout<i1>
      %51 = comb.xor %50, %true : i1
      cf.cond_br %51, ^bb4, ^bb5
    ^bb4:  // pred: ^bb3
      llhd.drv %state_q, %c0_i3 after %0 : !hw.inout<i3>
      llhd.drv %alert_set_q, %false after %0 : !hw.inout<i1>
      llhd.drv %alert_test_set_q, %false after %0 : !hw.inout<i1>
      llhd.drv %ping_set_q, %false after %0 : !hw.inout<i1>
      cf.br ^bb1
    ^bb5:  // pred: ^bb3
      %52 = llhd.prb %state_d : !hw.inout<i3>
      llhd.drv %state_q, %52 after %0 : !hw.inout<i3>
      %53 = llhd.prb %alert_set_d : !hw.inout<i1>
      llhd.drv %alert_set_q, %53 after %0 : !hw.inout<i1>
      %54 = llhd.prb %alert_test_set_d : !hw.inout<i1>
      llhd.drv %alert_test_set_q, %54 after %0 : !hw.inout<i1>
      %55 = llhd.prb %ping_set_d : !hw.inout<i1>
      llhd.drv %ping_set_q, %55 after %0 : !hw.inout<i1>
      cf.br ^bb1
    }
    llhd.drv %clk_i_0, %clk_i after %1 : !hw.inout<i1>
    llhd.drv %rst_ni_1, %rst_ni after %1 : !hw.inout<i1>
    %40 = llhd.prb %alert_tx_o : !hw.inout<struct<alert_p: i1, alert_n: i1>>
    hw.output %29, %14, %40 : i1, i1, !hw.struct<alert_p: i1, alert_n: i1>
  }
  hw.module private @tlul_err(in %clk_i : i1, in %rst_ni : i1, in %tl_i : !hw.struct<a_valid: i1, a_opcode: i3, a_param: i3, a_size: i2, a_source: i8, a_address: i32, a_mask: i4, a_data: i32, a_user: !hw.struct<rsvd: i5, instr_type: i4, cmd_intg: i7, data_intg: i7>, d_ready: i1>, out err_o : i1) {
    %c-1_i2 = hw.constant -1 : i2
    %c-1_i4 = hw.constant -1 : i4
    %c0_i30 = hw.constant 0 : i30
    %0 = llhd.constant_time <0ns, 0d, 1e>
    %c0_i2 = hw.constant 0 : i2
    %c0_i4 = hw.constant 0 : i4
    %c2_i32 = hw.constant 2 : i32
    %c1_i32 = hw.constant 1 : i32
    %true = hw.constant true
    %c0_i32 = hw.constant 0 : i32
    %false = hw.constant false
    %c1_i4 = hw.constant 1 : i4
    %c-4_i3 = hw.constant -4 : i3
    %c1_i3 = hw.constant 1 : i3
    %c0_i3 = hw.constant 0 : i3
    %c0_i109 = hw.constant 0 : i109
    %1 = hw.bitcast %c0_i109 : (i109) -> !hw.struct<a_valid: i1, a_opcode: i3, a_param: i3, a_size: i2, a_source: i8, a_address: i32, a_mask: i4, a_data: i32, a_user: !hw.struct<rsvd: i5, instr_type: i4, cmd_intg: i7, data_intg: i7>, d_ready: i1>
    %tl_i_0 = llhd.sig name "tl_i" %1 : !hw.struct<a_valid: i1, a_opcode: i3, a_param: i3, a_size: i2, a_source: i8, a_address: i32, a_mask: i4, a_data: i32, a_user: !hw.struct<rsvd: i5, instr_type: i4, cmd_intg: i7, data_intg: i7>, d_ready: i1>
    %2 = llhd.prb %tl_i_0 : !hw.inout<struct<a_valid: i1, a_opcode: i3, a_param: i3, a_size: i2, a_source: i8, a_address: i32, a_mask: i4, a_data: i32, a_user: !hw.struct<rsvd: i5, instr_type: i4, cmd_intg: i7, data_intg: i7>, d_ready: i1>>
    %a_opcode = hw.struct_extract %2["a_opcode"] : !hw.struct<a_valid: i1, a_opcode: i3, a_param: i3, a_size: i2, a_source: i8, a_address: i32, a_mask: i4, a_data: i32, a_user: !hw.struct<rsvd: i5, instr_type: i4, cmd_intg: i7, data_intg: i7>, d_ready: i1>
    %3 = comb.icmp eq %a_opcode, %c0_i3 {sv.namehint = "op_full"} : i3
    %4 = comb.icmp eq %a_opcode, %c1_i3 {sv.namehint = "op_partial"} : i3
    %5 = comb.icmp eq %a_opcode, %c-4_i3 {sv.namehint = "op_get"} : i3
    %a_user = hw.struct_extract %2["a_user"] : !hw.struct<a_valid: i1, a_opcode: i3, a_param: i3, a_size: i2, a_source: i8, a_address: i32, a_mask: i4, a_data: i32, a_user: !hw.struct<rsvd: i5, instr_type: i4, cmd_intg: i7, data_intg: i7>, d_ready: i1>
    %instr_type = hw.struct_extract %a_user["instr_type"] : !hw.struct<rsvd: i5, instr_type: i4, cmd_intg: i7, data_intg: i7>
    %6 = func.call @"prim_mubi_pkg::mubi4_test_true_strict"(%instr_type) : (i4) -> i1
    %7 = comb.or %3, %4 : i1
    %8 = comb.and %6, %7 {sv.namehint = "instr_wr_err"} : i1
    %9 = func.call @"prim_mubi_pkg::mubi4_test_invalid"(%instr_type) {sv.namehint = "instr_type_err"} : (i4) -> i1
    %10 = comb.and %13, %17, %18, %21 : i1
    %11 = comb.xor %10, %true : i1
    %12 = comb.or %11, %8, %9 : i1
    %13 = comb.or %3, %4, %5 {sv.namehint = "opcode_allowed"} : i1
    %addr_sz_chk = llhd.sig %false : i1
    %mask_chk = llhd.sig %false : i1
    %fulldata_chk = llhd.sig %false : i1
    %mask = llhd.sig %c0_i4 : i4
    %a_address = hw.struct_extract %2["a_address"] : !hw.struct<a_valid: i1, a_opcode: i3, a_param: i3, a_size: i2, a_source: i8, a_address: i32, a_mask: i4, a_data: i32, a_user: !hw.struct<rsvd: i5, instr_type: i4, cmd_intg: i7, data_intg: i7>, d_ready: i1>
    %14 = comb.extract %a_address from 0 : (i32) -> i2
    %15 = comb.concat %c0_i2, %14 : i2, i2
    %16 = comb.shl %c1_i4, %15 : i4
    llhd.drv %mask, %16 after %0 : !hw.inout<i4>
    %17 = llhd.prb %addr_sz_chk : !hw.inout<i1>
    %18 = llhd.prb %mask_chk : !hw.inout<i1>
    %19 = llhd.prb %fulldata_chk : !hw.inout<i1>
    %20 = llhd.prb %mask : !hw.inout<i4>
    llhd.process {
      cf.br ^bb1
    ^bb1:  // 2 preds: ^bb0, ^bb9
      llhd.drv %addr_sz_chk, %false after %0 : !hw.inout<i1>
      llhd.drv %mask_chk, %false after %0 : !hw.inout<i1>
      llhd.drv %fulldata_chk, %false after %0 : !hw.inout<i1>
      %22 = llhd.prb %tl_i_0 : !hw.inout<struct<a_valid: i1, a_opcode: i3, a_param: i3, a_size: i2, a_source: i8, a_address: i32, a_mask: i4, a_data: i32, a_user: !hw.struct<rsvd: i5, instr_type: i4, cmd_intg: i7, data_intg: i7>, d_ready: i1>>
      %a_valid = hw.struct_extract %22["a_valid"] : !hw.struct<a_valid: i1, a_opcode: i3, a_param: i3, a_size: i2, a_source: i8, a_address: i32, a_mask: i4, a_data: i32, a_user: !hw.struct<rsvd: i5, instr_type: i4, cmd_intg: i7, data_intg: i7>, d_ready: i1>
      cf.cond_br %a_valid, ^bb2, ^bb9
    ^bb2:  // pred: ^bb1
      %23 = llhd.prb %tl_i_0 : !hw.inout<struct<a_valid: i1, a_opcode: i3, a_param: i3, a_size: i2, a_source: i8, a_address: i32, a_mask: i4, a_data: i32, a_user: !hw.struct<rsvd: i5, instr_type: i4, cmd_intg: i7, data_intg: i7>, d_ready: i1>>
      %a_size = hw.struct_extract %23["a_size"] : !hw.struct<a_valid: i1, a_opcode: i3, a_param: i3, a_size: i2, a_source: i8, a_address: i32, a_mask: i4, a_data: i32, a_user: !hw.struct<rsvd: i5, instr_type: i4, cmd_intg: i7, data_intg: i7>, d_ready: i1>
      %24 = comb.concat %c0_i30, %a_size : i30, i2
      %25 = comb.icmp ceq %24, %c0_i32 : i32
      cf.cond_br %25, ^bb3, ^bb4
    ^bb3:  // pred: ^bb2
      llhd.drv %addr_sz_chk, %true after %0 : !hw.inout<i1>
      %26 = llhd.prb %tl_i_0 : !hw.inout<struct<a_valid: i1, a_opcode: i3, a_param: i3, a_size: i2, a_source: i8, a_address: i32, a_mask: i4, a_data: i32, a_user: !hw.struct<rsvd: i5, instr_type: i4, cmd_intg: i7, data_intg: i7>, d_ready: i1>>
      %a_mask = hw.struct_extract %26["a_mask"] : !hw.struct<a_valid: i1, a_opcode: i3, a_param: i3, a_size: i2, a_source: i8, a_address: i32, a_mask: i4, a_data: i32, a_user: !hw.struct<rsvd: i5, instr_type: i4, cmd_intg: i7, data_intg: i7>, d_ready: i1>
      %27 = llhd.prb %mask : !hw.inout<i4>
      %28 = comb.xor %27, %c-1_i4 : i4
      %29 = comb.and %a_mask, %28 : i4
      %30 = comb.icmp eq %29, %c0_i4 : i4
      llhd.drv %mask_chk, %30 after %0 : !hw.inout<i1>
      %31 = llhd.prb %tl_i_0 : !hw.inout<struct<a_valid: i1, a_opcode: i3, a_param: i3, a_size: i2, a_source: i8, a_address: i32, a_mask: i4, a_data: i32, a_user: !hw.struct<rsvd: i5, instr_type: i4, cmd_intg: i7, data_intg: i7>, d_ready: i1>>
      %a_mask_1 = hw.struct_extract %31["a_mask"] : !hw.struct<a_valid: i1, a_opcode: i3, a_param: i3, a_size: i2, a_source: i8, a_address: i32, a_mask: i4, a_data: i32, a_user: !hw.struct<rsvd: i5, instr_type: i4, cmd_intg: i7, data_intg: i7>, d_ready: i1>
      %32 = llhd.prb %mask : !hw.inout<i4>
      %33 = comb.and %a_mask_1, %32 : i4
      %34 = comb.icmp ne %33, %c0_i4 : i4
      llhd.drv %fulldata_chk, %34 after %0 : !hw.inout<i1>
      cf.br ^bb9
    ^bb4:  // pred: ^bb2
      %35 = comb.icmp ceq %24, %c1_i32 : i32
      cf.cond_br %35, ^bb5, ^bb6
    ^bb5:  // pred: ^bb4
      %36 = llhd.prb %tl_i_0 : !hw.inout<struct<a_valid: i1, a_opcode: i3, a_param: i3, a_size: i2, a_source: i8, a_address: i32, a_mask: i4, a_data: i32, a_user: !hw.struct<rsvd: i5, instr_type: i4, cmd_intg: i7, data_intg: i7>, d_ready: i1>>
      %a_address_2 = hw.struct_extract %36["a_address"] : !hw.struct<a_valid: i1, a_opcode: i3, a_param: i3, a_size: i2, a_source: i8, a_address: i32, a_mask: i4, a_data: i32, a_user: !hw.struct<rsvd: i5, instr_type: i4, cmd_intg: i7, data_intg: i7>, d_ready: i1>
      %37 = comb.extract %a_address_2 from 0 : (i32) -> i1
      %38 = comb.xor %37, %true : i1
      llhd.drv %addr_sz_chk, %38 after %0 : !hw.inout<i1>
      %39 = llhd.prb %tl_i_0 : !hw.inout<struct<a_valid: i1, a_opcode: i3, a_param: i3, a_size: i2, a_source: i8, a_address: i32, a_mask: i4, a_data: i32, a_user: !hw.struct<rsvd: i5, instr_type: i4, cmd_intg: i7, data_intg: i7>, d_ready: i1>>
      %a_address_3 = hw.struct_extract %39["a_address"] : !hw.struct<a_valid: i1, a_opcode: i3, a_param: i3, a_size: i2, a_source: i8, a_address: i32, a_mask: i4, a_data: i32, a_user: !hw.struct<rsvd: i5, instr_type: i4, cmd_intg: i7, data_intg: i7>, d_ready: i1>
      %40 = comb.extract %a_address_3 from 1 : (i32) -> i1
      %a_mask_4 = hw.struct_extract %39["a_mask"] : !hw.struct<a_valid: i1, a_opcode: i3, a_param: i3, a_size: i2, a_source: i8, a_address: i32, a_mask: i4, a_data: i32, a_user: !hw.struct<rsvd: i5, instr_type: i4, cmd_intg: i7, data_intg: i7>, d_ready: i1>
      %41 = comb.extract %a_mask_4 from 0 : (i4) -> i2
      %42 = comb.icmp eq %41, %c0_i2 : i2
      %43 = comb.extract %a_mask_4 from 2 : (i4) -> i2
      %44 = comb.icmp eq %43, %c0_i2 : i2
      %45 = comb.mux %40, %42, %44 : i1
      llhd.drv %mask_chk, %45 after %0 : !hw.inout<i1>
      %46 = llhd.prb %tl_i_0 : !hw.inout<struct<a_valid: i1, a_opcode: i3, a_param: i3, a_size: i2, a_source: i8, a_address: i32, a_mask: i4, a_data: i32, a_user: !hw.struct<rsvd: i5, instr_type: i4, cmd_intg: i7, data_intg: i7>, d_ready: i1>>
      %a_address_5 = hw.struct_extract %46["a_address"] : !hw.struct<a_valid: i1, a_opcode: i3, a_param: i3, a_size: i2, a_source: i8, a_address: i32, a_mask: i4, a_data: i32, a_user: !hw.struct<rsvd: i5, instr_type: i4, cmd_intg: i7, data_intg: i7>, d_ready: i1>
      %47 = comb.extract %a_address_5 from 1 : (i32) -> i1
      %a_mask_6 = hw.struct_extract %46["a_mask"] : !hw.struct<a_valid: i1, a_opcode: i3, a_param: i3, a_size: i2, a_source: i8, a_address: i32, a_mask: i4, a_data: i32, a_user: !hw.struct<rsvd: i5, instr_type: i4, cmd_intg: i7, data_intg: i7>, d_ready: i1>
      %48 = comb.extract %a_mask_6 from 2 : (i4) -> i2
      %49 = comb.icmp eq %48, %c-1_i2 : i2
      %50 = comb.extract %a_mask_6 from 0 : (i4) -> i2
      %51 = comb.icmp eq %50, %c-1_i2 : i2
      %52 = comb.mux %47, %49, %51 : i1
      llhd.drv %fulldata_chk, %52 after %0 : !hw.inout<i1>
      cf.br ^bb9
    ^bb6:  // pred: ^bb4
      %53 = comb.icmp ceq %24, %c2_i32 : i32
      cf.cond_br %53, ^bb7, ^bb8
    ^bb7:  // pred: ^bb6
      %54 = llhd.prb %tl_i_0 : !hw.inout<struct<a_valid: i1, a_opcode: i3, a_param: i3, a_size: i2, a_source: i8, a_address: i32, a_mask: i4, a_data: i32, a_user: !hw.struct<rsvd: i5, instr_type: i4, cmd_intg: i7, data_intg: i7>, d_ready: i1>>
      %a_address_7 = hw.struct_extract %54["a_address"] : !hw.struct<a_valid: i1, a_opcode: i3, a_param: i3, a_size: i2, a_source: i8, a_address: i32, a_mask: i4, a_data: i32, a_user: !hw.struct<rsvd: i5, instr_type: i4, cmd_intg: i7, data_intg: i7>, d_ready: i1>
      %55 = comb.extract %a_address_7 from 0 : (i32) -> i2
      %56 = comb.icmp eq %55, %c0_i2 : i2
      llhd.drv %addr_sz_chk, %56 after %0 : !hw.inout<i1>
      llhd.drv %mask_chk, %true after %0 : !hw.inout<i1>
      %57 = llhd.prb %tl_i_0 : !hw.inout<struct<a_valid: i1, a_opcode: i3, a_param: i3, a_size: i2, a_source: i8, a_address: i32, a_mask: i4, a_data: i32, a_user: !hw.struct<rsvd: i5, instr_type: i4, cmd_intg: i7, data_intg: i7>, d_ready: i1>>
      %a_mask_8 = hw.struct_extract %57["a_mask"] : !hw.struct<a_valid: i1, a_opcode: i3, a_param: i3, a_size: i2, a_source: i8, a_address: i32, a_mask: i4, a_data: i32, a_user: !hw.struct<rsvd: i5, instr_type: i4, cmd_intg: i7, data_intg: i7>, d_ready: i1>
      %58 = comb.icmp eq %a_mask_8, %c-1_i4 : i4
      llhd.drv %fulldata_chk, %58 after %0 : !hw.inout<i1>
      cf.br ^bb9
    ^bb8:  // pred: ^bb6
      llhd.drv %addr_sz_chk, %false after %0 : !hw.inout<i1>
      llhd.drv %mask_chk, %false after %0 : !hw.inout<i1>
      llhd.drv %fulldata_chk, %false after %0 : !hw.inout<i1>
      cf.br ^bb9
    ^bb9:  // 5 preds: ^bb1, ^bb3, ^bb5, ^bb7, ^bb8
      llhd.wait (%17, %18, %19, %2, %20 : i1, i1, i1, !hw.struct<a_valid: i1, a_opcode: i3, a_param: i3, a_size: i2, a_source: i8, a_address: i32, a_mask: i4, a_data: i32, a_user: !hw.struct<rsvd: i5, instr_type: i4, cmd_intg: i7, data_intg: i7>, d_ready: i1>, i4), ^bb1
    }
    %21 = comb.or %5, %4, %19 : i1
    llhd.drv %tl_i_0, %tl_i after %0 : !hw.inout<struct<a_valid: i1, a_opcode: i3, a_param: i3, a_size: i2, a_source: i8, a_address: i32, a_mask: i4, a_data: i32, a_user: !hw.struct<rsvd: i5, instr_type: i4, cmd_intg: i7, data_intg: i7>, d_ready: i1>>
    hw.output %12 : i1
  }
  hw.module private @tlul_data_integ_dec(in %data_intg_i : i39, out data_err_o : i1) {
    %c0_i2 = hw.constant 0 : i2
    %u_data_chk.data_o, %u_data_chk.syndrome_o, %u_data_chk.err_o = hw.instance "u_data_chk" @prim_secded_inv_39_32_dec(data_i: %data_intg_i: i39) -> (data_o: i32, syndrome_o: i7, err_o: i2) {sv.namehint = "data_err"}
    %0 = comb.icmp ne %u_data_chk.err_o, %c0_i2 : i2
    hw.output %0 : i1
  }
  hw.module private @tlul_data_integ_enc(in %data_i : i32, out data_intg_o : i39) {
    %u_data_gen.data_o = hw.instance "u_data_gen" @prim_secded_inv_39_32_enc(data_i: %data_i: i32) -> (data_o: i39)
    hw.output %u_data_gen.data_o : i39
  }
  hw.module private @tlul_cmd_intg_chk(in %tl_i : !hw.struct<a_valid: i1, a_opcode: i3, a_param: i3, a_size: i2, a_source: i8, a_address: i32, a_mask: i4, a_data: i32, a_user: !hw.struct<rsvd: i5, instr_type: i4, cmd_intg: i7, data_intg: i7>, d_ready: i1>, out err_o : i1) {
    %c0_i2 = hw.constant 0 : i2
    %c0_i14 = hw.constant 0 : i14
    %0 = func.call @"tlul_pkg::extract_h2d_cmd_intg"(%tl_i) {sv.namehint = "cmd"} : (!hw.struct<a_valid: i1, a_opcode: i3, a_param: i3, a_size: i2, a_source: i8, a_address: i32, a_mask: i4, a_data: i32, a_user: !hw.struct<rsvd: i5, instr_type: i4, cmd_intg: i7, data_intg: i7>, d_ready: i1>) -> !hw.struct<instr_type: i4, addr: i32, opcode: i3, mask: i4>
    %a_user = hw.struct_extract %tl_i["a_user"] : !hw.struct<a_valid: i1, a_opcode: i3, a_param: i3, a_size: i2, a_source: i8, a_address: i32, a_mask: i4, a_data: i32, a_user: !hw.struct<rsvd: i5, instr_type: i4, cmd_intg: i7, data_intg: i7>, d_ready: i1>
    %cmd_intg = hw.struct_extract %a_user["cmd_intg"] : !hw.struct<rsvd: i5, instr_type: i4, cmd_intg: i7, data_intg: i7>
    %1 = hw.bitcast %0 : (!hw.struct<instr_type: i4, addr: i32, opcode: i3, mask: i4>) -> i43
    %2 = comb.concat %cmd_intg, %c0_i14, %1 : i7, i14, i43
    %u_chk.data_o, %u_chk.syndrome_o, %u_chk.err_o = hw.instance "u_chk" @prim_secded_inv_64_57_dec(data_i: %2: i64) -> (data_o: i57, syndrome_o: i7, err_o: i2) {sv.namehint = "err"}
    %data_intg = hw.struct_extract %a_user["data_intg"] : !hw.struct<rsvd: i5, instr_type: i4, cmd_intg: i7, data_intg: i7>
    %a_data = hw.struct_extract %tl_i["a_data"] : !hw.struct<a_valid: i1, a_opcode: i3, a_param: i3, a_size: i2, a_source: i8, a_address: i32, a_mask: i4, a_data: i32, a_user: !hw.struct<rsvd: i5, instr_type: i4, cmd_intg: i7, data_intg: i7>, d_ready: i1>
    %3 = comb.concat %data_intg, %a_data : i7, i32
    %u_tlul_data_integ_dec.data_err_o = hw.instance "u_tlul_data_integ_dec" @tlul_data_integ_dec(data_intg_i: %3: i39) -> (data_err_o: i1) {sv.namehint = "data_err"}
    %a_valid = hw.struct_extract %tl_i["a_valid"] : !hw.struct<a_valid: i1, a_opcode: i3, a_param: i3, a_size: i2, a_source: i8, a_address: i32, a_mask: i4, a_data: i32, a_user: !hw.struct<rsvd: i5, instr_type: i4, cmd_intg: i7, data_intg: i7>, d_ready: i1>
    %4 = comb.icmp ne %u_chk.err_o, %c0_i2 : i2
    %5 = comb.or %4, %u_tlul_data_integ_dec.data_err_o : i1
    %6 = comb.and %a_valid, %5 : i1
    hw.output %6 : i1
  }
  hw.module private @tlul_rsp_intg_gen(in %tl_i : !hw.struct<d_valid: i1, d_opcode: i3, d_param: i3, d_size: i2, d_source: i8, d_sink: i1, d_data: i32, d_user: !hw.struct<rsp_intg: i7, data_intg: i7>, d_error: i1, a_ready: i1>, out tl_o : !hw.struct<d_valid: i1, d_opcode: i3, d_param: i3, d_size: i2, d_source: i8, d_sink: i1, d_data: i32, d_user: !hw.struct<rsp_intg: i7, data_intg: i7>, d_error: i1, a_ready: i1>) {
    %0 = llhd.constant_time <0ns, 0d, 1e>
    %c0_i51 = hw.constant 0 : i51
    %c0_i7 = hw.constant 0 : i7
    %c0_i66 = hw.constant 0 : i66
    %1 = hw.bitcast %c0_i66 : (i66) -> !hw.struct<d_valid: i1, d_opcode: i3, d_param: i3, d_size: i2, d_source: i8, d_sink: i1, d_data: i32, d_user: !hw.struct<rsp_intg: i7, data_intg: i7>, d_error: i1, a_ready: i1>
    %tl_i_0 = llhd.sig name "tl_i" %1 : !hw.struct<d_valid: i1, d_opcode: i3, d_param: i3, d_size: i2, d_source: i8, d_sink: i1, d_data: i32, d_user: !hw.struct<rsp_intg: i7, data_intg: i7>, d_error: i1, a_ready: i1>
    %tl_o = llhd.sig %1 : !hw.struct<d_valid: i1, d_opcode: i3, d_param: i3, d_size: i2, d_source: i8, d_sink: i1, d_data: i32, d_user: !hw.struct<rsp_intg: i7, data_intg: i7>, d_error: i1, a_ready: i1>
    %rsp_intg = llhd.sig %c0_i7 : i7
    %2 = llhd.prb %tl_i_0 : !hw.inout<struct<d_valid: i1, d_opcode: i3, d_param: i3, d_size: i2, d_source: i8, d_sink: i1, d_data: i32, d_user: !hw.struct<rsp_intg: i7, data_intg: i7>, d_error: i1, a_ready: i1>>
    %3 = func.call @"tlul_pkg::extract_d2h_rsp_intg"(%2) {sv.namehint = "gen_rsp_intg.rsp"} : (!hw.struct<d_valid: i1, d_opcode: i3, d_param: i3, d_size: i2, d_source: i8, d_sink: i1, d_data: i32, d_user: !hw.struct<rsp_intg: i7, data_intg: i7>, d_error: i1, a_ready: i1>) -> !hw.struct<opcode: i3, size: i2, error: i1>
    %4 = hw.bitcast %3 : (!hw.struct<opcode: i3, size: i2, error: i1>) -> i6
    %5 = comb.concat %c0_i51, %4 : i51, i6
    %gen_rsp_intg.u_rsp_gen.data_o = hw.instance "gen_rsp_intg.u_rsp_gen" @prim_secded_inv_64_57_enc(data_i: %5: i57) -> (data_o: i64)
    %6 = comb.extract %gen_rsp_intg.u_rsp_gen.data_o from 57 : (i64) -> i7
    llhd.drv %rsp_intg, %6 after %0 : !hw.inout<i7>
    %data_intg = llhd.sig %c0_i7 : i7
    %d_data = hw.struct_extract %2["d_data"] : !hw.struct<d_valid: i1, d_opcode: i3, d_param: i3, d_size: i2, d_source: i8, d_sink: i1, d_data: i32, d_user: !hw.struct<rsp_intg: i7, data_intg: i7>, d_error: i1, a_ready: i1>
    %gen_data_intg.u_tlul_data_integ_enc.data_intg_o = hw.instance "gen_data_intg.u_tlul_data_integ_enc" @tlul_data_integ_enc(data_i: %d_data: i32) -> (data_intg_o: i39)
    %7 = comb.extract %gen_data_intg.u_tlul_data_integ_enc.data_intg_o from 32 : (i39) -> i7
    llhd.drv %data_intg, %7 after %0 : !hw.inout<i7>
    %8 = llhd.prb %tl_o : !hw.inout<struct<d_valid: i1, d_opcode: i3, d_param: i3, d_size: i2, d_source: i8, d_sink: i1, d_data: i32, d_user: !hw.struct<rsp_intg: i7, data_intg: i7>, d_error: i1, a_ready: i1>>
    %9 = llhd.prb %rsp_intg : !hw.inout<i7>
    %10 = llhd.prb %data_intg : !hw.inout<i7>
    llhd.process {
      cf.br ^bb1
    ^bb1:  // 2 preds: ^bb0, ^bb1
      %11 = llhd.prb %tl_i_0 : !hw.inout<struct<d_valid: i1, d_opcode: i3, d_param: i3, d_size: i2, d_source: i8, d_sink: i1, d_data: i32, d_user: !hw.struct<rsp_intg: i7, data_intg: i7>, d_error: i1, a_ready: i1>>
      llhd.drv %tl_o, %11 after %0 : !hw.inout<struct<d_valid: i1, d_opcode: i3, d_param: i3, d_size: i2, d_source: i8, d_sink: i1, d_data: i32, d_user: !hw.struct<rsp_intg: i7, data_intg: i7>, d_error: i1, a_ready: i1>>
      %12 = llhd.sig.struct_extract %tl_o["d_user"] : !hw.inout<struct<d_valid: i1, d_opcode: i3, d_param: i3, d_size: i2, d_source: i8, d_sink: i1, d_data: i32, d_user: !hw.struct<rsp_intg: i7, data_intg: i7>, d_error: i1, a_ready: i1>>
      %13 = llhd.sig.struct_extract %12["rsp_intg"] : !hw.inout<struct<rsp_intg: i7, data_intg: i7>>
      %14 = llhd.prb %rsp_intg : !hw.inout<i7>
      llhd.drv %13, %14 after %0 : !hw.inout<i7>
      %15 = llhd.sig.struct_extract %12["data_intg"] : !hw.inout<struct<rsp_intg: i7, data_intg: i7>>
      %16 = llhd.prb %data_intg : !hw.inout<i7>
      llhd.drv %15, %16 after %0 : !hw.inout<i7>
      llhd.wait (%2, %8, %9, %10 : !hw.struct<d_valid: i1, d_opcode: i3, d_param: i3, d_size: i2, d_source: i8, d_sink: i1, d_data: i32, d_user: !hw.struct<rsp_intg: i7, data_intg: i7>, d_error: i1, a_ready: i1>, !hw.struct<d_valid: i1, d_opcode: i3, d_param: i3, d_size: i2, d_source: i8, d_sink: i1, d_data: i32, d_user: !hw.struct<rsp_intg: i7, data_intg: i7>, d_error: i1, a_ready: i1>, i7, i7), ^bb1
    }
    llhd.drv %tl_i_0, %tl_i after %0 : !hw.inout<struct<d_valid: i1, d_opcode: i3, d_param: i3, d_size: i2, d_source: i8, d_sink: i1, d_data: i32, d_user: !hw.struct<rsp_intg: i7, data_intg: i7>, d_error: i1, a_ready: i1>>
    hw.output %8 : !hw.struct<d_valid: i1, d_opcode: i3, d_param: i3, d_size: i2, d_source: i8, d_sink: i1, d_data: i32, d_user: !hw.struct<rsp_intg: i7, data_intg: i7>, d_error: i1, a_ready: i1>
  }
  hw.module private @tlul_rsp_intg_gen_6(in %tl_i : !hw.struct<d_valid: i1, d_opcode: i3, d_param: i3, d_size: i2, d_source: i8, d_sink: i1, d_data: i32, d_user: !hw.struct<rsp_intg: i7, data_intg: i7>, d_error: i1, a_ready: i1>, out tl_o : !hw.struct<d_valid: i1, d_opcode: i3, d_param: i3, d_size: i2, d_source: i8, d_sink: i1, d_data: i32, d_user: !hw.struct<rsp_intg: i7, data_intg: i7>, d_error: i1, a_ready: i1>) {
    %0 = llhd.constant_time <0ns, 0d, 1e>
    %c0_i7 = hw.constant 0 : i7
    %c0_i66 = hw.constant 0 : i66
    %1 = hw.bitcast %c0_i66 : (i66) -> !hw.struct<d_valid: i1, d_opcode: i3, d_param: i3, d_size: i2, d_source: i8, d_sink: i1, d_data: i32, d_user: !hw.struct<rsp_intg: i7, data_intg: i7>, d_error: i1, a_ready: i1>
    %tl_i_0 = llhd.sig name "tl_i" %1 : !hw.struct<d_valid: i1, d_opcode: i3, d_param: i3, d_size: i2, d_source: i8, d_sink: i1, d_data: i32, d_user: !hw.struct<rsp_intg: i7, data_intg: i7>, d_error: i1, a_ready: i1>
    %tl_o = llhd.sig %1 : !hw.struct<d_valid: i1, d_opcode: i3, d_param: i3, d_size: i2, d_source: i8, d_sink: i1, d_data: i32, d_user: !hw.struct<rsp_intg: i7, data_intg: i7>, d_error: i1, a_ready: i1>
    %rsp_intg = llhd.sig %c0_i7 : i7
    llhd.drv %rsp_intg, %c0_i7 after %0 : !hw.inout<i7>
    %data_intg = llhd.sig %c0_i7 : i7
    llhd.drv %data_intg, %c0_i7 after %0 : !hw.inout<i7>
    %2 = llhd.prb %tl_i_0 : !hw.inout<struct<d_valid: i1, d_opcode: i3, d_param: i3, d_size: i2, d_source: i8, d_sink: i1, d_data: i32, d_user: !hw.struct<rsp_intg: i7, data_intg: i7>, d_error: i1, a_ready: i1>>
    %3 = llhd.prb %tl_o : !hw.inout<struct<d_valid: i1, d_opcode: i3, d_param: i3, d_size: i2, d_source: i8, d_sink: i1, d_data: i32, d_user: !hw.struct<rsp_intg: i7, data_intg: i7>, d_error: i1, a_ready: i1>>
    %4 = llhd.prb %rsp_intg : !hw.inout<i7>
    %5 = llhd.prb %data_intg : !hw.inout<i7>
    llhd.process {
      cf.br ^bb1
    ^bb1:  // 2 preds: ^bb0, ^bb1
      %6 = llhd.prb %tl_i_0 : !hw.inout<struct<d_valid: i1, d_opcode: i3, d_param: i3, d_size: i2, d_source: i8, d_sink: i1, d_data: i32, d_user: !hw.struct<rsp_intg: i7, data_intg: i7>, d_error: i1, a_ready: i1>>
      llhd.drv %tl_o, %6 after %0 : !hw.inout<struct<d_valid: i1, d_opcode: i3, d_param: i3, d_size: i2, d_source: i8, d_sink: i1, d_data: i32, d_user: !hw.struct<rsp_intg: i7, data_intg: i7>, d_error: i1, a_ready: i1>>
      %7 = llhd.sig.struct_extract %tl_o["d_user"] : !hw.inout<struct<d_valid: i1, d_opcode: i3, d_param: i3, d_size: i2, d_source: i8, d_sink: i1, d_data: i32, d_user: !hw.struct<rsp_intg: i7, data_intg: i7>, d_error: i1, a_ready: i1>>
      %8 = llhd.sig.struct_extract %7["rsp_intg"] : !hw.inout<struct<rsp_intg: i7, data_intg: i7>>
      %9 = llhd.prb %rsp_intg : !hw.inout<i7>
      llhd.drv %8, %9 after %0 : !hw.inout<i7>
      %10 = llhd.sig.struct_extract %7["data_intg"] : !hw.inout<struct<rsp_intg: i7, data_intg: i7>>
      %11 = llhd.prb %data_intg : !hw.inout<i7>
      llhd.drv %10, %11 after %0 : !hw.inout<i7>
      llhd.wait (%2, %3, %4, %5 : !hw.struct<d_valid: i1, d_opcode: i3, d_param: i3, d_size: i2, d_source: i8, d_sink: i1, d_data: i32, d_user: !hw.struct<rsp_intg: i7, data_intg: i7>, d_error: i1, a_ready: i1>, !hw.struct<d_valid: i1, d_opcode: i3, d_param: i3, d_size: i2, d_source: i8, d_sink: i1, d_data: i32, d_user: !hw.struct<rsp_intg: i7, data_intg: i7>, d_error: i1, a_ready: i1>, i7, i7), ^bb1
    }
    llhd.drv %tl_i_0, %tl_i after %0 : !hw.inout<struct<d_valid: i1, d_opcode: i3, d_param: i3, d_size: i2, d_source: i8, d_sink: i1, d_data: i32, d_user: !hw.struct<rsp_intg: i7, data_intg: i7>, d_error: i1, a_ready: i1>>
    hw.output %3 : !hw.struct<d_valid: i1, d_opcode: i3, d_param: i3, d_size: i2, d_source: i8, d_sink: i1, d_data: i32, d_user: !hw.struct<rsp_intg: i7, data_intg: i7>, d_error: i1, a_ready: i1>
  }
  hw.module private @tlul_adapter_reg(in %clk_i : i1, in %rst_ni : i1, in %tl_i : !hw.struct<a_valid: i1, a_opcode: i3, a_param: i3, a_size: i2, a_source: i8, a_address: i32, a_mask: i4, a_data: i32, a_user: !hw.struct<rsvd: i5, instr_type: i4, cmd_intg: i7, data_intg: i7>, d_ready: i1>, out tl_o : !hw.struct<d_valid: i1, d_opcode: i3, d_param: i3, d_size: i2, d_source: i8, d_sink: i1, d_data: i32, d_user: !hw.struct<rsp_intg: i7, data_intg: i7>, d_error: i1, a_ready: i1>, in %en_ifetch_i : i4, out intg_error_o : i1, out re_o : i1, out we_o : i1, out addr_o : i9, out wdata_o : i32, out be_o : i4, in %busy_i : i1, in %rdata_i : i32, in %error_i : i1) {
    %0 = llhd.constant_time <0ns, 1d, 0e>
    %1 = llhd.constant_time <0ns, 0d, 1e>
    %c0_i109 = hw.constant 0 : i109
    %c0_i14 = hw.constant 0 : i14
    %c-1_i32 = hw.constant -1 : i32
    %c0_i32 = hw.constant 0 : i32
    %c0_i2 = hw.constant 0 : i2
    %c0_i8 = hw.constant 0 : i8
    %true = hw.constant true
    %false = hw.constant false {sv.namehint = "intg_error"}
    %c-4_i3 = hw.constant -4 : i3
    %c1_i3 = hw.constant 1 : i3
    %c0_i3 = hw.constant 0 : i3
    %clk_i_0 = llhd.sig name "clk_i" %false : i1
    %2 = llhd.prb %clk_i_0 : !hw.inout<i1>
    %rst_ni_1 = llhd.sig name "rst_ni" %false : i1
    %3 = llhd.prb %rst_ni_1 : !hw.inout<i1>
    %4 = hw.bitcast %c0_i109 : (i109) -> !hw.struct<a_valid: i1, a_opcode: i3, a_param: i3, a_size: i2, a_source: i8, a_address: i32, a_mask: i4, a_data: i32, a_user: !hw.struct<rsvd: i5, instr_type: i4, cmd_intg: i7, data_intg: i7>, d_ready: i1>
    %tl_i_2 = llhd.sig name "tl_i" %4 : !hw.struct<a_valid: i1, a_opcode: i3, a_param: i3, a_size: i2, a_source: i8, a_address: i32, a_mask: i4, a_data: i32, a_user: !hw.struct<rsvd: i5, instr_type: i4, cmd_intg: i7, data_intg: i7>, d_ready: i1>
    %rdata_i_3 = llhd.sig name "rdata_i" %c0_i32 : i32
    %error_i_4 = llhd.sig name "error_i" %false : i1
    %outstanding_q = llhd.sig %false : i1
    %a_ack = llhd.sig %false : i1
    %d_ack = llhd.sig %false : i1
    %rdata_q = llhd.sig %c0_i32 : i32
    %error_q = llhd.sig %false : i1
    %err_internal = llhd.sig %false : i1
    %addr_align_err = llhd.sig %false : i1
    %reqid_q = llhd.sig %c0_i8 : i8
    %reqsz_q = llhd.sig %c0_i2 : i2
    %rspop_q = llhd.sig %c0_i3 : i3
    %rd_req = llhd.sig %false : i1
    %wr_req = llhd.sig %false : i1
    %5 = llhd.prb %tl_i_2 : !hw.inout<struct<a_valid: i1, a_opcode: i3, a_param: i3, a_size: i2, a_source: i8, a_address: i32, a_mask: i4, a_data: i32, a_user: !hw.struct<rsvd: i5, instr_type: i4, cmd_intg: i7, data_intg: i7>, d_ready: i1>>
    %a_valid = hw.struct_extract %5["a_valid"] : !hw.struct<a_valid: i1, a_opcode: i3, a_param: i3, a_size: i2, a_source: i8, a_address: i32, a_mask: i4, a_data: i32, a_user: !hw.struct<rsvd: i5, instr_type: i4, cmd_intg: i7, data_intg: i7>, d_ready: i1>
    %a_ready = hw.struct_extract %u_rsp_intg_gen.tl_o["a_ready"] : !hw.struct<d_valid: i1, d_opcode: i3, d_param: i3, d_size: i2, d_source: i8, d_sink: i1, d_data: i32, d_user: !hw.struct<rsp_intg: i7, data_intg: i7>, d_error: i1, a_ready: i1>
    %6 = comb.and %a_valid, %a_ready : i1
    llhd.drv %a_ack, %6 after %1 : !hw.inout<i1>
    %d_valid = hw.struct_extract %u_rsp_intg_gen.tl_o["d_valid"] : !hw.struct<d_valid: i1, d_opcode: i3, d_param: i3, d_size: i2, d_source: i8, d_sink: i1, d_data: i32, d_user: !hw.struct<rsp_intg: i7, data_intg: i7>, d_error: i1, a_ready: i1>
    %d_ready = hw.struct_extract %5["d_ready"] : !hw.struct<a_valid: i1, a_opcode: i3, a_param: i3, a_size: i2, a_source: i8, a_address: i32, a_mask: i4, a_data: i32, a_user: !hw.struct<rsvd: i5, instr_type: i4, cmd_intg: i7, data_intg: i7>, d_ready: i1>
    %7 = comb.and %d_valid, %d_ready : i1
    llhd.drv %d_ack, %7 after %1 : !hw.inout<i1>
    %8 = llhd.prb %a_ack : !hw.inout<i1>
    %a_opcode = hw.struct_extract %5["a_opcode"] : !hw.struct<a_valid: i1, a_opcode: i3, a_param: i3, a_size: i2, a_source: i8, a_address: i32, a_mask: i4, a_data: i32, a_user: !hw.struct<rsvd: i5, instr_type: i4, cmd_intg: i7, data_intg: i7>, d_ready: i1>
    %9 = comb.icmp eq %a_opcode, %c0_i3 : i3
    %10 = comb.icmp eq %a_opcode, %c1_i3 : i3
    %11 = comb.or %9, %10 : i1
    %12 = comb.and %8, %11 : i1
    llhd.drv %wr_req, %12 after %1 : !hw.inout<i1>
    %13 = comb.icmp eq %a_opcode, %c-4_i3 : i3
    %14 = comb.and %8, %13 : i1
    llhd.drv %rd_req, %14 after %1 : !hw.inout<i1>
    %15 = llhd.prb %wr_req : !hw.inout<i1>
    %16 = llhd.prb %err_internal : !hw.inout<i1>
    %17 = comb.xor %16, %true : i1
    %18 = comb.and %15, %17 : i1
    %19 = llhd.prb %rd_req : !hw.inout<i1>
    %20 = comb.and %19, %17 : i1
    %a_data = hw.struct_extract %5["a_data"] : !hw.struct<a_valid: i1, a_opcode: i3, a_param: i3, a_size: i2, a_source: i8, a_address: i32, a_mask: i4, a_data: i32, a_user: !hw.struct<rsvd: i5, instr_type: i4, cmd_intg: i7, data_intg: i7>, d_ready: i1>
    %a_mask = hw.struct_extract %5["a_mask"] : !hw.struct<a_valid: i1, a_opcode: i3, a_param: i3, a_size: i2, a_source: i8, a_address: i32, a_mask: i4, a_data: i32, a_user: !hw.struct<rsvd: i5, instr_type: i4, cmd_intg: i7, data_intg: i7>, d_ready: i1>
    %a_address = hw.struct_extract %5["a_address"] : !hw.struct<a_valid: i1, a_opcode: i3, a_param: i3, a_size: i2, a_source: i8, a_address: i32, a_mask: i4, a_data: i32, a_user: !hw.struct<rsvd: i5, instr_type: i4, cmd_intg: i7, data_intg: i7>, d_ready: i1>
    %21 = comb.extract %a_address from 2 : (i32) -> i7
    %22 = comb.concat %21, %c0_i2 : i7, i2
    llhd.process {
      cf.br ^bb1
    ^bb1:  // 6 preds: ^bb0, ^bb2, ^bb4, ^bb6, ^bb7, ^bb8
      %38 = llhd.prb %clk_i_0 : !hw.inout<i1>
      %39 = llhd.prb %rst_ni_1 : !hw.inout<i1>
      llhd.wait (%2, %3 : i1, i1), ^bb2
    ^bb2:  // pred: ^bb1
      %40 = llhd.prb %clk_i_0 : !hw.inout<i1>
      %41 = comb.xor bin %38, %true : i1
      %42 = comb.and bin %41, %40 : i1
      %43 = llhd.prb %rst_ni_1 : !hw.inout<i1>
      %44 = comb.xor bin %43, %true : i1
      %45 = comb.and bin %39, %44 : i1
      %46 = comb.or bin %42, %45 : i1
      cf.cond_br %46, ^bb3, ^bb1
    ^bb3:  // pred: ^bb2
      %47 = llhd.prb %rst_ni_1 : !hw.inout<i1>
      %48 = comb.xor %47, %true : i1
      cf.cond_br %48, ^bb4, ^bb5
    ^bb4:  // pred: ^bb3
      llhd.drv %outstanding_q, %false after %0 : !hw.inout<i1>
      cf.br ^bb1
    ^bb5:  // pred: ^bb3
      %49 = llhd.prb %a_ack : !hw.inout<i1>
      cf.cond_br %49, ^bb6, ^bb7
    ^bb6:  // pred: ^bb5
      llhd.drv %outstanding_q, %true after %0 : !hw.inout<i1>
      cf.br ^bb1
    ^bb7:  // pred: ^bb5
      %50 = llhd.prb %d_ack : !hw.inout<i1>
      cf.cond_br %50, ^bb8, ^bb1
    ^bb8:  // pred: ^bb7
      llhd.drv %outstanding_q, %false after %0 : !hw.inout<i1>
      cf.br ^bb1
    }
    llhd.process {
      cf.br ^bb1
    ^bb1:  // 5 preds: ^bb0, ^bb2, ^bb4, ^bb5, ^bb6
      %38 = llhd.prb %clk_i_0 : !hw.inout<i1>
      %39 = llhd.prb %rst_ni_1 : !hw.inout<i1>
      llhd.wait (%2, %3 : i1, i1), ^bb2
    ^bb2:  // pred: ^bb1
      %40 = llhd.prb %clk_i_0 : !hw.inout<i1>
      %41 = comb.xor bin %38, %true : i1
      %42 = comb.and bin %41, %40 : i1
      %43 = llhd.prb %rst_ni_1 : !hw.inout<i1>
      %44 = comb.xor bin %43, %true : i1
      %45 = comb.and bin %39, %44 : i1
      %46 = comb.or bin %42, %45 : i1
      cf.cond_br %46, ^bb3, ^bb1
    ^bb3:  // pred: ^bb2
      %47 = llhd.prb %rst_ni_1 : !hw.inout<i1>
      %48 = comb.xor %47, %true : i1
      cf.cond_br %48, ^bb4, ^bb5
    ^bb4:  // pred: ^bb3
      llhd.drv %reqid_q, %c0_i8 after %0 : !hw.inout<i8>
      llhd.drv %reqsz_q, %c0_i2 after %0 : !hw.inout<i2>
      llhd.drv %rspop_q, %c0_i3 after %0 : !hw.inout<i3>
      cf.br ^bb1
    ^bb5:  // pred: ^bb3
      %49 = llhd.prb %a_ack : !hw.inout<i1>
      cf.cond_br %49, ^bb6, ^bb1
    ^bb6:  // pred: ^bb5
      %50 = llhd.prb %tl_i_2 : !hw.inout<struct<a_valid: i1, a_opcode: i3, a_param: i3, a_size: i2, a_source: i8, a_address: i32, a_mask: i4, a_data: i32, a_user: !hw.struct<rsvd: i5, instr_type: i4, cmd_intg: i7, data_intg: i7>, d_ready: i1>>
      %a_source = hw.struct_extract %50["a_source"] : !hw.struct<a_valid: i1, a_opcode: i3, a_param: i3, a_size: i2, a_source: i8, a_address: i32, a_mask: i4, a_data: i32, a_user: !hw.struct<rsvd: i5, instr_type: i4, cmd_intg: i7, data_intg: i7>, d_ready: i1>
      llhd.drv %reqid_q, %a_source after %0 : !hw.inout<i8>
      %51 = llhd.prb %tl_i_2 : !hw.inout<struct<a_valid: i1, a_opcode: i3, a_param: i3, a_size: i2, a_source: i8, a_address: i32, a_mask: i4, a_data: i32, a_user: !hw.struct<rsvd: i5, instr_type: i4, cmd_intg: i7, data_intg: i7>, d_ready: i1>>
      %a_size = hw.struct_extract %51["a_size"] : !hw.struct<a_valid: i1, a_opcode: i3, a_param: i3, a_size: i2, a_source: i8, a_address: i32, a_mask: i4, a_data: i32, a_user: !hw.struct<rsvd: i5, instr_type: i4, cmd_intg: i7, data_intg: i7>, d_ready: i1>
      llhd.drv %reqsz_q, %a_size after %0 : !hw.inout<i2>
      %52 = llhd.prb %rd_req : !hw.inout<i1>
      %53 = comb.concat %c0_i2, %52 : i2, i1
      llhd.drv %rspop_q, %53 after %0 : !hw.inout<i3>
      cf.br ^bb1
    }
    llhd.process {
      cf.br ^bb1
    ^bb1:  // 5 preds: ^bb0, ^bb2, ^bb4, ^bb5, ^bb6
      %38 = llhd.prb %clk_i_0 : !hw.inout<i1>
      %39 = llhd.prb %rst_ni_1 : !hw.inout<i1>
      llhd.wait (%2, %3 : i1, i1), ^bb2
    ^bb2:  // pred: ^bb1
      %40 = llhd.prb %clk_i_0 : !hw.inout<i1>
      %41 = comb.xor bin %38, %true : i1
      %42 = comb.and bin %41, %40 : i1
      %43 = llhd.prb %rst_ni_1 : !hw.inout<i1>
      %44 = comb.xor bin %43, %true : i1
      %45 = comb.and bin %39, %44 : i1
      %46 = comb.or bin %42, %45 : i1
      cf.cond_br %46, ^bb3, ^bb1
    ^bb3:  // pred: ^bb2
      %47 = llhd.prb %rst_ni_1 : !hw.inout<i1>
      %48 = comb.xor %47, %true : i1
      cf.cond_br %48, ^bb4, ^bb5
    ^bb4:  // pred: ^bb3
      llhd.drv %rdata_q, %c0_i32 after %0 : !hw.inout<i32>
      llhd.drv %error_q, %false after %0 : !hw.inout<i1>
      cf.br ^bb1
    ^bb5:  // pred: ^bb3
      %49 = llhd.prb %a_ack : !hw.inout<i1>
      cf.cond_br %49, ^bb6, ^bb1
    ^bb6:  // pred: ^bb5
      %50 = llhd.prb %error_i_4 : !hw.inout<i1>
      %51 = llhd.prb %err_internal : !hw.inout<i1>
      %52 = llhd.prb %wr_req : !hw.inout<i1>
      %53 = comb.or %50, %51, %52 : i1
      %54 = llhd.prb %rdata_i_3 : !hw.inout<i32>
      %55 = comb.mux %53, %c-1_i32, %54 : i32
      llhd.drv %rdata_q, %55 after %0 : !hw.inout<i32>
      %56 = llhd.prb %error_i_4 : !hw.inout<i1>
      %57 = llhd.prb %err_internal : !hw.inout<i1>
      %58 = comb.or %56, %57 : i1
      llhd.drv %error_q, %58 after %0 : !hw.inout<i1>
      cf.br ^bb1
    }
    %23 = llhd.prb %rdata_q {sv.namehint = "rdata"} : !hw.inout<i32>
    %24 = llhd.prb %error_q {sv.namehint = "error"} : !hw.inout<i1>
    %25 = llhd.prb %outstanding_q : !hw.inout<i1>
    %26 = llhd.prb %rspop_q : !hw.inout<i3>
    %27 = llhd.prb %reqsz_q : !hw.inout<i2>
    %28 = llhd.prb %reqid_q : !hw.inout<i8>
    %29 = hw.bitcast %c0_i14 : (i14) -> !hw.struct<rsp_intg: i7, data_intg: i7>
    %30 = comb.or %25, %busy_i : i1
    %31 = comb.xor %30, %true : i1
    %32 = hw.struct_create (%25, %26, %c0_i3, %27, %28, %false, %23, %29, %24, %31) {sv.namehint = "tl_o_pre"} : !hw.struct<d_valid: i1, d_opcode: i3, d_param: i3, d_size: i2, d_source: i8, d_sink: i1, d_data: i32, d_user: !hw.struct<rsp_intg: i7, data_intg: i7>, d_error: i1, a_ready: i1>
    %u_rsp_intg_gen.tl_o = hw.instance "u_rsp_intg_gen" @tlul_rsp_intg_gen_6(tl_i: %32: !hw.struct<d_valid: i1, d_opcode: i3, d_param: i3, d_size: i2, d_source: i8, d_sink: i1, d_data: i32, d_user: !hw.struct<rsp_intg: i7, data_intg: i7>, d_error: i1, a_ready: i1>) -> (tl_o: !hw.struct<d_valid: i1, d_opcode: i3, d_param: i3, d_size: i2, d_source: i8, d_sink: i1, d_data: i32, d_user: !hw.struct<rsp_intg: i7, data_intg: i7>, d_error: i1, a_ready: i1>)
    %a_user = hw.struct_extract %5["a_user"] : !hw.struct<a_valid: i1, a_opcode: i3, a_param: i3, a_size: i2, a_source: i8, a_address: i32, a_mask: i4, a_data: i32, a_user: !hw.struct<rsvd: i5, instr_type: i4, cmd_intg: i7, data_intg: i7>, d_ready: i1>
    %instr_type = hw.struct_extract %a_user["instr_type"] : !hw.struct<rsvd: i5, instr_type: i4, cmd_intg: i7, data_intg: i7>
    %33 = func.call @"prim_mubi_pkg::mubi4_test_true_strict"(%instr_type) : (i4) -> i1
    %34 = func.call @"prim_mubi_pkg::mubi4_test_false_loose"(%en_ifetch_i) : (i4) -> i1
    %35 = comb.and %33, %34 {sv.namehint = "instr_error"} : i1
    %36 = llhd.prb %addr_align_err : !hw.inout<i1>
    %37 = comb.or %36, %u_err.err_o, %35 : i1
    llhd.drv %err_internal, %37 after %1 : !hw.inout<i1>
    llhd.process {
      cf.br ^bb1
    ^bb1:  // 2 preds: ^bb0, ^bb4
      %38 = llhd.prb %wr_req : !hw.inout<i1>
      cf.cond_br %38, ^bb2, ^bb3
    ^bb2:  // pred: ^bb1
      %39 = llhd.prb %tl_i_2 : !hw.inout<struct<a_valid: i1, a_opcode: i3, a_param: i3, a_size: i2, a_source: i8, a_address: i32, a_mask: i4, a_data: i32, a_user: !hw.struct<rsvd: i5, instr_type: i4, cmd_intg: i7, data_intg: i7>, d_ready: i1>>
      %a_address_5 = hw.struct_extract %39["a_address"] : !hw.struct<a_valid: i1, a_opcode: i3, a_param: i3, a_size: i2, a_source: i8, a_address: i32, a_mask: i4, a_data: i32, a_user: !hw.struct<rsvd: i5, instr_type: i4, cmd_intg: i7, data_intg: i7>, d_ready: i1>
      %40 = comb.extract %a_address_5 from 0 : (i32) -> i2
      %41 = comb.icmp ne %40, %c0_i2 : i2
      llhd.drv %addr_align_err, %41 after %1 : !hw.inout<i1>
      cf.br ^bb4
    ^bb3:  // pred: ^bb1
      llhd.drv %addr_align_err, %false after %1 : !hw.inout<i1>
      cf.br ^bb4
    ^bb4:  // 2 preds: ^bb2, ^bb3
      llhd.wait (%15, %5, %36 : i1, !hw.struct<a_valid: i1, a_opcode: i3, a_param: i3, a_size: i2, a_source: i8, a_address: i32, a_mask: i4, a_data: i32, a_user: !hw.struct<rsvd: i5, instr_type: i4, cmd_intg: i7, data_intg: i7>, d_ready: i1>, i1), ^bb1
    }
    %u_err.err_o = hw.instance "u_err" @tlul_err(clk_i: %2: i1, rst_ni: %3: i1, tl_i: %5: !hw.struct<a_valid: i1, a_opcode: i3, a_param: i3, a_size: i2, a_source: i8, a_address: i32, a_mask: i4, a_data: i32, a_user: !hw.struct<rsvd: i5, instr_type: i4, cmd_intg: i7, data_intg: i7>, d_ready: i1>) -> (err_o: i1) {sv.namehint = "tl_err"}
    llhd.drv %clk_i_0, %clk_i after %1 : !hw.inout<i1>
    llhd.drv %rst_ni_1, %rst_ni after %1 : !hw.inout<i1>
    llhd.drv %tl_i_2, %tl_i after %1 : !hw.inout<struct<a_valid: i1, a_opcode: i3, a_param: i3, a_size: i2, a_source: i8, a_address: i32, a_mask: i4, a_data: i32, a_user: !hw.struct<rsvd: i5, instr_type: i4, cmd_intg: i7, data_intg: i7>, d_ready: i1>>
    llhd.drv %rdata_i_3, %rdata_i after %1 : !hw.inout<i32>
    llhd.drv %error_i_4, %error_i after %1 : !hw.inout<i1>
    hw.output %u_rsp_intg_gen.tl_o, %false, %20, %18, %22, %a_data, %a_mask : !hw.struct<d_valid: i1, d_opcode: i3, d_param: i3, d_size: i2, d_source: i8, d_sink: i1, d_data: i32, d_user: !hw.struct<rsp_intg: i7, data_intg: i7>, d_error: i1, a_ready: i1>, i1, i1, i1, i9, i32, i4
  }
  hw.module private @timer_core(in %clk_i : i1, in %rst_ni : i1, in %active : i1, in %prescaler : i12, in %step : i8, out tick : i1, out mtime_d : i64, in %mtime : i64, in %mtimecmp : !hw.array<1xi64>, out intr : i1) {
    %0 = llhd.constant_time <0ns, 0d, 1e>
    %c0_i0 = hw.constant 0 : i0
    %c0_i56 = hw.constant 0 : i56
    %1 = llhd.constant_time <0ns, 1d, 0e>
    %true = hw.constant true
    %c1_i12 = hw.constant 1 : i12
    %c0_i12 = hw.constant 0 : i12
    %false = hw.constant false
    %clk_i_0 = llhd.sig name "clk_i" %false : i1
    %2 = llhd.prb %clk_i_0 : !hw.inout<i1>
    %rst_ni_1 = llhd.sig name "rst_ni" %false : i1
    %3 = llhd.prb %rst_ni_1 : !hw.inout<i1>
    %active_2 = llhd.sig name "active" %false : i1
    %prescaler_3 = llhd.sig name "prescaler" %c0_i12 : i12
    %intr = llhd.sig %false : i1
    %tick_count = llhd.sig %c0_i12 : i12
    llhd.process {
      cf.br ^bb1
    ^bb1:  // 6 preds: ^bb0, ^bb2, ^bb4, ^bb6, ^bb8, ^bb9
      %15 = llhd.prb %clk_i_0 : !hw.inout<i1>
      %16 = llhd.prb %rst_ni_1 : !hw.inout<i1>
      llhd.wait (%2, %3 : i1, i1), ^bb2
    ^bb2:  // pred: ^bb1
      %17 = llhd.prb %clk_i_0 : !hw.inout<i1>
      %18 = comb.xor bin %15, %true : i1
      %19 = comb.and bin %18, %17 : i1
      %20 = llhd.prb %rst_ni_1 : !hw.inout<i1>
      %21 = comb.xor bin %20, %true : i1
      %22 = comb.and bin %16, %21 : i1
      %23 = comb.or bin %19, %22 : i1
      cf.cond_br %23, ^bb3, ^bb1
    ^bb3:  // pred: ^bb2
      %24 = llhd.prb %rst_ni_1 : !hw.inout<i1>
      %25 = comb.xor %24, %true : i1
      cf.cond_br %25, ^bb4, ^bb5
    ^bb4:  // pred: ^bb3
      llhd.drv %tick_count, %c0_i12 after %1 : !hw.inout<i12>
      cf.br ^bb1
    ^bb5:  // pred: ^bb3
      %26 = llhd.prb %active_2 : !hw.inout<i1>
      %27 = comb.xor %26, %true : i1
      cf.cond_br %27, ^bb6, ^bb7
    ^bb6:  // pred: ^bb5
      llhd.drv %tick_count, %c0_i12 after %1 : !hw.inout<i12>
      cf.br ^bb1
    ^bb7:  // pred: ^bb5
      %28 = llhd.prb %tick_count : !hw.inout<i12>
      %29 = llhd.prb %prescaler_3 : !hw.inout<i12>
      %30 = comb.icmp eq %28, %29 : i12
      cf.cond_br %30, ^bb8, ^bb9
    ^bb8:  // pred: ^bb7
      llhd.drv %tick_count, %c0_i12 after %1 : !hw.inout<i12>
      cf.br ^bb1
    ^bb9:  // pred: ^bb7
      %31 = llhd.prb %tick_count : !hw.inout<i12>
      %32 = comb.add %31, %c1_i12 : i12
      llhd.drv %tick_count, %32 after %1 : !hw.inout<i12>
      cf.br ^bb1
    }
    %4 = llhd.prb %active_2 : !hw.inout<i1>
    %5 = llhd.prb %tick_count : !hw.inout<i12>
    %6 = llhd.prb %prescaler_3 : !hw.inout<i12>
    %7 = comb.icmp uge %5, %6 : i12
    %8 = comb.and %4, %7 : i1
    %9 = comb.concat %c0_i56, %step : i56, i8
    %10 = comb.add %mtime, %9 : i64
    %11 = hw.array_get %mtimecmp[%c0_i0] : !hw.array<1xi64>, i0
    %12 = comb.icmp uge %mtime, %11 : i64
    %13 = comb.and %4, %12 : i1
    llhd.drv %intr, %13 after %0 : !hw.inout<i1>
    llhd.drv %clk_i_0, %clk_i after %0 : !hw.inout<i1>
    llhd.drv %rst_ni_1, %rst_ni after %0 : !hw.inout<i1>
    llhd.drv %active_2, %active after %0 : !hw.inout<i1>
    llhd.drv %prescaler_3, %prescaler after %0 : !hw.inout<i12>
    %14 = llhd.prb %intr : !hw.inout<i1>
    hw.output %8, %10, %14 : i1, i64, i1
  }
  hw.module private @rv_timer_reg_top(in %clk_i : i1, in %rst_ni : i1, in %tl_i : !hw.struct<a_valid: i1, a_opcode: i3, a_param: i3, a_size: i2, a_source: i8, a_address: i32, a_mask: i4, a_data: i32, a_user: !hw.struct<rsvd: i5, instr_type: i4, cmd_intg: i7, data_intg: i7>, d_ready: i1>, out tl_o : !hw.struct<d_valid: i1, d_opcode: i3, d_param: i3, d_size: i2, d_source: i8, d_sink: i1, d_data: i32, d_user: !hw.struct<rsp_intg: i7, data_intg: i7>, d_error: i1, a_ready: i1>, out reg2hw : !hw.struct<alert_test: !hw.struct<q: i1, qe: i1>, ctrl: !hw.array<1xstruct<q: i1>>, intr_enable0: !hw.array<1xstruct<q: i1>>, intr_state0: !hw.array<1xstruct<q: i1>>, intr_test0: !hw.array<1xstruct<q: i1, qe: i1>>, cfg0: !hw.struct<step: !hw.struct<q: i8>, prescale: !hw.struct<q: i12>>, timer_v_lower0: !hw.struct<q: i32>, timer_v_upper0: !hw.struct<q: i32>, compare_lower0_0: !hw.struct<q: i32, qe: i1>, compare_upper0_0: !hw.struct<q: i32, qe: i1>>, in %hw2reg : !hw.struct<intr_state0: !hw.array<1xstruct<d: i1, de: i1>>, timer_v_lower0: !hw.struct<d: i32, de: i1>, timer_v_upper0: !hw.struct<d: i32, de: i1>>, in %racl_policies_i : !hw.array<1xstruct<write_perm: i2, read_perm: i2>>, out racl_error_o : !hw.struct<valid: i1, overflow: i1, racl_role: i1, ctn_uid: i1, read_access: i1, request_address: i32>, out intg_err_o : i1) {
    %c-1_i3 = hw.constant -1 : i3
    %c-1_i4 = hw.constant -1 : i4
    %c-16_i5 = hw.constant -16 : i5
    %c0_i5 = hw.constant 0 : i5
    %c0_i23 = hw.constant 0 : i23
    %c-8_i4 = hw.constant -8 : i4
    %c6_i4 = hw.constant 6 : i4
    %c5_i4 = hw.constant 5 : i4
    %c4_i4 = hw.constant 4 : i4
    %c3_i4 = hw.constant 3 : i4
    %c2_i4 = hw.constant 2 : i4
    %c0_i0 = hw.constant 0 : i0
    %0 = llhd.constant_time <0ns, 1d, 0e>
    %1 = llhd.constant_time <0ns, 0d, 1e>
    %c0_i37 = hw.constant 0 : i37
    %c0_i4 = hw.constant 0 : i4
    %c0_i157 = hw.constant 0 : i157
    %c-1_i32 = hw.constant -1 : i32
    %c7_i4 = hw.constant 7 : i4
    %c1_i4 = hw.constant 1 : i4
    %c0_i32 = hw.constant 0 : i32
    %false = hw.constant false {sv.namehint = "racl_role"}
    %c-228_i9 = hw.constant -228 : i9
    %c-232_i9 = hw.constant -232 : i9
    %c-236_i9 = hw.constant -236 : i9
    %c-240_i9 = hw.constant -240 : i9
    %c-244_i9 = hw.constant -244 : i9
    %c-248_i9 = hw.constant -248 : i9
    %c-252_i9 = hw.constant -252 : i9
    %c-256_i9 = hw.constant -256 : i9
    %c4_i9 = hw.constant 4 : i9
    %c0_i9 = hw.constant 0 : i9
    %c0_i10 = hw.constant 0 : i10
    %c0_i2 = hw.constant 0 : i2
    %c0_i8 = hw.constant 0 : i8
    %c0_i12 = hw.constant 0 : i12
    %c-7_i4 = hw.constant -7 : i4
    %true = hw.constant true
    %clk_i_0 = llhd.sig name "clk_i" %false : i1
    %2 = llhd.prb %clk_i_0 : !hw.inout<i1>
    %rst_ni_1 = llhd.sig name "rst_ni" %false : i1
    %3 = llhd.prb %rst_ni_1 : !hw.inout<i1>
    %4 = hw.bitcast %c0_i157 : (i157) -> !hw.struct<alert_test: !hw.struct<q: i1, qe: i1>, ctrl: !hw.array<1xstruct<q: i1>>, intr_enable0: !hw.array<1xstruct<q: i1>>, intr_state0: !hw.array<1xstruct<q: i1>>, intr_test0: !hw.array<1xstruct<q: i1, qe: i1>>, cfg0: !hw.struct<step: !hw.struct<q: i8>, prescale: !hw.struct<q: i12>>, timer_v_lower0: !hw.struct<q: i32>, timer_v_upper0: !hw.struct<q: i32>, compare_lower0_0: !hw.struct<q: i32, qe: i1>, compare_upper0_0: !hw.struct<q: i32, qe: i1>>
    %reg2hw = llhd.sig %4 : !hw.struct<alert_test: !hw.struct<q: i1, qe: i1>, ctrl: !hw.array<1xstruct<q: i1>>, intr_enable0: !hw.array<1xstruct<q: i1>>, intr_state0: !hw.array<1xstruct<q: i1>>, intr_test0: !hw.array<1xstruct<q: i1, qe: i1>>, cfg0: !hw.struct<step: !hw.struct<q: i8>, prescale: !hw.struct<q: i12>>, timer_v_lower0: !hw.struct<q: i32>, timer_v_upper0: !hw.struct<q: i32>, compare_lower0_0: !hw.struct<q: i32, qe: i1>, compare_upper0_0: !hw.struct<q: i32, qe: i1>>
    %5 = hw.bitcast %c0_i4 : (i4) -> !hw.array<1xstruct<write_perm: i2, read_perm: i2>>
    %racl_policies_i_2 = llhd.sig name "racl_policies_i" %5 : !hw.array<1xstruct<write_perm: i2, read_perm: i2>>
    %6 = hw.bitcast %c0_i37 : (i37) -> !hw.struct<valid: i1, overflow: i1, racl_role: i1, ctn_uid: i1, read_access: i1, request_address: i32>
    %racl_error_o = llhd.sig %6 : !hw.struct<valid: i1, overflow: i1, racl_role: i1, ctn_uid: i1, read_access: i1, request_address: i32>
    %reg_we = llhd.sig %false : i1
    %reg_addr = llhd.sig %c0_i9 : i9
    %reg_be = llhd.sig %c0_i4 : i4
    %wr_err = llhd.sig %false : i1
    %reg_rdata_next = llhd.sig %c0_i32 : i32
    %intg_err = llhd.sig %false : i1
    %u_chk.err_o = hw.instance "u_chk" @tlul_cmd_intg_chk(tl_i: %tl_i: !hw.struct<a_valid: i1, a_opcode: i3, a_param: i3, a_size: i2, a_source: i8, a_address: i32, a_mask: i4, a_data: i32, a_user: !hw.struct<rsvd: i5, instr_type: i4, cmd_intg: i7, data_intg: i7>, d_ready: i1>) -> (err_o: i1)
    llhd.drv %intg_err, %u_chk.err_o after %1 : !hw.inout<i1>
    %reg_we_err = llhd.sig %false : i1
    %reg_we_check = llhd.sig %c0_i10 : i10
    %7 = llhd.prb %reg_we_check : !hw.inout<i10>
    %8 = llhd.prb %reg_we : !hw.inout<i1>
    %9 = comb.xor %74, %true : i1
    %10 = comb.and %8, %9 : i1
    %u_prim_reg_we_check.err_o = hw.instance "u_prim_reg_we_check" @prim_reg_we_check(clk_i: %2: i1, rst_ni: %3: i1, oh_i: %7: i10, en_i: %10: i1) -> (err_o: i1)
    llhd.drv %reg_we_err, %u_prim_reg_we_check.err_o after %1 : !hw.inout<i1>
    %err_q = llhd.sig %false : i1
    llhd.process {
      cf.br ^bb1
    ^bb1:  // 5 preds: ^bb0, ^bb2, ^bb4, ^bb5, ^bb6
      %123 = llhd.prb %clk_i_0 : !hw.inout<i1>
      %124 = llhd.prb %rst_ni_1 : !hw.inout<i1>
      llhd.wait (%2, %3 : i1, i1), ^bb2
    ^bb2:  // pred: ^bb1
      %125 = llhd.prb %clk_i_0 : !hw.inout<i1>
      %126 = comb.xor bin %123, %true : i1
      %127 = comb.and bin %126, %125 : i1
      %128 = llhd.prb %rst_ni_1 : !hw.inout<i1>
      %129 = comb.xor bin %128, %true : i1
      %130 = comb.and bin %124, %129 : i1
      %131 = comb.or bin %127, %130 : i1
      cf.cond_br %131, ^bb3, ^bb1
    ^bb3:  // pred: ^bb2
      %132 = llhd.prb %rst_ni_1 : !hw.inout<i1>
      %133 = comb.xor %132, %true : i1
      cf.cond_br %133, ^bb4, ^bb5
    ^bb4:  // pred: ^bb3
      llhd.drv %err_q, %false after %0 : !hw.inout<i1>
      cf.br ^bb1
    ^bb5:  // pred: ^bb3
      %134 = llhd.prb %intg_err : !hw.inout<i1>
      %135 = llhd.prb %reg_we_err : !hw.inout<i1>
      %136 = comb.or %134, %135 : i1
      cf.cond_br %136, ^bb6, ^bb1
    ^bb6:  // pred: ^bb5
      llhd.drv %err_q, %true after %0 : !hw.inout<i1>
      cf.br ^bb1
    }
    %11 = llhd.prb %err_q : !hw.inout<i1>
    %12 = llhd.prb %intg_err : !hw.inout<i1>
    %13 = llhd.prb %reg_we_err : !hw.inout<i1>
    %14 = comb.or %11, %12, %13 : i1
    %u_rsp_intg_gen.tl_o = hw.instance "u_rsp_intg_gen" @tlul_rsp_intg_gen(tl_i: %u_reg_if.tl_o: !hw.struct<d_valid: i1, d_opcode: i3, d_param: i3, d_size: i2, d_source: i8, d_sink: i1, d_data: i32, d_user: !hw.struct<rsp_intg: i7, data_intg: i7>, d_error: i1, a_ready: i1>) -> (tl_o: !hw.struct<d_valid: i1, d_opcode: i3, d_param: i3, d_size: i2, d_source: i8, d_sink: i1, d_data: i32, d_user: !hw.struct<rsp_intg: i7, data_intg: i7>, d_error: i1, a_ready: i1>)
    %15 = llhd.prb %racl_error_o : !hw.inout<struct<valid: i1, overflow: i1, racl_role: i1, ctn_uid: i1, read_access: i1, request_address: i32>>
    %u_reg_if.tl_o, %u_reg_if.intg_error_o, %u_reg_if.re_o, %u_reg_if.we_o, %u_reg_if.addr_o, %u_reg_if.wdata_o, %u_reg_if.be_o = hw.instance "u_reg_if" @tlul_adapter_reg(clk_i: %2: i1, rst_ni: %3: i1, tl_i: %tl_i: !hw.struct<a_valid: i1, a_opcode: i3, a_param: i3, a_size: i2, a_source: i8, a_address: i32, a_mask: i4, a_data: i32, a_user: !hw.struct<rsvd: i5, instr_type: i4, cmd_intg: i7, data_intg: i7>, d_ready: i1>, en_ifetch_i: %c-7_i4: i4, busy_i: %false: i1, rdata_i: %16: i32, error_i: %18: i1) -> (tl_o: !hw.struct<d_valid: i1, d_opcode: i3, d_param: i3, d_size: i2, d_source: i8, d_sink: i1, d_data: i32, d_user: !hw.struct<rsp_intg: i7, data_intg: i7>, d_error: i1, a_ready: i1>, intg_error_o: i1, re_o: i1, we_o: i1, addr_o: i9, wdata_o: i32, be_o: i4) {sv.namehint = "reg_re"}
    llhd.drv %reg_we, %u_reg_if.we_o after %1 : !hw.inout<i1>
    llhd.drv %reg_addr, %u_reg_if.addr_o after %1 : !hw.inout<i9>
    llhd.drv %reg_be, %u_reg_if.be_o after %1 : !hw.inout<i4>
    %16 = llhd.prb %reg_rdata_next {sv.namehint = "reg_rdata"} : !hw.inout<i32>
    %17 = llhd.prb %wr_err : !hw.inout<i1>
    %18 = comb.or %74, %17, %12 {sv.namehint = "reg_error"} : i1
    %alert_test_we = llhd.sig %false : i1
    %ctrl_we = llhd.sig %false : i1
    %ctrl_qs = llhd.sig %false : i1
    %intr_enable0_we = llhd.sig %false : i1
    %intr_enable0_qs = llhd.sig %false : i1
    %intr_state0_we = llhd.sig %false : i1
    %intr_state0_qs = llhd.sig %false : i1
    %intr_test0_we = llhd.sig %false : i1
    %cfg0_we = llhd.sig %false : i1
    %cfg0_prescale_qs = llhd.sig %c0_i12 : i12
    %cfg0_step_qs = llhd.sig %c0_i8 : i8
    %timer_v_lower0_we = llhd.sig %false : i1
    %timer_v_lower0_qs = llhd.sig %c0_i32 : i32
    %timer_v_upper0_we = llhd.sig %false : i1
    %timer_v_upper0_qs = llhd.sig %c0_i32 : i32
    %compare_lower0_0_we = llhd.sig %false : i1
    %compare_lower0_0_qs = llhd.sig %c0_i32 : i32
    %compare_upper0_0_we = llhd.sig %false : i1
    %compare_upper0_0_qs = llhd.sig %c0_i32 : i32
    %alert_test_flds_we = llhd.sig %false : i1
    %19 = llhd.prb %alert_test_flds_we {sv.namehint = "alert_test_qe"} : !hw.inout<i1>
    %20 = llhd.prb %alert_test_we : !hw.inout<i1>
    %21 = llhd.sig.struct_extract %reg2hw["alert_test"] : !hw.inout<struct<alert_test: !hw.struct<q: i1, qe: i1>, ctrl: !hw.array<1xstruct<q: i1>>, intr_enable0: !hw.array<1xstruct<q: i1>>, intr_state0: !hw.array<1xstruct<q: i1>>, intr_test0: !hw.array<1xstruct<q: i1, qe: i1>>, cfg0: !hw.struct<step: !hw.struct<q: i8>, prescale: !hw.struct<q: i12>>, timer_v_lower0: !hw.struct<q: i32>, timer_v_upper0: !hw.struct<q: i32>, compare_lower0_0: !hw.struct<q: i32, qe: i1>, compare_upper0_0: !hw.struct<q: i32, qe: i1>>>
    %22 = llhd.sig.struct_extract %21["q"] : !hw.inout<struct<q: i1, qe: i1>>
    %u_alert_test.qe, %u_alert_test.qre, %u_alert_test.q, %u_alert_test.ds, %u_alert_test.qs = hw.instance "u_alert_test" @prim_subreg_ext(re: %false: i1, we: %20: i1, wd: %92: i1, d: %false: i1) -> (qe: i1, qre: i1, q: i1, ds: i1, qs: i1)
    llhd.drv %alert_test_flds_we, %u_alert_test.qe after %1 : !hw.inout<i1>
    llhd.drv %22, %u_alert_test.q after %1 : !hw.inout<i1>
    %23 = llhd.sig.struct_extract %21["qe"] : !hw.inout<struct<q: i1, qe: i1>>
    llhd.drv %23, %19 after %1 : !hw.inout<i1>
    %24 = llhd.prb %ctrl_we : !hw.inout<i1>
    %25 = llhd.sig.struct_extract %reg2hw["ctrl"] : !hw.inout<struct<alert_test: !hw.struct<q: i1, qe: i1>, ctrl: !hw.array<1xstruct<q: i1>>, intr_enable0: !hw.array<1xstruct<q: i1>>, intr_state0: !hw.array<1xstruct<q: i1>>, intr_test0: !hw.array<1xstruct<q: i1, qe: i1>>, cfg0: !hw.struct<step: !hw.struct<q: i8>, prescale: !hw.struct<q: i12>>, timer_v_lower0: !hw.struct<q: i32>, timer_v_upper0: !hw.struct<q: i32>, compare_lower0_0: !hw.struct<q: i32, qe: i1>, compare_upper0_0: !hw.struct<q: i32, qe: i1>>>
    %26 = llhd.sig.array_get %25[%c0_i0] : !hw.inout<array<1xstruct<q: i1>>>
    %27 = llhd.sig.struct_extract %26["q"] : !hw.inout<struct<q: i1>>
    %u_ctrl.qe, %u_ctrl.q, %u_ctrl.ds, %u_ctrl.qs = hw.instance "u_ctrl" @prim_subreg(clk_i: %2: i1, rst_ni: %3: i1, we: %24: i1, wd: %92: i1, de: %false: i1, d: %false: i1) -> (qe: i1, q: i1, ds: i1, qs: i1)
    llhd.drv %27, %u_ctrl.q after %1 : !hw.inout<i1>
    llhd.drv %ctrl_qs, %u_ctrl.qs after %1 : !hw.inout<i1>
    %28 = llhd.prb %intr_enable0_we : !hw.inout<i1>
    %29 = llhd.sig.struct_extract %reg2hw["intr_enable0"] : !hw.inout<struct<alert_test: !hw.struct<q: i1, qe: i1>, ctrl: !hw.array<1xstruct<q: i1>>, intr_enable0: !hw.array<1xstruct<q: i1>>, intr_state0: !hw.array<1xstruct<q: i1>>, intr_test0: !hw.array<1xstruct<q: i1, qe: i1>>, cfg0: !hw.struct<step: !hw.struct<q: i8>, prescale: !hw.struct<q: i12>>, timer_v_lower0: !hw.struct<q: i32>, timer_v_upper0: !hw.struct<q: i32>, compare_lower0_0: !hw.struct<q: i32, qe: i1>, compare_upper0_0: !hw.struct<q: i32, qe: i1>>>
    %30 = llhd.sig.array_get %29[%c0_i0] : !hw.inout<array<1xstruct<q: i1>>>
    %31 = llhd.sig.struct_extract %30["q"] : !hw.inout<struct<q: i1>>
    %u_intr_enable0.qe, %u_intr_enable0.q, %u_intr_enable0.ds, %u_intr_enable0.qs = hw.instance "u_intr_enable0" @prim_subreg(clk_i: %2: i1, rst_ni: %3: i1, we: %28: i1, wd: %92: i1, de: %false: i1, d: %false: i1) -> (qe: i1, q: i1, ds: i1, qs: i1)
    llhd.drv %31, %u_intr_enable0.q after %1 : !hw.inout<i1>
    llhd.drv %intr_enable0_qs, %u_intr_enable0.qs after %1 : !hw.inout<i1>
    %32 = llhd.prb %intr_state0_we : !hw.inout<i1>
    %intr_state0 = hw.struct_extract %hw2reg["intr_state0"] : !hw.struct<intr_state0: !hw.array<1xstruct<d: i1, de: i1>>, timer_v_lower0: !hw.struct<d: i32, de: i1>, timer_v_upper0: !hw.struct<d: i32, de: i1>>
    %33 = hw.array_get %intr_state0[%c0_i0] : !hw.array<1xstruct<d: i1, de: i1>>, i0
    %de = hw.struct_extract %33["de"] : !hw.struct<d: i1, de: i1>
    %d = hw.struct_extract %33["d"] : !hw.struct<d: i1, de: i1>
    %34 = llhd.sig.struct_extract %reg2hw["intr_state0"] : !hw.inout<struct<alert_test: !hw.struct<q: i1, qe: i1>, ctrl: !hw.array<1xstruct<q: i1>>, intr_enable0: !hw.array<1xstruct<q: i1>>, intr_state0: !hw.array<1xstruct<q: i1>>, intr_test0: !hw.array<1xstruct<q: i1, qe: i1>>, cfg0: !hw.struct<step: !hw.struct<q: i8>, prescale: !hw.struct<q: i12>>, timer_v_lower0: !hw.struct<q: i32>, timer_v_upper0: !hw.struct<q: i32>, compare_lower0_0: !hw.struct<q: i32, qe: i1>, compare_upper0_0: !hw.struct<q: i32, qe: i1>>>
    %35 = llhd.sig.array_get %34[%c0_i0] : !hw.inout<array<1xstruct<q: i1>>>
    %36 = llhd.sig.struct_extract %35["q"] : !hw.inout<struct<q: i1>>
    %u_intr_state0.qe, %u_intr_state0.q, %u_intr_state0.ds, %u_intr_state0.qs = hw.instance "u_intr_state0" @prim_subreg_0(clk_i: %2: i1, rst_ni: %3: i1, we: %32: i1, wd: %92: i1, de: %de: i1, d: %d: i1) -> (qe: i1, q: i1, ds: i1, qs: i1)
    llhd.drv %36, %u_intr_state0.q after %1 : !hw.inout<i1>
    llhd.drv %intr_state0_qs, %u_intr_state0.qs after %1 : !hw.inout<i1>
    %intr_test0_flds_we = llhd.sig %false : i1
    %37 = llhd.prb %intr_test0_flds_we {sv.namehint = "intr_test0_qe"} : !hw.inout<i1>
    %38 = llhd.prb %intr_test0_we : !hw.inout<i1>
    %39 = llhd.sig.struct_extract %reg2hw["intr_test0"] : !hw.inout<struct<alert_test: !hw.struct<q: i1, qe: i1>, ctrl: !hw.array<1xstruct<q: i1>>, intr_enable0: !hw.array<1xstruct<q: i1>>, intr_state0: !hw.array<1xstruct<q: i1>>, intr_test0: !hw.array<1xstruct<q: i1, qe: i1>>, cfg0: !hw.struct<step: !hw.struct<q: i8>, prescale: !hw.struct<q: i12>>, timer_v_lower0: !hw.struct<q: i32>, timer_v_upper0: !hw.struct<q: i32>, compare_lower0_0: !hw.struct<q: i32, qe: i1>, compare_upper0_0: !hw.struct<q: i32, qe: i1>>>
    %40 = llhd.sig.array_get %39[%c0_i0] : !hw.inout<array<1xstruct<q: i1, qe: i1>>>
    %41 = llhd.sig.struct_extract %40["q"] : !hw.inout<struct<q: i1, qe: i1>>
    %u_intr_test0.qe, %u_intr_test0.qre, %u_intr_test0.q, %u_intr_test0.ds, %u_intr_test0.qs = hw.instance "u_intr_test0" @prim_subreg_ext(re: %false: i1, we: %38: i1, wd: %92: i1, d: %false: i1) -> (qe: i1, qre: i1, q: i1, ds: i1, qs: i1)
    llhd.drv %intr_test0_flds_we, %u_intr_test0.qe after %1 : !hw.inout<i1>
    llhd.drv %41, %u_intr_test0.q after %1 : !hw.inout<i1>
    %42 = llhd.sig.struct_extract %40["qe"] : !hw.inout<struct<q: i1, qe: i1>>
    llhd.drv %42, %37 after %1 : !hw.inout<i1>
    %43 = llhd.prb %cfg0_we : !hw.inout<i1>
    %44 = llhd.sig.struct_extract %reg2hw["cfg0"] : !hw.inout<struct<alert_test: !hw.struct<q: i1, qe: i1>, ctrl: !hw.array<1xstruct<q: i1>>, intr_enable0: !hw.array<1xstruct<q: i1>>, intr_state0: !hw.array<1xstruct<q: i1>>, intr_test0: !hw.array<1xstruct<q: i1, qe: i1>>, cfg0: !hw.struct<step: !hw.struct<q: i8>, prescale: !hw.struct<q: i12>>, timer_v_lower0: !hw.struct<q: i32>, timer_v_upper0: !hw.struct<q: i32>, compare_lower0_0: !hw.struct<q: i32, qe: i1>, compare_upper0_0: !hw.struct<q: i32, qe: i1>>>
    %45 = llhd.sig.struct_extract %44["prescale"] : !hw.inout<struct<step: !hw.struct<q: i8>, prescale: !hw.struct<q: i12>>>
    %46 = llhd.sig.struct_extract %45["q"] : !hw.inout<struct<q: i12>>
    %u_cfg0_prescale.qe, %u_cfg0_prescale.q, %u_cfg0_prescale.ds, %u_cfg0_prescale.qs = hw.instance "u_cfg0_prescale" @prim_subreg_1(clk_i: %2: i1, rst_ni: %3: i1, we: %43: i1, wd: %103: i12, de: %false: i1, d: %c0_i12: i12) -> (qe: i1, q: i12, ds: i12, qs: i12)
    llhd.drv %46, %u_cfg0_prescale.q after %1 : !hw.inout<i12>
    llhd.drv %cfg0_prescale_qs, %u_cfg0_prescale.qs after %1 : !hw.inout<i12>
    %47 = llhd.sig.struct_extract %44["step"] : !hw.inout<struct<step: !hw.struct<q: i8>, prescale: !hw.struct<q: i12>>>
    %48 = llhd.sig.struct_extract %47["q"] : !hw.inout<struct<q: i8>>
    %u_cfg0_step.qe, %u_cfg0_step.q, %u_cfg0_step.ds, %u_cfg0_step.qs = hw.instance "u_cfg0_step" @prim_subreg_2(clk_i: %2: i1, rst_ni: %3: i1, we: %43: i1, wd: %104: i8, de: %false: i1, d: %c0_i8: i8) -> (qe: i1, q: i8, ds: i8, qs: i8)
    llhd.drv %48, %u_cfg0_step.q after %1 : !hw.inout<i8>
    llhd.drv %cfg0_step_qs, %u_cfg0_step.qs after %1 : !hw.inout<i8>
    %49 = llhd.prb %timer_v_lower0_we : !hw.inout<i1>
    %timer_v_lower0 = hw.struct_extract %hw2reg["timer_v_lower0"] : !hw.struct<intr_state0: !hw.array<1xstruct<d: i1, de: i1>>, timer_v_lower0: !hw.struct<d: i32, de: i1>, timer_v_upper0: !hw.struct<d: i32, de: i1>>
    %de_3 = hw.struct_extract %timer_v_lower0["de"] : !hw.struct<d: i32, de: i1>
    %d_4 = hw.struct_extract %timer_v_lower0["d"] : !hw.struct<d: i32, de: i1>
    %50 = llhd.sig.struct_extract %reg2hw["timer_v_lower0"] : !hw.inout<struct<alert_test: !hw.struct<q: i1, qe: i1>, ctrl: !hw.array<1xstruct<q: i1>>, intr_enable0: !hw.array<1xstruct<q: i1>>, intr_state0: !hw.array<1xstruct<q: i1>>, intr_test0: !hw.array<1xstruct<q: i1, qe: i1>>, cfg0: !hw.struct<step: !hw.struct<q: i8>, prescale: !hw.struct<q: i12>>, timer_v_lower0: !hw.struct<q: i32>, timer_v_upper0: !hw.struct<q: i32>, compare_lower0_0: !hw.struct<q: i32, qe: i1>, compare_upper0_0: !hw.struct<q: i32, qe: i1>>>
    %51 = llhd.sig.struct_extract %50["q"] : !hw.inout<struct<q: i32>>
    %u_timer_v_lower0.qe, %u_timer_v_lower0.q, %u_timer_v_lower0.ds, %u_timer_v_lower0.qs = hw.instance "u_timer_v_lower0" @prim_subreg_3(clk_i: %2: i1, rst_ni: %3: i1, we: %49: i1, wd: %u_reg_if.wdata_o: i32, de: %de_3: i1, d: %d_4: i32) -> (qe: i1, q: i32, ds: i32, qs: i32)
    llhd.drv %51, %u_timer_v_lower0.q after %1 : !hw.inout<i32>
    llhd.drv %timer_v_lower0_qs, %u_timer_v_lower0.qs after %1 : !hw.inout<i32>
    %52 = llhd.prb %timer_v_upper0_we : !hw.inout<i1>
    %timer_v_upper0 = hw.struct_extract %hw2reg["timer_v_upper0"] : !hw.struct<intr_state0: !hw.array<1xstruct<d: i1, de: i1>>, timer_v_lower0: !hw.struct<d: i32, de: i1>, timer_v_upper0: !hw.struct<d: i32, de: i1>>
    %de_5 = hw.struct_extract %timer_v_upper0["de"] : !hw.struct<d: i32, de: i1>
    %d_6 = hw.struct_extract %timer_v_upper0["d"] : !hw.struct<d: i32, de: i1>
    %53 = llhd.sig.struct_extract %reg2hw["timer_v_upper0"] : !hw.inout<struct<alert_test: !hw.struct<q: i1, qe: i1>, ctrl: !hw.array<1xstruct<q: i1>>, intr_enable0: !hw.array<1xstruct<q: i1>>, intr_state0: !hw.array<1xstruct<q: i1>>, intr_test0: !hw.array<1xstruct<q: i1, qe: i1>>, cfg0: !hw.struct<step: !hw.struct<q: i8>, prescale: !hw.struct<q: i12>>, timer_v_lower0: !hw.struct<q: i32>, timer_v_upper0: !hw.struct<q: i32>, compare_lower0_0: !hw.struct<q: i32, qe: i1>, compare_upper0_0: !hw.struct<q: i32, qe: i1>>>
    %54 = llhd.sig.struct_extract %53["q"] : !hw.inout<struct<q: i32>>
    %u_timer_v_upper0.qe, %u_timer_v_upper0.q, %u_timer_v_upper0.ds, %u_timer_v_upper0.qs = hw.instance "u_timer_v_upper0" @prim_subreg_3(clk_i: %2: i1, rst_ni: %3: i1, we: %52: i1, wd: %u_reg_if.wdata_o: i32, de: %de_5: i1, d: %d_6: i32) -> (qe: i1, q: i32, ds: i32, qs: i32)
    llhd.drv %54, %u_timer_v_upper0.q after %1 : !hw.inout<i32>
    llhd.drv %timer_v_upper0_qs, %u_timer_v_upper0.qs after %1 : !hw.inout<i32>
    %compare_lower0_0_flds_we = llhd.sig %false : i1
    %55 = llhd.prb %compare_lower0_0_flds_we : !hw.inout<i1>
    %u_compare_lower0_00_qe.q_o = hw.instance "u_compare_lower0_00_qe" @prim_flop(clk_i: %2: i1, rst_ni: %3: i1, d_i: %55: i1) -> (q_o: i1) {sv.namehint = "compare_lower0_0_qe"}
    %56 = llhd.prb %compare_lower0_0_we : !hw.inout<i1>
    %57 = llhd.sig.struct_extract %reg2hw["compare_lower0_0"] : !hw.inout<struct<alert_test: !hw.struct<q: i1, qe: i1>, ctrl: !hw.array<1xstruct<q: i1>>, intr_enable0: !hw.array<1xstruct<q: i1>>, intr_state0: !hw.array<1xstruct<q: i1>>, intr_test0: !hw.array<1xstruct<q: i1, qe: i1>>, cfg0: !hw.struct<step: !hw.struct<q: i8>, prescale: !hw.struct<q: i12>>, timer_v_lower0: !hw.struct<q: i32>, timer_v_upper0: !hw.struct<q: i32>, compare_lower0_0: !hw.struct<q: i32, qe: i1>, compare_upper0_0: !hw.struct<q: i32, qe: i1>>>
    %58 = llhd.sig.struct_extract %57["q"] : !hw.inout<struct<q: i32, qe: i1>>
    %u_compare_lower0_0.qe, %u_compare_lower0_0.q, %u_compare_lower0_0.ds, %u_compare_lower0_0.qs = hw.instance "u_compare_lower0_0" @prim_subreg_4(clk_i: %2: i1, rst_ni: %3: i1, we: %56: i1, wd: %u_reg_if.wdata_o: i32, de: %false: i1, d: %c0_i32: i32) -> (qe: i1, q: i32, ds: i32, qs: i32)
    llhd.drv %compare_lower0_0_flds_we, %u_compare_lower0_0.qe after %1 : !hw.inout<i1>
    llhd.drv %58, %u_compare_lower0_0.q after %1 : !hw.inout<i32>
    llhd.drv %compare_lower0_0_qs, %u_compare_lower0_0.qs after %1 : !hw.inout<i32>
    %59 = llhd.sig.struct_extract %57["qe"] : !hw.inout<struct<q: i32, qe: i1>>
    llhd.drv %59, %u_compare_lower0_00_qe.q_o after %1 : !hw.inout<i1>
    %compare_upper0_0_flds_we = llhd.sig %false : i1
    %60 = llhd.prb %compare_upper0_0_flds_we : !hw.inout<i1>
    %u_compare_upper0_00_qe.q_o = hw.instance "u_compare_upper0_00_qe" @prim_flop(clk_i: %2: i1, rst_ni: %3: i1, d_i: %60: i1) -> (q_o: i1) {sv.namehint = "compare_upper0_0_qe"}
    %61 = llhd.prb %compare_upper0_0_we : !hw.inout<i1>
    %62 = llhd.sig.struct_extract %reg2hw["compare_upper0_0"] : !hw.inout<struct<alert_test: !hw.struct<q: i1, qe: i1>, ctrl: !hw.array<1xstruct<q: i1>>, intr_enable0: !hw.array<1xstruct<q: i1>>, intr_state0: !hw.array<1xstruct<q: i1>>, intr_test0: !hw.array<1xstruct<q: i1, qe: i1>>, cfg0: !hw.struct<step: !hw.struct<q: i8>, prescale: !hw.struct<q: i12>>, timer_v_lower0: !hw.struct<q: i32>, timer_v_upper0: !hw.struct<q: i32>, compare_lower0_0: !hw.struct<q: i32, qe: i1>, compare_upper0_0: !hw.struct<q: i32, qe: i1>>>
    %63 = llhd.sig.struct_extract %62["q"] : !hw.inout<struct<q: i32, qe: i1>>
    %u_compare_upper0_0.qe, %u_compare_upper0_0.q, %u_compare_upper0_0.ds, %u_compare_upper0_0.qs = hw.instance "u_compare_upper0_0" @prim_subreg_4(clk_i: %2: i1, rst_ni: %3: i1, we: %61: i1, wd: %u_reg_if.wdata_o: i32, de: %false: i1, d: %c0_i32: i32) -> (qe: i1, q: i32, ds: i32, qs: i32)
    llhd.drv %compare_upper0_0_flds_we, %u_compare_upper0_0.qe after %1 : !hw.inout<i1>
    llhd.drv %63, %u_compare_upper0_0.q after %1 : !hw.inout<i32>
    llhd.drv %compare_upper0_0_qs, %u_compare_upper0_0.qs after %1 : !hw.inout<i32>
    %64 = llhd.sig.struct_extract %62["qe"] : !hw.inout<struct<q: i32, qe: i1>>
    llhd.drv %64, %u_compare_upper0_00_qe.q_o after %1 : !hw.inout<i1>
    %addr_hit = llhd.sig %c0_i10 : i10
    %racl_role_vec = llhd.sig %c0_i2 : i2
    %racl_addr_hit_read = llhd.sig %c0_i10 : i10
    %racl_addr_hit_write = llhd.sig %c0_i10 : i10
    llhd.drv %racl_role_vec, %c0_i2 after %1 : !hw.inout<i2>
    %65 = llhd.prb %racl_addr_hit_read : !hw.inout<i10>
    %66 = llhd.prb %racl_addr_hit_write : !hw.inout<i10>
    %67 = llhd.prb %addr_hit : !hw.inout<i10>
    %68 = llhd.prb %reg_addr : !hw.inout<i9>
    %69 = llhd.prb %racl_policies_i_2 : !hw.inout<array<1xstruct<write_perm: i2, read_perm: i2>>>
    %70 = llhd.prb %racl_role_vec : !hw.inout<i2>
    llhd.process {
      cf.br ^bb1
    ^bb1:  // 2 preds: ^bb0, ^bb1
      llhd.drv %racl_addr_hit_read, %c0_i10 after %1 : !hw.inout<i10>
      llhd.drv %racl_addr_hit_write, %c0_i10 after %1 : !hw.inout<i10>
      %123 = llhd.sig.extract %addr_hit from %c0_i4 : (!hw.inout<i10>) -> !hw.inout<i1>
      %124 = llhd.prb %reg_addr : !hw.inout<i9>
      %125 = comb.icmp eq %124, %c0_i9 : i9
      llhd.drv %123, %125 after %1 : !hw.inout<i1>
      %126 = llhd.sig.extract %addr_hit from %c1_i4 : (!hw.inout<i10>) -> !hw.inout<i1>
      %127 = llhd.prb %reg_addr : !hw.inout<i9>
      %128 = comb.icmp eq %127, %c4_i9 : i9
      llhd.drv %126, %128 after %1 : !hw.inout<i1>
      %129 = llhd.sig.extract %addr_hit from %c2_i4 : (!hw.inout<i10>) -> !hw.inout<i1>
      %130 = llhd.prb %reg_addr : !hw.inout<i9>
      %131 = comb.icmp eq %130, %c-256_i9 : i9
      llhd.drv %129, %131 after %1 : !hw.inout<i1>
      %132 = llhd.sig.extract %addr_hit from %c3_i4 : (!hw.inout<i10>) -> !hw.inout<i1>
      %133 = llhd.prb %reg_addr : !hw.inout<i9>
      %134 = comb.icmp eq %133, %c-252_i9 : i9
      llhd.drv %132, %134 after %1 : !hw.inout<i1>
      %135 = llhd.sig.extract %addr_hit from %c4_i4 : (!hw.inout<i10>) -> !hw.inout<i1>
      %136 = llhd.prb %reg_addr : !hw.inout<i9>
      %137 = comb.icmp eq %136, %c-248_i9 : i9
      llhd.drv %135, %137 after %1 : !hw.inout<i1>
      %138 = llhd.sig.extract %addr_hit from %c5_i4 : (!hw.inout<i10>) -> !hw.inout<i1>
      %139 = llhd.prb %reg_addr : !hw.inout<i9>
      %140 = comb.icmp eq %139, %c-244_i9 : i9
      llhd.drv %138, %140 after %1 : !hw.inout<i1>
      %141 = llhd.sig.extract %addr_hit from %c6_i4 : (!hw.inout<i10>) -> !hw.inout<i1>
      %142 = llhd.prb %reg_addr : !hw.inout<i9>
      %143 = comb.icmp eq %142, %c-240_i9 : i9
      llhd.drv %141, %143 after %1 : !hw.inout<i1>
      %144 = llhd.sig.extract %addr_hit from %c7_i4 : (!hw.inout<i10>) -> !hw.inout<i1>
      %145 = llhd.prb %reg_addr : !hw.inout<i9>
      %146 = comb.icmp eq %145, %c-236_i9 : i9
      llhd.drv %144, %146 after %1 : !hw.inout<i1>
      %147 = llhd.sig.extract %addr_hit from %c-8_i4 : (!hw.inout<i10>) -> !hw.inout<i1>
      %148 = llhd.prb %reg_addr : !hw.inout<i9>
      %149 = comb.icmp eq %148, %c-232_i9 : i9
      llhd.drv %147, %149 after %1 : !hw.inout<i1>
      %150 = llhd.sig.extract %addr_hit from %c-7_i4 : (!hw.inout<i10>) -> !hw.inout<i1>
      %151 = llhd.prb %reg_addr : !hw.inout<i9>
      %152 = comb.icmp eq %151, %c-228_i9 : i9
      llhd.drv %150, %152 after %1 : !hw.inout<i1>
      %153 = llhd.prb %addr_hit : !hw.inout<i10>
      llhd.drv %racl_addr_hit_read, %153 after %1 : !hw.inout<i10>
      %154 = llhd.prb %addr_hit : !hw.inout<i10>
      llhd.drv %racl_addr_hit_write, %154 after %1 : !hw.inout<i10>
      llhd.wait (%65, %66, %67, %68, %69, %70 : i10, i10, i10, i9, !hw.array<1xstruct<write_perm: i2, read_perm: i2>>, i2), ^bb1
    }
    %71 = comb.or %u_reg_if.re_o, %8 : i1
    %72 = comb.icmp ne %67, %c0_i10 : i10
    %73 = comb.xor %72, %true : i1
    %74 = comb.and %71, %73 {sv.namehint = "addrmiss"} : i1
    %75 = llhd.sig.struct_extract %racl_error_o["valid"] : !hw.inout<struct<valid: i1, overflow: i1, racl_role: i1, ctn_uid: i1, read_access: i1, request_address: i32>>
    %76 = comb.icmp eq %65, %c0_i10 : i10
    %77 = comb.and %u_reg_if.re_o, %76 : i1
    %78 = comb.icmp eq %66, %c0_i10 : i10
    %79 = comb.and %8, %78 : i1
    %80 = comb.or %77, %79 : i1
    %81 = comb.and %72, %80 : i1
    llhd.drv %75, %81 after %1 : !hw.inout<i1>
    %82 = llhd.sig.struct_extract %racl_error_o["request_address"] : !hw.inout<struct<valid: i1, overflow: i1, racl_role: i1, ctn_uid: i1, read_access: i1, request_address: i32>>
    %83 = comb.concat %c0_i23, %68 : i23, i9
    llhd.drv %82, %83 after %1 : !hw.inout<i32>
    %84 = llhd.sig.struct_extract %racl_error_o["racl_role"] : !hw.inout<struct<valid: i1, overflow: i1, racl_role: i1, ctn_uid: i1, read_access: i1, request_address: i32>>
    llhd.drv %84, %false after %1 : !hw.inout<i1>
    %85 = llhd.sig.struct_extract %racl_error_o["overflow"] : !hw.inout<struct<valid: i1, overflow: i1, racl_role: i1, ctn_uid: i1, read_access: i1, request_address: i32>>
    llhd.drv %85, %false after %1 : !hw.inout<i1>
    %86 = llhd.sig.struct_extract %racl_error_o["ctn_uid"] : !hw.inout<struct<valid: i1, overflow: i1, racl_role: i1, ctn_uid: i1, read_access: i1, request_address: i32>>
    llhd.drv %86, %false after %1 : !hw.inout<i1>
    %87 = llhd.sig.struct_extract %racl_error_o["read_access"] : !hw.inout<struct<valid: i1, overflow: i1, racl_role: i1, ctn_uid: i1, read_access: i1, request_address: i32>>
    llhd.drv %87, %false after %1 : !hw.inout<i1>
    %88 = llhd.prb %reg_be : !hw.inout<i4>
    llhd.process {
      cf.br ^bb1
    ^bb1:  // 2 preds: ^bb0, ^bb1
      %123 = llhd.prb %reg_we : !hw.inout<i1>
      %124 = llhd.prb %racl_addr_hit_write : !hw.inout<i10>
      %125 = comb.extract %124 from 0 : (i10) -> i1
      %126 = llhd.prb %reg_be : !hw.inout<i4>
      %127 = comb.extract %126 from 0 : (i4) -> i3
      %128 = comb.extract %126 from 0 : (i4) -> i1
      %129 = comb.xor %128, %true : i1
      %130 = comb.and %125, %129 : i1
      %131 = comb.extract %124 from 1 : (i10) -> i1
      %132 = comb.and %131, %129 : i1
      %133 = comb.extract %124 from 2 : (i10) -> i1
      %134 = comb.and %133, %129 : i1
      %135 = comb.extract %124 from 3 : (i10) -> i1
      %136 = comb.and %135, %129 : i1
      %137 = comb.extract %124 from 4 : (i10) -> i1
      %138 = comb.and %137, %129 : i1
      %139 = comb.extract %124 from 5 : (i10) -> i1
      %140 = comb.icmp ne %127, %c-1_i3 : i3
      %141 = comb.and %139, %140 : i1
      %142 = comb.extract %124 from 6 : (i10) -> i1
      %143 = comb.icmp ne %126, %c-1_i4 : i4
      %144 = comb.and %142, %143 : i1
      %145 = comb.extract %124 from 7 : (i10) -> i1
      %146 = comb.icmp ne %126, %c-1_i4 : i4
      %147 = comb.and %145, %146 : i1
      %148 = comb.extract %124 from 8 : (i10) -> i1
      %149 = comb.icmp ne %126, %c-1_i4 : i4
      %150 = comb.and %148, %149 : i1
      %151 = comb.extract %124 from 9 : (i10) -> i1
      %152 = comb.icmp ne %126, %c-1_i4 : i4
      %153 = comb.and %151, %152 : i1
      %154 = comb.or %130, %132, %134, %136, %138, %141, %144, %147, %150, %153 : i1
      %155 = comb.and %123, %154 : i1
      llhd.drv %wr_err, %155 after %1 : !hw.inout<i1>
      llhd.wait (%8, %66, %88, %17 : i1, i10, i4, i1), ^bb1
    }
    %89 = comb.extract %66 from 0 : (i10) -> i1
    %90 = comb.xor %18, %true : i1
    %91 = comb.and %89, %8, %90 : i1
    llhd.drv %alert_test_we, %91 after %1 : !hw.inout<i1>
    %92 = comb.extract %u_reg_if.wdata_o from 0 {sv.namehint = "ctrl_wd"} : (i32) -> i1
    %93 = comb.extract %66 from 1 : (i10) -> i1
    %94 = comb.and %93, %8, %90 : i1
    llhd.drv %ctrl_we, %94 after %1 : !hw.inout<i1>
    %95 = comb.extract %66 from 2 : (i10) -> i1
    %96 = comb.and %95, %8, %90 : i1
    llhd.drv %intr_enable0_we, %96 after %1 : !hw.inout<i1>
    %97 = comb.extract %66 from 3 : (i10) -> i1
    %98 = comb.and %97, %8, %90 : i1
    llhd.drv %intr_state0_we, %98 after %1 : !hw.inout<i1>
    %99 = comb.extract %66 from 4 : (i10) -> i1
    %100 = comb.and %99, %8, %90 : i1
    llhd.drv %intr_test0_we, %100 after %1 : !hw.inout<i1>
    %101 = comb.extract %66 from 5 : (i10) -> i1
    %102 = comb.and %101, %8, %90 : i1
    llhd.drv %cfg0_we, %102 after %1 : !hw.inout<i1>
    %103 = comb.extract %u_reg_if.wdata_o from 0 {sv.namehint = "cfg0_prescale_wd"} : (i32) -> i12
    %104 = comb.extract %u_reg_if.wdata_o from 16 {sv.namehint = "cfg0_step_wd"} : (i32) -> i8
    %105 = comb.extract %66 from 6 : (i10) -> i1
    %106 = comb.and %105, %8, %90 : i1
    llhd.drv %timer_v_lower0_we, %106 after %1 : !hw.inout<i1>
    %107 = comb.extract %66 from 7 : (i10) -> i1
    %108 = comb.and %107, %8, %90 : i1
    llhd.drv %timer_v_upper0_we, %108 after %1 : !hw.inout<i1>
    %109 = comb.extract %66 from 8 : (i10) -> i1
    %110 = comb.and %109, %8, %90 : i1
    llhd.drv %compare_lower0_0_we, %110 after %1 : !hw.inout<i1>
    %111 = comb.extract %66 from 9 : (i10) -> i1
    %112 = comb.and %111, %8, %90 : i1
    llhd.drv %compare_upper0_0_we, %112 after %1 : !hw.inout<i1>
    llhd.process {
      cf.br ^bb1
    ^bb1:  // 2 preds: ^bb0, ^bb1
      %123 = llhd.sig.extract %reg_we_check from %c0_i4 : (!hw.inout<i10>) -> !hw.inout<i1>
      %124 = llhd.prb %alert_test_we : !hw.inout<i1>
      llhd.drv %123, %124 after %1 : !hw.inout<i1>
      %125 = llhd.sig.extract %reg_we_check from %c1_i4 : (!hw.inout<i10>) -> !hw.inout<i1>
      %126 = llhd.prb %ctrl_we : !hw.inout<i1>
      llhd.drv %125, %126 after %1 : !hw.inout<i1>
      %127 = llhd.sig.extract %reg_we_check from %c2_i4 : (!hw.inout<i10>) -> !hw.inout<i1>
      %128 = llhd.prb %intr_enable0_we : !hw.inout<i1>
      llhd.drv %127, %128 after %1 : !hw.inout<i1>
      %129 = llhd.sig.extract %reg_we_check from %c3_i4 : (!hw.inout<i10>) -> !hw.inout<i1>
      %130 = llhd.prb %intr_state0_we : !hw.inout<i1>
      llhd.drv %129, %130 after %1 : !hw.inout<i1>
      %131 = llhd.sig.extract %reg_we_check from %c4_i4 : (!hw.inout<i10>) -> !hw.inout<i1>
      %132 = llhd.prb %intr_test0_we : !hw.inout<i1>
      llhd.drv %131, %132 after %1 : !hw.inout<i1>
      %133 = llhd.sig.extract %reg_we_check from %c5_i4 : (!hw.inout<i10>) -> !hw.inout<i1>
      %134 = llhd.prb %cfg0_we : !hw.inout<i1>
      llhd.drv %133, %134 after %1 : !hw.inout<i1>
      %135 = llhd.sig.extract %reg_we_check from %c6_i4 : (!hw.inout<i10>) -> !hw.inout<i1>
      %136 = llhd.prb %timer_v_lower0_we : !hw.inout<i1>
      llhd.drv %135, %136 after %1 : !hw.inout<i1>
      %137 = llhd.sig.extract %reg_we_check from %c7_i4 : (!hw.inout<i10>) -> !hw.inout<i1>
      %138 = llhd.prb %timer_v_upper0_we : !hw.inout<i1>
      llhd.drv %137, %138 after %1 : !hw.inout<i1>
      %139 = llhd.sig.extract %reg_we_check from %c-8_i4 : (!hw.inout<i10>) -> !hw.inout<i1>
      %140 = llhd.prb %compare_lower0_0_we : !hw.inout<i1>
      llhd.drv %139, %140 after %1 : !hw.inout<i1>
      %141 = llhd.sig.extract %reg_we_check from %c-7_i4 : (!hw.inout<i10>) -> !hw.inout<i1>
      %142 = llhd.prb %compare_upper0_0_we : !hw.inout<i1>
      llhd.drv %141, %142 after %1 : !hw.inout<i1>
      llhd.wait (%7, %20, %24, %28, %32, %38, %43, %49, %52, %56, %61 : i10, i1, i1, i1, i1, i1, i1, i1, i1, i1, i1), ^bb1
    }
    %113 = llhd.prb %ctrl_qs : !hw.inout<i1>
    %114 = llhd.prb %intr_enable0_qs : !hw.inout<i1>
    %115 = llhd.prb %intr_state0_qs : !hw.inout<i1>
    %116 = llhd.prb %cfg0_prescale_qs : !hw.inout<i12>
    %117 = llhd.prb %cfg0_step_qs : !hw.inout<i8>
    %118 = llhd.prb %timer_v_lower0_qs : !hw.inout<i32>
    %119 = llhd.prb %timer_v_upper0_qs : !hw.inout<i32>
    %120 = llhd.prb %compare_lower0_0_qs : !hw.inout<i32>
    %121 = llhd.prb %compare_upper0_0_qs : !hw.inout<i32>
    llhd.process {
      cf.br ^bb1
    ^bb1:  // 2 preds: ^bb0, ^bb22
      llhd.drv %reg_rdata_next, %c0_i32 after %1 : !hw.inout<i32>
      %123 = llhd.prb %racl_addr_hit_read : !hw.inout<i10>
      %124 = comb.extract %123 from 0 : (i10) -> i1
      %125 = comb.icmp ceq %124, %true : i1
      cf.cond_br %125, ^bb2, ^bb3
    ^bb2:  // pred: ^bb1
      %126 = llhd.sig.extract %reg_rdata_next from %c0_i5 : (!hw.inout<i32>) -> !hw.inout<i1>
      llhd.drv %126, %false after %1 : !hw.inout<i1>
      cf.br ^bb22
    ^bb3:  // pred: ^bb1
      %127 = llhd.prb %racl_addr_hit_read : !hw.inout<i10>
      %128 = comb.extract %127 from 1 : (i10) -> i1
      %129 = comb.icmp ceq %128, %true : i1
      cf.cond_br %129, ^bb4, ^bb5
    ^bb4:  // pred: ^bb3
      %130 = llhd.sig.extract %reg_rdata_next from %c0_i5 : (!hw.inout<i32>) -> !hw.inout<i1>
      %131 = llhd.prb %ctrl_qs : !hw.inout<i1>
      llhd.drv %130, %131 after %1 : !hw.inout<i1>
      cf.br ^bb22
    ^bb5:  // pred: ^bb3
      %132 = llhd.prb %racl_addr_hit_read : !hw.inout<i10>
      %133 = comb.extract %132 from 2 : (i10) -> i1
      %134 = comb.icmp ceq %133, %true : i1
      cf.cond_br %134, ^bb6, ^bb7
    ^bb6:  // pred: ^bb5
      %135 = llhd.sig.extract %reg_rdata_next from %c0_i5 : (!hw.inout<i32>) -> !hw.inout<i1>
      %136 = llhd.prb %intr_enable0_qs : !hw.inout<i1>
      llhd.drv %135, %136 after %1 : !hw.inout<i1>
      cf.br ^bb22
    ^bb7:  // pred: ^bb5
      %137 = llhd.prb %racl_addr_hit_read : !hw.inout<i10>
      %138 = comb.extract %137 from 3 : (i10) -> i1
      %139 = comb.icmp ceq %138, %true : i1
      cf.cond_br %139, ^bb8, ^bb9
    ^bb8:  // pred: ^bb7
      %140 = llhd.sig.extract %reg_rdata_next from %c0_i5 : (!hw.inout<i32>) -> !hw.inout<i1>
      %141 = llhd.prb %intr_state0_qs : !hw.inout<i1>
      llhd.drv %140, %141 after %1 : !hw.inout<i1>
      cf.br ^bb22
    ^bb9:  // pred: ^bb7
      %142 = llhd.prb %racl_addr_hit_read : !hw.inout<i10>
      %143 = comb.extract %142 from 4 : (i10) -> i1
      %144 = comb.icmp ceq %143, %true : i1
      cf.cond_br %144, ^bb10, ^bb11
    ^bb10:  // pred: ^bb9
      %145 = llhd.sig.extract %reg_rdata_next from %c0_i5 : (!hw.inout<i32>) -> !hw.inout<i1>
      llhd.drv %145, %false after %1 : !hw.inout<i1>
      cf.br ^bb22
    ^bb11:  // pred: ^bb9
      %146 = llhd.prb %racl_addr_hit_read : !hw.inout<i10>
      %147 = comb.extract %146 from 5 : (i10) -> i1
      %148 = comb.icmp ceq %147, %true : i1
      cf.cond_br %148, ^bb12, ^bb13
    ^bb12:  // pred: ^bb11
      %149 = llhd.sig.extract %reg_rdata_next from %c0_i5 : (!hw.inout<i32>) -> !hw.inout<i12>
      %150 = llhd.prb %cfg0_prescale_qs : !hw.inout<i12>
      llhd.drv %149, %150 after %1 : !hw.inout<i12>
      %151 = llhd.sig.extract %reg_rdata_next from %c-16_i5 : (!hw.inout<i32>) -> !hw.inout<i8>
      %152 = llhd.prb %cfg0_step_qs : !hw.inout<i8>
      llhd.drv %151, %152 after %1 : !hw.inout<i8>
      cf.br ^bb22
    ^bb13:  // pred: ^bb11
      %153 = llhd.prb %racl_addr_hit_read : !hw.inout<i10>
      %154 = comb.extract %153 from 6 : (i10) -> i1
      %155 = comb.icmp ceq %154, %true : i1
      cf.cond_br %155, ^bb14, ^bb15
    ^bb14:  // pred: ^bb13
      %156 = llhd.prb %timer_v_lower0_qs : !hw.inout<i32>
      llhd.drv %reg_rdata_next, %156 after %1 : !hw.inout<i32>
      cf.br ^bb22
    ^bb15:  // pred: ^bb13
      %157 = llhd.prb %racl_addr_hit_read : !hw.inout<i10>
      %158 = comb.extract %157 from 7 : (i10) -> i1
      %159 = comb.icmp ceq %158, %true : i1
      cf.cond_br %159, ^bb16, ^bb17
    ^bb16:  // pred: ^bb15
      %160 = llhd.prb %timer_v_upper0_qs : !hw.inout<i32>
      llhd.drv %reg_rdata_next, %160 after %1 : !hw.inout<i32>
      cf.br ^bb22
    ^bb17:  // pred: ^bb15
      %161 = llhd.prb %racl_addr_hit_read : !hw.inout<i10>
      %162 = comb.extract %161 from 8 : (i10) -> i1
      %163 = comb.icmp ceq %162, %true : i1
      cf.cond_br %163, ^bb18, ^bb19
    ^bb18:  // pred: ^bb17
      %164 = llhd.prb %compare_lower0_0_qs : !hw.inout<i32>
      llhd.drv %reg_rdata_next, %164 after %1 : !hw.inout<i32>
      cf.br ^bb22
    ^bb19:  // pred: ^bb17
      %165 = llhd.prb %racl_addr_hit_read : !hw.inout<i10>
      %166 = comb.extract %165 from 9 : (i10) -> i1
      %167 = comb.icmp ceq %166, %true : i1
      cf.cond_br %167, ^bb20, ^bb21
    ^bb20:  // pred: ^bb19
      %168 = llhd.prb %compare_upper0_0_qs : !hw.inout<i32>
      llhd.drv %reg_rdata_next, %168 after %1 : !hw.inout<i32>
      cf.br ^bb22
    ^bb21:  // pred: ^bb19
      llhd.drv %reg_rdata_next, %c-1_i32 after %1 : !hw.inout<i32>
      cf.br ^bb22
    ^bb22:  // 11 preds: ^bb2, ^bb4, ^bb6, ^bb8, ^bb10, ^bb12, ^bb14, ^bb16, ^bb18, ^bb20, ^bb21
      llhd.wait (%16, %65, %113, %114, %115, %116, %117, %118, %119, %120, %121 : i32, i10, i1, i1, i1, i12, i8, i32, i32, i32, i32), ^bb1
    }
    llhd.drv %clk_i_0, %clk_i after %1 : !hw.inout<i1>
    llhd.drv %rst_ni_1, %rst_ni after %1 : !hw.inout<i1>
    %122 = llhd.prb %reg2hw : !hw.inout<struct<alert_test: !hw.struct<q: i1, qe: i1>, ctrl: !hw.array<1xstruct<q: i1>>, intr_enable0: !hw.array<1xstruct<q: i1>>, intr_state0: !hw.array<1xstruct<q: i1>>, intr_test0: !hw.array<1xstruct<q: i1, qe: i1>>, cfg0: !hw.struct<step: !hw.struct<q: i8>, prescale: !hw.struct<q: i12>>, timer_v_lower0: !hw.struct<q: i32>, timer_v_upper0: !hw.struct<q: i32>, compare_lower0_0: !hw.struct<q: i32, qe: i1>, compare_upper0_0: !hw.struct<q: i32, qe: i1>>>
    llhd.drv %racl_policies_i_2, %racl_policies_i after %1 : !hw.inout<array<1xstruct<write_perm: i2, read_perm: i2>>>
    hw.output %u_rsp_intg_gen.tl_o, %122, %15, %14 : !hw.struct<d_valid: i1, d_opcode: i3, d_param: i3, d_size: i2, d_source: i8, d_sink: i1, d_data: i32, d_user: !hw.struct<rsp_intg: i7, data_intg: i7>, d_error: i1, a_ready: i1>, !hw.struct<alert_test: !hw.struct<q: i1, qe: i1>, ctrl: !hw.array<1xstruct<q: i1>>, intr_enable0: !hw.array<1xstruct<q: i1>>, intr_state0: !hw.array<1xstruct<q: i1>>, intr_test0: !hw.array<1xstruct<q: i1, qe: i1>>, cfg0: !hw.struct<step: !hw.struct<q: i8>, prescale: !hw.struct<q: i12>>, timer_v_lower0: !hw.struct<q: i32>, timer_v_upper0: !hw.struct<q: i32>, compare_lower0_0: !hw.struct<q: i32, qe: i1>, compare_upper0_0: !hw.struct<q: i32, qe: i1>>, !hw.struct<valid: i1, overflow: i1, racl_role: i1, ctn_uid: i1, read_access: i1, request_address: i32>, i1
  }
  hw.module @rv_timer(in %clk_i : i1, in %rst_ni : i1, in %tl_i : !hw.struct<a_valid: i1, a_opcode: i3, a_param: i3, a_size: i2, a_source: i8, a_address: i32, a_mask: i4, a_data: i32, a_user: !hw.struct<rsvd: i5, instr_type: i4, cmd_intg: i7, data_intg: i7>, d_ready: i1>, out tl_o : !hw.struct<d_valid: i1, d_opcode: i3, d_param: i3, d_size: i2, d_source: i8, d_sink: i1, d_data: i32, d_user: !hw.struct<rsp_intg: i7, data_intg: i7>, d_error: i1, a_ready: i1>, in %alert_rx_i : !hw.array<1xstruct<ping_p: i1, ping_n: i1, ack_p: i1, ack_n: i1>>, out alert_tx_o : !hw.array<1xstruct<alert_p: i1, alert_n: i1>>, in %racl_policies_i : !hw.array<1xstruct<write_perm: i2, read_perm: i2>>, out racl_error_o : !hw.struct<valid: i1, overflow: i1, racl_role: i1, ctn_uid: i1, read_access: i1, request_address: i32>, out intr_timer_expired_hart0_timer0_o : i1) {
    %true = hw.constant true
    %0 = llhd.constant_time <0ns, 0d, 1e>
    %c0_i0 = hw.constant 0 : i0
    %c0_i64 = hw.constant 0 : i64
    %false = hw.constant false
    %c0_i68 = hw.constant 0 : i68
    %c0_i2 = hw.constant 0 : i2
    %1 = hw.bitcast %c0_i2 : (i2) -> !hw.array<1xstruct<alert_p: i1, alert_n: i1>>
    %alert_tx_o = llhd.sig %1 : !hw.array<1xstruct<alert_p: i1, alert_n: i1>>
    %2 = hw.bitcast %c0_i68 : (i68) -> !hw.struct<intr_state0: !hw.array<1xstruct<d: i1, de: i1>>, timer_v_lower0: !hw.struct<d: i32, de: i1>, timer_v_upper0: !hw.struct<d: i32, de: i1>>
    %hw2reg = llhd.sig %2 : !hw.struct<intr_state0: !hw.array<1xstruct<d: i1, de: i1>>, timer_v_lower0: !hw.struct<d: i32, de: i1>, timer_v_upper0: !hw.struct<d: i32, de: i1>>
    %active = llhd.sig %false : i1
    %tick = llhd.sig %false : i1
    %3 = hw.bitcast %c0_i64 : (i64) -> !hw.array<1xi64>
    %mtime_d = llhd.sig %3 : !hw.array<1xi64>
    %mtime = llhd.sig %3 : !hw.array<1xi64>
    %4 = builtin.unrealized_conversion_cast %22 : !hw.array<1xarray<1xi64>> to !hw.array<1xi64>
    %5 = hw.bitcast %false : (i1) -> !hw.array<1xarray<1xi1>>
    %mtimecmp_update = llhd.sig %5 : !hw.array<1xarray<1xi1>>
    %intr_timer_set = llhd.sig %false : i1
    %intr_timer_state_d = llhd.sig %false : i1
    %intr_out = llhd.sig %false : i1
    %ctrl = hw.struct_extract %u_reg.reg2hw["ctrl"] : !hw.struct<alert_test: !hw.struct<q: i1, qe: i1>, ctrl: !hw.array<1xstruct<q: i1>>, intr_enable0: !hw.array<1xstruct<q: i1>>, intr_state0: !hw.array<1xstruct<q: i1>>, intr_test0: !hw.array<1xstruct<q: i1, qe: i1>>, cfg0: !hw.struct<step: !hw.struct<q: i8>, prescale: !hw.struct<q: i12>>, timer_v_lower0: !hw.struct<q: i32>, timer_v_upper0: !hw.struct<q: i32>, compare_lower0_0: !hw.struct<q: i32, qe: i1>, compare_upper0_0: !hw.struct<q: i32, qe: i1>>
    %6 = hw.array_get %ctrl[%c0_i0] : !hw.array<1xstruct<q: i1>>, i0
    %q = hw.struct_extract %6["q"] : !hw.struct<q: i1>
    llhd.drv %active, %q after %0 : !hw.inout<i1>
    %cfg0 = hw.struct_extract %u_reg.reg2hw["cfg0"] : !hw.struct<alert_test: !hw.struct<q: i1, qe: i1>, ctrl: !hw.array<1xstruct<q: i1>>, intr_enable0: !hw.array<1xstruct<q: i1>>, intr_state0: !hw.array<1xstruct<q: i1>>, intr_test0: !hw.array<1xstruct<q: i1, qe: i1>>, cfg0: !hw.struct<step: !hw.struct<q: i8>, prescale: !hw.struct<q: i12>>, timer_v_lower0: !hw.struct<q: i32>, timer_v_upper0: !hw.struct<q: i32>, compare_lower0_0: !hw.struct<q: i32, qe: i1>, compare_upper0_0: !hw.struct<q: i32, qe: i1>>
    %prescale = hw.struct_extract %cfg0["prescale"] : !hw.struct<step: !hw.struct<q: i8>, prescale: !hw.struct<q: i12>>
    %q_0 = hw.struct_extract %prescale["q"] : !hw.struct<q: i12>
    %step = hw.struct_extract %cfg0["step"] : !hw.struct<step: !hw.struct<q: i8>, prescale: !hw.struct<q: i12>>
    %q_1 = hw.struct_extract %step["q"] : !hw.struct<q: i8>
    %7 = llhd.sig.struct_extract %hw2reg["timer_v_upper0"] : !hw.inout<struct<intr_state0: !hw.array<1xstruct<d: i1, de: i1>>, timer_v_lower0: !hw.struct<d: i32, de: i1>, timer_v_upper0: !hw.struct<d: i32, de: i1>>>
    %8 = llhd.sig.struct_extract %7["de"] : !hw.inout<struct<d: i32, de: i1>>
    %9 = llhd.prb %tick : !hw.inout<i1>
    llhd.drv %8, %9 after %0 : !hw.inout<i1>
    %10 = llhd.sig.struct_extract %hw2reg["timer_v_lower0"] : !hw.inout<struct<intr_state0: !hw.array<1xstruct<d: i1, de: i1>>, timer_v_lower0: !hw.struct<d: i32, de: i1>, timer_v_upper0: !hw.struct<d: i32, de: i1>>>
    %11 = llhd.sig.struct_extract %10["de"] : !hw.inout<struct<d: i32, de: i1>>
    llhd.drv %11, %9 after %0 : !hw.inout<i1>
    %12 = llhd.sig.struct_extract %7["d"] : !hw.inout<struct<d: i32, de: i1>>
    %13 = llhd.prb %mtime_d : !hw.inout<array<1xi64>>
    %14 = hw.array_get %13[%c0_i0] : !hw.array<1xi64>, i0
    %15 = comb.extract %14 from 32 : (i64) -> i32
    llhd.drv %12, %15 after %0 : !hw.inout<i32>
    %16 = llhd.sig.struct_extract %10["d"] : !hw.inout<struct<d: i32, de: i1>>
    %17 = comb.extract %14 from 0 : (i64) -> i32
    llhd.drv %16, %17 after %0 : !hw.inout<i32>
    %18 = llhd.sig.array_get %mtime[%c0_i0] : !hw.inout<array<1xi64>>
    %timer_v_upper0 = hw.struct_extract %u_reg.reg2hw["timer_v_upper0"] : !hw.struct<alert_test: !hw.struct<q: i1, qe: i1>, ctrl: !hw.array<1xstruct<q: i1>>, intr_enable0: !hw.array<1xstruct<q: i1>>, intr_state0: !hw.array<1xstruct<q: i1>>, intr_test0: !hw.array<1xstruct<q: i1, qe: i1>>, cfg0: !hw.struct<step: !hw.struct<q: i8>, prescale: !hw.struct<q: i12>>, timer_v_lower0: !hw.struct<q: i32>, timer_v_upper0: !hw.struct<q: i32>, compare_lower0_0: !hw.struct<q: i32, qe: i1>, compare_upper0_0: !hw.struct<q: i32, qe: i1>>
    %q_2 = hw.struct_extract %timer_v_upper0["q"] : !hw.struct<q: i32>
    %timer_v_lower0 = hw.struct_extract %u_reg.reg2hw["timer_v_lower0"] : !hw.struct<alert_test: !hw.struct<q: i1, qe: i1>, ctrl: !hw.array<1xstruct<q: i1>>, intr_enable0: !hw.array<1xstruct<q: i1>>, intr_state0: !hw.array<1xstruct<q: i1>>, intr_test0: !hw.array<1xstruct<q: i1, qe: i1>>, cfg0: !hw.struct<step: !hw.struct<q: i8>, prescale: !hw.struct<q: i12>>, timer_v_lower0: !hw.struct<q: i32>, timer_v_upper0: !hw.struct<q: i32>, compare_lower0_0: !hw.struct<q: i32, qe: i1>, compare_upper0_0: !hw.struct<q: i32, qe: i1>>
    %q_3 = hw.struct_extract %timer_v_lower0["q"] : !hw.struct<q: i32>
    %19 = comb.concat %q_2, %q_3 : i32, i32
    llhd.drv %18, %19 after %0 : !hw.inout<i64>
    %compare_upper0_0 = hw.struct_extract %u_reg.reg2hw["compare_upper0_0"] : !hw.struct<alert_test: !hw.struct<q: i1, qe: i1>, ctrl: !hw.array<1xstruct<q: i1>>, intr_enable0: !hw.array<1xstruct<q: i1>>, intr_state0: !hw.array<1xstruct<q: i1>>, intr_test0: !hw.array<1xstruct<q: i1, qe: i1>>, cfg0: !hw.struct<step: !hw.struct<q: i8>, prescale: !hw.struct<q: i12>>, timer_v_lower0: !hw.struct<q: i32>, timer_v_upper0: !hw.struct<q: i32>, compare_lower0_0: !hw.struct<q: i32, qe: i1>, compare_upper0_0: !hw.struct<q: i32, qe: i1>>
    %q_4 = hw.struct_extract %compare_upper0_0["q"] : !hw.struct<q: i32, qe: i1>
    %compare_lower0_0 = hw.struct_extract %u_reg.reg2hw["compare_lower0_0"] : !hw.struct<alert_test: !hw.struct<q: i1, qe: i1>, ctrl: !hw.array<1xstruct<q: i1>>, intr_enable0: !hw.array<1xstruct<q: i1>>, intr_state0: !hw.array<1xstruct<q: i1>>, intr_test0: !hw.array<1xstruct<q: i1, qe: i1>>, cfg0: !hw.struct<step: !hw.struct<q: i8>, prescale: !hw.struct<q: i12>>, timer_v_lower0: !hw.struct<q: i32>, timer_v_upper0: !hw.struct<q: i32>, compare_lower0_0: !hw.struct<q: i32, qe: i1>, compare_upper0_0: !hw.struct<q: i32, qe: i1>>
    %q_5 = hw.struct_extract %compare_lower0_0["q"] : !hw.struct<q: i32, qe: i1>
    %20 = comb.concat %q_4, %q_5 : i32, i32
    %21 = hw.array_create %20 : i64
    %22 = hw.array_create %21 {sv.namehint = "mtimecmp"} : !hw.array<1xi64>
    %23 = llhd.sig.array_get %mtimecmp_update[%c0_i0] : !hw.inout<array<1xarray<1xi1>>>
    %24 = llhd.sig.array_get %23[%c0_i0] : !hw.inout<array<1xi1>>
    %qe = hw.struct_extract %compare_upper0_0["qe"] : !hw.struct<q: i32, qe: i1>
    %qe_6 = hw.struct_extract %compare_lower0_0["qe"] : !hw.struct<q: i32, qe: i1>
    %25 = comb.or %qe, %qe_6 : i1
    llhd.drv %24, %25 after %0 : !hw.inout<i1>
    %26 = llhd.prb %intr_out : !hw.inout<i1>
    %intr_enable0 = hw.struct_extract %u_reg.reg2hw["intr_enable0"] : !hw.struct<alert_test: !hw.struct<q: i1, qe: i1>, ctrl: !hw.array<1xstruct<q: i1>>, intr_enable0: !hw.array<1xstruct<q: i1>>, intr_state0: !hw.array<1xstruct<q: i1>>, intr_test0: !hw.array<1xstruct<q: i1, qe: i1>>, cfg0: !hw.struct<step: !hw.struct<q: i8>, prescale: !hw.struct<q: i12>>, timer_v_lower0: !hw.struct<q: i32>, timer_v_upper0: !hw.struct<q: i32>, compare_lower0_0: !hw.struct<q: i32, qe: i1>, compare_upper0_0: !hw.struct<q: i32, qe: i1>>
    %27 = hw.array_get %intr_enable0[%c0_i0] : !hw.array<1xstruct<q: i1>>, i0
    %q_7 = hw.struct_extract %27["q"] {sv.namehint = "intr_timer_en"} : !hw.struct<q: i1>
    %intr_state0 = hw.struct_extract %u_reg.reg2hw["intr_state0"] : !hw.struct<alert_test: !hw.struct<q: i1, qe: i1>, ctrl: !hw.array<1xstruct<q: i1>>, intr_enable0: !hw.array<1xstruct<q: i1>>, intr_state0: !hw.array<1xstruct<q: i1>>, intr_test0: !hw.array<1xstruct<q: i1, qe: i1>>, cfg0: !hw.struct<step: !hw.struct<q: i8>, prescale: !hw.struct<q: i12>>, timer_v_lower0: !hw.struct<q: i32>, timer_v_upper0: !hw.struct<q: i32>, compare_lower0_0: !hw.struct<q: i32, qe: i1>, compare_upper0_0: !hw.struct<q: i32, qe: i1>>
    %28 = hw.array_get %intr_state0[%c0_i0] : !hw.array<1xstruct<q: i1>>, i0
    %q_8 = hw.struct_extract %28["q"] {sv.namehint = "intr_timer_state_q"} : !hw.struct<q: i1>
    %intr_test0 = hw.struct_extract %u_reg.reg2hw["intr_test0"] : !hw.struct<alert_test: !hw.struct<q: i1, qe: i1>, ctrl: !hw.array<1xstruct<q: i1>>, intr_enable0: !hw.array<1xstruct<q: i1>>, intr_state0: !hw.array<1xstruct<q: i1>>, intr_test0: !hw.array<1xstruct<q: i1, qe: i1>>, cfg0: !hw.struct<step: !hw.struct<q: i8>, prescale: !hw.struct<q: i12>>, timer_v_lower0: !hw.struct<q: i32>, timer_v_upper0: !hw.struct<q: i32>, compare_lower0_0: !hw.struct<q: i32, qe: i1>, compare_upper0_0: !hw.struct<q: i32, qe: i1>>
    %29 = hw.array_get %intr_test0[%c0_i0] : !hw.array<1xstruct<q: i1, qe: i1>>, i0
    %q_9 = hw.struct_extract %29["q"] {sv.namehint = "intr_timer_test_q"} : !hw.struct<q: i1, qe: i1>
    %qe_10 = hw.struct_extract %29["qe"] {sv.namehint = "intr_timer_test_qe"} : !hw.struct<q: i1, qe: i1>
    %30 = llhd.sig.struct_extract %hw2reg["intr_state0"] : !hw.inout<struct<intr_state0: !hw.array<1xstruct<d: i1, de: i1>>, timer_v_lower0: !hw.struct<d: i32, de: i1>, timer_v_upper0: !hw.struct<d: i32, de: i1>>>
    %31 = llhd.sig.array_get %30[%c0_i0] : !hw.inout<array<1xstruct<d: i1, de: i1>>>
    %32 = llhd.sig.struct_extract %31["de"] : !hw.inout<struct<d: i1, de: i1>>
    %33 = llhd.prb %mtimecmp_update : !hw.inout<array<1xarray<1xi1>>>
    %34 = builtin.unrealized_conversion_cast %33 : !hw.array<1xarray<1xi1>> to !hw.array<1xi1>
    %35 = hw.array_get %34[%c0_i0] : !hw.array<1xi1>, i0
    %36 = comb.or %gen_harts_0.u_intr_hw.hw2reg_intr_state_de_o, %35 : i1
    llhd.drv %32, %36 after %0 : !hw.inout<i1>
    %37 = llhd.sig.struct_extract %31["d"] : !hw.inout<struct<d: i1, de: i1>>
    %38 = llhd.prb %intr_timer_state_d : !hw.inout<i1>
    %39 = comb.xor %35, %true : i1
    %40 = comb.and %38, %39 : i1
    llhd.drv %37, %40 after %0 : !hw.inout<i1>
    %41 = llhd.prb %intr_timer_set : !hw.inout<i1>
    %gen_harts_0.u_intr_hw.hw2reg_intr_state_de_o, %gen_harts_0.u_intr_hw.hw2reg_intr_state_d_o, %gen_harts_0.u_intr_hw.intr_o = hw.instance "gen_harts_0.u_intr_hw" @prim_intr_hw(clk_i: %clk_i: i1, rst_ni: %rst_ni: i1, event_intr_i: %41: i1, reg2hw_intr_enable_q_i: %q_7: i1, reg2hw_intr_test_q_i: %q_9: i1, reg2hw_intr_test_qe_i: %qe_10: i1, reg2hw_intr_state_q_i: %q_8: i1) -> (hw2reg_intr_state_de_o: i1, hw2reg_intr_state_d_o: i1, intr_o: i1) {sv.namehint = "intr_timer_state_de"}
    llhd.drv %intr_timer_state_d, %gen_harts_0.u_intr_hw.hw2reg_intr_state_d_o after %0 : !hw.inout<i1>
    llhd.drv %intr_out, %gen_harts_0.u_intr_hw.intr_o after %0 : !hw.inout<i1>
    %42 = llhd.prb %active : !hw.inout<i1>
    %43 = llhd.sig.array_get %mtime_d[%c0_i0] : !hw.inout<array<1xi64>>
    %44 = llhd.prb %mtime : !hw.inout<array<1xi64>>
    %45 = hw.array_get %44[%c0_i0] : !hw.array<1xi64>, i0
    %gen_harts_0.u_core.tick, %gen_harts_0.u_core.mtime_d, %gen_harts_0.u_core.intr = hw.instance "gen_harts_0.u_core" @timer_core(clk_i: %clk_i: i1, rst_ni: %rst_ni: i1, active: %42: i1, prescaler: %q_0: i12, step: %q_1: i8, mtime: %45: i64, mtimecmp: %4: !hw.array<1xi64>) -> (tick: i1, mtime_d: i64, intr: i1)
    llhd.drv %tick, %gen_harts_0.u_core.tick after %0 : !hw.inout<i1>
    llhd.drv %43, %gen_harts_0.u_core.mtime_d after %0 : !hw.inout<i64>
    llhd.drv %intr_timer_set, %gen_harts_0.u_core.intr after %0 : !hw.inout<i1>
    %alerts = llhd.sig %false : i1
    %46 = llhd.prb %hw2reg : !hw.inout<struct<intr_state0: !hw.array<1xstruct<d: i1, de: i1>>, timer_v_lower0: !hw.struct<d: i32, de: i1>, timer_v_upper0: !hw.struct<d: i32, de: i1>>>
    %u_reg.tl_o, %u_reg.reg2hw, %u_reg.racl_error_o, %u_reg.intg_err_o = hw.instance "u_reg" @rv_timer_reg_top(clk_i: %clk_i: i1, rst_ni: %rst_ni: i1, tl_i: %tl_i: !hw.struct<a_valid: i1, a_opcode: i3, a_param: i3, a_size: i2, a_source: i8, a_address: i32, a_mask: i4, a_data: i32, a_user: !hw.struct<rsvd: i5, instr_type: i4, cmd_intg: i7, data_intg: i7>, d_ready: i1>, hw2reg: %46: !hw.struct<intr_state0: !hw.array<1xstruct<d: i1, de: i1>>, timer_v_lower0: !hw.struct<d: i32, de: i1>, timer_v_upper0: !hw.struct<d: i32, de: i1>>, racl_policies_i: %racl_policies_i: !hw.array<1xstruct<write_perm: i2, read_perm: i2>>) -> (tl_o: !hw.struct<d_valid: i1, d_opcode: i3, d_param: i3, d_size: i2, d_source: i8, d_sink: i1, d_data: i32, d_user: !hw.struct<rsp_intg: i7, data_intg: i7>, d_error: i1, a_ready: i1>, reg2hw: !hw.struct<alert_test: !hw.struct<q: i1, qe: i1>, ctrl: !hw.array<1xstruct<q: i1>>, intr_enable0: !hw.array<1xstruct<q: i1>>, intr_state0: !hw.array<1xstruct<q: i1>>, intr_test0: !hw.array<1xstruct<q: i1, qe: i1>>, cfg0: !hw.struct<step: !hw.struct<q: i8>, prescale: !hw.struct<q: i12>>, timer_v_lower0: !hw.struct<q: i32>, timer_v_upper0: !hw.struct<q: i32>, compare_lower0_0: !hw.struct<q: i32, qe: i1>, compare_upper0_0: !hw.struct<q: i32, qe: i1>>, racl_error_o: !hw.struct<valid: i1, overflow: i1, racl_role: i1, ctn_uid: i1, read_access: i1, request_address: i32>, intg_err_o: i1) {sv.namehint = "reg2hw"}
    llhd.drv %alerts, %u_reg.intg_err_o after %0 : !hw.inout<i1>
    %alert_test = hw.struct_extract %u_reg.reg2hw["alert_test"] : !hw.struct<alert_test: !hw.struct<q: i1, qe: i1>, ctrl: !hw.array<1xstruct<q: i1>>, intr_enable0: !hw.array<1xstruct<q: i1>>, intr_state0: !hw.array<1xstruct<q: i1>>, intr_test0: !hw.array<1xstruct<q: i1, qe: i1>>, cfg0: !hw.struct<step: !hw.struct<q: i8>, prescale: !hw.struct<q: i12>>, timer_v_lower0: !hw.struct<q: i32>, timer_v_upper0: !hw.struct<q: i32>, compare_lower0_0: !hw.struct<q: i32, qe: i1>, compare_upper0_0: !hw.struct<q: i32, qe: i1>>
    %q_11 = hw.struct_extract %alert_test["q"] : !hw.struct<q: i1, qe: i1>
    %qe_12 = hw.struct_extract %alert_test["qe"] : !hw.struct<q: i1, qe: i1>
    %47 = comb.and %q_11, %qe_12 : i1
    %48 = llhd.prb %alerts : !hw.inout<i1>
    %49 = hw.array_get %alert_rx_i[%c0_i0] : !hw.array<1xstruct<ping_p: i1, ping_n: i1, ack_p: i1, ack_n: i1>>, i0
    %50 = llhd.sig.array_get %alert_tx_o[%c0_i0] : !hw.inout<array<1xstruct<alert_p: i1, alert_n: i1>>>
    %gen_alert_tx_0.u_prim_alert_sender.alert_ack_o, %gen_alert_tx_0.u_prim_alert_sender.alert_state_o, %gen_alert_tx_0.u_prim_alert_sender.alert_tx_o = hw.instance "gen_alert_tx_0.u_prim_alert_sender" @prim_alert_sender(clk_i: %clk_i: i1, rst_ni: %rst_ni: i1, alert_test_i: %47: i1, alert_req_i: %48: i1, alert_rx_i: %49: !hw.struct<ping_p: i1, ping_n: i1, ack_p: i1, ack_n: i1>) -> (alert_ack_o: i1, alert_state_o: i1, alert_tx_o: !hw.struct<alert_p: i1, alert_n: i1>)
    llhd.drv %50, %gen_alert_tx_0.u_prim_alert_sender.alert_tx_o after %0 : !hw.inout<struct<alert_p: i1, alert_n: i1>>
    %51 = llhd.prb %alert_tx_o : !hw.inout<array<1xstruct<alert_p: i1, alert_n: i1>>>
    hw.output %u_reg.tl_o, %51, %u_reg.racl_error_o, %26 : !hw.struct<d_valid: i1, d_opcode: i3, d_param: i3, d_size: i2, d_source: i8, d_sink: i1, d_data: i32, d_user: !hw.struct<rsp_intg: i7, data_intg: i7>, d_error: i1, a_ready: i1>, !hw.array<1xstruct<alert_p: i1, alert_n: i1>>, !hw.struct<valid: i1, overflow: i1, racl_role: i1, ctn_uid: i1, read_access: i1, request_address: i32>, i1
  }
}
