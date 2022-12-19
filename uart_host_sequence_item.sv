//Create a sequence item that has 2 queues ---> one for the message and one for the driver actions
//all pins part of dut in sequence item to drive signals 

//keep adding driver actions in the enum 

	typedef enum {
		reset_dut=0,
		version_id,
		write_to_i2c_slave,
		read_from_i2c_slave,
		write_to_brg,
		read_from_status,
		set_slave_address,
		WAW,
		RAW,
		power_down
	} driver_ACTIONS_t;


class uart_host_sequence_item extends uvm_sequence_item ;

`uvm_object_utils(uart_host_sequence_item)


	function new(string name = "uart_host_sequence_item");
	super.new(name);
	endfunction:new


byte message_queue[$];
driver_ACTIONS_t drv_action_queue[$]; // [string] can I remove queue ?

logic tx;
logic rx;
logic reset;
logic scl;
logic sdarx;
logic sdatx;

//FOR DRIVER
real baud_rate = 9600.0;
real baud_period = 1/baud_rate;
real baud_delay = baud_period * 1e9;
real baud_delay2 = baud_delay/2;
bit ack; //for I2C ACK -----------> ACTIVE LOW ACK [if 0 then ack else nack]
bit nack;  //for I2C NACK
bit u_tx_done;
bit u_rx_done;
 function void reset_fn();
    	//resetn = 0; //active low reset
	tx = 1;
	rx = 1;
	scl = 1;
	sdarx = 1;
	sdatx = 1;
     
	while(message_queue.size()) begin
	message_queue.pop_front();
	end

	while(drv_action_queue.size()) begin
	drv_action_queue.pop_front();
	end

  endfunction: reset_fn


  function void print();
    
      $display("tx = %b", tx);
      $display("rx = %b", rx);
      $display("reset = %b", reset);
      $display("sdarx = %b", sdarx);
      $display("sdatx = %b", sdatx);
      $display("scl = %b", scl);
      
  endfunction

//FOR MONITOR
reg[7:0] temp_mon_output;
byte mon_output_message_q[$];
byte mon_input_message_q[$];	


endclass: uart_host_sequence_item

//FOR I2C - 

class i2c_received_sequence_item extends uvm_sequence_item;

  rand bit[7:0] data_queue [$];
  rand bit [6:0] address;
  typedef enum {write = 0,read = 1} read_write;
  rand read_write r_w;
 // rand int stopClks;

    `uvm_object_utils_begin(i2c_received_sequence_item)
    `uvm_field_queue_int(data_queue, UVM_ALL_ON)
    `uvm_field_int(address, UVM_ALL_ON)
    `uvm_field_enum(read_write, r_w, UVM_ALL_ON)
    `uvm_object_utils_end

  function new(string name="i2c_received_sequence_item");
    super.new(name);
  endfunction : new

endclass 

