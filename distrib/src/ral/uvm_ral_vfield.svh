//
// -------------------------------------------------------------
//    Copyright 2004-2009 Synopsys, Inc.
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


typedef class uvm_ral_vfield;
class uvm_ral_vfield_cbs extends uvm_callback;
   string fname = "";
   int    lineno = 0;

   function new(string name = "uvm_ral_vfield_cbs");
      super.new(name);
   endfunction
   
   virtual task pre_write(uvm_ral_vfield       field,
                          longint unsigned     idx,
                          ref uvm_ral_data_t   wdat,
                          ref uvm_ral::path_e  path,
                          ref uvm_ral_map   map);
   endtask: pre_write

   virtual task post_write(uvm_ral_vfield        field,
                           longint unsigned      idx,
                           uvm_ral_data_t        wdat,
                           uvm_ral::path_e       path,
                           uvm_ral_map        map,
                           ref uvm_ral::status_e status);
   endtask: post_write

   virtual task pre_read(uvm_ral_vfield        field,
                         longint unsigned      idx,
                         ref uvm_ral::path_e   path,
                         ref uvm_ral_map    map);
   endtask: pre_read

   virtual task post_read(uvm_ral_vfield         field,
                          longint unsigned       idx,
                          ref uvm_ral_data_t     rdat,
                          uvm_ral::path_e        path,
                          uvm_ral_map         map,
                          ref uvm_ral::status_e  status);
   endtask: post_read
endclass: uvm_ral_vfield_cbs
typedef uvm_callbacks#(uvm_ral_vfield, uvm_ral_vfield_cbs) uvm_ral_vfield_cb;
typedef uvm_callback_iter#(uvm_ral_vfield, uvm_ral_vfield_cbs) uvm_ral_vfield_cb_iter;



