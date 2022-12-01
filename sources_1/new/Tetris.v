module Tetris(
    input clk, rstn,
    input PS2_CLK,PS2_DATA,
    input refresh,
    output hs, vs, pwm, [11:0]rgb,
    output reg start,
    output reg refresh_done,
    output reg eu, ed, el, er, edrop, overflow

);

    wire [10:0] key_event;
    keyboard keyboard(
        .clk_100mhz(clk),
        .rst_n(rstn),
        .ps2_c(PS2_CLK),
        .ps2_d(PS2_DATA),
        .key_event(key_event)
    );  

    reg w1,a1,s1,d1,w2,a2,s2,d2,music,reset,ifstart;
    reg [7:0]temp;
    always @(posedge clk,negedge rstn) begin
        if(~rstn) begin w1<=0;a1<=0;s1<=0;d1<=0;w2<=0;a2<=0;s2<=0;d2<=0;start<=0;music<=0;reset<=1;ifstart<=0; end
        else begin
        temp<=key_event[7:0];
            if (key_event[10]&!key_event[8]&temp!=key_event[7:0]) 
            begin//按键有效+不是松开
                case ({key_event[7:0]}) 
                    8'h1D: begin w1<=1; end//W
                    8'h1C: begin a1<=1; end//A
                    8'h1B: begin s1<=1; end//S
                    8'h23: begin d1<=1; end//D
                    8'h75: if (key_event[9]) begin w2<=1; end//↑上下左坳带剝缀E0
                    8'h6B: if (key_event[9]) begin a2<=1; end//�?
                    8'h72: if (key_event[9]) begin s2<=1; end//�?
                    8'h74: if (key_event[9]) begin d2<=1; end//�?
                    8'h3A: begin music<=~music; end//M
                    8'h4D: begin start<=0; end//P pause
                    8'h29: begin start<=1;ifstart<=1; end//space
                    8'h2D: begin reset<=0;ifstart<=0; end//R
                    8'h5A: begin  end//enter
                endcase
                temp<=key_event[7:0];
            end
            else begin 
                temp<=key_event[7:0];w1<=0;a1<=0;s1<=0;d1<=0;w2<=0;a2<=0;s2<=0;d2<=0;reset<=1;
            end
        end
    end

    reg [4:1]sw;
    always @(posedge clk,negedge rstn) begin
        if(~rstn) sw<=0;
        else if(~ifstart&(w2||w1)) sw<=sw+1;
        else if(~ifstart&(s2||s1)) sw<=sw-1;
    end

    wire [16:1]timer;
    TIMER TIMER(
        .sw(sw),
        .start(ifstart),
        .timer(timer),
        .clk(clk),
        .rstn(reset)
    );

    wire pclk;
    clk_wiz_0 clk_wiz_0(
        .clk_out1(pclk),
        .clk_in1(clk)
    );

    reg [8:1]score1,score2;
    wire [8:1]raddr1,raddr2;
    reg [3:1]rdata1,rdata2;
    // RAM ram1(
    //     .clk(clk),
    //     .score(score1),
    //     .rdata(rdata1),
    //     .raddr(raddr1),
    //     .rstn(reset),
    //     .refresh(refresh1)
    // );

    // RAM ram2(
    //     .clk(clk),
    //     .score(score2),
    //     .rdata(rdata2),
    //     .raddr(raddr2),
    //     .rstn(reset),
    //     .refresh(refresh1)
    // );
    
    reg [5:1]x1,y1,type1;
    reg [3:1]next1;
    wire refresh1;
    // player player1(
    //     .clk        (clk),
    //     .rstn       (reset),
    //     .start      (start),
    //     .up         (w1),
    //     .down       (s1),
    //     .left       (a1),
    //     .right      (d1),
    //     .x          (x1),
    //     .y          (y1),
    //     .refresh    (refresh1),
    //     .refresh_done    (refresh_done1),//底层清楚结束标志，脉冲信号
    //     .type       (type1[5:3]),
    //     .dir        (type1[2:1]),
    //     .next_type  (next1),
    //     .fail       (fail1),
    //     .eu         (eu1),
    //     .ed         (ed1),
    //     .el         (el1),
    //     .er         (er1),
    //     .edrop      (edrop1),
    //     .overflow   (overflow1)
    //     );

    reg [5:1]x2,y2,type2;
    reg [3:1]next2;
    wire refresh2;
    // player player2(
    //     .clk        (clk),
    //     .rstn       (reset),
    //     .start      (start),//游戏运行标志
    //     .up         (w2),
    //     .down       (s2),
    //     .left       (a2),
    //     .right      (d2),
    //     .x          (x2),
    //     .y          (y2),
    //     .refresh    (refresh2),
    //     .refresh_done (refresh_done2),
    //     .type       (type2[5:3]),
    //     .dir        (type2[2:1]),
    //     .next_type  (next2),
    //     .fail       (fail2),
    //     .eu         (eu2),
    //     .ed         (ed2),
    //     .el         (el2),
    //     .er         (er2),
    //     .edrop      (edrop2),
    //     .overflow   (overflow2)
    // );


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

    MUSIC MUSIC(
        .clk(clk),
        .start(music),
        .rstn(reset),            
        .B(pwm)
    );

    always @(*) begin
        next1<=3;
        next2<=7;
        type1<=5'b01000;
        type2<=5'b11000;
        score1<=8'h59;
        score2<=8'h13;
        rdata1<=0;
        if (raddr2>=100)rdata2<=3'b101; else rdata2<=0;
    end

    always @(posedge clk,negedge rstn) begin
        if(~rstn) begin x1<=0;y1<=0;x2<=0;y2<=0; end
        else begin 
            if(w1) y1<=y1-1;
            if(a1) x1<=x1-1;
            if(s1) y1<=y1+1;
            if(d1) x1<=x1+1;
            if(w2) y2<=y2-1;
            if(a2) x2<=x2-1;
            if(s2) y2<=y2+1;
            if(d2) x2<=x2+1;
        end
    end
endmodule
