// 
// -------------------------------------------------------------
//    Copyright 2004-2008 Synopsys, Inc.
//    Copyright 2010 Mentor Graphics Corp.
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

`include "uvm_pkg.sv"

program tb;

import uvm_pkg::*;

`include "regmodel.sv"
`include "tb_env.sv"


class tb_test extends uvm_test;

   function new(string name = "tb_test", uvm_component parent = null);
      super.new(name, parent);
   endfunction

   
   virtual task run();
      tb_env env;

      if (!$cast(env, uvm_top.find("env")) || env == null) begin
         `uvm_fatal("test", "Cannot find tb_env");
      end

      env.regmodel.reset();

      begin
         uvm_reg_bit_bash_seq seq;
         seq = uvm_reg_bit_bash_seq::type_id::create("seq",this);
         seq.model = env.regmodel;

         seq.start(null);
         seq.wait_for_sequence_state(FINISHED);
      end
            
      global_stop_request();
   endtask
endclass


initial begin
   static tb_env env = new("env");
   static tb_test test = new("test");
   
   uvm_report_server svr;
   svr = _global_reporter.get_report_server();
   svr.set_max_quit_count(10);
   run_test();
end

endprogram
