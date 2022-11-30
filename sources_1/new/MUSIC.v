module MUSIC(
    input clk,
    input start,
    input rstn,            
    output reg B
);
    reg [25:1]t;
    reg clk_out;
    always@(posedge clk,negedge rstn)
        if(~rstn) begin clk_out<=0;t<=25000000; end
        else if(t==0) begin clk_out<=~clk_out;t<=25000000; end
        else begin t<=t-1; end


    reg [6:1]state;
    always@(posedge clk_out,negedge rstn)         
        if(~rstn) state<=0;
        else if(start) 
            state<=state+1;
 
    reg [5:1]m;
    always@(*)
    if(start)
        case(state) 
        0: m=7;                    
        1: m=7; 
        2: m=7;
        3: m=8;     
        4: m=9;   
        5: m=9;    
        6: m=10;
        7: m=9;

        8: m=8;  
        9: m=8;
        10: m=6;
        11: m=6;     
        12: m=10;
        13: m=10;
        14: m=9;     
        15: m=8;

        16: m=7;
        17: m=7;
        18: m=7;     
        19: m=8;
        20: m=9;
        21: m=9;    
        22: m=10;  
        23: m=9;  

        24: m=8;
        25: m=8;
        26: m=6;     
        27: m=6;
        28: m=6;
        29: m=6;    
        30: m=0;  
        31: m=0;  

        32: m=11;
        33: m=11;
        34: m=11;
        35: m=9;        
        36: m=13;     
        37: m=13;    
        38: m=12;
        39: m=11;

        40: m=10;
        41: m=10; 
        42: m=10;    
        43: m=11;
        44: m=10; 
        45: m=10;
        46: m=9;
        47: m=8;

        48: m=7; 
        49: m=7; 
        50: m=7;      
        51: m=8; 
        52: m=9; 
        53: m=9;
        54: m=10;
        55: m=9;
        
        56: m=8;
        57: m=8;
        58: m=6;
        59: m=6; 
        60: m=6; 
        61: m=6;      
        62: m=0; 
        63: m=0;

        default: m=0;
        endcase
    else m=0;

    reg [27:1]q;
    always@(posedge clk)
    begin
        case(m)
        0 :q=0;
        1 :q=100000000/261 ; //261.6HZ 低do//10000000
        2 :q=100000000/293 ; //293.7HZ 低ri           
        3 :q=100000000/329 ; //329.6HZ 低mi 
        4 :q=100000000/349 ; //349.2HZ 低fa               
        5 :q=100000000/392 ; //392HZ 低so                  
        6 :q=100000000/440 ; //440HZ 低la              
        7 :q=100000000/499 ; //493.9HZ 低xi  
        8 :q=100000000/523 ; //523.3HZ中do
        9 :q=100000000/587 ; //587.3HZ 中ri          
        10:q=100000000/659 ; //659.3HZ 中mi        
        11:q=100000000/698 ; //698.5HZ 中fa
        12:q=100000000/784 ; //784HZ 中so      
        13:q=100000000/880 ; //880HZ 中la            
        14:q=100000000/998 ; //987.8HZ 中xi
        15:q=100000000/1046; //1045.4HZ 高do      
        16:q=100000000/1174; //1174.7HZ 高ri         
        17:q=100000000/1318; //1318.5HZ 高mi
        18:q=100000000/1396; //1396.3HZ 高fa         
        19:q=100000000/1568; //1568HZ 高so           
        20:q=100000000/1760; //1760HZ 高la              
        21:q=100000000/1976; //1975.5HZ 高xi                               
        endcase    
    end
 
    reg [27:1]p;
    always@(posedge clk,negedge rstn)      
    begin
        if(~rstn) begin B<=0;p<=0; end
        else 
        if(q==0) begin B<=0;p<=0; end
        else
        begin 
            if(p==q-1) p<=0;
            else p<=p+1;
            if(p==0) B<=1;
            if(p==q/1024) B<=0;
        end
    end 

endmodule