`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   20:09:19 03/22/2016
// Design Name:   top
// Module Name:   C:/Users/dhrre/Desktop/Projects/Handwriting_recog/FPGA/dhr_dir/try/TRY3/top_tb.v
// Project Name:  TRY3
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: top
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module top_tb;

	// Inputs
	reg clk;
	reg reset;

	// Outputs
	wire [7:0] fifo_din_test;
	wire [7:0] fifo_dout_test;
	wire [6:0] data_count_test;
	wire rd_en_test;
	wire wr_en_test;
	wire one_second_tick_test;
	wire one_second_pulse_test;
	wire [7:0] count_test;
	wire fifo_empty_test;

	// Instantiate the Unit Under Test (UUT)
	top uut (
		.clk(clk), 
		.reset(reset), 
		.fifo_din_test(fifo_din_test), 
		.fifo_dout_test(fifo_dout_test), 
		.data_count_test(data_count_test), 
		.rd_en_test(rd_en_test), 
		.wr_en_test(wr_en_test), 
		.one_second_tick_test(one_second_tick_test), 
		.one_second_pulse_test(one_second_pulse_test), 
		.count_test(count_test),
		.fifo_empty_test(fifo_empty_test)
	);

	initial begin
		// Initialize Inputs
		clk = 0;
		reset = 1;

		// Wait 100 ns for global reset to finish
		#100;
        
		// Add stimulus here
		reset = 0;
	end
	
	always begin
		#1 clk = ~ clk;
	end
      
endmodule

