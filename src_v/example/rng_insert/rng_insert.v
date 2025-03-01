//By Alexander Peacock, undergrad at UCF ECE
//email: alexpeacock56ten@gmail.com

module rng_insert #(
    parameter BITWIDTH = 8,
    parameter BITWIDTHLOG2 = 3, //LOG2 of BITWIDTH
    parameter FBITWIDTH = 4 //fractional BITWIDTH
    
)(
    input iClk, //clock signal
    input iRstN, //reset signal
    input iClr, //clear signal
    input iEn, //enable signal
    input [BITWIDTH-1:0] iWindow,//input window size
    input [FBITWIDTH-1:0] iProb, //input probability, MSB never 1 as cannot be 1.0
    input [BITWIDTHLOG2-1:0] iWINLOG2, //LOG2 of window
    input iA, //input bit
    output out //output bit
    );
    
    wire [BITWIDTH-1:0] half; //stores 0.5
    reg signed [BITWIDTH-1:0] cnt; //counts flips gotten
    reg state; //used to give output
    wire signed [BITWIDTH+FBITWIDTH-2:0] mult; //holds multiplication value
    wire signed [BITWIDTH+2:0] target; //holds target amount of flips needed
    reg [BITWIDTH-1:0] cntBit; //counts number of bits in window
    wire [FBITWIDTH-1:0] prob; //holds probability needed
    
    wire polarity; //determines polarity of probability needed, if you need to add or remove 1s
    assign polarity = (half > iProb);
    
    assign half = {1'b0,1'b1,{(FBITWIDTH-2){1'b0}}}; //gets 0.5 probability
    assign prob = polarity ? (half - iProb) : (iProb-half); //finds target probability in positive form, so absolute of (iprob - half)
    assign mult = (prob << (iWINLOG2)); //multiplication of window using shifting from the equation (iprob-half)*window
    assign target = mult[BITWIDTH+FBITWIDTH-2:FBITWIDTH-1]; //finds actual target amount by getting MSB to FBITWIDTH-1 of mult as needs adjustment from fractional bits
    
    
    wire [BITWIDTH-1:0] winStart; //used for window length in counting down
    assign winStart = iWindow-1;
    
    wire check; //checks if a new window is about to start or if target itself is not 0.5
    assign check = cntBit == 0 && target != 0;
    
    //Used for bit flipping logic
    always@(posedge iClk or negedge iRstN) begin
    //resets the process
        if(!iRstN) begin 
            state <= 0;  
        end else begin
            //if the program is enabled, otherwise disable
            if(iEn) begin
                //if the counter doesn't meet the target flip amount or window length just ends
                if(cnt != target | (check)) begin 
                    //if the sign is negative flip 1s, otherwise flip 0s;
                    if(polarity) begin
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
        if(!iRstN | iClr) begin
            cnt <= 0;
            cntBit <= 0;
        end else begin
            //if the program is enabled, otherwise disable
            if(iEn) begin
                //resets the window counter if it ends or decrement by 1
                cntBit <= (cntBit == 0) ? winStart : cntBit - 1;
                    //if the counter doesn't meet the target flip amount
                    if(cnt != target) begin
                            //if the sign is negative count down, otherwise count up 
                            cnt <= cnt + !(polarity ^ iA);
                    end else begin
                        //keeps flip count static until the end of the window, unless a new window starts
                        if(check) begin
                            cnt <= !(polarity ^ iA); //allows for flipping first bit in a window
                        end else begin
                            cnt <= cnt;
                        end
                    end
            end else begin
                cnt <= 0;
                cntBit <= 0;
            end   
        end
    end
    
    assign out = state; //outputs the bit 
    
endmodule
