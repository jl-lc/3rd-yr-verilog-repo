`timescale 1ns / 1ps

module PD (
    input wire clk, reset, enable,
    input wire[3:0] din,
    output wire pattern1, pattern2
);
    reg patt1, patt2;
    reg[2:0] state = 3'b000;

    parameter state1 = 3'b001, state2 = 3'b010, state3 = 3'b011, state4 = 3'b100;
    parameter state5 = 3'b101, state6 = 3'b110, state7 = 3'b111;

    assign pattern1 = patt1;
    assign pattern2 = patt2;

    always@(posedge clk or posedge reset)
    begin
        case(state)
            state1:
                begin
                    if (reset)
                        state <= state7;
                    else if (enable)
                    begin
                        if (din == 0)
                            state <= state2;
                        else
                            state <= state1;
                        patt1 <= 0;
                        patt2 <= 0;
                    end
                end
            state2:
                begin
                    if (reset)
                        state <= state7;
                    else if (enable)
                    begin
                        if (din == 5)
                            state <= state3;
                        else if (din == 6)
                            state <= state5;
                        else if (din == 0)
                            state <= state2;
                        else
                            state <= state1;
                        patt1 <= 0;
                        patt2 <= 0;
                    end
                end
            state3:
                begin
                    if (reset)
                        state <= state7;
                    else if (enable)
                    begin
                        if (din == 3)
                            state <= state4;
                        else if (din == 0)
                            state <= state2;
                        else
                            state <= state1;
                        patt1 <= 0;
                        patt2 <= 0;
                    end
                end
            state4:
                begin
                    if (reset)
                        state <= state7;
                    else if (enable)
                    begin
                        if (din == 1)
                            patt1 <= 1;
                        else if (din == 0)
                            state <= state2;
                        else
                            patt1 <= 0;
                        state <= state1;
                        patt2 <= 0;
                    end
                end
            state5:
                begin
                    if (reset)
                        state <= state7;
                    else if (enable)
                    begin
                        if (din == 1)
                            state <= state6;
                        else if (din == 0)
                            state <= state2;
                        else
                            state <= state1;
                        patt1 <= 0;
                        patt2 <= 0;
                    end
                end
            state6:
                begin
                    if (reset)
                        state <= state7;
                    else if (enable)
                    begin
                        if (din == 9)
                            patt2 <= 1;
                        else if (din == 0)
                            state <= state2;
                        else
                            patt2 <= 0;
                        state <= state1;
                        patt1 <= 0;
                    end
                end
            default:
                begin
                    if (reset)
                        state <= state7;
                    else
                        state <= state1;
                    patt1 <= 0;
                    patt2 <= 0;
                end
        endcase
    end

endmodule
