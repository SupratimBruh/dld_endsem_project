// 4-digit multiplexed 7-segment driver.
// disp nibbles (digit3..digit0): 0-9 digits, A, b, C, d, E, F = blank.
// seg[6:0] = {g,f,e,d,c,b,a}.  an[0] = rightmost digit.
module seg7_driver #(
    parameter SEG_ACTIVE_LOW = 0,
    parameter AN_ACTIVE_LOW  = 0
)(
    input  wire        clk,
    input  wire [15:0] disp,
    output wire [6:0]  seg,
    output wire [3:0]  an
);
    reg [15:0] rc;
    initial rc = 0;
    always @(posedge clk) rc <= rc + 1;
    wire [1:0] d = rc[15:14];            // ~760 Hz refresh per digit at 50 MHz

    reg [3:0] nib, a;
    reg [6:0] s;
    always @(*) begin
        case (d)
            2'd0: begin nib = disp[3:0];   a = 4'b0001; end
            2'd1: begin nib = disp[7:4];   a = 4'b0010; end
            2'd2: begin nib = disp[11:8];  a = 4'b0100; end
            default: begin nib = disp[15:12]; a = 4'b1000; end
        endcase
        case (nib)
            4'h0: s = 7'h3F;  4'h1: s = 7'h06;  4'h2: s = 7'h5B;  4'h3: s = 7'h4F;
            4'h4: s = 7'h66;  4'h5: s = 7'h6D;  4'h6: s = 7'h7D;  4'h7: s = 7'h07;
            4'h8: s = 7'h7F;  4'h9: s = 7'h6F;  4'hA: s = 7'h77;  4'hB: s = 7'h7C;
            4'hC: s = 7'h39;  4'hD: s = 7'h5E;  4'hE: s = 7'h79;  default: s = 7'h00;
        endcase
    end
    assign seg = SEG_ACTIVE_LOW ? ~s : s;
    assign an  = AN_ACTIVE_LOW  ? ~a : a;
endmodule
