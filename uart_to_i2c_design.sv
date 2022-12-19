//
//        UART to I2C BRIDGE BUS 
//        GROUP-05
//        1. Aiswariya 2. Swetha 3. Laksh 4. Vishwajeet
//
//
//UART TO I2C DESIGN
//UART SIDE: UART RX AND TX, TWO FIFOS - FOR RX AND TX, STATE MACHINE FOR PROCESSING "PACKET COMMANDS" 
//I2C SIDE: I2C MASTER WITH TX AND RX, STATE MACHINE FOR TAKING OUT "PACKETS" FROM FIFO AND SENDING TO I2C SLAVE TB
`timescale 1ns/1ps
module top(
    input reg rx,input reg reset,
    output reg tx,

    input reg sdarx,
    output reg sdatx,
    output reg scl
);
bit start_command_flag=0;
bit stop_command_flag=0;
bit read_command_flag=0;
bit write_command_flag=0;
bit busy_flag=0;
bit uart_stopbit_flag=0;
bit Data_receive_start_flag=0;
bit start_flag=0;
bit Stop_flag=0;
byte BRG0;
byte BRG1;
byte UART_state;
byte write;
bit register_flag=0;
byte din;
byte I2CClkL;
byte I2CClkH;
logic [15:0] I2CClk;
logic [15:0] BRG_register;
byte I2CTO;
byte I2CAdr;
logic [15:0] I2CStat;
logic [15:0] IOState;

//---------------------------------------Internal Register Assignment-------------------------------------------------------------------
//=======================================================================================================================================
typedef enum  byte {Internal_Register0,Internal_Register1,Internal_Register2,Internal_Register3,Internal_Register4,Internal_Register5,Internal_Register6,Internal_Register7,Internal_Register8,Internal_Register9,Internal_Register10} Internal_Register_memory;
Internal_Register_memory IR;

always @ (UART_state) begin
    if (UART_state==write && register_flag==1)
        IR <= din;
    case (IR)
        0: BRG0 <= din; 
        1: BRG1 <= din;
        2: IOState <= din;
    //  3: IOState <= din;
    //  4: IOState <= din;
    //  5: IOState <= din;
        6: I2CAdr  <= din;
        7: I2CClkL <= din;
        8: I2CClkH <= din;
        9: I2CTO   <= din;
       10: I2CStat <= din;
       default : $display("Register address out of scope");
   endcase
       

end

//---------------------------------------Internal Register Assignment-------------------------------------------------------------------
//=======================================================================================================================================


logic [7:0] Internal_Register[10];

real I2C_bus_freq;
real I2C_clock_freq_period;
real I2C_clk_delay;
real I2C_half;
real I2C_quarter;

//byte I2CClkL;
//byte I2CClkH;
//logic [15:0] I2CClk;
//logic [15:0] BRG_register;
//assign I2CClk<={I2CClkH,I2CClkL};
//assign I2C_bus_freq <= ((15_000_000)/(8*I2CClk));
//assign Baudrate <= (7.3728*1e6)/( 16 + BRG_register ) ;

//---------------------------------------I2C clock generator-----------------------------------------------------------------------------
//=======================================================================================================================================
typedef enum byte {f_375khz,f_268khz,f_208khz,f_99khz,f_7400hz} I2C_Clk_frequency;
I2C_Clk_frequency I2C_clk_freq1;
initial begin
I2C_clk_freq1= f_375khz;



 I2C_bus_freq = (15000000/(8* I2CClk));
 I2C_clock_freq_period = 1/I2C_bus_freq;
 I2C_clk_delay = I2C_clock_freq_period * 1e9;
 I2C_half = I2C_clk_delay/2;
 I2C_quarter = I2C_half/2;
end

always @(I2CClkH,I2CClkL) begin
    case (I2C_clk_freq1)
        16'b0000_0101: I2CClk=5;
        16'b0000_0111: I2CClk=7;
        16'b0000_1001: I2CClk=9;
        16'b0001_0011: I2CClk=19;        
        16'b1111_1111: I2CClk=255;
        default : begin 
                    I2CClk=5;
                    $display("default frequency\n");
                  end
    endcase
end

//=======================================================================================================================================




//---------------------------------------Baudrate Change -------------------------------------------------------------------------------
//=======================================================================================================================================

    always @(*) begin
        if ( !busy_flag ) begin
         BRG0 <= BRG0;

        if (reset==0)
            BRG_register = 16'h2FF0;           // 752 in decimal
        else 
                                               // whenever the BRG1 register will update we need to update baudrate
            BRG_register <= {BRG1,BRG0};
        end
    end

//=======================================================================================================================================



//--------------------------------------- States Machine Declaration UART ---------------------------------------------------------------

typedef enum logic [1:0] {START_UART,DATA_RECEIVE_UART,STOP_UART} UART_states;
UART_states s1;

//=======================================================================================================================================
//---------------------------------------------- I2C State Machine-----------------------------------------------------------
//=======================================================================================================================================

typedef enum logic [2:0] {IDLE_I2C,Check_Data,Command,Write_Send,Read_Store,Stop} I2C_states;
I2C_states Next_State;



//---------------------------------------Variable Declaration ---------------------------------------------------------------------------
//=======================================================================================================================================
//real baud_rate = (7.3728*1e6)/(16 + BRG_register ) ;
 real baud_rate = 9600.0;
 real baud_period = 1/baud_rate;
 real baud_delay = baud_period * 1e9;
 real baud_delay2 = baud_delay/2;
reg [7:0] din;
logic [7:0] RX_FIFO[$:255];
int size=0;
logic start_bit=0;
logic stop_bit =0;
logic Read_bit=0;
logic Write_bit=0;
logic [1:0] S1;
logic State_RX;
logic [7:0] Data ;
logic [7:0] Counter;
real start_time_uart;
real End_time_uart;




//---------------------------------------Baud Rate Generator-----------------------------------------------------------------------------
//=======================================================================================================================================
bit baud_rate_default=0;
always  begin 
    //$display ("baud_delay = %2d",baud_delay);
    #(baud_delay) baud_rate_default = ~baud_rate_default ;
end

//=======================================================================================================================================
task UART_stop_bit();
 
    if(rx==0) 
             $display("Stop bit not high @%4t\n",$time);
                
    else begin
             $display("Stop bit high data received @%4t\n",$time);
             End_time_uart <= $time ; 
             uart_stopbit_flag<=1;
    end
      #baud_delay2;
      busy_flag=0;
      s1.next();
endtask


//=======================================================================================================================================



task receive_byte_from_host;
               
         for(int jj=0; jj<8; jj+=1)begin
             #baud_delay;
             din[jj] = rx;
             $display("R : Data received from host Din[%1d] = %b   bit = %1d         time= %4t      data received :%8b ", jj,rx, jj, $time, din);
             $display("--------------------------------------------------------");
         end
         
         #baud_delay;
         s1.next();
        
endtask
//=======================================================================================================================================
                                                /*TASK: SEND BYTE TO HOST */
//=======================================================================================================================================

task send_byte_to_host(input reg [7:0] data);

        tx=0;
        $display("\n\n\n\nrx=0 sent",$time);
            for (int ii=0;ii<8;ii++) begin
                #baud_delay;
                tx=data[ii];
                $display("S : Data sent from host tx = data[%1d]= %1d  bit : %1d         time= %4t",ii,tx,ii,$time);
                if (ii == 7) begin
                    #baud_delay2;
                    tx=1;
                    repeat ($urandom_range(3,1))
                    #baud_delay;
                end
            end
endtask


//---------------------------------------  UART Receiver condition check & FIFO storage -------------------------------------------------
//=======================================================================================================================================
initial begin
  forever begin
        if (!reset) begin
            start_flag<=0;
            Data_receive_start_flag=0;
            Stop_flag=0;
            busy_flag=0;
            send_byte_to_host("o");
            send_byte_to_host("k");
            BRG0<=8'hFF;
            BRG1<=8'h02;
            start_command_flag=0;
            stop_command_flag=0;
            write_command_flag=0;
            read_command_flag=0;
        end
      start_detect();
      receive_byte_from_host();
      UART_stop_bit();

      RX_FIFO.push_back(din);
  
      $display("size : %2d",RX_FIFO.size());
      
      size = RX_FIFO.size();
      
      if (RX_FIFO.size()>255)
         $display(" RX_FIFO is Full ");
      else
         $display("\nRX_FIFO= %2p",RX_FIFO);
  
  end

end

always @(RX_FIFO.size()) begin
        
       $display("\n-----------------------------------------------------------------------%2t",$time);
       $display("\nSize= %1d != 0  is  TRUE",RX_FIFO.size());

       case (din) 
           8'h53: begin
                      $display ( "Start command receive : S \n" );
                      start_command_flag= 1;
                  end
           8'h50: begin 
                      $display ( "Stop command receive : P \n" );
                      stop_command_flag=1;
                  end
           8'h52: begin
                      $display ( "Read command receive : R \n" );
                      read_command_flag=1;
                  end
           8'h57: begin   
                      $display ( "Write command receive : W \n");
                      write_command_flag=1;
                  end
           8'h49:     $display ( "Read GPIO port command receive : I\n" );
           8'h4F:     $display ( "Write GPIO to port command receive : O\n" );
           8'h5A:     $display ( "Power down command receive : Z\n" );
         default: begin 
                      $display ( "\n----------------Data received------------\n " ); 
                      foreach(RX_FIFO[i])
                                $display("\nRX_FIFO[%1d]= %2h",i,RX_FIFO[i]);

                      if (RX_FIFO.size()>255)
                            $display("\n\nRX_FIFO is full crossed its limit : \n\n");
                  end
       endcase
       $display("\n-----------------------------------------------------------------------%2t",$time);
end
//=======================================================================================================================================


//---------------------------------------     Start Detection of UART       -------------------------------------------------------------
//=======================================================================================================================================
task start_detect();
    @(negedge(rx)); begin
            busy_flag =1;
            $display( "---start bit neg edge receives --- @%4t",$time);
            din=0;
            start_time_uart <= $time ;

      #baud_delay2;
      
      if (rx==0) 
         $display("start bit detected confirmed");

     Data_receive_start_flag=1;
     s1.next();
 end
endtask
//--------------------------------------- State Machine UART Receiver ------------------------------------------------------------------
//=======================================================================================================================================

/*
initial begin 
    s1.first();
    forever begin
        @(posedge baud_rate_default)
        if (!reset) begin
            start_flag<=0;
            Data_receive_start_flag=0;
            Stop_flag=0;
            busy_flag=0;
            send_byte_to_host("o");
            send_byte_to_host("k");
            BRG0<=8'hFF;
            BRG1<=8'h02;
            start_command_flag=0;
            stop_command_flag=0;
            write_command_flag=0;
            read_command_flag=0;

        end

        else
            begin
            case (s1)
                START_UART   :  start_detect();
                DATA_RECEIVE_UART :  if ( Data_receive_start_flag==1 ) begin
                                   receive_byte_from_host();
                                end
                STOP_UART    :  UART_stop_bit();
                default      : begin
                    if(s1==STOP_UART)
                        $display(" Uart signal is not proper ");
                    s1=START_UART;
                end
            endcase
        end
    end
end
*/
//=======================================================================================================================================

task send_data_to_I2C_slave();
    sdatx=1;
    $display("start bit detected for I2C to I2C_slave\n");
endtask
//--------------------------------------- State Machine I2C Transmitter ------------------------------------------------------------------
//=========================================================================================================================================
/*
always @(RX_FIFO.size()) begin


    case (Next_State)

                state1 : if (RX_FIFO.size()>0)
                            if(start_command_flag==1) begin
                                Next_State.next();
                                RX_FIFO.pop_back();
                            end
                     // check if size >0
                state2 :   data_out =RX_FIFO.pop_back();
                            send_data_to_I2C_slave();
                                                                    
                     // check the data 
                     // Command S then bit high for start next state 
        Check_Data : if (Command) begin
                        Data = RX_FIFO.pop_back();
                        Next_State = Command ;
                     end
                     // check LSB of data if 0 next state write , else next state read
           Command : if (Data[0]==0) 
                        Next_State = Write_Send;
                      else
                        Next_State = Read_Store;
                     // counter = data next state send_bytes
                     // for (int ii=0;ii<=counter;ii++) task send next_state stop
        Write_Send :   begin 
                        Counter = Data ;
                  //      send_byte_to_host(Counter);
                        Next_State= Stop;
                       end
        Read_Store : begin 
                        Counter = Data ;
                    //    receive_bytes(Counter);
                        Next_State = Stop;
                     end
                     // detect stop command 
              Stop : if (Stop==1)  
                       Next_State= IDLE_I2C;
    endcase 

end

*/
//=======================================================================================================================================
/*always @(negedge reset or posedge timeout_period) begin
    Next_State <= 3'b000;
    send_byte_to_host(8'h4F);
    send_byte_to_host(8'h4A);
    RX_FIFO={};
    start_flag<=0;
    Stop_flag<=0;
    write_flag<=0;
    read_flag<=0;

end
*/

/*
real i2c_freq = 100e3;
real i2c_period = 1/i2c_freq;
real i2c_delay = i2c_period * 1e9;
real i2c_half = i2c_delay/2;
real i2c_quarter = i2c_half/2;
bit [7:0] RX_FIFO[$:255];
int size=0;
bit start_bit=0;
bit stop_bit =0;
bit data_byte_complete = 0;
bit start_sequence_detected = 0;
reg signed [7:0] i2c_address;
bit signed [7:0] start_sequence;
bit signed [7:0] data_byte;
bit signed [7:0] stop_byte;
bit i2ctx_indication;
reg scl_in;
real counter=0;
reg [7:0] num_of_bytes;
typedef struct {
bit [6:0] address;
bit r_w;
bit[7:0] byte_packet[$] ;
} payload;
payload pload[$] ;
payload pload1;
payload pload2;


logic signed [7:0] sequence_detect;
logic signed [7:0] number_of_bytes;
logic signed [7:0] byte_data;

always@(*) begin
    scl_in = scl;
end
	task start_stop_sequence_detection();
	@(negedge(tx)); begin
      $display( "---start bit neg edge receives -- @%4t",$time);
      din=0;
      end
      #baud_delay2;
      if (tx==0) begin
          $display("start bit detected confirmed");
          start_bit=1;
         for(int jj=0; jj<8; jj+=1)begin
             #baud_delay;
             din[jj] = tx;
             $display("R : Data received from host Din[%1d] = %b   bit = %1d         time= %4t      data received :%8b ", jj,tx, jj, $time, din);
             $display("--------------------------------------------------------");
         end
		 
         #baud_delay;
  
         if(tx==0) begin
             $display("Stop bit not high @%4t\n",$time);
             stop_bit =1;
         end
		 
		 sequence_detect = din;
		 
	endtask
	
	task address_store();
	@(negedge(tx)); begin
      $display( "---start bit neg edge receives -- @%4t",$time);
      din=0;
      end
      #baud_delay2;
      if (tx==0) begin
          $display("start bit detected confirmed");
          start_bit=1;
         for(int jj=0; jj<8; jj+=1)begin
             #baud_delay;
             din[jj] = tx;
             $display("R : Data received from host Din[%1d] = %b   bit = %1d         time= %4t      data received :%8b ", jj,tx, jj, $time, din);
             $display("--------------------------------------------------------");
         end
		 
         #baud_delay;
  
         if(tx==0) begin
             $display("Stop bit not high @%4t\n",$time);
             stop_bit =1;
         end
		 
		 pload1.address = din[7:1];
		 pload1.r_w = din[0];
	endtask
	
	task number_of_bytes_detected();
	@(negedge(tx)); begin
      $display( "---start bit neg edge receives -- @%4t",$time);
      din=0;
      end
      #baud_delay2;
      if (tx==0) begin
          $display("start bit detected confirmed");
          start_bit=1;
         for(int jj=0; jj<8; jj+=1)begin
             #baud_delay;
             din[jj] = tx;
             $display("R : Data received from host Din[%1d] = %b   bit = %1d         time= %4t      data received :%8b ", jj,tx, jj, $time, din);
             $display("--------------------------------------------------------");
         end
		 
         #baud_delay;
  
         if(tx==0) begin
             $display("Stop bit not high @%4t\n",$time);
             stop_bit =1;
         end
		 
		number_of_bytes = din;
		//pload1.byte_packet.push_back(number_of_bytes);
		 
	endtask
	
	task byte_transfer();
	@(negedge(tx)); begin
      $display( "---start bit neg edge receives -- @%4t",$time);
      din=0;
      end
      #baud_delay2;
      if (tx==0) begin
          $display("start bit detected confirmed");
          start_bit=1;
         for(int jj=0; jj<8; jj+=1)begin
             #baud_delay;
             din[jj] = tx;
             $display("R : Data received from host Din[%1d] = %b   bit = %1d         time= %4t      data received :%8b ", jj,tx, jj, $time, din);
             $display("--------------------------------------------------------");
         end
		 
         #baud_delay;
  
         if(tx==0) begin
             $display("Stop bit not high @%4t\n",$time);
             stop_bit =1;
         end
		 
		byte_data = din;
		pload1.byte_packet.push_back(byte_data);
		 
	endtask
	
	task send_start();
		scl=1;
		sdatx=1;

		#i2c_quarter;
		sdatx=0;
		#i2c_quarter;
		scl=0;
		#i2c_quarter;
	endtask:send_start

	task sendi2ctx_address();
		for(int ii=7; ii>=0; ii-=1)begin
		sdatx = pload2.address[ii];
		if(ii==0) sdatx = pload2.r_w;
		#i2c_quarter;
		scl=1;
			while(scl_in==0) //clock stretching
				#10;
				#i2c_half;
				scl=0;
				#i2c_quarter;
		end
		sdatx =1;
		#i2c_quarter;
		scl=1;
			while(scl_in==0)
			#10;
			#i2c_quarter;
			//sample ack
			#i2c_quarter;
			scl=0;
			#i2c_quarter;
	endtask:sendi2ctx
	
		task sendi2ctx_data();
		for(int ii=7; ii>=0; ii-=1)begin
		sdatx = pload2.address[ii];
		//if(ii==0) sdatx = pload2.r_w;
		#i2c_quarter;
		scl=1;
			while(scl_in==0) //clock stretching
				#10;
				#i2c_half;
				scl=0;
				#i2c_quarter;
		end
		sdatx =1;
		#i2c_quarter;
		scl=1;
			while(scl_in==0)
			#10;
			#i2c_quarter;
			//sample ack
			#i2c_quarter;
			scl=0;
			#i2c_quarter;
	endtask:sendi2ctx

	task send_stop();
	sdatx=0;
	#i2c_quarter;
	scl=1;
	while(scl_in==0)
	#10;
	#i2c_quarter;
	sdatx=1;
	#i2c_half;
	endtask:send_stop
	
  task SM2();
  forever begin
  case(STATE_I2C_TX)
 START_SEQUENCE: if(pload.size()>0 && i2ctx_indication ==1 )
					begin
					pload2 = pload.pop_front();
					counter = counter -1;
					send_start();
					STATE_I2C_TX = TRANSFER;
					end
					
TRANSFER_ADD:	 begin
				 sendi2ctx_address();
				 STATE_I2C_TX = TRANSFER_DATA;
				 end

TRANSFER_DATA:	repeat(number_of_bytes) 
				begin
				sendi2ctx_data();
				STATE_I2C_TX = STOP_CONDITION;
				end
STOP_CONDITION:begin
					(pload2.byte_packet()!= null)
					send_stop();
					STATE_I2C_TX = START_SEQUENCE ;
			   end
default:       STATE_I2C_TX = START_SEQUENCE ;
  endcase
  end
  endtask
  
    task SM1();
    forever begin
      case (State_RX_UART)
        IDLE : if ( reset == 0 )
          	   begin
			    i2ctx_indication =0;
				State_RX_UART=START_BIT;
               end 
			   else
			   State_RX_UART = IDLE;
        end
        START_BIT : begin
					start_stop_sequence_detection();
					if (sequence_detect == 8'h53 ) begin
						i2ctx_indication =0;
						State_RX_UART=DATA_BIT;
					end
					else State_RX_UART=START_BIT;
					end

        ADD_STORE :begin address_store();
					i2ctx_indication =0;	//if(data_byte_complete == 1)
					State_RX_UART=DATA_BYTE;		//begin
					end						//		counter=counter+1;
											//		State_RX = STOP_BIT;
											//		i2ctx_indication =0;
											//end
        DATA_BYTE : begin
					number_of_bytes_detected();
					repeat(number_of_bytes)
						begin
						byte_transfer();
						end
					i2ctx_indication =0;
					pload.push_back(pload1);
					counter = counter+1;
					State_RX_UART=STOP_BYTE_STATE;		
					end
        STOP_BYTE_STATE : begin
						  start_stop_sequence_detection();
					      if (sequence_detect == 8'h50 ) begin
								i2ctx_indication =1;
								State_RX_UART=DATA_BIT;
							end
						  else State_RX_UART=START_BIT;
						  end
      default :  State_RX_UART = IDLE;
  	  endcase        
      
    end
  endtask


  
  //Read condition is left to do.
  fork 
  SM1();
  SM2();
  join_none

  end
endmodule:top*/

endmodule:top
