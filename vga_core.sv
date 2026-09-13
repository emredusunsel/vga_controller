// Instantiate vga_timing and vga_pattern
// connect the timing coordinates and active signal to the
// pattern generator. Expose the timign and RGB outputs 
// through the core

// The coordinate/debug outputs help simulation; they do not
// need physical board pins.

// RGB, coordinates, active, and sync all describe the same
// pixel interval. Do not register only RGB, because that would
// shift the colours relative to the timing

// There is no ready signal or backpressure. Once running,
// the core must produce one pixel interval every clokc continuously

// Do not need a framebuffer:
// A framebuffer stores an image in memory
// Here, each pixel colour is calculated directly from its coordinate
// "The current coordinate is inside the rectangle, so output white"
// The means you only need counters, comparisons, and colour-selection
// logic. You do not need to store 307,200 pixels

// Even when the picture is static, the controller must keep
// transmitting it repeatedly.

`timescale 1ps/1ps

module vga_core (
    input   logic   clk_pix_i,
    input   logic   rstn_i,
    input   logic   pattern_i,

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
    
endmodule
