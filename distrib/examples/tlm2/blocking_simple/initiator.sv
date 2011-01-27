//----------------------------------------------------------------------
//   Copyright 2010 Mentor Graphics Corporation
//   Copyright 2010 Synopsys, Inc
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


class initiator extends uvm_component;

   uvm_tlm_b_initiator_socket#(apb_rw) sock;

   `uvm_component_utils(initiator)

   function new(string name = "initiator", uvm_component parent = null);
      super.new(name, parent);
      sock = new("sock", this);
   endfunction

   //
   // Execute a simple read-modify-write
   //
   virtual task run_phase(uvm_phase_schedule phase);
      apb_rw rw;
      uvm_tlm_time delay = new;

      rw = apb_rw::type_id::create("rw",,get_full_name());
      rw.kind = apb_rw::READ;
      rw.addr = 32'h0000_FF00;
      
      sock.b_transport(rw, delay);

      // Ok to reuse the same RW instance
      rw.kind = apb_rw::WRITE;
      rw.data = ~rw.data;

      sock.b_transport(rw, delay);

      global_stop_request();
   endtask

endclass