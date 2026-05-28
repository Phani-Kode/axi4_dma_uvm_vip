`include "uvm_macros.svh"
import uvm_pkg::*;

typedef enum bit [1:0] {
    AXI_FIXED = 2'b00,
    AXI_INCR  = 2'b01,
    AXI_WRAP  = 2'b10
} axi_burst_t;

typedef enum bit {
    AXI_READ  = 1'b0,
    AXI_WRITE = 1'b1
} axi_trans_type_t;

class axi4_seq_item #(parameter ADDR_WIDTH = 32, parameter DATA_WIDTH = 32) extends uvm_sequence_item;

    // Transaction Metadata
    rand axi_trans_type_t trans_type;

    // AXI Address Channel Fields
    rand logic [3:0]            id;
    rand logic [ADDR_WIDTH-1:0] addr;
    rand logic [7:0]            len;   // Burst length: 1 to 256 transfers
    rand logic [2:0]            size;  // Bytes per transfer
    rand axi_burst_t            burst;

    // Data Fields
    rand logic [DATA_WIDTH-1:0]     data [];
    rand logic [(DATA_WIDTH/8)-1:0] strb [];

    // Response Fields (populated by Monitor)
    logic [1:0] resp;

    `uvm_object_utils_begin(axi4_seq_item)
        `uvm_field_enum(axi_trans_type_t, trans_type, UVM_ALL_ON)
        `uvm_field_int(addr, UVM_ALL_ON)
        `uvm_field_int(len, UVM_ALL_ON)
        `uvm_field_int(size, UVM_ALL_ON)
        `uvm_field_enum(axi_burst_t, burst, UVM_ALL_ON)
        `uvm_field_array_int(data, UVM_ALL_ON)
    `uvm_object_utils_end

    function new(string name = "axi4_seq_item");
        super.new(name);
    endfunction

    // ---------------------------------------------------------
    // Constraints for valid AXI4 traffic generation
    // ---------------------------------------------------------

    // Data array size must match the burst length (len is N-1)
    constraint c_data_size {
        data.size() == (len + 1);
        strb.size() == (len + 1);
    }

    // Wrap bursts must have lengths of 2, 4, 8, or 16
    constraint c_wrap_len {
        if (burst == AXI_WRAP) {
            len inside {1, 3, 7, 15}; // N-1
        }
    }

    // Size constraint: Cannot exceed the physical data bus width
    constraint c_size_limit {
        (1 << size) <= (DATA_WIDTH / 8);
    }

    // 4KB boundary restriction: A burst must not cross a 4KB boundary
    constraint c_4kb_boundary {
        ((addr & 12'hFFF) + ((len + 1) * (1 << size))) <= 13'h1000;
    }

endclass
