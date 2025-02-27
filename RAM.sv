`timescale 1ns / 1ps

module RAM(
    input logic [15:0] axi_data_in,
    input logic [11:0] axi_adr_in,
    input logic axi_write,
    input logic axi_read,
    output logic [31:0] axi_data_out,
    
    input logic [31:0] SEND_DATA,
    input logic [11:0] SEND_ADDR,

    input logic [11:0] READ_ADDRESS,
    
    output logic [15:0] READ_DATA,
    //
    input write_to_cache,
    //
    
    input logic mode,
    input logic clk
    );
 
 reg [31:0] MEM [0:4095];
 logic [11:0] shifted_SEND_ADDR;
 logic [11:0] shifted_shifted_SEND_ADDR;
 
/*always @(posedge clk) begin
    if(mode) begin
        if(axi_write)begin
           MEM[axi_adr_in] <= axi_data_in;
           READ_DATA <= MEM[READ_ADDRESS]; // need changes
        end
        else if(axi_read) axi_data_out <= MEM[axi_adr_in];
    end
    else begin
        MEM[SEND_ADDR] <= SEND_DATA;
    end
 end   */

 d_flip_flop d1(.clk(clk), .d(SEND_ADDR), .q(shifted_SEND_ADDR));
 d_flip_flop d2(.clk(clk), .d(shifted_SEND_ADDR), .q(shifted_shifted_SEND_ADDR));
    
    always @(posedge clk) begin
    if(mode) begin
        if(axi_write)begin
           MEM[axi_adr_in] <= axi_data_in;
        end
        else if(axi_read) axi_data_out <= MEM[axi_adr_in];
    end
    else begin
    if(write_to_cache)
        READ_DATA <= MEM[READ_ADDRESS]; 
    else begin
        MEM[shifted_shifted_SEND_ADDR] <= SEND_DATA;
    end
    end
 end   

endmodule
