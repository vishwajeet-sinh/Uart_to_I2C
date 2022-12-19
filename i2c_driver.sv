//I2C DRIVER  ---> CONTAINS 
//BUILT INSIDE THE AGENT 
//CONNECT I2C DRIVER AND MONITOR THE SIGNALS IN I2C MONITOR

class i2c_driver extends uvm_component#(i2c_received_sequence_item);
  i2c_received_sequence_item data_packet_i2c;
   virtual uart_to_i2c_interface v_intf;
  uvm_analysis_port#(Cmd)i2crx;
  bit [7:0] dq[$];
  Cmd message;
  bit [7:0] low = 'h13;
  bit[7:0] high = 'h00;
 
  real f = ((15000000) / ((8) * (low + high)));
  real i2c_period = 1/f ;
  real i2c_delay = i2c_period * 1e9;	
  real i2c_half = i2c_delay / 2;
  real i2c_quarter = i2c_half/2;
  logic sclk = v_intf.scl;

  `uvm_component_utils_begin(i2c_driver)
  `uvm_field_object(data_packet_i2c, UVM_ALL_ON)
  `uvm_component_utils_end

  function new(string name="i2c_driver", uvm_component parent = null);
    super.new(name, parent);
    i2crx = new("i2crx", this);
  endfunction : new

virtual function void build_phase(uvm_phase phase);
$display("I'm in Build Phase of I2C DRIVER");
super.build_phase(phase);
		  

  endfunction

  virtual function void connect_phase(uvm_phase phase);
super.connect_phase(phase);
$display("I'm in Connect Phase of I2C DRIVER");
if(!uvm_config_db #(virtual uart_to_i2c_interface)::get(null,"*","virtual_intf", v_intf))
		begin
		`uvm_fatal("NO_VIF", "Failed to get virtual interface");
		end    

  endfunction


  // run phase
  task run_phase(uvm_phase phase);
$display("I'm in Run Phase of I2C DRIVER");
    // wait for initial reset
    @(negedge v_intf.reset);
    v_intf.sdarx =1;

    forever begin
      seq_item_port.get_next_item(data_packet_i2c); 

      $display("\n\n\n\n-------------start_i2c_transaction---------------\n\n");
      data_packet_i2c.print();

      // send start
      v_intf.sdarx = 0;
      forever begin
	#(i2c_half);
	  sclk = ~sclk;
      end
      $display("I2C_TX start: @%0t", $time);

      // address and read_write info
      for(int a = ($bits(data_packet_i2c.address) - 1); a >= 0 ; a--) begin
	v_intf.sdarx = data_packet_i2c.address[a];
	$display("I2C_TX bit: %d @%0t", v_intf.sdarx, $time);
      end
      
      v_intf.sdarx = data_packet_i2c.r_w;
      $display("I2C_TX byte: 0x%0x @%0t", {data_packet_i2c.address, data_packet_i2c.r_w}, $time);


      foreach(data_packet_i2c.data_queue[b]) begin
	// send byte info
	for(int a = ($bits(data_packet_i2c.data_queue[a]) - 1); a >= 0 ; a--) begin
	  v_intf.sdarx = data_packet_i2c.data_queue[b][a];
	  $display("I2C_TX driven bit: %d @%0t", v_intf.sdarx, $time);
	end
	$display("I2C_TX driven byte: 0x%0x @%0t", data_packet_i2c.data_queue[b], $time);
      end

      // send stop
      $display("I2C_TX driving stop: @%0t", $time);
      v_intf.sdarx=0;
      #i2c_quarter;
      if(sclk==1) begin
      while(sclk==0)
      #10;
      #i2c_quarter;
      v_intf.sdarx=1;
      #i2c_half;


      $display("\n\n------------------I2C Transaction COMPLETE ---------------------\n\n\n\n");
    end
	end
  endtask

endclass






