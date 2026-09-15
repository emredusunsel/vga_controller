// - Draw a 32x32 white square on a blue background
// - Move it one pixel horizontally and vertically per frame
// - Update its position only when frame_end_o is high at a risign pixel-clock edge
// - Reverse horizontal direction at the left and right boundaries
// - Reverse vertical direction at the top and bottom boundaries

// Updating during a frame blanking keeps the squares position constant
// thorughout the visible scan. If its position changed midway through
// drawing the picture, different rows could show different positions
// a form of tearing

// Your frame-end signal now has a practical purpose: it acts as a clock enable
// while all registers still use clk_pix_i. Dont use it as a seperate clock

// For a 32x32 square, its top-left coordinate must stay within:
//  0 <= x <= 608, 0 <= y <= 448

// The drawing condition becomes:
//  (x_i >= square_x) && (x_i < square_x + 32) &&
//  (y_i >= square_y) && (y_i < square_y + 32)

`timescale 1ns/1ps

module vga_pattern (
    input   logic   [9:0]   x_i,        // Horizontal coordinate
    input   logic   [9:0]   y_i,        // Vertical coordinate
    input   logic           active_i,   // Visible are qualification
    
    output  logic   [3:0]   red_o,      // Red intensity
    output  logic   [3:0]   green_o,    // Green intensity
    output  logic   [3:0]   blue_o      // Blue intensity
);

    localparam logic [11:0] WHITE   = 12'hFFF;
    localparam logic [11:0] YELLOW  = 12'hFF0;
    localparam logic [11:0] CYAN    = 12'h0FF;
    localparam logic [11:0] GREEN   = 12'h0F0;
    localparam logic [11:0] MAGENTA = 12'hF0F;
    localparam logic [11:0] RED     = 12'hF00;
    localparam logic [11:0] BLUE    = 12'h00F;
    localparam logic [11:0] BLACK   = 12'h000;

    logic [11:0] rgb;

    always_comb begin : vga_pattern_block
        if (!active_i)
            rgb = 12'h000;
        else begin

        end
    end

    assign red_o   = rgb[11:8];
    assign green_o = rgb[ 7:4];
    assign blue_o  = rgb[ 3:0];

endmodule
