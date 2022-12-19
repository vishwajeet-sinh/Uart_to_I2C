class uart_i2c_test extends uvm_test;

  `uvm_component_utils(uart_i2c_test)

  	uart_i2c_env env;
  	uart_host_sequence  seq;
  
  
	virtual uart_to_i2c_interface v_intf;

  	function new(string name,uvm_component parent);
    	super.new(name,parent);
  	endfunction: new

  	function void build_phase(uvm_phase phase);
    		super.build_phase(phase);
		$display("I'm in Build Phase of UART-I2C Test");
    		if(!uvm_config_db #(virtual uart_to_i2c_interface)::get(null,"*","virtual_intf", v_intf))
    			begin
        		`uvm_fatal("FATAL","virtual interface not successful")
    			end 
    		seq = uart_host_sequence::type_id::create("seq",this);
    		env = uart_i2c_env::type_id::create("env", this);

  	endfunction: build_phase

 
       function void connect_phase(uvm_phase phase);
       		super.connect_phase(phase);
		$display("I'm in Connect Phase of UART-I2C Test");
       endfunction: connect_phase


  	task run_phase(uvm_phase phase);
		$display("I'm in Run Phase of UART-I2C Test");
    		phase.raise_objection(this,"Begin TEST");
    		seq.start(env.u_agent.uart_sqr);
    		#100
    		phase.drop_objection(this,"done");
  	endtask : run_phase

endclass : uart_i2c_test
