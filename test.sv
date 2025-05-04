module	conv3_3_p1_s2#(
	parameter	DW	=	8,
	parameter	IMG_Width	=	5,
	parameter	IMG_Height	=	5
)(
	input		signed[DW-1:0]	data_i,
	input						valid_i,
	input		signed[15:0]	weight_i,		// 权重
	input						weight_valid_i,	// 权重有效

	output						ready_i,

	output		signed[31:0]	data_o,
	output						valid_o,

	input						clk,
	input						rst_n
);


localparam	IDLE	=	0,
			S1		=	1;

reg		[0:0]	state, next_state;
reg		[7:0]	count_c, count_r;

reg		[DW-1:0]	a[8:0];
reg		[DW-1:0]	b[2:0];	// 寄存一下
reg		valid_q;
wire	valid_en;
reg		signed[DW-1:0]	k00, k01, k02, k10, k11, k12, k20, k21, k22;
wire	signed[31:0]	mul00, mul01, mul02, mul10, mul11, mul12, mul20, mul21, mul22;

wire	fifo0_wr_en, fifo0_rd_en;
wire	fifo1_wr_en, fifo1_rd_en;

wire	[DW-1:0]	fifo0_dout, fifo1_dout;

assign	ready_i	=	state == IDLE;

assign	fifo0_wr_en	=	(state == IDLE) && valid_i && ready_i;
assign	fifo0_rd_en	=	(state == S1) || 
						(((count_r >= 1) || (count_r == 0 && count_c == IMG_Width-1)) && state == IDLE && ready_i && valid_i);
assign	fifo1_wr_en	=	(state == IDLE) && valid_i && ready_i && (count_r >= 1);
assign	fifo1_rd_en	=	(state == S1) || 
						(((count_r >= 2) || (count_r == 1 && count_c == IMG_Width-1)) && state == IDLE && ready_i && valid_i);
// 这里写的有些冗余
assign	valid_en	=	(((state == IDLE && count_r[0] == 1 && count_c[0] == 1 ) ||
						(state == IDLE && count_r != 0 && count_r[0] == 0 && count_c == 0)) && ready_i && valid_i)||
						(state == S1 && (count_c[0] == 1));

assign	valid_o	=	valid_q;


assign	mul00	=	k00 * a[0];
assign	mul01	=	k01 * a[1];
assign	mul02	=	k02 * a[2];
assign	mul10	=	k10 * a[3];
assign	mul11	=	k11 * a[4];
assign	mul12	=	k12 * a[5];
assign	mul20	=	k20 * a[6];
assign	mul21	=	k21 * a[7];
assign	mul22	=	k22 * a[8];

assign	data_o	=	mul00 + mul01 + mul02 + mul10 + mul11 + mul12 + mul20 + mul21 + mul22;

initial begin
	k00	=	1;	k01	=	1;	k02	=	1;
	k10	=	1;	k11	=	1;	k12	=	1;
	k20	=	1;	k21	=	1;	k22	=	1;
end

// valid_q
always@(posedge clk, negedge rst_n)begin
	if(rst_n == 0)	valid_q	<=	1'b0;
	// else if(state == IDLE && valid_en && valid_i && ready_i)	valid_q	<=	1'b1;
	else if(valid_en)	valid_q	<=	1'b1;
	else	valid_q	<=	1'b0;
end

// b
always@(posedge clk, negedge rst_n)begin
	if(rst_n == 0)begin
		b[0]	<=	0;	b[1]	<=	0;	b[2]	<=	0;
	end
	else if(state == IDLE && count_r >= 2 && count_c == 0 && valid_i && ready_i)begin
		b[0]	<=	fifo1_dout;	b[1]	<=	fifo0_dout;	b[2]	<=	data_i;
	end
	else if(state == S1 && count_c == 0)begin
		b[0]	<=	fifo1_dout;	b[1]	<=	fifo0_dout;	b[2]	<=	0;
	end
end

// a 是否能更加精简一些
integer	i;

