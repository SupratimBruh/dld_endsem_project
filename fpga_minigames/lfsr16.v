// Free-running 16-bit LFSR (taps 16,14,13,11). Never reset by game selection,
// so the value sampled at a human button press is effectively random.
module lfsr16(
    input  wire        clk,
    output wire [15:0] q
);
    reg [15:0] r;
    initial r = 16'hACE1;
    always @(posedge clk) r <= {r[14:0], r[15] ^ r[13] ^ r[12] ^ r[10]};
    assign q = r;
endmodule
