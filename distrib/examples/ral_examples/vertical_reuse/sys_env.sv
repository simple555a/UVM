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


import apb_pkg::*;
import sys_ral_pkg::*;

class sys_env extends uvm_env;

   `uvm_component_utils(sys_env)

   ral_sys_S ral;
   apb_agent apb;

   function new(string name = "sys_env", uvm_component parent = null);
      super.new(name, parent);
   endfunction: new

   virtual function void build();
      super.build();
      apb = apb_agent::type_id::create("apb_agent",this);
      ral = ral_sys_S::type_id::create("ral_sys_S");
      ral.build();
   endfunction: build

   virtual function void connect();
      ral2apb_adapter ral2apb = new;
      ral.default_map.set_sequencer(apb.sqr,ral2apb);
   endfunction

endclass: sys_env

