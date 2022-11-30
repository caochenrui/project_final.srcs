`timescale 1ns / 1ps

module Tetris_tb(
    );    
    reg clk, rstn;
    wire pwm;
    Tetris Tetris(.clk(clk),.rstn(rstn),.pwm(pwm));
    initial begin
        clk=0;rstn=1;
        #0.1 rstn=0;#0.1 rstn=1;#1
        #1000
        $finish;
    end
    always #0.01 clk <= ~clk;
endmodule
