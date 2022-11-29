module Tetris(
    input clk, rstn,
    input PS2_CLK,PS2_DATA,
    input [3:0]SW,
    output hs, vs, [11:0]rgb
);

    wire [10:0] key_event;
    keyboard keyboard(
        .clk_100mhz(clk),
        .rst_n(rstn),
        .ps2_c(ps2_c),
        .ps2_d(ps2_d),
        .key_event(key_event)
    );  

    reg t,w1,a1,s1,d1,w2,a2,s2,d2,start;
    always @(posedge clk,negedge rstn) begin
        if(~rstn) begin t<=1;w1<=0;a1<=0;s1<=0;d1<=0;w2<=0;a2<=0;s2<=0;d2<=0;start<=0; end
        else if (key_event[10]&!key_event[8]&t) begin//按键有效+丝是松开
            case (key_event[7:0]) 
                8'h1D: begin w1<=1; end//W
                8'h1C: begin a1<=1; end//A
                8'h1B: begin s1<=1; end//S
                8'h23: begin d1<=1; end//D
                8'h75: if (key_event[9]) begin w2<=1; end//↑上下左坳带剝缀E0
                8'h6B: if (key_event[9]) begin a2<=1; end//�?
                8'h72: if (key_event[9]) begin s2<=1; end//�?
                8'h74: if (key_event[9]) begin d2<=1; end//�?
                8'h3A: begin  end//M
                8'h4D: begin start<=0; end//P
                8'h29: begin start<=1; end//space
                8'h76: begin  end//esc
                8'h5A: begin  end//enter
            endcase
            t<=0;
        end
        else begin 
            t<=1;w1<=0;a1<=0;s1<=0;d1<=0;w2<=0;a2<=0;s2<=0;d2<=0;start<=0;
        end
    end

    wire [16:1]timer;
    TIMER TIMER(
        .sw(SW),
        .start(start),
        .timer(timer),
        .clk(clk),
        .rstn(rstn)
    );

    wire pclk;
    clk_wiz_0 clk_wiz_0(
        .clk_out1(pclk),
        .clk_in1(clk)
    );

    wire [8:1]score1,score2,raddr1,raddr2;
    wire [5:1]rdata1,rdata2;
//    RAM ram1(
//        .score(score1),
//        .rdata(rdata1),
//        .raddr(raddr1)
//    );

//    RAM ram2(
//        .score(score2),
//        .rdata(rdata2),
//        .raddr(raddr2)
//    );
    
    wire [5:1]x1,y1,type1;
    wire [3:1]next1;
    wire refresh1;
//    player player1(
//        .clk        (clk),
//        .rstn       (rstn),
//        .space      (start),
//        .up         (w1),
//        .down       (s1),
//        .left       (a1),
//        .right      (d1),
//        .x          (x1),
//        .y          (y1),
//        .refresh    (refresh1),
//        .type       (type1[5:3]),
//        .dir        (type1[2:1]),
//        .next       (next1)
//    );

    wire [5:1]x2,y2,type2;
    wire [3:1]next2;
    wire refresh2;
//    player player2(
//        .clk        (clk),
//        .rstn       (rstn),
//        .space      (start),
//        .up         (w2),
//        .down       (s2),
//        .left       (a2),
//        .right      (d2),
//        .x          (x2),
//        .y          (y2),
//        .refresh    (refresh2),
//        .type       (type2[5:3]),
//        .dir        (type2[2:1]),
//        .next       (next2)
//    );


    wire hen,ven;
    DST DST(
        .pclk(pclk),
        .rstn(rstn),
        .hen(hen),
        .ven(ven),
        .hs(hs),
        .vs(vs)
    );

    DDP DDP(
        .rstn(rstn),
        .pclk(pclk),
        .hen(hen),
        .ven(ven),
        .x1(x1),
        .y1(y1),
        .type1(type1),
        .next1(next1),
        .score1(score1),
        .score2(score2),
        .timer(timer),
        .x2(x2),
        .y2(y2),
        .type2(type2),
        .next2(next2),
        .rdata1(rdata1),
        .rdata2(rdata2),
        .raddr1(raddr1),
        .raddr2(raddr2),
        .rgb(rgb)
    );
endmodule
