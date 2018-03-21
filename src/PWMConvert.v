module PWMConvert(GCK, Vsync, mode, rst, OUT, data, addr, en);

input            GCK;
input            Vsync;
input            mode;
input            rst;
input     [15:0] data;
output    [15:0] OUT;
output    [ 8:0] addr;
output           en;

reg       [15:0] OUT;
reg              en;

reg       [10:0] rd_addr;
reg       [15:0] rd_reg     [0:15];
reg       [15:0] out_buffer [0:15];
reg       [ 2:0] out_cs;
reg       [ 2:0] out_ns;
reg              push_reg;
reg              rd_addr_add;
reg              push_buffer;
reg              r_push_reg;
reg              r_push_buffer;
reg              r_carry_60;
reg       [ 4:0] cnt;

parameter [ 2:0] OUT_IDLE   = 3'b000,
                 OUT_ACTION = 3'b001,
                 OUT_SEND   = 3'b010,
                 OUT_PUSH   = 3'b011,
                 OUT_STALL  = 3'b100;

integer i;

// ============== Control Unit ==============
// ---------- Finite State Machine ----------
always @(posedge GCK or posedge rst) begin
  if (rst) out_cs <= OUT_IDLE;
  else     out_cs <= out_ns;
end

always @(*) begin
  out_ns = out_cs;
  case (out_cs)
    OUT_IDLE: begin
      out_ns = OUT_ACTION;
    end
    OUT_ACTION: begin
      if (cnt[4]) out_ns = OUT_SEND;
    end
    OUT_SEND: begin
      if (~Vsync) out_ns = OUT_PUSH;
    end
    OUT_PUSH: begin
      out_ns = OUT_STALL;
    end
    OUT_STALL: begin
      out_ns = OUT_IDLE;
    end
  endcase
end

always @(*) begin
  push_reg     = 1'b0;
  rd_addr_add  = 1'b0;
  push_buffer  = 1'b0;
  case (out_cs)
    OUT_ACTION: begin
      push_reg = 1'b1;
      rd_addr_add  = 1'b1;
    end
    OUT_PUSH: begin
      push_buffer  = 1'b1;
    end
  endcase
end

// -------- Control Signal Pipeline ---------
always @(posedge GCK or posedge rst) begin
  if (rst) begin
    r_push_reg     <= 1'b0;
    r_carry_60     <= 1'b0;
    r_push_buffer  <= 1'b0;
  end
  else begin
    r_push_reg     <= push_reg;  
    r_carry_60     <= ~rd_addr[9];
    r_push_buffer  <= push_buffer;
  end
end
// ==========================================

// ================ Datapath ================
assign addr = rd_addr[8:0];

always @(posedge GCK or posedge rst) begin
  if (rst)      cnt <= 5'b0;
  else begin
    if (~Vsync) cnt <= 5'b1;
    else        cnt <= cnt + 5'b1;
  end
end

always @(posedge GCK or posedge rst) begin
  if (rst)    en <= 1'b0;
  else begin
    if (mode) en <= rd_addr[10];
    else      en <= rd_addr[9];
  end
end

always @(posedge GCK or posedge rst) begin
  if (rst)           rd_addr <= 11'h10;
  else begin
    if (rd_addr_add) rd_addr <= rd_addr + 11'b1;
  end
end

always @(posedge GCK or posedge rst) begin
  if (rst) begin
    for (i = 0; i < 16; i = i + 1) begin
      rd_reg[i] <= 15'b0;
    end
  end
  else begin
    if (r_push_reg) begin
      rd_reg[15] <= mode ? {1'b0, data[15:1]} + (data[0] & r_carry_60) : data;
      for (i = 0; i < 15; i = i + 1) begin
        rd_reg[i] <= rd_reg[i + 1];
      end
    end
  end
end

always @(posedge GCK or posedge rst) begin
  if (rst) begin
    OUT <= 16'b0;
    for (i = 0; i < 16; i = i + 1) begin
      out_buffer[i] <= 16'b0;
    end
  end
  else begin
    for (i = 0; i < 16; i = i + 1) begin
      {OUT[i], out_buffer[i]} <= r_push_buffer ? ({1'b1, ~rd_reg[i]}) : {OUT[i], out_buffer[i]} + 17'b1;
    end
  end
end
// ==========================================

endmodule
