// 
// -------------------------------------------------------------
//    Copyright 2004-2008 Synopsys, Inc.
//    All Rights Reserved Worldwide
// 
//    Licensed under the Apache License, Version 2.0 (the
//    "License"); you may not use this file except in
//    compliance with the License.  You may obtain a copy of
//    the License at
// 
//        http://www.apache.org/licenses/LICENSE-2.0
// 
//    Unless required by applicable law or agreed to in
//    writing, software distributed under the License is
//    distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
//    CONDITIONS OF ANY KIND, either express or implied.  See
//    the License for the specific language governing
//    permissions and limitations under the License.
// -------------------------------------------------------------
// 

`include "wishbone.sv"

program tb;

import wb_pkg::*;

`include "ral_oc_ethernet.sv"


class oc_ethernet_env extends uvm_env;

   `uvm_component_utils(oc_ethernet_env)

   wb_agent              host;
   ral_block_oc_ethernet ral;
   uvm_ral_sequence      seq;
   uvm_sequencer_base    seqr;

   function new(string name = "oc_ethernet_env", uvm_component parent = null);
      super.new(name, parent);
   endfunction: new

   virtual function void build();

      string hdl_root = "$root.tb_top.dut";

      void'($value$plusargs("ROOT_HDL_PATH=%s",hdl_root));

      ral = ral_block_oc_ethernet::type_id::create("ral");
      host = wb_agent::type_id::create("host", this);

      ral.build();

      ral.set_hdl_path_root(hdl_root);

      set_config_int("host.seqr", "count", 0);

      /*`ifdef VCS
      this.ral.set_hdl_path_root("$root.tb_top.dut");
      `else
      this.ral.set_hdl_path_root("tb_top.dut");
      `endif*/
   endfunction: build

   virtual function void connect();
      ral2wsh_adapter ral2wsh = new;
      seqr = uvm_utils#(wb_sequencer)::find(host);
      ral.default_map.set_sequencer(seqr,ral2wsh);
      this.host.drv.bind_vitf(tb_top.wb_sl);
   endfunction

   virtual task run();
     if (seq == null) begin
       uvm_report_fatal("NO_SEQUENCE","Env's sequence is not defined. Nothing to do. Exiting.");
       return;
     end

     begin : do_reset
       uvm_report_info("RESET","Performing reset of 5 cycles");
       tb_top.rst <= 1;
       repeat (5) @(posedge tb_top.wb_clk);
       tb_top.rst <= 0;
     end

     uvm_report_info("START_SEQ",{"Starting sequence '",seq.get_name(),"'"});
     seq.ral = ral;
     seq.start(null);
     global_stop_request();
   endtask

endclass: oc_ethernet_env



initial begin

   oc_ethernet_env env;

   begin
     uvm_report_server svr;
     svr = _global_reporter.get_report_server();
     svr.set_max_quit_count(10);
   end

   env = new("env");

   begin
     string seq_name;
     if ($value$plusargs("UVM_SEQUENCE=%s",seq_name)) begin
       uvm_ral_sequence seq;
       seq = uvm_utils #(uvm_ral_sequence)::create_type_by_name(seq_name,"tb");
       if (seq == null) 
         uvm_report_fatal("NO_SEQUENCE",
           "This env requires you to specify the sequence to run using UVM_SEQUENCE=<name>");
       env.seq = seq;
     end
   end

   run_test();
end

endprogram

