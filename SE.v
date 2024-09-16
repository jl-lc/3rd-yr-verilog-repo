`timescale 1ns / 1ps


module SE #(
    parameter [7:0] ARRAYLENGTH = 10,   // ranges from a minimum value of 3 to a maximum value of 255
    parameter [7:0] DATAWIDTH   = 8     // ranges from a minimum value of 2 to a maximum value of 255
)(
    input wire clk,      
    input wire [DATAWIDTH*ARRAYLENGTH-1:0] array_in,
    input wire valid_in,
    output reg [DATAWIDTH*ARRAYLENGTH-1:0] array_out,
    output reg valid_out
);

    reg [DATAWIDTH*ARRAYLENGTH-1:0] internal_reg1, internal_reg2, internal_reg3;
    reg [(ARRAYLENGTH + 1)/2 + 1 : 0] valid_reg; // n/2 iterations + 1 input + 1 output
    wire busy;

    // init 
    initial begin
        internal_reg1 = 0;
        internal_reg2 = 0;
        internal_reg3 = 0;
        valid_reg = 0;
    end

    // generate architecture
    genvar i;

    generate // 1 computation stage of compare and swaps
        for (i = ARRAYLENGTH; i > 1; i = i - 2)
        begin : comp_swap_top // compare and swap top layer
            always @(*)
            begin
                if (internal_reg1[DATAWIDTH*i-1:DATAWIDTH*(i-1)] > internal_reg1[DATAWIDTH*(i-1)-1:DATAWIDTH*(i-2)])
                begin
                    internal_reg2[DATAWIDTH*(i-1)-1:DATAWIDTH*(i-2)] = internal_reg1[DATAWIDTH*i-1:DATAWIDTH*(i-1)];
                    internal_reg2[DATAWIDTH*i-1:DATAWIDTH*(i-1)] = internal_reg1[DATAWIDTH*(i-1)-1:DATAWIDTH*(i-2)];
                end
                else
                begin
                    internal_reg2[DATAWIDTH*(i-1)-1:DATAWIDTH*(i-2)] = internal_reg1[DATAWIDTH*(i-1)-1:DATAWIDTH*(i-2)];
                    internal_reg2[DATAWIDTH*i-1:DATAWIDTH*(i-1)] = internal_reg1[DATAWIDTH*i-1:DATAWIDTH*(i-1)];
                end
            end
        end
        
        for (i = ARRAYLENGTH-1; i > 1; i = i - 2)
        begin : comp_swap_bottom // compare and swap bottom layer
            always @(*)
            begin
                if (internal_reg2[DATAWIDTH*i-1:DATAWIDTH*(i-1)] > internal_reg2[DATAWIDTH*(i-1)-1:DATAWIDTH*(i-2)])
                begin
                    internal_reg3[DATAWIDTH*(i-1)-1:DATAWIDTH*(i-2)] = internal_reg2[DATAWIDTH*i-1:DATAWIDTH*(i-1)];
                    internal_reg3[DATAWIDTH*i-1:DATAWIDTH*(i-1)] = internal_reg2[DATAWIDTH*(i-1)-1:DATAWIDTH*(i-2)];
                end
                else
                begin
                    internal_reg3[DATAWIDTH*(i-1)-1:DATAWIDTH*(i-2)] = internal_reg2[DATAWIDTH*(i-1)-1:DATAWIDTH*(i-2)];
                    internal_reg3[DATAWIDTH*i-1:DATAWIDTH*(i-1)] = internal_reg2[DATAWIDTH*i-1:DATAWIDTH*(i-1)];
                end
            end
        end

    endgenerate

    // combinational logic not covered in generate block
    always @(*) // remaining wires for 1 computation stage of compare and swaps
    begin
        if (ARRAYLENGTH % 2 == 0)
        begin : even
            internal_reg3[DATAWIDTH-1:0] = internal_reg2[DATAWIDTH-1:0];
        end
        else
        begin : odd
            internal_reg2[DATAWIDTH-1:0] = internal_reg1[DATAWIDTH-1:0];
        end

        internal_reg3[DATAWIDTH*ARRAYLENGTH-1:DATAWIDTH*(ARRAYLENGTH-1)] = internal_reg2[DATAWIDTH*ARRAYLENGTH-1:DATAWIDTH*(ARRAYLENGTH-1)];
    end

    // procedural block for input and muxing compare&swap architecture
    always @(posedge clk)
    begin
        if (valid_reg[0]) // if valid, load input
            internal_reg1 <= array_in;
        else if (busy) // feed output back to input while still working on the same data
            internal_reg1 <= internal_reg3;

        valid_reg <= valid_reg << 1; // shift register valid signal
        valid_out <= valid_reg[(ARRAYLENGTH + 1)/2 + 1]; // valid out when iterated n/2 times and output registered, last bit of valid_reg
        array_out <= internal_reg3;
    end

    // combinational logic for valid input
    always @(*) // valid input with busy logic to stop accepting new inputs
    begin
        if (~busy)
            valid_reg[0] = valid_in; // if previous data is complete, accept valid input
        else
            valid_reg[0] = 1'b0;
    end

    // combinational logic for busy logic
    assign busy = |valid_reg[(ARRAYLENGTH + 1)/2 + 1 : 1]; // busy when there is data being processed

endmodule