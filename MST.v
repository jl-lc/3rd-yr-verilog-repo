`timescale 1ns / 100ps

module mst
    (
    input clock,
    input reset,
    input enable,
    output reg [7:0] wra,
    output reg [7:0] wrd,
    output reg [7:0] rda,
    output reg [7:0] rdd,
    output reg we,
    output reg [8:0] t1attempts,
    output reg [8:0] t1fails,
    output reg [8:0] t2attempts,
    output reg [8:0] t2fails,
    output reg done
    );

    wire [7:0] rddmem;
    
    memory u2 (.clock(clock), .reset(reset), .we(we), .wra(wra), .wrd(wrd), .rda(rda), .rdd(rddmem));

    // INSERT THE CODE FOR YOUR MEMORY SYSTEM TESTER LOGIC HERE...
    wire clk;
    reg [1:0] count = 0;    // keep track of 3 cycles
    reg test1_done = 0;

    assign clk = ~clock;    // flip clock for falling edge output

    // simple counter
    always @(posedge clk)
    begin : counter
        if (enable)
        begin
            count <= count + 1;
            if (count == 2)
                count <= 0;
        end
    end
    
    always @(posedge clk)
    begin : tests
        if (reset)                              // reset all outputs
        begin
            rda <= 8'h00;
            wrd <= 8'h00;
            wra <= 8'h00;
            we <= 0;
            t1attempts <= 8'h00;
            t1fails <= 8'h00;
            t2attempts <= 8'h00;
            t2fails <= 8'h00;
            done <= 0;
        end
        else if (~test1_done && ~done)          // test 1
        begin
            if (enable && count == 0) 
            begin                               // write into memory
                we <= 1;
                wrd <= 8'h00;                   // write 8'h00
            end
            else if (enable && count == 1)
            begin                               // read from address, disable write enable for clarity
                we <= 0;                        // since rda & wra both start at 0, we are reading (rdd) from the correct address in this cycle already
            end
            else if (enable && count == 2)
            begin
                wra <= wra + 8'h01;             // increment address
                rda <= wra + 8'h01;             // read from written address
                t1attempts <= t1attempts + 1;   // increment attempts
                if (t1attempts == 9'h0FF)       // nonblocking assignment, check ahead
                    test1_done <= 1;            // max attempts checked, move on to test 2
                if (rdd != wrd)                 // check if data doesn't match, increment fails
                    t1fails <= t1fails + 1;
            end
            else
                we <= 0;                        // completeness
        end
        else if (test1_done && ~done)           // test 2
        begin
            if (enable && count == 0) 
            begin                               // write into memory
                we <= 1;
                wrd <= 8'hFF;                   // write 8'hFF
            end
            else if (enable && count == 1)
            begin                               // read from address, disable write enable for clarity
                we <= 0;                        // since rda & wra both start at 0, we are reading (rdd) from the correct address in this cycle already
            end
            else if (enable && count == 2)
            begin
                wra <= wra + 8'h01;             // increment address
                rda <= wra + 8'h01;             // read from written address
                t2attempts <= t2attempts + 1;   // increment attempts
                if (t2attempts == 9'h0FF)       // nonblocking assignment, check ahead
                    done <= 1;                  // max attempts checked, finish
                if (rdd != wrd)                 // check if data doesn't match, increment fails
                    t2fails <= t2fails + 1;
            end
            else
                we <= 0;                        // completeness
        end
        else                                    // done. signals remain as is
        begin
            rda <= rda;
            wrd <= wrd;
            wra <= wra;
            we <= 0;
            t1attempts <= t1attempts;
            t1fails <= t1fails;
            t2attempts <= t2attempts;
            t2fails <= t2fails;
            done <= 1;
        end
    end
    
endmodule



module memory(
    input clock,
    input reset,
    input we,
    input [7:0] wra,
    input [7:0] wrd,
    input [7:0] rda,
    output [7:0] rdd
    );
    
    reg [7:0] mem[255:0];
    reg [7:0] rddata;
    
    always @(posedge clock)
    begin
        if(reset)
        begin
            rddata <= 8'h00;
        end
        else
        begin
            if(we)
            begin
                mem[wra] <= wrd;
            end
            rddata <= mem[rda];
        end
    end
    
    assign rdd = rddata;
        
endmodule