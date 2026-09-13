`timescale 1ns / 1ps

module tb_async_fifo;

    // 1. Parameters matching your top module
    parameter data_size = 8;
    parameter addr_size = 4;

    // 2. Inputs (regs for driving stimulus)
    reg [data_size-1:0] wdata;
    reg winc, wclk, wrst_n;
    reg rinc, rclk, rrst_n;

    // 3. Outputs (wires for observing results)
    wire [data_size-1:0] rdata;
    wire wfull, rempty;

    // Loop integer for our bursts
    integer i;

    // 4. Instantiate the Top-Level Module (Device Under Test)
    top #(.data_size(data_size), .addr_size(addr_size)) dut (
        .wdata(wdata),
        .winc(winc),
        .wclk(wclk),
        .wrst_n(wrst_n),
        .rinc(rinc),
        .rclk(rclk),
        .rrst_n(rrst_n),
        .rdata(rdata),
        .wfull(wfull),
        .rempty(rempty)
    );

    // 5. Clock Generation
    // Write clock: 100 MHz (10 ns period)
    initial begin
        wclk = 0;
        forever #5 wclk = ~wclk; 
    end

    // Read clock: ~41.6 MHz (24 ns period) - Different frequency to prove CDC works!
    initial begin
        rclk = 0;
        forever #12 rclk = ~rclk; 
    end

    // 6. Stimulus Sequence
    initial begin
        // --- A. Initialize Everything to Zero ---
        wdata = 0;
        winc = 0;
        rinc = 0;
        wrst_n = 0;
        rrst_n = 0;

        // --- B. Reset Sequence ---
        // Hold reset low to clear pointers, then release
        #50;
        wrst_n = 1;
        rrst_n = 1; 
        #50;

        // --- C. Write Burst (Fill the FIFO) ---
        $display("--- STARTING WRITE BURST ---");
        // Write 16 times (2^4 = 16)
        for (i = 0; i < (1<<addr_size); i = i + 1) begin
            @(posedge wclk);
            if (!wfull) begin
                wdata = i + 10; // Dummy data: 10, 11, 12, 13...
                winc = 1;
            end
        end
        
        // Push one more write to see if 'wfull' correctly ignores it
        @(posedge wclk);
        wdata = 8'hFF; 
        winc = 1;
        
        @(posedge wclk);
        winc = 0; // Stop writing
        
        // --- D. Wait for Synchronizers ---
        // Takes a few clock cycles for the Gray pointers to cross domains
        #150;

        // --- E. Read Burst (Empty the FIFO) ---
        $display("--- STARTING READ BURST ---");
        // Read 16 times
        for (i = 0; i < (1<<addr_size); i = i + 1) begin
            @(posedge rclk);
            if (!rempty) begin
                rinc = 1;
            end
        end
        
        // Try one more read to see if 'rempty' prevents underflow
        @(posedge rclk);
        rinc = 1;
        
        @(posedge rclk);
        rinc = 0; // Stop reading

        // --- F. End Simulation ---
        #100;
        $display("--- SIMULATION COMPLETE ---");
        $finish;
    end

endmodule