module player(
    input clk, rstn, start,
    input up, down, left, right,
    input refresh_done,//底部块消除完成标志
    input eu, ed, el, er, edrop, overflow,
    output reg [4:0]x, y,//当前块坐标
    output reg [2:0]type,
    output reg [1:0]dir,
    output reg fail, refresh,//fail为失败信号，refresh控制RAM开始刷新，1有效，脉冲信号。
    output reg next_type
);
    reg next_dir;
    reg next_x;
    reg next_y;
    reg mode;//速降模式和普通模式

    reg [10:0]drop, fast_drop;
    always @(posedge clk)begin
        fail <= fail;
        refresh <= 0;
        x <= x;
        y <= y;
        type <= type;
        dir <= dir;
        mode <= mode;
        next_type <= $random() % 7+1;//1~7
        next_dir <= 0;
        // next_dir <= dir + 1;//后面得改，先用这个试试 

        if(start)begin
            drop <= (drop == 100000000) ?(drop + 1):0;
            fast_drop <= (drop == 50000000) ?(fast_drop + 1):0;
        end
        if((mode) ? (fast_drop) : (drop))begin//mode为1：快速下落使能
            if(!edrop)begin//如果不能下落
                if(overflow)begin//如果溢出
                    fail <= 1;
                end
                else begin//否则刷新底部块
                    refresh <= 1;
                end
            end
            else begin
                y <= y + 1;//正常下落
            end
        end//块下落
        else begin
            if(refresh_done)begin//底部刷新完成
                x <= 3;
                y <= 0;
                type <= next_type;
                dir <= next_dir;
                mode <= 0;
            end
            if(up & eu)begin
                dir <= dir + 1;
            end
            if(down & ed)begin
                mode <= 1;
            end
            if(left & el)begin
                x <= x - 1 ;
            end
            if(right & er)begin
                x <= x + 1;
            end
        end
        if(!rstn)begin
            refresh <= 0;
            fail <= 0;
        end
    end
endmodule