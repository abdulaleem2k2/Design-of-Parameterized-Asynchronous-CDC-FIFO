`timescale 1ns / 1ps

/* =====================================================================
   Module: two_ff_sync
   Description: A standard 2-stage flip-flop synchronizer. It acts as 
   a shock absorber, taking asynchronous, potentially unstable Gray code 
   signals and delaying them by two clock cycles to safely lock them 
   into the local synchronous clock domain.
   ===================================================================== */
module two_ff_sync#(parameter addr_size=4)(
    input clk,rst_n,
    input [addr_size-1:0] din,
    output reg [addr_size-1:0] sync_out
    );
    
    reg [addr_size-1:0] d_temp;
    
    always@(posedge clk or negedge rst_n) begin
        if(~rst_n) begin
            {d_temp,sync_out}=0;
        end
        else begin
            {sync_out,d_temp}={d_temp,din};
        end     
    end
endmodule