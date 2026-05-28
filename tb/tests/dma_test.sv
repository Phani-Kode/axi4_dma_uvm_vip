`include "uvm_macros.svh"
import uvm_pkg::*;

class dma_test extends uvm_test;
    `uvm_component_utils(dma_test)

    dma_env           env;
    dma_base_sequence seq;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        env = dma_env::type_id::create("env", this);
    endfunction

    task run_phase(uvm_phase phase);
        phase.raise_objection(this);

        seq = dma_base_sequence::type_id::create("seq");

        // Start the sequence on the AXI Agent's sequencer
        seq.start(env.axi_agnt.sqr);

        // Wait for final transactions to drain
        #500;

        phase.drop_objection(this);
    endtask
endclass
