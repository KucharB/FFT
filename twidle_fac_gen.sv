// ROM implementation with 4096 twiddle factors in 2's complement
module twiddle_rom #(parameter WIDTH = 32, parameter DEPTH = 4096) (
    input  logic [$clog2(DEPTH)-1:0] addr, // Address input
    output logic [WIDTH-1:0]          data  // Data output
);

    // Memory array to store twiddle factors
    logic [WIDTH-1:0] rom [0:DEPTH-1];

    // Initialize the ROM with twiddle factors (precomputed values)
    initial begin
        $readmemh("twiddle_factors.hex", rom); // Load from hex file
    end

    // Read data based on address
    always_comb begin
        data = rom[addr];
    end

endmodule

// Testbench for twiddle_rom
module tb_twiddle_rom;
    // Parameters
    parameter WIDTH = 32;
    parameter DEPTH = 4096;

    // Signals
    logic [$clog2(DEPTH)-1:0] addr;
    logic [WIDTH-1:0] data;

    // DUT instantiation
    twiddle_rom #(.WIDTH(WIDTH), .DEPTH(DEPTH)) dut (
        .addr(addr),
        .data(data)
    );

    // Testbench variables
    int i;

    // Test procedure
    initial begin
        // Load the twiddle factors into the ROM (requires precomputed hex file)
        $display("Starting twiddle_rom test...");

        // Iterate through all addresses
        for (i = 0; i < DEPTH; i++) begin
            addr = i[$clog2(DEPTH)-1:0]; // Assign address
            #10; // Wait for a few time units

            // Display the result
            $display("Address: %d, Data: %h", addr, data);
        end

        $display("Test completed.");
        $finish;
    end
endmodule
