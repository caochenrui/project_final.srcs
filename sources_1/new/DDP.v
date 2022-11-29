`timescale 1ns / 1ps

module DDP(
    input rstn,
    input pclk,
    input hen,
    input ven,

    input [5:1]x1,y1,
    input [5:1]type1,
    input [3:1]next1,
    input [8:1]score1,
    input [8:1]score2,
    input [16:1]timer,
    input [5:1]x2,y2,
    input [5:1]type2,
    input [3:1]next2,

    input [5:1]rdata1, //P1棋局
    input [5:1]rdata2, //P2棋局
    output reg [8:1]raddr1, //P1棋局
    output reg [8:1]raddr2, //P2棋局
    output reg [12:1]rgb
);

    reg [10:1]m,n;
    reg [7:0]ziku[5375:0];
    reg [7:0]preview[55:0];
    reg [15:0]type[27:0];
    always @ (posedge pclk,negedge rstn)
    begin
        if(!rstn) 
        begin 
            m<=0;n<=0; 
            $readmemh("./ziku copy.COE",ziku);
            $readmemh("./preview copy.COE",preview);
            $readmemh("./28 copy.COE",type);
        end
        else if(hen&&ven) 
        begin
            if (m=='d799&&n=='d599) begin m<=0;n<=0; end
            else if (m=='d799) begin m<=0;n<=n+1; end
            else begin m<=m+1; end
        end
    end
    
    reg [3:1]rgbb;
    always @ (*)
        if(ven&&hen)
            begin
                if((m>=x1*20+160&&m<x1*20+240&&n>=y1*20+160&&n<y1*20+240)&&type[(type1[5:3]-1)*4+type1[2:1]][(n-y1*20-160)/20*4+(m-x1*20-160)/20]) begin //每行16位
                    rgbb=type1[5:3];
                    case (rgbb)
                            3'b001: rgb=12'h0FF;
                            3'b010: rgb=12'h00F;
                            3'b011: rgb=12'hFA0;
                            3'b100: rgb=12'hFF0;
                            3'b101: rgb=12'h0F0;
                            3'b110: rgb=12'hA0F;
                            3'b111: rgb=12'hF00;
                            default: rgb=12'h000;
                    endcase 
                    end
                else 
                if((m>=x2*20+440&&m<x2*20+520&&n>=y2*20+160&&n<y2*20+240)&&type[(type2[5:3]-1)*4+type2[2:1]][(n-y2*20-160)/20*4+(m-x2*20-440)/20]) begin
                    rgbb=type2[5:3];
                    case (rgbb)
                            3'b001: rgb=12'h0FF;
                            3'b010: rgb=12'h00F;
                            3'b011: rgb=12'hFA0;
                            3'b100: rgb=12'hFF0;
                            3'b101: rgb=12'h0F0;
                            3'b110: rgb=12'hA0F;
                            3'b111: rgb=12'hF00;
                            default: rgb=12'h000;
                    endcase 
                    end

                else if(m>=160&&m<360&&n>=160&&n<560) //player1
                    begin raddr1=(n-160)/20*10+(m-160)/20;rgbb=rdata1; 
                    case (rgbb)
                            3'b001: rgb=12'h0FF;
                            3'b010: rgb=12'h00F;
                            3'b011: rgb=12'hFA0;
                            3'b100: rgb=12'hFF0;
                            3'b101: rgb=12'h0F0;
                            3'b110: rgb=12'hA0F;
                            3'b111: rgb=12'hF00;
                            default: rgb=12'h000;
                    endcase
                    end
                else if(m>=440&&m<640&&n>=160&&n<560) //player2
                    begin raddr2=(n-160)/20*10+(m-440)/20;rgbb=rdata2; 
                    case (rgbb)
                            3'b001: rgb=12'h0FF;
                            3'b010: rgb=12'h00F;
                            3'b011: rgb=12'hFA0;
                            3'b100: rgb=12'hFF0;
                            3'b101: rgb=12'h0F0;
                            3'b110: rgb=12'hA0F;
                            3'b111: rgb=12'hF00;
                            default: rgb=12'h000;
                    endcase
                    end

                else if(m>=80&&m<160&&n>=200&&n<280) //preview1
                    begin rgb=preview[(n-200)/10*8+(next1-1)*64][(m-80)/10]?12'hFFF:12'h000; end //每行8位
                else if(m>=640&&m<720&&n>=200&&n<280) //preview2
                    begin rgb=preview[(n-200)/10*8+(next2-1)*64][(m-640)/10]?12'hFFF:12'h000; end

                else if(m>=104&&m<136&&n>=164&&n<196) //preview11
                    begin rgb=ziku[5120+(n-164)*4+(m-104)/8][(m-104)%8]?12'hFFF:12'h000; end //32*32 每行4字节
                else if(m>=664&&m<696&&n>=164&&n<196) //preview22
                    begin rgb=ziku[5120+(n-164)*4+(m-664)/8][(m-664)%8]?12'hFFF:12'h000; end

                else if(m>=88&&m<120&&n>=488&&n<552) //score11 32*64
                    begin rgb=ziku[256+score1[8:5]*256+(n-488)*4+(m-88)/8][(m-88)%8]?12'hFFF:12'h000; end
                else if(m>=120&&m<152&&n>=488&&n<552) //score12 32*64
                    begin rgb=ziku[256+score1[4:1]*256+(n-488)*4+(m-120)/8][(m-120)%8]?12'hFFF:12'h000; end
                else if(m>=648&&m<680&&n>=488&&n<552) //score21 32*64
                    begin rgb=ziku[256+score2[8:5]*256+(n-488)*4+(m-648)/8][(m-648)%8]?12'hFFF:12'h000; end
                else if(m>=680&&m<712&&n>=488&&n<552) //score22 32*64
                    begin rgb=ziku[256+score2[4:1]*256+(n-488)*4+(m-680)/8][(m-680)%8]?12'hFFF:12'h000; end

                else if(m>=88&&m<152&&n>=456&&n<488) //score10 32*32
                    begin rgb=ziku[(n-456)*4+(m-88)/8][(m-88)%8]?12'hFFF:12'h000; end
                else if(m>=648&&m<712&&n>=456&&n<488) //score20 32*32
                    begin rgb=ziku[(n-456)*4+(m-648)/8][(m-648)%8]?12'hFFF:12'h000; end

                else if(m>=160&&m<448&&n>=48&&n<112) //title1 256*64
                    begin rgb=ziku[3072+(n-48)*32+(m-160)/8][(m-160)%8]?12'hFFF:12'h000; end

                else if(m>=480&&m<512&&n>=48&&n<112) //title20 32*64
                    begin rgb=ziku[256+timer[16:13]*256+(n-48)*4+(m-480)/8][(m-480)%8]?12'hFFF:12'h000; end
                else if(m>=512&&m<544&&n>=48&&n<112) //title21 32*64
                    begin rgb=ziku[256+timer[12:9]*256+(n-48)*4+(m-512)/8][(m-512)%8]?12'hFFF:12'h000; end
                else if(m>=544&&m<576&&n>=48&&n<112) //title22 32*64
                    begin rgb=ziku[256+timer[12:9]*256+(n-48)*4+(m-544)/8][(m-544)%8]?12'hFFF:12'h000; end
                else if(m>=576&&m<608&&n>=48&&n<112) //title23 32*64
                    begin rgb=ziku[256+timer[8:5]*256+(n-48)*4+(m-576)/8][(m-576)%8]?12'hFFF:12'h000; end
                else if(m>=608&&m<640&&n>=48&&n<112) //title24 32*64
                    begin rgb=ziku[256+timer[4:1]*256+(n-48)*4+(m-608)/8][(m-608)%8]?12'hFFF:12'h000; end

                else rgb=12'h000;//background
            end
        else rgb=12'h000;
endmodule
