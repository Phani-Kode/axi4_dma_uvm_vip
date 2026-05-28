import uvm_pkg::*;
`include "uvm_macros.svh"

module tb_top;
    logic aclk;
    logic aresetn;

    // 1. Clock Generation (100 MHz)
    initial begin
        aclk = 0;
        forever #5 aclk = ~aclk;
    end

    // 2. Reset Generation (Active Low)
    initial begin
        aresetn = 0;
        #25 aresetn = 1;
    end

    // 3. Instantiate the AXI4 Interface
    axi4_if vif (
        .aclk(aclk),
        .aresetn(aresetn)
    );

    // Note: In a full project, you would instantiate your RTL DMA controller here
    // and connect it to the `vif`. For this VIP verification environment,
    // the interface pins will be driven directly by our UVM driver.

    // 4. Pass Virtual Interface to UVM and Run Test
    initial begin
        uvm_config_db#(virtual axi4_if)::set(null, "*", "vif", vif);
        run_test("dma_test");
    end

    // Optional: Waveform dumping for QuestaSim / VCS debugging
    initial begin
        $dumpfile("axi_dma.vcd");
        $dumpvars(0, tb_top);
    end
endmodule
