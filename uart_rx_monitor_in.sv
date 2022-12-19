//MONITOR THE RX PIN OF THE DUT --------------------> IMPLEMENT A UART RECEIVER IN THIS MONITOR TO RECEIVE THE INPUT DATA FROM THE DRIVER TO THE TEST BENCH 
//CONTEXT ----> DRIVER TX TO DUT RX --------------> CAPTURE THIS MESSAGE IN MONITOR RX_IN
//SEND THIS MESSAGE TO THE SCOREBOARD FOR COMPARISON WITH THE OUTPUT MESSAGE OF THE DUT (VIA THE TX PIN)
//CONNECT THE MONITOR TO THE AGENT PORT WHICH IS THEN CONNECTED TO THE SCOREBOARD IN ENVIRONMENT


class uart_rx_monitor_in extends uvm_monitor;
	`uvm_component_utils(uart_rx_monitor_in)
 
	uvm_analysis_port #(uart_host_sequence_item) monitor_uart_input_port; 
	uart_host_sequence_item input_message;
	virtual uart_to_i2c_interface v_intf;

	function new(string name, uvm_component parent);
	super.new(name, parent);
	monitor_uart_input_port = new("monitor_uart_input_port", this);
	endfunction:new

	function void build_phase(uvm_phase phase);
	super.build_phase(phase);
	if(!uvm_config_db #(virtual uart_to_i2c_interface)::get(null,"*","virtual_intf", v_intf))
          begin
           `uvm_fatal("NO_VIF", "Failed to get virtual interface");
          end
	$display("I'm in Build Phase of UART HOST INPUT MONITOR");
	endfunction : build_phase
	

	//CONNECT PHASE  
	function void connect_phase(uvm_phase phase);
	super.connect_phase(phase);
	$display("I'm in Connect Phase of UART HOST INPUT MONITOR");
	endfunction : connect_phase

	
	byte temp_mon_input;
	
	virtual task run_phase(uvm_phase phase);
	begin
	$display("I'm in Run Phase of UART HOST INPUT MONITOR");

		// fork
		 forever begin
		input_message = new();
			//	#input_message.baud_delay;
	//	if(v_intf.rx == 0) $display("Start bit detected");
    		@(negedge(v_intf.rx)); begin
		//#input_message.baud_delay;
		$display( "---start bit neg edge received -- @%4t",$time);
		end

    		#input_message.baud_delay2;

	    		for(int i=0; i<8; i+=1)begin
        		#input_message.baud_delay;
        		temp_mon_input[i] = v_intf.rx;
			$display("R : Data received from DRIVER TX = data[%1d]= %1d  bit : %1d         time= %4t",i,v_intf.tx,i,$time);

       			//$display("Value in temp variable of monitor:%02h TX value of DUT:%h Real-time:%t", temp_mon_output, v_intf.tx, $realtime);
		input_message.mon_input_message_q.push_back(temp_mon_input);

    		end
		    		#input_message.baud_delay;
		$displayh("message_from DRIVER TX:%p", input_message.mon_input_message_q);
    		if(v_intf.rx==0)begin
        	$display("MONITOR OF TX: Stop bit not high");
    		end

    		#input_message.baud_delay2;
    		$display("Value in temporary variable of monitor_in:%02h", temp_mon_input);

		if(v_intf.rx==1)begin
        	$display("MONITOR OF TX: Stop bit high");
    		end


			
			
		

				monitor_uart_input_port.write(input_message);

		
			//print the outputs from the driver
			#10;
		end
		// join_none

	end
	endtask : run_phase 
 
endclass : uart_rx_monitor_in


/*

task receive_byte();

reg[7:0] din;
forever begin
    @(negedge(tx));
    din=0;
    #baud_delay2;

    for(int jj=0; jj<8; jj+=1)begin
        #baud_delay;
        din[jj] = tx;
        $display("%02h %h %t", din, tx, $realtime);
    end:for
    #baud_delay;

    if(tx==0)begin
        $display("Stop bit not high");
    end

    #baud_delay2;
    $display("%02h", din);
end:forever
endtask:receive_byte */
