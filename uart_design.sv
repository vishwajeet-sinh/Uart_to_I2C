//A UART Message - Transmitter and Receiver 
`timescale 1ns/100ps
module top(
    input tx,input rx
);
real baud_rate = 9600.0;
real baud_period = 1/baud_rate;
real baud_delay = baud_period * 1e9;
real baud_delay2 = baud_delay/2;
//bit acknowledge=0;
string tx_fifo[$];
reg[7:0] din;
initial begin
forever begin
//if(acknowledge==1) begin
//reg[7:0] din;
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
    // push data in the queue
    tx_fifo.push_back(din);
    #baud_delay;

    if(tx==0)
        $display("Stop bit not high @%4t\n",$time);
    else begin
        $display("Stop bit high data received @%4t\n",$time);
        //acknowledge=1;
    end
end

//always @(!tx_fifo.size()) begin

    //fsm

//end
    #baud_delay2;
  $display("after delay/4\n  din= %02h @%4t", din,$time);
end
//end
end
endmodule:top

