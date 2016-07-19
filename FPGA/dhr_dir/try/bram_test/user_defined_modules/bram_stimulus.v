`include "uart_core/uart_core.v"
`include "utils/reset_controller.v"
`include "bram.v"

module bram_stimulus (
	// standard signals
	input wire CLK,
	input wire RESET_SWITCH,
	output wire RESET, 
	// transmitter related signals
	output wire TX,
	// receiver related signals
	input wire RX,
	output wire RX_DONE_TICK
	);

	// local variables
		// transmitter related signals   
		reg TX_START_TRANSMISSION;
		wire TX_BUSY; 
		reg [7:0] TX_DATA_IN;
		// receiver related signals
		wire [7:0] RX_DATA_OUT;
		// block_ram
		reg READ_OR_WRITE;
		wire TRIGGER_ACTION;
		wire OUTPUT_READY;
		reg [7:0] START_ADDRESS;
		reg [31:0] INPUT_DATA;
		wire [31:0] OUTPUT_DATA;
		reg [7:0] NO_OF_BYTES;
		wire READ_COMPLETE;
		reg bram_start_operation;
		// testing_related_local_signals
		reg [4:0] write_count;
		reg address_flag;


	// module instantiations
	uart_core u(
		.clk(CLK),
		.reset(RESET),
		.rx_done_tick(RX_DONE_TICK),
		.tx_start_transmission(TX_START_TRANSMISSION),
		.tx_busy(TX_BUSY),
		.rx(RX),
		.rx_data_out(RX_DATA_OUT),
		.tx(TX),
		.tx_data_in(TX_DATA_IN)
		);

	reset_controller r(
		.clk(CLK),
		.reset(RESET),
		.switch_input(RESET_SWITCH)
		);

	bram b(
		.clk           (CLK),
		.reset         (RESET),
		.read_or_write (READ_OR_WRITE),
		.trigger_action(TRIGGER_ACTION),
		.output_ready  (OUTPUT_READY),
		.start_address (START_ADDRESS),
		.input_data    (INPUT_DATA),
		.output_data   (OUTPUT_DATA),
		.no_of_bytes   (NO_OF_BYTES),
		.read_complete (READ_COMPLETE)
		);
	
	pulse_generator #(
		.PULSE_WIDTH(32'd1)
		) pulse_gen(
		.clk(CLK),
		.generate_pulse(bram_start_operation), // toggle pulse generator
		.pulse(TRIGGER_ACTION) // generates a PULSE on this wire
		);

	always @(posedge CLK , posedge RESET ) begin

		if(RESET) begin
			// bram
			READ_OR_WRITE <= 0;
			START_ADDRESS <= 0;
			INPUT_DATA <= 0;
			NO_OF_BYTES <= 0;
			bram_start_operation <= 0;
			// local
			write_count <= 0;
			address_flag <= 0;
		end // if(RESET)
		else if(RX_DONE_TICK) begin
			if(write_count < 20) begin
				START_ADDRESS[7:0] <= write_count;
				INPUT_DATA <= RX_DATA_OUT;
				bram_start_operation <= ~bram_start_operation;
				write_count <= write_count + 1;
			end // if(write_count < 20)
			else begin
				READ_OR_WRITE <= 1;
				if(address_flag == 0) begin
					START_ADDRESS[7:0] <= RX_DATA_OUT;
				end // if(address_flag == 0)
				else begin
					NO_OF_BYTES <= RX_DATA_OUT;
			  		bram_start_operation <= ~bram_start_operation;
				end // else
			end // else
		end // else if(RX_DONE_TICK) 
	end // always @(posedge(CLK), posedge(RESET))

	always @(posedge CLK) begin
		if(OUTPUT_READY) begin
			TX_DATA_IN = OUTPUT_DATA[7:0];
			TX_START_TRANSMISSION = ~TX_START_TRANSMISSION;
		end // if(OUTPUT_READY)
		else begin
			TX_START_TRANSMISSION = 0;
			TX_DATA_IN = 0;
		end // else
	end // always @(posedge CLK)

endmodule
