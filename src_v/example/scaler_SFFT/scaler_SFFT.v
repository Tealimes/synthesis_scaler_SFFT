`ifndef scaler_SFFT
`define scaler_SFFT

`include "uButterfly.v"

module scaler_SFFT #(
    parameter BITWIDTH = 8,
    parameter BINPUT = 2,
    parameter NUMINPUTS = 2,
    parameter LOG2N = 1
) (
    input wire iClk, iRstN, iEn, loadW, iClr,
    input wire [NUMINPUTS-1:0] iReal, iImg,
    input wire [BITWIDTH-1:0] iwReal, iwImg,
    output wire oBReal, oBImg, //DELETE THESE??????
    output wire [NUMINPUTS-1:0] oReal, oImg
);
    wire [NUMINPUTS*LOG2N-1:0] midReal, midImg;
    
    //1D array k = (i * number of inputs) + j for i is row and j is column
    genvar b,i,j,t;
    integer stage;
    generate
        //determines how many connected butterflies per stage and their input number
        for(b=2; b<=NUMINPUTS; b=b<<1) begin
            for(t=$clog2(b)-1; t != -1; t = -1) begin
                //goes through each seperated butterfly
                for(i=0; i<NUMINPUTS; i=i+b) begin  
                        //goes through the indexes of seperated butterflies
                        for(j=0; j<(b/2); j=j+1) begin
                            if(b == 2) begin
                                uButterfly #(
                                    .BITWIDTH(BITWIDTH), .BINPUT(BINPUT)
                                ) u_uButterfly_stage1 (
                                    .iClk(iClk), .iRstN(iRstN), .iEn(iEn), .loadW(loadW), .iClr(iClr),    
                                    .iReal0(iReal[i+j]), .iImg0(iImg[i+j]), .iReal1(iReal[i+j+b/2]), .iImg1(iImg[i+j+b/2]),
                                    .iwReal(iwReal), .iwImg(iwImg), .oBReal(oBReal), .oBImg(oBImg),
                                    .oReal0(midReal[(t*NUMINPUTS)+i+j]), .oImg0(midImg[(t*NUMINPUTS)+i+j]), .oReal1(midReal[(t*NUMINPUTS)+i+j+b/2]), .oImg1(midImg[(t*NUMINPUTS)+i+j+b/2]) 
                                );  
                                
                            end else begin
                                uButterfly #(
                                    .BITWIDTH(BITWIDTH), .BINPUT(BINPUT)
                                ) u_uButterfly_stages (
                                    .iClk(iClk), .iRstN(iRstN), .iEn(iEn), .loadW(loadW), .iClr(iClr),    
                                    .iReal0(midReal[(t*NUMINPUTS-1)+i+j]), .iImg0(midImg[(t*NUMINPUTS-1)+i+j]), .iReal1(midReal[(t*NUMINPUTS-1)+i+j+b/2]), .iImg1(midImg[(t*NUMINPUTS-1)+i+j+b/2]),
                                    .iwReal(iwReal), .iwImg(iwImg), .oBReal(oBReal), .oBImg(oBImg),
                                    .oReal0(midReal[(t*NUMINPUTS)+i+j]), .oImg0(midImg[(t*NUMINPUTS)+i+j]), .oReal1(midReal[(t*NUMINPUTS)+i+j+b/2]), .oImg1(midImg[(t*NUMINPUTS)+i+j+b/2]) 
                                );       
                        end
                    end
                end 
                    
                end       
            end
            assign oReal = midReal[NUMINPUTS-1:0];
            assign oImg = midImg[NUMINPUTS-1:0];
    endgenerate
       
   
endmodule

`endif
