typedef enum{
  WRITE = 0,
  READ = 1
} read_write;

class Cmd extends uvm_object;
  bit [7:0] data_queue[$];
  bit [6:0] address = 0;
  read_write r_w;
  bit [6:0] len = 0;

  `uvm_object_utils_begin(Cmd)
    `uvm_field_queue_int(data_queue, UVM_ALL_ON)
    `uvm_field_int(address, UVM_ALL_ON)
    `uvm_field_enum(read_write, r_w, UVM_ALL_ON)
    `uvm_field_int(len, UVM_ALL_ON)
  `uvm_object_utils_end

  function new(string name = "");
    super.new(name);
  endfunction

endclass
