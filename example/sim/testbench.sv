module testbench;

    logic clk = 0;
    logic rst = 1;

    always #5ns clk = !clk;

    bus #(
        .NO_OF_SLAVES(2),
        .ENABLE_MASTER_API(0)
    ) bus (
        .clk(clk),
        .rst(rst)
    );

    slave #(0) slave0 (bus.slave0);
    slave #(1) slave1 (bus.slave1);

endmodule: testbench
