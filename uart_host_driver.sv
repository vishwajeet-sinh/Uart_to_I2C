//UART HOST DRIVER
//-------> Implement the UART Transmitter to send messages to the DUT
//-------> Based on the sequence, do the driver action
//-------> Process the message item (sequence_item)
//-------> Send messages around to I2C Slave, Scoreboards if any !
//-------> Connect using UVM analysis ports of type imp


class uart_host_driver extends uvm_driver #(uart_host_sequence_item);

	`uvm_component_utils(uart_host_driver)

	uvm_analysis_port#(uart_host_sequence_item) push_driver_message;
	function new(string name, uvm_component parent);
	super.new(name, parent);
	endfunction:new

	uart_host_sequence_item uart_host_seq_item;
	virtual uart_to_i2c_interface v_intf;

//BUILD PHASE
	function void build_phase(uvm_phase phase);
	super.build_phase(phase);
	push_driver_message=new("push_driver_message",this);
	if(!uvm_config_db #(virtual uart_to_i2c_interface)::get(null,"*","virtual_intf", v_intf))
          begin
           `uvm_fatal("NO_VIF", "Failed to get virtual interface");
          end
	$display("I'm in Build Phase of UART HOST DRIVER");
	endfunction : build_phase

//CONNECT PHASE  
	function void connect_phase(uvm_phase phase);
	super.connect_phase(phase);
	$display("I'm in Connect Phase of UART HOST DRIVER");
	endfunction : connect_phase


	driver_ACTIONS_t driver_action;
	byte temp,s;
        byte message_q[$];
	real baud_rate;
	

//RUN PHASE - IMPLEMENT THE UART TRANSMITTER 
//Process Driver Actions
//Process messages --> If Baud Rate is written calculate baud_rate

	task run_phase(uvm_phase phase);
	$display("I'm in run phase of UART HOST DRIVER");	
       
	//RESET THE SIGNALS	
	v_intf.rx = 1;
	$display("rx:%b", v_intf.rx);
	v_intf.tx = 1;
	$display("tx:%b", v_intf.tx);
	//v_intf.reset = 0;
	



fork	
		forever begin
			seq_item_port.get_next_item(uart_host_seq_item);
		//	uart_host_seq_item.reset_fn()

		//#uart_host_seq_item.baud_delay;

				while(uart_host_seq_item.message_queue.size()) begin 
					$displayh("message_from_sequence:%p", uart_host_seq_item.message_queue);
          				temp = uart_host_seq_item.message_queue.pop_front();
					message_q.push_back(temp);
					$display("Driver::Message:%d", uart_host_seq_item.message_queue.size());
					$display("message_in_driver:%p", message_q);
				end

				while(uart_host_seq_item.drv_action_queue.size()) begin 
          				driver_action = uart_host_seq_item.drv_action_queue.pop_front();
					$display("Driver:: Driver action:%s", driver_action.name());
				end

				case(driver_action)
				
					reset_dut: begin
					$display("Inside Case: RESET_DUT");
					$display(" RECEIVED OK - 4F AND 4B FROM DUT" );
					end
					
					
					version_id: begin
					$display("Get Version ID ");
					end

					write_to_i2c_slave: begin
					$display("Write to Address: 25");
					end

					read_from_i2c_slave: begin
					$display("Read from Address: 25");
					end

					write_to_brg: begin
					baud_rate = (7.3728*1e6)/( 16 + {8'hF1, 8'h03} );
					end

		 			read_from_status: begin
					$display("REad from Status registers");
					end


					



			        endcase 
				
					//v_intf.reset = 1;

				//ACCORDING TO UART PROTOCOL - SEND A START BIT
					//if(v_intf.reset ==  1)begin
				//	#uart_host_seq_item.baud_delay; 
				
					v_intf.rx = 0;
					$display("\n\n\n\ntx=0 sent from driver",$time);
			#uart_host_seq_item.baud_delay; //if removed S not detected

                		//SEND THE DATA BIT BY BIT
			foreach(message_q[b]) begin
			$display(b, message_q[b]);
			s = message_q[b];
				
 				for (int i=0;i<8;i++) begin

               				v_intf.rx = s[i];
                			$display("S : Data sent from host Tx = data[%1d]= %1d  bit : %1d         time= %4t",i,v_intf.rx,i,$time);
					#uart_host_seq_item.baud_delay; 
				end //for
				#uart_host_seq_item.baud_delay; //can have it
		
			end //foreach 
                	 		

                

				//ACCORDING TO UART PROTOCOL - SEND A STOP BIT
					v_intf.rx = 1;
					uart_host_seq_item.u_tx_done = 1; 
					$display("\n\n\n\ntx=1 sent from driver",$time);
                    			#uart_host_seq_item.baud_delay; 

					
   

            				//end //if -  this is for the comment of interface reset

		//end
                //send_message(uart_host_seq_item, v_intf);
	        //send_driver_action(uart_host_seq_item,v_intf);
		
	
	       


	
			//uart_host_seq_item.print();
			seq_item_port.item_done();
		end 
      

join_none
	endtask:run_phase

/*task send_message(input uart_host_sequence_item  seq_item, virtual uart_to_i2c_interface intf);
	
      		
						
			while(seq_item.message_queue.size()) begin 
          			temp = seq_item.message_queue.pop_front();
				message_q.push_back(temp);
				$display("Driver::Message:%d", seq_item.message_queue.size());
                 		$displayh("message:%p", seq_item.message_queue);

			end




endtask:send_message

task send_driver_action(input uart_host_sequence_item  seq_item, virtual uart_to_i2c_interface intf);

			while(seq_item.drv_action_queue.size()) begin 
          			driver_action = seq_item.drv_action_queue.pop_front();
				$display("Driver:: Driver action:%s", driver_action.name());
			end





endtask:send_driver_action

*/
endclass: uart_host_driver

