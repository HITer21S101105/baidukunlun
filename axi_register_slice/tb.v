
`timescale 1ns/100ps

module tb_top();

  reg clk;
  reg resetn;
  
  reg s_axi_valid;
  wire s_axi_ready;
  reg [31:0] s_axi_data;
  
  wire m_axi_valid;
  reg m_axi_ready;
  wire [31:0] m_axi_data;
  
  axi_register_slice #(
    .DATA_WIDTH(32),
    .FORWARD_REGISTERED(1),
    .BACKWARD_REGISTERED(1)
  ) dut (
    .clk(clk),
    .resetn(resetn),
    .s_axi_valid(s_axi_valid),
    .s_axi_ready(s_axi_ready),
    .s_axi_data(s_axi_data),
    .m_axi_valid(m_axi_valid),
    .m_axi_ready(m_axi_ready),
    .m_axi_data(m_axi_data)
  );
  
  initial begin
    clk = 0;
    forever #5 clk = ~clk;
  end
  
  initial begin
    resetn = 0;
    s_axi_valid = 0;
    s_axi_data = 0;
    m_axi_ready = 1;
    @(posedge clk);
    #10 resetn = 1;
    #200;
    $finish;
  end

reg [4:0] cnt;
  
  always @(posedge clk) begin
    if (resetn == 0) begin
      cnt <= 0;
    end
    else begin
      s_axi_valid <= 1;
      s_axi_data <= $random;
      m_axi_ready <= 1;
      cnt <= cnt + 1;
      
 	if(cnt == 10)begin
	   
	   m_axi_ready <= 0;
	   cnt <= 0;
	end
    end
  end
  
  always @(posedge clk) begin
    if (m_axi_valid && m_axi_ready) begin
      $display("m_axi_data = %x", m_axi_data);
    end
  end
  
endmodule