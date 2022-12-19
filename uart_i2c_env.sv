class uart_i2c_env extends uvm_env;
 
	`uvm_component_utils(uart_i2c_env)

  	uart_host_agent u_agent;
	uart_to_i2c_scoreboard ui_scoreboard;
	i2c_slave_agent i_agent;
	//i2c_slave_scoreboard i_scoreboard;	

  	function new(string name, uvm_component parent);
	super.new(name, parent);
	endfunction:new

	uart_host_sequence_item uart_host_seq_item;
	virtual uart_to_i2c_interface v_intf;

	function void build_phase(uvm_phase phase);
	$display("I'm in Build Phase of UART I2C ENV");
	super.build_phase(phase);
	u_agent = uart_host_agent::type_id::create("u_agent", this);
	ui_scoreboard = uart_to_i2c_scoreboard::type_id::create("ui_scoreboard", this);
	i_agent = i2c_slave_agent::type_id::create("i_agent", this);
	//i_scoreboard = i2c_slave_scoreboard::type_id::create("i_scoreboard", this);

      	if(!uvm_config_db #(virtual uart_to_i2c_interface)::get(null,"*","virtual_intf", v_intf))
          begin
           `uvm_fatal("NO_VIF", "Failed to get virtual interface");
          end
        endfunction : build_phase
  
	function void connect_phase(uvm_phase phase);
	$display("I'm in Connect Phase of UART I2C ENV");
	super.connect_phase(phase);
	u_agent.monitor_in.monitor_uart_input_port.connect(ui_scoreboard.sb_imp_fifo_mon_in);
	u_agent.monitor_out.monitor_uart_output_port.connect(ui_scoreboard.sb_imp_fifo_mon_out);
	i_agent.i_monitor.i2c_port.connect(ui_scoreboard.sb_imp_fifo_imon_in);
	i_agent.o_monitor.i2cmsgport.connect(ui_scoreboard.sb_imp_fifo_imon_out);
//	i_agent.o_monitor.i2cdataimp.connect(i_scoreboard.sb_imp_fifo_imon_out_data);
//	i_agent.o_monitor.i2cstopimp.connect(i_scoreboard.sb_imp_fifo_imon_out_stop);

	endfunction : connect_phase

endclass: uart_i2c_env
