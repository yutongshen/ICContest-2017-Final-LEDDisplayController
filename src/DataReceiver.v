module DataReceiver(DCK, DAI, DEN, rst, addr, data, en1, en2);

input           DCK;
input           DAI;
input           DEN;
input           rst;
output   [ 8:0] addr;
output   [15:0] data;
output          en1;
output          en2;

reg             en1;
reg             en2;

reg      [16:0] r_data;
reg      [ 9:0] wd_addr;
reg             wd_addr_add;
reg      [ 1:0] in_cs;
reg      [ 1:0] in_ns;
reg             en_wd;

parameter [1:0] IN_IDLE   = 2'b00,
                IN_ACTION = 2'b01,
                IN_SAVE   = 2'b10;

integer i;

// ============== Control Unit ==============
// ---------- Finite State Machine ----------
always @(posedge DCK or posedge rst) begin
  if (rst) in_cs <= IN_IDLE;
  else     in_cs <= in_ns;
end

always @(*) begin
  in_ns = in_cs;
  case (in_cs)
    IN_IDLE: begin
      if (DEN)  in_ns = IN_ACTION;
    end
    IN_ACTION: begin
      if (~DEN) in_ns = IN_SAVE;
    end
    IN_SAVE: begin
                in_ns = IN_IDLE;
    end
  endcase
end

always @(*) begin
  wd_addr_add = 0;
  en_wd = 1;
  case (in_cs)
    IN_ACTION: begin
      if (~DEN) en_wd = 0;
    end
    IN_SAVE: begin
      wd_addr_add = 1;
    end
  endcase
end
// ==========================================

// ================ Datapath ================
assign addr = wd_addr[8:0];
assign data = r_data[15:0];

always @(posedge DCK or posedge rst) begin
  if (rst) begin
    wd_addr <= 10'b0;
  end
  else if (wd_addr_add) begin
    wd_addr <= wd_addr + 10'b1;
  end
end

always @(posedge DCK or posedge rst) begin
  if (rst) r_data <= 16'b0;
  else begin
    r_data[16] <= DAI;
    for (i = 0; i < 16; i = i + 1) begin
      r_data[i] <= r_data[i + 1];
    end
  end
end

always @(posedge DCK) begin
  en1 <= en_wd | wd_addr[9];
  en2 <= en_wd | ~wd_addr[9];
end
// ==========================================

endmodule
