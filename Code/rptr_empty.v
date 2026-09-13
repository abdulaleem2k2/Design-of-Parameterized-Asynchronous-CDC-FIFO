`timescale 1ns / 1ps

/* =====================================================================
   Module: rptr_empty
   Description: The Read Domain logic. It maintains the binary read 
   pointer for memory extraction, translates it into N+1 bit Gray code 
   to send across domains, and calculates the EMPTY flag using look-ahead 
   logic to prevent reading invalid/garbage data.
   ===================================================================== */
module rptr_empty#(parameter addr_size=4)(
    input rinc,rclk,rrst_n,
    input [addr_size:0] rd_wptr, //read domain write pointer
    output rempty,
    output [addr_size-1:0] raddr,
    output [addr_size:0] rptr
    );
    
    reg [addr_size:0] r_bin,r_grey;
    reg r_empty_check;
    wire [addr_size:0] r_bin_next,r_grey_next;
    
    always@(posedge rclk,negedge rrst_n) begin
        if(~rrst_n)
            {r_bin,r_grey}<=0;
        else
            {r_bin,r_grey}<={r_bin_next,r_grey_next};
    end
    
    always@(posedge rclk,negedge rrst_n) begin
        if(~rrst_n)
            r_empty_check<=1'd1;
        else if(r_grey_next==rd_wptr)
            r_empty_check<=1'd1;
        else
            r_empty_check<=1'd0;    
    end
        
    assign r_bin_next=r_bin+(rinc&&~rempty);
    assign r_grey_next=(r_bin_next>>1)^r_bin_next;
    assign raddr=r_bin[addr_size-1:0];
    assign rptr=r_grey;
    assign rempty=r_empty_check;
  
endmodule