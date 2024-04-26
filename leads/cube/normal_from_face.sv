module normal_from_face(input [15:0] face [0:2], output [15:0] normal [0:2]);
    cross_product cp1(
        face[1] - face[0],
        face[2] - face[1],
        normal
    );
endmodule