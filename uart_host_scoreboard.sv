//UART HOST SCOREBOARD ------------------> GET THE MESSAGES FROM BOTH THE MONITORS AND COMPARE THE RESULTS TO CHECK IF THE INPUT MATCHES THE OUTPUT
//CONNECT THE SB AND MONITORS IN THE ENV

class uart_host_scoreboard extends uvm_scoreboard;
	`uvm_component_utils(uart_host_scoreboard )
	`uvm_analysis_imp_decl(_mon_in)
	`uvm_analysis_imp_decl(_mon_out)

	uvm_analysis_imp_mon_in #(uart_host_sequence_item, uart_host_scoreboard ) sb_imp_fifo_mon_in;
	uvm_analysis_imp_mon_out #(uart_host_sequence_item, uart_host_scoreboard ) sb_imp_fifo_mon_out;

	uart_host_sequence_item sb_in, sb_out;
	uart_host_sequence_item fifo_in[$], fifo_out[$]; 
	
	virtual uart_to_i2c_interface v_intf;

	function new(string name,uvm_component parent);
	super.new(name, parent);
	endfunction:new

	function void build_phase(uvm_phase phase);

		$display("I'm in build phase of UART HOST SCOREBOARD ");
		super.build_phase(phase);

		sb_imp_fifo_mon_in = new("sb_imp_fifo_mon_in",this);
		sb_imp_fifo_mon_out = new("sb_imp_fifo_mon_out",this);
		
		sb_in = new();
		sb_out = new();

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

	 virtual function void write_mon_in(input uart_host_sequence_item inp_seq_item);
	  fifo_in.push_back(inp_seq_item);
	  $display("Size of the queue_in-predicted = %0d", fifo_in.size());
	 endfunction

         virtual function void write_mon_out(input uart_host_sequence_item out_seq_item);
	  fifo_out.push_back(out_seq_item);
	  $display("Size of the queue_out-actual = %0d", fifo_out.size());
	 endfunction

bit start;
byte temp;
	task run_phase(uvm_phase phase);
		$display("I'm in run phase of UART HOST SCOREBOARD");
		forever begin
			#sb_in.baud_delay;
			
			begin
				if((fifo_in.size()) && (fifo_out.size()))
				begin
					sb_in = fifo_in.pop_front();
					$display("sb_in");
					
					
					sb_out = fifo_out.pop_front();
					$display("out_req");
					foreach (sb_in.mon_output_message_q[b]) begin
					`uvm_info("SCORE BOARD OF UART", $sformatf("QUEUE MESSAGES FROM MONITOR", sb_in.mon_output_message_q[b]), UVM_MEDIUM)
						end
					if(sb_in.rx) begin
					start = 1;
					`uvm_info("SCORE BOARD OF UART", $sformatf("START DETECTED"), UVM_MEDIUM)
					end
					else begin
					start = 0;
					`uvm_info("SCORE BOARD OF UART", $sformatf("START NOT DETECTED"), UVM_MEDIUM)
					end
					/*if(in_req.start_write[0]) write_prior = 0;
					else if(in_req.start_write[1]) write_prior =1;
					else if(in_req.start_write[2]) write_prior = 2;
					else write_prior = 3;


					for (int i = 0; i <3; i+=1) begin
					if (i == read_prior) begin
						if(out_req.RREADY[i] == 1 && out_req.RVALID[i] == 1 ) 
							`uvm_info("MY_INFO", $sformatf("PASS READ %d", i), UVM_MEDIUM)
						else `uvm_error(get_name,$sformatf(" ERROR READ %d",i));
						end
					else begin 
						if (out_req.RREADY[i] == 1 || out_req.RVALID[i] == 1 )
						`uvm_error(get_name,$sformatf(" ERROR READ %d",i));
					end

					if (i == write_prior) begin
						if(out_req.BREADY[i] == 1 && out_req.BVALID[i] == 1 ) 
							`uvm_info("MY_INFO", $sformatf("PASS WRITE %d", i), UVM_MEDIUM)
						else `uvm_error(get_name,$sformatf(" ERROR WRITE %d",i));
					end
					else begin 
						if (out_req.BREADY[i] == 1 || out_req.BVALID[i] == 1 )
						`uvm_error(get_name,$sformatf(" ERROR WRITE %d",i));
					end

						
					end */
					


				end //IF
		end //BEGIN
		end //FOREVER
	endtask: run_phase


endclass : uart_host_scoreboard
