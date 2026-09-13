// > Combinational. No clock or reset

// Highest priority rule:
//      whenever active_i = 0, all RGB outputs must be zero
//  That includes the porches as well as the sync intervals
//  Merely checking whether a sync signal is low is insufficient

// When pattern_i = 0, display eight vertical bars:
// | Visible x range | Clolour |  {red_o, green_o, blue_o} |
// |-----------------|---------|---------------------------|
// | 0-79            | White   | 12'hFFF                   |
// | 80-159          | Yellow  | 12'hFF0                   |
// | 160-239         | Cyan    | 12'h0FF                   |
// | 240-319         | Green   | 12'h0F0                   |
// | 320-399         | Magenta | 12'hF0F                   |
// | 400-479         | Red     | 12'hF00                   |
// | 480-559         | Blue    | 12'h00F                   |
// | 560-639         | Black   | 12'h000                   |

// Each bar is 80 pixels wide and extends across all 480 visible rows

// when pattern_i = 1, display:
//  - A blue background: 12'h00F
//  - A white rectangle: 12'hFFF
//  - Rectangle condition: 240 <= x < 480 and 180 <= y < 300

// The rectangle is exatly 160 pixels wide and 120 pixels tall,
//      centered on the screen

// Boundary examples:
// | Coordinate | Expected colour                 |
// |------------|---------------------------------|
// | (239, 180) | Blue                            |
// | (240, 180) | White                           |
// | (399, 299) | White                           |
// | (400, 299) | Blue                            |
// | (240, 300) | Blue                            |
// | (640, 200) | Black, outside the visible area |

// > Assign every RGB output on every combinational path
//      so that you do not infer latches

`timescale 1ns/1ps

module vga_pattern (
    input   logic   [9:0]   x_i,        // Horizontal coordinate
    input   logic   [9:0]   y_i,        // Vertical coordinate
    input   logic           active_i,   // Visible are qualification
    input   logic           pattern_i,  // Selects the requested pattern
    
    output  logic   [3:0]   red_o,      // Red intensity
    output  logic   [3:0]   green_o,    // Green intensity
    output  logic   [3:0]   blue_o      // Blue intensity
);

endmodule
