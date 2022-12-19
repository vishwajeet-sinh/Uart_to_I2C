 //should it be wire ?

//INPUT TO UART SIDE OF DUT FROM UART TB ---> RX
//INPUT TO UART SIDE OF DUT FROM UART TB ---> RESETn
//OUTPUT FROM UART SIDE OF DUT TO UART TB ----> TX


//INOUT --> I2C MASTER OF DUT AND I2C SLAVE TB ---> SDA
//OUTPUT FROM I2C MASTER SIDE OF DUT TO I2C SLAVE TB ----> SCL


interface uart_to_i2c_interface();

logic rx; //INPUT
logic tx; //OUTPUT
logic sdarx; //INPUT
logic sdatx; //OUTPUT
logic scl; //OUTPUT
logic reset; //INPUT

endinterface: uart_to_i2c_interface


