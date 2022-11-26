//A UART Message - Transmitter and Receiver 
`timescale 1ns/100ps
module top(
    input tx,input rx
);

real baud_rate = 9600.0;
real baud_period = 1/baud_rate;
real baud_delay = baud_period * 1e9;
real baud_delay2 = baud_delay/2;
reg [7:0] din;
reg [7:0] Data;
bit [7:0] TX_FIFO[];
int counter=0;
int size=0;
reg loop;

initial begin
forever begin
    loop=0;
    @(negedge(tx)); begin
    $display( "---start bit neg edge receives -- @%4t",$time);
    din=0;
    end
    #baud_delay2;
    if (tx==0) begin
        $display("start bit detected confirmed");
    for(int jj=0; jj<8; jj+=1)begin
        #baud_delay;
        din[jj] = tx;
        $display("R : Data received from host Din[%1d] = %b   bit = %1d         time= %4t      data received :%8b ", jj,tx, jj, $time, din);
        $display("--------------------------------------------------------");
    end
    #baud_delay;

    if(tx==0)
        $display("Stop bit not high @%4t\n",$time);
    else begin
        $display("Stop bit high data received @%4t\n",$time);
    end
    end
  
   #baud_delay2;

   //push data in the queue
   TX_FIFO = new [TX_FIFO.size() + 1](TX_FIFO);
   TX_FIFO[counter]= din;
   $display("size : %2d",TX_FIFO.size());
   size = TX_FIFO.size();
   if (counter < 255) begin
       $display("\nTX_FIFO[%1d]= %2h",counter,TX_FIFO[counter]);
       counter = counter + 1;
   end
   else
       $display(" TX_FIFO is Full ");
   end
   loop =1;
end
always @(TX_FIFO.size()) begin
        
       $display("\n-----------------------------------------------------------------------%2t",$time);
       $display("\nSize= %1d != 0  is  TRUE",TX_FIFO.size());
       Data = TX_FIFO[counter-1];

       $display("\n Data Received : %2h",Data);

       case (Data) 
           8'h53: $display ( "start command receive : S \n" );
           8'h50: $display ( "stop command receive : P\n" );
           8'h52: $display ( "Read command receive : R\n" );
           8'h57: $display ( "write command receive : W \n" );
           8'h49: $display ( "Read GPIO port command receive : I\n" );
           8'h4F: $display ( "Write GPIO to port command receive : O\n" );
           8'h5A: $display ( "Power down command receive : Z\n" );
           default: begin 
                    $display ( "\n----------------Data received------------\n " ); 
                        if (counter < 255) begin
                            TX_FIFO[counter-1]= Data;

                            for ( int i=0;i<counter;i++)
                                $display("\nTX_FIFO[%1d]= %2h",i,TX_FIFO[i]);

                        end

                        else
                            $display("\n\nTX_FIFO is full crossed its limit : \n\n");
                    end
       endcase
       $display("\n-----------------------------------------------------------------------%2t",$time);
end

endmodule:top

