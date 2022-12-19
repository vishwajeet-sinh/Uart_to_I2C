//UART HOST SCOREBOARD ------------------> GET THE MESSAGES FROM BOTH THE MONITORS AND COMPARE THE RESULTS TO CHECK IF THE INPUT MATCHES THE OUTPUT
//CONNECT THE SB AND MONITORS IN THE ENV

class uart_to_i2c_scoreboard extends uvm_scoreboard;
	`uvm_component_utils(uart_to_i2c_scoreboard)
	`uvm_analysis_imp_decl(_mon_in)
	`uvm_analysis_imp_decl(_mon_out)
	`uvm_analysis_imp_decl(_imon_in)
	`uvm_analysis_imp_decl(_imon_out)

	uvm_analysis_imp_mon_in #(uart_host_sequence_item, uart_to_i2c_scoreboard) sb_imp_fifo_mon_in;
	uvm_analysis_imp_mon_out #(uart_host_sequence_item, uart_to_i2c_scoreboard) sb_imp_fifo_mon_out;
	uvm_analysis_imp_imon_in #(i2c_received_sequence_item, uart_to_i2c_scoreboard) sb_imp_fifo_imon_in;
	uvm_analysis_imp_imon_out #(Cmd, uart_to_i2c_scoreboard) sb_imp_fifo_imon_out;

	uart_host_sequence_item sb_in;
	i2c_received_sequence_item sb_out;
	uart_host_sequence_item u_fifo_in[$], u_fifo_out[$]; 
	i2c_received_sequence_item  i2c_fifo_in[$];
	Cmd fifo_out[$];
	byte fifo_out_data[$];
	bit fifo_out_stop[$];
	bit start;
byte temp;
	virtual uart_to_i2c_interface v_intf;

	function new(string name,uvm_component parent);
	super.new(name, parent);
	endfunction:new

	function void build_phase(uvm_phase phase);

		$display("I'm in build phase of UART HOST SCOREBOARD ");
		super.build_phase(phase);

		sb_imp_fifo_mon_in = new("sb_imp_fifo_mon_in",this);
		sb_imp_fifo_mon_out = new("sb_imp_fifo_mon_out",this);
		sb_imp_fifo_imon_in = new("sb_imp_fifo_imon_in",this);
		sb_imp_fifo_imon_out = new("sb_imp_fifo_imon_out",this);
		
		sb_in = new();
		
		if(!uvm_config_db #(virtual uart_to_i2c_interface)::get(null,"*","virtual_intf", v_intf))
		begin
		`uvm_fatal("NO_VIF", "Failed to get virtual interface");
		end

	endfunction:build_phase

	function void connect_phase(uvm_phase phase);

		$display("I'm in connect phase of UART HOST SCOREBOARD ");
		super.connect_phase(phase);
	
	endfunction: connect_phase

	//Write function

	 virtual function void write_mon_in(input uart_host_sequence_item inp_seq_item); //input of dut
	  u_fifo_in.push_back(inp_seq_item);
	  $display("Size of the queue_in-predicted = %0d", u_fifo_in.size());
	 endfunction

         virtual function void write_mon_out(input uart_host_sequence_item out_seq_item); 
	  u_fifo_out.push_back(out_seq_item);
	  $display("Size of the queue_out-actual = %0d", u_fifo_out.size());
	 endfunction

	virtual function void write_imon_in(input i2c_received_sequence_item inp_seq_item);
	  i2c_fifo_in.push_back(inp_seq_item);
	  $display("Size of the queue_in-predicted = %0d", i2c_fifo_in.size());
	 endfunction

         virtual function void write_imon_out(input Cmd out_seq_item); //output of dut
	  fifo_out.push_back(out_seq_item);
	  $display("Size of the queue_out-actual = %0d", fifo_out.size());
	 endfunction


	task run_phase(uvm_phase phase);
		$display("I'm in run phase of UART HOST SCOREBOARD");
		forever begin
			#sb_in.baud_delay
			
			
				if(u_fifo_in.size()) begin
				
					sb_in = u_fifo_in.pop_front();
					//$display("sb_in");
					
					
					//sb_out = fifo_out.pop_front();
					//$display("out_req");
					
					if(sb_in.rx) begin
					start = 1;
					`uvm_info("SCORE BOARD OF UART-I2C", $sformatf("START DETECTED"), UVM_MEDIUM)
					end
					else begin
					start = 0;
					`uvm_info("SCORE BOARD OF UART-I2C", $sformatf("START NOT DETECTED"), UVM_MEDIUM)
					end
					
					


				end //IF
		
		end //FOREVER
	endtask: run_phase


endclass : uart_to_i2c_scoreboard
