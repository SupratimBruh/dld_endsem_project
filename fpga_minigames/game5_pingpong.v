// Game 5: LED ping-pong, 2 players. P1 = BTN0 (LED0 end), P2 = BTN3 (LED11 end).
// Press when the ball is within the last two LEDs on your side to return it.
// Pressing too early or missing gives the opponent a point. First to 9 wins.
// Ball speeds up each return. Display: P1 score (left) | P2 score (right).
module game5_pingpong (
    input  wire        clk, rst, tick_1ms,
    input  wire [3:0]  b,
    output reg  [15:0] disp,
    output reg  [11:0] led,
    output reg  [2:0]  snd
);
    localparam SERVE=2'd0, RALLY=2'd1, POINT=2'd2, OVER=2'd3;
    reg [1:0]  st;
    reg [3:0]  pos, hits, p1, p2;
    reg        dir, server;           // dir: 1 = toward P2 (right), 0 = toward P1
    reg [10:0] ms;
    reg [9:0]  blink;
    reg [7:0]  bp;                    // hit-beep timer (ms)

    wire [10:0] interval = (hits >= 4'd11) ? 11'd88 : (11'd220 - hits*11'd12);
    wire in1   = (dir == 1'b0) && (pos <= 4'd1);
    wire in2   = (dir == 1'b1) && (pos >= 4'd10);
    wire ok1   = b[0] && in1;
    wire ok2   = b[3] && in2;
    wire flt1  = b[0] && !in1;
    wire flt2  = b[3] && !in2;
    wire step  = tick_1ms && (ms >= interval);
    wire miss1 = step && (dir == 1'b0) && (pos == 4'd0)  && !b[0];
    wire miss2 = step && (dir == 1'b1) && (pos == 4'd11) && !b[3];
    wire p1_gets = flt2 | miss2;
    wire p2_gets = flt1 | miss1;
    wire dir_eff = (ok1 | ok2) ? ~dir : dir;

    always @(posedge clk) begin
        if (rst) begin
            st<=SERVE; pos<=0; hits<=0; p1<=0; p2<=0; dir<=1; server<=0;
            ms<=0; blink<=0; bp<=0;
        end else begin
            if (tick_1ms) begin blink <= blink + 1; if (bp != 0) bp <= bp - 1; end
            case (st)
                SERVE: begin
                    if (server==1'b0 && b[0]) begin pos<=0;  dir<=1; hits<=0; ms<=0; bp<=60; st<=RALLY; end
                    else if (server==1'b1 && b[3]) begin pos<=11; dir<=0; hits<=0; ms<=0; bp<=60; st<=RALLY; end
                end
                RALLY: begin
                    if (p1_gets || p2_gets) begin
                        if (p1_gets) p1 <= p1 + 1; else p2 <= p2 + 1;
                        server <= p1_gets;                 // loser serves
                        ms <= 0;
                        st <= ((p1_gets && p1 == 4'd8) || (!p1_gets && p2 == 4'd8)) ? OVER : POINT;
                    end else begin
                        if (ok1 || ok2) begin
                            dir <= ~dir; bp <= 60;
                            if (hits != 4'd15) hits <= hits + 1;
                        end
                        if (tick_1ms) begin
                            if (ms >= interval) begin
                                ms  <= 0;
                                pos <= dir_eff ? pos + 4'd1 : pos - 4'd1;
                            end else ms <= ms + 1;
                        end
                    end
                end
                POINT: if (tick_1ms) begin
                    if (ms == 11'd1000) begin ms<=0; st<=SERVE; end else ms <= ms + 1;
                end
                OVER: begin
                    if (tick_1ms && ms < 11'd2000) ms <= ms + 1;
                    if (b[0] || b[3]) begin p1<=0; p2<=0; server<=0; st<=SERVE; end
                end
            endcase
        end
    end

    always @(*) begin
        disp = {p1, 4'hF, 4'hF, p2};
        led = 12'h000; snd = 3'd0;
        case (st)
            SERVE: led = server ? {blink[8], 11'b0} : {11'b0, blink[8]};
            RALLY: begin led = 12'd1 << pos; if (bp != 0) snd = 3'd3; end
            POINT: begin led = blink[7] ? 12'hFFF : 12'h000; if (ms < 11'd300) snd = 3'd2; end
            OVER:  begin led = blink[7] ? ((p1 == 4'd9) ? 12'h03F : 12'hFC0) : 12'h000;
                         if (ms < 11'd600) snd = 3'd1; end
        endcase
    end
endmodule