always@(posedge clk, negedge rst_n)begin
	if(rst_n == 0)begin
		for(i = 0; i < 9; i=i+1)begin
			a[i]	<=	0;
		end
	end
	else if(state == IDLE && valid_i && ready_i)begin
		if(count_r == 1)begin
			a[0]	<=	0;		a[1]	<=	0;		a[2]	<=	0;
			a[3]	<=	a[4];	a[4]	<=	a[5];	a[5]	<=	fifo0_dout;
			a[6]	<=	a[7];	a[7]	<=	a[8];	a[8]	<=	data_i;
		end
		else if(count_c == 0 && count_r >= 2)begin
			a[0]	<=	a[1];	a[1]	<=	a[2];	a[2]	<=	0;
			a[3]	<=	a[4];	a[4]	<=	a[5];	a[5]	<=	0;
			a[6]	<=	a[7];	a[7]	<=	a[8];	a[8]	<=	0;
		end
		else if(count_c == 1 && count_r >= 2)begin
			a[0]	<=	0;	a[1]	<=	b[0];	a[2]	<=	fifo1_dout;
			a[3]	<=	0;	a[4]	<=	b[1];	a[5]	<=	fifo0_dout;
			a[6]	<=	0;	a[7]	<=	b[2];	a[8]	<=	data_i;
		end
		else if(count_r >= 2)begin
			a[0]	<=	a[1];	a[1]	<=	a[2];	a[2]	<=	fifo1_dout;
			a[3]	<=	a[4];	a[4]	<=	a[5];	a[5]	<=	fifo0_dout;
			a[6]	<=	a[7];	a[7]	<=	a[8];	a[8]	<=	data_i;
		end
	end
	else if(state == S1)begin
		if(count_c == 0)begin
			a[0]	<=	a[1];	a[1]	<=	a[2];	a[2]	<=	0;
			a[3]	<=	a[4];	a[4]	<=	a[5];	a[5]	<=	0;
			a[6]	<=	a[7];	a[7]	<=	a[8];	a[8]	<=	0;
		end
		else if(count_c == 1)begin
			a[0]	<=	0;	a[1]	<=	b[0];	a[2]	<=	fifo1_dout;
			a[3]	<=	0;	a[4]	<=	b[1];	a[5]	<=	fifo0_dout;
			a[6]	<=	0;	a[7]	<=	b[2];	a[8]	<=	0;
		end
		else if(count_c == IMG_Width)begin
			a[0]	<=	a[1];	a[1]	<=	a[2];	a[2]	<=	0;
			a[3]	<=	a[4];	a[4]	<=	a[5];	a[5]	<=	0;
			a[6]	<=	0;		a[7]	<=	0;		a[8]	<=	0;
		end
		else begin
			a[0]	<=	a[1];	a[1]	<=	a[2];	a[2]	<=	fifo1_dout;
			a[3]	<=	a[4];	a[4]	<=	a[5];	a[5]	<=	fifo0_dout;
			a[6]	<=	0;		a[7]	<=	0;		a[8]	<=	0;
		end
	end
end

// count_c
always@(posedge clk, negedge rst_n)begin
	if(rst_n == 0)	count_c	<=	8'd0;
	else if(state == IDLE && valid_i && ready_i)	count_c	<=	count_c == IMG_Width-1 ? 0 : count_c +1;
	else if(state == S1)	count_c	<=	count_c == IMG_Width ? 0 : count_c + 1;
end

// count_r
always@(posedge clk, negedge rst_n)begin
	if(rst_n == 0)	count_r	<=	0;
	else if(state == IDLE && valid_i && ready_i && count_c == IMG_Width-1)	count_r	<=	count_r == IMG_Height-1 ? 0 : count_r +1;
end


always@(*)begin
	case(state)
		IDLE:begin
			if(count_c == IMG_Width-1 && count_r == IMG_Height-1)	next_state	=	S1;
			else	next_state	=	IDLE;
		end

		S1:begin
			if(count_c == IMG_Width)	next_state	=	IDLE;
			else	next_state	=	S1;
		end

		default:	next_state	=	IDLE;
	endcase
end

always@(posedge clk, negedge rst_n)begin
	if(rst_n == 0)	state	<=	IDLE;
	else	state	<=	next_state;
end


sync_fifo	#(
	.DW(DW),
	.DP(IMG_Width)
)fifo0(
	.din(data_i),
	.wr_en(fifo0_wr_en),
	.rd_en(fifo0_rd_en),
	.full(),
	.empty(),
	.dout(fifo0_dout),
	.clk(clk),
	.rst_n(rst_n)
);

sync_fifo	#(
	.DW(DW),
	.DP(IMG_Width)
)fifo1(
	.din(fifo0_dout),
	.wr_en(fifo1_wr_en),
	.rd_en(fifo1_rd_en),
	.full(),
	.empty(),
	.dout(fifo1_dout),
	.clk(clk),
	.rst_n(rst_n)
);


endmodule

