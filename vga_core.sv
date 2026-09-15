// Instantiate vga_timing and vga_pattern
// connect the timing coordinates and active signal to the
// pattern generator. Expose the timing and RGB outputs 
// through the core

// The coordinate/debug outputs help simulation; they do not
// need physical board pins.

// RGB, coordinates, active, and sync all describe the same
// pixel interval. Do not register only RGB, because that would
// shift the colours relative to the timing

// There is no ready signal or backpressure. Once running,
// the core must produce one pixel interval every clock continuously

// Do not need a framebuffer:
// A framebuffer stores an image in memory
// Here, each pixel colour is calculated directly from its coordinate
// "The current coordinate is inside the rectangle, so output white"
// The means you only need counters, comparisons, and colour-selection
// logic. You do not need to store 307,200 pixels

// Even when the picture is static, the controller must keep
// transmitting it repeatedly.

`timescale 1ns/1ps

module vga_core (
    input   logic   clk_pix_i,
    input   logic   rstn_i,
    input   logic   [1:0]   pattern_i,

    output  logic   [3:0]   red_o,
    output  logic   [3:0]   green_o,
    output  logic   [3:0]   blue_o,
    output  logic           hsync_o,
    output  logic           vsync_o,

    // Simulation/debug outputs
    output  logic   [9:0]   x_o,
    output  logic   [9:0]   y_o,
    output  logic           active_o,
    output  logic           frame_end_o
);
    
    logic [9:0] x_w, y_w;
    logic active_w;

    vga_timing u_vga_timing (
        .clk_pix_i  (clk_pix_i),
        .rstn_i     (rstn_i),
        
        .x_o        (x_w),
        .y_o        (y_w),
        .active_o   (active_w),
        .hsync_o    (hsync_o),
        .vsync_o    (vsync_o),
        .frame_end_o(frame_end_o)
    );

    vga_pattern u_vga_pattern (
        .x_i      (x_w),
        .y_i      (y_w),
        .active_i (active_w),
        .pattern_i(pattern_i),

        .red_o    (red_o),
        .green_o  (green_o),
        .blue_o   (blue_o)
    );

    assign x_o = x_w;
    assign y_o = y_w;
    assign active_o = active_w;

endmodule
