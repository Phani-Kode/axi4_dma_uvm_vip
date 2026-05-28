`include "uvm_macros.svh"
import uvm_pkg::*;

class dma_env extends uvm_env;
    `uvm_component_utils(dma_env)

    // Instantiate your VIP Agent and your Testbench Scoreboard
    axi4_agent     axi_agnt;
    dma_scoreboard scb;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        axi_agnt = axi4_agent::type_id::create("axi_agnt", this);
        scb      = dma_scoreboard::type_id::create("scb", this);
    endfunction

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);

        // Connect the Monitor's analysis port to the Scoreboard's export
        axi_agnt.mon.ap.connect(scb.ap_export);
    endfunction
endclass
