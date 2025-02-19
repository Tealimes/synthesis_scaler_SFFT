//By Alexander Peacock, undergrad at UCF ECE
//email: alexpeacock56ten@gmail.com

module rng_insert #(
    parameter BITWIDTH = 8,
    parameter FBITWIDTH = 4
)(
    input iClk,
    input iRstN,
    input iClr,
    input iEn,
    input [BITWIDTH-1:0] iWindow,
    input [FBITWIDTH-1:0] iProb,
    input [BITWIDTH-1:0] iWINLOG2,
    input iA, 
    output out
    );
    
    wire [BITWIDTH-1:0] half;
    reg signed [BITWIDTH-1:0] cnt;
    reg state;
    reg next_state;
    wire signed [BITWIDTH-1:0] mult;
    wire signed [BITWIDTH-1:0] target;
    reg [BITWIDTH-1:0] cntBit;
    wire [BITWIDTH-1:0] prob;
    
    
    assign half = {1'b0,1'b1,{(FBITWIDTH-2){1'b0}}}; //gets 0.5
    assign prob = iProb-half; //finds probability needed
    assign mult = (prob << (iWINLOG2));  //probability multiplication with window length
    assign target = (prob[FBITWIDTH-1]) ? mult >>> (FBITWIDTH-1) : mult >> (FBITWIDTH-1); //acounts for the decimal points of probability
    
    //Used for bit flipping logic
    always@(posedge iClk or negedge iRstN) begin
    //resets the process
        if(!iRstN) begin 
            state <= 0;
        end else begin
            //if the program is enabled, otherwise disable
            if(iEn) begin
                //if the counter doesn't meet the target flip amount or window length just ends
                if(cnt != target | (cntBit == 0)) begin 
                    //if the sign is negative flip 1s, otherwise flip 0s;
                    if(prob[BITWIDTH-1]) begin
                       //used to insert 0
                       state <= 0;
                    end else begin
                        //used to insert 1
                        state <= 1;
                    end
                end else begin
                    state <= iA;
                end
            end else begin
                state <= 0;
            end   
        end   
    end
    
    //Used for counter logic
    always@(posedge iClk or negedge iRstN) begin
        //resets the process
        if(!iRstN) begin
            cnt <= 0;
            cntBit <= 0;
        end else begin
            //if cleared or window met, count is cleared
            if(iClr) begin
                cnt <= 0;
                cntBit <= iWindow-1;
            end else begin
                //if the program is enabled, otherwise disable
                if(iEn) begin
                    //resets the window counter if it ends or decrement by 1
                    cntBit <= (cntBit == 0) ? iWindow-1 : cntBit - 1;
                        //if the counter doesn't meet the target flip amount
                        if(cnt != target) begin
                                //if the sign is negative count down, otherwise count up
                                if(prob[BITWIDTH-1]) begin
                                    cnt <= cnt - iA; //used to insert 0
                                end else begin
                                    cnt <= cnt + !iA; //used to insert 1
                                end
                        end else begin
                            //keeps flip count static until the end of the window
                            if(prob[BITWIDTH-1]) begin
                                cnt <= (cntBit == 0) ? 0 - iA : cnt; //allows the first bit to flip 1
                            end else begin
                               cnt <=  (cntBit == 0) ? {{(BITWIDTH-1){1'b0}},!iA} : cnt; //allows the first bit to flip 0
                            end
                        end
                end else begin
                    cnt <= 0;
                    cntBit <= 0;
                end   
            end
        end
    end
    
    assign out = state; //outputs the bit 
    
endmodule
