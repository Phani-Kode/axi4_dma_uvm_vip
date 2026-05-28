`include "uvm_macros.svh"
import uvm_pkg::*;

class axi4_monitor extends uvm_monitor;
    `uvm_component_utils(axi4_monitor)

    virtual axi4_if vif;
    uvm_analysis_port #(axi4_seq_item) ap;

    // A class-level item explicitly used for the covergroup to sample
    axi4_seq_item cg_item;

    // =========================================================================
    // Functional Coverage Model
    // =========================================================================
    covergroup axi4_cg;
        option.per_instance = 1;
        option.name = "axi4_monitor_coverage";

        // Coverpoint 1: Track if we are seeing both Reads and Writes
        cp_trans_type: coverpoint cg_item.trans_type {
            bins write = {AXI_WRITE};
            bins read  = {AXI_READ};
        }

        // Coverpoint 2: Track the types of bursts used
        cp_burst: coverpoint cg_item.burst {
            bins fixed = {AXI_FIXED};
            bins incr  = {AXI_INCR};
            bins wrap  = {AXI_WRAP};
        }

        // Coverpoint 3: Track varying burst lengths
        cp_len: coverpoint cg_item.len {
            bins single_beat = {0};
            bins short_burst = {[1:15]};
            bins long_burst  = {[16:255]};
        }

        // Cross Coverage: Ensure every burst type is tested for both reads and writes
        cross_trans_burst: cross cp_trans_type, cp_burst;
    endgroup

    function new(string name, uvm_component parent);
        super.new(name, parent);
        ap = new("ap", this);
        // Instantiate the covergroup
        axi4_cg = new();
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db#(virtual axi4_if)::get(this, "", "vif", vif)) begin
            `uvm_fatal("NOVIF", {"Virtual interface must be set for: ", get_full_name(), ".vif"});
        end
    endfunction

    task run_phase(uvm_phase phase);
        @(posedge vif.aclk iff vif.aresetn == 1'b1);
        fork
            monitor_write_channel();
            monitor_read_channel();
        join
    endtask

    task monitor_write_channel();
        axi4_seq_item item;
        forever begin
            @(posedge vif.aclk);
            if (vif.awvalid && vif.awready) begin
                item = axi4_seq_item::type_id::create("item");
                item.trans_type = AXI_WRITE;
                item.addr       = vif.awaddr;
                item.len        = vif.awlen;
                item.burst      = axi_burst_t'(vif.awburst);

                // Sample the coverage model before sending it out
                cg_item = item;
                axi4_cg.sample();

                ap.write(item);
            end
        end
    endtask

    task monitor_read_channel();
        axi4_seq_item item;
        forever begin
            @(posedge vif.aclk);
            if (vif.arvalid && vif.arready) begin
                item = axi4_seq_item::type_id::create("item");
                item.trans_type = AXI_READ;
                item.addr       = vif.araddr;
                item.len        = vif.arlen;
                item.burst      = axi_burst_t'(vif.arburst);

                // Sample the coverage model before sending it out
                cg_item = item;
                axi4_cg.sample();

                ap.write(item);
            end
        end
    endtask
endclass
