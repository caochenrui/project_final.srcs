module RAM(
    input clk, rstn,
    input refresh,
    input [7:0]ra,//rd0是显示时要读取的地址，用ra0输出
    input [4:0]x, y,
    //input [11:0]clo,//方块除坐标外还有颜色信息 这个是什么？
    input [2:0]type,
    input [1:0]dir,
    output reg [2:0]rd,//rd0给显示模块
    output reg [8:1]score,
    output reg el, er, eu, ed, edrop, overflow, refresh_done
);

    

    reg [2:0]rdata_ALL [199:0];//200个数据点，每个数据点12位存储RGB 为空时存储fff(黑色000)
    
    always@(*) rd = rdata_ALL[ra];

    reg [4:0]m1[0:27];
    reg [4:0]m2[0:27];
    reg [4:0]m3[0:27];
    reg [4:0]m4[0:27];
    reg [4:0]n1[0:27];
    reg [4:0]n2[0:27];
    reg [4:0]n3[0:27];
    reg [4:0]n4[0:27];//28种形态的下落块的四个格子的相对坐标（mi, ni）
    reg [4:0]x1, x2, x3, x4, y1, y2, y3, y4;//当前四个方块的xy坐标（xi,yi）
    reg [4:0]ux1, ux2, ux3, ux4, uy1, uy2, uy3, uy4;
    


    reg [2:0]CS;
    reg [2:0]NS;
    reg [4:0]ref, next_ref;
    wire eref;
    assign eref = ((|rdata_ALL[ref * 10 + 9])&
                   (|rdata_ALL[ref * 10 + 8])&
                   (|rdata_ALL[ref * 10 + 7])&
                   (|rdata_ALL[ref * 10 + 6])&
                   (|rdata_ALL[ref * 10 + 5])&
                   (|rdata_ALL[ref * 10 + 4])&
                   (|rdata_ALL[ref * 10 + 3])&
                   (|rdata_ALL[ref * 10 + 2])&
                   (|rdata_ALL[ref * 10 + 1])&
                   (|rdata_ALL[ref * 10 + 0]));//当前排是否可消除,若可消除，则为1
    parameter IDLE = 3'b000,
              GETIN = 3'b001,
              REFRESH = 3'b010;
              //S4 = 3'b011;
    

    always @(posedge clk)begin
        CS <= NS;
        ref <= next_ref;
    end
    
    always @(posedge clk)begin
    NS <= CS;
    next_ref <= ref; 
    refresh_done <= 0;
    case(CS)
        IDLE:begin
           if(refresh) NS <= GETIN;
        end
        GETIN:begin
          NS <= REFRESH;
        end
        REFRESH: begin
         if(!ref)begin
             next_ref <= 19;
             NS <= IDLE;
             refresh_done <= 1;
         end
         else begin
            if(!eref)begin//最后一排满了
                next_ref = ref - 1;
            end
         end
        end
    endcase
    end
    
    integer i = 0;
    reg [6:0]cnt_score;
    always @(*)begin
        //cnt_score = cnt_ score;
        case(CS)
        IDLE: ;
        GETIN: begin
           rdata_ALL[y1*10 + x1] = type;
           rdata_ALL[y2*10 + x2] = type;
           rdata_ALL[y3*10 + x3] = type;
           rdata_ALL[y4*10 + x4] = type;
           ref = 19;
        end
        REFRESH: begin
            if(eref)begin//如果当前排满了
                cnt_score = cnt_score + 1;
                for(i = 199 - 10*ref;i >= 10;i = i - 1) rdata_ALL[i] = rdata_ALL[i-10];
                //for(i = 0;i < 10;i = i + 1) rdata_ALL[i] = 12'hfff;//置为0
            end
        end
        endcase
    end
    
    
    always @(*) begin
        score[4:1]=(cnt_score)%10;
        score[8:5]=(cnt_score)/10;
    end



    //五个使能信号的判断
    always @(*)begin
      x1 = x + m1[{type,dir}];
      x2 = x + m2[{type,dir}];
      x3 = x + m3[{type,dir}];
      x4 = x + m4[{type,dir}];
      y1 = y + n1[{type,dir}];
      y2 = y + n2[{type,dir}];
      y3 = y + n3[{type,dir}];
      y4 = y + n4[{type,dir}];//当前下落块的四个方格（xi, yi）坐标
      ux1 = x + m1[{type,dir+1}];
      ux2 = x + m2[{type,dir+1}];
      ux3 = x + m3[{type,dir+1}];
      ux4 = x + m4[{type,dir+1}];
      uy1 = y + n1[{type,dir+1}];
      uy2 = y + n2[{type,dir+1}];
      uy3 = y + n3[{type,dir+1}];
      uy4 = y + n4[{type,dir+1}];//当前下落块的旋转后的四个方格（uxi, uyi）坐标
      el = (x1 > 0 & (~|rdata_ALL[x1 - 1 + y1 * 4]) &
            x2 > 0 & (~|rdata_ALL[x2 - 1 + y2 * 4]) &
            x3 > 0 & (~|rdata_ALL[x3 - 1 + y3 * 4]) &   
            x4 > 0 & (~|rdata_ALL[x4 - 1 + y4 * 4])    
         );//左移使能
      er = (x1 < 9 & (~|rdata_ALL[x1 + 1 + y1 * 4]) &
            x2 < 9 & (~|rdata_ALL[x2 + 1 + y2 * 4]) &
            x3 < 9 & (~|rdata_ALL[x3 + 1 + y3 * 4]) &   
            x4 < 9 & (~|rdata_ALL[x4 + 1 + y4 * 4])    
         );//右移使能
      eu = (ux1 > 0 & ux1 < 9 & uy1 < 19 & uy1 > 0 & (~|rdata_ALL[ux1 + uy1 * 4]) &
            ux2 > 0 & ux2 < 9 & uy2 < 19 & uy2 > 0 & (~|rdata_ALL[ux2 + uy2 * 4]) &
            ux3 > 0 & ux3 < 9 & uy3 < 19 & uy3 > 0 & (~|rdata_ALL[ux3 + uy3 * 4]) &   
            ux4 > 0 & ux4 < 9 & uy4 < 19 & uy4 > 0 & (~|rdata_ALL[ux4 + uy4 * 4])    
         );//旋转使能
      ed = edrop;
      edrop = (y1 < 19 & (~|rdata_ALL[x1 + (y1 + 1) * 4]) &
               y2 < 19 & (~|rdata_ALL[x2 + (y2 + 1) * 4]) &
               y3 < 19 & (~|rdata_ALL[x3 + (y3 + 1) * 4]) &   
               y4 < 19 & (~|rdata_ALL[x4 + (y4 + 1) * 4])    
         );//下落使能
      overflow = (~|rdata_ALL[x1 + y1 * 4]) &
                 (~|rdata_ALL[x2 + y2 * 4]) &
                 (~|rdata_ALL[x3 + y3 * 4]) &   
                 (~|rdata_ALL[x4 + y4 * 4]) ;//下落使能
    //下落块四个方格初始化
      if(!rstn)begin
            m1[0] <= 0;
            m2[0] <= 1;
            m3[0] <= 2;
            m4[0] <= 3;
            n1[0] <= 1;
            n2[0] <= 1;
            n3[0] <= 1;
            n4[0] <= 1;
            m1[1] <= 2;
            m2[1] <= 2;
            m3[1] <= 2;
            m4[1] <= 2;
            n1[1] <= 0;
            n2[1] <= 1;
            n3[1] <= 2;
            n4[1] <= 3;
            m1[2] <= 0;
            m2[2] <= 1;
            m3[2] <= 2;
            m4[2] <= 3;
            n1[2] <= 2;
            n2[2] <= 2;
            n3[2] <= 2;
            n4[2] <= 2;
            m1[3] <= 1;
            m2[3] <= 1;
            m3[3] <= 1;
            m4[3] <= 1;
            n1[3] <= 0;
            n2[3] <= 1;
            n3[3] <= 2;
            n4[3] <= 3;//第一排

            m1[4] <= 0;
            m2[4] <= 0;
            m3[4] <= 1;
            m4[4] <= 2;
            n1[4] <= 0;
            n2[4] <= 1;
            n3[4] <= 1;
            n4[4] <= 1;
            m1[5] <= 1;
            m2[5] <= 2;
            m3[5] <= 1;
            m4[5] <= 1;
            n1[5] <= 0;
            n2[5] <= 0;
            n3[5] <= 1;
            n4[5] <= 2;
            m1[6] <= 0;
            m2[6] <= 1;
            m3[6] <= 2;
            m4[6] <= 2;
            n1[6] <= 1;
            n2[6] <= 1;
            n3[6] <= 1;
            n4[6] <= 2;
            m1[7] <= 1;
            m2[7] <= 1;
            m3[7] <= 0;
            m4[7] <= 1;
            n1[7] <= 0;
            n2[7] <= 1;
            n3[7] <= 2;
            n4[7] <= 2;//第二排

            m1[8] <= 2;
            m2[8] <= 0;
            m3[8] <= 1;
            m4[8] <= 2;
            n1[8] <= 0;
            n2[8] <= 1;
            n3[8] <= 1;
            n4[8] <= 1;
            m1[9] <= 1;
            m2[9] <= 1;
            m3[9] <= 1;
            m4[9] <= 2;
            n1[9] <= 0;
            n2[9] <= 1;
            n3[9] <= 2;
            n4[9] <= 2;
            m1[10] <= 0;
            m2[10] <= 1;
            m3[10] <= 2;
            m4[10] <= 0;
            n1[10] <= 1;
            n2[10] <= 1;
            n3[10] <= 1;
            n4[10] <= 2;
            m1[11] <= 0;
            m2[11] <= 1;
            m3[11] <= 1;
            m4[11] <= 1;
            n1[11] <= 0;
            n2[11] <= 0;
            n3[11] <= 1;
            n4[11] <= 2;//第三排

            m1[12] <= 1;
            m2[12] <= 2;
            m3[12] <= 1;
            m4[12] <= 2;
            n1[12] <= 0;
            n2[12] <= 0;
            n3[12] <= 1;
            n4[12] <= 1;
            m1[13] <= 1;
            m2[13] <= 2;
            m3[13] <= 1;
            m4[13] <= 2;
            n1[13] <= 0;
            n2[13] <= 0;
            n3[13] <= 1;
            n4[13] <= 1;
            m1[14] <= 1;
            m2[14] <= 2;
            m3[14] <= 1;
            m4[14] <= 2;
            n1[14] <= 0;
            n2[14] <= 0;
            n3[14] <= 1;
            n4[14] <= 1;
            m1[15] <= 1;
            m2[15] <= 2;
            m3[15] <= 1;
            m4[15] <= 2;
            n1[15] <= 0;
            n2[15] <= 0;
            n3[15] <= 1;
            n4[15] <= 1;//第四排

            m1[16] <= 1;
            m2[16] <= 2;
            m3[16] <= 0;
            m4[16] <= 1;
            n1[16] <= 0;
            n2[16] <= 0;
            n3[16] <= 1;
            n4[16] <= 1;
            m1[17] <= 1;
            m2[17] <= 1;
            m3[17] <= 2;
            m4[17] <= 2;
            n1[17] <= 0;
            n2[17] <= 1;
            n3[17] <= 1;
            n4[17] <= 2;
            m1[18] <= 1;
            m2[18] <= 2;
            m3[18] <= 0;
            m4[18] <= 1;
            n1[18] <= 1;
            n2[18] <= 1;
            n3[18] <= 2;
            n4[18] <= 2;
            m1[19] <= 0;
            m2[19] <= 0;
            m3[19] <= 1;
            m4[19] <= 1;
            n1[19] <= 0;
            n2[19] <= 1;
            n3[19] <= 1;
            n4[19] <= 2;//第五排

            m1[20] <= 1;
            m2[20] <= 0;
            m3[20] <= 1;
            m4[20] <= 2;
            n1[20] <= 0;
            n2[20] <= 1;
            n3[20] <= 1;
            n4[20] <= 1;
            m1[21] <= 1;
            m2[21] <= 1;
            m3[21] <= 2;
            m4[21] <= 1;
            n1[21] <= 0;
            n2[21] <= 1;
            n3[21] <= 1;
            n4[21] <= 2;
            m1[22] <= 0;
            m2[22] <= 1;
            m3[22] <= 2;
            m4[22] <= 1;
            n1[22] <= 1;
            n2[22] <= 1;
            n3[22] <= 1;
            n4[22] <= 2;
            m1[23] <= 1;
            m2[23] <= 0;
            m3[23] <= 1;
            m4[23] <= 1;
            n1[23] <= 0;
            n2[23] <= 1;
            n3[23] <= 1;
            n4[23] <= 2;//第六排

            m1[24] <= 0;
            m2[24] <= 1;
            m3[24] <= 1;
            m4[24] <= 2;
            n1[24] <= 0;
            n2[24] <= 0;
            n3[24] <= 1;
            n4[24] <= 1;
            m1[25] <= 2;
            m2[25] <= 1;
            m3[25] <= 2;
            m4[25] <= 1;
            n1[25] <= 0;
            n2[25] <= 1;
            n3[25] <= 1;
            n4[25] <= 2;
            m1[26] <= 0;
            m2[26] <= 1;
            m3[26] <= 1;
            m4[26] <= 2;
            n1[26] <= 1;
            n2[26] <= 1;
            n3[26] <= 2;
            n4[26] <= 2;
            m1[27] <= 1;
            m2[27] <= 0;
            m3[27] <= 1;
            m4[27] <= 0;
            n1[27] <= 0;
            n2[27] <= 1;
            n3[27] <= 1;
            n4[27] <= 2;//第七排
            end
    end
    
    always @(*) begin
        assign rd[0]=rdata_ALL[ra0];
        assign rd[1]=rdata_ALL[ra1];
    end

endmodule


