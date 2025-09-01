


module synth (
    input clock,
    input uart_rx,
    output uart_tx,
    output synth_out
);

parameter LFO_WIDTH = 8;

// Top Level Logic 
logic [26:0] main_counter;
wire reset;
wire [LFO_WIDTH-1:0] LFO_output;
wire [LFO_WIDTH-1:0] set_LFO_register;

wire uart_rx_ready;
wire uart_rx_byte;

wire uart_tx_serial_out;
wire uart_tx_active;
wire uart_tx_start;
wire uart_tx_finish;

logic [7:0] r_uart_tx_byte;

uart_rx #(.CLKS_PER_BIT(217)) uartRX (
    .i_Clock(clock),
    .i_RX_Serial(uart_rx),
    .o_RX_DV(uart_rx_ready),
    .o_RX_Byte(uart_rx_byte)
);

uart_tx #(.CLKS_PER_BIT(217)) uartTX (
    .i_Clock(clock),
    .i_TX_DV(uart_tx_start),             // activates transmission
    .i_TX_Byte(r_uart_tx_byte),          // input byte
    .o_TX_Active(uart_tx_active),        // high when transmitting
    .o_TX_Serial(uart_tx_serial_out),    // serial out
    .o_TX_Done(uart_tx_finish)           // high for 1 clk cycle when Tx completes
); 


/* ----------------- UART SYNTH COMMANDS -------------------
Single commands
0 --> Reset to 0
1 --> Reset to default values
USE MIDI ENCODINGS for the rest of the values (research this)

-----------------------------------------------------------*/


// LFO
logic [1:0] LFO_wave_type;
wire LFO_freq_en;
wire LFO_amp_en;

LFO #(.LFO_WIDTH(LFO_WIDTH)) LFO1 (
    .i_clock(clock),
    .i_reset(reset),
    .i_main_counter(main_counter),
    .i_amplitude_freq_reg(set_LFO_register),
    .i_freq_en(LFO_freq_en),
    .i_amp_en(LFO_amp_en),
    .i_wave_type_reg(LFO_wave_type),
    .o_LFO(LFO_output)
);

// TODO Note to Freq converter (ideally certain bits can represent the frequency in the encoding if possible)
note_2_freq n2f 
(
    .note_ready(),
    .i_uart_RX(),
    .cycles_per_note()
);

// TODO Oscillator Module (One for sub, one for main)


// TODO Mixer Module (Should be at least 2 bits bigger than output width)


// TODO Low Pass Filter


// TODO High Pass Filter


// TODO Delta-Sigma Converter
sigma_delta_converter #(.AUDIO_WIDTH(8)) dac
(
    .clock(clock),
    .reset(reset),
    .audio_in(audio),
    .dac_out(synth_out)
);

endmodule