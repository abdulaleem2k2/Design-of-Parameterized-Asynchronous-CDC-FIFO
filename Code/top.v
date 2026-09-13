`timescale 1ns / 1ps

/* =====================================================================
   Module: top
   Description: The top-level structural wrapper for the Asynchronous FIFO. 
   It instantiates the memory array, the write/read pointer logic blocks, 
   and the two synchronizers, acting as the physical breadboard connecting 
   the two isolated clock domains.
   ===================================================================== */
module top#(parameter data_size=8,parameter addr_size=4)(
    input [data_size-1:0] wdata,
    input winc,wclk,wrst_n,rinc,rclk,rrst_n,
    output [data_size-1:0] rdata,
    output wfull,rempty
    );
    
    wire [addr_size:0] rptr_in,wptr_in;
    wire [addr_size:0] rptr_out,wptr_out;
    wire [addr_size-1:0] raddr,waddr;
    
    wptr_full #(.addr_size(addr_size)) dut(.wclk(wclk),.winc(winc),.wrst_n(wrst_n),.wd_rptr(rptr_out),.wfull(wfull),.waddr(waddr),.wptr(wptr_in));
    rptr_empty #(.addr_size(addr_size)) dut1(.rclk(rclk),.rinc(rinc),.rrst_n(rrst_n),.rd_wptr(wptr_out),.rempty(rempty),.raddr(raddr),.rptr(rptr_in));
    FIFO_memory #(.addr_size(addr_size),.data_size(data_size)) dut2(.wdata(wdata),.waddr(waddr),.raddr(raddr),.wclk(wclk),.wclk_en(winc),.wfull(wfull),.rdata(rdata));
    two_ff_sync #(.addr_size(addr_size+1)) dut3(.clk(rclk),.rst_n(rrst_n),.din(wptr_in),.sync_out(wptr_out));
    two_ff_sync #(.addr_size(addr_size+1)) dut4(.clk(wclk),.rst_n(wrst_n),.din(rptr_in),.sync_out(rptr_out));
    
endmodule