class uvm_ral_vfield extends uvm_object;

   `uvm_register_cb(uvm_ral_vfield, uvm_ral_vfield_cbs)
   
   virtual task pre_write(longint unsigned     idx,
                          ref uvm_ral_data_t   wdat,
                          ref uvm_ral::path_e  path,
                          ref uvm_ral_map   map);
   endtask: pre_write

   virtual task post_write(longint unsigned       idx,
                           uvm_ral_data_t         wdat,
                           uvm_ral::path_e        path,
                           uvm_ral_map         map,
                           ref uvm_ral::status_e  status);
   endtask: post_write

   virtual task pre_read(longint unsigned      idx,
                         ref uvm_ral::path_e   path,
                         ref uvm_ral_map    map);
   endtask: pre_read

   virtual task post_read(longint unsigned       idx,
                          ref uvm_ral_data_t     rdat,
                          uvm_ral::path_e        path,
                          uvm_ral_map         map,
                          ref uvm_ral::status_e  status);
   endtask: post_read

   local uvm_ral_vreg parent;
   local int unsigned lsb;
   local int unsigned size;
   local string fname = "";
   local int lineno = 0;
   local bit read_in_progress;
   local bit write_in_progress;

   extern /*local*/ function new(string  name);

   extern /*local*/ function void configure(uvm_ral_vreg parent,
                                            int unsigned size,
                                            int unsigned lsb_pos);

   extern virtual function string get_full_name();
   extern virtual function uvm_ral_vreg get_parent();
   extern virtual function uvm_ral_vreg get_register();
   extern virtual function int unsigned get_lsb_pos_in_register();
   extern virtual function int unsigned get_n_bits();

   extern virtual function string get_access(uvm_ral_map map = null);

   extern virtual function void display(string prefix = "");
   extern virtual function string psdisplay(string prefix = "");

   extern virtual task write(input  longint unsigned   idx,
                             output uvm_ral::status_e  status,
                             input  uvm_ral_data_t     value,
                             input  uvm_ral::path_e    path = uvm_ral::DEFAULT,
                             input  uvm_ral_map     map = null,
                             input  uvm_sequence_base  parent = null,
                             input  uvm_object         extension = null,
                             input  string             fname = "",
                             input  int                lineno = 0);
   extern virtual task read(input  longint unsigned    idx,
                            output uvm_ral::status_e   status,
                            output uvm_ral_data_t      value,
                            input  uvm_ral::path_e     path = uvm_ral::DEFAULT,
                            input  uvm_ral_map      map = null,
                            input  uvm_sequence_base   parent = null,
                            input  uvm_object          extension = null,
                            input  string              fname = "",
                            input  int                 lineno = 0);
               
   extern virtual task poke(input  longint unsigned    idx,
                            output uvm_ral::status_e   status,
                            input  uvm_ral_data_t      value,
                            input  uvm_sequence_base   parent = null,
                            input  uvm_object          extension = null,
                            input  string              fname = "",
                            input  int                 lineno = 0);
   extern virtual task peek(input  longint unsigned    idx,
                            output uvm_ral::status_e   status,
                            output uvm_ral_data_t      value,
                            input  uvm_sequence_base   parent = null,
                            input  uvm_object          extension = null,
                            input  string              fname = "",
                            input  int                 lineno = 0);
               
   extern virtual function void do_print (uvm_printer printer);
   extern virtual function string convert2string;
   extern virtual function uvm_object clone();
   extern virtual function void do_copy   (uvm_object rhs);
   extern virtual function bit do_compare (uvm_object  rhs,
                                          uvm_comparer comparer);
   extern virtual function void do_pack (uvm_packer packer);
   extern virtual function void do_unpack (uvm_packer packer);

endclass: uvm_ral_vfield


function uvm_ral_vfield::new(string name);
   super.new(name);
endfunction: new

function void uvm_ral_vfield::configure(uvm_ral_vreg  parent,
                                   int unsigned  size,
                                   int unsigned  lsb_pos);
   this.parent = parent;
   if (size == 0) begin
      `uvm_error("RAL", $psprintf("Virtual field \"%s\" cannot have 0 bits", this.get_full_name()));
      size = 1;
   end
   if (size > `UVM_RAL_DATA_WIDTH) begin
      `uvm_error("RAL", $psprintf("Virtual field \"%s\" cannot have more than %0d bits",
                                     this.get_full_name(),
                                     `UVM_RAL_DATA_WIDTH));
      size = `UVM_RAL_DATA_WIDTH;
   end

   this.size   = size;
   this.lsb    = lsb_pos;

   this.parent.add_field(this);
endfunction: configure



function string uvm_ral_vfield::get_full_name();
   get_full_name = {this.parent.get_full_name(), ".", this.get_name()};
endfunction: get_full_name


function uvm_ral_vreg uvm_ral_vfield::get_register();
   get_register = this.parent;
endfunction: get_register


function uvm_ral_vreg uvm_ral_vfield::get_parent();
   get_parent = this.parent;
endfunction: get_parent



function int unsigned uvm_ral_vfield::get_lsb_pos_in_register();
   get_lsb_pos_in_register = this.lsb;
endfunction: get_lsb_pos_in_register


function int unsigned uvm_ral_vfield::get_n_bits();
   get_n_bits = this.size;
endfunction: get_n_bits


function string uvm_ral_vfield::get_access(uvm_ral_map map = null);
   if (this.parent.get_memory() == null) begin
      `uvm_error("RAL", $psprintf("Cannot call uvm_ral_vfield::get_rights() on unimplemented virtual field \"%s\"",
                                     this.get_full_name()));
      return "RW";
   end

   return this.parent.get_access(map);
endfunction: get_access


function void uvm_ral_vfield::display(string prefix = "");
   $write("%s\n", this.psdisplay(prefix));
endfunction: display


function string uvm_ral_vfield::psdisplay(string prefix = "");
   string res_str = "";
   string t_str = "";
   bit with_debug_info = 1'b0;
   $sformat(psdisplay, {"%s%s[%0d-%0d]"}, prefix,
            this.get_name(),
            this.get_lsb_pos_in_register() + this.get_n_bits() - 1,
            this.get_lsb_pos_in_register());
   if (read_in_progress == 1'b1) begin
      if (fname != "" && lineno != 0)
         $sformat(res_str, "%s:%0d ",fname, lineno);
      psdisplay = {psdisplay, "\n", res_str, "currently executing read method"}; 
   end
   if ( write_in_progress == 1'b1) begin
      if (fname != "" && lineno != 0)
         $sformat(res_str, "%s:%0d ",fname, lineno);
      psdisplay = {psdisplay, "\n", res_str, "currently executing write method"}; 
   end

endfunction: psdisplay


task uvm_ral_vfield::write(input  longint unsigned    idx,
                           output uvm_ral::status_e   status,
                           input  uvm_ral_data_t      value,
                           input  uvm_ral::path_e     path = uvm_ral::DEFAULT,
                           input  uvm_ral_map      map = null,
                           input  uvm_sequence_base   parent = null,
                           input  uvm_object          extension = null,
                           input  string              fname = "",
                           input  int                 lineno = 0);
   uvm_ral_data_t  tmp;
   uvm_ral_data_t  segval;
   uvm_ral_addr_t  segoff;
   uvm_ral::status_e st;

   int flsb, fmsb, rmwbits;
   int segsiz, segn;
   uvm_ral_mem    mem;
   uvm_ral::path_e rm_path;

   uvm_ral_vfield_cb_iter cbs = new(this);

   this.fname = fname;
   this.lineno = lineno;

   write_in_progress = 1'b1;
   mem = this.parent.get_memory();
   if (mem == null) begin
      `uvm_error("RAL", $psprintf("Cannot call uvm_ral_vfield::write() on unimplemented virtual register \"%s\"",
                                     this.get_full_name()));
      status = uvm_ral::ERROR;
      return;
   end

   if (path == uvm_ral::DEFAULT) begin
      uvm_ral_block blk = this.parent.get_block();
      path = blk.get_default_path();
   end

   status = uvm_ral::IS_OK;

   this.parent.XatomicX(1);

   if (value >> this.size) begin
      `uvm_warning("RAL", $psprintf("Writing value 'h%h that is greater than field \"%s\" size (%0d bits)", value, this.get_full_name(), this.get_n_bits()));
      value &= value & ((1<<this.size)-1);
   end
   tmp = 0;

   this.pre_write(idx, value, path, map);
   for (uvm_ral_vfield_cbs cb = cbs.first(); cb != null;
        cb = cbs.next()) begin
      cb.fname = this.fname;
      cb.lineno = this.lineno;
      cb.pre_write(this, idx, value, path, map);
   end

   segsiz = mem.get_n_bytes() * 8;
   flsb    = this.get_lsb_pos_in_register();
   segoff  = this.parent.get_offset_in_memory(idx) + (flsb / segsiz);

   // Favor backdoor read to frontdoor read for the RMW operation
   rm_path = uvm_ral::DEFAULT;
   if (mem.get_backdoor() != null) rm_path = uvm_ral::BACKDOOR;

   // Any bits on the LSB side we need to RMW?
   rmwbits = flsb % segsiz;

   // Total number of memory segment in this field
   segn = (rmwbits + this.get_n_bits() - 1) / segsiz + 1;

   if (rmwbits > 0) begin
      uvm_ral_addr_t  segn;

      mem.read(st, segoff, tmp, rm_path, map, parent, , extension, fname, lineno);
      if (st != uvm_ral::IS_OK && st != uvm_ral::HAS_X) begin
         `uvm_error("RAL",
                    $psprintf("Unable to read LSB bits in %s[%0d] to for RMW cycle on virtual field %s.",
                              mem.get_full_name(), segoff, this.get_full_name()));
         status = uvm_ral::ERROR;
         this.parent.XatomicX(0);
         return;
      end

      value = (value << rmwbits) | (tmp & ((1<<rmwbits)-1));
   end

   // Any bits on the MSB side we need to RMW?
   fmsb = rmwbits + this.get_n_bits() - 1;
   rmwbits = (fmsb+1) % segsiz;
   if (rmwbits > 0) begin
      if (segn > 0) begin
         mem.read(st, segoff + segn - 1, tmp, rm_path, map, parent,, extension, fname, lineno);
         if (st != uvm_ral::IS_OK && st != uvm_ral::HAS_X) begin
            `uvm_error("RAL",
                       $psprintf("Unable to read MSB bits in %s[%0d] to for RMW cycle on virtual field %s.",
                                 mem.get_full_name(), segoff+segn-1,
                                 this.get_full_name()));
            status = uvm_ral::ERROR;
            this.parent.XatomicX(0);
            return;
         end
      end
      value |= (tmp & ~((1<<rmwbits)-1)) << ((segn-1)*segsiz);
   end

   // Now write each of the segments
   tmp = value;
   repeat (segn) begin
      mem.write(st, segoff, tmp, path, map, parent,, extension, fname, lineno);
      if (st != uvm_ral::IS_OK && st != uvm_ral::HAS_X) status = uvm_ral::ERROR;

      segoff++;
      tmp = tmp >> segsiz;
   end

   this.post_write(idx, value, path, map, status);
   for (uvm_ral_vfield_cbs cb = cbs.first(); cb != null;
        cb = cbs.next()) begin
      cb.fname = this.fname;
      cb.lineno = this.lineno;
      cb.post_write(this, idx, value, path, map, status);
   end

   this.parent.XatomicX(0);


   `uvm_info("RAL", $psprintf("Wrote virtual field \"%s\"[%0d] via %s with: 'h%h",
                              this.get_full_name(), idx,
                              (path == uvm_ral::BFM) ? "frontdoor" : "backdoor",
                              value),UVM_MEDIUM); 
   
   write_in_progress = 1'b0;
   this.fname = "";
   this.lineno = 0;
endtask: write


task uvm_ral_vfield::read(input longint unsigned     idx,
                          output uvm_ral::status_e   status,
                          output uvm_ral_data_t      value,
                          input  uvm_ral::path_e     path = uvm_ral::DEFAULT,
                          input  uvm_ral_map      map = null,
                          input  uvm_sequence_base   parent = null,
                          input  uvm_object          extension = null,
                          input  string              fname = "",
                          input  int                 lineno = 0);
   uvm_ral_data_t  tmp;
   uvm_ral_data_t  segval;
   uvm_ral_addr_t  segoff;
   uvm_ral::status_e st;

   int flsb, lsb;
   int segsiz, segn;
   uvm_ral_mem    mem;

   uvm_ral_vfield_cb_iter cbs = new(this);

   this.fname = fname;
   this.lineno = lineno;

   read_in_progress = 1'b1;
   mem = this.parent.get_memory();
   if (mem == null) begin
      `uvm_error("RAL", $psprintf("Cannot call uvm_ral_vfield::read() on unimplemented virtual register \"%s\"",
                                     this.get_full_name()));
      status = uvm_ral::ERROR;
      return;
   end

   if (path == uvm_ral::DEFAULT) begin
      uvm_ral_block blk = this.parent.get_block();
      path = blk.get_default_path();
   end

   status = uvm_ral::IS_OK;

   this.parent.XatomicX(1);

   value = 0;

   this.pre_read(idx, path, map);
   for (uvm_ral_vfield_cbs cb = cbs.first(); cb != null;
        cb = cbs.next()) begin
      cb.fname = this.fname;
      cb.lineno = this.lineno;
      cb.pre_read(this, idx, path, map);
   end

   segsiz = mem.get_n_bytes() * 8;
   flsb    = this.get_lsb_pos_in_register();
   segoff  = this.parent.get_offset_in_memory(idx) + (flsb / segsiz);
   lsb = flsb % segsiz;

   // Total number of memory segment in this field
   segn = (lsb + this.get_n_bits() - 1) / segsiz + 1;

   // Read each of the segments, MSB first
   segoff += segn - 1;
   repeat (segn) begin
      value = value << segsiz;

      mem.read(st, segoff, tmp, path, map, parent, , extension, fname, lineno);
      if (st != uvm_ral::IS_OK && st != uvm_ral::HAS_X) status = uvm_ral::ERROR;

      segoff--;
      value |= tmp;
   end

   // Any bits on the LSB side we need to get rid of?
   value = value >> lsb;

   // Any bits on the MSB side we need to get rid of?
   value &= (1<<this.get_n_bits()) - 1;

   this.post_read(idx, value, path, map, status);
   for (uvm_ral_vfield_cbs cb = cbs.first(); cb != null;
        cb = cbs.next()) begin
      cb.fname = this.fname;
      cb.lineno = this.lineno;
      cb.post_read(this, idx, value, path, map, status);
   end

   this.parent.XatomicX(0);

   `uvm_info("RAL", $psprintf("Read virtual field \"%s\"[%0d] via %s: 'h%h",
                              this.get_full_name(), idx,
                              (path == uvm_ral::BFM) ? "frontdoor" : "backdoor",
                              value),UVM_MEDIUM);


   read_in_progress = 1'b0;
   this.fname = "";
   this.lineno = 0;
endtask: read
               

task uvm_ral_vfield::poke(input  longint unsigned  idx,
                          output uvm_ral::status_e status,
                          input  uvm_ral_data_t    value,
                          input  uvm_sequence_base parent = null,
                          input  uvm_object        extension = null,
                          input  string            fname = "",
                          input  int               lineno = 0);
   uvm_ral_data_t  tmp;
   uvm_ral_data_t  segval;
   uvm_ral_addr_t  segoff;
   uvm_ral::status_e st;

   int flsb, fmsb, rmwbits;
   int segsiz, segn;
   uvm_ral_mem    mem;
   uvm_ral::path_e rm_path;
   this.fname = fname;
   this.lineno = lineno;

   mem = this.parent.get_memory();
   if (mem == null) begin
      `uvm_error("RAL", $psprintf("Cannot call uvm_ral_vfield::poke() on unimplemented virtual register \"%s\"",
                                     this.get_full_name()));
      status = uvm_ral::ERROR;
      return;
   end

   status = uvm_ral::IS_OK;

   this.parent.XatomicX(1);

   if (value >> this.size) begin
      `uvm_warning("RAL", $psprintf("Writing value 'h%h that is greater than field \"%s\" size (%0d bits)", value, this.get_full_name(), this.get_n_bits()));
      value &= value & ((1<<this.size)-1);
   end
   tmp = 0;

   segsiz = mem.get_n_bytes() * 8;
   flsb    = this.get_lsb_pos_in_register();
   segoff  = this.parent.get_offset_in_memory(idx) + (flsb / segsiz);

   // Any bits on the LSB side we need to RMW?
   rmwbits = flsb % segsiz;

   // Total number of memory segment in this field
   segn = (rmwbits + this.get_n_bits() - 1) / segsiz + 1;

   if (rmwbits > 0) begin
      uvm_ral_addr_t  segn;

      mem.peek(st, segoff, tmp, "", parent, extension, fname, lineno);
      if (st != uvm_ral::IS_OK && st != uvm_ral::HAS_X) begin
         `uvm_error("RAL",
                    $psprintf("Unable to read LSB bits in %s[%0d] to for RMW cycle on virtual field %s.",
                              mem.get_full_name(), segoff, this.get_full_name()));
         status = uvm_ral::ERROR;
         this.parent.XatomicX(0);
         return;
      end

      value = (value << rmwbits) | (tmp & ((1<<rmwbits)-1));
   end

   // Any bits on the MSB side we need to RMW?
   fmsb = rmwbits + this.get_n_bits() - 1;
   rmwbits = (fmsb+1) % segsiz;
   if (rmwbits > 0) begin
      if (segn > 0) begin
         mem.peek(st, segoff + segn - 1, tmp, "", parent, extension, fname, lineno);
         if (st != uvm_ral::IS_OK && st != uvm_ral::HAS_X) begin
            `uvm_error("RAL",
                       $psprintf("Unable to read MSB bits in %s[%0d] to for RMW cycle on virtual field %s.",
                                 mem.get_full_name(), segoff+segn-1,
                                 this.get_full_name()));
            status = uvm_ral::ERROR;
            this.parent.XatomicX(0);
            return;
         end
      end
      value |= (tmp & ~((1<<rmwbits)-1)) << ((segn-1)*segsiz);
   end

   // Now write each of the segments
   tmp = value;
   repeat (segn) begin
      mem.poke(st, segoff, tmp, "", parent, extension, fname, lineno);
      if (st != uvm_ral::IS_OK && st != uvm_ral::HAS_X) status = uvm_ral::ERROR;

      segoff++;
      tmp = tmp >> segsiz;
   end

   this.parent.XatomicX(0);

   `uvm_info("RAL", $psprintf("Wrote virtual field \"%s\"[%0d] with: 'h%h",
                              this.get_full_name(), idx, value),UVM_MEDIUM);

   this.fname = "";
   this.lineno = 0;
endtask: poke


task uvm_ral_vfield::peek(input  longint unsigned  idx,
                          output uvm_ral::status_e status,
                          output uvm_ral_data_t    value,
                          input  uvm_sequence_base parent = null,
                          input  uvm_object        extension = null,
                          input  string            fname = "",
                          input  int               lineno = 0);
   uvm_ral_data_t  tmp;
   uvm_ral_data_t  segval;
   uvm_ral_addr_t  segoff;
   uvm_ral::status_e st;

   int flsb, lsb;
   int segsiz, segn;
   uvm_ral_mem    mem;
   this.fname = fname;
   this.lineno = lineno;

   mem = this.parent.get_memory();
   if (mem == null) begin
      `uvm_error("RAL", $psprintf("Cannot call uvm_ral_vfield::peek() on unimplemented virtual register \"%s\"",
                                     this.get_full_name()));
      status = uvm_ral::ERROR;
      return;
   end

   status = uvm_ral::IS_OK;

   this.parent.XatomicX(1);

   value = 0;

   segsiz = mem.get_n_bytes() * 8;
   flsb    = this.get_lsb_pos_in_register();
   segoff  = this.parent.get_offset_in_memory(idx) + (flsb / segsiz);
   lsb = flsb % segsiz;

   // Total number of memory segment in this field
   segn = (lsb + this.get_n_bits() - 1) / segsiz + 1;

   // Read each of the segments, MSB first
   segoff += segn - 1;
   repeat (segn) begin
      value = value << segsiz;

      mem.peek(st, segoff, tmp, "", parent, extension, fname, lineno);

      if (st != uvm_ral::IS_OK && st != uvm_ral::HAS_X) status = uvm_ral::ERROR;

      segoff--;
      value |= tmp;
   end

   // Any bits on the LSB side we need to get rid of?
   value = value >> lsb;

   // Any bits on the MSB side we need to get rid of?
   value &= (1<<this.get_n_bits()) - 1;

   this.parent.XatomicX(0);

   `uvm_info("RAL", $psprintf("Peeked virtual field \"%s\"[%0d]: 'h%h", this.get_full_name(), idx, value),UVM_MEDIUM);

   this.fname = "";
   this.lineno = 0;
endtask: peek
               

function void uvm_ral_vfield::do_print (uvm_printer printer);
  super.do_print(printer);
  printer.print_generic("initiator", parent.get_type_name(), -1, psdisplay());
endfunction

function string uvm_ral_vfield::convert2string();
  return psdisplay();
endfunction

//TODO - add fatal messages

function uvm_object uvm_ral_vfield::clone();
  return null;
endfunction

function void uvm_ral_vfield::do_copy   (uvm_object rhs);
endfunction

function bit uvm_ral_vfield::do_compare (uvm_object  rhs,
                                        uvm_comparer comparer);
  return 0;
endfunction

function void uvm_ral_vfield::do_pack (uvm_packer packer);
endfunction

function void uvm_ral_vfield::do_unpack (uvm_packer packer);
endfunction


