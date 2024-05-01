`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 30.04.2024 19:17:49
// Design Name: 
// Module Name: spi_master
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments: SPI designed for 
//                      system frequency = 100 MHz
//                      spi_clk frequency = 10 MHz
// 
//////////////////////////////////////////////////////////////////////////////////


module spi_master #(
        parameter FINAL_DIVSR = 4,
        parameter D_WIDTH = 8)
(
    output               spi_clk_o,
    output               mosi_o,
    output               ready_o,
    output               spi_done_o,
    output [D_WIDTH-1:0]  dout,
    input [D_WIDTH-1:0]  din,
    input                clk_i,srst_i,
    input                cpol, cpha,
    input                miso_i,
    input                start_i
    );
    
    localparam DIVSR_BITS = $clog2(FINAL_DIVSR);
    localparam NO_BITS = $clog2(D_WIDTH);
    
    parameter [1:0] IDLE = 2'd0;
    parameter [1:0] VALUE_DRIVE = 2'd2;
    parameter [1:0] VALUE_SAMPLE = 2'd3;
    parameter [1:0] CPHA_DEL = 2'd1;
    
    reg  [1:0]           state_reg, state_nxt;
    reg  [D_WIDTH-1:0]   sin_reg, sin_nxt;
    reg  [D_WIDTH-1:0]   sout_reg, sout_nxt;
    reg  [DIVSR_BITS-1:0]clk_cnt_nxt,clk_cnt_reg;
    reg  [NO_BITS-1:0]   n_nxt,n_reg;
    wire                 spi_clk_nxt;
    reg                  spi_clk_reg;
    reg                  ready;
    wire                 p_clk;
    reg                  spi_done;
    
    always @(posedge clk_i , posedge srst_i) begin
        if(srst_i) begin
            state_reg <= IDLE;
            sin_reg <= 0;
            sout_reg <= 0;
            clk_cnt_reg <= 0;
            n_reg <= 0;
            spi_clk_reg <= 0;
            spi_done <= 0; 
        end
        else begin
            state_reg <= state_nxt;
            sin_reg <= sin_nxt;
            sout_reg <= sout_nxt;
            clk_cnt_reg <= clk_cnt_nxt;
            n_reg <= n_nxt;
            spi_clk_reg <= spi_clk_nxt; 
        end
    end 
    
    always@(*) begin
        ready = 1'b0;
        state_nxt = state_reg;
        sin_nxt = sin_reg;
        sout_nxt = sout_reg;
        clk_cnt_nxt = clk_cnt_reg;
        n_nxt = n_reg;
        spi_done = 1'b0;
        
        case(state_reg) 
            IDLE : begin
                ready = 1'b1;
                if(start_i) begin
                    clk_cnt_nxt = 0;
                    n_nxt = 0;
                    sout_nxt = din;
                    state_nxt = CPHA_DEL;
                end
                else 
                    state_nxt = IDLE;
            end
            
            CPHA_DEL : begin
                if(clk_cnt_reg == (FINAL_DIVSR-1)) begin
                    state_nxt = VALUE_DRIVE;
                    clk_cnt_nxt = 0;
                end
                else    
                    clk_cnt_nxt = clk_cnt_reg + 1'b1; 
            end
            
            VALUE_DRIVE : begin
                if(clk_cnt_reg == (FINAL_DIVSR - 1)) begin
                    clk_cnt_nxt = 0;
                    sin_nxt = {sin_reg[D_WIDTH-2:0],miso_i};
                    state_nxt = VALUE_SAMPLE;
                end
                else 
                    clk_cnt_nxt = clk_cnt_reg + 1'b1;               
            end
            
            VALUE_SAMPLE : begin
                if(clk_cnt_reg == (FINAL_DIVSR - 1)) begin
                    if(n_reg == D_WIDTH-1) begin
                        spi_done = 1'b1;
                        state_nxt = IDLE;
                    end
                    else begin
                        clk_cnt_nxt = 0;
                        n_nxt = n_reg + 1'b1;
                        sout_nxt = {sout_reg[D_WIDTH-2:0],1'b0};
                        state_nxt = VALUE_DRIVE;
                    end
                end
                else 
                        clk_cnt_nxt = clk_cnt_reg + 1'b1;
            end
        endcase
    end
    
    assign spi_done_o = spi_done;
    assign ready_o = ready;
    
    assign dout = sin_reg;
    assign mosi_o = sout_reg[D_WIDTH-1];
   
    
    //lookahead output decoding for SPI_CLK
    
    assign p_clk = ((state_nxt==VALUE_SAMPLE) & ~cpha) || ((state_nxt == VALUE_DRIVE) & cpha);
    assign spi_clk_nxt = cpol ? ~p_clk: p_clk;
    
     assign spi_clk_o = spi_clk_reg;
endmodule
