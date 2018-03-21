`timescale 1ns/10ps
module LEDDC( DCK, DAI, DEN, GCK, Vsync, mode, rst, OUT);
input           DCK;
input           DAI;
input           DEN;
input           GCK;
input           Vsync;
input           mode;
input           rst;
output [15:0]   OUT;



wire [ 8:0] wd_addr;
wire [15:0] r_data;
wire        en_wd1;
wire        en_wd2;

wire [15:0] rd_data1;
wire [15:0] rd_data2;
wire [ 8:0] rd_addr;
wire        en_rd;

wire [15:0] rd_data;

assign rd_data = en_rd ? rd_data1 : rd_data2;

DataReceiver  dr(.DCK  (DCK     ),
                 .DAI  (DAI     ),
                 .DEN  (DEN     ),
                 .rst  (rst     ),
                 .addr (wd_addr ),
                 .data (r_data  ),
                 .en1  (en_wd1  ),
                 .en2  (en_wd2  ));

PWMConvert    pc(.GCK  (GCK     ),
                 .Vsync(Vsync   ),
                 .mode (mode    ),
                 .rst  (rst     ),
                 .OUT  (OUT     ),
                 .data (rd_data ),
                 .addr (rd_addr ),
                 .en   (en_rd   ));

sram_512x16 ram1(.QA   (rd_data1),
                 .AA   (rd_addr ),
                 .CLKA (GCK     ),
                 .CENA (~en_rd  ),
                 .AB   (wd_addr ),
                 .DB   (r_data  ),
                 .CLKB (~DCK    ),
                 .CENB (en_wd1  ));

sram_512x16 ram2(.QA   (rd_data2),
                 .AA   (rd_addr ),
                 .CLKA (GCK     ),
                 .CENA (en_rd   ),
                 .AB   (wd_addr ),
                 .DB   (r_data  ),
                 .CLKB (~DCK    ),
                 .CENB (en_wd2  ));

endmodule
