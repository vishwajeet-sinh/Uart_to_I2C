//UART SEQUENCE ---------> 9 TEST CASES 


class uart_host_sequence extends uvm_sequence #(uart_host_sequence_item);

	`uvm_object_utils(uart_host_sequence)

	function new(string name="uart_host_sequence"); //mandatory string name should be given else compilation error
	super.new(name);
	endfunction:new


	uart_host_sequence_item uart_host_seq_item;

//TEST CASE 1.......................>>>>>>>>>>>>>>>>>>>>> COMMAND 1: write N bytes to the slave I2C device
//S   ADDR+W      N          DATA 0 TO 7         P 

	task write_to_i2c_device(input reg[7:0] w_address, input reg[7:0] num_bytes);

		start_item(uart_host_seq_item);
		uart_host_seq_item.drv_action_queue.push_back(write_to_i2c_slave);
		uart_host_seq_item.message_queue.push_back(8'h53); //S
		uart_host_seq_item.message_queue.push_back(w_address & 8'hFE); //write lsb=0
		uart_host_seq_item.message_queue.push_back(num_bytes);
	repeat(num_bytes) begin
		uart_host_seq_item.message_queue.push_back($urandom_range(255,0));
	end
		uart_host_seq_item.message_queue.push_back("P"); //0x50
		finish_item(uart_host_seq_item);

	endtask:write_to_i2c_device

//TEST CASE 2.......................>>>>>>>>>>>>>>>>>>>>> COMMAND 2 - READ N BYTES FROM TARGET DEVICE I2C
//S   ADDR+R      N     P 

	task read_from_i2c_device(input reg[7:0] r_address, input reg[7:0] num_bytes);

		start_item(uart_host_seq_item);
		uart_host_seq_item.drv_action_queue.push_back(read_from_i2c_slave);
		uart_host_seq_item.message_queue.push_back("S"); //0x53
		uart_host_seq_item.message_queue.push_back(r_address & 8'hFF); //read lsb=1
		uart_host_seq_item.message_queue.push_back(num_bytes);
		uart_host_seq_item.message_queue.push_back("P"); //0x50
		finish_item(uart_host_seq_item);

	endtask:read_from_i2c_device

//TEST CASE 3.......................>>>>>>>>>>>>>>>>>>>>> COMMAND 3 - WRITE TO 181M (internal_registers)
//W    REG_ADDR    REG_DATA        P

	task write_to_int_reg(input reg[7:0] reg_address, input reg[7:0] reg_data);
		
		start_item(uart_host_seq_item);
		uart_host_seq_item.drv_action_queue.push_back(write_to_brg);
		uart_host_seq_item.message_queue.push_back("W"); //0x57
		uart_host_seq_item.message_queue.push_back(reg_address);
		uart_host_seq_item.message_queue.push_back(reg_data);
		uart_host_seq_item.message_queue.push_back("P"); //0x50
		finish_item(uart_host_seq_item);

	endtask:write_to_int_reg

//TEST CASE 4.......................>>>>>>>>>>>>>>>>>>>>> COMMAND 4 - READ FROM 181M (internal_registers)
// R REG_ADDR  P

	task read_from_int_reg(input reg[7:0] reg_address);

		start_item(uart_host_seq_item);
		uart_host_seq_item.drv_action_queue.push_back(read_from_status);
		uart_host_seq_item.message_queue.push_back("R"); //0x52
		uart_host_seq_item.message_queue.push_back(reg_address);
		uart_host_seq_item.message_queue.push_back("P"); //0x50
		finish_item(uart_host_seq_item);

	endtask:read_from_int_reg


//TEST CASE 5.......................>>>>>>>>>>>>>>>>>>>>> COMMAND 5 - POWER DOWN MODE
// Z          0x5A 0xA5     P

	task power_down_mode();

		start_item(uart_host_seq_item);
		uart_host_seq_item.drv_action_queue.push_back(power_down);
		uart_host_seq_item.message_queue.push_back("Z"); //0x5A
		uart_host_seq_item.message_queue.push_back(8'h5A);
		uart_host_seq_item.message_queue.push_back(8'hA5);
		uart_host_seq_item.message_queue.push_back("P"); //0x50
		finish_item(uart_host_seq_item);

	endtask:power_down_mode

//TEST CASE 6.......................>>>>>>>>>>>>>>>>>>>>> COMMAND 6 - REPEATED START: READ AFTER WRITE 
// S      W_addr+W       No. of bytes  W_data      S     R_ADDR+R      No. of bytes  P

	task RS_read_after_write(input reg[7:0] w_address, input reg[7:0] w_num_bytes, input reg[7:0] r_address, input reg[7:0] r_num_bytes);

			start_item(uart_host_seq_item);
			uart_host_seq_item.drv_action_queue.push_back(RAW);
			uart_host_seq_item.message_queue.push_back("S"); //0x53
			uart_host_seq_item.message_queue.push_back(w_address & 8'hFE); //write lsb=0
			uart_host_seq_item.message_queue.push_back(w_num_bytes);
		repeat(w_num_bytes) begin
			uart_host_seq_item.message_queue.push_back($urandom_range(255,0));
		end
			uart_host_seq_item.message_queue.push_back("S"); //0x53
			uart_host_seq_item.message_queue.push_back(r_address & 8'hFF); //read lsb=1
			uart_host_seq_item.message_queue.push_back(r_num_bytes);
			uart_host_seq_item.message_queue.push_back("P"); //0x50
			finish_item(uart_host_seq_item);

	endtask:RS_read_after_write

//TEST CASE 7.......................>>>>>>>>>>>>>>>>>>>>> COMMAND 7 -  REPEATED START: WRITE AFTER WRITE 
// S      W_addr+W       No. of bytes  W_data      S     W_ADDR+W      No. of bytes  W_DATA   P

	task RS_write_after_write(input reg[7:0] w_address, input reg[7:0] w_num_bytes, input reg[7:0] rw_address, input reg[7:0] rw_num_bytes);

			start_item(uart_host_seq_item);
			uart_host_seq_item.drv_action_queue.push_back(WAW);
			uart_host_seq_item.message_queue.push_back("S"); //0x53
			uart_host_seq_item.message_queue.push_back(w_address & 8'hFE); //write lsb=0
			uart_host_seq_item.message_queue.push_back(w_num_bytes);
		repeat(w_num_bytes) begin
			uart_host_seq_item.message_queue.push_back($urandom_range(255,0));
		end
			uart_host_seq_item.message_queue.push_back("S"); //0x53
			uart_host_seq_item.message_queue.push_back(rw_address & 8'hFE); //write lsb=0
			uart_host_seq_item.message_queue.push_back(rw_num_bytes);
		repeat(rw_num_bytes) begin
			uart_host_seq_item.message_queue.push_back($urandom_range(255,0));
		end
			uart_host_seq_item.message_queue.push_back("P"); //0x50
			finish_item(uart_host_seq_item);

	endtask:RS_write_after_write

//TEST CASE 8.......................>>>>>>>>>>>>>>>>>>>>> COMMAND 8 - RESET DUT TO GET "OK" FROM DUT

	task reset_DUT();

		start_item(uart_host_seq_item);
		uart_host_seq_item.drv_action_queue.push_back(reset_dut);
		finish_item(uart_host_seq_item);

	endtask: reset_DUT

//TEST CASE 9.......................>>>>>>>>>>>>>>>>>>>>> COMMAND 9 - GET THE VERSION ID FROM THE DUT

	task Read_version_fn_ID();
		
		start_item(uart_host_seq_item);
		uart_host_seq_item.drv_action_queue.push_back(version_id);
		uart_host_seq_item.message_queue.push_back("V"); 
		uart_host_seq_item.message_queue.push_back("P"); 
		finish_item(uart_host_seq_item);

	endtask: Read_version_fn_ID

	task body();

	uart_host_seq_item = uart_host_sequence_item::type_id::create("uart_host_seq_item");
	`uvm_info("START","INSIDE SEQUENCE BODY",UVM_MEDIUM)


		reset_DUT();
		Read_version_fn_ID();
		write_to_i2c_device({7'h25,1'h0}, 1);      //i2c slave address - anything other than 0x26
		read_from_i2c_device({7'h25,1'h1}, 1);     //READ = 1, WRITE = 0 LSB
		write_to_int_reg(8'h00, 8'hF1);           //Write to BRG0
		write_to_int_reg(8'h01, 8'h03);           //Write to BRG1
		read_from_int_reg(8'h0A);                //Read from I2C Status Register
		power_down_mode();                      //Check Power Down Mode
		RS_read_after_write({7'h25,1'h0}, 1, {7'h25,1'h1}, 1);
		RS_write_after_write({7'h25,1'h0}, 1, {7'h25,1'h0}, 2);
		

	endtask:body

endclass:uart_host_sequence


//TO VERIFY UNRECOGNIZED COMMANDS ARE IGNORED BY THE DEVICE ----------------------------------------> 
//DELAY BETWEEN 2 BYTES OF DATA -------------------------------------------------------------------> less than 655 ms -----------> time-out ------------> clear the rx buffer
//
//reg summary
//////////////////////////////////////
/*




0x00            BRG0                   0xF0
0x01            BRG1                   0x02
0x02            Portconf GPIO          0x55
0x03            Portconf GPIO          0x55
0x04            IOstate                 -
0x05            reserved               0x00
0x06            I2Caddr                0x26
0x07            I2CClkL                0x13
0x08            I2CClkH                0x00
0x09            I2CTO                  0x66
0x0A            I2CStat                0xF0


*/
