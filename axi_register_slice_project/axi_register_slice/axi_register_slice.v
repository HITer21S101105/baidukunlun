`timescale 1ns/100ps

module axi_register_slice #(
    parameter DATA_WIDTH = 32,
    parameter FORWARD_REGISTER = 0,
    parameter BACKWARD_REGISTER = 0)
     ( 
        input clk,
        input resetn,

        input s_axi_valid,
        output s_axi_ready,
        input [DATA_WIDTH-1:0] s_axi_data,

        output m_axi_valid,
        input m_axi_ready,
        output [DATA_WIDTH-1:0] m_axi_data
    );
/*  s_axi_data -> bwd_data -> fwd_data(1) -> m_axi_data
    s_axi_valid -> bwd_valid -> fwd_valid(1) -> m_axi_valid
    s_axi_ready <- bwd_ready(2) <- fwd_ready <- m_axi_ready
*/

wire [DATA_WIDTH-1:0] bwd_data_s;
wire bwd_valid_s;
wire bwd_ready_s;
wire [DATA_WIDTH-1:0] fwd_data_s;
wire fwd_valid_s;
wire fwd_ready_s;


generate  if(FORWARD_REGISTER == 1)begin
    reg fwd_valid = 1'b0;
    reg [DATA_WIDTH-1:0] fwd_data = 'h00;
    assign fwd_valid_s = fwd_valid; 
    assign fwd_ready_s = ~fwd_valid | m_axi_ready;
    assign fwd_data_s = fwd_data;

    always@(posedge clk) begin
        if(~fwd_valid | m_axi_ready)begin
            fwd_data <= bwd_data_s;
        end
    end   

    always@(posedge clk) begin
        if(resetn == 0)begin
            fwd_valid <= 1'b0;
        end
        else begin
            if(bwd_valid_s)begin
                fwd_valid <= 1'b1;
            end
            else if(m_axi_ready) begin
                fwd_valid <= 1'b0;
            end
            end
    end
end

else begin
    assign fwd_data_s = bwd_data_s;
    assign fwd_valid_s = bwd_valid_s;
    assign fwd_ready_s = m_axi_ready;
end
   
endgenerate

generate if(BACKWARD_REGISTER == 1)begin
    reg bwd_ready = 1'b1;
    reg [DATA_WIDTH-1:0] bwd_data = 'h00; 
    assign bwd_ready_s = bwd_ready;
    assign bwd_valid_s = ~bwd_ready | s_axi_valid;
    assign bwd_data_s = bwd_ready ? s_axi_data : bwd_data;

    always@(posedge clk)begin
        if(bwd_ready)begin
            bwd_data <= s_axi_data;
        end
    end 

    always@(posedge clk)begin
        if(resetn == 0)begin
            bwd_ready <= 1'b1;
        end
        else begin
            if(fwd_ready_s)begin
                bwd_ready <= 1'b1;
            end
            else if(s_axi_valid)begin
                bwd_ready <= 1'b0;
            end
        end
    end
end 

else begin
    assign bwd_data_s = s_axi_data;
    assign bwd_valid_s = s_axi_valid;
    assign bwd_ready_s = fwd_ready_s;
end

endgenerate

assign s_axi_ready = bwd_ready_s;
assign m_axi_data = fwd_data_s;
assign m_axi_valid = fwd_valid_s;

endmodule