//By Alexander Peacock, undergrad at UCF ECE
//email: alexpeacock56ten@gmail.com

`ifndef scaler_SFFT
`define scaler_SFFT

`include "uButterfly.v"

module scaler_SFFT #(
    parameter BITWIDTH = 8,
    parameter BINPUT = 2,
    parameter NUMINPUTS = 8,
    parameter LOG2N = $clog2(NUMINPUTS)
) (
    input wire iClk, iRstN, iEn, loadW, iClr,
    input wire [NUMINPUTS-1:0] iReal, iImg,
    input wire [BITWIDTH-1:0] iwReal, iwImg,
    output wire oBReal, oBImg,
    output wire [NUMINPUTS-1:0] oReal, oImg
);
    wire [(NUMINPUTS*LOG2N)-1:0] midReal, midImg;
    
    //used to calculate full FFT
    genvar b,i,j,stage;
    generate
        //loops through each stage
        for(stage=0; stage<LOG2N; stage=stage+1) begin : g_stages
            //determines inputs per butterfly grouping
            for(b=2**(stage+1); b != -1; b = -1) begin : g_groupinputs
                //steps through each seperated butterfly grouping
                for(i=0; i<NUMINPUTS; i=i+b) begin : g_totalinputs
                        //goes through the indexes of seperated butterflies
                        for(j=0; j<(b/2); j=j+1) begin : g_step
                            if(stage == 0) begin
                                uButterfly #(
                                    .BITWIDTH(BITWIDTH), .BINPUT(BINPUT)
                                ) u_uButterfly_stage1 (
                                    .iClk(iClk), .iRstN(iRstN), .iEn(iEn), .loadW(loadW), .iClr(iClr),    
                                    .iReal0(iReal[i+j]), .iImg0(iImg[i+j]), .iReal1(iReal[i+j+b/2]), .iImg1(iImg[i+j+b/2]),
                                    .iwReal(iwReal), .iwImg(iwImg), .oBReal(oBReal), .oBImg(oBImg),
                                    .oReal0(midReal[(stage*NUMINPUTS)+i+j]), .oImg0(midImg[(stage*NUMINPUTS)+i+j]), .oReal1(midReal[(stage*NUMINPUTS)+i+j+b/2]), .oImg1(midImg[(stage*NUMINPUTS)+i+j+b/2]) 
                                );  
                                
                            end else begin
                                uButterfly #(
                                    .BITWIDTH(BITWIDTH), .BINPUT(BINPUT)
                                ) u_uButterfly_stages (
                                    .iClk(iClk), .iRstN(iRstN), .iEn(iEn), .loadW(loadW), .iClr(iClr),    
                                    .iReal0(midReal[(stage*NUMINPUTS-NUMINPUTS)+i+j]), .iImg0(midImg[(stage*NUMINPUTS-NUMINPUTS)+i+j]), .iReal1(midReal[(stage*NUMINPUTS-NUMINPUTS)+i+j+b/2]), .iImg1(midImg[(stage*NUMINPUTS-NUMINPUTS)+i+j+b/2]),
                                    .iwReal(iwReal), .iwImg(iwImg), .oBReal(oBReal), .oBImg(oBImg),
                                    .oReal0(midReal[(stage*NUMINPUTS)+i+j]), .oImg0(midImg[(stage*NUMINPUTS)+i+j]), .oReal1(midReal[(stage*NUMINPUTS)+i+j+b/2]), .oImg1(midImg[(stage*NUMINPUTS)+i+j+b/2]) 
                                );       
                        end
                    end
                end 
                    
                end       
            end
    endgenerate
    
    assign oReal = midReal[(NUMINPUTS*LOG2N)-1:(NUMINPUTS*LOG2N)-NUMINPUTS];
    assign oImg = midImg[(NUMINPUTS*LOG2N)-1:(NUMINPUTS*LOG2N)-NUMINPUTS];
   
endmodule

`endif
