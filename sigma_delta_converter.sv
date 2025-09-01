// Converts parallel audio output to a 1-bit output

module sigma_delta_converter #(parameter AUDIO_WIDTH = 8)
(
    input                   clock,
    input                   reset,
    input [AUDIO_WIDTH-1:0] audio_in,
    output logic            dac_out
);

    logic [AUDIO_WIDTH:0] integrator;
    logic [AUDIO_WIDTH:0] feedback;
    logic [AUDIO_WIDTH:0] error;

    always_ff @(posedge clock or posedge reset) begin
        if (reset) begin
            integrator <= 0;
            dac_out <= 0;
        end else begin
            feedback = dac_out ? (1 << AUDIO_WIDTH) : 0;  // 256 or 0
            error = audio_in - feedback;
            integrator = integrator + error;
            dac_out <= integrator[AUDIO_WIDTH];  // MSB
        end
    end

endmodule