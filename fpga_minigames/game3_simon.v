// Game 3: Simon Says. BTN0 starts. LED0-3 flash a growing sequence (with tones);
// repeat it with BTN0-3. Display shows level. 15 levels wins. 5 s idle = lose.
module game3_simon (
    input  wire        clk, rst, tick_1ms,
    input  wire [15:0] rnd,
    input  wire [3:0]  b,
    output reg  [15:0] disp,
    output reg  [11:0] led,
    output reg  [2:0]  snd
);
    localparam IDLE=3'd0, PRE=3'd1, SHOWON=3'd2, SHOWOFF=3'd3,
               INPUT=3'd4, FB=3'd5, OVER=3'd6, WIN=3'd7;
    reg [2:0]  st;
    reg [1:0]  seq [0:15];
    reg [3:0]  len, idx;
    reg [1:0]  pc;
    reg [12:0] ms;
    reg [9:0]  blink;

    wire any = |b;
    wire [1:0] c = b[0] ? 2'd0 : b[1] ? 2'd1 : b[2] ? 2'd2 : 2'd3;
    wire start = b[0] && (st==IDLE || st==OVER || st==WIN);

    always @(posedge clk) begin
        if (rst) begin st<=IDLE; len<=1; idx<=0; ms<=0; pc<=0; blink<=0; end
        else begin
            if (tick_1ms) blink <= blink + 1;
            case (st)
                PRE: if (tick_1ms) begin
                        if (ms == 13'd700) begin ms<=0; idx<=0; st<=SHOWON; end
                        else ms <= ms + 1;
                     end
                SHOWON: if (tick_1ms) begin
                        if (ms == 13'd400) begin ms<=0; st<=SHOWOFF; end
                        else ms <= ms + 1;
                     end
                SHOWOFF: if (tick_1ms) begin
                        if (ms == 13'd200) begin
                            ms <= 0;
                            if (idx == len-1) begin idx<=0; st<=INPUT; end
                            else begin idx<=idx+1; st<=SHOWON; end
                        end else ms <= ms + 1;
                     end
                INPUT: begin
                    if (any) begin
                        pc <= c; ms <= 0;
                        st <= (c == seq[idx]) ? FB : OVER;
                    end else if (tick_1ms) begin
                        if (ms == 13'd5000) begin ms<=0; st<=OVER; end
                        else ms <= ms + 1;
                    end
                end
                FB: if (tick_1ms) begin
                        if (ms == 13'd200) begin
                            ms <= 0;
                            if (idx == len-1) begin
                                if (len == 4'd15) st <= WIN;
                                else begin seq[len] <= rnd[1:0]; len <= len + 1; st <= PRE; end
                            end else begin idx <= idx + 1; st <= INPUT; end
                        end else ms <= ms + 1;
                    end
                OVER, WIN: if (tick_1ms && ms < 13'd1000) ms <= ms + 1;
                default: ;
            endcase
            if (start) begin len<=1; seq[0]<=rnd[1:0]; ms<=0; idx<=0; st<=PRE; end
        end
    end

    wire [3:0]  shown_len = (st==OVER) ? len - 4'd1 : len;
    wire [15:0] bcd;
    bin2bcd u_b(.bin({10'b0, shown_len}), .bcd(bcd));

    always @(*) begin
        disp = {4'hF, 4'hF, bcd[7:4], bcd[3:0]};
        led = 12'h000; snd = 3'd0;
        case (st)
            IDLE:    begin disp = 16'h0000; led = {11'b0, blink[8]}; end
            SHOWON:  begin led = 12'd1 << seq[idx]; snd = 3'd3 + seq[idx]; end
            FB:      begin led = 12'd1 << pc;       snd = 3'd3 + pc; end
            OVER:    begin led = blink[8] ? 12'hAAA : 12'h555; if (ms < 13'd600) snd = 3'd2; end
            WIN:     begin disp = 16'hCCCC; led = blink[7] ? 12'hFFF : 12'h000;
                           if (ms < 13'd600) snd = 3'd1; end
            default: ;
        endcase
    end
endmodule
