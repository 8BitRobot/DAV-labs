module scale(
    input signed [15:0] Sx,
    input signed [15:0] Sy,
    input signed [15:0] Sz,
    output signed [15:0] M [0:3][0:3]
);
    // Generate the 4x4 scaling matrix for a 3D point in the homogeneous representation with
    // scaling factors Sx, Sy, and Sz.
    // The scaling matrix is:
    // | Sx  0   0   0 |
    // | 0   Sy  0   0 |
    // | 0   0   Sz  0 |
    // | 0   0   0   1 |
    assign M = '{
        '{Sx,0,0,0},
        '{0,Sy,0,0},
        '{0,0,Sz,0},
        '{0,0,0,1}
    };
endmodule

module rotate(
    input [15:0] angle,
    input [1:0] axis,
    output reg signed [15:0] M [0:3][0:3]
);

    wire signed [15:0] op1, op2;

    cos cos1(.angle(angle), .cos(op1));
    cos cos2(.angle(angle), .cos(op2));

    always_comb begin
        if (axis == 0) begin // x-axis rotation

        end else if (axis == 1) begin // y-axis rotation

        end else begin // z-axis rotation

        end
    end
endmodule