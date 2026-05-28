`include "uvm_macros.svh"
import uvm_pkg::*;

class axi4_driver extends uvm_driver #(axi4_seq_item);
    `uvm_component_utils(axi4_driver)

    virtual axi4_if vif;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db#(virtual axi4_if)::get(this, "", "vif", vif)) begin
            `uvm_fatal("NOVIF", {"Virtual interface must be set for: ", get_full_name(), ".vif"});
        end
    endfunction

    task run_phase(uvm_phase phase);
        // Initialize signals to 0
        vif.awvalid <= 0; vif.wvalid <= 0; vif.arvalid <= 0;
        vif.bready  <= 1; vif.rready <= 1; // Always ready to accept responses for this basic VIP

        @(posedge vif.aclk iff vif.aresetn == 1'b1);

        forever begin
            seq_item_port.get_next_item(req);

            if (req.trans_type == AXI_WRITE) begin
                drive_write(req);
            end else begin
                drive_read(req);
            end

            seq_item_port.item_done();
        end
    endtask

    // Task to drive an AXI Write Burst
    task drive_write(axi4_seq_item item);
        // 1. Write Address Phase (AW Channel)
        @(posedge vif.aclk);
        vif.awid    <= item.id;
        vif.awaddr  <= item.addr;
        vif.awlen   <= item.len;
        vif.awsize  <= item.size;
        vif.awburst <= item.burst;
        vif.awvalid <= 1;
        @(posedge vif.aclk iff vif.awready == 1'b1);
        vif.awvalid <= 0;

        // 2. Write Data Phase (W Channel)
        foreach (item.data[i]) begin
            @(posedge vif.aclk);
            vif.wdata  <= item.data[i];
            vif.wstrb  <= item.strb[i];
            vif.wlast  <= (i == item.len) ? 1'b1 : 1'b0;
            vif.wvalid <= 1;
            @(posedge vif.aclk iff vif.wready == 1'b1);
        end
        vif.wvalid <= 0;
        vif.wlast  <= 0;

        // 3. Write Response Phase (Wait for BVALID)
        @(posedge vif.aclk iff vif.bvalid == 1'b1);
        item.resp = vif.bresp;
    endtask

    // Task to drive an AXI Read Burst
    task drive_read(axi4_seq_item item);
        // 1. Read Address Phase (AR Channel)
        @(posedge vif.aclk);
        vif.arid    <= item.id;
        vif.araddr  <= item.addr;
        vif.arlen   <= item.len;
        vif.arsize  <= item.size;
        vif.arburst <= item.burst;
        vif.arvalid <= 1;
        @(posedge vif.aclk iff vif.arready == 1'b1);
        vif.arvalid <= 0;

        // 2. Read Data Phase (R Channel)
        item.data = new[item.len + 1];
        for (int i = 0; i <= item.len; i++) begin
            @(posedge vif.aclk iff vif.rvalid == 1'b1);
            item.data[i] = vif.rdata;
            if (vif.rlast) break;
        end
    endtask
endclass
