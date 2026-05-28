interface axi4_if #(
    parameter ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 32,
    parameter ID_WIDTH   = 4
)(
    input logic aclk,
    input logic aresetn
);

    // Write Address Channel (AW)
    logic [ID_WIDTH-1:0]   awid;
    logic [ADDR_WIDTH-1:0] awaddr;
    logic [7:0]            awlen;
    logic [2:0]            awsize;
    logic [1:0]            awburst;
    logic                  awvalid;
    logic                  awready;

    // Write Data Channel (W)
    logic [DATA_WIDTH-1:0]     wdata;
    logic [(DATA_WIDTH/8)-1:0] wstrb;
    logic                      wlast;
    logic                      wvalid;
    logic                      wready;

    // Write Response Channel (B)
    logic [ID_WIDTH-1:0] bid;
    logic [1:0]          bresp;
    logic                bvalid;
    logic                bready;

    // Read Address Channel (AR)
    logic [ID_WIDTH-1:0]   arid;
    logic [ADDR_WIDTH-1:0] araddr;
    logic [7:0]            arlen;
    logic [2:0]            arsize;
    logic [1:0]            arburst;
    logic                  arvalid;
    logic                  arready;

    // Read Data Channel (R)
    logic [ID_WIDTH-1:0]   rid;
    logic [DATA_WIDTH-1:0] rdata;
    logic [1:0]            rresp;
    logic                  rlast;
    logic                  rvalid;
    logic                  rready;

    // =========================================================================
    // SystemVerilog Assertions (SVA) for AXI Handshake and Protocol Validation
    // =========================================================================

    // 1. Handshake Rule: VALID cannot drop until READY is asserted
    property p_awvalid_stable;
        @(posedge aclk) disable iff (!aresetn)
        awvalid && !awready |=> awvalid;
    endproperty
    assert property (p_awvalid_stable) else $error("AXI Protocol Violation: AWVALID dropped before AWREADY");

    property p_wvalid_stable;
        @(posedge aclk) disable iff (!aresetn)
        wvalid && !wready |=> wvalid;
    endproperty
    assert property (p_wvalid_stable) else $error("AXI Protocol Violation: WVALID dropped before WREADY");

    // 2. Reset Rule: VALID signals must be low after reset
    property p_reset_val_low;
        @(posedge aclk)
        !aresetn |=> (!awvalid && !wvalid && !bvalid && !arvalid && !rvalid);
    endproperty
    assert property (p_reset_val_low) else $error("AXI Protocol Violation: VALID signals not 0 after reset");

    // 3. Payload Stability: Data/Address cannot change while waiting for READY
    property p_awaddr_stable;
        @(posedge aclk) disable iff (!aresetn)
        awvalid && !awready |=> $stable(awaddr);
    endproperty
    assert property (p_awaddr_stable) else $error("AXI Protocol Violation: AWADDR changed while waiting for AWREADY");

endinterface
