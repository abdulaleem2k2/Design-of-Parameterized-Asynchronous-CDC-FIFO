`timescale 1ns/1ps

/* =====================================================================
   Module: FIFO_memory
   Description: The Dual-Port RAM where the data payload is physically 
   stored. It utilizes a synchronous write port (controlled by wclk and 
   wclk_en) and an asynchronous/combinational read port.
   ===================================================================== */
module FIFO_memory #(parameter data_size=8,parameter addr_size=4)(
    input [data_size-1:0] wdata,
    input [addr_size-1:0] waddr,raddr,
    input wclk,wclk_en,wfull,
    output [data_size-1:0] rdata
    );
    
    localparam depth=1<<addr_size;
    reg [data_size-1:0] mem [depth-1:0];
    
    always@(posedge wclk) begin
        if(~wfull&&wclk_en)
            mem[waddr]<=wdata;
    end
    
    assign rdata=mem[raddr];

endmodule