module slave #(
    parameter SLAVE_ID
)(
    interface intf
);

    enum {RECEIVE, RESPONSE} current_state, next_state;

    logic wr;
    logic [intf.ADDR_WIDTH-1:0] addr;
    logic [intf.DATA_WIDTH-1:0] wdata;
    logic [intf.DATA_WIDTH-1:0] rdata;
    logic [intf.DATA_WIDTH-1:0] memory[2**intf.ADDR_WIDTH-1:0];

    always_ff @( posedge intf.clk ) begin
        if (intf.rst) begin
            current_state <= RECEIVE;
        end else begin
            current_state <= next_state;
        end
    end

    always_comb begin
        wr = 1'b0;
        case (current_state)
            RECEIVE: begin
                if (intf.receive_read(SLAVE_ID, addr)) begin
                    next_state = RESPONSE;
                end else if (intf.receive_write(SLAVE_ID, addr, wdata)) begin
                    wr = 1'b1;
                    next_state = RECEIVE;
                end else begin
                    next_state = RECEIVE;
                end
            end
            RESPONSE: begin
                if (intf.response(SLAVE_ID, rdata)) begin
                    next_state = RECEIVE;
                end else begin
                    next_state = RECEIVE;
                end
            end
        endcase
    end

    always_ff @( posedge intf.clk ) begin
        if (wr) begin
            memory[addr] <= wdata;
        end
        rdata <= memory[addr];
    end

endmodule: slave
