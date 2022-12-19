//UART HOST AGENT ---> CONTAINS DRIVER, SEQUENCER, 2 MONITORS
//CONNECT DRIVER AND THE SEQUENCER
//CONNECT MONITORS TO THE AGENT'S PORTS

class uart_host_agent extends uvm_agent;
	`uvm_component_utils(uart_host_agent)
	
	uart_host_sequencer uart_sqr;
	uart_host_driver uart_drv;
	uart_rx_monitor_in  monitor_in;
	uart_tx_monitor_out monitor_out;
	
	//uart_host_sequence_item uart_host_seq_item;
        virtual uart_to_i2c_interface v_intf;
	
	uvm_analysis_port #(uart_host_sequence_item) agent_m_input_port;
	uvm_analysis_port #(uart_host_sequence_item) agent_m_output_port;


	function new(string name = "uart_host_agent", uvm_component parent = null);
	super.new(name,parent);
	endfunction: new
	
	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		$display("I'm in Build Phase of UART HOST AGENT");
		uart_drv = uart_host_driver::type_id::create("uart_drv", this);
		uart_sqr = uart_host_sequencer::type_id::create("uart_sqr", this);
		monitor_in = uart_rx_monitor_in::type_id::create("monitor_in", this);
	    	monitor_out = uart_tx_monitor_out::type_id::create("monitor_out", this);
		agent_m_input_port = new("agent_m_input_port", this);
		agent_m_output_port = new("agent_m_output_port", this);

 		if(!uvm_config_db #(virtual uart_to_i2c_interface)::get(null,"*","virtual_intf", v_intf))
		begin
		`uvm_fatal("NO_VIF", "Failed to get virtual interface");
		end
         endfunction: build_phase
	
  	function void connect_phase(uvm_phase phase);
		super.connect_phase(phase);
                $display("I'm in Connect Phase of UART HOST AGENT");
      	        uart_drv.seq_item_port.connect(uart_sqr.seq_item_export);
		//uart_drv.push_driver_message.connect(monitor_out.mon_drv);
		monitor_in.monitor_uart_input_port.connect(agent_m_input_port);
		monitor_out.monitor_uart_output_port.connect(agent_m_output_port);		
	endfunction:connect_phase
	
endclass: uart_host_agent









