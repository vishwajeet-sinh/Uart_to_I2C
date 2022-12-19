`timescale 1ns / 1ps
`include "uart_design.svp"
`include "uart_to_i2c_interface.sv"

package uart_to_i2c_pkg;

	import uvm_pkg::*;
	`include "msgtype.sv"
	`include "uart_host_sequence_item.sv"
	`include "uart_host_sequence.sv"
	`include "uart_host_sequencer.sv"
	`include "uart_host_driver.sv"
	`include "uart_rx_monitor_in.sv"
	`include "uart_tx_monitor_out.sv"
	`include "i2c_monitor.sv"
	`include "uart_to_i2c_scoreboard.sv"
	//`include "i2c_slave_scoreboard.sv"
	`include "uart_host_agent.sv"
	`include "i2c_slave_agent.sv"
	`include "uart_i2c_env.sv"
	`include "uart_i2c_test.sv"

endpackage:uart_to_i2c_pkg

//include wrapper

	module uart_to_i2c_dut(input reset,  uart_to_i2c_interface intf);
		dut ud(.reset(reset), .tx(intf.tx), .rx(intf.rx), .sdarx(intf.sdarx), .sdatx(intf.sdatx), .scl(intf.scl));
 	endmodule: uart_to_i2c_dut

module top ();

	import uvm_pkg::*;

	`include "uvm_pkg.sv";
	`include "uvm_macros.svh";


	logic reset;
	uart_to_i2c_interface v_intf();
	uart_to_i2c_dut d1(reset, v_intf);

real baud_rate = 9600.0;
real baud_period = 1/baud_rate;
real baud_delay = baud_period * 1e9;
real baud_delay2 = baud_delay/2;


	//set vif in configuration database
	initial begin
	uvm_config_db #(virtual uart_to_i2c_interface)::set(null,"*","virtual_intf", v_intf);
	run_test("uart_i2c_test");
	end



//waveform generation
  initial begin
    //clk=1;
    reset = 1;	
    #5 reset = 0;
    #5  reset = 1;
    // #7 ARESETn = 0;
  end

	//for gtkwave
	initial begin 
	$dumpfile("uart2i2c.vcd");
	$dumpvars(0,top);
	end



	initial begin
	#200000000;
	$finish();
	end

endmodule : top
