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
//  - Rectangle condition: 240 <= x < 400 and 180 <= y < 300

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
    input   logic   [1:0]   pattern_i,  // Selects the requested pattern
    
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
            case (pattern_i)
                2'b00: begin
                    if ((x_i >= 640) || (y_i >= 480))
                        rgb = BLACK;
                    else begin
                        if (x_i < 80)
                            rgb = WHITE;
                        else if ((x_i >= 80) && (x_i < 160))
                            rgb = YELLOW;
                        else if ((x_i >= 160) && (x_i < 240))
                            rgb = CYAN;
                        else if ((x_i >= 240) && (x_i < 320))
                            rgb = GREEN;
                        else if ((x_i >= 320) && (x_i < 400))
                            rgb = MAGENTA;
                        else if ((x_i >= 400) && (x_i < 480))
                            rgb = RED;
                        else if ((x_i >= 480) && (x_i < 560))
                            rgb = BLUE;
                        else if ((x_i >= 560) && (x_i < 640))
                            rgb = BLACK;
                        else
                            rgb = BLACK;
                    end
                end

                2'b01: begin
                    if ((x_i >= 640) || (y_i >= 480))
                        rgb = BLACK;
                    else begin
                        if ((x_i >= 240) && (x_i < 400) && (y_i >= 180) && (y_i < 300))
                            rgb = WHITE;
                        else
                            rgb = BLUE;
                    end
                end

                2'b10: begin
                    if ((x_i >= 640) && (y_i >= 480))
                        rgb = BLACK;
                    else begin
                        if (((x_i + y_i) % 80 == 0) && ((x_i - y_i) % 40 == 0))
                            rgb = WHITE;
                        else
                            rgb = RED;
                    end
                end
                default: rgb = 12'h000;
            endcase
            
        end
    end

    assign red_o   = rgb[11:8];
    assign green_o = rgb[ 7:4];
    assign blue_o  = rgb[ 3:0];

endmodule
