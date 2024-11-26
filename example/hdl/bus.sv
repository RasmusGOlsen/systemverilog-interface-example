interface bus #(
    parameter int                    ADDR_WIDTH = 3,
    parameter int                    DATA_WIDTH = 8,
    parameter int                    MAX_NO_OF_SLAVES = 4,
    parameter int                    NO_OF_SLAVES = 2,
    parameter bit                    ENABLE_MASTER_API = 1,
    parameter bit [NO_OF_SLAVES-1:0] ENABLE_SLAVE_API = '1
) (
    input logic clk,
    input logic rst
);

    logic [ADDR_WIDTH-1:0]       addr;
    logic [DATA_WIDTH-1:0]       m_rdata;
    logic [DATA_WIDTH-1:0]       s_rdata[MAX_NO_OF_SLAVES-1:0];
    logic [DATA_WIDTH-1:0]       wdata;
    logic                        rd;
    logic                        wr;
    logic [MAX_NO_OF_SLAVES-1:0] en;

    modport master (
        input m_rdata,
        output addr, rd, wr, en, wdata,
        import read, write, get_response
    );

    modport slave0 (
        input clk, rst, addr, rd, wr, en, wdata,
        output s_rdata,
        import receive_read, receive_write, response
    );

    modport slave1 (
        input clk, rst, addr, rd, wr, en, wdata,
        output s_rdata,
        import receive_read, receive_write, response
    );

    modport slave2 (
        input clk, rst, addr, rd, wr, en, wdata,
        output s_rdata,
        import receive_read, receive_write, response
    );

    modport slave3 (
        input clk, rst, addr, rd, wr, en, wdata,
        output s_rdata,
        import receive_read, receive_write, response
    );


    enum {READY, RESPONSE} current_state[NO_OF_SLAVES], next_state[NO_OF_SLAVES];


    function read(input logic [ADDR_WIDTH-1:0] a);
    endfunction: read

    function write(input logic [ADDR_WIDTH-1:0] a, input logic [DATA_WIDTH-1:0] d);
    endfunction: write

    function bit get_response(output logic [DATA_WIDTH-1:0] d);
    endfunction: get_response

    function bit receive_read(input int id, output logic [ADDR_WIDTH-1:0] a);
        if (rd && en[id]) begin
            a = addr;
            return 1'b1;
        end else begin
            return 1'b0;
        end
    endfunction: receive_read

    function bit receive_write(input int id, output logic [ADDR_WIDTH-1:0] a, output logic [DATA_WIDTH-1:0] d);
        if (wr && en[id]) begin
            a = addr;
            d = wdata;
            return 1'b1;
        end else begin
            return 1'b0;
        end
    endfunction: receive_write

    function response(input int id, input logic [DATA_WIDTH-1:0] d);
        if (current_state[id] == RESPONSE) begin
            s_rdata[id] = d;
            return 1'b1;
        end else begin
            return 1'b0;
        end
    endfunction: response


    always_comb begin
        case (en)
            4'b0001: m_rdata = s_rdata[0];
            4'b0010: m_rdata = s_rdata[1];
            4'b0100: m_rdata = s_rdata[2];
            4'b1000: m_rdata = s_rdata[3];
            default: m_rdata = 0;
        endcase
    end


    generate
        if (ENABLE_MASTER_API) begin
            // always_ff @( posedge clk ) fsm_master_ff();
            // always_comb fsm_master_comb();
        end
        for (genvar i = 0; i < NO_OF_SLAVES; i = i + 1) begin: slaves
            localparam int SLAVE_ID = i;

            if (ENABLE_SLAVE_API[i]) begin
                always_ff @( posedge clk ) begin
                    if (rst) begin
                        current_state[SLAVE_ID] <= READY;
                    end else begin
                        current_state[SLAVE_ID] <= next_state[SLAVE_ID];
                    end
                end

                always_comb begin
                    case (current_state[SLAVE_ID])
                        READY: begin
                            if (en[SLAVE_ID]) begin
                                if (rd) begin
                                    next_state[SLAVE_ID] = RESPONSE;
                                end else if (wr) begin
                                    next_state[SLAVE_ID] = READY;
                                end else begin
                                    next_state[SLAVE_ID] = READY;
                                end
                            end
                        end
                        RESPONSE: begin
                            next_state[SLAVE_ID] = READY;
                        end
                    endcase
                end

            end
        end
    endgenerate

endinterface: bus
