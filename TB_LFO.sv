`timescale 1ns/1ps

module tb_LFO;

parameter CLK_PERIOD = 40;

// LFO inputs
logic           clock;
logic           reset;
logic [26:0]    main_counter;
logic [7:0]     amplitude_freq_reg;
logic           freq_en;
logic           amp_en;
logic [1:0]     wave_type_reg;

// LFO Output
logic [7:0] LFO;
integer random;

// DUT
LFO #(.LFO_WIDTH(8)) dut
(
    .i_clock(clock),
    .i_reset(reset),
    .i_main_counter(main_counter),
    .i_amplitude_freq_reg(amplitude_freq_reg),
    .i_freq_en(freq_en),
    .i_amp_en(amp_en),
    .i_wave_type_reg(wave_type_reg),
    .o_LFO(LFO)
);

// Clock Generation
initial clock = 0;
always #(CLK_PERIOD/2) clock = ~clock;

// initial
initial begin
main_counter = 0;
amplitude_freq_reg = 0;
freq_en = 0;
amp_en = 0;
wave_type_reg = 0;
reset = 1;

@(posedge(clock))
// set frequency and amplitude
reset = 0;
main_counter += 1;
freq_en = 1;
amplitude_freq_reg = 2;

@(posedge(clock))
freq_en = 0;
main_counter += 1;
amp_en = 1;
amplitude_freq_reg = 255;

@(posedge(clock))
amp_en = 1;
freq_en = 1;


while (1) begin

random = $urandom_range(30000000,300000000);
#random
wave_type_reg = $urandom_range(0,3);
end 

end

always @(posedge(clock)) begin
    main_counter += 1;
end

endmodule
