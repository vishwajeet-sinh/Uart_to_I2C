//MONITOR THE TX PIN OF THE DUT --------------------> IMPLEMENT A UART RECEIVER IN THIS MONITOR TO RECEIVE THE OUTPUT DATA FROM THE TX OF THE DUT TO SEND TO THE TEST BENCH (DRIVER)
//CONTEXT ----> DUT TX TO MONITOR RX --------------> CAPTURE THIS MESSAGE IN MONITOR TX_OUT
//SEND THIS MESSAGE TO THE SCOREBOARD FOR COMPARISON WITH THE INPUT MESSAGE OF THE DUT (VIA THE RX PIN)
//CONNECT THE MONITOR TO THE AGENT PORT WHICH IS THEN CONNECTED TO THE SCOREBOARD IN ENVIRONMENT

//`uvm_analysis_imp_decl(_drv_msg)

class uart_tx_monitor_out extends uvm_monitor;
	`uvm_component_utils(uart_tx_monitor_out)
 
	uvm_analysis_port #(uart_host_sequence_item) monitor_uart_output_port; 
	//uvm_analysis_imp_drv_msg #(uart_host_sequence_item, uart_tx_monitor_out) mon_drv;

	uart_host_sequence_item output_message;
	virtual uart_to_i2c_interface v_intf;

	function new(string name, uvm_component parent);
	super.new(name, parent);
	monitor_uart_output_port = new("monitor_uart_output_port", this);
	//mon_drv = new("mon_drv", this);
	endfunction:new

	function void build_phase(uvm_phase phase);
	super.build_phase(phase);
	if(!uvm_config_db #(virtual uart_to_i2c_interface)::get(null,"*","virtual_intf", v_intf))
          begin
           `uvm_fatal("NO_VIF", "Failed to get virtual interface");
          end
	$display("I'm in Build Phase of UART HOST OUTPUT MONITOR");
	endfunction : build_phase
	

	//CONNECT PHASE  
	function void connect_phase(uvm_phase phase);
	super.connect_phase(phase);
	$display("I'm in Connect Phase of UART HOST OUTPUT MONITOR");
	endfunction : connect_phase

	uart_host_sequence_item fifo_in[$], fifo_out[$]; 
	byte temp_mon_output;
		
	virtual function void write_mon_drv(input uart_host_sequence_item out_seq_item);
	  fifo_out.push_back(out_seq_item);
	  $display("Size of the queue_out-actual = %0d", fifo_out.size());
	 endfunction
	
	virtual task run_phase(uvm_phase phase);
	begin
	$display("I'm in Run Phase of UART HOST OUTPUT MONITOR");

		// fork
		 forever begin
			output_message = new();
	//	#output_message.baud_delay;
	//	if(v_intf.tx == 0) $display("Start bit detected");
    		@(negedge(v_intf.tx)); begin
		$display( "---start bit neg edge received -- @%4t",$time);
		end
    		#output_message.baud_delay2;
		if(v_intf.tx == 0) $display("Start bit detected");
    		for(int i=0; i<8; i+=1)begin
        		#output_message.baud_delay;
        		temp_mon_output[i] = v_intf.tx;
			$display("R : Data received from DUT Tx = data[%1d]= %1d  bit : %1d         time= %4t",i,v_intf.tx,i,$time);

       			//$display("Value in temp variable of monitor:%02h TX value of DUT:%h Real-time:%t", temp_mon_output, v_intf.tx, $realtime);
		output_message.mon_output_message_q.push_back(temp_mon_output);

    		end
		    		#output_message.baud_delay;
		$displayh("message_from_DUT TX:%p", output_message.mon_output_message_q);
    		if(v_intf.tx==0)begin
        	$display("MONITOR OF TX: Stop bit not high");
    		end

    		#output_message.baud_delay2;
    		$display("Value in temporary variable of monitor:%02h", temp_mon_output);

		if(v_intf.tx==1)begin
        	$display("MONITOR OF TX: Stop bit high");
    		end


			
			
		

				monitor_uart_output_port.write(output_message);
			

			//print the outputs from the driver */
			#10; 
		end //forever
		
		// join_none

	end //begin
	endtask : run_phase 
 
endclass : uart_tx_monitor_out



