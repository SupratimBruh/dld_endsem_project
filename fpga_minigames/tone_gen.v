// Square-wave tone generator for the buzzer.
// 0 silent | 1 high beep (success) | 2 low buzz (failure) | 3..6 Simon colours | 7 spare
module tone_gen #(parameter CLK_HZ = 50_000_000)(
    input  wire       clk,
    input  wire [2:0] snd,
    output reg        buzz
);
    reg [19:0] half, cnt;
    initial begin buzz = 0; cnt = 0; end
    always @(*) begin
        case (snd)
            3'd1:    half = CLK_HZ/(2*1500);
            3'd2:    half = CLK_HZ/(2*200);
            3'd3:    half = CLK_HZ/(2*523);
            3'd4:    half = CLK_HZ/(2*659);
            3'd5:    half = CLK_HZ/(2*784);
            3'd6:    half = CLK_HZ/(2*988);
            default: half = CLK_HZ/(2*1319);
        endcase
    end
    always @(posedge clk) begin
        if (snd == 3'd0) begin cnt <= 0; buzz <= 0; end
        else if (cnt >= half - 1) begin cnt <= 0; buzz <= ~buzz; end
        else cnt <= cnt + 1;
    end
endmodule
