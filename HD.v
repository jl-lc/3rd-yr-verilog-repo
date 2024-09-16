`timescale 1ns / 1ps

module HD (
    input [11:0] code, 
    output reg[7:0] data,
    output reg[3:0] syndrome
);
    reg [11:0]  code_o;
    wire [3:0]  check_r, check_c;
    wire [7:0]  data_r;

    assign check_r = {code[7], code[3], code[1], code[0]};
    assign data_r  = {code[11], code[10], code[9], code[8], code[6], code[5], code[4], code[2]};

    assign check_c[0] = data_r[0] ^ data_r[1] ^ data_r[3] ^ data_r[4] ^ data_r[6];
    assign check_c[1] = data_r[0] ^ data_r[2] ^ data_r[3] ^ data_r[5] ^ data_r[6];
    assign check_c[2] = data_r[1] ^ data_r[2] ^ data_r[3] ^ data_r[7];
    assign check_c[3] = data_r[4] ^ data_r[5] ^ data_r[6] ^ data_r[7];
    
    always @(code) begin
        code_o = code;
        syndrome = check_r ^ check_c;
        if ((syndrome == 0) || (syndrome == 1) || (syndrome == 2) || (syndrome == 4) || (syndrome == 8)) begin
            data = data_r;
        end else begin
            code_o[syndrome-1] = ~code_o[syndrome-1];
            data = {code_o[11], code_o[10], code_o[9], code_o[8], code_o[6], code_o[5], code_o[4], code_o[2]};
        end
    end

endmodule