// Game 2: Whack-a-mole. LED0-3 are the holes; press the matching BTN0-3.
// Moles get faster as score rises. 3 misses = game over (LED11:9 show lives).
// BTN0 starts / restarts. Display shows score.
module game2_whack (
    input  wire        clk, rst, tick_1ms,
    input  wire [15:0] rnd,
    input  wire [3:0]  b,
    output reg  [15:0] disp,
    output reg  [11:0] led,
    output reg  [2:0]  snd
);
    localparam IDLE=2'd0, SHOW=2'd1, GAP=2'd2, OVER=2'd3;
    reg [1:0]  st, pos, misses, fb;
    reg [7:0]  score;
    reg [10:0] ms;
    reg [9:0]  blink;

    wire any = |b;
    wire [10:0] limit = (score >= 8'd14) ? 11'd360 : (11'd1200 - score*11'd60);
    wire hit_ev  = (st==SHOW) && b[pos];
    wire miss_ev = (st==SHOW) && !hit_ev && (any || (tick_1ms && ms >= limit));
    wire start   = b[0] && (st==IDLE || st==OVER);

    always @(posedge clk) begin
        if (rst) begin st<=IDLE; pos<=0; misses<=0; fb<=0; score<=0; ms<=0; blink<=0; end
        else begin
            if (tick_1ms) blink <= blink + 1;
            if (hit_ev) begin score<=score+1; fb<=2'd1; ms<=0; st<=GAP; end
            else if (miss_ev) begin
                misses <= misses + 1; fb <= 2'd2; ms <= 0;
                st <= (misses == 2'd2) ? OVER : GAP;
            end
            else if (tick_1ms) begin
                case (st)
                    SHOW: ms <= ms + 1;
                    GAP:  if (ms == 11'd300) begin ms<=0; pos<=rnd[1:0]; st<=SHOW; end
                          else ms <= ms + 1;
                    OVER: if (ms < 11'd1000) ms <= ms + 1;
                    default: ;
                endcase
            end
            if (start) begin score<=0; misses<=0; fb<=0; ms<=0; st<=GAP; end
        end
    end

    wire [15:0] bcd;
    bin2bcd u_b(.bin({6'b0, score}), .bcd(bcd));
    wire [2:0] lives = 3'b111 >> misses;
    reg  [3:0] mole;

    always @(*) begin
        disp = {4'hF, 4'hF, bcd[7:4], bcd[3:0]};
        mole = 4'b0; snd = 3'd0;
        case (st)
            IDLE: mole = {3'b0, blink[8]};
            SHOW: mole = 4'd1 << pos;
            GAP:  begin
                if (fb==2'd1 && ms < 11'd100) snd = 3'd1;
                if (fb==2'd2 && ms < 11'd150) snd = 3'd2;
            end
            OVER: begin mole = blink[7] ? 4'hF : 4'h0; if (ms < 11'd600) snd = 3'd2; end
        endcase
        led = {lives, 5'b0, mole};
    end
endmodule
