`timescale 1ns/1ps

module vga_core_rect_tb;

    localparam real CLK_FREQ_MHZ = 25.2;
    localparam real CLK_PERIOD = 1000.0 / CLK_FREQ_MHZ; // 39.682... ns
    localparam real HALF_PERIOD = CLK_PERIOD / 2.0; // 19.841... ns

    logic clk_pix_i, rstn_i;
    logic [1:0] pattern_i;
    logic [3:0] red_o, green_o, blue_o;
    logic hsync_o, vsync_o;
    // Simulation/debug outputs
    logic [9:0] x_o, y_o;
    logic active_o, frame_end_o;

    int fd0;

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

    initial begin
        pattern_i = 2'b01;
        #100;
        rstn_i = 1;
        wait (frame_end_o)
            @(posedge clk_pix_i);
        $finish;
    end

    initial begin
        fd0 = $fopen ("rectangle.ppm", "w");
        $fdisplay(fd0, "P3");
        $fdisplay(fd0, "640 480");
        $fdisplay(fd0, "15");
        for (int i = 0; i < 420000; i++) begin
            @(negedge clk_pix_i);
            if (active_o)
                $fdisplay(fd0, "%0d %0d %0d", red_o, green_o, blue_o);
            else
                wait (active_o);
        end
        $fclose(fd0);
    end

    // initial begin
    //     $monitor("x_o = %0d y_o = %0d | red_o = %0h green_o = %0h blue_o = %0h | active_o = %0b hsync = %0b vysnc = %0b frame_end = %0b",
    //             x_o,
    //             y_o,
    //             red_o,
    //             green_o,
    //             blue_o,
    //             active_o,
    //             hsync_o,
    //             vsync_o,
    //             frame_end_o);
    // end

endmodule
