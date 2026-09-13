`timescale 1ns / 1ps

/* =====================================================================
   Module: wptr_full
   Description: The Write Domain logic. It maintains the binary write 
   pointer for memory addressing, translates the pointer into N+1 bit 
   Gray code to send across domains, and calculates the FULL flag using 
   look-ahead logic to prevent data overwrite.
   ===================================================================== */
module wptr_full#(parameter addr_size=4)(
    input winc,wclk,wrst_n,
    input [addr_size:0]wd_rptr, //write domain read pointer
    output wfull,
    output  [addr_size-1:0] waddr,
    output [addr_size:0] wptr
    );
    
    reg [addr_size:0] w_bin,w_grey;
    wire [addr_size:0] w_bin_next,w_grey_next;
    reg w_full_check;
    
    always@(posedge wclk,negedge wrst_n) begin
        if(~wrst_n)
            {w_bin,w_grey}<=0;
        else
           {w_bin,w_grey}<={w_bin_next,w_grey_next};             
    end
    
    always@(posedge wclk,negedge wrst_n) begin
        if(~wrst_n)
            w_full_check<=1'b0;
        else if((w_grey_next[addr_size:addr_size-1]==~wd_rptr[addr_size:addr_size-1])&&(w_grey_next[addr_size-2:0]==wd_rptr[addr_size-2:0]))
            w_full_check<=1'b1;
        else
            w_full_check<=1'b0;
    end
    
    assign w_bin_next=w_bin+(winc&&~wfull);
    assign w_grey_next=(w_bin_next>>1)^w_bin_next; // Fixed the XOR logic here!
    assign waddr=w_bin[addr_size-1:0];
    assign wptr=w_grey;
    assign wfull=w_full_check;
    
endmodule