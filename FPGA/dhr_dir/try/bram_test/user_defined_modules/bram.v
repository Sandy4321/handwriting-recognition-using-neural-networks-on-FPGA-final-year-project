
module bram(
	// standard definitions
	input wire clk,
	input wire reset,

	// control signals
	input wire read_or_write,
	input wire trigger_action,
	output wire output_ready,

	// data signals
	input wire  [7:0] start_address,
	input wire  [31:0] input_data,
	output wire [31:0] output_data,

	// other signals
	input wire  [7:0] no_of_bytes,
	output reg read_complete
	);

	// local parameters
	reg [7:0] address;
	// read
		reg [7:0] count;
		reg [7:0] next_count;
		reg read_ce;
		reg output_ce;
	// write
		reg write_ce;

	assign output_ready = output_ce;

	// state name declaration
	localparam [1:0]
		idle_state  = 2'b00,
		write_state = 2'b01,
		read_state  = 2'b10;

	// state registers declaration
	reg [1:0] current_state;
	reg [1:0] next_state;

	// BRAM_SDP_MACRO: Simple Dual Port RAM  Spartan-6
	// Xilinx HDL Language Template, version 14.7

	BRAM_SDP_MACRO #(
		.BRAM_SIZE("9Kb"), // Target BRAM, "9Kb" or "18Kb" 
		.DEVICE("SPARTAN6"), // Target device: "VIRTEX5", "VIRTEX6", "SPARTAN6" 
		.WRITE_WIDTH(32),    // Valid values are 1-36
		.READ_WIDTH(32),     // Valid values are 1-36
		.DO_REG(0),         // Optional output register (0 or 1)
		.INIT_FILE ("NONE"),
		.SIM_COLLISION_CHECK ("ALL"), // Collision check enable "ALL", "WARNING_ONLY", 
		                            //   "GENERATE_X_ONLY" or "NONE" 
		.SRVAL(72'd0), // Set/Reset value for port output
		.INIT(72'd0),  // Initial values on output port
		.INIT_00(256'd0),
		.INIT_01(256'd0),
		.INIT_02(256'd0),
		.INIT_03(256'd0),
		.INIT_04(256'd0),
		.INIT_05(256'd0),
		.INIT_06(256'd0),
		.INIT_07(256'd0),
		.INIT_08(256'd0),
		.INIT_09(256'd0),
		.INIT_0A(256'd0),
		.INIT_0B(256'd0),
		.INIT_0C(256'd0),
		.INIT_0D(256'd0),
		.INIT_0E(256'd0),
		.INIT_0F(256'd0),
		.INIT_10(256'd0),
		.INIT_11(256'd0),
		.INIT_12(256'd0),
		.INIT_13(256'd0),
		.INIT_14(256'd0),
		.INIT_15(256'd0),
		.INIT_16(256'd0),
		.INIT_17(256'd0),
		.INIT_18(256'd0),
		.INIT_19(256'd0),
		.INIT_1A(256'd0),
		.INIT_1B(256'd0),
		.INIT_1C(256'd0),
		.INIT_1D(256'd0),
		.INIT_1E(256'd0),
		.INIT_1F(256'd0),
		          
		// The next set of INITP_xx are for the parity bits
		.INITP_00(256'd0),
		.INITP_01(256'd0),
		.INITP_02(256'd0),
		.INITP_03(256'd0)

	) BRAM_SDP_MACRO_instance (
		.DO(output_data),      			// Output read data port, width defined by READ_WIDTH parameter
		.DI(input_data),      			// Input write data port, width defined by WRITE_WIDTH parameter
		.RDADDR(address),				// Input read address, width defined by read port depth
		.RDCLK(clk),					// 1-bit input read clock
		.RDEN(read_ce),  				// 1-bit input read port enable
		.REGCE(output_ce),				// 1-bit input read output register enable
		.RST(reset),    				// 1-bit input reset      
		.WE(4'b1111),      				// Input write enable, width defined by write port depth
		.WRADDR(address),				// Input write address, width defined by write port depth
		.WRCLK(clk),					// 1-bit input write clock
		.WREN(write_ce)   					// 1-bit input write port enable
		);

	// End of BRAM_SDP_MACRO_inst instantiation

	// state register updation
	always @(posedge clk, posedge reset) begin
		if(reset) begin
			current_state <= idle_state;
			count <= 1;
		end // if(reset)
		else begin
			current_state <= next_state;
			count <= next_count;
		end // else
	end // always @(posedge clk, posedge reset)

/*
input:
			trigger_action		read_or_write		no_of_bytes			start_address
intermediate:
			count 				next_count 			address 			
outputs:
			write_ce 			read_complete		read_ce 			output_ce
*/

	// next state logic and output logic
	always @* begin
		// default values
		next_state = idle_state;
		next_count = count;
		address = start_address;
		write_ce = 0;
		read_ce = 0;
		read_complete = 0;
		output_ce = 0;
		case (current_state)
			
			idle_state: begin
				next_count = 1;
				if(trigger_action == 1) begin
					if(read_or_write == 1) begin
						read_ce = 1;
						next_state = read_state;
					end // if(read_or_write == 1)
					else begin
						write_ce = 1;
						next_state = write_state;
					end // else
				end // if(trigger_action == 1)
			end // idle_state:

			read_state: begin
				output_ce = 1;
				if(no_of_bytes > count) begin
					next_count = count + 1;
					address = start_address + count;
					read_ce = 1;
					next_state = current_state;
				end // if(no_of_bytes != count)
				else begin
					if(trigger_action == 1) begin
						if(read_or_write == 1) begin
							next_count = 1;
							read_ce = 1;
							next_state = current_state;
						end // if(read_or_write == 1)
						else begin
							write_ce = 1;
							next_state = write_state;
						end // else
					end // if(trigger_action == 1)
					else begin
						read_complete = 1;
					end // else
				end // else
			end // read_state:

			write_state:  begin
				if(trigger_action == 1) begin
					if(read_or_write == 1) begin
						next_count = 1;
						read_ce = 1;
						next_state = read_state;
					end // if(read_or_write == 1)
					else begin
						write_ce = 1;
						next_state = write_state;
					end // else
				end // if(trigger_action == 1)
			end // write_state:
		endcase // current_state
	end // always @*

endmodule


// module testbench();
// 	reg CLK;
// 	reg RESET;
// 	reg READ_OR_WRITE;
// 	reg TRIGGER_ACTION;
// 	wire OUTPUT_READY;
// 	reg [7:0] START_ADDRESS;
// 	reg [31:0] INPUT_DATA;
// 	wire [31:0] OUTPUT_DATA;
// 	reg [7:0] NO_OF_BYTES;
// 	wire READ_COMPLETE;

// 	bram b(
// 		.clk               	(CLK),
// 		.reset             	(RESET),
// 		.read_or_write     	(READ_OR_WRITE),
// 		.trigger_action    	(TRIGGER_ACTION),
// 		.output_ready      	(OUTPUT_READY),
// 		.start_address     	(START_ADDRESS),
// 		.input_data        	(INPUT_DATA),
// 		.output_data       	(OUTPUT_DATA),
// 		.no_of_bytes       	(NO_OF_BYTES),
// 		.read_complete		(READ_COMPLETE)
// 		);

// 	initial begin
// 		CLK = 0;
// 		RESET = 0;
// 		READ_OR_WRITE = 0;
// 		TRIGGER_ACTION = 0;
// 		START_ADDRESS = 0;
// 		INPUT_DATA = 0;
// 		NO_OF_BYTES = 0;
// 	end

// 	always begin
// 		#5 CLK = ~CLK;
// 	end

// 	initial begin
// 		#105 RESET <= 0;
// 		#10 RESET <= 1;
// 		#10 RESET <= 0;

// 		// 0 ----- 23
// 		#30 START_ADDRESS <= 0; 
// 		INPUT_DATA <= 23;
// 		TRIGGER_ACTION <= 1;
// 		#10 TRIGGER_ACTION <= 0;
		
// 		// read 0
// 		#10 READ_OR_WRITE <= 1;
// 		TRIGGER_ACTION <= 1;
// 		#10 TRIGGER_ACTION <= 0;
		
// 		#10 READ_OR_WRITE <= 0;

// 		// 10 --- 6
// 		#50 START_ADDRESS <= 10; 
// 		INPUT_DATA <= 6;
// 		TRIGGER_ACTION <= 1;
// 		#10 TRIGGER_ACTION <= 0;
				
// 		// 0 --- 56
// 		#10 START_ADDRESS <= 0; 
// 		INPUT_DATA <= 56;
// 		TRIGGER_ACTION <= 1;
// 		#10 TRIGGER_ACTION <= 0;
		
// 		// 1 --- 84
// 		#10 START_ADDRESS <= 1; 
// 		INPUT_DATA <= 84;
// 		TRIGGER_ACTION <= 1;
// 		#10 TRIGGER_ACTION <= 0;
		
// 		// 2 --- 102
// 		#10 START_ADDRESS <= 2; 
// 		INPUT_DATA <= 102;
// 		TRIGGER_ACTION <= 1;
// 		#10 TRIGGER_ACTION <= 0;
		
// 		// 3 --- 510
// 		#10 START_ADDRESS <= 3; 
// 		INPUT_DATA <= 510;
// 		TRIGGER_ACTION <= 1;
// 		#10 TRIGGER_ACTION <= 0;
		
// 		// 4 --- 633
// 		#10 START_ADDRESS <= 4; 
// 		INPUT_DATA <= 633;
// 		TRIGGER_ACTION <= 1;
// 		#10 TRIGGER_ACTION <= 0;
		
// 		// 20 --- 814
// 		#10 START_ADDRESS <= 20; 
// 		INPUT_DATA <= 814;
// 		TRIGGER_ACTION <= 1;
// 		#10 TRIGGER_ACTION <= 0;
		
// 		// 21 --- 12
// 		#10 START_ADDRESS <= 21; 
// 		INPUT_DATA <= 12;
// 		TRIGGER_ACTION <= 1;
// 		#10 TRIGGER_ACTION <= 0;
		
// 		// 22 --- 4
// 		#10 START_ADDRESS <= 22; 
// 		INPUT_DATA <= 4;
// 		TRIGGER_ACTION <= 1;
// 		#10 TRIGGER_ACTION <= 0;
		
// 		// 43 --- 422
// 		#10 START_ADDRESS <= 43; 
// 		INPUT_DATA <= 422;
// 		TRIGGER_ACTION <= 1;
// 		#10 TRIGGER_ACTION <= 0;
		
// 		// 44 --- 123
// 		#10 START_ADDRESS <= 44; 
// 		INPUT_DATA <= 123;
// 		TRIGGER_ACTION <= 1;
// 		#10 TRIGGER_ACTION <= 0;
		
// 		// 253 --- 234
// 		#10 START_ADDRESS <= 253; 
// 		INPUT_DATA <= 234;
// 		TRIGGER_ACTION <= 1;
// 		#10 TRIGGER_ACTION <= 0;
		
// 		// 254 --- 345
// 		#10 START_ADDRESS <= 254; 
// 		INPUT_DATA <= 345;
// 		TRIGGER_ACTION <= 1;
// 		#10 TRIGGER_ACTION <= 0;

// 		// 255 --- 789
// 		#10 START_ADDRESS <= 255; 
// 		INPUT_DATA <= 789;
// 		TRIGGER_ACTION <= 1;
// 		#10 TRIGGER_ACTION <= 0;		

// //		// read 0
// //		READ_OR_WRITE <= 1; 
// //		START_ADDRESS <= 0;
// //		#10 TRIGGER_ACTION <= 1;
// //		#10 TRIGGER_ACTION <= 0;
		
// 		// read 0 - 4
// 		#20 READ_OR_WRITE <= 1;
// 		START_ADDRESS <= 0;
// 		#10 NO_OF_BYTES <= 5;
// 		TRIGGER_ACTION <= 1;
// 		#10 TRIGGER_ACTION <= 0;
		
// 		// read 0
// 		#100 NO_OF_BYTES <= 1;
// 		START_ADDRESS <= 0;
// 		TRIGGER_ACTION <= 1;
// 		#10 TRIGGER_ACTION <= 0;
		
// 		// read 1
// 		#40 START_ADDRESS <= 1;
// 		TRIGGER_ACTION <= 1;
// 		#10 TRIGGER_ACTION <= 0;
		
// 		// read 10
// 		#40 START_ADDRESS <= 10;
// 		TRIGGER_ACTION <= 1;
// 		#10 TRIGGER_ACTION <= 0;
		
// 		// read 20 - 23
// 		#20 READ_OR_WRITE <= 1;
// 		START_ADDRESS <= 20;
// 		#10 NO_OF_BYTES <= 4;
// 		TRIGGER_ACTION <= 1;
// 		#10 TRIGGER_ACTION <= 0;
		
// 		// read 43 - 44
// 		#80 READ_OR_WRITE <= 1;
// 		START_ADDRESS <= 43;
// 		#10 NO_OF_BYTES <= 2;
// 		TRIGGER_ACTION <= 1;
// 		#10 TRIGGER_ACTION <= 0;
		
// 		// read 253 - 255
// 		#80 READ_OR_WRITE <= 1;
// 		START_ADDRESS <= 253;
// 		#10 NO_OF_BYTES <= 3;
// 		TRIGGER_ACTION <= 1;
// 		#10 TRIGGER_ACTION <= 0;
				
// 	end

// endmodule
