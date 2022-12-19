//FILE: SEQUENCER 
//Connects the sequences with the UART DRIVER 

class uart_host_sequencer extends uvm_sequencer #(uart_host_sequence_item);

`uvm_component_utils(uart_host_sequencer)

	function new(string name, uvm_component parent);
	super.new(name, parent);
	endfunction:new

	function void build_phase(uvm_phase phase);

		$display("I'm in build phase of UART HOST SEQUENCER");
		super.build_phase(phase);

	endfunction:build_phase

	function void connect_phase(uvm_phase phase);

		$display("I'm in connect phase of UART HOST SEQUENCER");
		super.connect_phase(phase);

	endfunction:connect_phase



endclass: uart_host_sequencer

