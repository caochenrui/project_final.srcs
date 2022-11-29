module player(
    input clk, rstn, space, enter, exc,
    input up, down, left, right,
    input drop,
    output reg [4:0]x, y,
    output reg [2:0]type,
    output reg [1:0]dir
);
//    reg []
//    reg next_type;
//    reg next_dir;
//    reg next_x;
//    reg next_y;
//    wire overflow;
//    wire el, er, eu, ed;
//    integer i, j;
//    wire [4:0]x1, x2, x3, x4, y1, y2, y3, y4;//为四个块在图中坐�?
//    always @(posedge clk) begin
//        if(!drop)begin
//            if()begin
//                if(溢出)begin
                    
                
//                end
//                else begin

//                end
//            end
//            else begin
//                y=y+1;
//            end//下落�?�?
//        end
//        else begin
//            if(up)begin
//                dir<=(dir==3)?0:(dir+1);
//            end
//            if(down)begin
//                速降
//            end
//            if(left & x > 0)begin
//                x <= x - 1 ;
//            end
//            if(right & x < 9)begin
//                x <= x + 1;
//            end
//        end
//    end




endmodule