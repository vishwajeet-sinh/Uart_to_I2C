//I2C SLAVE AGENT ---> CONTAINS I2C DRIVER, I2C SLAVE, I2C MONITOR
//CONNECT MONITOR TO THE AGENT'S PORTS

class i2c_slave_agent extends uvm_agent;
	`uvm_component_utils(i2c_slave_agent)
	
	//i2c_driver i2c_drv;
	i2c_monitor i_monitor;
	i2cmonnn o_monitor;
	
//	i2c_sdarx_monitor_in  i_monitor_in; //sdarx input to dut
//	i2c_sdatx_monitor_out i_monitor_out; //sdatx output to dut
	
	//uart_host_sequence_item uart_host_seq_item;
        virtual uart_to_i2c_interface v_intf;
	
	uvm_analysis_port #(i2c_received_sequence_item) agent_mi2c_port;
	uvm_analysis_port #(Cmd) agent_i2cmsg_port;
	uvm_analysis_port #(bit[7:0]) agent_i2cdata;
	uvm_analysis_port #(bit) agent_i2cstop;

	//uvm_analysis_port #(uart_host_sequence_item) agent_mi2c_output_port;


	function new(string name = "i2c_slave_agent", uvm_component parent = null);
	super.new(name,parent);
	endfunction: new
	
	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		$display("I'm in Build Phase of I2C SLAVE AGENT");
		//i2c_drv = i2c_driver::type_id::create("i2c_drv", this);
		i_monitor = i2c_monitor ::type_id::create("i_monitor", this);
		o_monitor = i2cmonnn ::type_id::create("o_monitor", this);
		

	//	i_monitor_in = i2c_sdarx_monitor_in ::type_id::create("i_monitor_in", this);
	  //  	i_monitor_out = i2c_sdatx_monitor_out::type_id::create("i_monitor_out", this);
	//	agent_mi2c_input_port = new("agent_mi2c_input_port", this);
		agent_mi2c_port = new("agent_mi2c_port", this);
		agent_i2cmsg_port = new("agent_i2cmsg_port", this);
		agent_i2cdata = new("agent_i2cdata", this);
		agent_i2cstop = new("agent_i2cstop", this);



 		if(!uvm_config_db #(virtual uart_to_i2c_interface)::get(null,"*","virtual_intf", v_intf))
		begin
		`uvm_fatal("NO_VIF", "Failed to get virtual interface");
		end
         endfunction: build_phase
	
  	function void connect_phase(uvm_phase phase);
		super.connect_phase(phase);
                $display("I'm in Connect Phase of I2C SLAVE AGENT");
      	        //i2c_drv.seq_item_port.connect(u_agent.uart_sqr.seq_item_export);
	//	i_monitor_in.monitor_i2c_input_port.connect(agent_mi2c_input_port);
		i_monitor.i2c_port.connect(agent_mi2c_port);
		o_monitor.i2cmsgport.connect(agent_i2cmsg_port);
		agent_i2cdata.connect(o_monitor.i2cdataimp);
		agent_i2cstop.connect(o_monitor.i2cstopimp);
 

			
	endfunction:connect_phase
	
endclass: i2c_slave_agent









