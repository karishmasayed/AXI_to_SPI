
`timescale 1ns/1ps

module axi_state_machine
   (
    // System Signals
    input wire AXI_ACLK,
    input wire AXI_ARESETN,
	input  CLK_50MHZ,
    input  RESET,	 
    // Master Interface Write Address
    output wire [31:0] AXI_AWADDR,
    output wire [2:0]  AXI_AWPROT,
    output wire        AXI_AWVALID,
    input  wire        AXI_AWREADY,
    // Master Interface Write Data
    output wire [31:0] AXI_WDATA,
    output wire [3:0]  AXI_WSTRB,
    output wire        AXI_WVALID,
    input  wire        AXI_WREADY,
    // Master Interface Write Response
    input  wire [1:0]   AXI_BRESP,
    input  wire         AXI_BVALID,
    output wire         AXI_BREADY,
    // Master Interface Read Address
    output wire [31:0] AXI_ARADDR,
    output wire [2:0]  AXI_ARPROT,
    output wire        AXI_ARVALID,
    input  wire        AXI_ARREADY,
    // Master Interface Read Data
    input  wire [31:0]  AXI_RDATA,
    input  wire [1:0]   AXI_RRESP,
    input  wire         AXI_RVALID,
    output wire         AXI_RREADY,
    
	output MISO,
    input MOSI,
    input SCLK,
    input CS

    );

   // AXI4 signals
   reg       axi_done;
   reg [2:0] state_write;
   
   reg  start_axi_write;
   reg  start_axi_read;
   
   reg   awvalid;
   reg   wvalid;

   reg   arvalid;
   reg   rready;
   reg   bready;
   
   reg [31:0] 	awaddr;
   reg [31:0] 	wdata;
   reg [31:0] 	araddr;
   
   reg [31:0]   read_data;

   wire [31:0]	rdata;

reg MISO_i;

reg [31:0] DATA_REG_i;
reg [31:0] ADDR_REG_i;

reg [31:0] DATA_REG_inter_i;
reg [31:0] ADDR_REG_inter_i;

reg [5:0]  cycle;
reg [5:0]  state;
reg [7:0]  address;
reg [33:0] input_reg;
reg [31:0] output_reg;

reg [33:0] rec_input_reg;
reg [7:0]  can_reg_address;

reg [31:0] reg_0 = 32'd111;
reg [31:0] reg_1 = 32'd154;
reg [31:0] reg_2 = 32'd120;
reg [31:0] reg_3 = 32'd144;
reg [31:0] reg_4 = 32'd145;


reg sclk_low_sync;
reg sclk_low_sync1;
reg sclk_low;

reg address_index;
reg data_index;

wire sclk_pos_edge;
wire sclk_neg_edge;

reg [9:0] h_count;
reg [9:0] l_count;
reg [3:0] delay_counter;

reg       sclk_high;
reg [4:0] channel_count;
reg [7:0] temp;

reg sync0_MOSI;
reg sync1_MOSI;

reg sync0_SCLK;
reg sync1_SCLK;

reg sync0_CS;
reg sync1_CS;

wire posedge_MOSI;
wire posedge_CS;
wire posedge_SCLK;

reg spi_done;

reg [31:0] ADDRESS_TO_BE_READ = 32'd45885;


always @(posedge AXI_ACLK or negedge AXI_ARESETN)
  begin
     if (AXI_ARESETN == 0)
         start_axi_write <= 0;
     else begin
          if (spi_done == 1) 
              start_axi_write <= 1;
          else
              start_axi_write <= start_axi_write; 
          
          if (~(AXI_BRESP == 2'd0) && AXI_BVALID)
              start_axi_write <= 1;
          else
              start_axi_write <= start_axi_write;           
          end             
   end

always @(posedge AXI_ACLK or negedge AXI_ARESETN)
  begin
      if (AXI_ARESETN == 0) begin
          wdata        	<= 32'd0;
          awaddr      	<= 32'd0;
          awvalid     	<= 0;
          wvalid       	<= 0;
          bready      	<= 0;
          axi_done 		<= 0;
          end
      else begin
	  
           if(start_axi_write) begin 
		   case (state_write)
		   
		   3'd0 : begin		   
                     if (~awvalid && ~wvalid  && ~bready) begin
                           wdata 	 	<= DATA_REG; 
                           awaddr    	<= ADDR_REG;
                           awvalid   	<= 1;
                           wvalid    	<= 1; 
                           bready   	<= 1;
						   state_write  <=  3'd1;
						   axi_done     <= 0;
                           end
                     else begin
                           wdata 		<= wdata;
                           awaddr		<= awaddr;
                           awvalid  	<= awvalid;
                           wvalid    	<= wvalid; 
                           bready   	<= bready; 
                           axi_done     <= 0;						   
                           end
				 end

		   3'd1:  begin      
                        if (AXI_AWREADY && awvalid)
                             awvalid <= 0;
                        else
                             awvalid <= awvalid;
                      
                        if (AXI_WREADY && wvalid) 
                             wvalid <= 0;
                        else
                             wvalid <= wvalid; 
                          
                        if (AXI_BVALID) begin
                             bready    	 <= 0; 
                             axi_done    <= 1;
							 state_write <= 3'd2;
                             end
                        else begin  
                             bready     <= bready; 
                             axi_done 	<= axi_done;
                             end
                   end   
			3'd2 : begin
			          state_write <= 3'd0;
                   end	
            endcase       		
            end   
                
	   end
  end         

assign  AXI_ARADDR      = araddr;
assign  AXI_ARVALID      = arvalid;
assign  AXI_RREADY      = rready;

assign  AXI_AWADDR     = awaddr;
assign  AXI_AWVALID    = awvalid;
assign  AXI_AWPROT     = 3'h0;

assign  AXI_WDATA       = wdata;
assign  AXI_WVALID      = wvalid;

assign  AXI_BREADY    = bready;

always @(posedge AXI_ACLK or negedge AXI_ARESETN)
  begin
      if (AXI_ARESETN == 0) begin
          araddr   <= 32'd0;
          arvalid  <= 1;
          rready   <= 1;
          end
      else begin
            if (start_axi_read) begin                   
                  if (~arvalid && ~rready) begin
                       araddr  <= ADDRESS_TO_BE_READ;
                       arvalid <= 1;
                       rready  <= 1;  
                       end
                  else begin
                       araddr  <= araddr;
                       arvalid <= arvalid;
                       rready  <= rready; 
                       end
                                         
                 if (AXI_ARREADY) begin
                      arvalid 	<= 0;
                      read_data <= AXI_RDATA;
                      end
                 else
                      arvalid <= arvalid;                
                end 
             end                        
      end 
     



always @(posedge CLK_50MHZ or negedge RESET)
begin
	if(~RESET) begin
	     sync0_MOSI <= 0;
         sync1_MOSI <= 0;
	end
	else begin
		 sync0_MOSI <= MOSI;
         sync1_MOSI <= sync0_MOSI ;
        end
end

assign posedge_MOSI =  sync0_MOSI & ~sync1_MOSI;
//assign negedge_MOSI = ~sync0_MOSI &  sync1_MOSI;

always @(posedge CLK_50MHZ or negedge RESET)
begin
	if(~RESET) begin
	     sync0_CS <= 0;
         sync1_CS <= 0;
	end
	else begin
		 sync0_CS <= CS;
         sync1_CS <= sync0_CS ;
        end
end

assign posedge_CS = CS & ~sync0_CS;

always @(posedge CLK_50MHZ or negedge RESET)
begin
	if(~RESET) begin
	     sync0_SCLK <= 0;
         sync1_SCLK <= 0;
	end
	else begin
		 sync0_SCLK <= SCLK;
         sync1_SCLK <= sync0_SCLK ;
        end
end

assign posedge_SCLK =  sync0_SCLK & ~sync1_SCLK;
assign negedge_SCLK = ~sync0_SCLK &  sync1_SCLK;
 
always @(negedge CLK_50MHZ or negedge RESET) begin
	if(~RESET) begin
		state 			 <= 6'b0;
		cycle 			 <= 6'd0;
		DATA_REG_i 		 <= 32'd0;
		ADDR_REG_i 		 <= 32'd0;
		MISO_i 			 <= 1'd0;
        delay_counter 	 <= 0;
        rec_input_reg 	 <= 34'd0;
        input_reg 		 <= 34'd0;
        output_reg 		 <= 32'd0;
		ADDR_REG_inter_i <= 32'd0;
		DATA_REG_inter_i <= 32'd0;
		spi_done         <= 0; 
	end 
	else begin 
	    if (spi_done) begin
		    DATA_REG <= rec_input_reg;
			ADDR_REG <= can_reg_address;
			ADDR_REG <= can_reg_address;
		end
		    
		case(state) 
		
			6'd0: begin
				  MISO_i	<= 1'b1;
				  state  	<= 6'd1;
				  input_reg <= 32'd0;;	
			      end	
			      			
		    6'd1: begin	
			       if(CS == 1'd0) begin
			             state <= 6'd2;
			          else   
			             state <= 6'd1;
				   end	
			     end
			     
			6'd2: begin
			      if(posedge_SCLK == 1'd1) begin
					 if(cycle == 6'd8)  begin
						state	  		<= 6'd3;
						cycle 			<= 6'd0;
						can_reg_address <= input_reg;
						end
					  else begin
						 input_reg[10'd7-cycle] <= MOSI;
						 cycle 		<= cycle+1;
						 state 		<= 6'd2;
					     end 
			        end
			      end    
				
			6'd3:begin 
                     spi_done <= 0;			
					 if (can_reg_address [0])
						 state <= 6'd4;
					 else 
						 state <= 6'd5;
				end
			
			6'd4: begin
			      if(posedge_SCLK == 1'd1) begin
					 if(cycle == 6'd32)  begin
						state	  		<= 6'd7;
						cycle 			<= 6'd0;
						rec_input_reg 	<= input_reg;
						end
					  else begin
						 input_reg[10'd31-cycle] <= MOSI;
						 cycle 		<= cycle+1;
						 state 		<= 6'd4;
					     end 
			        end
			      end 
			
			6'd5:begin     
					case(can_reg_address [7:1])
						7'd1 : output_reg [31:0] 	<= reg_0 [31:0];
						7'd2 : output_reg [31:0] 	<= reg_1 [31:0];
						7'd3 : output_reg [31:0] 	<= reg_2 [31:0];
						7'd4 : output_reg [31:0] 	<= reg_3 [31:0];
						7'd5 : output_reg [31:0] 	<= reg_4 [31:0];
					endcase					
					state <= 6'd6;
				end     
						
			6'd6: begin 
			       if(posedge_SCLK == 1'd1) begin
					  if(cycle == 6'd32)  begin
						state 	<= 6'd7;
						cycle 	<= 6'd0;
						end
				       else begin
						MISO_i 	<= output_reg[10'd31-cycle];			
						cycle 	<= cycle+1;
						state 	<= 6'd6;
						end 
			         end		
			      end
			
			6'd7:begin     
						if(delay_counter < 4'd8) begin
							delay_counter 	<= delay_counter+1;
							state			<= 6'd7;
                        end
						else
							delay_counter 	<= 4'b0;    
					    if(delay_counter == 4'd8) begin
							state 		<= 6'd0;
							spi_done    <= 1;
						end
					end  										
            endcase	  
            end
       					
end


     assign MISO     = MISO_i;
     //assign ADDR_REG = ADDR_REG_inter_i;
     //assign DATA_REG = DATA_REG_inter_i;
    // assign temp = input_reg;
         
endmodule
