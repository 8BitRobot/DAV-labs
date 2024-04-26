module trig(input clk, output outClk);
    assign outClk = clk;
endmodule

module cos(
    input [$clog2(359):0] angle, // Range of input angle is 0 to 359 degrees.
    output signed [15:0] cos
);
    // Our polynomial approximation for cos(x) is:
    // cos(x) = 34195 - 107 * x - 3 * x^2
    // where x is in degrees.
    // This approximation is valid for x in the range of 0 to 90 degrees.
    wire [6:0] new_angle;
    wire new_sign;
    assign new_angle = (angle <= 180) ? ((angle < 90) ? angle : 180 - angle) : ((angle < 270) ? angle - 180 : 360 - angle);
    assign new_sign = (angle >= 91 && angle <= 270);

    wire [15:0] angle_squared = new_angle * new_angle;

    wire [31:0] cos_unsigned = 32'd34195 - 7'd107 * new_angle - (2'd3 * angle_squared);

    // Create a wire, `clamped_cos_unsigned`, that clamps `cos_unsigned` to be between 515 and 32549.
    wire [15:0] clamped_cos_unsigned;
    assign clamped_cos_unsigned = (cos_unsigned < 515) ? 515 : ((cos_unsigned > 32549) ? 32549 : cos_unsigned);

    assign cos = new_sign ? (-1 * clamped_cos_unsigned) : clamped_cos_unsigned;
endmodule