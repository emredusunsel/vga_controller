`timescale 1ns/1ps

module vga_timing_tb;

    localparam real CLK_FREQ_MHZ = 25.2;
    localparam real CLK_PERIOD = 1000.0 / CLK_FREQ_MHZ; // 39.68253968... ns
    localparam real HALF_PERIOD = CLK_PERIOD / 2.0; // 19.84126984... ns

    logic clk_pix_i, rstn_i;
    logic [9:0] x_o, y_o;
    logic active_o, hsync_o, vsync_o, frame_end_o;

    vga_timing dut (
        .clk_pix_i(clk_pix_i),
        .rstn_i(rstn_i),
        .x_o(x_o),
        .y_o(y_o),
        .active_o(active_o),
        .hsync_o(hsync_o),
        .vsync_o(vsync_o),
        .frame_end_o(frame_end_o)
    );

    task automatic check(
        logic exp_active,
        logic exp_hsync,
        logic exp_vsync,
        logic exp_frame_end
    );
        #1;
        if (exp_active !== active_o)
            $fatal(1, "active fail %0d x_o = %0d | y_o = %0d",
                    active_o, x_o, y_o);
        if (exp_hsync !== hsync_o)
            $fatal(1, "hsync fail %0d x_o = %0d | y_o = %0d",
                    hsync_o, x_o, y_o);
        if (exp_vsync !== vsync_o)
            $fatal(1, "vsync fail %0d x_o = %0d | y_o = %0d",
                    vsync_o, x_o, y_o);
        if (exp_frame_end !== frame_end_o)
            $fatal(1, "frame_end fail %0d x_o = %0d | y_o = %0d",
                    frame_end_o, x_o, y_o);            

    endtask

    task automatic cycle();
        wait ((x_o == 639) && (y_o == 0))
            check(1, 1, 1, 0);

        wait ((x_o == 640) && (y_o == 0))
            check(0, 1, 1, 0);

        wait ((x_o == 655) && (y_o == 0))
            check(0, 1, 1, 0);

        wait ((x_o == 656) && (y_o == 0))
            check(0, 0, 1, 0);

        wait ((x_o == 751) && (y_o == 0))
            check(0, 0, 1, 0);

        wait ((x_o == 752) && (y_o == 0))
            check(0, 1, 1, 0);

        wait ((x_o == 799) && (y_o == 0))
            check(0, 1, 1, 0);

        wait ((x_o == 0) && (y_o == 1))
            check(1, 1, 1, 0);

        wait ((x_o == 0) && (y_o == 480))
            check(0, 1, 1, 0);

        wait ((x_o == 0) && (y_o == 490))
            check(0, 1, 0, 0);

        wait ((x_o == 0) && (y_o == 492))
            check(0, 1, 1, 0);

        wait ((x_o == 799) && (y_o == 524))
            check(0, 1, 1, 1);

        #1;
        $display("Cycle PASS");
    endtask

    initial begin
        clk_pix_i = 1'b0;
        forever begin
            #(HALF_PERIOD);
            clk_pix_i = ~clk_pix_i;
        end
    end

    initial begin
        rstn_i = 0;
    end

    initial begin
        repeat (2) @(negedge clk_pix_i);
        check(0, 1, 1, 0);
        if ((x_o !== '0) | (y_o !== '0))
            $fatal(1, "FAIL");
        @(negedge clk_pix_i);
        rstn_i = 1;
        cycle();
        cycle();

        #10;

        $finish;
    end

endmodule
