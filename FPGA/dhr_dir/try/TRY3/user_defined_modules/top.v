`include "../ipcore_dir/FIFO.v"
`include "integer_seven_segment_display_controller/integer_seven_segment_display_controller.v"
`include "uart_core/uart_core.v"
//`include "tick_generator.v"

module top(
	input wire clk,
	input wire reset,
	// test signals
	output wire [7:0] fifo_din_test,
	output wire [7:0] fifo_dout_test,
	output wire [6:0] data_count_test,
	output wire rd_en_test,
	output wire wr_en_test,
	output wire one_second_tick_test,
	output wire one_second_pulse_test,
	output wire [7:0] count_test,
	output wire fifo_empty_test
	);
	
	wire [7:0] fifo_din;
	assign fifo_din_test = fifo_din;
	wire [7:0] fifo_dout;
	assign fifo_dout_test = fifo_dout;
	wire fifo_rd_en;
	assign rd_en_test = fifo_rd_en;
	assign fifo_rd_en = 1;
	reg fifo_wr_en;
	assign wr_en_test = fifo_wr_en;
	wire [6:0] data_count;
	assign data_count_test = data_count;
	wire fifo_empty;
	assign fifo_empty_test = fifo_empty;
	
	FIFO fifo_instance1(
		.clk(clk),
		.srst(reset),
		.rd_en(fifo_rd_en),
		.wr_en(fifo_wr_en),
		.din(fifo_din),
		.dout(fifo_dout),
		.data_count(data_count),
		.empty(fifo_empty)
	);
	
	wire one_second_tick;
	assign one_second_tick_test = one_second_tick;
	
//	tick_generator #(.tick_time(1000),.frequency(1000000))
	tick_generator #(.tick_time(1),.frequency(4))
		tick_generator_instance1(
			.clk(clk),
			.reset(reset),
			.tick(one_second_tick)
		);
	
	wire one_second_pulse;
	assign one_second_pulse_test = one_second_pulse;
	
	pulse_generator pulse_generator_instance1(
		.clk(clk),
		.reset(reset),
		.generate_pulse(one_second_tick),
		.pulse(one_second_pulse)
	);
	
	reg [7:0] count;
	assign fifo_din = count;
	assign count_test = count;
	
	// state declarations
	localparam [1:0] 
		idle = 2'b00,
		writing = 2'b01,
		reading = 2'b10;
	
	always @(posedge(clk),posedge(reset)) begin
		if(reset) begin
			count <= 0;
			fifo_wr_en <= 0;
		end else begin
			if(one_second_pulse) begin
				count <= count + 1;
				fifo_wr_en <= 1;
			end else begin
				count <= count;
				fifo_wr_en <= 0;
			end
		end
	end
	
endmodule
