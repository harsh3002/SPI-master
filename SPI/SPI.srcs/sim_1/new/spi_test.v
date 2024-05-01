`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 30.04.2024 21:57:57
// Design Name: 
// Module Name: spi_test
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module spi_test #(
    parameter FINAL_DIVSR = 5,
    parameter D_WIDTH = 8
    );
    
    wire               spi_clk_o;
    wire               mosi_o;
    wire               ready_o;
    wire               spi_done_o;
    wire[D_WIDTH-1:0]  dout;
    reg [D_WIDTH-1:0]  din;
    reg                clk_i,srst_i;
    reg                cpol, cpha;
    reg                miso_i;
    reg                start_i;
    
    spi_master #(.FINAL_DIVSR(FINAL_DIVSR), .D_WIDTH(D_WIDTH)) dut (
    .spi_clk_o(spi_clk_o),
    .mosi_o(mosi_o),
    .ready_o(ready_o),
    .spi_done_o(spi_done_o),
    .din(din),
    .dout(dout),
    .clk_i(clk_i),
    .srst_i(srst_i),
    .cpol(cpol),
    .cpha(cpha),
    .miso_i(miso_i),
    .start_i(start_i));
    
    initial begin
                  clk_i <= 1'b0;
      forever  #5 clk_i <= ~clk_i;
    end
    
    initial begin
        srst_i <= 1'b1;
       #50 srst_i <= 1'b0;    
    end
    initial begin
        cpol <= 1'b0;
        cpha <= 1'b0;
        #100 start_i <= 1'b1;
        din <= 8'b10101010;
        miso_i <= 1'b0;
        @(negedge spi_clk_o);
        miso_i <= 1'b1;
        start_i <= 1'b0;
@(negedge spi_clk_o);
         miso_i <= 1'b0;
@(negedge spi_clk_o);         miso_i <= 1'b0;
@(negedge spi_clk_o);         miso_i <= 1'b1;
@(negedge spi_clk_o);         miso_i <= 1'b0;
@(negedge spi_clk_o);         miso_i <= 1'b0;
@(negedge spi_clk_o);        miso_i <=1'b1;
@(negedge spi_clk_o);       miso_i <= 1'b0;
@(negedge spi_clk_o);       miso_i <= 1'b1;
@(negedge spi_clk_o);       miso_i <= 1'b0;
@(negedge spi_clk_o); 

#500 $finish; 
   end
endmodule
