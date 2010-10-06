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

`include "any_agent.sv"

//------------------------------------------------------------------------------
// VIP developer code
//------------------------------------------------------------------------------


// The APB and WSH transaction items appear identical, but they
// differ in type, a very important distinction. The types would
// normally be very different, but we make their members have
// the same names so we can reuse the generic any_driver for
// processing responses for them.

class apb_item extends uvm_sequence_item;
  `uvm_object_utils(apb_item)
  function new(string name="apb_item");
    super.new(name);
  endfunction
  rand bit unsigned   read;
  rand uvm_ral_addr_t addr;
  rand uvm_ral_data_t data;
  virtual function string convert2string();
    return {"read:",$sformatf("%0d",read)," addr:",$sformatf("%0h",addr), " data:",$sformatf("%0h",data)};
  endfunction
endclass


class wsh_item extends uvm_sequence_item;
  `uvm_object_utils(wsh_item)
  function new(string name="apb_item");
    super.new(name);
  endfunction
  rand bit unsigned   read;
  rand uvm_ral_addr_t addr;
  rand uvm_ral_data_t data;
  virtual function string convert2string();
    return {"read:",$sformatf("%0d",read)," addr:",$sformatf("%0h",addr), " data:",$sformatf("%0h",data)};
  endfunction
endclass


class ral2apb_adapter extends uvm_ral_adapter;

  `uvm_object_utils(ral2apb_adapter)

  virtual function uvm_sequence_item ral2bus(uvm_rw_access rw_access);
    apb_item apb = apb_item::type_id::create("apb_item");
    apb.read = (rw_access.kind == uvm_ral::READ) ? 1 : 0;
    apb.addr = rw_access.addr;
    apb.data = rw_access.data;
    return apb;
  endfunction

  virtual function void bus2ral(uvm_sequence_item bus_item, uvm_rw_access rw_access);
    apb_item apb;
    if (!$cast(apb,bus_item)) begin
      `uvm_fatal("NOT_APB_TYPE","Provided bus_item is not of the correct type")
      return;
    end
    rw_access.kind = apb.read ? uvm_ral::READ : uvm_ral::WRITE;
    rw_access.addr = apb.addr;
    rw_access.data = apb.data;
  endfunction

endclass

class ral2wsh_adapter extends uvm_ral_adapter;

  `uvm_object_utils(ral2wsh_adapter)

  virtual function uvm_sequence_item ral2bus(uvm_rw_access rw_access);
    wsh_item wsh = wsh_item::type_id::create("wsh_item");
    wsh.read = (rw_access.kind == uvm_ral::READ) ? 1 : 0;
    wsh.addr = rw_access.addr;
    wsh.data = rw_access.data;
    return wsh;
  endfunction

  virtual function void bus2ral(uvm_sequence_item bus_item, uvm_rw_access rw_access);
    wsh_item wsh;
    if (!$cast(wsh,bus_item)) begin
      `uvm_fatal("NOT_APB_TYPE","Provided bus_item is not of the correct type")
      return;
    end
    rw_access.kind = wsh.read ? uvm_ral::READ : uvm_ral::WRITE;
    rw_access.addr = wsh.addr;
    rw_access.data = wsh.data;
  endfunction

endclass

// TODO: just leverage an actual DUT w/ interface, as in the vert_reuse exmaple... 
class my_apb_driver extends any_driver #(apb_item);
   `uvm_component_utils(my_apb_driver)
   function new(string name = "apb_driver", uvm_component parent=null);
      super.new(name, parent);
   endfunction: new
   virtual task pre_req(apb_item req);
     // remap so for APB: regA is at addr 1, regX is at addr 0
     // for WSH: shared regX is also at addr 0, regW is at addr 'h10
     if (req.addr == 'h10)  // regX bus addr => mem[0]
       req.addr = 'h0;
     else if (req.addr == 'h0) // regA bus addr => mem[1]
       req.addr = 'h1;
   endtask
endclass

//------------------------------------------------------------------------------
// Integrator code
//------------------------------------------------------------------------------


typedef any_agent #(apb_item) apb_agent;
typedef any_agent #(wsh_item) wsh_agent;

class blk_env extends uvm_env;

   `uvm_component_utils(blk_env)

   ral_block_B  ral;
   apb_agent    apb;
   wsh_agent    wsh;

   function new(string name = "blk_env", uvm_component parent=null);
      super.new(name, parent);
   endfunction: new

   virtual function void build();
      any_driver#(apb_item)::type_id::set_type_override(my_apb_driver::get_type());
      apb =   apb_agent::type_id::create("apb_agent",this);
      wsh =   wsh_agent::type_id::create("wsh_agent",this);
      ral = ral_block_B::type_id::create("ral_blk_B");
      ral.build();
   endfunction: build

   virtual function void connect();
      ral2apb_adapter ral2apb = new;
      ral2wsh_adapter ral2wsh = new;
      ral.APB.set_sequencer(apb.sqr, ral2apb);
      ral.WSH.set_sequencer(wsh.sqr, ral2wsh);
      apb.drv.base_addr = 'h20;
   endfunction

endclass
