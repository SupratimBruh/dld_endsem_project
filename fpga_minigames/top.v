// Top level: 6 mini-games selected by SW[11:9] = 1..6 (binary). BTN4 = global reset.
// Set the parameters below to match your board (check the manual/schematic).
module top #(
    parameter CLK_HZ          = 50_000_000,  // onboard oscillator frequency
    parameter BTN_ACTIVE_HIGH = 1,           // 0 if buttons read 0 when pressed
    parameter SEG_ACTIVE_LOW  = 1,           // EDGE display segments are active-low
    parameter AN_ACTIVE_LOW   = 0            // EDGE digit enables are active-high
)(
    input  wire        clk,
    input  wire [11:0] sw,
    input  wire [4:0]  btn,
    output wire [11:0] led,
    output wire [6:0]  seg,
    output wire [3:0]  an,
    output wire        buzzer
);
    // ---- switch synchroniser ----
    reg [11:0] sw_a, sw_b;
    initial begin sw_a = 0; sw_b = 0; end
    always @(posedge clk) begin sw_a <= sw; sw_b <= sw_a; end
    wire [2:0] sel = sw_b[11:9];

    // ---- shared blocks ----
    wire tick_1ms;
    tick_gen #(.CLK_HZ(CLK_HZ)) u_tick (.clk(clk), .tick_1ms(tick_1ms));

    wire [15:0] rnd;
    lfsr16 u_lfsr (.clk(clk), .q(rnd));

    wire [4:0] bl, bp;
    genvar i;
    generate
        for (i = 0; i < 5; i = i + 1) begin : g_db
            sync_debounce #(.CLK_HZ(CLK_HZ)) u_db (
                .clk(clk),
                .btn_in(BTN_ACTIVE_HIGH ? btn[i] : ~btn[i]),
                .level(bl[i]), .pressed(bp[i]));
        end
    endgenerate
    wire        rst = bl[4];
    wire [3:0]  b   = bp[3:0];

    // ---- game select: a game is held in reset whenever it is not selected ----
    wire [5:0] act;
    assign act[0] = (sel == 3'd1);
    assign act[1] = (sel == 3'd2);
    assign act[2] = (sel == 3'd3);
    assign act[3] = (sel == 3'd4);
    assign act[4] = (sel == 3'd5);
    assign act[5] = (sel == 3'd6);

    wire [15:0] d1, d2, d3, d4, d5, d6;
    wire [11:0] l1, l2, l3, l4, l5, l6;
    wire [2:0]  s1, s2, s3, s4, s5, s6;

    game1_reaction g1 (.clk(clk), .rst(rst | ~act[0]), .tick_1ms(tick_1ms), .rnd(rnd),
                       .b_ok(b[0]), .disp(d1), .led(l1), .snd(s1));
    game2_whack    g2 (.clk(clk), .rst(rst | ~act[1]), .tick_1ms(tick_1ms), .rnd(rnd),
                       .b(b), .disp(d2), .led(l2), .snd(s2));
    game3_simon    g3 (.clk(clk), .rst(rst | ~act[2]), .tick_1ms(tick_1ms), .rnd(rnd),
                       .b(b), .disp(d3), .led(l3), .snd(s3));
    game4_guess    g4 (.clk(clk), .rst(rst | ~act[3]), .tick_1ms(tick_1ms), .rnd(rnd),
                       .sw(sw_b[7:0]), .b_ok(b[0]), .disp(d4), .led(l4), .snd(s4));
    game5_pingpong g5 (.clk(clk), .rst(rst | ~act[4]), .tick_1ms(tick_1ms),
                       .b(b), .disp(d5), .led(l5), .snd(s5));
    game6_sum      g6 (.clk(clk), .rst(rst | ~act[5]), .tick_1ms(tick_1ms), .rnd(rnd),
                       .sw(sw_b[3:0]), .b_ok(b[0]), .b_inc(b[1]), .b_dec(b[2]), .b_ten(b[3]),
                       .disp(d6), .led(l6), .snd(s6));

    // ---- output mux ----
    reg [15:0] disp;
    reg [11:0] led_o;
    reg [2:0]  snd;
    always @(*) begin
        case (sel)
            3'd1: begin disp = d1; led_o = l1; snd = s1; end
            3'd2: begin disp = d2; led_o = l2; snd = s2; end
            3'd3: begin disp = d3; led_o = l3; snd = s3; end
            3'd4: begin disp = d4; led_o = l4; snd = s4; end
            3'd5: begin disp = d5; led_o = l5; snd = s5; end
            3'd6: begin disp = d6; led_o = l6; snd = s6; end
            default: begin disp = {4'hF, 4'hF, 4'hF, 1'b0, sel}; led_o = 12'h000; snd = 3'd0; end
        endcase
    end
    assign led = led_o;

    seg7_driver #(.SEG_ACTIVE_LOW(SEG_ACTIVE_LOW), .AN_ACTIVE_LOW(AN_ACTIVE_LOW))
        u_seg (.clk(clk), .disp(disp), .seg(seg), .an(an));

    tone_gen #(.CLK_HZ(CLK_HZ)) u_tone (.clk(clk), .snd(snd), .buzz(buzzer));
endmodule
