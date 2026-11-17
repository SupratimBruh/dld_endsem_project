// Game 4: Guess the number (0-255). Set SW[7:0], press BTN0 to guess.
// LED11:8 on = go HIGHER, LED3:0 on = go LOWER. 9 tries.
// Display: [tries used][guess in decimal]. BTN0 starts / restarts.
module game4_guess (
    input  wire        clk, rst, tick_1ms,
    input  wire [15:0] rnd,
    input  wire [7:0]  sw,
    input  wire        b_ok,
    output reg  [15:0] disp,
    output reg  [11:0] led,
    output reg  [2:0]  snd
);
    localparam IDLE=2'd0, PLAY=2'd1, WIN=2'd2, OVER=2'd3;
    reg [1:0]  st, hint;          // hint: 0 none, 1 higher, 2 lower
    reg [7:0]  target;
    reg [3:0]  tries;
    reg [10:0] ms;
    reg [9:0]  blink;

    wire start = b_ok && (st != PLAY);

    always @(posedge clk) begin
        if (rst) begin st<=IDLE; hint<=0; target<=0; tries<=0; ms<=0; blink<=0; end
        else begin
            if (tick_1ms) begin
                blink <= blink + 1;
                if (ms < 11'd1000) ms <= ms + 1;
            end
            if (st==PLAY && b_ok) begin
                tries <= tries + 1; ms <= 0;
                if (sw == target) st <= WIN;
                else begin
                    hint <= (sw < target) ? 2'd1 : 2'd2;
                    if (tries == 4'd8) st <= OVER;
                end
            end
            if (start) begin target<=rnd[7:0]; tries<=0; hint<=0; ms<=0; st<=PLAY; end
        end
    end

    wire [15:0] bsw, btg;
    bin2bcd u_s(.bin({6'b0, sw}),     .bcd(bsw));
    bin2bcd u_t(.bin({6'b0, target}), .bcd(btg));

    always @(*) begin
        disp = {tries, bsw[11:0]};
        led = 12'h000; snd = 3'd0;
        case (st)
            IDLE: led = {11'b0, blink[8]};
            PLAY: begin
                if (hint == 2'd1) led = 12'hF00;
                if (hint == 2'd2) led = 12'h00F;
                if (hint != 2'd0 && ms < 11'd100) snd = 3'd3;
            end
            WIN:  begin led = blink[7] ? 12'hFFF : 12'h000; if (ms < 11'd600) snd = 3'd1; end
            OVER: begin disp = {4'hE, btg[11:0]};
                        led = blink[8] ? 12'hAAA : 12'h555; if (ms < 11'd600) snd = 3'd2; end
        endcase
    end
endmodule
