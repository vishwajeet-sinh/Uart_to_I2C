`include "uart_design.sv"
module tb;
real baud_rate = 9600.0;
real baud_period = 1/baud_rate;
real baud_delay = baud_period * 1e9;
real baud_delay2 = baud_delay/2;
reg [7:0]data;
reg [7:0] dd;
reg tx,rx;
    
top UD(.tx(tx),.rx(rx));
    
    task send_byte(input reg [7:0] data);
        tx=0;
        $display("\n\n\n\ntx=0 sent",$time);
            for (int ii=0;ii<8;ii++) begin
                #baud_delay;
                tx=data[ii];
                $display("S : Data sent from host Tx = data[%1d]= %1d  bit : %1d         time= %4t",ii,tx,ii,$time);
                if (ii == 7) begin
//                    $display(" ",$time);
                    #baud_delay2;
                    tx=1;
                    repeat (2)//($urandom_range(3,1));
                    #baud_delay;
                end
            end
    endtask : send_byte

    initial begin
        tx=1;
        #baud_delay;

        send_byte(8'h53);
        send_byte(8'h50);
        send_byte(8'hFE);
        send_byte(8'h45);
        send_byte(8'hAC);


        for(int ii=0;ii<3;ii++)  begin
            dd=ii;
            send_byte(dd);
        end

        tx=1;

    end

    initial begin
        $dumpfile("wave.vcd");
        $dumpvars();
        #100000000   $finish;
    end

endmodule: tb
