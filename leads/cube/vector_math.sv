module cross_product(
    input [15:0] v1 [0:2],
    input [15:0] v2 [0:2],
    output [15:0] v [0:2]
);
    assign v[0] = v1[1] * v2[2] - v1[2] * v2[1];
    assign v[1] = v1[2] * v2[0] - v1[0] * v2[2];
    assign v[2] = v1[0] * v2[1] - v1[1] * v2[0];
endmodule

module dot_product(
    input [15:0] v1 [0:2],
    input [15:0] v2 [0:2],
    output [15:0] dot
);
    assign dot = v1[0] * v2[0] + v1[1] * v2[1] + v1[2] * v2[2];
endmodule