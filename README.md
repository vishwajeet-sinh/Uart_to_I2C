# Uart_to_I2C
UART_TO_I2C_BUS_BRIDGE : Design
Detect the UART message ( 1 start bit, 8 Data Bits , 1 stop bit )
start bit active low , stop bit active high
DUT receives the data, add that data to the FIFO and then check the data through FSM and do required operation and send the data to I2C slave.
