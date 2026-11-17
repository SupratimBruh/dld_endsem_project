// Combinational binary -> 4-digit BCD (0..9999), constant divisors only
module bin2bcd(
    input  wire [13:0] bin,
    output wire [15:0] bcd
);
    assign bcd[15:12] = (bin / 1000) % 10;
    assign bcd[11:8]  = (bin / 100)  % 10;
    assign bcd[7:4]   = (bin / 10)   % 10;
    assign bcd[3:0]   =  bin         % 10;
endmodule
