`timescale 1ns/1ps

module vga_core_signal_tb;

    localparam real CLK_FREQ_MHZ = 25.2;
    localparam real CLK_PERIOD = 1000.0 / CLK_FREQ_MHZ; // 39.682... ns
    localparam real HALF_PERIOD = CLK_PERIOD / 2.0; // 19.841... ns

    localparam logic [11:0] WHITE   = 12'hFFF;
    localparam logic [11:0] YELLOW  = 12'hFF0;
    localparam logic [11:0] CYAN    = 12'h0FF;
    localparam logic [11:0] GREEN   = 12'h0F0;
    localparam logic [11:0] MAGENTA = 12'hF0F;
    localparam logic [11:0] RED     = 12'hF00;
    localparam logic [11:0] BLUE    = 12'h00F;
    localparam logic [11:0] BLACK   = 12'h000;

    logic clk_pix_i, rstn_i, pattern_i;
    logic [3:0] red_o, green_o, blue_o;
    logic hsync_o, vsync_o;
    // Simulation/debug outputs
    logic [9:0] x_o, y_o;
    logic active_o, frame_end_o;

    vga_core dut (
        .clk_pix_i(clk_pix_i),
        .rstn_i(rstn_i),
        .pattern_i(pattern_i),
        
        .red_o(red_o),
        .green_o(green_o),
        .blue_o(blue_o),
        .hsync_o(hsync_o),
        .vsync_o(vsync_o),

        .x_o(x_o),
        .y_o(y_o),
        .active_o(active_o),
        .frame_end_o(frame_end_o)
    );

    // Initialize CLK
    initial begin
        clk_pix_i = 0;
        forever begin
            #(HALF_PERIOD);
            clk_pix_i = ~clk_pix_i;
        end
    end

    // Initialize RSTN
    initial rstn_i = 0;

    // ACTIVE REGION CHECK
    task automatic check_active(logic exp_active);
        if (exp_active !== active_o)
            $fatal(1, "FAIL active = %0b exp = %0b",
                    active_o,
                    exp_active);
    endtask

    // RGB = 0 when active = 0
    task automatic check_rgb_nactive();
        if ({red_o, green_o, blue_o} !== '0)
            $fatal(1, "FAIL rgb = %0h exp = 0",
                    {red_o, green_o, blue_o});
    endtask


    // Frame contains 420,000 clock cycles and 307,200 active pixels
    int frame_cycle = 0;
    int active_pixel = 0;

    task automatic check_cycle();
        if (active_o) active_pixel = active_pixel + 1;
        if (rstn_i) frame_cycle = frame_cycle + 1;

        if (frame_end_o) begin
            if ((active_pixel !== 307200) || (frame_cycle !== 420000))
                $fatal(1, "active_pixel = %0d frame_cycle = %0d",
                        active_pixel,
                        frame_cycle);
        end
    endtask


    // RGB matches the selected pattern at each visible coordinate
    task automatic check_rgb();
        logic [11:0] exp_rgb;

        if ((pattern_i == 1'b0) && rstn_i) begin
            if (y_o >= 480) begin
                exp_rgb = BLACK;
                if (exp_rgb !== {red_o, green_o, blue_o})
                    $fatal(1, "FAIL");
            end else begin
                if (x_o < 80) begin
                    exp_rgb = WHITE;
                    if (exp_rgb !== {red_o, green_o, blue_o})
                        $fatal(1, "FAIL 1");
                end else if ((x_o >= 80) && (x_o < 160)) begin
                    exp_rgb = YELLOW;
                    if (exp_rgb !== {red_o, green_o, blue_o})
                        $fatal(1, "FAIL 2");
                end else if ((x_o >= 160) && (x_o < 240)) begin
                    exp_rgb = CYAN;
                    if (exp_rgb !== {red_o, green_o, blue_o})
                        $fatal(1, "FAIL 3");
                end else if ((x_o >= 240) && (x_o < 320)) begin
                    exp_rgb = GREEN;
                    if (exp_rgb !== {red_o, green_o, blue_o})
                        $fatal(1, "FAIL 4");
                end else if ((x_o >= 320) && (x_o < 400)) begin
                    exp_rgb = MAGENTA;
                    if (exp_rgb !== {red_o, green_o, blue_o})
                        $fatal(1, "FAIL 5");
                end else if ((x_o >= 400) && (x_o < 480)) begin
                    exp_rgb = RED;
                    if (exp_rgb !== {red_o, green_o, blue_o})
                        $fatal(1, "FAIL 6");
                end else if ((x_o >= 480) && (x_o < 560)) begin
                    exp_rgb = BLUE;
                    if (exp_rgb !== {red_o, green_o, blue_o})
                        $fatal(1, "FAIL 7");
                end else if ((x_o <= 560) && (x_o < 640)) begin
                    exp_rgb = BLACK;
                    if (exp_rgb !== {red_o, green_o, blue_o})
                        $fatal(1, "FAIL 8");
                end else
                    exp_rgb = BLACK;
                    if (exp_rgb !== {red_o, green_o, blue_o})
                        $fatal(1, "FAIL 9");
            end
        end else if ((pattern_i == 1'b1) && rstn_i) begin
            if ((x_o >= 640) || (y_o >= 480)) begin
                exp_rgb = BLACK;
                if (exp_rgb !== {red_o, green_o, blue_o})
                    $fatal(1, "FAIL00");
            end else begin
                if ((x_o >= 240) && (x_o < 400) && (y_o >= 180) && (y_o < 300)) begin
                    exp_rgb = WHITE;
                    if (exp_rgb !== {red_o, green_o, blue_o})
                        $fatal(1, "FAIL01");
                end else begin
                    exp_rgb = BLUE;
                    if (exp_rgb !== {red_o, green_o, blue_o})
                        $fatal(1, "FAIL02");
                end
            end
        end
    endtask

    initial begin
        pattern_i = 0;
        #100;
        rstn_i = 1;
        wait(frame_end_o)
            repeat (2) @(negedge clk_pix_i);
        rstn_i = 0;
        pattern_i = 1;
        #100;
        rstn_i = 1;
        wait(frame_end_o)       // wraparound/second loop
            repeat (2) @(negedge clk_pix_i);
        repeat (400) @(negedge clk_pix_i);
        rstn_i = 0;
        @(negedge clk_pix_i);
        if ((x_o !== 0) || (y_o !== 0) || (active_o !== 0) || (frame_end_o !== 0) ||
            (hsync_o !== 1) || (vsync_o !== 1)) begin
            $fatal(1, "FAIL MIDWAY RESET");
        end
        @(negedge clk_pix_i);
        $finish;
    end

    always @(negedge clk_pix_i) begin
        if (rstn_i && ((x_o < 640) && (y_o < 480)))
            check_active(1'b1);
        else
            check_active(1'b0);
    end

    always @(negedge clk_pix_i) begin
        if (active_o === 1'b0)
            check_rgb_nactive();
    end

    always @(negedge clk_pix_i) begin
        check_cycle();
        if (!rstn_i || frame_end_o) begin
            active_pixel = 0;
            frame_cycle = 0;
        end
    end

    always @(negedge clk_pix_i) begin
        check_rgb();
    end

endmodule
