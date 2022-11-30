`timescale 1ns / 1ps

module Tetris_tb(
    );    
    reg clk, rstn,ps2clk,ps2data;
    wire pwm;
    Tetris Tetris(.clk(clk),.rstn(rstn),.pwm(pwm),.PS2_CLK(ps2clk),.PS2_DATA(ps2data));
    initial begin
        clk=0;rstn=1;ps2clk<=1;ps2data<=1;
        #0.1 rstn=0;#0.1 rstn=1;#1
        #0.1 ps2data<=0;
        #0.1 ps2clk <= ~ps2clk;
//        #0.1 ps2data<=0;ps2clk <= ~ps2clk;
//        #0.1 ps2clk <= ~ps2clk;
        #0.1 ps2data<=0;ps2clk <= ~ps2clk;
        #0.1 ps2clk <= ~ps2clk;
        #0.1 ps2data<=0;ps2clk <= ~ps2clk;
        #0.1 ps2clk <= ~ps2clk;
        #0.1 ps2data<=0;ps2clk <= ~ps2clk;
        #0.1 ps2clk <= ~ps2clk;
        #0.1 ps2data<=1;ps2clk <= ~ps2clk;
        #0.1 ps2clk <= ~ps2clk;
        #0.1 ps2data<=1;ps2clk <= ~ps2clk;
        #0.1 ps2clk <= ~ps2clk;
        #0.1 ps2data<=1;ps2clk <= ~ps2clk;
        #0.1 ps2clk <= ~ps2clk;
        #0.1 ps2data<=0;ps2clk <= ~ps2clk;
        #0.1 ps2clk <= ~ps2clk;
        #0.1 ps2data<=1;ps2clk <= ~ps2clk;
        #0.1 ps2clk <= ~ps2clk;
        

        #0.1 ps2data<=1;ps2clk <= ~ps2clk;
        #0.1 ps2clk <= ~ps2clk;
        #0.1 ps2data<=1;ps2clk <= ~ps2clk;
        #0.1 ps2clk <= ~ps2clk;

        #0.1 ps2data<=0;ps2clk <= ~ps2clk;
        #0.1 ps2clk <= ~ps2clk;

        #1
        $finish;
    end
    always #0.01 clk <= ~clk;
//    always #0.1 ps2clk <= ~ps2clk;

endmodule
