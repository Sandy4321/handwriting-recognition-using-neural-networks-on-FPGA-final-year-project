module pulse_generator #(
	parameter PULSE_WIDTH = 32'd1
	)(
	input wire clk,
	input wire reset,
	input wire generate_pulse,
	output reg pulse
	);
 
	reg [31:0] count;
	reg previous_pulse_value,previous_pulse_value_next;
	
	always @* begin
		pulse = (previous_pulse_value != generate_pulse);
	end
	
	always @(posedge(clk),posedge(reset))  begin
		if(reset) begin
			previous_pulse_value <= 0;
		end else begin
			previous_pulse_value <= previous_pulse_value_next;
		end
	end
	
	always @* begin
		if(previous_pulse_value != generate_pulse) begin
			previous_pulse_value_next = generate_pulse;
		end else begin
			previous_pulse_value_next = previous_pulse_value;
		end
	end

endmodule

// module stimulus();
// 	reg CLK,GENERATE_PULSE;
// 	wire PULSE;

// 	pulse_generator #(.PULSE_WIDTH(32'd1))
// 		p(
// 			.clk(CLK),
// 			.generate_pulse(GENERATE_PULSE),
// 			.pulse(PULSE)
// 		);

// 	initial begin
// 		$dumpfile("simulation.vcd");
// 		$dumpvars(0,
// 			CLK,
// 			PULSE,
// 			GENERATE_PULSE
// 		);
// 	end

// 	initial begin
// 		CLK = 1'b0;
// 		GENERATE_PULSE = 1'b0;
// 	end

// 	always begin
// 		#1 CLK = ~ CLK;
// 	end

// 	always begin
// 		#10 GENERATE_PULSE = ~ GENERATE_PULSE;
// 	end

// 	initial begin
// 		#100 $finish;
// 	end
// endmodule // module