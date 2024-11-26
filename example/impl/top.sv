module top #(
    parameter  int DATA_WIDTH = 8,
    parameter  int ADDR_WIDTH = 3,
    localparam int NO_OF_SLAVES = 2
)(
    input  logic clk,
    input  logic rst,
    input  [ADDR_WIDTH-1:0]       addr,
    output [DATA_WIDTH-1:0]       rdata,
    input  [DATA_WIDTH-1:0]       wdata,
    input                         rd,
    input                         wr,
    input  [NO_OF_SLAVES-1:0]     en
);

    bus #(
        .NO_OF_SLAVES(NO_OF_SLAVES)
    ) bus (
        .clk(clk),
        .rst(rst)
    );

    slave #(0) slave0 (bus.slave0);
    slave #(1) slave1 (bus.slave1);

    assign bus.addr = addr;
    assign bus.wdata = wdata;
    assign bus.wr = wr;
    assign bus.rd = rd;
    assign bus.en = en[NO_OF_SLAVES-1:0];
    assign rdata = bus.m_rdata;

endmodule: top
