// 1-cycle pulse every 1 ms
module tick_gen #(parameter CLK_HZ = 50_000_000)(
    input  wire clk,
    output reg  tick_1ms
);
    localparam DIV = CLK_HZ/1000;
    reg [$clog2(DIV+1)-1:0] c;
    initial begin c = 0; tick_1ms = 0; end
    always @(posedge clk) begin
        if (c == DIV-1) begin c <= 0; tick_1ms <= 1; end
        else            begin c <= c + 1; tick_1ms <= 0; end
    end
endmodule
