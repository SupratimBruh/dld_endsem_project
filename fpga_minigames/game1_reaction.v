// Game 1: Reaction timer. BTN0 starts. After a random 1-6 s delay all LEDs light;
// press BTN0 as fast as you can. Display shows reaction time in ms.
// Pressing early = foul (display EEEE, low buzz).
module game1_reaction (
    input  wire        clk, rst, tick_1ms,
    input  wire [15:0] rnd,
    input  wire        b_ok,
    output reg  [15:0] disp,
    output reg  [11:0] led,
    output reg  [2:0]  snd
);
    localparam IDLE=3'd0, WAIT=3'd1, GO=3'd2, RES=3'd3, FOUL=3'd4;
    reg [2:0]  st;
    reg [13:0] cnt, target;
    reg [9:0]  blink;
    wire [15:0] bcd;
    bin2bcd u_b(.bin(cnt), .bcd(bcd));

    wire start = b_ok && (st==IDLE || st==RES || st==FOUL);

    always @(posedge clk) begin
        if (rst) begin st<=IDLE; cnt<=0; target<=14'd1000; blink<=0; end
        else begin
            if (tick_1ms) blink <= blink + 1;
            case (st)
                WAIT: if (b_ok) begin st<=FOUL; cnt<=0; end
                      else if (tick_1ms) begin
                          if (cnt == target) begin cnt<=0; st<=GO; end
                          else cnt <= cnt + 1;
                      end
                GO:   if (b_ok) st <= RES;
                      else if (tick_1ms) begin
                          if (cnt == 14'd9999) st <= RES; else cnt <= cnt + 1;
                      end
                FOUL: if (tick_1ms && cnt < 14'd1000) cnt <= cnt + 1;
                default: ;
            endcase
            if (start) begin target <= 14'd1000 + rnd[11:0]; cnt<=0; st<=WAIT; end
        end
    end

    always @(*) begin
        disp = 16'hFFFF; led = 12'h000; snd = 3'd0;
        case (st)
            IDLE: begin disp = 16'h0000; led = {11'b0, blink[8]}; end
            WAIT: ;
            GO:   begin led = 12'hFFF; if (cnt < 14'd100) snd = 3'd1; end
            RES:  disp = bcd;
            FOUL: begin disp = 16'hEEEE; led = blink[7] ? 12'hAAA : 12'h555;
                        if (cnt < 14'd500) snd = 3'd2; end
            default: ;
        endcase
    end
endmodule
