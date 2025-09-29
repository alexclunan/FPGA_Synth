// Assume 25 MHz Clock
/*
LFO module for a synth

*/

`define SQUARE 2'b00
`define TRIANGLE 2'b01
`define SAWTOOTH 2'b10
`define REVERSE_SAWTOOTH 2'b11


module LFO #(parameter LFO_WIDTH = 16)
(
    input wire          i_clock,
    input wire          i_reset,
    input wire [26:0]   i_main_counter,
    input wire [7:0]    i_amplitude_freq_reg,
    input wire          i_freq_en,
    input wire          i_amp_en,
    input wire [1:0]    i_wave_type_reg,
    output wire [LFO_WIDTH-1:0]   o_LFO
);


reg signed [LFO_WIDTH-1:0] LFO_state;
logic [LFO_WIDTH-1:0] freq_adder_comp;
logic [LFO_WIDTH-1:0] wave_shaper;
logic [LFO_WIDTH-2:0] amplitude_reg;
logic [15:0] freq_reg;
logic [1:0] output_ready_flag;
logic up_down_state; // 1 up, 0 down
logic wave_shaper_flag;


logic debug;

// wave types: 0-Square | 1-Triangle | 2-Sawtooth | 3-Reverse Sawtooth


always @(posedge(i_clock) or posedge(i_reset)) begin

    if (i_reset) begin
        LFO_state           <= 0;
        freq_adder_comp     <= 0;
        amplitude_reg       <= 0;
        freq_reg            <= 0;
        output_ready_flag   <= 0;
        up_down_state       <= 0;
        wave_shaper         <= 0;
        debug               <= 0;

    end else begin
    // Do the following when the counter reaches the end of the frequency loop
    if( (i_main_counter[26:26-LFO_WIDTH+1] == freq_adder_comp) && (output_ready_flag == 2'b11) ) begin
        
        // Set LFO based on wave type
        case (i_wave_type_reg)
            `SQUARE: begin
                if (LFO_state > -1) // If the state if greater than half the max amp value
                    LFO_state <= ~{1'b0, amplitude_reg[LFO_WIDTH-2:0]} + 1; // Set to negative amplitude
                else
                    LFO_state <= {1'b0, amplitude_reg[LFO_WIDTH-2:0]}; // Set to positive amplitude
            end 
            `TRIANGLE: begin
                if(up_down_state == 1'b1)
                    LFO_state <= LFO_state + 1'b1;
                else
                    LFO_state <= LFO_state - 1'b1;
            end
            `SAWTOOTH: begin
                LFO_state <= LFO_state + 1'b1;
            end
            `REVERSE_SAWTOOTH: begin
                LFO_state <= LFO_state - 1'b1;
            end
        endcase
        debug <= 1;
        // update the frequency comparison register and reset values
        freq_adder_comp <= freq_adder_comp + freq_reg;
        output_ready_flag <= 0;
        wave_shaper <= wave_shaper;

    end else begin
        debug <= 0;
         // Control logic for amplitude and frequency registers
         // sets output ready flag only when both are updated
        if (i_freq_en && i_amp_en) begin
            freq_reg <= freq_reg;
            amplitude_reg <= amplitude_reg;
            output_ready_flag <= 2'b11;
        end else begin
            if (i_freq_en) begin
                freq_reg <= i_amplitude_freq_reg;
                output_ready_flag[0] <= 1'b1;
            end else begin
                freq_reg <= freq_reg;
                output_ready_flag[0] <= output_ready_flag[0];
            end

            if (i_amp_en) begin
                amplitude_reg <= i_amplitude_freq_reg;
                output_ready_flag[1] <= 1'b1;
            end else begin
                amplitude_reg <= amplitude_reg;
                output_ready_flag[1] <= output_ready_flag[1];
            end
        end

        // Updates output inside of frequency intervals. This generates the shape of the wave
        // Triangle Wave needs to be updated 2^WIDTH * 2 times per period, Sawtooth Waves need to be updated 2^WIDTH times per period
        // After switch to signed numbers:  AMP_REG * 2 times per period
        if ((i_main_counter[26-LFO_WIDTH-1:26-LFO_WIDTH+1-LFO_WIDTH-1] == wave_shaper) && i_wave_type_reg == `TRIANGLE && wave_shaper_flag) begin
            wave_shaper <= wave_shaper + freq_reg * (amplitude_reg / -1);
            wave_shaper_flag <= 0;
            if(up_down_state == 1'b1)
                LFO_state <= LFO_state + 1'b1;
            else
                LFO_state <= LFO_state - 1'b1;
        end else if ((i_main_counter[26-LFO_WIDTH:26-LFO_WIDTH+1-LFO_WIDTH] == wave_shaper) && i_wave_type_reg == `SAWTOOTH && wave_shaper_flag) begin
            wave_shaper <= wave_shaper + freq_reg * (amplitude_reg / -1);
            wave_shaper_flag <= 0;
            LFO_state <= LFO_state + 1'b1;
        end else if ((i_main_counter[26-LFO_WIDTH:26-LFO_WIDTH+1-LFO_WIDTH] == wave_shaper) && i_wave_type_reg == `REVERSE_SAWTOOTH && wave_shaper_flag) begin
            wave_shaper <= wave_shaper + freq_reg * (amplitude_reg / -1);
            wave_shaper_flag <= 0;
            LFO_state <= LFO_state - 1'b1;
        end else begin
            wave_shaper <= wave_shaper;
            wave_shaper_flag <= 1;
            LFO_state <= LFO_state;
        end

        freq_adder_comp <= freq_adder_comp;
    end


    // Set triangle wave up/down state based on if the wave is at its min/max value
    if (LFO_state >= amplitude_reg)
        up_down_state <= 0;
    else if (LFO_state == 0)
        up_down_state <= 1;
    else 
        up_down_state <= up_down_state;

    end
end

assign o_LFO = LFO_state;
// To find frequency, compare vs the top 8 bits of the main counter vs the reg


endmodule
