`timescale 1ns/1ps

module tb_sigma_delta_converter;

parameter CLK_PERIOD = 40;


logic           clock;
logic           reset;
logic [7:0]     audio;
logic           dac_out;


integer random;

// DUT
sigma_delta_converter #(.AUDIO_WIDTH(8)) dut
(
    .clock(clock),
    .reset(reset),
    .audio_in(audio),
    .dac_out(dac_out)
);

// Clock Generation
initial clock = 0;
always #(CLK_PERIOD/2) clock = ~clock;

// initial
initial begin
audio = 127;
reset = 1;



@(posedge(clock))
reset = 0;

#4000
audio = 0;

#4000
audio = 50;

#4000
audio = 100;

#4000
audio = 130;

#4000
audio = 180;

#4000
audio = 215;

#4000
audio = 255;

while (1) begin

random = $urandom_range(100 * CLK_PERIOD, 1000 * CLK_PERIOD);
#random
audio = $urandom_range(0,255);
end 

end


endmodule
