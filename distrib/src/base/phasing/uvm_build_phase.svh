//
//----------------------------------------------------------------------
//   Copyright 2007-2011 Mentor Graphics Corporation
//   Copyright 2007-2010 Cadence Design Systems, Inc.
//   Copyright 2010 Synopsys, Inc.
//   All Rights Reserved Worldwide
//
//   Licensed under the Apache License, Version 2.0 (the
//   "License"); you may not use this file except in
//   compliance with the License.  You may obtain a copy of
//   the License at
//
//       http://www.apache.org/licenses/LICENSE-2.0
//
//   Unless required by applicable law or agreed to in
//   writing, software distributed under the License is
//   distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
//   CONDITIONS OF ANY KIND, either express or implied.  See
//   the License for the specific language governing
//   permissions and limitations under the License.
//----------------------------------------------------------------------

// Class: uvm_build_phase
//
// Create and configure of testbench structure
//
// <uvm_topdown_phase> that calls the
// <uvm_component::build_phase> method.
//
// Upon entry:
//  - The top-level components have been instantiated under <uvm_root>.
//  - Current simulation time is still equal to 0 but some "delta cycles" may have occurred
//
// Typical Uses:
//  - Instantiate sub-components.
//  - Instantiate register model.
//  - Get configuration values for the component being built.
//  - Set configuration values for sub-components.
//
// Exit Criteria:
//  - All <uvm_component>s have been instantiated.

class uvm_build_phase extends uvm_topdown_phase;
   virtual function void exec_func(uvm_component comp, uvm_phase phase);
      uvm_component comp_;
      if ($cast(comp_,comp)) 
        comp_.build_phase(phase); 
   endfunction : exec_func
   local static uvm_build_phase m_inst;
   static const string type_name = "uvm_build_phase";
   static function uvm_build_phase get();
      if(m_inst == null) begin 
         m_inst = new();
      end
      return m_inst; 
   endfunction : get
   `_protected function new(string name="build");
      super.new(name); 
   endfunction : new
   virtual function string get_type_name();
      return type_name;
   endfunction : get_type_name
endclass : uvm_build_phase
