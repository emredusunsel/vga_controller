
// Both coordinates need 10 bits:
//      y must reach 524, which does not fit in 9 bits

// On every rising edge:
//  1. If reset is low, set both coordinates to zero.
//  2. Otherwise, if x is less than 799, increment x and hold y
//  3. If x is 799, set x to zero and advance y
//  4. If both x is 799 and y is 524, wrap both to zero

// Do not use hsync as a clock for the vertical counter.
// Both counters use clk_pix_i;
//  the horizontal terminal count enables the vertical increment

// | Output      | Required Behaviour outside reset        |
// |-------------|-----------------------------------------|
// | active_o    | HIGH when x < 640 and y < 480           |
// | hsync_o     | LOW when 656 <= x < 752; HIGH otherwise |
// | vsync_o     | LOW when 490 <= y < 492; HIGH otherwise |
// | frame_end_o | HIGH onlt when x = 799 and y = 524      |

// frame_end_o lasts one pixel interval.
//  Another sequential block can use it as an enable on the rising edge
//  that wraps the counters

// > Derive these outputs combinationallt from the current counters,
//      without adding output pipeline registers

// Reset behaviour:
//  - A risign edge with rstn_i = 0 sets x_o = 0, y_o = 0
//  - While reset is low, force active_o = 0, frame_end_o = 0,
//      and both sync outputs high
//  - After reset is released, (0, 0) becomes the first active
//      interval before the next rising edge advances to (1, 0)
// This defines the initial pixel precisely and avoids ambiguity
//  in testbench

// Required output values outside reset:
// | Current(x, y) | Active | HSYNC | VSYNC | Meaning                            |
// |---------------|--------|-------|-------|------------------------------------|
// | (  0,   0)    | 1      | 1     | 1     | First visible pixel                |
// | (639,   0)    | 1      | 1     | 1     | Last visible pixel of first line   |
// | (640,   0)    | 0      | 1     | 1     | Horizontal front porch starts      |
// | (655,   0)    | 0      | 1     | 1     | Last front porch interval          |
// | (656,   0)    | 0      | 0     | 1     | Horizontal sync starts             |
// | (751,   0)    | 0      | 0     | 1     | Last horizontal sync interval      |
// | (752,   0)    | 0      | 1     | 1     | Back porch starts                  |
// | (799,   0)    | 0      | 1     | 1     | Last interval of first line        |
// | (  0,   1)    | 1      | 1     | 1     | First visible pixel of second line |
// | (  0, 480)    | 0      | 1     | 1     | Vertical blanking starts           |
// | (  0, 490)    | 0      | 1     | 0     | Vertival sync starts               |
// | (  0, 492)    | 0      | 1     | 1     | Vertical back porch starts         |
// | (799, 524)    | 0      | 1     | 1     | Last interval of frame             |

// Horizontal scanning and horicaontal sync continue during
//  verical blanking. For example, at (649, 490) both
//  sync signals are low


`timescale 1ps/1ps

module vga_timing (
    input   logic           clk_pix_i,  // Pixel clock
    input   logic           rstn_i,     // Synchronous active-low reset
    
    output  logic   [9:0]   x_o,        // Current horizontal positioning, including blanking
    output  logic   [9:0]   y_o,        // Current vertical positioning, including blanking
    output  logic           active_o,   // Current position is visible
    output  logic           hsync_o,    // Horizontal sync
    output  logic           vsync_o,    // Vertical sync
    output  logic           frame_end_o // Current position is the last interval of the fram
);



endmodule
