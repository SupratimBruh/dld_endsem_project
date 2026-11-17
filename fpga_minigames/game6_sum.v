// Game 6: Sum game. BTN0 starts. Digits 1-9 flash one at a time; add them up.
// Enter answer: BTN1 = +1, BTN2 = -1, BTN3 = +10, BTN0 = confirm.
// Correct: "C  xx" + success beep. Wrong: "E  xx" (right sum) + low buzz.
// SW[1:0] = speed (1000/700/500/300 ms), SW[3:2] = length (4..7 digits).
module game6_sum (
    input  wire        clk, rst, tick_1ms,
    input  wire [15:0] rnd,
    input  wire [3:0]  sw,
    input  wire        b_ok, b_inc, b_dec, b_ten,
    output reg  [15:0] disp,
    output reg  [11:0] led,
    output reg  [2:0]  snd
);
    localparam IDLE=3'd0, PICK=3'd1, SHOW=3'd2, GAP=3'd3, ENTER=3'd4, RESULT=3'd5;
    localparam GAP_MS = 11'd200;

    reg [2:0]  state;
    reg [10:0] ms, show_ms;
    reg [2:0]  shown, len;
    reg [3:0]  cur;
    reg [6:0]  sum_ref, entry;
    reg        correct;
    reg [9:0]  blink;

    wire start = (state==IDLE || state==RESULT) && b_ok;

    always @(posedge clk) begin
        if (rst) begin
            state<=IDLE; ms<=0; shown<=0; len<=4; show_ms<=1000;
            cur<=0; sum_ref<=0; entry<=0; correct<=0; blink<=0;
        end else begin
            if (tick_1ms) blink <= blink + 1;
            case (state)
                PICK: if (rnd[3:0] >= 4'd1 && rnd[3:0] <= 4'd9) begin
                          cur <= rnd[3:0]; sum_ref <= sum_ref + rnd[3:0];
                          ms <= 0; state <= SHOW;
                      end
                SHOW: if (tick_1ms) begin
                          if (ms == show_ms - 1) begin ms <= 0; state <= GAP; end
                          else ms <= ms + 1;
                      end
                GAP:  if (tick_1ms) begin
                          if (ms == GAP_MS - 1) begin
                              ms <= 0;
                              if (shown == len - 1) state <= ENTER;
                              else begin shown <= shown + 1; state <= PICK; end
                          end else ms <= ms + 1;
                      end
                ENTER: begin
                    if (b_inc) entry <= (entry == 7'd99) ? 7'd0  : entry + 7'd1;
                    if (b_dec) entry <= (entry == 7'd0)  ? 7'd99 : entry - 7'd1;
                    if (b_ten) entry <= (entry >= 7'd90) ? entry - 7'd90 : entry + 7'd10;
                    if (b_ok) begin correct <= (entry == sum_ref); ms <= 0; state <= RESULT; end
                end
                RESULT: if (tick_1ms && ms < 11'd2000) ms <= ms + 1;
                default: ;
            endcase

            if (start) begin
                len <= 3'd4 + sw[3:2];
                case (sw[1:0])
                    2'd0: show_ms <= 11'd1000;
                    2'd1: show_ms <= 11'd700;
                    2'd2: show_ms <= 11'd500;
                    2'd3: show_ms <= 11'd300;
                endcase
                sum_ref <= 0; shown <= 0; entry <= 0; ms <= 0; state <= PICK;
            end
        end
    end

    wire [6:0] show_val = (state==RESULT && !correct) ? sum_ref : entry;
    wire [3:0] tens = show_val / 10;
    wire [3:0] ones = show_val % 10;

    always @(*) begin
        disp = 16'h0000; led = 12'h000; snd = 3'd0;
        case (state)
            IDLE:  begin disp = 16'h0000; led = {11'b0, blink[8]}; end
            PICK:  disp = 16'hFFFF;
            SHOW:  begin disp = {4'hF, 4'hF, 4'hF, cur}; led = (12'd1 << (shown + 1)) - 1; end
            GAP:   begin disp = 16'hFFFF;                led = (12'd1 << (shown + 1)) - 1; end
            ENTER: disp = {4'hF, 4'hF, tens, ones};
            RESULT: begin
                disp = {correct ? 4'hC : 4'hE, 4'hF, tens, ones};
                if (correct) begin led = blink[8] ? 12'hFFF : 12'h000; if (ms < 11'd600) snd = 3'd1; end
                else         begin led = blink[8] ? 12'hAAA : 12'h555; if (ms < 11'd600) snd = 3'd2; end
            end
            default: ;
        endcase
    end
endmodule
