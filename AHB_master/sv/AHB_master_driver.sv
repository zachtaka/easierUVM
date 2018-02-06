// You can insert code here by setting file_header_inc in file common.tpl

//=============================================================================
// Project  : generated_tb
//
// File Name: AHB_master_driver.sv
//
//
// Version:   1.0
//
// Code created by Easier UVM Code Generator version 2016-08-11 on Mon Jan 22 15:51:47 2018
//=============================================================================
// Description: Driver for AHB_master
//=============================================================================

`ifndef AHB_MASTER_DRIVER_SV
`define AHB_MASTER_DRIVER_SV

// You can insert code here by setting driver_inc_before_class in file AHB_master.tpl
import tb_parameters::*;
class AHB_master_driver extends uvm_driver #(trans);

  `uvm_component_utils(AHB_master_driver)

  virtual AHB_master_if vif;
  AHB_master_config m_config;

  extern function new(string name, uvm_component parent);

  // You can insert code here by setting driver_inc_inside_class in file AHB_master.tpl

  /*-------------------------------------------------------------------------------
	-- Functions
	-------------------------------------------------------------------------------*/
	function void build_phase(uvm_phase phase);
		if (!uvm_config_db #(AHB_master_config)::get(this, "", "config", m_config))
    		`uvm_error(get_type_name(), "AHB_master config not found")
	endfunction : build_phase

	function burst_t len2burst(int length);
		case (length)
			1:  return SINGLE;
			4:  return INCR4;
			8:  return INCR8;
			16: return INCR16;
			default: return INCR;
		endcase	
	endfunction : len2burst

	/*-------------------------------------------------------------------------------
	-- Tasks
	-------------------------------------------------------------------------------*/

	task reset_address_phase();
		vif.HTRANS <= 0;
		vif.HBURST <= 0;
		vif.HADDR  <= 0;
		vif.HSIZE  <= 0;
		vif.HWRITE <= 0;
	endtask : reset_address_phase

	task reset_data_phase();
		vif.HWDATA <= 0;
	endtask : reset_data_phase

	task reset();
		reset_address_phase();
		reset_data_phase();
	endtask : reset


	bit[ADDRESS_WIDTH-1:0] address;
	bit[2:0] size;
	trans trans;
	// Add execute_address_phase()
	task execute_address_phase();
		while(!($urandom_range(0,99)<GEN_RATE)) begin 
			@(posedge vif.clk);
			reset_address_phase();
		end
		seq_item_port.get_next_item(trans);
		for (int i = 0; i < trans.length; i++) begin
			// Address phase
			@(posedge vif.clk);
			vif.HTRANS <= (i==0) ? NONSEQ : SEQ;
			vif.HADDR <= trans.start_address + i*(2**trans.size);
			vif.HWRITE <= trans.write;
			vif.HBURST <= len2burst(trans.length);
			vif.HSIZE <= trans.size;
			address = vif.HADDR;
			size = vif.HSIZE;

			// Data phase
			@(negedge vif.clk);
			wait(vif.HREADY);
			fork
				if (trans.write) execute_data_phase();
			join_none
			
		end
		seq_item_port.item_done();

	endtask : execute_address_phase

	task execute_data_phase();
		@(posedge vif.clk); 
		vif.HWDATA <= get_data(address,size);
	endtask : execute_data_phase

	task run_phase(uvm_phase phase);
		phase.raise_objection(this);
		wait(vif.rst_n);
		repeat (TOTAL_TRANSFERS) begin
			execute_address_phase();
		end
		@(posedge vif.clk);
		reset_address_phase();
		phase.drop_objection(this);
	endtask : run_phase


endclass : AHB_master_driver 


function AHB_master_driver::new(string name, uvm_component parent);
  super.new(name, parent);
endfunction : new


// You can insert code here by setting driver_inc_after_class in file AHB_master.tpl

`endif // AHB_MASTER_DRIVER_SV
