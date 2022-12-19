


class i2c_monitor extends uvm_monitor;
    `uvm_component_utils(i2c_monitor)
     
     i2c_received_sequence_item i2c_message_to_be_sent;
     virtual uart_to_i2c_interface v_intf;	
     typedef enum {
    idle,
    start,
    data,
    stop_i2c
} state;
     state state1;
     uvm_analysis_port #(i2c_received_sequence_item) i2c_port;
     bit [7:0] byte_to_sent;
     function new (string name = "", uvm_component parent = null);
	super.new(name, parent);
        i2c_port = new("i2c_port",this);
     endfunction : new

	function void build_phase(uvm_phase phase);
	super.build_phase(phase);
	
	$display("I'm in Build Phase of I2C MONITOR");
	endfunction : build_phase


    virtual function void connect_phase (uvm_phase phase);
	 $display("I'm in Connect Phase of I2C MONITOR");
if(!uvm_config_db #(virtual uart_to_i2c_interface)::get(null,"*","virtual_intf", v_intf))
          begin
           `uvm_fatal("NO_VIF", "Failed to get virtual interface");
          end

        endfunction : connect_phase
     
    virtual task run_phase(uvm_phase phase);
	 $display("I'm in Connect Phase of I2C MONITOR");
i2c_message_to_be_sent = new();
       state1 = idle;
       case(state1)
           idle : begin
	       i2c_message_to_be_sent.data_queue = {};
  	       forever begin
	           @ (posedge v_intf.sdatx);
	           if (v_intf.scl) begin
		       break;
	           end
	       end
            state1 = start;
	end
           start : begin
               fork : i2c_data
                   begin
		       forever begin
		           for (int i = 0; i < 8; i++) begin
			       @ (posedge v_intf.scl);
			       byte_to_sent[i] = v_intf.sdatx;
			   end
			i2c_message_to_be_sent.data_queue.push_back(byte_to_sent);
		       end
   		   end
		begin forever
		    begin
			@ (posedge v_intf.sdatx);
			if (v_intf.scl) begin
			    state1 = stop_i2c;
			    i2c_port.write(i2c_message_to_be_sent);
 			    break;
			end
		    end
		end
		join_any
		    disable i2c_data;
           end
          stop_i2c: begin
	      state1 = idle;
          end
      
       endcase


    endtask : run_phase

endclass : i2c_monitor


`uvm_analysis_imp_decl(_i2c_data)
`uvm_analysis_imp_decl(_i2c_stop_signal)
class i2cmonnn extends uvm_monitor;
  uvm_analysis_imp_i2c_data#(bit[7:0], i2cmonnn) i2cdataimp;
  uvm_analysis_imp_i2c_stop_signal#(bit, i2cmonnn) i2cstopimp;
 
  uvm_analysis_port#(Cmd) i2cmsgport;

  
  bit next_stop;
  Cmd i2x_rx_msg;
  int remaining_bytes;
  bit[7:0] i2c_rx_q [$];
  `uvm_component_utils(i2cmonnn)

  function new(string name="bridgemonitor", uvm_component parent = null);
    super.new(name, parent);
    i2cdataimp = new("i2cdataimp", this);
    i2cstopimp = new("i2cstopimp", this);
    i2cmsgport = new("i2cmsgport", this);
  endfunction : new

  function void write_i2c_stop_signal(bit stop);
    $display("I2C_RX: received stop @%t", $time);
    i2x_rx_msg.len = i2x_rx_msg.data_queue.size();
    i2cmsgport.write(i2x_rx_msg);
    i2c_rx_q.delete();
    i2x_rx_msg = null;
  endfunction


  function void write_i2c_data(bit[7:0] data);
    $display("I2C_RX: Received Byte: 0x%x @%t", data, $time);
    if(i2c_rx_q.size() == 0) begin
      i2c_rx_q.push_back(data);
      i2x_rx_msg = new("i2c_rx_msg");
      i2x_rx_msg.address = data[7:1];
      i2x_rx_msg.r_w = read_write'(data[0]);
      next_stop = 0;
    end

    else begin
      i2c_rx_q.push_back(data);
      i2x_rx_msg.data_queue.push_back(data);
    end
  endfunction

endclass
