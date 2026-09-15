`timescale 1ns/1ps

module vga_pattern_tb;

    localparam logic [11:0] WHITE   = 12'hFFF;
    localparam logic [11:0] YELLOW  = 12'hFF0;
    localparam logic [11:0] CYAN    = 12'h0FF;
    localparam logic [11:0] GREEN   = 12'h0F0;
    localparam logic [11:0] MAGENTA = 12'hF0F;
    localparam logic [11:0] RED     = 12'hF00;
    localparam logic [11:0] BLUE    = 12'h00F;
    localparam logic [11:0] BLACK   = 12'h000;

    logic [9:0] x_i, y_i;
    logic active_i;
    logic [1:0] pattern_i;
    logic [3:0] red_o, green_o, blue_o;

    vga_pattern dut (
        .x_i(x_i),
        .y_i(y_i),
        .active_i(active_i),
        .pattern_i(pattern_i),
        .red_o(red_o),
        .green_o(green_o),
        .blue_o(blue_o)
    );

    task automatic check(
        logic [11:0] exp_rgb
    );
        #1;

        if (exp_rgb[11:8] !== red_o)
            $fatal(1, "FAIL red = %0h exp = %0h", red_o, exp_rgb[11:8]);
        if (exp_rgb[7:4] !== green_o)
            $fatal(1, "FAIL green = %0h exp = %0h", green_o, exp_rgb[7:4]);
        if (exp_rgb[3:0] !== blue_o)
            $fatal(1, "FAIL blue = %0h exp = %0h", blue_o, exp_rgb[3:0]);

    endtask

    task automatic pattern1();
        if ((x_i >= 640) || (y_i >= 480))
            check(BLACK);
        else begin
            if (x_i < 80)
                check(WHITE);
            else if ((x_i >= 80) && (x_i < 160))
                check(YELLOW);
            else if ((x_i >= 160) && (x_i < 240))
                check(CYAN);
            else if ((x_i >= 240) && (x_i < 320))
                check(GREEN);
            else if ((x_i >= 320) && (x_i < 400))
                check(MAGENTA);
            else if ((x_i >= 400) && (x_i < 480))
                check(RED);
            else if ((x_i >= 480) && (x_i < 560))
                check(BLUE);
            else if ((x_i >= 560) && (x_i < 640))
                check(BLACK);
        end
    endtask

    task automatic pattern2();
        if ((x_i >= 640) || (y_i >= 480))
            check(BLACK);
        else begin
            if ((x_i >= 240) && (x_i < 400) && (y_i >= 180) && (y_i < 300))
                check(WHITE);
            else
                check(BLUE);
        end
    endtask

    initial begin
        pattern_i = 2'b00;
        active_i = 1;
    end

    initial begin
        for (int ycount = 0; ycount < 525; ycount++) begin
            y_i = ycount;
            for (int xcount = 0; xcount < 800; xcount++) begin
                x_i = xcount;
                if ((x_i < 640) && (y_i < 480)) // visible
                    active_i = 1;
                else
                    active_i = 0;
                pattern1();
                #5;
            end
        end

        #50; 
        $display("PATTERN 1: PASSED");
        #50;
        pattern_i = 2'b01;

        for (int ycnt = 0; ycnt < 525; ycnt++) begin
            y_i = ycnt;
            for (int xcnt = 0; xcnt < 800; xcnt++) begin
                x_i = xcnt;
                if ((x_i < 640) && (y_i < 480)) // visible
                    active_i = 1;
                else
                    active_i = 0;
                pattern2();
                #5;
            end
        end

        #50;
        $display("PATTERN 2: PASSED");
        #50;

        $finish;
    end

    // initial begin
    //     $monitor("x_i = %0d | y_i = %0d || red_o = %0h | green_o = %0h | blue_o = %0h",
    //             x_i,
    //             y_i,
    //             red_o,
    //             green_o,
    //             blue_o);
    // end

endmodule
