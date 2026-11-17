// 2-flop synchronizer + debouncer. Outputs stable level and a 1-cycle press pulse.
module sync_debounce #(
    parameter CLK_HZ = 50_000_000,
    parameter MS     = 10
)(
    input  wire clk,
    input  wire btn_in,      // active-high (top.v inverts if board is active-low)
    output reg  level,       // debounced level
    output reg  pressed      // one-cycle pulse on press
);
    localparam MAX = (CLK_HZ/1000)*MS;
    reg s0, s1, prev;
    reg [$clog2(MAX+1)-1:0] cnt;
    initial begin s0=0; s1=0; prev=0; cnt=0; level=0; pressed=0; end

    always @(posedge clk) begin
        s0 <= btn_in;
        s1 <= s0;
        if (s1 == level)       cnt <= 0;
        else if (cnt == MAX)   begin level <= s1; cnt <= 0; end
        else                   cnt <= cnt + 1;
        prev    <= level;
        pressed <= level & ~prev;
    end
endmodule
