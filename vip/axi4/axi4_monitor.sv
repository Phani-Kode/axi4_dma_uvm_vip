`include "uvm_macros.svh"
import uvm_pkg::*;

class axi4_monitor extends uvm_monitor;
    `uvm_component_utils(axi4_monitor)

    virtual axi4_if vif;
    uvm_analysis_port #(axi4_seq_item) ap;

    function new(string name, uvm_component parent);
        super.new(name, parent);
        ap = new("ap", this);
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

    // Passively monitor write transactions
    task monitor_write_channel();
        axi4_seq_item item;
        forever begin
            @(posedge vif.aclk);
            // Detect AW Handshake
            if (vif.awvalid && vif.awready) begin
                item = axi4_seq_item::type_id::create("item");
                item.trans_type = AXI_WRITE;
                item.addr       = vif.awaddr;
                item.len        = vif.awlen;
                item.burst      = axi_burst_t'(vif.awburst);

                // (In a full VIP, you would spawn a separate process to track the W and B channels
                // independently due to AXI's out-of-order completion capabilities.
                // For this example, we'll keep the capture simple.)

                ap.write(item); // Send to scoreboard
            end
        end
    endtask

    // Passively monitor read transactions
    task monitor_read_channel();
        axi4_seq_item item;
        forever begin
            @(posedge vif.aclk);
            // Detect AR Handshake
            if (vif.arvalid && vif.arready) begin
                item = axi4_seq_item::type_id::create("item");
                item.trans_type = AXI_READ;
                item.addr       = vif.araddr;
                item.len        = vif.arlen;
                item.burst      = axi_burst_t'(vif.arburst);

                ap.write(item); // Send to scoreboard
            end
        end
    endtask
endclass
