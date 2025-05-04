//  
//  
//  ------------------------------------------------------------
//    STMicroelectronics N.V. 2011
//   All rights reserved. Reproduction in whole or part is prohibited  without the written consent of the copyright holder.                                                                                                                                                                                                                                                                                                                           
//    STMicroelectronics RESERVES THE RIGHTS TO MAKE CHANGES WITHOUT  NOTICE AT ANY TIME.
//  STMicroelectronics MAKES NO WARRANTY,  EXPRESSED, IMPLIED OR STATUTORY, INCLUDING BUT NOT LIMITED TO ANY IMPLIED  WARRANTY OR MERCHANTABILITY OR FITNESS FOR ANY PARTICULAR PURPOSE,  OR THAT THE USE WILL NOT INFRINGE ANY THIRD PARTY PATENT,  COPYRIGHT OR TRADEMARK.
//  STMicroelectronics SHALL NOT BE LIABLE  FOR ANY LOSS OR DAMAGE ARISING FROM THE USE OF ITS LIBRARIES OR  SOFTWARE.
//    STMicroelectronics
//   850, Rue Jean Monnet
//   BP 16 - 38921 Crolles Cedex - France
//   Central R&D / DAIS.
//                                                                                                                                                                                                                                                                                                                                                                             
//    
//  
//  ------------------------------------------------------------
//  
//  
//    User           : sophie dumont           
//    Project        : CMP_LUND_110420         
//    Division       : Not known               
//    Creation date  : 20 April 2011           
//    Generator mode : MemConfMAT10/distributed
//    
//    WebGen configuration           : C65LP_ST_SPHDL:335,22:MemConfMAT10/distributed:2.4.a-00
//  
//    HDL C65_ST_SP Compiler version : 4.5@20081008.0 (UPT date)                               
//    
//  
//  For more information about the cuts or the generation environment, please
//  refer to files uk.env and ugnGuiSetupDB in directory DESIGN_DATA.
//   
//  
//  





/****************************************************************
--  Description         : verilog_model for ST_SPHDL cmos65
--  ModelVersion        : 4.4
--  Date                : Jun, 2008
--  Changes Made by	: DRM
--
****************************************************************/

/******************** START OF HEADER****************************
   This Header Gives Information about the parameters & options present in the Model

   words = 160
   bits  = 32
   mux   = 8 
   
   
   
   
   
   

**********************END OF HEADER ******************************/



`ifdef slm
        `define functional
`endif
`celldefine
`suppress_faults
`enable_portfaults
`ifdef functional
   `timescale 1ns / 1ns
   `delay_mode_unit
`endif

`ifdef functional



module ST_SPHDL_160x32m8_L (Q, RY,CK, CSN, TBYPASS, WEN, A, D    );   
 
    parameter
        Fault_file_name = "ST_SPHDL_160x32m8_L_faults.txt",
        ConfigFault = 0,
        max_faults = 20,
        MEM_INITIALIZE  = 1'b0,
        BinaryInit = 1'b0,
        InitFileName = "ST_SPHDL_160x32m8_L.cde",
        Corruption_Read_Violation = 1,
        Debug_mode = "all_warning_mode",
        InstancePath = "ST_SPHDL_160x32m8_L";
    
    parameter
        Words = 160,
        Bits = 32,
        Addr = 8,
        mux = 8,
        Rows = Words/mux;




   


    parameter
        WordX = 32'bx,
        AddrX = 8'bx,
        Word0 = 32'b0,
        X = 1'bx;


	output [Bits-1 : 0] Q;
        
        output RY;   
        
        input [Bits-1 : 0] D;
	input [Addr-1 : 0] A;
	        
        input CK, CSN, TBYPASS, WEN;

        
        
        

        



        reg [Bits-1 : 0] Qint;
         
           
	wire [Bits-1 : 0] Dint,Mint;
        
        assign Mint=32'b0;
        
        wire [Addr-1 : 0] Aint;
	wire CKint;
	wire CSNint;
	wire WENint;

        
        	
        wire TBYPASSint;
        

        
        wire RYint;
          
          
           buf (RY, RYint);  
         
        reg RY_outreg, RY_out;
           
        assign RYint = RY_out;

        
        
        
        // REG DECLARATION
        
	//Output Register for tbypass
        reg [Bits-1 : 0] tbydata;
        //delayed Output Register
        reg [Bits-1 : 0] delOutReg_data;
        reg [Bits-1 : 0] OutReg_data;   // Data Output register
	reg [Bits-1 : 0] tempMem;
	reg lastCK;
        reg CSNreg;	

        `ifdef slm
        `else
	reg [Bits-1 : 0] Mem [Words-1 : 0]; // RAM array
        `endif
	
	reg [Bits-1 :0] Mem_temp;
	reg ValidAddress;
	reg ValidDebugCode;
        

        
        reg WENreg;
        
        reg [1:0] debug_level;
        reg [8*10: 0] operating_mode;
        reg [8*44: 0] message_status;

        integer d, a, p, i, k, j, l;
        `ifdef slm
           integer MemAddr;
        `endif


        //************************************************************
        //****** CONFIG FAULT IMPLEMENTATION VARIABLES*************** 
        //************************************************************ 

        integer file_ptr, ret_val;
        integer fault_word;
        integer fault_bit;
        integer fcnt, Fault_in_memory;
        integer n, cnt, t;  
        integer FailureLocn [max_faults -1 :0];

        reg [100 : 0] stuck_at;
        reg [200 : 0] tempStr;
        reg [7:0] fault_char;
        reg [7:0] fault_char1; // 8 Bit File Pointer
        reg [Addr -1 : 0] std_fault_word;
        reg [max_faults -1 :0] fault_repair_flag;
        reg [max_faults -1 :0] repair_flag;
        reg [Bits - 1: 0] stuck_at_0fault [max_faults -1 : 0];
        reg [Bits - 1: 0] stuck_at_1fault [max_faults -1 : 0];
        reg [100 : 0] array_stuck_at[max_faults -1 : 0] ; 
        reg msgcnt;
        

        reg [Bits -1 : 0] stuck0;
        reg [Bits -1 : 0] stuck1;

        `ifdef slm
        reg [Bits -1 : 0] slm_temp_data;
        `endif
        

        integer flag_error;

        
          
          buf bufq [Bits-1:0] (Q,Qint);
        
        
        buf bufdata [Bits-1:0] (Dint,D);
        buf bufaddr [Addr-1:0] (Aint,A);
        
	buf (TBYPASSint, TBYPASS);
	buf (CKint, CK);
	
        //MEM_EN = CSN or  TBYPASS
        
        or (CSNint, CSN, TBYPASS);   
	
        buf (WENint, WEN);
        
        
        
        

        

// BEHAVIOURAL MODULE DESCRIPTION

task WriteMemX;
begin
   `ifdef slm
   $slm_ResetMemory(MemAddr, WordX);
   `else
    for (i = 0; i < Words; i = i + 1)
       Mem[i] = WordX;
   `endif        
end
endtask


task WriteOutX;                
begin
   OutReg_data= WordX;
end
endtask

task WriteCycle;                  
input [Addr-1 : 0] Address;
reg [Bits-1:0] tempReg1,tempReg2;
integer po,i;
begin

   tempReg1 = WordX;
   if (^Address !== X) begin
      if (ValidAddress) begin
      `ifdef slm
         $slm_ReadMemoryS(MemAddr, Address, tempReg1);
      `else
         tempReg1 = Mem[Address];
      `endif
            
         for (po=0;po<Bits;po=po+1) begin
            if (Mint[po] === 1'b0)
               tempReg1[po] = Dint[po];
            else if ((Mint[po] !== 1'b1) && (tempReg1[po] !== Dint[po]))
               tempReg1[po] = 1'bx;
         end                
      `ifdef slm
         $slm_WriteMemory(MemAddr, Address, tempReg1);
      `else
         Mem[Address] = tempReg1;
      `endif
      end//if (ValidAddress)
      else
         if(debug_level < 2) $display("%m - %t (MSG_ID 701) WARNING: Address Out Of Range. ",$realtime); 
   end //if (^Address !== X)
   else
   begin
      if(debug_level < 2) $display("%m - %t (MSG_ID 008) WARNING: Illegal Value on Address Bus. Memory Corrupted ",$realtime);
      WriteMemX;
   end
 end

endtask

task ReadCycle;
input [Addr-1 : 0] Address;
reg [Bits-1:0] MemData;
integer a;
begin
   if (ValidAddress)
   begin        
      `ifdef slm
       $slm_ReadMemory(MemAddr, Address, MemData);
      `else
      MemData = Mem[Address];
      `endif
   end //if (ValidAddress)  
                
   if(ValidAddress === X)
   begin
      if (Corruption_Read_Violation === 1)
      begin   
         if(debug_level < 2) $display("%m - %t (MSG_ID 008) WARNING: Illegal Value on Address Bus. Memory and Output Corrupted ",$realtime);
         WriteMemX;
      end
      else
         if(debug_level < 2) $display("%m - %t (MSG_ID 008) WARNING: Illegal Value on Address Bus. Output Corrupted ",$realtime);
      MemData = WordX;
   end                        
   else if (ValidAddress === 0)
   begin                        
      if(debug_level < 2) $display("%m - %t (MSG_ID 701) WARNING: Address Out Of Range. Output Corrupted ",$realtime); 
      MemData = WordX;
   end
   
   OutReg_data = MemData;
end
endtask

task wen_x_handler;
input [Addr-1 : 0] Address;
input [Bits-1 : 0] Mask;
reg [Bits-1 : 0] prev_data;
begin
   if(^Address !== X) begin
      if (Address < Words) begin
      `ifdef slm
         $slm_ReadMemoryS(MemAddr, Address, tempMem);
      `else
         tempMem = Mem[Address];
      `endif
         prev_data = tempMem;  
         for (j = 0;j< Bits; j=j+1) begin
            //calculating data to write in memory
            if (tempMem[j] !== Dint[j]) begin
               if (Mask[j] !== 1'b1) begin
                  tempMem[j] = 1'bx;
               end
            end
            //calculating data to write on output
            if (prev_data[j] !== OutReg_data[j]) begin
               OutReg_data[j]  = 1'bx;
            end
         end//for (j = 0;j< Bits;
      end
      else begin
         WriteOutX;
      end   
   end  //  if(^Address !== X)
   else begin
      WriteMemX;
      WriteOutX;
   end  //else  
`ifdef slm
   $slm_WriteMemory(MemAddr, Address, tempMem);
`else
   Mem[Address] = tempMem;
`endif
end
endtask
        

task task_insert_faults_in_memory;
begin
   Fault_in_memory = 1;
   for(i = 0;i< fcnt;i = i+ 1)
   begin
      if (fault_repair_flag[i] !== 1)
      begin
         Fault_in_memory = 0;
         if (array_stuck_at[i] === "sa0")
         begin
            `ifdef slm
            //Read first
            $slm_ReadMemoryS(MemAddr, FailureLocn[i], slm_temp_data);
            //operation
            slm_temp_data = slm_temp_data & stuck_at_0fault[i];
            //write back
            $slm_WriteMemoryS(MemAddr, FailureLocn[i], slm_temp_data);
            `else
            Mem[FailureLocn[i]] = Mem[FailureLocn[i]] & stuck_at_0fault[i];
            `endif
         end //if(array_stuck_at)
                                        
         if(array_stuck_at[i] === "sa1")
         begin
            `ifdef slm
            //Read first
            $slm_ReadMemoryS(MemAddr, FailureLocn[i], slm_temp_data);
            //operation
            slm_temp_data = slm_temp_data | stuck_at_1fault[i];
            //write back
            $slm_WriteMemoryS(MemAddr, FailureLocn[i], slm_temp_data);
            `else
            Mem[FailureLocn[i]] = Mem[FailureLocn[i]] | stuck_at_1fault[i]; 
            `endif
         end //if(array_stuck_at)
      end//if (fault_repair_flag
   end// for loop...
end
endtask






initial
begin
   // Define format for timing value
  $timeformat (-9, 2, " ns", 0);
  `ifdef slm
  $slm_RegisterMemory(MemAddr, Words, Bits);
  `endif   
  
  debug_level= 2'b0;
   message_status = "All Messages are Switched ON";
  `ifdef  NO_WARNING_MODE
     debug_level = 2'b10;
     message_status = "All Warning Messages are Switched OFF";
  `endif  
  `ifdef slm
     operating_mode = "SLM";
  `else
     operating_mode = "FUNCTIONAL";
  `endif
if(debug_level !== 2'b10) begin
  $display ("%mINFORMATION ");
  $display ("***************************************");
  $display ("The Model is Operating in %s MODE", operating_mode);
  $display ("%s", message_status);
  if(ConfigFault)
  $display ("Configurable Fault Functionality is ON");   
  else
  $display ("Configurable Fault Functionality is OFF");  
   
  $display ("***************************************");
end
  if (MEM_INITIALIZE === 1'b1)
  begin   
     `ifdef slm
        if (BinaryInit)
           $slm_LoadMemory(MemAddr, InitFileName, "VERILOG_BIN");
        else
           $slm_LoadMemory(MemAddr, InitFileName, "VERILOG_HEX");

     `else
        if (BinaryInit)
           $readmemb(InitFileName, Mem, 0, Words-1);
        else
           $readmemh(InitFileName, Mem, 0, Words-1);
     `endif
  end

  
  RY_out = 1'b1;


        
/*  -----------Implemetation for config fault starts------*/
   msgcnt = X;
   t = 0;
   fault_repair_flag = {max_faults{1'b1}};
   repair_flag = {max_faults{1'b1}};
   if(ConfigFault) 
   begin
        file_ptr = $fopen(Fault_file_name , "r");
        if(file_ptr == 0)
        begin     
          if(debug_level < 3) $display("%m - %t (MSG_ID 201) FAILURE: File cannot be opened ",$realtime);      
        end        
      else                
      begin : read_fault_file
      t = 0;
      for (i = 0; i< max_faults; i= i + 1)
      begin
         
         stuck0 = {Bits{1'b1}};
         stuck1 = {Bits{1'b0}};
         fault_char1 = $fgetc (file_ptr);
         if (fault_char1 == 8'b11111111)
                 disable read_fault_file;
         ret_val = $ungetc (fault_char1, file_ptr);
         ret_val = $fgets(tempStr, file_ptr);
         ret_val = $sscanf(tempStr, "%d %d %s",fault_word, fault_bit, stuck_at) ;
        flag_error = 0; 
         if(ret_val !== 0)
            begin         
               if(ret_val == 2 || ret_val == 3)
               begin
                  if(ret_val == 2)
                      stuck_at = "sa0";

                  if(stuck_at !== "sa0" && stuck_at !== "sa1" && stuck_at !== "none")
                  begin
                      if(debug_level < 2) $display("%m - %t (MSG_ID 203) WARNING: Wrong value for stuck at in fault file ",$realtime);
                      flag_error = 1;
                  end    
                      
                  if(fault_word > Words-1)
                  begin
                      if(debug_level < 2) $display("%m - %t (MSG_ID 206) WARNING: Address out of range in fault file ",$realtime);
                      flag_error = 1;
                  end    

                  if(fault_bit > Bits)
                  begin  
                      if(debug_level < 2) $display("%m - %t (MSG_ID 205) WARNING: Faulty bit out of range in fault file ",$realtime);
                      flag_error = 1;
                  end    

                  if(flag_error == 0)
                  //Correct Inputs
                  begin
                      if(stuck_at === "none")
                      begin
                         if(debug_level < 2) $display("%m - %t (MSG_ID 202) WARNING: No fault injected, empty fault file ",$realtime);
                      end
                      else
                      //Adding the faults
                      begin
                         FailureLocn[t] = fault_word;
                         std_fault_word = fault_word;
                         
                         fault_repair_flag[t] = 1'b0;
                         if (stuck_at === "sa0" )
                         begin
                            stuck0[fault_bit] = 1'b0;         
                            stuck_at_0fault[t] = stuck0;
                         end     
                         if (stuck_at === "sa1" )
                         begin
                            stuck1[fault_bit] = 1'b1;
                            stuck_at_1fault[t] = stuck1; 
                         end

                         array_stuck_at[t] = stuck_at;
                         t = t + 1;
                      end //if(stuck_at === "none")  
                  end //if(flag_error == 0)
               end //if(ret_val == 2 || ret_val == 3 
               else
               //wrong number of arguments
               begin
                  if(debug_level < 2)
                  $display("%m - %t WARNING :  WRONG VALUES ENTERED FOR FAULTY WORD OR FAULTY BIT OR STUCK_AT IN Fault_file_name", $realtime);
                  flag_error = 1;
               end
             end //if(ret_val !== 0)
             else
             begin
                 if(debug_level < 2) $display("%m - %t (MSG_ID 202) WARNING: No fault injected, empty fault file ",$realtime);
             end    
      end //for (i = 0; i< m
      end //begin: read_fault_file  
      $fclose (file_ptr);

      fcnt = t;
      
      //fault injection at time 0.
      task_insert_faults_in_memory;
      
   end // config_fault 
end// initial



//+++++++++++++++++++++++++++++++ CONFIG FAULT IMPLEMETATION ENDS+++++++++++++++++++++++++++++++//
        
always @(CKint)
begin
   if(CKint === 1'b1 && lastCK === 1'b0)
      CSNreg = CSNint;
   
   if(CKint === 1'b1 && lastCK === 1'b0 && CSNint === 1'b0) begin
      WENreg = WENint;
      if (^Aint === X)
         ValidAddress = X;
      else if (Aint < Words)
         ValidAddress = 1;
      else    
         ValidAddress = 0;

      if (ValidAddress)
      `ifdef slm
         $slm_ReadMemoryS(MemAddr, Aint, Mem_temp);
      `else        
         Mem_temp = Mem[Aint];
      `endif       
      else
         Mem_temp = WordX; 
         
      /*---------------------- Normal Read and Write -----------------*/
      
         RY_outreg = ~CKint;
         if (WENint === 1) begin
            ReadCycle(Aint);
         end
         else if (WENint === 0) begin
            WriteCycle(Aint);
         end
         else if (WENint === X) begin
            // Uncertain write cycle
            if (^Aint === X) begin
               WriteOutX;
               WriteMemX;
            end
            else
              wen_x_handler(Aint,Mint);
         end                 
            
      
   end // if(CKint === 1'b1...)
   // Unknown Clock Behaviour or unknown control signal
   else if((CKint === 1'b1 && CSNint === 1'bx) || (CKint === 1'bx && CSNreg !== 1'b1)) begin
      WriteOutX;
      WriteMemX;
       
      RY_out = 1'bX;
      if(CKint === 1'bx && CSNreg !== 1'b1) begin
         if(debug_level < 2) $display("%m - %t (MSG_ID 003) WARNING: Illegal Value on Clock. Memory and Output Corrupted ",$realtime);
      end
      else begin
         if(debug_level < 2) $display("%m - %t (MSG_ID 010) WARNING: Invalid control signal (chip select / memory bypass) Memory and Output Corrupted ",$realtime);
      end
   end
             
   

   if(ConfigFault) begin
      task_insert_faults_in_memory;
   
   end//if(ConfigFault)

   
   lastCK = CKint;
end // always @(CKint)
        
always @(CSNint)
begin

// Unknown Clock & CSN signal
   if (CSNint !== 1 && CKint === 1'bx)
   begin
      if(debug_level < 2) $display("%m - %t (MSG_ID 010) WARNING: Invalid control signal (chip select / memory bypass) Memory and Output Corrupted ",$realtime);
      WriteMemX;
      WriteOutX;
      
      RY_out = 1'bX;
   end

end

  



//TBYPASS functionality
always @(TBYPASSint)
begin
 
   
   delOutReg_data = WordX;
   OutReg_data = WordX;
   if(TBYPASSint !== 1'b0) begin        
      if(TBYPASSint === 1'b1) 
         tbydata = Dint;
      else
         tbydata = WordX;
   end        
   else                         // TBYPASSint = 0
   begin        
      Qint = WordX;
        // tbydata holds no relevance when tbypass is inactive
   end        


end //end of always TBYPASSint

always @(Dint)
begin

   
   if(TBYPASSint === 1'b1)
      tbydata = Dint;

   
end //end of always Dint

//assign output data
always @(OutReg_data)
   #1 delOutReg_data = OutReg_data;

always @(delOutReg_data or tbydata or TBYPASSint ) begin

if(TBYPASSint === 1'bX )
      Qint = WordX;
else if (TBYPASSint === 1'b1 )
      Qint = tbydata;    
else
      
      Qint = delOutReg_data;

end


always @(TBYPASSint)
begin
   if(TBYPASSint !== 1'b0)
    RY_outreg = 1'bx;
end

always @(negedge CKint)
begin

   
   if((TBYPASSint === 1'b0) && (CSNreg === 1'b0) && RY_out !== 1'bx)
    RY_outreg = ~CKint;


end

always @(RY_outreg)
begin
  #1 RY_out = RY_outreg;
end




 
// Power down functionality for verilog_model



endmodule

`else

`timescale 1ns / 1ps
`delay_mode_path


module ST_SPHDL_160x32m8_L_main ( Q_glitch,  Q_data, Q_gCK, RY_rfCK, RY_rrCK, RY_frCK, ICRY, delTBYPASS, TBYPASS_D_Q, TBYPASS_main, CK,  CSN, TBYPASS, WEN,  A, D, M,debug_level ,TimingViol0, TimingViol1, TimingViol2, TimingViol3, TimingViol4, TimingViol5, TimingViol6, TimingViol7, TimingViol8, TimingViol9, TimingViol10, TimingViol_ttms_ttmh, TimingViol12, TimingViol13     );
    
   parameter
        Fault_file_name = "ST_SPHDL_160x32m8_L_faults.txt",
        ConfigFault = 0,
        max_faults = 20,
        MEM_INITIALIZE  = 1'b0,
        BinaryInit = 1'b0,
        InitFileName = "ST_SPHDL_160x32m8_L.cde",
        Debug_mode = "ALL_WARNING_MODE",
        InstancePath = "ST_SPHDL_160x32m8_L";

   parameter
        Words = 160,
        Bits = 32,
        Addr = 8,
        mux = 8,
        Rows = Words/mux;


       

   


    parameter
        WordX = 32'bx,
        AddrX = 8'bx,
        X = 1'bx;

	output [Bits-1 : 0] Q_glitch;
	output [Bits-1 : 0] Q_data;
	output [Bits-1 : 0] Q_gCK;
        
        output ICRY;
        output RY_rfCK;
	output RY_rrCK;
	output RY_frCK;   
	output [Bits-1 : 0] delTBYPASS; 
	output TBYPASS_main; 
        output [Bits-1 : 0] TBYPASS_D_Q;
        
        input [Bits-1 : 0] D, M;
	input [Addr-1 : 0] A;
	input CK, CSN, TBYPASS, WEN;
        input [1 : 0] debug_level;

	input [Bits-1 : 0] TimingViol2, TimingViol3, TimingViol12, TimingViol13;
	input TimingViol0, TimingViol1, TimingViol4, TimingViol5, TimingViol6, TimingViol7, TimingViol8, TimingViol9, TimingViol10, TimingViol_ttms_ttmh;

        
        
        
       
        
        
        

	wire [Bits-1 : 0] Dint,Mint;
	wire [Addr-1 : 0] Aint;
	wire CKint;
	wire CSNint;
	wire WENint;
        
        






	wire  Mreg_0;
	wire  Mreg_1;
	wire  Mreg_2;
	wire  Mreg_3;
	wire  Mreg_4;
	wire  Mreg_5;
	wire  Mreg_6;
	wire  Mreg_7;
	wire  Mreg_8;
	wire  Mreg_9;
	wire  Mreg_10;
	wire  Mreg_11;
	wire  Mreg_12;
	wire  Mreg_13;
	wire  Mreg_14;
	wire  Mreg_15;
	wire  Mreg_16;
	wire  Mreg_17;
	wire  Mreg_18;
	wire  Mreg_19;
	wire  Mreg_20;
	wire  Mreg_21;
	wire  Mreg_22;
	wire  Mreg_23;
	wire  Mreg_24;
	wire  Mreg_25;
	wire  Mreg_26;
	wire  Mreg_27;
	wire  Mreg_28;
	wire  Mreg_29;
	wire  Mreg_30;
	wire  Mreg_31;
	
	reg [Bits-1 : 0] OutReg_glitch; // Glitch Output register
        reg [Bits-1 : 0] OutReg_data;   // Data Output register
	reg [Bits-1 : 0] Dreg,Mreg;
	reg [Bits-1 : 0] Mreg_temp;
	reg [Bits-1 : 0] tempMem;
	reg [Bits-1 : 0] prevMem;
	reg [Addr-1 : 0] Areg;
	reg [Bits-1 : 0] Q_gCKreg; 
	reg [Bits-1 : 0] lastQ_gCK;
	reg [Bits-1 : 0] last_Qdata;
	reg lastCK, CKreg;
	reg CSNreg;
	reg WENreg;
        
        reg [Bits-1 : 0] TimingViol2_last,TimingViol3_last;
        reg [Bits-1 : 0] TimingViol12_last,TimingViol13_last;
	
	reg [Bits-1 : 0] Mem [Words-1 : 0]; // RAM array
	
	reg [Bits-1 :0] Mem_temp;
	reg ValidAddress;
	reg ValidDebugCode;

	reg ICGFlag;
           
        reg Operation_Flag;
	

        
        reg [Bits-1:0] Mem_Red [2*mux-1:0];
        
        integer d, a, p, i, k, j, l;

        //************************************************************
        //****** CONFIG FAULT IMPLEMENTATION VARIABLES*************** 
        //************************************************************ 

        integer file_ptr, ret_val;
        integer fault_word;
        integer fault_bit;
        integer fcnt, Fault_in_memory;
        integer n, cnt, t;  
        integer FailureLocn [max_faults -1 :0];

        reg [100 : 0] stuck_at;
        reg [200 : 0] tempStr;
        reg [7:0] fault_char;
        reg [7:0] fault_char1; // 8 Bit File Pointer
        reg [Addr -1 : 0] std_fault_word;
        reg [max_faults -1 :0] fault_repair_flag;
        reg [max_faults -1 :0] repair_flag;
        reg [Bits - 1: 0] stuck_at_0fault [max_faults -1 : 0];
        reg [Bits - 1: 0] stuck_at_1fault [max_faults -1 : 0];
        reg [100 : 0] array_stuck_at[max_faults -1 : 0] ; 
        reg msgcnt;
        

        reg [Bits -1 : 0] stuck0;
        reg [Bits -1 : 0] stuck1;
        integer flag_error;

	assign Mreg_0 = Mreg[0];
	assign Mreg_1 = Mreg[1];
	assign Mreg_2 = Mreg[2];
	assign Mreg_3 = Mreg[3];
	assign Mreg_4 = Mreg[4];
	assign Mreg_5 = Mreg[5];
	assign Mreg_6 = Mreg[6];
	assign Mreg_7 = Mreg[7];
	assign Mreg_8 = Mreg[8];
	assign Mreg_9 = Mreg[9];
	assign Mreg_10 = Mreg[10];
	assign Mreg_11 = Mreg[11];
	assign Mreg_12 = Mreg[12];
	assign Mreg_13 = Mreg[13];
	assign Mreg_14 = Mreg[14];
	assign Mreg_15 = Mreg[15];
	assign Mreg_16 = Mreg[16];
	assign Mreg_17 = Mreg[17];
	assign Mreg_18 = Mreg[18];
	assign Mreg_19 = Mreg[19];
	assign Mreg_20 = Mreg[20];
	assign Mreg_21 = Mreg[21];
	assign Mreg_22 = Mreg[22];
	assign Mreg_23 = Mreg[23];
	assign Mreg_24 = Mreg[24];
	assign Mreg_25 = Mreg[25];
	assign Mreg_26 = Mreg[26];
	assign Mreg_27 = Mreg[27];
	assign Mreg_28 = Mreg[28];
	assign Mreg_29 = Mreg[29];
	assign Mreg_30 = Mreg[30];
	assign Mreg_31 = Mreg[31];
        buf bufdint [Bits-1:0] (Dint, D);
        buf bufmint [Bits-1:0] (Mint, M);
        buf bufaint [Addr-1:0] (Aint, A);
	
	buf (TBYPASS_main, TBYPASS);
	buf (CKint, CK);
        
        buf (CSNint, CSN);    
	buf (WENint, WEN);

        //TBYPASS functionality
        
        buf bufdeltb [Bits-1:0] (delTBYPASS, TBYPASS);
          
        
        
        buf buftbdq [Bits-1:0] (TBYPASS_D_Q, D );
         
        
        
        







        wire RY_rfCKint, RY_rrCKint, RY_frCKint, ICRYFlagint;
        reg RY_rfCKreg, RY_rrCKreg, RY_frCKreg; 
	reg InitialRYFlag, ICRYFlag;

        
        buf (RY_rfCK, RY_rfCKint);
	buf (RY_rrCK, RY_rrCKint);
	buf (RY_frCK, RY_frCKint);
        buf (ICRY, ICRYFlagint);
        assign ICRYFlagint = ICRYFlag;
        
        

    specify
        specparam

            tdq = 0.01,
            ttmq = 0.01,
            
            taa_ry = 0.01,
            th_ry = 0.009,
            tck_ry = 0.01,
            taa = 1.00,
            th = 0.009;
        /*-------------------- Propagation Delays ------------------*/

   
	if (WENreg && !ICGFlag) (CK *> (Q_data[0] : D[0])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[1] : D[1])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[2] : D[2])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[3] : D[3])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[4] : D[4])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[5] : D[5])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[6] : D[6])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[7] : D[7])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[8] : D[8])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[9] : D[9])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[10] : D[10])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[11] : D[11])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[12] : D[12])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[13] : D[13])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[14] : D[14])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[15] : D[15])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[16] : D[16])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[17] : D[17])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[18] : D[18])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[19] : D[19])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[20] : D[20])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[21] : D[21])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[22] : D[22])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[23] : D[23])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[24] : D[24])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[25] : D[25])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[26] : D[26])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[27] : D[27])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[28] : D[28])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[29] : D[29])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[30] : D[30])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[31] : D[31])) = (taa, taa); 
   

	if (!ICGFlag) (CK *> (Q_glitch[0] : D[0])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[1] : D[1])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[2] : D[2])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[3] : D[3])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[4] : D[4])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[5] : D[5])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[6] : D[6])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[7] : D[7])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[8] : D[8])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[9] : D[9])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[10] : D[10])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[11] : D[11])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[12] : D[12])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[13] : D[13])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[14] : D[14])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[15] : D[15])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[16] : D[16])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[17] : D[17])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[18] : D[18])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[19] : D[19])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[20] : D[20])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[21] : D[21])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[22] : D[22])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[23] : D[23])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[24] : D[24])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[25] : D[25])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[26] : D[26])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[27] : D[27])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[28] : D[28])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[29] : D[29])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[30] : D[30])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[31] : D[31])) = (th, th);

	if (!ICGFlag) (CK *> (Q_gCK[0] : D[0])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[1] : D[1])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[2] : D[2])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[3] : D[3])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[4] : D[4])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[5] : D[5])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[6] : D[6])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[7] : D[7])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[8] : D[8])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[9] : D[9])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[10] : D[10])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[11] : D[11])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[12] : D[12])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[13] : D[13])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[14] : D[14])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[15] : D[15])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[16] : D[16])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[17] : D[17])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[18] : D[18])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[19] : D[19])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[20] : D[20])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[21] : D[21])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[22] : D[22])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[23] : D[23])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[24] : D[24])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[25] : D[25])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[26] : D[26])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[27] : D[27])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[28] : D[28])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[29] : D[29])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[30] : D[30])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[31] : D[31])) = (th, th);

	if (!TBYPASS) (TBYPASS *> delTBYPASS[0]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[1]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[2]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[3]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[4]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[5]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[6]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[7]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[8]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[9]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[10]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[11]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[12]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[13]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[14]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[15]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[16]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[17]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[18]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[19]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[20]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[21]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[22]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[23]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[24]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[25]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[26]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[27]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[28]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[29]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[30]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[31]) = (0);
	if (TBYPASS) (TBYPASS *> delTBYPASS[0]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[1]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[2]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[3]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[4]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[5]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[6]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[7]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[8]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[9]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[10]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[11]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[12]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[13]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[14]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[15]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[16]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[17]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[18]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[19]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[20]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[21]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[22]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[23]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[24]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[25]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[26]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[27]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[28]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[29]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[30]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[31]) = (ttmq);
      (D[0] *> TBYPASS_D_Q[0]) = (tdq, tdq);
      (D[1] *> TBYPASS_D_Q[1]) = (tdq, tdq);
      (D[2] *> TBYPASS_D_Q[2]) = (tdq, tdq);
      (D[3] *> TBYPASS_D_Q[3]) = (tdq, tdq);
      (D[4] *> TBYPASS_D_Q[4]) = (tdq, tdq);
      (D[5] *> TBYPASS_D_Q[5]) = (tdq, tdq);
      (D[6] *> TBYPASS_D_Q[6]) = (tdq, tdq);
      (D[7] *> TBYPASS_D_Q[7]) = (tdq, tdq);
      (D[8] *> TBYPASS_D_Q[8]) = (tdq, tdq);
      (D[9] *> TBYPASS_D_Q[9]) = (tdq, tdq);
      (D[10] *> TBYPASS_D_Q[10]) = (tdq, tdq);
      (D[11] *> TBYPASS_D_Q[11]) = (tdq, tdq);
      (D[12] *> TBYPASS_D_Q[12]) = (tdq, tdq);
      (D[13] *> TBYPASS_D_Q[13]) = (tdq, tdq);
      (D[14] *> TBYPASS_D_Q[14]) = (tdq, tdq);
      (D[15] *> TBYPASS_D_Q[15]) = (tdq, tdq);
      (D[16] *> TBYPASS_D_Q[16]) = (tdq, tdq);
      (D[17] *> TBYPASS_D_Q[17]) = (tdq, tdq);
      (D[18] *> TBYPASS_D_Q[18]) = (tdq, tdq);
      (D[19] *> TBYPASS_D_Q[19]) = (tdq, tdq);
      (D[20] *> TBYPASS_D_Q[20]) = (tdq, tdq);
      (D[21] *> TBYPASS_D_Q[21]) = (tdq, tdq);
      (D[22] *> TBYPASS_D_Q[22]) = (tdq, tdq);
      (D[23] *> TBYPASS_D_Q[23]) = (tdq, tdq);
      (D[24] *> TBYPASS_D_Q[24]) = (tdq, tdq);
      (D[25] *> TBYPASS_D_Q[25]) = (tdq, tdq);
      (D[26] *> TBYPASS_D_Q[26]) = (tdq, tdq);
      (D[27] *> TBYPASS_D_Q[27]) = (tdq, tdq);
      (D[28] *> TBYPASS_D_Q[28]) = (tdq, tdq);
      (D[29] *> TBYPASS_D_Q[29]) = (tdq, tdq);
      (D[30] *> TBYPASS_D_Q[30]) = (tdq, tdq);
      (D[31] *> TBYPASS_D_Q[31]) = (tdq, tdq);


        // RY functionality
	if (!ICRYFlag && InitialRYFlag) (CK *> RY_rfCK) = (th_ry, th_ry);

        if (!ICRYFlag && InitialRYFlag) (CK *> RY_rrCK) = (taa_ry, taa_ry); 
	if (!ICRYFlag && InitialRYFlag) (CK *> RY_frCK) = (tck_ry, tck_ry);   

	endspecify


assign #0 Q_data = OutReg_data;
assign Q_glitch = OutReg_glitch;
assign Q_gCK = Q_gCKreg;




    // BEHAVIOURAL MODULE DESCRIPTION

task chstate;
   input [Bits-1 : 0] clkin;
   output [Bits-1 : 0] clkout;
   integer d;
begin
   if ( $realtime != 0 )
      for (d = 0; d < Bits; d = d + 1)
      begin
         if (clkin[d] === 1'b0)
            clkout[d] = 1'b1;
         else if (clkin[d] === 1'b1)
            clkout[d] = 1'bx;
         else
            clkout[d] = 1'b0;
      end
end
endtask


task task_insert_faults_in_memory;
begin
   Fault_in_memory = 1;
   for(i = 0;i< fcnt;i = i+ 1)
   begin
     if (fault_repair_flag[i] !== 1)
     begin
       Fault_in_memory = 0;
       if (array_stuck_at[i] === "sa0")
       begin
          Mem[FailureLocn[i]] = Mem[FailureLocn[i]] & stuck_at_0fault[i];
       end //if(array_stuck_at)
                                              
       if(array_stuck_at[i] === "sa1")
       begin
         Mem[FailureLocn[i]] = Mem[FailureLocn[i]] | stuck_at_1fault[i]; 
       end //if(array_stuck_at)
     end//if (fault_repair_flag
   end// for loop...
end
endtask



task WriteMemX;
begin
    for (i = 0; i < Words; i = i + 1)
       Mem[i] = WordX;
end
endtask

task WriteLocX;
   input [Addr-1 : 0] Address;
begin
   if (^Address !== X)
       Mem[Address] = WordX;
   else
      WriteMemX;
end
endtask

task WriteLocMskX;
  input [Addr-1 : 0] Address;
  input [Bits-1 : 0] Mask;
  input [Bits-1 : 0] prevMem;
  reg [Bits-1 : 0] Outdata;
begin
  if (^Address !== X)
  begin
      tempMem = Mem[Address];
     for (j = 0;j< Bits; j=j+1)
     begin
        if (prevMem[j] !== Dreg[j]) 
        begin
           if (Mask[j] !== 1'b1)
              tempMem[j] = 1'bx;
        end
     end//for (j = 0;j< Bi

     Mem[Address] = tempMem;
  end//if (^Address !== X
  else
     WriteMemX;
end
endtask

task WriteLocMskX_bwise;
   input [Addr-1 : 0] Address;
   input [Bits-1 : 0] Mask;
begin
   if (^Address !== X)
   begin
      tempMem = Mem[Address];
             
      for (j = 0;j< Bits; j=j+1)
         if (Mask[j] === 1'bx)
            tempMem[j] = 1'bx;
                    
      Mem[Address] = tempMem;

   end//if (^Address !== X
   else
      WriteMemX;
end
endtask
    
task WriteOutX;                
begin
   OutReg_data= WordX;
   OutReg_glitch= WordX;
end
endtask

task WriteOutX_bwise;
   input [Bits-1 : 0] flag;
   input [Bits-1 : 0] Delayedflag;
   input [Addr-1 : 0] Address;
   reg [Bits-1 : 0] MemData;
begin
    MemData = Mem[Address];
        
   for ( l = 0; l < Bits; l = l + 1 )
      if (Delayedflag[l] !== flag[l] && MemData[l] === 1'bx)
      begin
         OutReg_data[l] = 1'bx;
	 OutReg_glitch[l] = 1'bx;
      end
end
endtask

task WriteOut;
begin
   for (i = 0;i < Bits; i = i+1)
   begin        
   
      if (last_Qdata[i] !== Mem_temp[i])     
      begin
         OutReg_data[i] = 1'bX;
         OutReg_glitch[i] = 1'bX;
      end
      else
         OutReg_glitch[i] = OutReg_data[i];
   end   
end
endtask  

task WriteCycle;                  
   input [Addr-1 : 0] Address;
   reg [Bits-1:0] tempReg1,tempReg2;
   integer po,i;
begin

   tempReg1 = WordX;
   if (^Address !== X)
   begin
      if (ValidAddress)
      begin
         
                 tempReg1 = Mem[Address];
                 for (po=0;po<Bits;po=po+1)
                 if (Mreg[po] === 1'b0)
                       tempReg1[po] = Dreg[po];
                 else if ((Mreg[po] !== 1'b1) && (tempReg1[po] !== Dreg[po]))
                       tempReg1[po] = 1'bx;
                        
                 Mem[Address] = tempReg1;
                    
      end //if (ValidAddress)
      else
         if(debug_level < 2) $display("%m - %t (MSG_ID 701) WARNING: Write Port:  Address Out Of Range. ",$realtime);
   end//if (^Address !== X)
   else
   begin
      if(debug_level < 2) $display("%m - %t (MSG_ID 008) WARNING: Write Port:  Illegal Value on Address Bus. Memory Corrupted ",$realtime);
      WriteMemX;
   end
 end

endtask

task ReadCycle;
   input [Addr-1 : 0] Address;
   reg [Bits-1:0] MemData;
   integer a;
begin

   if (ValidAddress)
      MemData = Mem[Address];

   if(ValidAddress === X)
   begin
      if(debug_level < 2) $display("%m - %t (MSG_ID 008) WARNING: Read Port:  Illegal Value on Address Bus. Memory and Output Corrupted ",$realtime);
      WriteMemX;
      MemData = WordX;
   end                        
   else if (ValidAddress === 0)
   begin                        
      if(debug_level < 2) $display("%m - %t (MSG_ID 701) WARNING: Read Port:  Address Out Of Range. Output Corrupted ",$realtime);
      MemData = WordX;
   end

   for (a = 0; a < Bits; a = a + 1)
   begin
      if (MemData[a] !== OutReg_data[a])
         OutReg_glitch[a] = WordX[a];
      else
         OutReg_glitch[a] = MemData[a];
   end//for (a = 0; a <

   OutReg_data = MemData;
   Operation_Flag = 1;
   last_Qdata = Q_data;

end
endtask




assign RY_rfCKint = RY_rfCKreg;
assign RY_frCKint = RY_frCKreg;
assign RY_rrCKint = RY_rrCKreg;

// Define format for timing value
initial
begin
  $timeformat (-9, 2, " ns", 0);
  ICGFlag = 0;
  if (MEM_INITIALIZE === 1'b1)
  begin   
     if (BinaryInit)
        $readmemb(InitFileName, Mem, 0, Words-1);
     else
        $readmemh(InitFileName, Mem, 0, Words-1);
  end

  
  ICRYFlag = 1;
  InitialRYFlag = 0;
  ICRYFlag <= 0;
  RY_rfCKreg = 1'b1;
  RY_rrCKreg = 1'b1;
  RY_frCKreg = 1'b1;


/*  -----------Implemetation for config fault starts------*/
   msgcnt = X;
   t = 0;
   fault_repair_flag = {max_faults{1'b1}};
   repair_flag = {max_faults{1'b1}};
   if(ConfigFault) 
   begin
        file_ptr = $fopen(Fault_file_name , "r");
        if(file_ptr == 0)
        begin     
          if(debug_level < 3) $display("%m - %t (MSG_ID 201) FAILURE: File cannot be opened ",$realtime);      
        end        
      else                
      begin : read_fault_file
      t = 0;
      for (i = 0; i< max_faults; i= i + 1)
      begin
         
         stuck0 = {Bits{1'b1}};
         stuck1 = {Bits{1'b0}};
         fault_char1 = $fgetc (file_ptr);
         if (fault_char1 == 8'b11111111)
                 disable read_fault_file;
         ret_val = $ungetc (fault_char1, file_ptr);
         ret_val = $fgets(tempStr, file_ptr);
         ret_val = $sscanf(tempStr, "%d %d %s",fault_word, fault_bit, stuck_at) ;
        flag_error = 0; 
         if(ret_val !== 0)
            begin         
               if(ret_val == 2 || ret_val == 3)
               begin
                  if(ret_val == 2)
                      stuck_at = "sa0";

                  if(stuck_at !== "sa0" && stuck_at !== "sa1" && stuck_at !== "none")
                  begin
                      if(debug_level < 2) $display("%m - %t (MSG_ID 203) WARNING: Wrong value for stuck at in fault file ",$realtime);
                      flag_error = 1;
                  end    
                      
                  if(fault_word > Words-1)
                  begin
                      if(debug_level < 2) $display("%m - %t (MSG_ID 206) WARNING: Address out of range in fault file ",$realtime);
                      flag_error = 1;
                  end    

                  if(fault_bit > Bits)
                  begin  
                      if(debug_level < 2) $display("%m - %t (MSG_ID 205) WARNING: Faulty bit out of range in fault file ",$realtime);
                      flag_error = 1;
                  end    

                  if(flag_error == 0)
                  //Correct Inputs
                  begin
                      if(stuck_at === "none")
                      begin
                         if(debug_level < 2) $display("%m - %t (MSG_ID 202) WARNING: No fault injected, empty fault file ",$realtime);
                      end
                      else
                      //Adding the faults
                      begin
                         FailureLocn[t] = fault_word;
                         std_fault_word = fault_word;
                         
                         fault_repair_flag[t] = 1'b0;
                         if (stuck_at === "sa0" )
                         begin
                            stuck0[fault_bit] = 1'b0;         
                            stuck_at_0fault[t] = stuck0;
                         end     
                         if (stuck_at === "sa1" )
                         begin
                            stuck1[fault_bit] = 1'b1;
                            stuck_at_1fault[t] = stuck1; 
                         end

                         array_stuck_at[t] = stuck_at;
                         t = t + 1;
                      end //if(stuck_at === "none")  
                  end //if(flag_error == 0)
               end //if(ret_val == 2 || ret_val == 3 
               else
               //wrong number of arguments
               begin
                  if(debug_level < 2)
                  $display("%m - %t WARNING :  WRONG VALUES ENTERED FOR FAULTY WORD OR FAULTY BIT OR STUCK_AT IN Fault_file_name", $realtime);
                  flag_error = 1;
               end
             end //if(ret_val !== 0)
             else
             begin
                 if(debug_level < 2) $display("%m - %t (MSG_ID 202) WARNING: No fault injected, empty fault file ",$realtime);
             end    
      end //for (i = 0; i< m
      end //begin: read_fault_file  
      $fclose (file_ptr);
      fcnt = t;

      
      
      //fault injection at time 0.
      task_insert_faults_in_memory;
      

   end // config_fault 
end// initial



//+++++++++++++++++++++++++++++++ CONFIG FAULT IMPLEMETATION ENDS+++++++++++++++++++++++++++++++//

always @(CKint)
begin
   lastCK = CKreg;
   CKreg = CKint;
   if(CKreg === 1'b1 && lastCK === 1'b0)
   begin
     CSNreg = CSNint;
   end

   
   if (CKint !== 0 && CSNint !== 1)
   begin
     InitialRYFlag = 1;
   end
   

   
   if (CKint===1 && lastCK ===0 && CSNint === X)
       ICRYFlag = 1;
   else if (CKint === 1 && lastCK === 0 && CSNint === 0)
       ICRYFlag = 0;
   

   /*---------------------- Latching signals ----------------------*/
   if(CKreg === 1'b1 && lastCK === 1'b0)
   begin
      
      WENreg = WENint;
   end   
   if(CKreg === 1'b1 && lastCK === 1'b0 && CSNint === 1'b0) begin
      ICGFlag = 0;
      Dreg = Dint;
      Mreg = Mint;
      Areg = Aint;
      if (^Areg === X)
         ValidAddress = X;
      else if (Areg < Words)
         ValidAddress = 1;
      else
         ValidAddress = 0;

      if (ValidAddress)
         Mem_temp = Mem[Aint];
      else
         Mem_temp = WordX; 

      
      
      Operation_Flag = 0;
      last_Qdata = Q_data;
      
      /*------ Normal Read and Write --------*/
      if (WENreg === 1)
      begin
         ReadCycle(Areg);
         chstate(Q_gCKreg, Q_gCKreg);
      end//if (WENreg === 1 && C
      else if (WENreg === 0 )
      begin
         WriteCycle(Areg);
      end
      /*---------- Corruption due to faulty values on signals --------*/
      else if (WENreg === X)
      begin
         chstate(Q_gCKreg, Q_gCKreg);
         // Uncertain write cycle
         WriteLocMskX(Areg,Mreg,Mem_temp);
         WriteOut;
         if (^Areg === X || Areg > Words-1)
         begin
              WriteOutX;	// if add is unknown put X at output
         end    
      end//else if (WENreg =
      
         

      
   end//if(CKreg === 1'b1 && lastCK =   
   // Unknown Clock Behaviour
   else if (((CSNint === 1'bx) && (CKint === 1)) || (CKint=== 1'bx && CSNreg !==1)) begin
      WriteMemX;
      WriteOutX;
      ICGFlag = 1'b1;
       
      ICRYFlag = 1'b1;
      if(CKint === 1'bx && CSNreg !== 1'b1) begin
         if(debug_level < 2) $display("%m - %t (MSG_ID 003) WARNING: Illegal Value on Clock. Memory and Output Corrupted ",$realtime);
      end
      else begin
         if(debug_level < 2) $display("%m - %t (MSG_ID 010) WARNING: Invalid control signal (chip select / memory bypass) Memory and Output Corrupted ",$realtime);
      end
   end 
   if(ConfigFault) begin
      task_insert_faults_in_memory;
      
   end//if(ConfigFault)
   
 end // always @(CKint)

always @(CSNint)
begin   
   // Unknown Clock & CSN signal
      if (CSNint !== 1 && CKint === X )
      begin
         chstate(Q_gCKreg, Q_gCKreg);
       	 WriteMemX;
	 WriteOutX;
         
         ICRYFlag = 1;   
      end//if (CSNint !== 1
end      


always @(TBYPASS_main)
begin

   OutReg_data = WordX;
   OutReg_glitch = WordX;
   
   if (TBYPASS_main !== 0)
      ICRYFlag = 1;
   
end


  

        /*---------------RY Functionality-----------------*/
always @(posedge CKreg)
begin


   if ((CSNreg === 0) && (CKreg === 1 && lastCK === 0) && TBYPASS_main === 1'b0)
   begin
           RY_rfCKreg = ~RY_rfCKreg;
        RY_rrCKreg = ~RY_rrCKreg;
   end


end

always @(negedge CKreg)
begin

   
   if (TBYPASS_main === 1'b0 && (CSNreg === 1'b0) && (CKreg === 1'b0 && lastCK === 1'b1))
   begin
        RY_frCKreg = ~RY_frCKreg;
    end


end

always @(TimingViol9 or TimingViol10 or TimingViol4 or TimingViol5 or TimingViol8 )
ICRYFlag = 1;
        /*---------------------------------*/






   




   
/*---------------TBYPASS  Functionality in functional model -----------------*/

always @(TimingViol9 or TimingViol10 or TimingViol4 or TimingViol5 or TimingViol8)
begin
   if (TBYPASS !== 0)
      WriteMemX;
end

always @(TimingViol2 or TimingViol3)
// tds or tdh violation
begin
#0
   for (l = 0; l < Bits; l = l + 1)
   begin   
      if((TimingViol2[l] !== TimingViol2_last[l]))
         Mreg[l] = 1'bx;
      if((TimingViol3[l] !== TimingViol3_last[l]))
         Mreg[l] = 1'bx;   
   end   
   WriteLocMskX_bwise(Areg,Mreg);
   TimingViol2_last = TimingViol2;
   TimingViol3_last = TimingViol3;
end


        
/*---------- Corruption due to Timing Violations ---------------*/

always @(TimingViol9 or TimingViol10)
// tckl -  tcycle
begin
#0
   Dreg = WordX;
   WriteOutX;
   #0.00 WriteMemX;
end

always @(TimingViol4 or TimingViol5)
// tps or tph
begin
#0
   Dreg = WordX;
   if ((WENreg !== 0) || (lastCK === X))
      WriteOutX;
   if (lastCK === X)
      WriteMemX;  
   WriteMemX; 
   if (CSNreg === 1 && WENreg !== 0)
   begin
      chstate(Q_gCKreg, Q_gCKreg);
   end
end

always @(TimingViol8)
// tckh
begin
#0
   Dreg = WordX;
   ICGFlag = 1;
   chstate(Q_gCKreg, Q_gCKreg);
   WriteOutX;
   WriteMemX;
end

always @(TimingViol0 or TimingViol1)
// tas or tah
begin
#0
   Areg = AddrX;
   ValidAddress = X;
   if (WENreg !== 0)
      WriteOutX;
   WriteMemX;
end


always @(TimingViol6 or TimingViol7)
//tws or twh
begin
#0
   if (CSNreg === X)
   begin
      WriteMemX; 
      WriteOutX;
   end
   else
   begin
      WriteLocMskX(Areg,Mreg,Mem_temp); 
      WriteOut;
      if (^Areg === X)
         WriteOutX;	// if add is unknown put X at output
   end
end


always @(TimingViol_ttms_ttmh)
//ttms/ttmh
begin
#0
   Dreg = WordX;
   WriteOutX;
   WriteMemX;  
   
   ICRYFlag = 1; 
end





endmodule

module ST_SPHDL_160x32m8_L_OPschlr (QINT,  RYINT, Q_gCK, Q_glitch,  Q_data, RY_rfCK, RY_rrCK, RY_frCK, ICRY, delTBYPASS, TBYPASS_D_Q, TBYPASS_main  );

    parameter
        Words = 160,
        Bits = 32,
        Addr = 8;
        

    parameter
        WordX = 32'bx,
        AddrX = 8'bx,
        X = 1'bx;

	output [Bits-1 : 0] QINT;
	input [Bits-1 : 0] Q_glitch;
	input [Bits-1 : 0] Q_data;
	input [Bits-1 : 0] Q_gCK;
        input [Bits-1 : 0] TBYPASS_D_Q;
        input [Bits-1 : 0] delTBYPASS;
        input TBYPASS_main;



	integer m,a, d, n, o, p;
	wire [Bits-1 : 0] QINTint;
	wire [Bits-1 : 0] QINTERNAL;

        reg [Bits-1 : 0] OutReg;
	reg [Bits-1 : 0] lastQ_gCK, Q_gCKreg;
	reg [Bits-1 : 0] lastQ_data, Q_datareg;
	reg [Bits-1 : 0] QINTERNALreg;
	reg [Bits-1 : 0] lastQINTERNAL;

buf bufqint [Bits-1:0] (QINT, QINTint);


	assign QINTint[0] = (TBYPASS_main===0 && delTBYPASS[0]===0)?OutReg[0] : (TBYPASS_main===1 && delTBYPASS[0]===1)?TBYPASS_D_Q[0] : WordX;
	assign QINTint[1] = (TBYPASS_main===0 && delTBYPASS[1]===0)?OutReg[1] : (TBYPASS_main===1 && delTBYPASS[1]===1)?TBYPASS_D_Q[1] : WordX;
	assign QINTint[2] = (TBYPASS_main===0 && delTBYPASS[2]===0)?OutReg[2] : (TBYPASS_main===1 && delTBYPASS[2]===1)?TBYPASS_D_Q[2] : WordX;
	assign QINTint[3] = (TBYPASS_main===0 && delTBYPASS[3]===0)?OutReg[3] : (TBYPASS_main===1 && delTBYPASS[3]===1)?TBYPASS_D_Q[3] : WordX;
	assign QINTint[4] = (TBYPASS_main===0 && delTBYPASS[4]===0)?OutReg[4] : (TBYPASS_main===1 && delTBYPASS[4]===1)?TBYPASS_D_Q[4] : WordX;
	assign QINTint[5] = (TBYPASS_main===0 && delTBYPASS[5]===0)?OutReg[5] : (TBYPASS_main===1 && delTBYPASS[5]===1)?TBYPASS_D_Q[5] : WordX;
	assign QINTint[6] = (TBYPASS_main===0 && delTBYPASS[6]===0)?OutReg[6] : (TBYPASS_main===1 && delTBYPASS[6]===1)?TBYPASS_D_Q[6] : WordX;
	assign QINTint[7] = (TBYPASS_main===0 && delTBYPASS[7]===0)?OutReg[7] : (TBYPASS_main===1 && delTBYPASS[7]===1)?TBYPASS_D_Q[7] : WordX;
	assign QINTint[8] = (TBYPASS_main===0 && delTBYPASS[8]===0)?OutReg[8] : (TBYPASS_main===1 && delTBYPASS[8]===1)?TBYPASS_D_Q[8] : WordX;
	assign QINTint[9] = (TBYPASS_main===0 && delTBYPASS[9]===0)?OutReg[9] : (TBYPASS_main===1 && delTBYPASS[9]===1)?TBYPASS_D_Q[9] : WordX;
	assign QINTint[10] = (TBYPASS_main===0 && delTBYPASS[10]===0)?OutReg[10] : (TBYPASS_main===1 && delTBYPASS[10]===1)?TBYPASS_D_Q[10] : WordX;
	assign QINTint[11] = (TBYPASS_main===0 && delTBYPASS[11]===0)?OutReg[11] : (TBYPASS_main===1 && delTBYPASS[11]===1)?TBYPASS_D_Q[11] : WordX;
	assign QINTint[12] = (TBYPASS_main===0 && delTBYPASS[12]===0)?OutReg[12] : (TBYPASS_main===1 && delTBYPASS[12]===1)?TBYPASS_D_Q[12] : WordX;
	assign QINTint[13] = (TBYPASS_main===0 && delTBYPASS[13]===0)?OutReg[13] : (TBYPASS_main===1 && delTBYPASS[13]===1)?TBYPASS_D_Q[13] : WordX;
	assign QINTint[14] = (TBYPASS_main===0 && delTBYPASS[14]===0)?OutReg[14] : (TBYPASS_main===1 && delTBYPASS[14]===1)?TBYPASS_D_Q[14] : WordX;
	assign QINTint[15] = (TBYPASS_main===0 && delTBYPASS[15]===0)?OutReg[15] : (TBYPASS_main===1 && delTBYPASS[15]===1)?TBYPASS_D_Q[15] : WordX;
	assign QINTint[16] = (TBYPASS_main===0 && delTBYPASS[16]===0)?OutReg[16] : (TBYPASS_main===1 && delTBYPASS[16]===1)?TBYPASS_D_Q[16] : WordX;
	assign QINTint[17] = (TBYPASS_main===0 && delTBYPASS[17]===0)?OutReg[17] : (TBYPASS_main===1 && delTBYPASS[17]===1)?TBYPASS_D_Q[17] : WordX;
	assign QINTint[18] = (TBYPASS_main===0 && delTBYPASS[18]===0)?OutReg[18] : (TBYPASS_main===1 && delTBYPASS[18]===1)?TBYPASS_D_Q[18] : WordX;
	assign QINTint[19] = (TBYPASS_main===0 && delTBYPASS[19]===0)?OutReg[19] : (TBYPASS_main===1 && delTBYPASS[19]===1)?TBYPASS_D_Q[19] : WordX;
	assign QINTint[20] = (TBYPASS_main===0 && delTBYPASS[20]===0)?OutReg[20] : (TBYPASS_main===1 && delTBYPASS[20]===1)?TBYPASS_D_Q[20] : WordX;
	assign QINTint[21] = (TBYPASS_main===0 && delTBYPASS[21]===0)?OutReg[21] : (TBYPASS_main===1 && delTBYPASS[21]===1)?TBYPASS_D_Q[21] : WordX;
	assign QINTint[22] = (TBYPASS_main===0 && delTBYPASS[22]===0)?OutReg[22] : (TBYPASS_main===1 && delTBYPASS[22]===1)?TBYPASS_D_Q[22] : WordX;
	assign QINTint[23] = (TBYPASS_main===0 && delTBYPASS[23]===0)?OutReg[23] : (TBYPASS_main===1 && delTBYPASS[23]===1)?TBYPASS_D_Q[23] : WordX;
	assign QINTint[24] = (TBYPASS_main===0 && delTBYPASS[24]===0)?OutReg[24] : (TBYPASS_main===1 && delTBYPASS[24]===1)?TBYPASS_D_Q[24] : WordX;
	assign QINTint[25] = (TBYPASS_main===0 && delTBYPASS[25]===0)?OutReg[25] : (TBYPASS_main===1 && delTBYPASS[25]===1)?TBYPASS_D_Q[25] : WordX;
	assign QINTint[26] = (TBYPASS_main===0 && delTBYPASS[26]===0)?OutReg[26] : (TBYPASS_main===1 && delTBYPASS[26]===1)?TBYPASS_D_Q[26] : WordX;
	assign QINTint[27] = (TBYPASS_main===0 && delTBYPASS[27]===0)?OutReg[27] : (TBYPASS_main===1 && delTBYPASS[27]===1)?TBYPASS_D_Q[27] : WordX;
	assign QINTint[28] = (TBYPASS_main===0 && delTBYPASS[28]===0)?OutReg[28] : (TBYPASS_main===1 && delTBYPASS[28]===1)?TBYPASS_D_Q[28] : WordX;
	assign QINTint[29] = (TBYPASS_main===0 && delTBYPASS[29]===0)?OutReg[29] : (TBYPASS_main===1 && delTBYPASS[29]===1)?TBYPASS_D_Q[29] : WordX;
	assign QINTint[30] = (TBYPASS_main===0 && delTBYPASS[30]===0)?OutReg[30] : (TBYPASS_main===1 && delTBYPASS[30]===1)?TBYPASS_D_Q[30] : WordX;
	assign QINTint[31] = (TBYPASS_main===0 && delTBYPASS[31]===0)?OutReg[31] : (TBYPASS_main===1 && delTBYPASS[31]===1)?TBYPASS_D_Q[31] : WordX;

assign QINTERNAL = QINTERNALreg;

always @(TBYPASS_main)
begin
           
   if (TBYPASS_main === 0 || TBYPASS_main === X) 
      QINTERNALreg = WordX;
   
end


        
/*------------------ RY functionality -----------------*/
        output RYINT;
        input RY_rfCK, RY_rrCK, RY_frCK, ICRY;
        wire RYINTint;
        reg RYINTreg, RYRiseFlag;

        buf (RYINT, RYINTint);

assign RYINTint = RYINTreg;
        
initial
begin
  RYRiseFlag = 1'b0;
  RYINTreg = 1'b1;
end

always @(ICRY)
begin
   if($realtime == 0)
      RYINTreg = 1'b1;
   else
      RYINTreg = 1'bx;
end

always @(RY_rfCK)
if (ICRY !== 1)
begin
   RYINTreg = 0;
   RYRiseFlag=0;
end

always @(RY_rrCK)
if (ICRY !== 1 && $realtime != 0)
begin
   if (RYRiseFlag === 0)
   begin
      RYRiseFlag=1;
   end
   else
   begin
      RYINTreg = 1'b1;
      RYRiseFlag=0;
   end
end
always @(RY_frCK)
#0
if (ICRY !== 1 && $realtime != 0)
begin
   if (RYRiseFlag === 0)
   begin
      RYRiseFlag=1;
   end
   else
   begin
      RYINTreg = 1'b1;
      RYRiseFlag=0;
   end
end
/*------------------------------------------------ */

always @(Q_gCK)
begin
#0  //This has been used for removing races during hold time violations in MODELSIM simulator.
   lastQ_gCK = Q_gCKreg;
   Q_gCKreg <= Q_gCK;
   for (m = 0; m < Bits; m = m + 1)
   begin
     if (lastQ_gCK[m] !== Q_gCK[m])
     begin
       	lastQINTERNAL[m] = QINTERNALreg[m];
       	QINTERNALreg[m] = Q_glitch[m];
     end
   end
end

always @(Q_data)
begin
#0  //This has been used for removing races during hold time vilations in MODELSIM simulator.
   lastQ_data = Q_datareg;
   Q_datareg <= Q_data;
   for (n = 0; n < Bits; n = n + 1)
   begin
      if (lastQ_data[n] !== Q_data[n])
      begin
       	lastQINTERNAL[n] = QINTERNALreg[n];
       	QINTERNALreg[n] = Q_data[n];
      end
   end
end

always @(QINTERNAL)
begin
   for (d = 0; d < Bits; d = d + 1)
   begin
      if (OutReg[d] !== QINTERNAL[d])
          OutReg[d] = QINTERNAL[d];
   end
end



endmodule


module ST_SPHDL_160x32m8_L (Q, RY, CK, CSN, TBYPASS, WEN,  A,  D   );
   

    parameter 
        Fault_file_name = "ST_SPHDL_160x32m8_L_faults.txt",   
        ConfigFault = 0,
        max_faults = 20,
        MEM_INITIALIZE = 1'b0,
        BinaryInit     = 1'b0,
        InitFileName   = "ST_SPHDL_160x32m8_L.cde",     
        Corruption_Read_Violation = 1,
        Debug_mode = "ALL_WARNING_MODE",
        InstancePath = "ST_SPHDL_160x32m8_L";

    parameter
        Words = 160,
        Bits = 32,
        Addr = 8,
        mux = 8,
        Rows = Words/mux;
        






    parameter
        WordX = 32'bx,
        AddrX = 8'bx,
        X = 1'bx;


    output [Bits-1 : 0] Q;
    
    output RY;   
    input CK;
    input CSN;
    input WEN;
    input TBYPASS;
    input [Addr-1 : 0] A;
    input [Bits-1 : 0] D;
    
    





   
   wire [Bits-1 : 0] Q_glitchint;
   wire [Bits-1 : 0] Q_dataint;
   wire [Bits-1 : 0] Dint,Mint;
   wire [Addr-1 : 0] Aint;
   wire [Bits-1 : 0] Q_gCKint;
   wire CKint;
   wire CSNint;
   wire WENint;
   wire TBYPASSint;
   wire TBYPASS_mainint;
   wire [Bits-1 : 0]  TBYPASS_D_Qint;
   wire [Bits-1 : 0]  delTBYPASSint;






   
   wire [Bits-1 : 0] Qint, Q_out;
   wire CS_taa = !CSNint;
   wire csn_tcycle = !CSNint;
   wire csn_tcycle_DEBUG, csn_tcycle_DEBUGN;
   reg [Bits-1 : 0] Dreg,Mreg;
   reg [Addr-1 : 0] Areg;
   reg CKreg;
   reg CSNreg;
   reg WENreg;
	
   reg [Bits-1 : 0] TimingViol2, TimingViol3, TimingViol12, TimingViol13;
   reg [Bits-1 : 0] TimingViol2_last, TimingViol3_last, TimingViol12_last, TimingViol13_last;
	reg TimingViol2_0, TimingViol3_0, TimingViol12_0, TimingViol13_0;
	reg TimingViol2_1, TimingViol3_1, TimingViol12_1, TimingViol13_1;
	reg TimingViol2_2, TimingViol3_2, TimingViol12_2, TimingViol13_2;
	reg TimingViol2_3, TimingViol3_3, TimingViol12_3, TimingViol13_3;
	reg TimingViol2_4, TimingViol3_4, TimingViol12_4, TimingViol13_4;
	reg TimingViol2_5, TimingViol3_5, TimingViol12_5, TimingViol13_5;
	reg TimingViol2_6, TimingViol3_6, TimingViol12_6, TimingViol13_6;
	reg TimingViol2_7, TimingViol3_7, TimingViol12_7, TimingViol13_7;
	reg TimingViol2_8, TimingViol3_8, TimingViol12_8, TimingViol13_8;
	reg TimingViol2_9, TimingViol3_9, TimingViol12_9, TimingViol13_9;
	reg TimingViol2_10, TimingViol3_10, TimingViol12_10, TimingViol13_10;
	reg TimingViol2_11, TimingViol3_11, TimingViol12_11, TimingViol13_11;
	reg TimingViol2_12, TimingViol3_12, TimingViol12_12, TimingViol13_12;
	reg TimingViol2_13, TimingViol3_13, TimingViol12_13, TimingViol13_13;
	reg TimingViol2_14, TimingViol3_14, TimingViol12_14, TimingViol13_14;
	reg TimingViol2_15, TimingViol3_15, TimingViol12_15, TimingViol13_15;
	reg TimingViol2_16, TimingViol3_16, TimingViol12_16, TimingViol13_16;
	reg TimingViol2_17, TimingViol3_17, TimingViol12_17, TimingViol13_17;
	reg TimingViol2_18, TimingViol3_18, TimingViol12_18, TimingViol13_18;
	reg TimingViol2_19, TimingViol3_19, TimingViol12_19, TimingViol13_19;
	reg TimingViol2_20, TimingViol3_20, TimingViol12_20, TimingViol13_20;
	reg TimingViol2_21, TimingViol3_21, TimingViol12_21, TimingViol13_21;
	reg TimingViol2_22, TimingViol3_22, TimingViol12_22, TimingViol13_22;
	reg TimingViol2_23, TimingViol3_23, TimingViol12_23, TimingViol13_23;
	reg TimingViol2_24, TimingViol3_24, TimingViol12_24, TimingViol13_24;
	reg TimingViol2_25, TimingViol3_25, TimingViol12_25, TimingViol13_25;
	reg TimingViol2_26, TimingViol3_26, TimingViol12_26, TimingViol13_26;
	reg TimingViol2_27, TimingViol3_27, TimingViol12_27, TimingViol13_27;
	reg TimingViol2_28, TimingViol3_28, TimingViol12_28, TimingViol13_28;
	reg TimingViol2_29, TimingViol3_29, TimingViol12_29, TimingViol13_29;
	reg TimingViol2_30, TimingViol3_30, TimingViol12_30, TimingViol13_30;
	reg TimingViol2_31, TimingViol3_31, TimingViol12_31, TimingViol13_31;
   reg TimingViol0, TimingViol1;
   reg TimingViol4, TimingViol5, TimingViol6, TimingViol7, TimingViol_ttms_ttmh;
   reg TimingViol8, TimingViol9, TimingViol10, TimingViol10_taa;








   wire [Bits-1 : 0] MEN,CSWEMTBYPASS;
   wire CSTBYPASSN, CSWETBYPASSN;
   wire csn_tckl;
   wire csn_tckl_ry;
   wire csn_tckh;

   reg tckh_flag;
   reg tckl_flag;

   wire CS_taa_ry = !CSNint;
   
/* This register is used to force all warning messages 
** OFF during run time.
** 
*/ 
   reg [1:0] debug_level;
   reg [8*10: 0] operating_mode;
   reg [8*44: 0] message_status;





initial
begin
  debug_level = 2'b0;
  message_status = "All Messages are Switched ON";
  `ifdef  NO_WARNING_MODE
     debug_level = 2'b10;
    message_status = "All Messages are Switched OFF"; 
  `endif 
if(debug_level !== 2'b10) begin
  $display ("%m  INFORMATION");
   $display ("***************************************");
   $display ("The Model is Operating in TIMING MODE");
   $display ("Please make sure that SDF is properly annotated otherwise dummy values will be used");
   $display ("%s", message_status);
   $display ("***************************************");
   if(ConfigFault)
  $display ("Configurable Fault Functionality is ON");   
  else
  $display ("Configurable Fault Functionality is OFF"); 
  
  $display ("***************************************");
end     
end     

   buf (CKint, CK);

   //MEM_EN = CSN or  TBYPASS
   or (CSNint, CSN, TBYPASS  );

   buf (TBYPASSint, TBYPASS);
   buf (WENint, WEN);
   buf bufDint [Bits-1:0] (Dint, D);
   
   assign Mint = 32'b0;
   
   buf bufAint [Addr-1:0] (Aint, A);






   
     buf bufqint [Bits-1:0] (Q,Qint); 





	reg TimingViol9_tck_ry, TimingViol10_taa_ry;
        wire  RYint, RY_rfCKint, RY_rrCKint, RY_frCKint, RY_out;
        reg RY_outreg; 
        assign RY_out = RY_outreg;
  
     
       buf (RY, RY_out);  
       
        always @(RYint)
        begin
        RY_outreg = RYint;
        end

        
   // Only include timing checks during behavioural modelling



not (CS, CSN);    


    not (TBYPASSN, TBYPASS);
    not (WE, WEN);

    and (CSWE, CS, WE);
    and (CSWETBYPASSN, CSWE, TBYPASSN);
    and (CSTBYPASSN, CS, TBYPASSN);
    and (CSWEN, CS, WEN);
 
    assign csn_tckh = tckh_flag;
    assign csn_tckl = tckl_flag;
    assign csn_tckl_ry = tckl_flag;


        
 not (MEN[0], Mint[0]);
 not (MEN[1], Mint[1]);
 not (MEN[2], Mint[2]);
 not (MEN[3], Mint[3]);
 not (MEN[4], Mint[4]);
 not (MEN[5], Mint[5]);
 not (MEN[6], Mint[6]);
 not (MEN[7], Mint[7]);
 not (MEN[8], Mint[8]);
 not (MEN[9], Mint[9]);
 not (MEN[10], Mint[10]);
 not (MEN[11], Mint[11]);
 not (MEN[12], Mint[12]);
 not (MEN[13], Mint[13]);
 not (MEN[14], Mint[14]);
 not (MEN[15], Mint[15]);
 not (MEN[16], Mint[16]);
 not (MEN[17], Mint[17]);
 not (MEN[18], Mint[18]);
 not (MEN[19], Mint[19]);
 not (MEN[20], Mint[20]);
 not (MEN[21], Mint[21]);
 not (MEN[22], Mint[22]);
 not (MEN[23], Mint[23]);
 not (MEN[24], Mint[24]);
 not (MEN[25], Mint[25]);
 not (MEN[26], Mint[26]);
 not (MEN[27], Mint[27]);
 not (MEN[28], Mint[28]);
 not (MEN[29], Mint[29]);
 not (MEN[30], Mint[30]);
 not (MEN[31], Mint[31]);
 and (CSWEMTBYPASS[0], MEN[0], CSWETBYPASSN);
 and (CSWEMTBYPASS[1], MEN[1], CSWETBYPASSN);
 and (CSWEMTBYPASS[2], MEN[2], CSWETBYPASSN);
 and (CSWEMTBYPASS[3], MEN[3], CSWETBYPASSN);
 and (CSWEMTBYPASS[4], MEN[4], CSWETBYPASSN);
 and (CSWEMTBYPASS[5], MEN[5], CSWETBYPASSN);
 and (CSWEMTBYPASS[6], MEN[6], CSWETBYPASSN);
 and (CSWEMTBYPASS[7], MEN[7], CSWETBYPASSN);
 and (CSWEMTBYPASS[8], MEN[8], CSWETBYPASSN);
 and (CSWEMTBYPASS[9], MEN[9], CSWETBYPASSN);
 and (CSWEMTBYPASS[10], MEN[10], CSWETBYPASSN);
 and (CSWEMTBYPASS[11], MEN[11], CSWETBYPASSN);
 and (CSWEMTBYPASS[12], MEN[12], CSWETBYPASSN);
 and (CSWEMTBYPASS[13], MEN[13], CSWETBYPASSN);
 and (CSWEMTBYPASS[14], MEN[14], CSWETBYPASSN);
 and (CSWEMTBYPASS[15], MEN[15], CSWETBYPASSN);
 and (CSWEMTBYPASS[16], MEN[16], CSWETBYPASSN);
 and (CSWEMTBYPASS[17], MEN[17], CSWETBYPASSN);
 and (CSWEMTBYPASS[18], MEN[18], CSWETBYPASSN);
 and (CSWEMTBYPASS[19], MEN[19], CSWETBYPASSN);
 and (CSWEMTBYPASS[20], MEN[20], CSWETBYPASSN);
 and (CSWEMTBYPASS[21], MEN[21], CSWETBYPASSN);
 and (CSWEMTBYPASS[22], MEN[22], CSWETBYPASSN);
 and (CSWEMTBYPASS[23], MEN[23], CSWETBYPASSN);
 and (CSWEMTBYPASS[24], MEN[24], CSWETBYPASSN);
 and (CSWEMTBYPASS[25], MEN[25], CSWETBYPASSN);
 and (CSWEMTBYPASS[26], MEN[26], CSWETBYPASSN);
 and (CSWEMTBYPASS[27], MEN[27], CSWETBYPASSN);
 and (CSWEMTBYPASS[28], MEN[28], CSWETBYPASSN);
 and (CSWEMTBYPASS[29], MEN[29], CSWETBYPASSN);
 and (CSWEMTBYPASS[30], MEN[30], CSWETBYPASSN);
 and (CSWEMTBYPASS[31], MEN[31], CSWETBYPASSN);

   specify
      specparam



         tckl_tck_ry = 0.00,
         tcycle_taa_ry = 0.00,

 
         
	 tms = 0.0,
         tmh = 0.0,
         tcycle = 0.0,
         tcycle_taa = 0.0,
         tckh = 0.0,
         tckl = 0.0,
         ttms = 0.0,
         ttmh = 0.0,
         tps = 0.0,
         tph = 0.0,
         tws = 0.0,
         twh = 0.0,
         tas = 0.0,
         tah = 0.0,
         tds = 0.0,
         tdh = 0.0;
        /*---------------------- Timing Checks ---------------------*/

	$setup(posedge A[0], posedge CK &&& CSTBYPASSN, tas, TimingViol0);
	$setup(posedge A[1], posedge CK &&& CSTBYPASSN, tas, TimingViol0);
	$setup(posedge A[2], posedge CK &&& CSTBYPASSN, tas, TimingViol0);
	$setup(posedge A[3], posedge CK &&& CSTBYPASSN, tas, TimingViol0);
	$setup(posedge A[4], posedge CK &&& CSTBYPASSN, tas, TimingViol0);
	$setup(posedge A[5], posedge CK &&& CSTBYPASSN, tas, TimingViol0);
	$setup(posedge A[6], posedge CK &&& CSTBYPASSN, tas, TimingViol0);
	$setup(posedge A[7], posedge CK &&& CSTBYPASSN, tas, TimingViol0);
	$setup(negedge A[0], posedge CK &&& CSTBYPASSN, tas, TimingViol0);
	$setup(negedge A[1], posedge CK &&& CSTBYPASSN, tas, TimingViol0);
	$setup(negedge A[2], posedge CK &&& CSTBYPASSN, tas, TimingViol0);
	$setup(negedge A[3], posedge CK &&& CSTBYPASSN, tas, TimingViol0);
	$setup(negedge A[4], posedge CK &&& CSTBYPASSN, tas, TimingViol0);
	$setup(negedge A[5], posedge CK &&& CSTBYPASSN, tas, TimingViol0);
	$setup(negedge A[6], posedge CK &&& CSTBYPASSN, tas, TimingViol0);
	$setup(negedge A[7], posedge CK &&& CSTBYPASSN, tas, TimingViol0);
	$hold(posedge CK &&& CSTBYPASSN, posedge A[0], tah, TimingViol1);
	$hold(posedge CK &&& CSTBYPASSN, posedge A[1], tah, TimingViol1);
	$hold(posedge CK &&& CSTBYPASSN, posedge A[2], tah, TimingViol1);
	$hold(posedge CK &&& CSTBYPASSN, posedge A[3], tah, TimingViol1);
	$hold(posedge CK &&& CSTBYPASSN, posedge A[4], tah, TimingViol1);
	$hold(posedge CK &&& CSTBYPASSN, posedge A[5], tah, TimingViol1);
	$hold(posedge CK &&& CSTBYPASSN, posedge A[6], tah, TimingViol1);
	$hold(posedge CK &&& CSTBYPASSN, posedge A[7], tah, TimingViol1);
	$hold(posedge CK &&& CSTBYPASSN, negedge A[0], tah, TimingViol1);
	$hold(posedge CK &&& CSTBYPASSN, negedge A[1], tah, TimingViol1);
	$hold(posedge CK &&& CSTBYPASSN, negedge A[2], tah, TimingViol1);
	$hold(posedge CK &&& CSTBYPASSN, negedge A[3], tah, TimingViol1);
	$hold(posedge CK &&& CSTBYPASSN, negedge A[4], tah, TimingViol1);
	$hold(posedge CK &&& CSTBYPASSN, negedge A[5], tah, TimingViol1);
	$hold(posedge CK &&& CSTBYPASSN, negedge A[6], tah, TimingViol1);
	$hold(posedge CK &&& CSTBYPASSN, negedge A[7], tah, TimingViol1);
	$setup(posedge D[0], posedge CK &&& (CSWEMTBYPASS[0] != 0), tds, TimingViol2_0);
	$setup(posedge D[1], posedge CK &&& (CSWEMTBYPASS[1] != 0), tds, TimingViol2_1);
	$setup(posedge D[2], posedge CK &&& (CSWEMTBYPASS[2] != 0), tds, TimingViol2_2);
	$setup(posedge D[3], posedge CK &&& (CSWEMTBYPASS[3] != 0), tds, TimingViol2_3);
	$setup(posedge D[4], posedge CK &&& (CSWEMTBYPASS[4] != 0), tds, TimingViol2_4);
	$setup(posedge D[5], posedge CK &&& (CSWEMTBYPASS[5] != 0), tds, TimingViol2_5);
	$setup(posedge D[6], posedge CK &&& (CSWEMTBYPASS[6] != 0), tds, TimingViol2_6);
	$setup(posedge D[7], posedge CK &&& (CSWEMTBYPASS[7] != 0), tds, TimingViol2_7);
	$setup(posedge D[8], posedge CK &&& (CSWEMTBYPASS[8] != 0), tds, TimingViol2_8);
	$setup(posedge D[9], posedge CK &&& (CSWEMTBYPASS[9] != 0), tds, TimingViol2_9);
	$setup(posedge D[10], posedge CK &&& (CSWEMTBYPASS[10] != 0), tds, TimingViol2_10);
	$setup(posedge D[11], posedge CK &&& (CSWEMTBYPASS[11] != 0), tds, TimingViol2_11);
	$setup(posedge D[12], posedge CK &&& (CSWEMTBYPASS[12] != 0), tds, TimingViol2_12);
	$setup(posedge D[13], posedge CK &&& (CSWEMTBYPASS[13] != 0), tds, TimingViol2_13);
	$setup(posedge D[14], posedge CK &&& (CSWEMTBYPASS[14] != 0), tds, TimingViol2_14);
	$setup(posedge D[15], posedge CK &&& (CSWEMTBYPASS[15] != 0), tds, TimingViol2_15);
	$setup(posedge D[16], posedge CK &&& (CSWEMTBYPASS[16] != 0), tds, TimingViol2_16);
	$setup(posedge D[17], posedge CK &&& (CSWEMTBYPASS[17] != 0), tds, TimingViol2_17);
	$setup(posedge D[18], posedge CK &&& (CSWEMTBYPASS[18] != 0), tds, TimingViol2_18);
	$setup(posedge D[19], posedge CK &&& (CSWEMTBYPASS[19] != 0), tds, TimingViol2_19);
	$setup(posedge D[20], posedge CK &&& (CSWEMTBYPASS[20] != 0), tds, TimingViol2_20);
	$setup(posedge D[21], posedge CK &&& (CSWEMTBYPASS[21] != 0), tds, TimingViol2_21);
	$setup(posedge D[22], posedge CK &&& (CSWEMTBYPASS[22] != 0), tds, TimingViol2_22);
	$setup(posedge D[23], posedge CK &&& (CSWEMTBYPASS[23] != 0), tds, TimingViol2_23);
	$setup(posedge D[24], posedge CK &&& (CSWEMTBYPASS[24] != 0), tds, TimingViol2_24);
	$setup(posedge D[25], posedge CK &&& (CSWEMTBYPASS[25] != 0), tds, TimingViol2_25);
	$setup(posedge D[26], posedge CK &&& (CSWEMTBYPASS[26] != 0), tds, TimingViol2_26);
	$setup(posedge D[27], posedge CK &&& (CSWEMTBYPASS[27] != 0), tds, TimingViol2_27);
	$setup(posedge D[28], posedge CK &&& (CSWEMTBYPASS[28] != 0), tds, TimingViol2_28);
	$setup(posedge D[29], posedge CK &&& (CSWEMTBYPASS[29] != 0), tds, TimingViol2_29);
	$setup(posedge D[30], posedge CK &&& (CSWEMTBYPASS[30] != 0), tds, TimingViol2_30);
	$setup(posedge D[31], posedge CK &&& (CSWEMTBYPASS[31] != 0), tds, TimingViol2_31);
	$setup(negedge D[0], posedge CK &&& (CSWEMTBYPASS[0] != 0), tds, TimingViol2_0);
	$setup(negedge D[1], posedge CK &&& (CSWEMTBYPASS[1] != 0), tds, TimingViol2_1);
	$setup(negedge D[2], posedge CK &&& (CSWEMTBYPASS[2] != 0), tds, TimingViol2_2);
	$setup(negedge D[3], posedge CK &&& (CSWEMTBYPASS[3] != 0), tds, TimingViol2_3);
	$setup(negedge D[4], posedge CK &&& (CSWEMTBYPASS[4] != 0), tds, TimingViol2_4);
	$setup(negedge D[5], posedge CK &&& (CSWEMTBYPASS[5] != 0), tds, TimingViol2_5);
	$setup(negedge D[6], posedge CK &&& (CSWEMTBYPASS[6] != 0), tds, TimingViol2_6);
	$setup(negedge D[7], posedge CK &&& (CSWEMTBYPASS[7] != 0), tds, TimingViol2_7);
	$setup(negedge D[8], posedge CK &&& (CSWEMTBYPASS[8] != 0), tds, TimingViol2_8);
	$setup(negedge D[9], posedge CK &&& (CSWEMTBYPASS[9] != 0), tds, TimingViol2_9);
	$setup(negedge D[10], posedge CK &&& (CSWEMTBYPASS[10] != 0), tds, TimingViol2_10);
	$setup(negedge D[11], posedge CK &&& (CSWEMTBYPASS[11] != 0), tds, TimingViol2_11);
	$setup(negedge D[12], posedge CK &&& (CSWEMTBYPASS[12] != 0), tds, TimingViol2_12);
	$setup(negedge D[13], posedge CK &&& (CSWEMTBYPASS[13] != 0), tds, TimingViol2_13);
	$setup(negedge D[14], posedge CK &&& (CSWEMTBYPASS[14] != 0), tds, TimingViol2_14);
	$setup(negedge D[15], posedge CK &&& (CSWEMTBYPASS[15] != 0), tds, TimingViol2_15);
	$setup(negedge D[16], posedge CK &&& (CSWEMTBYPASS[16] != 0), tds, TimingViol2_16);
	$setup(negedge D[17], posedge CK &&& (CSWEMTBYPASS[17] != 0), tds, TimingViol2_17);
	$setup(negedge D[18], posedge CK &&& (CSWEMTBYPASS[18] != 0), tds, TimingViol2_18);
	$setup(negedge D[19], posedge CK &&& (CSWEMTBYPASS[19] != 0), tds, TimingViol2_19);
	$setup(negedge D[20], posedge CK &&& (CSWEMTBYPASS[20] != 0), tds, TimingViol2_20);
	$setup(negedge D[21], posedge CK &&& (CSWEMTBYPASS[21] != 0), tds, TimingViol2_21);
	$setup(negedge D[22], posedge CK &&& (CSWEMTBYPASS[22] != 0), tds, TimingViol2_22);
	$setup(negedge D[23], posedge CK &&& (CSWEMTBYPASS[23] != 0), tds, TimingViol2_23);
	$setup(negedge D[24], posedge CK &&& (CSWEMTBYPASS[24] != 0), tds, TimingViol2_24);
	$setup(negedge D[25], posedge CK &&& (CSWEMTBYPASS[25] != 0), tds, TimingViol2_25);
	$setup(negedge D[26], posedge CK &&& (CSWEMTBYPASS[26] != 0), tds, TimingViol2_26);
	$setup(negedge D[27], posedge CK &&& (CSWEMTBYPASS[27] != 0), tds, TimingViol2_27);
	$setup(negedge D[28], posedge CK &&& (CSWEMTBYPASS[28] != 0), tds, TimingViol2_28);
	$setup(negedge D[29], posedge CK &&& (CSWEMTBYPASS[29] != 0), tds, TimingViol2_29);
	$setup(negedge D[30], posedge CK &&& (CSWEMTBYPASS[30] != 0), tds, TimingViol2_30);
	$setup(negedge D[31], posedge CK &&& (CSWEMTBYPASS[31] != 0), tds, TimingViol2_31);
	$hold(posedge CK &&& (CSWEMTBYPASS[0] != 0), posedge D[0], tdh, TimingViol3_0);
	$hold(posedge CK &&& (CSWEMTBYPASS[1] != 0), posedge D[1], tdh, TimingViol3_1);
	$hold(posedge CK &&& (CSWEMTBYPASS[2] != 0), posedge D[2], tdh, TimingViol3_2);
	$hold(posedge CK &&& (CSWEMTBYPASS[3] != 0), posedge D[3], tdh, TimingViol3_3);
	$hold(posedge CK &&& (CSWEMTBYPASS[4] != 0), posedge D[4], tdh, TimingViol3_4);
	$hold(posedge CK &&& (CSWEMTBYPASS[5] != 0), posedge D[5], tdh, TimingViol3_5);
	$hold(posedge CK &&& (CSWEMTBYPASS[6] != 0), posedge D[6], tdh, TimingViol3_6);
	$hold(posedge CK &&& (CSWEMTBYPASS[7] != 0), posedge D[7], tdh, TimingViol3_7);
	$hold(posedge CK &&& (CSWEMTBYPASS[8] != 0), posedge D[8], tdh, TimingViol3_8);
	$hold(posedge CK &&& (CSWEMTBYPASS[9] != 0), posedge D[9], tdh, TimingViol3_9);
	$hold(posedge CK &&& (CSWEMTBYPASS[10] != 0), posedge D[10], tdh, TimingViol3_10);
	$hold(posedge CK &&& (CSWEMTBYPASS[11] != 0), posedge D[11], tdh, TimingViol3_11);
	$hold(posedge CK &&& (CSWEMTBYPASS[12] != 0), posedge D[12], tdh, TimingViol3_12);
	$hold(posedge CK &&& (CSWEMTBYPASS[13] != 0), posedge D[13], tdh, TimingViol3_13);
	$hold(posedge CK &&& (CSWEMTBYPASS[14] != 0), posedge D[14], tdh, TimingViol3_14);
	$hold(posedge CK &&& (CSWEMTBYPASS[15] != 0), posedge D[15], tdh, TimingViol3_15);
	$hold(posedge CK &&& (CSWEMTBYPASS[16] != 0), posedge D[16], tdh, TimingViol3_16);
	$hold(posedge CK &&& (CSWEMTBYPASS[17] != 0), posedge D[17], tdh, TimingViol3_17);
	$hold(posedge CK &&& (CSWEMTBYPASS[18] != 0), posedge D[18], tdh, TimingViol3_18);
	$hold(posedge CK &&& (CSWEMTBYPASS[19] != 0), posedge D[19], tdh, TimingViol3_19);
	$hold(posedge CK &&& (CSWEMTBYPASS[20] != 0), posedge D[20], tdh, TimingViol3_20);
	$hold(posedge CK &&& (CSWEMTBYPASS[21] != 0), posedge D[21], tdh, TimingViol3_21);
	$hold(posedge CK &&& (CSWEMTBYPASS[22] != 0), posedge D[22], tdh, TimingViol3_22);
	$hold(posedge CK &&& (CSWEMTBYPASS[23] != 0), posedge D[23], tdh, TimingViol3_23);
	$hold(posedge CK &&& (CSWEMTBYPASS[24] != 0), posedge D[24], tdh, TimingViol3_24);
	$hold(posedge CK &&& (CSWEMTBYPASS[25] != 0), posedge D[25], tdh, TimingViol3_25);
	$hold(posedge CK &&& (CSWEMTBYPASS[26] != 0), posedge D[26], tdh, TimingViol3_26);
	$hold(posedge CK &&& (CSWEMTBYPASS[27] != 0), posedge D[27], tdh, TimingViol3_27);
	$hold(posedge CK &&& (CSWEMTBYPASS[28] != 0), posedge D[28], tdh, TimingViol3_28);
	$hold(posedge CK &&& (CSWEMTBYPASS[29] != 0), posedge D[29], tdh, TimingViol3_29);
	$hold(posedge CK &&& (CSWEMTBYPASS[30] != 0), posedge D[30], tdh, TimingViol3_30);
	$hold(posedge CK &&& (CSWEMTBYPASS[31] != 0), posedge D[31], tdh, TimingViol3_31);
	$hold(posedge CK &&& (CSWEMTBYPASS[0] != 0), negedge D[0], tdh, TimingViol3_0);
	$hold(posedge CK &&& (CSWEMTBYPASS[1] != 0), negedge D[1], tdh, TimingViol3_1);
	$hold(posedge CK &&& (CSWEMTBYPASS[2] != 0), negedge D[2], tdh, TimingViol3_2);
	$hold(posedge CK &&& (CSWEMTBYPASS[3] != 0), negedge D[3], tdh, TimingViol3_3);
	$hold(posedge CK &&& (CSWEMTBYPASS[4] != 0), negedge D[4], tdh, TimingViol3_4);
	$hold(posedge CK &&& (CSWEMTBYPASS[5] != 0), negedge D[5], tdh, TimingViol3_5);
	$hold(posedge CK &&& (CSWEMTBYPASS[6] != 0), negedge D[6], tdh, TimingViol3_6);
	$hold(posedge CK &&& (CSWEMTBYPASS[7] != 0), negedge D[7], tdh, TimingViol3_7);
	$hold(posedge CK &&& (CSWEMTBYPASS[8] != 0), negedge D[8], tdh, TimingViol3_8);
	$hold(posedge CK &&& (CSWEMTBYPASS[9] != 0), negedge D[9], tdh, TimingViol3_9);
	$hold(posedge CK &&& (CSWEMTBYPASS[10] != 0), negedge D[10], tdh, TimingViol3_10);
	$hold(posedge CK &&& (CSWEMTBYPASS[11] != 0), negedge D[11], tdh, TimingViol3_11);
	$hold(posedge CK &&& (CSWEMTBYPASS[12] != 0), negedge D[12], tdh, TimingViol3_12);
	$hold(posedge CK &&& (CSWEMTBYPASS[13] != 0), negedge D[13], tdh, TimingViol3_13);
	$hold(posedge CK &&& (CSWEMTBYPASS[14] != 0), negedge D[14], tdh, TimingViol3_14);
	$hold(posedge CK &&& (CSWEMTBYPASS[15] != 0), negedge D[15], tdh, TimingViol3_15);
	$hold(posedge CK &&& (CSWEMTBYPASS[16] != 0), negedge D[16], tdh, TimingViol3_16);
	$hold(posedge CK &&& (CSWEMTBYPASS[17] != 0), negedge D[17], tdh, TimingViol3_17);
	$hold(posedge CK &&& (CSWEMTBYPASS[18] != 0), negedge D[18], tdh, TimingViol3_18);
	$hold(posedge CK &&& (CSWEMTBYPASS[19] != 0), negedge D[19], tdh, TimingViol3_19);
	$hold(posedge CK &&& (CSWEMTBYPASS[20] != 0), negedge D[20], tdh, TimingViol3_20);
	$hold(posedge CK &&& (CSWEMTBYPASS[21] != 0), negedge D[21], tdh, TimingViol3_21);
	$hold(posedge CK &&& (CSWEMTBYPASS[22] != 0), negedge D[22], tdh, TimingViol3_22);
	$hold(posedge CK &&& (CSWEMTBYPASS[23] != 0), negedge D[23], tdh, TimingViol3_23);
	$hold(posedge CK &&& (CSWEMTBYPASS[24] != 0), negedge D[24], tdh, TimingViol3_24);
	$hold(posedge CK &&& (CSWEMTBYPASS[25] != 0), negedge D[25], tdh, TimingViol3_25);
	$hold(posedge CK &&& (CSWEMTBYPASS[26] != 0), negedge D[26], tdh, TimingViol3_26);
	$hold(posedge CK &&& (CSWEMTBYPASS[27] != 0), negedge D[27], tdh, TimingViol3_27);
	$hold(posedge CK &&& (CSWEMTBYPASS[28] != 0), negedge D[28], tdh, TimingViol3_28);
	$hold(posedge CK &&& (CSWEMTBYPASS[29] != 0), negedge D[29], tdh, TimingViol3_29);
	$hold(posedge CK &&& (CSWEMTBYPASS[30] != 0), negedge D[30], tdh, TimingViol3_30);
	$hold(posedge CK &&& (CSWEMTBYPASS[31] != 0), negedge D[31], tdh, TimingViol3_31);

        
        $setup(posedge CSN, edge[01,0x,x1,1x] CK &&& TBYPASSint != 1'b1, tps, TimingViol4);
	$setup(negedge CSN, edge[01,0x,x1,1x] CK &&& TBYPASSint != 1'b1, tps, TimingViol4);
	$hold(edge[01,0x,x1,x0] CK &&& TBYPASSint != 1'b1, posedge CSN, tph, TimingViol5);
	$hold(edge[01,0x,x1,x0] CK &&& TBYPASSint != 1'b1, negedge CSN, tph, TimingViol5);
        $setup(posedge WEN, edge[01,0x,x1,1x] CK &&& (CSTBYPASSN != 'b0), tws, TimingViol6);
        $setup(negedge WEN, edge[01,0x,x1,1x] CK &&& (CSTBYPASSN != 'b0), tws, TimingViol6);
        $hold(edge[01,0x,x1,x0] CK &&& (CSTBYPASSN != 'b0), posedge WEN, twh, TimingViol7);
        $hold(edge[01,0x,x1,x0] CK &&& (CSTBYPASSN != 'b0), negedge WEN, twh, TimingViol7);
        

        $period(posedge CK &&& (csn_tcycle != 0), tcycle, TimingViol10); 
        $period(posedge CK &&& (CS_taa != 0), tcycle_taa, TimingViol10_taa);
        $width(posedge CK &&& (csn_tckh != 'b0), tckh, 0, TimingViol8);
        $width(negedge CK &&& (csn_tckl != 'b0), tckl, 0, TimingViol9);
        
        // TBYPASS setup/hold violations
        $setup(posedge TBYPASS, posedge CK &&& (CS != 0),ttms, TimingViol_ttms_ttmh);
        $setup(negedge TBYPASS, posedge CK &&& (CS != 0),ttms, TimingViol_ttms_ttmh);

        $hold(posedge CK &&& (CS != 1'b0), posedge TBYPASS, ttmh, TimingViol_ttms_ttmh);
        $hold(posedge CK &&& (CS != 1'b0), negedge TBYPASS, ttmh, TimingViol_ttms_ttmh); 



        $period(posedge CK &&& (CS_taa_ry != 0), tcycle_taa_ry, TimingViol10_taa_ry);
        $width(negedge CK &&& (csn_tckl_ry!= 0), tckl_tck_ry, 0, TimingViol9_tck_ry);


        
	endspecify

always @(CKint)
begin
   CKreg <= CKint;
end

always @(posedge CKint)
begin
   if (CSNint !== 1)
   begin
      Dreg = Dint;
      Mreg = Mint;
      WENreg = WENint;
      Areg = Aint;
   end
   CSNreg = CSNint;
   if (CSNint === 1'b1)
      tckh_flag = 0;
   else
      tckh_flag = 1;
        
tckl_flag = 1;
end
     
always @(negedge CKint)
begin
   #0.00   tckh_flag = 1;
   if (CSNint === 1)
      tckl_flag = 0;
   else
      tckl_flag = 1;
end
     
always @(CSNint)
begin
   if (CKint !== 1)
      tckl_flag = ~CSNint;
end

always @(TimingViol10_taa)
begin
   if(debug_level < 2)
   $display("%m - %t WARNING: READ/WRITE ACCESS TIME IS GREATER THAN THE CLOCK PERIOD",$realtime);
end

// conversion from registers to array elements for mask setup violation notifiers


// conversion from registers to array elements for mask hold violation notifiers


// conversion from registers to array elements for data setup violation notifiers

always @(TimingViol2_31)
begin
   TimingViol2[31] = TimingViol2_31;
end


always @(TimingViol2_30)
begin
   TimingViol2[30] = TimingViol2_30;
end


always @(TimingViol2_29)
begin
   TimingViol2[29] = TimingViol2_29;
end


always @(TimingViol2_28)
begin
   TimingViol2[28] = TimingViol2_28;
end


always @(TimingViol2_27)
begin
   TimingViol2[27] = TimingViol2_27;
end


always @(TimingViol2_26)
begin
   TimingViol2[26] = TimingViol2_26;
end


always @(TimingViol2_25)
begin
   TimingViol2[25] = TimingViol2_25;
end


always @(TimingViol2_24)
begin
   TimingViol2[24] = TimingViol2_24;
end


always @(TimingViol2_23)
begin
   TimingViol2[23] = TimingViol2_23;
end


always @(TimingViol2_22)
begin
   TimingViol2[22] = TimingViol2_22;
end


always @(TimingViol2_21)
begin
   TimingViol2[21] = TimingViol2_21;
end


always @(TimingViol2_20)
begin
   TimingViol2[20] = TimingViol2_20;
end


always @(TimingViol2_19)
begin
   TimingViol2[19] = TimingViol2_19;
end


always @(TimingViol2_18)
begin
   TimingViol2[18] = TimingViol2_18;
end


always @(TimingViol2_17)
begin
   TimingViol2[17] = TimingViol2_17;
end


always @(TimingViol2_16)
begin
   TimingViol2[16] = TimingViol2_16;
end


always @(TimingViol2_15)
begin
   TimingViol2[15] = TimingViol2_15;
end


always @(TimingViol2_14)
begin
   TimingViol2[14] = TimingViol2_14;
end


always @(TimingViol2_13)
begin
   TimingViol2[13] = TimingViol2_13;
end


always @(TimingViol2_12)
begin
   TimingViol2[12] = TimingViol2_12;
end


always @(TimingViol2_11)
begin
   TimingViol2[11] = TimingViol2_11;
end


always @(TimingViol2_10)
begin
   TimingViol2[10] = TimingViol2_10;
end


always @(TimingViol2_9)
begin
   TimingViol2[9] = TimingViol2_9;
end


always @(TimingViol2_8)
begin
   TimingViol2[8] = TimingViol2_8;
end


always @(TimingViol2_7)
begin
   TimingViol2[7] = TimingViol2_7;
end


always @(TimingViol2_6)
begin
   TimingViol2[6] = TimingViol2_6;
end


always @(TimingViol2_5)
begin
   TimingViol2[5] = TimingViol2_5;
end


always @(TimingViol2_4)
begin
   TimingViol2[4] = TimingViol2_4;
end


always @(TimingViol2_3)
begin
   TimingViol2[3] = TimingViol2_3;
end


always @(TimingViol2_2)
begin
   TimingViol2[2] = TimingViol2_2;
end


always @(TimingViol2_1)
begin
   TimingViol2[1] = TimingViol2_1;
end


always @(TimingViol2_0)
begin
   TimingViol2[0] = TimingViol2_0;
end


// conversion from registers to array elements for data hold violation notifiers

always @(TimingViol3_31)
begin
   TimingViol3[31] = TimingViol3_31;
end


always @(TimingViol3_30)
begin
   TimingViol3[30] = TimingViol3_30;
end


always @(TimingViol3_29)
begin
   TimingViol3[29] = TimingViol3_29;
end


always @(TimingViol3_28)
begin
   TimingViol3[28] = TimingViol3_28;
end


always @(TimingViol3_27)
begin
   TimingViol3[27] = TimingViol3_27;
end


always @(TimingViol3_26)
begin
   TimingViol3[26] = TimingViol3_26;
end


always @(TimingViol3_25)
begin
   TimingViol3[25] = TimingViol3_25;
end


always @(TimingViol3_24)
begin
   TimingViol3[24] = TimingViol3_24;
end


always @(TimingViol3_23)
begin
   TimingViol3[23] = TimingViol3_23;
end


always @(TimingViol3_22)
begin
   TimingViol3[22] = TimingViol3_22;
end


always @(TimingViol3_21)
begin
   TimingViol3[21] = TimingViol3_21;
end


always @(TimingViol3_20)
begin
   TimingViol3[20] = TimingViol3_20;
end


always @(TimingViol3_19)
begin
   TimingViol3[19] = TimingViol3_19;
end


always @(TimingViol3_18)
begin
   TimingViol3[18] = TimingViol3_18;
end


always @(TimingViol3_17)
begin
   TimingViol3[17] = TimingViol3_17;
end


always @(TimingViol3_16)
begin
   TimingViol3[16] = TimingViol3_16;
end


always @(TimingViol3_15)
begin
   TimingViol3[15] = TimingViol3_15;
end


always @(TimingViol3_14)
begin
   TimingViol3[14] = TimingViol3_14;
end


always @(TimingViol3_13)
begin
   TimingViol3[13] = TimingViol3_13;
end


always @(TimingViol3_12)
begin
   TimingViol3[12] = TimingViol3_12;
end


always @(TimingViol3_11)
begin
   TimingViol3[11] = TimingViol3_11;
end


always @(TimingViol3_10)
begin
   TimingViol3[10] = TimingViol3_10;
end


always @(TimingViol3_9)
begin
   TimingViol3[9] = TimingViol3_9;
end


always @(TimingViol3_8)
begin
   TimingViol3[8] = TimingViol3_8;
end


always @(TimingViol3_7)
begin
   TimingViol3[7] = TimingViol3_7;
end


always @(TimingViol3_6)
begin
   TimingViol3[6] = TimingViol3_6;
end


always @(TimingViol3_5)
begin
   TimingViol3[5] = TimingViol3_5;
end


always @(TimingViol3_4)
begin
   TimingViol3[4] = TimingViol3_4;
end


always @(TimingViol3_3)
begin
   TimingViol3[3] = TimingViol3_3;
end


always @(TimingViol3_2)
begin
   TimingViol3[2] = TimingViol3_2;
end


always @(TimingViol3_1)
begin
   TimingViol3[1] = TimingViol3_1;
end


always @(TimingViol3_0)
begin
   TimingViol3[0] = TimingViol3_0;
end




ST_SPHDL_160x32m8_L_main ST_SPHDL_160x32m8_L_maininst ( Q_glitchint,  Q_dataint, Q_gCKint, RY_rfCKint, RY_rrCKint, RY_frCKint, ICRYint, delTBYPASSint, TBYPASS_D_Qint, TBYPASS_mainint, CKint,  CSNint , TBYPASSint, WENint,  Aint, Dint, Mint, debug_level  , TimingViol0, TimingViol1, TimingViol2, TimingViol3, TimingViol4, TimingViol5, TimingViol6, TimingViol7, TimingViol8, TimingViol9, TimingViol10, TimingViol_ttms_ttmh, TimingViol12, TimingViol13      );

ST_SPHDL_160x32m8_L_OPschlr ST_SPHDL_160x32m8_L_OPschlrinst (Qint, RYint,  Q_gCKint, Q_glitchint,  Q_dataint, RY_rfCKint, RY_rrCKint, RY_frCKint, ICRYint, delTBYPASSint, TBYPASS_D_Qint, TBYPASS_mainint  );

defparam ST_SPHDL_160x32m8_L_maininst.Fault_file_name = Fault_file_name;
defparam ST_SPHDL_160x32m8_L_maininst.ConfigFault = ConfigFault;
defparam ST_SPHDL_160x32m8_L_maininst.max_faults = max_faults;
defparam ST_SPHDL_160x32m8_L_maininst.MEM_INITIALIZE = MEM_INITIALIZE;
defparam ST_SPHDL_160x32m8_L_maininst.BinaryInit = BinaryInit;
defparam ST_SPHDL_160x32m8_L_maininst.InitFileName = InitFileName;

endmodule

`endif

`delay_mode_path
`disable_portfaults
`nosuppress_faults
`endcelldefine










/****************************************************************
--  Description         : verilog_model for ST_SPHDL cmos65
--  ModelVersion        : 4.4
--  Date                : Jun, 2008
--  Changes Made by	: DRM
--
****************************************************************/

/******************** START OF HEADER****************************
   This Header Gives Information about the parameters & options present in the Model

   words = 1216
   bits  = 32
   mux   = 16 
   
   bit_write = yes 
   
   
   
   
   

**********************END OF HEADER ******************************/



`ifdef slm
        `define functional
`endif
`celldefine
`suppress_faults
`enable_portfaults
`ifdef functional
   `timescale 1ns / 1ns
   `delay_mode_unit
`endif

`ifdef functional



module ST_SPHDL_1216x32m16_bL (Q, RY,CK, CSN, TBYPASS, WEN, A, D , M   );   
 
    parameter
        Fault_file_name = "ST_SPHDL_1216x32m16_bL_faults.txt",
        ConfigFault = 0,
        max_faults = 20,
        MEM_INITIALIZE  = 1'b0,
        BinaryInit = 1'b0,
        InitFileName = "ST_SPHDL_1216x32m16_bL.cde",
        Corruption_Read_Violation = 1,
        Debug_mode = "all_warning_mode",
        InstancePath = "ST_SPHDL_1216x32m16_bL";
    
    parameter
        Words = 1216,
        Bits = 32,
        Addr = 11,
        mux = 16,
        Rows = Words/mux;




   


    parameter
        WordX = 32'bx,
        AddrX = 11'bx,
        Word0 = 32'b0,
        X = 1'bx;


	output [Bits-1 : 0] Q;
        
        output RY;   
        
        input [Bits-1 : 0] D;
	input [Addr-1 : 0] A;
	
        input [Bits-1:0] M;         
        input CK, CSN, TBYPASS, WEN;

        
        
        

        



        reg [Bits-1 : 0] Qint;
         
           
	wire [Bits-1 : 0] Dint,Mint;
        
        wire [Addr-1 : 0] Aint;
	wire CKint;
	wire CSNint;
	wire WENint;

        
        	
        wire TBYPASSint;
        

        
        wire RYint;
          
          
           buf (RY, RYint);  
         
        reg RY_outreg, RY_out;
           
        assign RYint = RY_out;

        
        
        
        // REG DECLARATION
        
	//Output Register for tbypass
        reg [Bits-1 : 0] tbydata;
        //delayed Output Register
        reg [Bits-1 : 0] delOutReg_data;
        reg [Bits-1 : 0] OutReg_data;   // Data Output register
	reg [Bits-1 : 0] tempMem;
	reg lastCK;
        reg CSNreg;	

        `ifdef slm
        `else
	reg [Bits-1 : 0] Mem [Words-1 : 0]; // RAM array
        `endif
	
	reg [Bits-1 :0] Mem_temp;
	reg ValidAddress;
	reg ValidDebugCode;
        

        
        reg WENreg;
        
        reg [1:0] debug_level;
        reg [8*10: 0] operating_mode;
        reg [8*44: 0] message_status;

        integer d, a, p, i, k, j, l;
        `ifdef slm
           integer MemAddr;
        `endif


        //************************************************************
        //****** CONFIG FAULT IMPLEMENTATION VARIABLES*************** 
        //************************************************************ 

        integer file_ptr, ret_val;
        integer fault_word;
        integer fault_bit;
        integer fcnt, Fault_in_memory;
        integer n, cnt, t;  
        integer FailureLocn [max_faults -1 :0];

        reg [100 : 0] stuck_at;
        reg [200 : 0] tempStr;
        reg [7:0] fault_char;
        reg [7:0] fault_char1; // 8 Bit File Pointer
        reg [Addr -1 : 0] std_fault_word;
        reg [max_faults -1 :0] fault_repair_flag;
        reg [max_faults -1 :0] repair_flag;
        reg [Bits - 1: 0] stuck_at_0fault [max_faults -1 : 0];
        reg [Bits - 1: 0] stuck_at_1fault [max_faults -1 : 0];
        reg [100 : 0] array_stuck_at[max_faults -1 : 0] ; 
        reg msgcnt;
        

        reg [Bits -1 : 0] stuck0;
        reg [Bits -1 : 0] stuck1;

        `ifdef slm
        reg [Bits -1 : 0] slm_temp_data;
        `endif
        

        integer flag_error;

        
          
          buf bufq [Bits-1:0] (Q,Qint);
        
        
        buf bufdata [Bits-1:0] (Dint,D);
        buf bufaddr [Addr-1:0] (Aint,A);
        
        buf bufmask [Bits-1:0] (Mint,M);
        
	buf (TBYPASSint, TBYPASS);
	buf (CKint, CK);
	
        //MEM_EN = CSN or  TBYPASS
        
        or (CSNint, CSN, TBYPASS);   
	
        buf (WENint, WEN);
        
        
        
        

        

// BEHAVIOURAL MODULE DESCRIPTION

task WriteMemX;
begin
   `ifdef slm
   $slm_ResetMemory(MemAddr, WordX);
   `else
    for (i = 0; i < Words; i = i + 1)
       Mem[i] = WordX;
   `endif        
end
endtask


task WriteOutX;                
begin
   OutReg_data= WordX;
end
endtask

task WriteCycle;                  
input [Addr-1 : 0] Address;
reg [Bits-1:0] tempReg1,tempReg2;
integer po,i;
begin

   tempReg1 = WordX;
   if (^Address !== X) begin
      if (ValidAddress) begin
      `ifdef slm
         $slm_ReadMemoryS(MemAddr, Address, tempReg1);
      `else
         tempReg1 = Mem[Address];
      `endif
            
         for (po=0;po<Bits;po=po+1) begin
            if (Mint[po] === 1'b0)
               tempReg1[po] = Dint[po];
            else if ((Mint[po] !== 1'b1) && (tempReg1[po] !== Dint[po]))
               tempReg1[po] = 1'bx;
         end                
      `ifdef slm
         $slm_WriteMemory(MemAddr, Address, tempReg1);
      `else
         Mem[Address] = tempReg1;
      `endif
      end//if (ValidAddress)
      else
         if(debug_level < 2) $display("%m - %t (MSG_ID 701) WARNING: Address Out Of Range. ",$realtime); 
   end //if (^Address !== X)
   else
   begin
      if(debug_level < 2) $display("%m - %t (MSG_ID 008) WARNING: Illegal Value on Address Bus. Memory Corrupted ",$realtime);
      WriteMemX;
   end
 end

endtask

task ReadCycle;
input [Addr-1 : 0] Address;
reg [Bits-1:0] MemData;
integer a;
begin
   if (ValidAddress)
   begin        
      `ifdef slm
       $slm_ReadMemory(MemAddr, Address, MemData);
      `else
      MemData = Mem[Address];
      `endif
   end //if (ValidAddress)  
                
   if(ValidAddress === X)
   begin
      if (Corruption_Read_Violation === 1)
      begin   
         if(debug_level < 2) $display("%m - %t (MSG_ID 008) WARNING: Illegal Value on Address Bus. Memory and Output Corrupted ",$realtime);
         WriteMemX;
      end
      else
         if(debug_level < 2) $display("%m - %t (MSG_ID 008) WARNING: Illegal Value on Address Bus. Output Corrupted ",$realtime);
      MemData = WordX;
   end                        
   else if (ValidAddress === 0)
   begin                        
      if(debug_level < 2) $display("%m - %t (MSG_ID 701) WARNING: Address Out Of Range. Output Corrupted ",$realtime); 
      MemData = WordX;
   end
   
   OutReg_data = MemData;
end
endtask

task wen_x_handler;
input [Addr-1 : 0] Address;
input [Bits-1 : 0] Mask;
reg [Bits-1 : 0] prev_data;
begin
   if(^Address !== X) begin
      if (Address < Words) begin
      `ifdef slm
         $slm_ReadMemoryS(MemAddr, Address, tempMem);
      `else
         tempMem = Mem[Address];
      `endif
         prev_data = tempMem;  
         for (j = 0;j< Bits; j=j+1) begin
            //calculating data to write in memory
            if (tempMem[j] !== Dint[j]) begin
               if (Mask[j] !== 1'b1) begin
                  tempMem[j] = 1'bx;
               end
            end
            //calculating data to write on output
            if (prev_data[j] !== OutReg_data[j]) begin
               OutReg_data[j]  = 1'bx;
            end
         end//for (j = 0;j< Bits;
      end
      else begin
         WriteOutX;
      end   
   end  //  if(^Address !== X)
   else begin
      WriteMemX;
      WriteOutX;
   end  //else  
`ifdef slm
   $slm_WriteMemory(MemAddr, Address, tempMem);
`else
   Mem[Address] = tempMem;
`endif
end
endtask
        

task task_insert_faults_in_memory;
begin
   Fault_in_memory = 1;
   for(i = 0;i< fcnt;i = i+ 1)
   begin
      if (fault_repair_flag[i] !== 1)
      begin
         Fault_in_memory = 0;
         if (array_stuck_at[i] === "sa0")
         begin
            `ifdef slm
            //Read first
            $slm_ReadMemoryS(MemAddr, FailureLocn[i], slm_temp_data);
            //operation
            slm_temp_data = slm_temp_data & stuck_at_0fault[i];
            //write back
            $slm_WriteMemoryS(MemAddr, FailureLocn[i], slm_temp_data);
            `else
            Mem[FailureLocn[i]] = Mem[FailureLocn[i]] & stuck_at_0fault[i];
            `endif
         end //if(array_stuck_at)
                                        
         if(array_stuck_at[i] === "sa1")
         begin
            `ifdef slm
            //Read first
            $slm_ReadMemoryS(MemAddr, FailureLocn[i], slm_temp_data);
            //operation
            slm_temp_data = slm_temp_data | stuck_at_1fault[i];
            //write back
            $slm_WriteMemoryS(MemAddr, FailureLocn[i], slm_temp_data);
            `else
            Mem[FailureLocn[i]] = Mem[FailureLocn[i]] | stuck_at_1fault[i]; 
            `endif
         end //if(array_stuck_at)
      end//if (fault_repair_flag
   end// for loop...
end
endtask






initial
begin
   // Define format for timing value
  $timeformat (-9, 2, " ns", 0);
  `ifdef slm
  $slm_RegisterMemory(MemAddr, Words, Bits);
  `endif   
  
  debug_level= 2'b0;
   message_status = "All Messages are Switched ON";
  `ifdef  NO_WARNING_MODE
     debug_level = 2'b10;
     message_status = "All Warning Messages are Switched OFF";
  `endif  
  `ifdef slm
     operating_mode = "SLM";
  `else
     operating_mode = "FUNCTIONAL";
  `endif
if(debug_level !== 2'b10) begin
  $display ("%mINFORMATION ");
  $display ("***************************************");
  $display ("The Model is Operating in %s MODE", operating_mode);
  $display ("%s", message_status);
  if(ConfigFault)
  $display ("Configurable Fault Functionality is ON");   
  else
  $display ("Configurable Fault Functionality is OFF");  
   
  $display ("***************************************");
end
  if (MEM_INITIALIZE === 1'b1)
  begin   
     `ifdef slm
        if (BinaryInit)
           $slm_LoadMemory(MemAddr, InitFileName, "VERILOG_BIN");
        else
           $slm_LoadMemory(MemAddr, InitFileName, "VERILOG_HEX");

     `else
        if (BinaryInit)
           $readmemb(InitFileName, Mem, 0, Words-1);
        else
           $readmemh(InitFileName, Mem, 0, Words-1);
     `endif
  end

  
  RY_out = 1'b1;


        
/*  -----------Implemetation for config fault starts------*/
   msgcnt = X;
   t = 0;
   fault_repair_flag = {max_faults{1'b1}};
   repair_flag = {max_faults{1'b1}};
   if(ConfigFault) 
   begin
        file_ptr = $fopen(Fault_file_name , "r");
        if(file_ptr == 0)
        begin     
          if(debug_level < 3) $display("%m - %t (MSG_ID 201) FAILURE: File cannot be opened ",$realtime);      
        end        
      else                
      begin : read_fault_file
      t = 0;
      for (i = 0; i< max_faults; i= i + 1)
      begin
         
         stuck0 = {Bits{1'b1}};
         stuck1 = {Bits{1'b0}};
         fault_char1 = $fgetc (file_ptr);
         if (fault_char1 == 8'b11111111)
                 disable read_fault_file;
         ret_val = $ungetc (fault_char1, file_ptr);
         ret_val = $fgets(tempStr, file_ptr);
         ret_val = $sscanf(tempStr, "%d %d %s",fault_word, fault_bit, stuck_at) ;
        flag_error = 0; 
         if(ret_val !== 0)
            begin         
               if(ret_val == 2 || ret_val == 3)
               begin
                  if(ret_val == 2)
                      stuck_at = "sa0";

                  if(stuck_at !== "sa0" && stuck_at !== "sa1" && stuck_at !== "none")
                  begin
                      if(debug_level < 2) $display("%m - %t (MSG_ID 203) WARNING: Wrong value for stuck at in fault file ",$realtime);
                      flag_error = 1;
                  end    
                      
                  if(fault_word > Words-1)
                  begin
                      if(debug_level < 2) $display("%m - %t (MSG_ID 206) WARNING: Address out of range in fault file ",$realtime);
                      flag_error = 1;
                  end    

                  if(fault_bit > Bits)
                  begin  
                      if(debug_level < 2) $display("%m - %t (MSG_ID 205) WARNING: Faulty bit out of range in fault file ",$realtime);
                      flag_error = 1;
                  end    

                  if(flag_error == 0)
                  //Correct Inputs
                  begin
                      if(stuck_at === "none")
                      begin
                         if(debug_level < 2) $display("%m - %t (MSG_ID 202) WARNING: No fault injected, empty fault file ",$realtime);
                      end
                      else
                      //Adding the faults
                      begin
                         FailureLocn[t] = fault_word;
                         std_fault_word = fault_word;
                         
                         fault_repair_flag[t] = 1'b0;
                         if (stuck_at === "sa0" )
                         begin
                            stuck0[fault_bit] = 1'b0;         
                            stuck_at_0fault[t] = stuck0;
                         end     
                         if (stuck_at === "sa1" )
                         begin
                            stuck1[fault_bit] = 1'b1;
                            stuck_at_1fault[t] = stuck1; 
                         end

                         array_stuck_at[t] = stuck_at;
                         t = t + 1;
                      end //if(stuck_at === "none")  
                  end //if(flag_error == 0)
               end //if(ret_val == 2 || ret_val == 3 
               else
               //wrong number of arguments
               begin
                  if(debug_level < 2)
                  $display("%m - %t WARNING :  WRONG VALUES ENTERED FOR FAULTY WORD OR FAULTY BIT OR STUCK_AT IN Fault_file_name", $realtime);
                  flag_error = 1;
               end
             end //if(ret_val !== 0)
             else
             begin
                 if(debug_level < 2) $display("%m - %t (MSG_ID 202) WARNING: No fault injected, empty fault file ",$realtime);
             end    
      end //for (i = 0; i< m
      end //begin: read_fault_file  
      $fclose (file_ptr);

      fcnt = t;
      
      //fault injection at time 0.
      task_insert_faults_in_memory;
      
   end // config_fault 
end// initial



//+++++++++++++++++++++++++++++++ CONFIG FAULT IMPLEMETATION ENDS+++++++++++++++++++++++++++++++//
        
always @(CKint)
begin
   if(CKint === 1'b1 && lastCK === 1'b0)
      CSNreg = CSNint;
   
   if(CKint === 1'b1 && lastCK === 1'b0 && CSNint === 1'b0) begin
      WENreg = WENint;
      if (^Aint === X)
         ValidAddress = X;
      else if (Aint < Words)
         ValidAddress = 1;
      else    
         ValidAddress = 0;

      if (ValidAddress)
      `ifdef slm
         $slm_ReadMemoryS(MemAddr, Aint, Mem_temp);
      `else        
         Mem_temp = Mem[Aint];
      `endif       
      else
         Mem_temp = WordX; 
         
      /*---------------------- Normal Read and Write -----------------*/
      
         RY_outreg = ~CKint;
         if (WENint === 1) begin
            ReadCycle(Aint);
         end
         else if (WENint === 0) begin
            WriteCycle(Aint);
         end
         else if (WENint === X) begin
            // Uncertain write cycle
            if (^Aint === X) begin
               WriteOutX;
               WriteMemX;
            end
            else
              wen_x_handler(Aint,Mint);
         end                 
            
      
   end // if(CKint === 1'b1...)
   // Unknown Clock Behaviour or unknown control signal
   else if((CKint === 1'b1 && CSNint === 1'bx) || (CKint === 1'bx && CSNreg !== 1'b1)) begin
      WriteOutX;
      WriteMemX;
       
      RY_out = 1'bX;
      if(CKint === 1'bx && CSNreg !== 1'b1) begin
         if(debug_level < 2) $display("%m - %t (MSG_ID 003) WARNING: Illegal Value on Clock. Memory and Output Corrupted ",$realtime);
      end
      else begin
         if(debug_level < 2) $display("%m - %t (MSG_ID 010) WARNING: Invalid control signal (chip select / memory bypass) Memory and Output Corrupted ",$realtime);
      end
   end
             
   

   if(ConfigFault) begin
      task_insert_faults_in_memory;
   
   end//if(ConfigFault)

   
   lastCK = CKint;
end // always @(CKint)
        
always @(CSNint)
begin

// Unknown Clock & CSN signal
   if (CSNint !== 1 && CKint === 1'bx)
   begin
      if(debug_level < 2) $display("%m - %t (MSG_ID 010) WARNING: Invalid control signal (chip select / memory bypass) Memory and Output Corrupted ",$realtime);
      WriteMemX;
      WriteOutX;
      
      RY_out = 1'bX;
   end

end

  



//TBYPASS functionality
always @(TBYPASSint)
begin
 
   
   delOutReg_data = WordX;
   OutReg_data = WordX;
   if(TBYPASSint !== 1'b0) begin        
      if(TBYPASSint === 1'b1) 
         tbydata = Dint;
      else
         tbydata = WordX;
   end        
   else                         // TBYPASSint = 0
   begin        
      Qint = WordX;
        // tbydata holds no relevance when tbypass is inactive
   end        


end //end of always TBYPASSint

always @(Dint)
begin

   
   if(TBYPASSint === 1'b1)
      tbydata = Dint;

   
end //end of always Dint

//assign output data
always @(OutReg_data)
   #1 delOutReg_data = OutReg_data;

always @(delOutReg_data or tbydata or TBYPASSint ) begin

if(TBYPASSint === 1'bX )
      Qint = WordX;
else if (TBYPASSint === 1'b1 )
      Qint = tbydata;    
else
      
      Qint = delOutReg_data;

end


always @(TBYPASSint)
begin
   if(TBYPASSint !== 1'b0)
    RY_outreg = 1'bx;
end

always @(negedge CKint)
begin

   
   if((TBYPASSint === 1'b0) && (CSNreg === 1'b0) && RY_out !== 1'bx)
    RY_outreg = ~CKint;


end

always @(RY_outreg)
begin
  #1 RY_out = RY_outreg;
end




 
// Power down functionality for verilog_model



endmodule

`else

`timescale 1ns / 1ps
`delay_mode_path


module ST_SPHDL_1216x32m16_bL_main ( Q_glitch,  Q_data, Q_gCK, RY_rfCK, RY_rrCK, RY_frCK, ICRY, delTBYPASS, TBYPASS_D_Q, TBYPASS_main, CK,  CSN, TBYPASS, WEN,  A, D, M,debug_level ,TimingViol0, TimingViol1, TimingViol2, TimingViol3, TimingViol4, TimingViol5, TimingViol6, TimingViol7, TimingViol8, TimingViol9, TimingViol10, TimingViol_ttms_ttmh, TimingViol12, TimingViol13     );
    
   parameter
        Fault_file_name = "ST_SPHDL_1216x32m16_bL_faults.txt",
        ConfigFault = 0,
        max_faults = 20,
        MEM_INITIALIZE  = 1'b0,
        BinaryInit = 1'b0,
        InitFileName = "ST_SPHDL_1216x32m16_bL.cde",
        Debug_mode = "ALL_WARNING_MODE",
        InstancePath = "ST_SPHDL_1216x32m16_bL";

   parameter
        Words = 1216,
        Bits = 32,
        Addr = 11,
        mux = 16,
        Rows = Words/mux;


       

   


    parameter
        WordX = 32'bx,
        AddrX = 11'bx,
        X = 1'bx;

	output [Bits-1 : 0] Q_glitch;
	output [Bits-1 : 0] Q_data;
	output [Bits-1 : 0] Q_gCK;
        
        output ICRY;
        output RY_rfCK;
	output RY_rrCK;
	output RY_frCK;   
	output [Bits-1 : 0] delTBYPASS; 
	output TBYPASS_main; 
        output [Bits-1 : 0] TBYPASS_D_Q;
        
        input [Bits-1 : 0] D, M;
	input [Addr-1 : 0] A;
	input CK, CSN, TBYPASS, WEN;
        input [1 : 0] debug_level;

	input [Bits-1 : 0] TimingViol2, TimingViol3, TimingViol12, TimingViol13;
	input TimingViol0, TimingViol1, TimingViol4, TimingViol5, TimingViol6, TimingViol7, TimingViol8, TimingViol9, TimingViol10, TimingViol_ttms_ttmh;

        
        
        
       
        
        
        

	wire [Bits-1 : 0] Dint,Mint;
	wire [Addr-1 : 0] Aint;
	wire CKint;
	wire CSNint;
	wire WENint;
        
        






	wire  Mreg_0;
	wire  Mreg_1;
	wire  Mreg_2;
	wire  Mreg_3;
	wire  Mreg_4;
	wire  Mreg_5;
	wire  Mreg_6;
	wire  Mreg_7;
	wire  Mreg_8;
	wire  Mreg_9;
	wire  Mreg_10;
	wire  Mreg_11;
	wire  Mreg_12;
	wire  Mreg_13;
	wire  Mreg_14;
	wire  Mreg_15;
	wire  Mreg_16;
	wire  Mreg_17;
	wire  Mreg_18;
	wire  Mreg_19;
	wire  Mreg_20;
	wire  Mreg_21;
	wire  Mreg_22;
	wire  Mreg_23;
	wire  Mreg_24;
	wire  Mreg_25;
	wire  Mreg_26;
	wire  Mreg_27;
	wire  Mreg_28;
	wire  Mreg_29;
	wire  Mreg_30;
	wire  Mreg_31;
	
	reg [Bits-1 : 0] OutReg_glitch; // Glitch Output register
        reg [Bits-1 : 0] OutReg_data;   // Data Output register
	reg [Bits-1 : 0] Dreg,Mreg;
	reg [Bits-1 : 0] Mreg_temp;
	reg [Bits-1 : 0] tempMem;
	reg [Bits-1 : 0] prevMem;
	reg [Addr-1 : 0] Areg;
	reg [Bits-1 : 0] Q_gCKreg; 
	reg [Bits-1 : 0] lastQ_gCK;
	reg [Bits-1 : 0] last_Qdata;
	reg lastCK, CKreg;
	reg CSNreg;
	reg WENreg;
        
        reg [Bits-1 : 0] TimingViol2_last,TimingViol3_last;
        reg [Bits-1 : 0] TimingViol12_last,TimingViol13_last;
	
	reg [Bits-1 : 0] Mem [Words-1 : 0]; // RAM array
	
	reg [Bits-1 :0] Mem_temp;
	reg ValidAddress;
	reg ValidDebugCode;

	reg ICGFlag;
           
        reg Operation_Flag;
	

        
        reg [Bits-1:0] Mem_Red [2*mux-1:0];
        
        integer d, a, p, i, k, j, l;

        //************************************************************
        //****** CONFIG FAULT IMPLEMENTATION VARIABLES*************** 
        //************************************************************ 

        integer file_ptr, ret_val;
        integer fault_word;
        integer fault_bit;
        integer fcnt, Fault_in_memory;
        integer n, cnt, t;  
        integer FailureLocn [max_faults -1 :0];

        reg [100 : 0] stuck_at;
        reg [200 : 0] tempStr;
        reg [7:0] fault_char;
        reg [7:0] fault_char1; // 8 Bit File Pointer
        reg [Addr -1 : 0] std_fault_word;
        reg [max_faults -1 :0] fault_repair_flag;
        reg [max_faults -1 :0] repair_flag;
        reg [Bits - 1: 0] stuck_at_0fault [max_faults -1 : 0];
        reg [Bits - 1: 0] stuck_at_1fault [max_faults -1 : 0];
        reg [100 : 0] array_stuck_at[max_faults -1 : 0] ; 
        reg msgcnt;
        

        reg [Bits -1 : 0] stuck0;
        reg [Bits -1 : 0] stuck1;
        integer flag_error;

	assign Mreg_0 = Mreg[0];
	assign Mreg_1 = Mreg[1];
	assign Mreg_2 = Mreg[2];
	assign Mreg_3 = Mreg[3];
	assign Mreg_4 = Mreg[4];
	assign Mreg_5 = Mreg[5];
	assign Mreg_6 = Mreg[6];
	assign Mreg_7 = Mreg[7];
	assign Mreg_8 = Mreg[8];
	assign Mreg_9 = Mreg[9];
	assign Mreg_10 = Mreg[10];
	assign Mreg_11 = Mreg[11];
	assign Mreg_12 = Mreg[12];
	assign Mreg_13 = Mreg[13];
	assign Mreg_14 = Mreg[14];
	assign Mreg_15 = Mreg[15];
	assign Mreg_16 = Mreg[16];
	assign Mreg_17 = Mreg[17];
	assign Mreg_18 = Mreg[18];
	assign Mreg_19 = Mreg[19];
	assign Mreg_20 = Mreg[20];
	assign Mreg_21 = Mreg[21];
	assign Mreg_22 = Mreg[22];
	assign Mreg_23 = Mreg[23];
	assign Mreg_24 = Mreg[24];
	assign Mreg_25 = Mreg[25];
	assign Mreg_26 = Mreg[26];
	assign Mreg_27 = Mreg[27];
	assign Mreg_28 = Mreg[28];
	assign Mreg_29 = Mreg[29];
	assign Mreg_30 = Mreg[30];
	assign Mreg_31 = Mreg[31];
        buf bufdint [Bits-1:0] (Dint, D);
        buf bufmint [Bits-1:0] (Mint, M);
        buf bufaint [Addr-1:0] (Aint, A);
	
	buf (TBYPASS_main, TBYPASS);
	buf (CKint, CK);
        
        buf (CSNint, CSN);    
	buf (WENint, WEN);

        //TBYPASS functionality
        
        buf bufdeltb [Bits-1:0] (delTBYPASS, TBYPASS);
          
        
        
        buf buftbdq [Bits-1:0] (TBYPASS_D_Q, D );
         
        
        
        







        wire RY_rfCKint, RY_rrCKint, RY_frCKint, ICRYFlagint;
        reg RY_rfCKreg, RY_rrCKreg, RY_frCKreg; 
	reg InitialRYFlag, ICRYFlag;

        
        buf (RY_rfCK, RY_rfCKint);
	buf (RY_rrCK, RY_rrCKint);
	buf (RY_frCK, RY_frCKint);
        buf (ICRY, ICRYFlagint);
        assign ICRYFlagint = ICRYFlag;
        
        

    specify
        specparam

            tdq = 0.01,
            ttmq = 0.01,
            
            taa_ry = 0.01,
            th_ry = 0.009,
            tck_ry = 0.01,
            taa = 1.00,
            th = 0.009;
        /*-------------------- Propagation Delays ------------------*/

   
	if (WENreg && !ICGFlag) (CK *> (Q_data[0] : D[0])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[1] : D[1])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[2] : D[2])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[3] : D[3])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[4] : D[4])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[5] : D[5])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[6] : D[6])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[7] : D[7])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[8] : D[8])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[9] : D[9])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[10] : D[10])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[11] : D[11])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[12] : D[12])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[13] : D[13])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[14] : D[14])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[15] : D[15])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[16] : D[16])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[17] : D[17])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[18] : D[18])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[19] : D[19])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[20] : D[20])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[21] : D[21])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[22] : D[22])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[23] : D[23])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[24] : D[24])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[25] : D[25])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[26] : D[26])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[27] : D[27])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[28] : D[28])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[29] : D[29])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[30] : D[30])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[31] : D[31])) = (taa, taa); 
   

	if (!ICGFlag) (CK *> (Q_glitch[0] : D[0])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[1] : D[1])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[2] : D[2])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[3] : D[3])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[4] : D[4])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[5] : D[5])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[6] : D[6])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[7] : D[7])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[8] : D[8])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[9] : D[9])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[10] : D[10])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[11] : D[11])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[12] : D[12])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[13] : D[13])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[14] : D[14])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[15] : D[15])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[16] : D[16])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[17] : D[17])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[18] : D[18])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[19] : D[19])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[20] : D[20])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[21] : D[21])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[22] : D[22])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[23] : D[23])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[24] : D[24])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[25] : D[25])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[26] : D[26])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[27] : D[27])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[28] : D[28])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[29] : D[29])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[30] : D[30])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[31] : D[31])) = (th, th);

	if (!ICGFlag) (CK *> (Q_gCK[0] : D[0])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[1] : D[1])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[2] : D[2])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[3] : D[3])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[4] : D[4])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[5] : D[5])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[6] : D[6])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[7] : D[7])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[8] : D[8])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[9] : D[9])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[10] : D[10])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[11] : D[11])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[12] : D[12])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[13] : D[13])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[14] : D[14])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[15] : D[15])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[16] : D[16])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[17] : D[17])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[18] : D[18])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[19] : D[19])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[20] : D[20])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[21] : D[21])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[22] : D[22])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[23] : D[23])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[24] : D[24])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[25] : D[25])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[26] : D[26])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[27] : D[27])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[28] : D[28])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[29] : D[29])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[30] : D[30])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[31] : D[31])) = (th, th);

	if (!TBYPASS) (TBYPASS *> delTBYPASS[0]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[1]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[2]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[3]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[4]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[5]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[6]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[7]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[8]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[9]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[10]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[11]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[12]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[13]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[14]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[15]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[16]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[17]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[18]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[19]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[20]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[21]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[22]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[23]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[24]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[25]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[26]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[27]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[28]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[29]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[30]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[31]) = (0);
	if (TBYPASS) (TBYPASS *> delTBYPASS[0]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[1]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[2]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[3]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[4]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[5]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[6]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[7]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[8]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[9]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[10]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[11]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[12]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[13]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[14]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[15]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[16]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[17]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[18]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[19]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[20]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[21]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[22]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[23]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[24]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[25]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[26]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[27]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[28]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[29]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[30]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[31]) = (ttmq);
      (D[0] *> TBYPASS_D_Q[0]) = (tdq, tdq);
      (D[1] *> TBYPASS_D_Q[1]) = (tdq, tdq);
      (D[2] *> TBYPASS_D_Q[2]) = (tdq, tdq);
      (D[3] *> TBYPASS_D_Q[3]) = (tdq, tdq);
      (D[4] *> TBYPASS_D_Q[4]) = (tdq, tdq);
      (D[5] *> TBYPASS_D_Q[5]) = (tdq, tdq);
      (D[6] *> TBYPASS_D_Q[6]) = (tdq, tdq);
      (D[7] *> TBYPASS_D_Q[7]) = (tdq, tdq);
      (D[8] *> TBYPASS_D_Q[8]) = (tdq, tdq);
      (D[9] *> TBYPASS_D_Q[9]) = (tdq, tdq);
      (D[10] *> TBYPASS_D_Q[10]) = (tdq, tdq);
      (D[11] *> TBYPASS_D_Q[11]) = (tdq, tdq);
      (D[12] *> TBYPASS_D_Q[12]) = (tdq, tdq);
      (D[13] *> TBYPASS_D_Q[13]) = (tdq, tdq);
      (D[14] *> TBYPASS_D_Q[14]) = (tdq, tdq);
      (D[15] *> TBYPASS_D_Q[15]) = (tdq, tdq);
      (D[16] *> TBYPASS_D_Q[16]) = (tdq, tdq);
      (D[17] *> TBYPASS_D_Q[17]) = (tdq, tdq);
      (D[18] *> TBYPASS_D_Q[18]) = (tdq, tdq);
      (D[19] *> TBYPASS_D_Q[19]) = (tdq, tdq);
      (D[20] *> TBYPASS_D_Q[20]) = (tdq, tdq);
      (D[21] *> TBYPASS_D_Q[21]) = (tdq, tdq);
      (D[22] *> TBYPASS_D_Q[22]) = (tdq, tdq);
      (D[23] *> TBYPASS_D_Q[23]) = (tdq, tdq);
      (D[24] *> TBYPASS_D_Q[24]) = (tdq, tdq);
      (D[25] *> TBYPASS_D_Q[25]) = (tdq, tdq);
      (D[26] *> TBYPASS_D_Q[26]) = (tdq, tdq);
      (D[27] *> TBYPASS_D_Q[27]) = (tdq, tdq);
      (D[28] *> TBYPASS_D_Q[28]) = (tdq, tdq);
      (D[29] *> TBYPASS_D_Q[29]) = (tdq, tdq);
      (D[30] *> TBYPASS_D_Q[30]) = (tdq, tdq);
      (D[31] *> TBYPASS_D_Q[31]) = (tdq, tdq);


        // RY functionality
	if (!ICRYFlag && InitialRYFlag) (CK *> RY_rfCK) = (th_ry, th_ry);

        if (!ICRYFlag && InitialRYFlag) (CK *> RY_rrCK) = (taa_ry, taa_ry); 
	if (!ICRYFlag && InitialRYFlag) (CK *> RY_frCK) = (tck_ry, tck_ry);   

	endspecify


assign #0 Q_data = OutReg_data;
assign Q_glitch = OutReg_glitch;
assign Q_gCK = Q_gCKreg;




    // BEHAVIOURAL MODULE DESCRIPTION

task chstate;
   input [Bits-1 : 0] clkin;
   output [Bits-1 : 0] clkout;
   integer d;
begin
   if ( $realtime != 0 )
      for (d = 0; d < Bits; d = d + 1)
      begin
         if (clkin[d] === 1'b0)
            clkout[d] = 1'b1;
         else if (clkin[d] === 1'b1)
            clkout[d] = 1'bx;
         else
            clkout[d] = 1'b0;
      end
end
endtask


task task_insert_faults_in_memory;
begin
   Fault_in_memory = 1;
   for(i = 0;i< fcnt;i = i+ 1)
   begin
     if (fault_repair_flag[i] !== 1)
     begin
       Fault_in_memory = 0;
       if (array_stuck_at[i] === "sa0")
       begin
          Mem[FailureLocn[i]] = Mem[FailureLocn[i]] & stuck_at_0fault[i];
       end //if(array_stuck_at)
                                              
       if(array_stuck_at[i] === "sa1")
       begin
         Mem[FailureLocn[i]] = Mem[FailureLocn[i]] | stuck_at_1fault[i]; 
       end //if(array_stuck_at)
     end//if (fault_repair_flag
   end// for loop...
end
endtask



task WriteMemX;
begin
    for (i = 0; i < Words; i = i + 1)
       Mem[i] = WordX;
end
endtask

task WriteLocX;
   input [Addr-1 : 0] Address;
begin
   if (^Address !== X)
       Mem[Address] = WordX;
   else
      WriteMemX;
end
endtask

task WriteLocMskX;
  input [Addr-1 : 0] Address;
  input [Bits-1 : 0] Mask;
  input [Bits-1 : 0] prevMem;
  reg [Bits-1 : 0] Outdata;
begin
  if (^Address !== X)
  begin
      tempMem = Mem[Address];
     for (j = 0;j< Bits; j=j+1)
     begin
        if (prevMem[j] !== Dreg[j]) 
        begin
           if (Mask[j] !== 1'b1)
              tempMem[j] = 1'bx;
        end
     end//for (j = 0;j< Bi

     Mem[Address] = tempMem;
  end//if (^Address !== X
  else
     WriteMemX;
end
endtask

task WriteLocMskX_bwise;
   input [Addr-1 : 0] Address;
   input [Bits-1 : 0] Mask;
begin
   if (^Address !== X)
   begin
      tempMem = Mem[Address];
             
      for (j = 0;j< Bits; j=j+1)
         if (Mask[j] === 1'bx)
            tempMem[j] = 1'bx;
                    
      Mem[Address] = tempMem;

   end//if (^Address !== X
   else
      WriteMemX;
end
endtask
    
task WriteOutX;                
begin
   OutReg_data= WordX;
   OutReg_glitch= WordX;
end
endtask

task WriteOutX_bwise;
   input [Bits-1 : 0] flag;
   input [Bits-1 : 0] Delayedflag;
   input [Addr-1 : 0] Address;
   reg [Bits-1 : 0] MemData;
begin
    MemData = Mem[Address];
        
   for ( l = 0; l < Bits; l = l + 1 )
      if (Delayedflag[l] !== flag[l] && MemData[l] === 1'bx)
      begin
         OutReg_data[l] = 1'bx;
	 OutReg_glitch[l] = 1'bx;
      end
end
endtask

task WriteOut;
begin
   for (i = 0;i < Bits; i = i+1)
   begin        
   
      if (last_Qdata[i] !== Mem_temp[i])     
      begin
         OutReg_data[i] = 1'bX;
         OutReg_glitch[i] = 1'bX;
      end
      else
         OutReg_glitch[i] = OutReg_data[i];
   end   
end
endtask  

task WriteCycle;                  
   input [Addr-1 : 0] Address;
   reg [Bits-1:0] tempReg1,tempReg2;
   integer po,i;
begin

   tempReg1 = WordX;
   if (^Address !== X)
   begin
      if (ValidAddress)
      begin
         
                 tempReg1 = Mem[Address];
                 for (po=0;po<Bits;po=po+1)
                 if (Mreg[po] === 1'b0)
                       tempReg1[po] = Dreg[po];
                 else if ((Mreg[po] !== 1'b1) && (tempReg1[po] !== Dreg[po]))
                       tempReg1[po] = 1'bx;
                        
                 Mem[Address] = tempReg1;
                    
      end //if (ValidAddress)
      else
         if(debug_level < 2) $display("%m - %t (MSG_ID 701) WARNING: Write Port:  Address Out Of Range. ",$realtime);
   end//if (^Address !== X)
   else
   begin
      if(debug_level < 2) $display("%m - %t (MSG_ID 008) WARNING: Write Port:  Illegal Value on Address Bus. Memory Corrupted ",$realtime);
      WriteMemX;
   end
 end

endtask

task ReadCycle;
   input [Addr-1 : 0] Address;
   reg [Bits-1:0] MemData;
   integer a;
begin

   if (ValidAddress)
      MemData = Mem[Address];

   if(ValidAddress === X)
   begin
      if(debug_level < 2) $display("%m - %t (MSG_ID 008) WARNING: Read Port:  Illegal Value on Address Bus. Memory and Output Corrupted ",$realtime);
      WriteMemX;
      MemData = WordX;
   end                        
   else if (ValidAddress === 0)
   begin                        
      if(debug_level < 2) $display("%m - %t (MSG_ID 701) WARNING: Read Port:  Address Out Of Range. Output Corrupted ",$realtime);
      MemData = WordX;
   end

   for (a = 0; a < Bits; a = a + 1)
   begin
      if (MemData[a] !== OutReg_data[a])
         OutReg_glitch[a] = WordX[a];
      else
         OutReg_glitch[a] = MemData[a];
   end//for (a = 0; a <

   OutReg_data = MemData;
   Operation_Flag = 1;
   last_Qdata = Q_data;

end
endtask




assign RY_rfCKint = RY_rfCKreg;
assign RY_frCKint = RY_frCKreg;
assign RY_rrCKint = RY_rrCKreg;

// Define format for timing value
initial
begin
  $timeformat (-9, 2, " ns", 0);
  ICGFlag = 0;
  if (MEM_INITIALIZE === 1'b1)
  begin   
     if (BinaryInit)
        $readmemb(InitFileName, Mem, 0, Words-1);
     else
        $readmemh(InitFileName, Mem, 0, Words-1);
  end

  
  ICRYFlag = 1;
  InitialRYFlag = 0;
  ICRYFlag <= 0;
  RY_rfCKreg = 1'b1;
  RY_rrCKreg = 1'b1;
  RY_frCKreg = 1'b1;


/*  -----------Implemetation for config fault starts------*/
   msgcnt = X;
   t = 0;
   fault_repair_flag = {max_faults{1'b1}};
   repair_flag = {max_faults{1'b1}};
   if(ConfigFault) 
   begin
        file_ptr = $fopen(Fault_file_name , "r");
        if(file_ptr == 0)
        begin     
          if(debug_level < 3) $display("%m - %t (MSG_ID 201) FAILURE: File cannot be opened ",$realtime);      
        end        
      else                
      begin : read_fault_file
      t = 0;
      for (i = 0; i< max_faults; i= i + 1)
      begin
         
         stuck0 = {Bits{1'b1}};
         stuck1 = {Bits{1'b0}};
         fault_char1 = $fgetc (file_ptr);
         if (fault_char1 == 8'b11111111)
                 disable read_fault_file;
         ret_val = $ungetc (fault_char1, file_ptr);
         ret_val = $fgets(tempStr, file_ptr);
         ret_val = $sscanf(tempStr, "%d %d %s",fault_word, fault_bit, stuck_at) ;
        flag_error = 0; 
         if(ret_val !== 0)
            begin         
               if(ret_val == 2 || ret_val == 3)
               begin
                  if(ret_val == 2)
                      stuck_at = "sa0";

                  if(stuck_at !== "sa0" && stuck_at !== "sa1" && stuck_at !== "none")
                  begin
                      if(debug_level < 2) $display("%m - %t (MSG_ID 203) WARNING: Wrong value for stuck at in fault file ",$realtime);
                      flag_error = 1;
                  end    
                      
                  if(fault_word > Words-1)
                  begin
                      if(debug_level < 2) $display("%m - %t (MSG_ID 206) WARNING: Address out of range in fault file ",$realtime);
                      flag_error = 1;
                  end    

                  if(fault_bit > Bits)
                  begin  
                      if(debug_level < 2) $display("%m - %t (MSG_ID 205) WARNING: Faulty bit out of range in fault file ",$realtime);
                      flag_error = 1;
                  end    

                  if(flag_error == 0)
                  //Correct Inputs
                  begin
                      if(stuck_at === "none")
                      begin
                         if(debug_level < 2) $display("%m - %t (MSG_ID 202) WARNING: No fault injected, empty fault file ",$realtime);
                      end
                      else
                      //Adding the faults
                      begin
                         FailureLocn[t] = fault_word;
                         std_fault_word = fault_word;
                         
                         fault_repair_flag[t] = 1'b0;
                         if (stuck_at === "sa0" )
                         begin
                            stuck0[fault_bit] = 1'b0;         
                            stuck_at_0fault[t] = stuck0;
                         end     
                         if (stuck_at === "sa1" )
                         begin
                            stuck1[fault_bit] = 1'b1;
                            stuck_at_1fault[t] = stuck1; 
                         end

                         array_stuck_at[t] = stuck_at;
                         t = t + 1;
                      end //if(stuck_at === "none")  
                  end //if(flag_error == 0)
               end //if(ret_val == 2 || ret_val == 3 
               else
               //wrong number of arguments
               begin
                  if(debug_level < 2)
                  $display("%m - %t WARNING :  WRONG VALUES ENTERED FOR FAULTY WORD OR FAULTY BIT OR STUCK_AT IN Fault_file_name", $realtime);
                  flag_error = 1;
               end
             end //if(ret_val !== 0)
             else
             begin
                 if(debug_level < 2) $display("%m - %t (MSG_ID 202) WARNING: No fault injected, empty fault file ",$realtime);
             end    
      end //for (i = 0; i< m
      end //begin: read_fault_file  
      $fclose (file_ptr);
      fcnt = t;

      
      
      //fault injection at time 0.
      task_insert_faults_in_memory;
      

   end // config_fault 
end// initial



//+++++++++++++++++++++++++++++++ CONFIG FAULT IMPLEMETATION ENDS+++++++++++++++++++++++++++++++//

always @(CKint)
begin
   lastCK = CKreg;
   CKreg = CKint;
   if(CKreg === 1'b1 && lastCK === 1'b0)
   begin
     CSNreg = CSNint;
   end

   
   if (CKint !== 0 && CSNint !== 1)
   begin
     InitialRYFlag = 1;
   end
   

   
   if (CKint===1 && lastCK ===0 && CSNint === X)
       ICRYFlag = 1;
   else if (CKint === 1 && lastCK === 0 && CSNint === 0)
       ICRYFlag = 0;
   

   /*---------------------- Latching signals ----------------------*/
   if(CKreg === 1'b1 && lastCK === 1'b0)
   begin
      
      WENreg = WENint;
   end   
   if(CKreg === 1'b1 && lastCK === 1'b0 && CSNint === 1'b0) begin
      ICGFlag = 0;
      Dreg = Dint;
      Mreg = Mint;
      Areg = Aint;
      if (^Areg === X)
         ValidAddress = X;
      else if (Areg < Words)
         ValidAddress = 1;
      else
         ValidAddress = 0;

      if (ValidAddress)
         Mem_temp = Mem[Aint];
      else
         Mem_temp = WordX; 

      
      
      Operation_Flag = 0;
      last_Qdata = Q_data;
      
      /*------ Normal Read and Write --------*/
      if (WENreg === 1)
      begin
         ReadCycle(Areg);
         chstate(Q_gCKreg, Q_gCKreg);
      end//if (WENreg === 1 && C
      else if (WENreg === 0 )
      begin
         WriteCycle(Areg);
      end
      /*---------- Corruption due to faulty values on signals --------*/
      else if (WENreg === X)
      begin
         chstate(Q_gCKreg, Q_gCKreg);
         // Uncertain write cycle
         WriteLocMskX(Areg,Mreg,Mem_temp);
         WriteOut;
         if (^Areg === X || Areg > Words-1)
         begin
              WriteOutX;	// if add is unknown put X at output
         end    
      end//else if (WENreg =
      
         

      
   end//if(CKreg === 1'b1 && lastCK =   
   // Unknown Clock Behaviour
   else if (((CSNint === 1'bx) && (CKint === 1)) || (CKint=== 1'bx && CSNreg !==1)) begin
      WriteMemX;
      WriteOutX;
      ICGFlag = 1'b1;
       
      ICRYFlag = 1'b1;
      if(CKint === 1'bx && CSNreg !== 1'b1) begin
         if(debug_level < 2) $display("%m - %t (MSG_ID 003) WARNING: Illegal Value on Clock. Memory and Output Corrupted ",$realtime);
      end
      else begin
         if(debug_level < 2) $display("%m - %t (MSG_ID 010) WARNING: Invalid control signal (chip select / memory bypass) Memory and Output Corrupted ",$realtime);
      end
   end 
   if(ConfigFault) begin
      task_insert_faults_in_memory;
      
   end//if(ConfigFault)
   
 end // always @(CKint)

always @(CSNint)
begin   
   // Unknown Clock & CSN signal
      if (CSNint !== 1 && CKint === X )
      begin
         chstate(Q_gCKreg, Q_gCKreg);
       	 WriteMemX;
	 WriteOutX;
         
         ICRYFlag = 1;   
      end//if (CSNint !== 1
end      


always @(TBYPASS_main)
begin

   OutReg_data = WordX;
   OutReg_glitch = WordX;
   
   if (TBYPASS_main !== 0)
      ICRYFlag = 1;
   
end


  

        /*---------------RY Functionality-----------------*/
always @(posedge CKreg)
begin


   if ((CSNreg === 0) && (CKreg === 1 && lastCK === 0) && TBYPASS_main === 1'b0)
   begin
           RY_rfCKreg = ~RY_rfCKreg;
        RY_rrCKreg = ~RY_rrCKreg;
   end


end

always @(negedge CKreg)
begin

   
   if (TBYPASS_main === 1'b0 && (CSNreg === 1'b0) && (CKreg === 1'b0 && lastCK === 1'b1))
   begin
        RY_frCKreg = ~RY_frCKreg;
    end


end

always @(TimingViol9 or TimingViol10 or TimingViol4 or TimingViol5 or TimingViol8 )
ICRYFlag = 1;
        /*---------------------------------*/






   




   
/*---------------TBYPASS  Functionality in functional model -----------------*/

always @(TimingViol9 or TimingViol10 or TimingViol4 or TimingViol5 or TimingViol8)
begin
   if (TBYPASS !== 0)
      WriteMemX;
end

always @(TimingViol2 or TimingViol3)
// tds or tdh violation
begin
#0
   for (l = 0; l < Bits; l = l + 1)
   begin   
      if((TimingViol2[l] !== TimingViol2_last[l]))
         Mreg[l] = 1'bx;
      if((TimingViol3[l] !== TimingViol3_last[l]))
         Mreg[l] = 1'bx;   
   end   
   WriteLocMskX_bwise(Areg,Mreg);
   TimingViol2_last = TimingViol2;
   TimingViol3_last = TimingViol3;
end


always @(TimingViol12 or TimingViol13)
// tms or tmh violation
begin
#0
   if ((CSNint === X) || (CKint === X))
   begin
      for (i = 0; i < Bits; i = i+1)
      begin   
         if (TimingViol12_last[i] !== TimingViol12[i])
	    Mreg[i] = 1'bx;
         if (TimingViol13_last[i] !== TimingViol13[i])
	    Mreg[i] = 1'bx;
      end      
      Areg = AddrX;
   end//if ((CSNint === X)
   else
   begin
      for (i = 0; i < Bits; i = i+1)
      begin   
         if ((TimingViol12_last[i] !== TimingViol12[i]) && (Mem_temp[i] !== Dreg[i]))
            Mreg[i] = 1'bx;
         if ((TimingViol13_last[i] !== TimingViol13[i]) && (Mem_temp[i] !== Dreg[i]))
            Mreg[i] = 1'bx;
      end      
   end
   WriteLocMskX_bwise(Areg, Mreg);
   TimingViol12_last = TimingViol12;
   TimingViol13_last = TimingViol13;
end

        
/*---------- Corruption due to Timing Violations ---------------*/

always @(TimingViol9 or TimingViol10)
// tckl -  tcycle
begin
#0
   Dreg = WordX;
   WriteOutX;
   #0.00 WriteMemX;
end

always @(TimingViol4 or TimingViol5)
// tps or tph
begin
#0
   Dreg = WordX;
   if ((WENreg !== 0) || (lastCK === X))
      WriteOutX;
   if (lastCK === X)
      WriteMemX;  
   WriteMemX; 
   if (CSNreg === 1 && WENreg !== 0)
   begin
      chstate(Q_gCKreg, Q_gCKreg);
   end
end

always @(TimingViol8)
// tckh
begin
#0
   Dreg = WordX;
   ICGFlag = 1;
   chstate(Q_gCKreg, Q_gCKreg);
   WriteOutX;
   WriteMemX;
end

always @(TimingViol0 or TimingViol1)
// tas or tah
begin
#0
   Areg = AddrX;
   ValidAddress = X;
   if (WENreg !== 0)
      WriteOutX;
   WriteMemX;
end


always @(TimingViol6 or TimingViol7)
//tws or twh
begin
#0
   if (CSNreg === X)
   begin
      WriteMemX; 
      WriteOutX;
   end
   else
   begin
      WriteLocMskX(Areg,Mreg,Mem_temp); 
      WriteOut;
      if (^Areg === X)
         WriteOutX;	// if add is unknown put X at output
   end
end


always @(TimingViol_ttms_ttmh)
//ttms/ttmh
begin
#0
   Dreg = WordX;
   WriteOutX;
   WriteMemX;  
   
   ICRYFlag = 1; 
end





endmodule

module ST_SPHDL_1216x32m16_bL_OPschlr (QINT,  RYINT, Q_gCK, Q_glitch,  Q_data, RY_rfCK, RY_rrCK, RY_frCK, ICRY, delTBYPASS, TBYPASS_D_Q, TBYPASS_main  );

    parameter
        Words = 1216,
        Bits = 32,
        Addr = 11;
        

    parameter
        WordX = 32'bx,
        AddrX = 11'bx,
        X = 1'bx;

	output [Bits-1 : 0] QINT;
	input [Bits-1 : 0] Q_glitch;
	input [Bits-1 : 0] Q_data;
	input [Bits-1 : 0] Q_gCK;
        input [Bits-1 : 0] TBYPASS_D_Q;
        input [Bits-1 : 0] delTBYPASS;
        input TBYPASS_main;



	integer m,a, d, n, o, p;
	wire [Bits-1 : 0] QINTint;
	wire [Bits-1 : 0] QINTERNAL;

        reg [Bits-1 : 0] OutReg;
	reg [Bits-1 : 0] lastQ_gCK, Q_gCKreg;
	reg [Bits-1 : 0] lastQ_data, Q_datareg;
	reg [Bits-1 : 0] QINTERNALreg;
	reg [Bits-1 : 0] lastQINTERNAL;

buf bufqint [Bits-1:0] (QINT, QINTint);


	assign QINTint[0] = (TBYPASS_main===0 && delTBYPASS[0]===0)?OutReg[0] : (TBYPASS_main===1 && delTBYPASS[0]===1)?TBYPASS_D_Q[0] : WordX;
	assign QINTint[1] = (TBYPASS_main===0 && delTBYPASS[1]===0)?OutReg[1] : (TBYPASS_main===1 && delTBYPASS[1]===1)?TBYPASS_D_Q[1] : WordX;
	assign QINTint[2] = (TBYPASS_main===0 && delTBYPASS[2]===0)?OutReg[2] : (TBYPASS_main===1 && delTBYPASS[2]===1)?TBYPASS_D_Q[2] : WordX;
	assign QINTint[3] = (TBYPASS_main===0 && delTBYPASS[3]===0)?OutReg[3] : (TBYPASS_main===1 && delTBYPASS[3]===1)?TBYPASS_D_Q[3] : WordX;
	assign QINTint[4] = (TBYPASS_main===0 && delTBYPASS[4]===0)?OutReg[4] : (TBYPASS_main===1 && delTBYPASS[4]===1)?TBYPASS_D_Q[4] : WordX;
	assign QINTint[5] = (TBYPASS_main===0 && delTBYPASS[5]===0)?OutReg[5] : (TBYPASS_main===1 && delTBYPASS[5]===1)?TBYPASS_D_Q[5] : WordX;
	assign QINTint[6] = (TBYPASS_main===0 && delTBYPASS[6]===0)?OutReg[6] : (TBYPASS_main===1 && delTBYPASS[6]===1)?TBYPASS_D_Q[6] : WordX;
	assign QINTint[7] = (TBYPASS_main===0 && delTBYPASS[7]===0)?OutReg[7] : (TBYPASS_main===1 && delTBYPASS[7]===1)?TBYPASS_D_Q[7] : WordX;
	assign QINTint[8] = (TBYPASS_main===0 && delTBYPASS[8]===0)?OutReg[8] : (TBYPASS_main===1 && delTBYPASS[8]===1)?TBYPASS_D_Q[8] : WordX;
	assign QINTint[9] = (TBYPASS_main===0 && delTBYPASS[9]===0)?OutReg[9] : (TBYPASS_main===1 && delTBYPASS[9]===1)?TBYPASS_D_Q[9] : WordX;
	assign QINTint[10] = (TBYPASS_main===0 && delTBYPASS[10]===0)?OutReg[10] : (TBYPASS_main===1 && delTBYPASS[10]===1)?TBYPASS_D_Q[10] : WordX;
	assign QINTint[11] = (TBYPASS_main===0 && delTBYPASS[11]===0)?OutReg[11] : (TBYPASS_main===1 && delTBYPASS[11]===1)?TBYPASS_D_Q[11] : WordX;
	assign QINTint[12] = (TBYPASS_main===0 && delTBYPASS[12]===0)?OutReg[12] : (TBYPASS_main===1 && delTBYPASS[12]===1)?TBYPASS_D_Q[12] : WordX;
	assign QINTint[13] = (TBYPASS_main===0 && delTBYPASS[13]===0)?OutReg[13] : (TBYPASS_main===1 && delTBYPASS[13]===1)?TBYPASS_D_Q[13] : WordX;
	assign QINTint[14] = (TBYPASS_main===0 && delTBYPASS[14]===0)?OutReg[14] : (TBYPASS_main===1 && delTBYPASS[14]===1)?TBYPASS_D_Q[14] : WordX;
	assign QINTint[15] = (TBYPASS_main===0 && delTBYPASS[15]===0)?OutReg[15] : (TBYPASS_main===1 && delTBYPASS[15]===1)?TBYPASS_D_Q[15] : WordX;
	assign QINTint[16] = (TBYPASS_main===0 && delTBYPASS[16]===0)?OutReg[16] : (TBYPASS_main===1 && delTBYPASS[16]===1)?TBYPASS_D_Q[16] : WordX;
	assign QINTint[17] = (TBYPASS_main===0 && delTBYPASS[17]===0)?OutReg[17] : (TBYPASS_main===1 && delTBYPASS[17]===1)?TBYPASS_D_Q[17] : WordX;
	assign QINTint[18] = (TBYPASS_main===0 && delTBYPASS[18]===0)?OutReg[18] : (TBYPASS_main===1 && delTBYPASS[18]===1)?TBYPASS_D_Q[18] : WordX;
	assign QINTint[19] = (TBYPASS_main===0 && delTBYPASS[19]===0)?OutReg[19] : (TBYPASS_main===1 && delTBYPASS[19]===1)?TBYPASS_D_Q[19] : WordX;
	assign QINTint[20] = (TBYPASS_main===0 && delTBYPASS[20]===0)?OutReg[20] : (TBYPASS_main===1 && delTBYPASS[20]===1)?TBYPASS_D_Q[20] : WordX;
	assign QINTint[21] = (TBYPASS_main===0 && delTBYPASS[21]===0)?OutReg[21] : (TBYPASS_main===1 && delTBYPASS[21]===1)?TBYPASS_D_Q[21] : WordX;
	assign QINTint[22] = (TBYPASS_main===0 && delTBYPASS[22]===0)?OutReg[22] : (TBYPASS_main===1 && delTBYPASS[22]===1)?TBYPASS_D_Q[22] : WordX;
	assign QINTint[23] = (TBYPASS_main===0 && delTBYPASS[23]===0)?OutReg[23] : (TBYPASS_main===1 && delTBYPASS[23]===1)?TBYPASS_D_Q[23] : WordX;
	assign QINTint[24] = (TBYPASS_main===0 && delTBYPASS[24]===0)?OutReg[24] : (TBYPASS_main===1 && delTBYPASS[24]===1)?TBYPASS_D_Q[24] : WordX;
	assign QINTint[25] = (TBYPASS_main===0 && delTBYPASS[25]===0)?OutReg[25] : (TBYPASS_main===1 && delTBYPASS[25]===1)?TBYPASS_D_Q[25] : WordX;
	assign QINTint[26] = (TBYPASS_main===0 && delTBYPASS[26]===0)?OutReg[26] : (TBYPASS_main===1 && delTBYPASS[26]===1)?TBYPASS_D_Q[26] : WordX;
	assign QINTint[27] = (TBYPASS_main===0 && delTBYPASS[27]===0)?OutReg[27] : (TBYPASS_main===1 && delTBYPASS[27]===1)?TBYPASS_D_Q[27] : WordX;
	assign QINTint[28] = (TBYPASS_main===0 && delTBYPASS[28]===0)?OutReg[28] : (TBYPASS_main===1 && delTBYPASS[28]===1)?TBYPASS_D_Q[28] : WordX;
	assign QINTint[29] = (TBYPASS_main===0 && delTBYPASS[29]===0)?OutReg[29] : (TBYPASS_main===1 && delTBYPASS[29]===1)?TBYPASS_D_Q[29] : WordX;
	assign QINTint[30] = (TBYPASS_main===0 && delTBYPASS[30]===0)?OutReg[30] : (TBYPASS_main===1 && delTBYPASS[30]===1)?TBYPASS_D_Q[30] : WordX;
	assign QINTint[31] = (TBYPASS_main===0 && delTBYPASS[31]===0)?OutReg[31] : (TBYPASS_main===1 && delTBYPASS[31]===1)?TBYPASS_D_Q[31] : WordX;

assign QINTERNAL = QINTERNALreg;

always @(TBYPASS_main)
begin
           
   if (TBYPASS_main === 0 || TBYPASS_main === X) 
      QINTERNALreg = WordX;
   
end


        
/*------------------ RY functionality -----------------*/
        output RYINT;
        input RY_rfCK, RY_rrCK, RY_frCK, ICRY;
        wire RYINTint;
        reg RYINTreg, RYRiseFlag;

        buf (RYINT, RYINTint);

assign RYINTint = RYINTreg;
        
initial
begin
  RYRiseFlag = 1'b0;
  RYINTreg = 1'b1;
end

always @(ICRY)
begin
   if($realtime == 0)
      RYINTreg = 1'b1;
   else
      RYINTreg = 1'bx;
end

always @(RY_rfCK)
if (ICRY !== 1)
begin
   RYINTreg = 0;
   RYRiseFlag=0;
end

always @(RY_rrCK)
if (ICRY !== 1 && $realtime != 0)
begin
   if (RYRiseFlag === 0)
   begin
      RYRiseFlag=1;
   end
   else
   begin
      RYINTreg = 1'b1;
      RYRiseFlag=0;
   end
end
always @(RY_frCK)
#0
if (ICRY !== 1 && $realtime != 0)
begin
   if (RYRiseFlag === 0)
   begin
      RYRiseFlag=1;
   end
   else
   begin
      RYINTreg = 1'b1;
      RYRiseFlag=0;
   end
end
/*------------------------------------------------ */

always @(Q_gCK)
begin
#0  //This has been used for removing races during hold time violations in MODELSIM simulator.
   lastQ_gCK = Q_gCKreg;
   Q_gCKreg <= Q_gCK;
   for (m = 0; m < Bits; m = m + 1)
   begin
     if (lastQ_gCK[m] !== Q_gCK[m])
     begin
       	lastQINTERNAL[m] = QINTERNALreg[m];
       	QINTERNALreg[m] = Q_glitch[m];
     end
   end
end

always @(Q_data)
begin
#0  //This has been used for removing races during hold time vilations in MODELSIM simulator.
   lastQ_data = Q_datareg;
   Q_datareg <= Q_data;
   for (n = 0; n < Bits; n = n + 1)
   begin
      if (lastQ_data[n] !== Q_data[n])
      begin
       	lastQINTERNAL[n] = QINTERNALreg[n];
       	QINTERNALreg[n] = Q_data[n];
      end
   end
end

always @(QINTERNAL)
begin
   for (d = 0; d < Bits; d = d + 1)
   begin
      if (OutReg[d] !== QINTERNAL[d])
          OutReg[d] = QINTERNAL[d];
   end
end



endmodule


module ST_SPHDL_1216x32m16_bL (Q, RY, CK, CSN, TBYPASS, WEN,  A,  D, M   );
   

    parameter 
        Fault_file_name = "ST_SPHDL_1216x32m16_bL_faults.txt",   
        ConfigFault = 0,
        max_faults = 20,
        MEM_INITIALIZE = 1'b0,
        BinaryInit     = 1'b0,
        InitFileName   = "ST_SPHDL_1216x32m16_bL.cde",     
        Corruption_Read_Violation = 1,
        Debug_mode = "ALL_WARNING_MODE",
        InstancePath = "ST_SPHDL_1216x32m16_bL";

    parameter
        Words = 1216,
        Bits = 32,
        Addr = 11,
        mux = 16,
        Rows = Words/mux;
        






    parameter
        WordX = 32'bx,
        AddrX = 11'bx,
        X = 1'bx;


    output [Bits-1 : 0] Q;
    
    output RY;   
    input CK;
    input CSN;
    input WEN;
    input TBYPASS;
    input [Addr-1 : 0] A;
    input [Bits-1 : 0] D;
    
    input [Bits-1 : 0] M;
    





   
   wire [Bits-1 : 0] Q_glitchint;
   wire [Bits-1 : 0] Q_dataint;
   wire [Bits-1 : 0] Dint,Mint;
   wire [Addr-1 : 0] Aint;
   wire [Bits-1 : 0] Q_gCKint;
   wire CKint;
   wire CSNint;
   wire WENint;
   wire TBYPASSint;
   wire TBYPASS_mainint;
   wire [Bits-1 : 0]  TBYPASS_D_Qint;
   wire [Bits-1 : 0]  delTBYPASSint;






   
   wire [Bits-1 : 0] Qint, Q_out;
   wire CS_taa = !CSNint;
   wire csn_tcycle = !CSNint;
   wire csn_tcycle_DEBUG, csn_tcycle_DEBUGN;
   reg [Bits-1 : 0] Dreg,Mreg;
   reg [Addr-1 : 0] Areg;
   reg CKreg;
   reg CSNreg;
   reg WENreg;
	
   reg [Bits-1 : 0] TimingViol2, TimingViol3, TimingViol12, TimingViol13;
   reg [Bits-1 : 0] TimingViol2_last, TimingViol3_last, TimingViol12_last, TimingViol13_last;
	reg TimingViol2_0, TimingViol3_0, TimingViol12_0, TimingViol13_0;
	reg TimingViol2_1, TimingViol3_1, TimingViol12_1, TimingViol13_1;
	reg TimingViol2_2, TimingViol3_2, TimingViol12_2, TimingViol13_2;
	reg TimingViol2_3, TimingViol3_3, TimingViol12_3, TimingViol13_3;
	reg TimingViol2_4, TimingViol3_4, TimingViol12_4, TimingViol13_4;
	reg TimingViol2_5, TimingViol3_5, TimingViol12_5, TimingViol13_5;
	reg TimingViol2_6, TimingViol3_6, TimingViol12_6, TimingViol13_6;
	reg TimingViol2_7, TimingViol3_7, TimingViol12_7, TimingViol13_7;
	reg TimingViol2_8, TimingViol3_8, TimingViol12_8, TimingViol13_8;
	reg TimingViol2_9, TimingViol3_9, TimingViol12_9, TimingViol13_9;
	reg TimingViol2_10, TimingViol3_10, TimingViol12_10, TimingViol13_10;
	reg TimingViol2_11, TimingViol3_11, TimingViol12_11, TimingViol13_11;
	reg TimingViol2_12, TimingViol3_12, TimingViol12_12, TimingViol13_12;
	reg TimingViol2_13, TimingViol3_13, TimingViol12_13, TimingViol13_13;
	reg TimingViol2_14, TimingViol3_14, TimingViol12_14, TimingViol13_14;
	reg TimingViol2_15, TimingViol3_15, TimingViol12_15, TimingViol13_15;
	reg TimingViol2_16, TimingViol3_16, TimingViol12_16, TimingViol13_16;
	reg TimingViol2_17, TimingViol3_17, TimingViol12_17, TimingViol13_17;
	reg TimingViol2_18, TimingViol3_18, TimingViol12_18, TimingViol13_18;
	reg TimingViol2_19, TimingViol3_19, TimingViol12_19, TimingViol13_19;
	reg TimingViol2_20, TimingViol3_20, TimingViol12_20, TimingViol13_20;
	reg TimingViol2_21, TimingViol3_21, TimingViol12_21, TimingViol13_21;
	reg TimingViol2_22, TimingViol3_22, TimingViol12_22, TimingViol13_22;
	reg TimingViol2_23, TimingViol3_23, TimingViol12_23, TimingViol13_23;
	reg TimingViol2_24, TimingViol3_24, TimingViol12_24, TimingViol13_24;
	reg TimingViol2_25, TimingViol3_25, TimingViol12_25, TimingViol13_25;
	reg TimingViol2_26, TimingViol3_26, TimingViol12_26, TimingViol13_26;
	reg TimingViol2_27, TimingViol3_27, TimingViol12_27, TimingViol13_27;
	reg TimingViol2_28, TimingViol3_28, TimingViol12_28, TimingViol13_28;
	reg TimingViol2_29, TimingViol3_29, TimingViol12_29, TimingViol13_29;
	reg TimingViol2_30, TimingViol3_30, TimingViol12_30, TimingViol13_30;
	reg TimingViol2_31, TimingViol3_31, TimingViol12_31, TimingViol13_31;
   reg TimingViol0, TimingViol1;
   reg TimingViol4, TimingViol5, TimingViol6, TimingViol7, TimingViol_ttms_ttmh;
   reg TimingViol8, TimingViol9, TimingViol10, TimingViol10_taa;








   wire [Bits-1 : 0] MEN,CSWEMTBYPASS;
   wire CSTBYPASSN, CSWETBYPASSN;
   wire csn_tckl;
   wire csn_tckl_ry;
   wire csn_tckh;

   reg tckh_flag;
   reg tckl_flag;

   wire CS_taa_ry = !CSNint;
   
/* This register is used to force all warning messages 
** OFF during run time.
** 
*/ 
   reg [1:0] debug_level;
   reg [8*10: 0] operating_mode;
   reg [8*44: 0] message_status;





initial
begin
  debug_level = 2'b0;
  message_status = "All Messages are Switched ON";
  `ifdef  NO_WARNING_MODE
     debug_level = 2'b10;
    message_status = "All Messages are Switched OFF"; 
  `endif 
if(debug_level !== 2'b10) begin
  $display ("%m  INFORMATION");
   $display ("***************************************");
   $display ("The Model is Operating in TIMING MODE");
   $display ("Please make sure that SDF is properly annotated otherwise dummy values will be used");
   $display ("%s", message_status);
   $display ("***************************************");
   if(ConfigFault)
  $display ("Configurable Fault Functionality is ON");   
  else
  $display ("Configurable Fault Functionality is OFF"); 
  
  $display ("***************************************");
end     
end     

   buf (CKint, CK);

   //MEM_EN = CSN or  TBYPASS
   or (CSNint, CSN, TBYPASS  );

   buf (TBYPASSint, TBYPASS);
   buf (WENint, WEN);
   buf bufDint [Bits-1:0] (Dint, D);
   
   buf bufMint [Bits-1:0] (Mint, M);
   
   buf bufAint [Addr-1:0] (Aint, A);






   
     buf bufqint [Bits-1:0] (Q,Qint); 





	reg TimingViol9_tck_ry, TimingViol10_taa_ry;
        wire  RYint, RY_rfCKint, RY_rrCKint, RY_frCKint, RY_out;
        reg RY_outreg; 
        assign RY_out = RY_outreg;
  
     
       buf (RY, RY_out);  
       
        always @(RYint)
        begin
        RY_outreg = RYint;
        end

        
   // Only include timing checks during behavioural modelling



not (CS, CSN);    


    not (TBYPASSN, TBYPASS);
    not (WE, WEN);

    and (CSWE, CS, WE);
    and (CSWETBYPASSN, CSWE, TBYPASSN);
    and (CSTBYPASSN, CS, TBYPASSN);
    and (CSWEN, CS, WEN);
 
    assign csn_tckh = tckh_flag;
    assign csn_tckl = tckl_flag;
    assign csn_tckl_ry = tckl_flag;


        
 not (MEN[0], Mint[0]);
 not (MEN[1], Mint[1]);
 not (MEN[2], Mint[2]);
 not (MEN[3], Mint[3]);
 not (MEN[4], Mint[4]);
 not (MEN[5], Mint[5]);
 not (MEN[6], Mint[6]);
 not (MEN[7], Mint[7]);
 not (MEN[8], Mint[8]);
 not (MEN[9], Mint[9]);
 not (MEN[10], Mint[10]);
 not (MEN[11], Mint[11]);
 not (MEN[12], Mint[12]);
 not (MEN[13], Mint[13]);
 not (MEN[14], Mint[14]);
 not (MEN[15], Mint[15]);
 not (MEN[16], Mint[16]);
 not (MEN[17], Mint[17]);
 not (MEN[18], Mint[18]);
 not (MEN[19], Mint[19]);
 not (MEN[20], Mint[20]);
 not (MEN[21], Mint[21]);
 not (MEN[22], Mint[22]);
 not (MEN[23], Mint[23]);
 not (MEN[24], Mint[24]);
 not (MEN[25], Mint[25]);
 not (MEN[26], Mint[26]);
 not (MEN[27], Mint[27]);
 not (MEN[28], Mint[28]);
 not (MEN[29], Mint[29]);
 not (MEN[30], Mint[30]);
 not (MEN[31], Mint[31]);
 and (CSWEMTBYPASS[0], MEN[0], CSWETBYPASSN);
 and (CSWEMTBYPASS[1], MEN[1], CSWETBYPASSN);
 and (CSWEMTBYPASS[2], MEN[2], CSWETBYPASSN);
 and (CSWEMTBYPASS[3], MEN[3], CSWETBYPASSN);
 and (CSWEMTBYPASS[4], MEN[4], CSWETBYPASSN);
 and (CSWEMTBYPASS[5], MEN[5], CSWETBYPASSN);
 and (CSWEMTBYPASS[6], MEN[6], CSWETBYPASSN);
 and (CSWEMTBYPASS[7], MEN[7], CSWETBYPASSN);
 and (CSWEMTBYPASS[8], MEN[8], CSWETBYPASSN);
 and (CSWEMTBYPASS[9], MEN[9], CSWETBYPASSN);
 and (CSWEMTBYPASS[10], MEN[10], CSWETBYPASSN);
 and (CSWEMTBYPASS[11], MEN[11], CSWETBYPASSN);
 and (CSWEMTBYPASS[12], MEN[12], CSWETBYPASSN);
 and (CSWEMTBYPASS[13], MEN[13], CSWETBYPASSN);
 and (CSWEMTBYPASS[14], MEN[14], CSWETBYPASSN);
 and (CSWEMTBYPASS[15], MEN[15], CSWETBYPASSN);
 and (CSWEMTBYPASS[16], MEN[16], CSWETBYPASSN);
 and (CSWEMTBYPASS[17], MEN[17], CSWETBYPASSN);
 and (CSWEMTBYPASS[18], MEN[18], CSWETBYPASSN);
 and (CSWEMTBYPASS[19], MEN[19], CSWETBYPASSN);
 and (CSWEMTBYPASS[20], MEN[20], CSWETBYPASSN);
 and (CSWEMTBYPASS[21], MEN[21], CSWETBYPASSN);
 and (CSWEMTBYPASS[22], MEN[22], CSWETBYPASSN);
 and (CSWEMTBYPASS[23], MEN[23], CSWETBYPASSN);
 and (CSWEMTBYPASS[24], MEN[24], CSWETBYPASSN);
 and (CSWEMTBYPASS[25], MEN[25], CSWETBYPASSN);
 and (CSWEMTBYPASS[26], MEN[26], CSWETBYPASSN);
 and (CSWEMTBYPASS[27], MEN[27], CSWETBYPASSN);
 and (CSWEMTBYPASS[28], MEN[28], CSWETBYPASSN);
 and (CSWEMTBYPASS[29], MEN[29], CSWETBYPASSN);
 and (CSWEMTBYPASS[30], MEN[30], CSWETBYPASSN);
 and (CSWEMTBYPASS[31], MEN[31], CSWETBYPASSN);

   specify
      specparam



         tckl_tck_ry = 0.00,
         tcycle_taa_ry = 0.00,

 
         
	 tms = 0.0,
         tmh = 0.0,
         tcycle = 0.0,
         tcycle_taa = 0.0,
         tckh = 0.0,
         tckl = 0.0,
         ttms = 0.0,
         ttmh = 0.0,
         tps = 0.0,
         tph = 0.0,
         tws = 0.0,
         twh = 0.0,
         tas = 0.0,
         tah = 0.0,
         tds = 0.0,
         tdh = 0.0;
        /*---------------------- Timing Checks ---------------------*/

	$setup(posedge A[0], posedge CK &&& CSTBYPASSN, tas, TimingViol0);
	$setup(posedge A[1], posedge CK &&& CSTBYPASSN, tas, TimingViol0);
	$setup(posedge A[2], posedge CK &&& CSTBYPASSN, tas, TimingViol0);
	$setup(posedge A[3], posedge CK &&& CSTBYPASSN, tas, TimingViol0);
	$setup(posedge A[4], posedge CK &&& CSTBYPASSN, tas, TimingViol0);
	$setup(posedge A[5], posedge CK &&& CSTBYPASSN, tas, TimingViol0);
	$setup(posedge A[6], posedge CK &&& CSTBYPASSN, tas, TimingViol0);
	$setup(posedge A[7], posedge CK &&& CSTBYPASSN, tas, TimingViol0);
	$setup(posedge A[8], posedge CK &&& CSTBYPASSN, tas, TimingViol0);
	$setup(posedge A[9], posedge CK &&& CSTBYPASSN, tas, TimingViol0);
	$setup(posedge A[10], posedge CK &&& CSTBYPASSN, tas, TimingViol0);
	$setup(negedge A[0], posedge CK &&& CSTBYPASSN, tas, TimingViol0);
	$setup(negedge A[1], posedge CK &&& CSTBYPASSN, tas, TimingViol0);
	$setup(negedge A[2], posedge CK &&& CSTBYPASSN, tas, TimingViol0);
	$setup(negedge A[3], posedge CK &&& CSTBYPASSN, tas, TimingViol0);
	$setup(negedge A[4], posedge CK &&& CSTBYPASSN, tas, TimingViol0);
	$setup(negedge A[5], posedge CK &&& CSTBYPASSN, tas, TimingViol0);
	$setup(negedge A[6], posedge CK &&& CSTBYPASSN, tas, TimingViol0);
	$setup(negedge A[7], posedge CK &&& CSTBYPASSN, tas, TimingViol0);
	$setup(negedge A[8], posedge CK &&& CSTBYPASSN, tas, TimingViol0);
	$setup(negedge A[9], posedge CK &&& CSTBYPASSN, tas, TimingViol0);
	$setup(negedge A[10], posedge CK &&& CSTBYPASSN, tas, TimingViol0);
	$hold(posedge CK &&& CSTBYPASSN, posedge A[0], tah, TimingViol1);
	$hold(posedge CK &&& CSTBYPASSN, posedge A[1], tah, TimingViol1);
	$hold(posedge CK &&& CSTBYPASSN, posedge A[2], tah, TimingViol1);
	$hold(posedge CK &&& CSTBYPASSN, posedge A[3], tah, TimingViol1);
	$hold(posedge CK &&& CSTBYPASSN, posedge A[4], tah, TimingViol1);
	$hold(posedge CK &&& CSTBYPASSN, posedge A[5], tah, TimingViol1);
	$hold(posedge CK &&& CSTBYPASSN, posedge A[6], tah, TimingViol1);
	$hold(posedge CK &&& CSTBYPASSN, posedge A[7], tah, TimingViol1);
	$hold(posedge CK &&& CSTBYPASSN, posedge A[8], tah, TimingViol1);
	$hold(posedge CK &&& CSTBYPASSN, posedge A[9], tah, TimingViol1);
	$hold(posedge CK &&& CSTBYPASSN, posedge A[10], tah, TimingViol1);
	$hold(posedge CK &&& CSTBYPASSN, negedge A[0], tah, TimingViol1);
	$hold(posedge CK &&& CSTBYPASSN, negedge A[1], tah, TimingViol1);
	$hold(posedge CK &&& CSTBYPASSN, negedge A[2], tah, TimingViol1);
	$hold(posedge CK &&& CSTBYPASSN, negedge A[3], tah, TimingViol1);
	$hold(posedge CK &&& CSTBYPASSN, negedge A[4], tah, TimingViol1);
	$hold(posedge CK &&& CSTBYPASSN, negedge A[5], tah, TimingViol1);
	$hold(posedge CK &&& CSTBYPASSN, negedge A[6], tah, TimingViol1);
	$hold(posedge CK &&& CSTBYPASSN, negedge A[7], tah, TimingViol1);
	$hold(posedge CK &&& CSTBYPASSN, negedge A[8], tah, TimingViol1);
	$hold(posedge CK &&& CSTBYPASSN, negedge A[9], tah, TimingViol1);
	$hold(posedge CK &&& CSTBYPASSN, negedge A[10], tah, TimingViol1);
	$setup(posedge D[0], posedge CK &&& (CSWEMTBYPASS[0] != 0), tds, TimingViol2_0);
	$setup(posedge D[1], posedge CK &&& (CSWEMTBYPASS[1] != 0), tds, TimingViol2_1);
	$setup(posedge D[2], posedge CK &&& (CSWEMTBYPASS[2] != 0), tds, TimingViol2_2);
	$setup(posedge D[3], posedge CK &&& (CSWEMTBYPASS[3] != 0), tds, TimingViol2_3);
	$setup(posedge D[4], posedge CK &&& (CSWEMTBYPASS[4] != 0), tds, TimingViol2_4);
	$setup(posedge D[5], posedge CK &&& (CSWEMTBYPASS[5] != 0), tds, TimingViol2_5);
	$setup(posedge D[6], posedge CK &&& (CSWEMTBYPASS[6] != 0), tds, TimingViol2_6);
	$setup(posedge D[7], posedge CK &&& (CSWEMTBYPASS[7] != 0), tds, TimingViol2_7);
	$setup(posedge D[8], posedge CK &&& (CSWEMTBYPASS[8] != 0), tds, TimingViol2_8);
	$setup(posedge D[9], posedge CK &&& (CSWEMTBYPASS[9] != 0), tds, TimingViol2_9);
	$setup(posedge D[10], posedge CK &&& (CSWEMTBYPASS[10] != 0), tds, TimingViol2_10);
	$setup(posedge D[11], posedge CK &&& (CSWEMTBYPASS[11] != 0), tds, TimingViol2_11);
	$setup(posedge D[12], posedge CK &&& (CSWEMTBYPASS[12] != 0), tds, TimingViol2_12);
	$setup(posedge D[13], posedge CK &&& (CSWEMTBYPASS[13] != 0), tds, TimingViol2_13);
	$setup(posedge D[14], posedge CK &&& (CSWEMTBYPASS[14] != 0), tds, TimingViol2_14);
	$setup(posedge D[15], posedge CK &&& (CSWEMTBYPASS[15] != 0), tds, TimingViol2_15);
	$setup(posedge D[16], posedge CK &&& (CSWEMTBYPASS[16] != 0), tds, TimingViol2_16);
	$setup(posedge D[17], posedge CK &&& (CSWEMTBYPASS[17] != 0), tds, TimingViol2_17);
	$setup(posedge D[18], posedge CK &&& (CSWEMTBYPASS[18] != 0), tds, TimingViol2_18);
	$setup(posedge D[19], posedge CK &&& (CSWEMTBYPASS[19] != 0), tds, TimingViol2_19);
	$setup(posedge D[20], posedge CK &&& (CSWEMTBYPASS[20] != 0), tds, TimingViol2_20);
	$setup(posedge D[21], posedge CK &&& (CSWEMTBYPASS[21] != 0), tds, TimingViol2_21);
	$setup(posedge D[22], posedge CK &&& (CSWEMTBYPASS[22] != 0), tds, TimingViol2_22);
	$setup(posedge D[23], posedge CK &&& (CSWEMTBYPASS[23] != 0), tds, TimingViol2_23);
	$setup(posedge D[24], posedge CK &&& (CSWEMTBYPASS[24] != 0), tds, TimingViol2_24);
	$setup(posedge D[25], posedge CK &&& (CSWEMTBYPASS[25] != 0), tds, TimingViol2_25);
	$setup(posedge D[26], posedge CK &&& (CSWEMTBYPASS[26] != 0), tds, TimingViol2_26);
	$setup(posedge D[27], posedge CK &&& (CSWEMTBYPASS[27] != 0), tds, TimingViol2_27);
	$setup(posedge D[28], posedge CK &&& (CSWEMTBYPASS[28] != 0), tds, TimingViol2_28);
	$setup(posedge D[29], posedge CK &&& (CSWEMTBYPASS[29] != 0), tds, TimingViol2_29);
	$setup(posedge D[30], posedge CK &&& (CSWEMTBYPASS[30] != 0), tds, TimingViol2_30);
	$setup(posedge D[31], posedge CK &&& (CSWEMTBYPASS[31] != 0), tds, TimingViol2_31);
	$setup(negedge D[0], posedge CK &&& (CSWEMTBYPASS[0] != 0), tds, TimingViol2_0);
	$setup(negedge D[1], posedge CK &&& (CSWEMTBYPASS[1] != 0), tds, TimingViol2_1);
	$setup(negedge D[2], posedge CK &&& (CSWEMTBYPASS[2] != 0), tds, TimingViol2_2);
	$setup(negedge D[3], posedge CK &&& (CSWEMTBYPASS[3] != 0), tds, TimingViol2_3);
	$setup(negedge D[4], posedge CK &&& (CSWEMTBYPASS[4] != 0), tds, TimingViol2_4);
	$setup(negedge D[5], posedge CK &&& (CSWEMTBYPASS[5] != 0), tds, TimingViol2_5);
	$setup(negedge D[6], posedge CK &&& (CSWEMTBYPASS[6] != 0), tds, TimingViol2_6);
	$setup(negedge D[7], posedge CK &&& (CSWEMTBYPASS[7] != 0), tds, TimingViol2_7);
	$setup(negedge D[8], posedge CK &&& (CSWEMTBYPASS[8] != 0), tds, TimingViol2_8);
	$setup(negedge D[9], posedge CK &&& (CSWEMTBYPASS[9] != 0), tds, TimingViol2_9);
	$setup(negedge D[10], posedge CK &&& (CSWEMTBYPASS[10] != 0), tds, TimingViol2_10);
	$setup(negedge D[11], posedge CK &&& (CSWEMTBYPASS[11] != 0), tds, TimingViol2_11);
	$setup(negedge D[12], posedge CK &&& (CSWEMTBYPASS[12] != 0), tds, TimingViol2_12);
	$setup(negedge D[13], posedge CK &&& (CSWEMTBYPASS[13] != 0), tds, TimingViol2_13);
	$setup(negedge D[14], posedge CK &&& (CSWEMTBYPASS[14] != 0), tds, TimingViol2_14);
	$setup(negedge D[15], posedge CK &&& (CSWEMTBYPASS[15] != 0), tds, TimingViol2_15);
	$setup(negedge D[16], posedge CK &&& (CSWEMTBYPASS[16] != 0), tds, TimingViol2_16);
	$setup(negedge D[17], posedge CK &&& (CSWEMTBYPASS[17] != 0), tds, TimingViol2_17);
	$setup(negedge D[18], posedge CK &&& (CSWEMTBYPASS[18] != 0), tds, TimingViol2_18);
	$setup(negedge D[19], posedge CK &&& (CSWEMTBYPASS[19] != 0), tds, TimingViol2_19);
	$setup(negedge D[20], posedge CK &&& (CSWEMTBYPASS[20] != 0), tds, TimingViol2_20);
	$setup(negedge D[21], posedge CK &&& (CSWEMTBYPASS[21] != 0), tds, TimingViol2_21);
	$setup(negedge D[22], posedge CK &&& (CSWEMTBYPASS[22] != 0), tds, TimingViol2_22);
	$setup(negedge D[23], posedge CK &&& (CSWEMTBYPASS[23] != 0), tds, TimingViol2_23);
	$setup(negedge D[24], posedge CK &&& (CSWEMTBYPASS[24] != 0), tds, TimingViol2_24);
	$setup(negedge D[25], posedge CK &&& (CSWEMTBYPASS[25] != 0), tds, TimingViol2_25);
	$setup(negedge D[26], posedge CK &&& (CSWEMTBYPASS[26] != 0), tds, TimingViol2_26);
	$setup(negedge D[27], posedge CK &&& (CSWEMTBYPASS[27] != 0), tds, TimingViol2_27);
	$setup(negedge D[28], posedge CK &&& (CSWEMTBYPASS[28] != 0), tds, TimingViol2_28);
	$setup(negedge D[29], posedge CK &&& (CSWEMTBYPASS[29] != 0), tds, TimingViol2_29);
	$setup(negedge D[30], posedge CK &&& (CSWEMTBYPASS[30] != 0), tds, TimingViol2_30);
	$setup(negedge D[31], posedge CK &&& (CSWEMTBYPASS[31] != 0), tds, TimingViol2_31);
	$hold(posedge CK &&& (CSWEMTBYPASS[0] != 0), posedge D[0], tdh, TimingViol3_0);
	$hold(posedge CK &&& (CSWEMTBYPASS[1] != 0), posedge D[1], tdh, TimingViol3_1);
	$hold(posedge CK &&& (CSWEMTBYPASS[2] != 0), posedge D[2], tdh, TimingViol3_2);
	$hold(posedge CK &&& (CSWEMTBYPASS[3] != 0), posedge D[3], tdh, TimingViol3_3);
	$hold(posedge CK &&& (CSWEMTBYPASS[4] != 0), posedge D[4], tdh, TimingViol3_4);
	$hold(posedge CK &&& (CSWEMTBYPASS[5] != 0), posedge D[5], tdh, TimingViol3_5);
	$hold(posedge CK &&& (CSWEMTBYPASS[6] != 0), posedge D[6], tdh, TimingViol3_6);
	$hold(posedge CK &&& (CSWEMTBYPASS[7] != 0), posedge D[7], tdh, TimingViol3_7);
	$hold(posedge CK &&& (CSWEMTBYPASS[8] != 0), posedge D[8], tdh, TimingViol3_8);
	$hold(posedge CK &&& (CSWEMTBYPASS[9] != 0), posedge D[9], tdh, TimingViol3_9);
	$hold(posedge CK &&& (CSWEMTBYPASS[10] != 0), posedge D[10], tdh, TimingViol3_10);
	$hold(posedge CK &&& (CSWEMTBYPASS[11] != 0), posedge D[11], tdh, TimingViol3_11);
	$hold(posedge CK &&& (CSWEMTBYPASS[12] != 0), posedge D[12], tdh, TimingViol3_12);
	$hold(posedge CK &&& (CSWEMTBYPASS[13] != 0), posedge D[13], tdh, TimingViol3_13);
	$hold(posedge CK &&& (CSWEMTBYPASS[14] != 0), posedge D[14], tdh, TimingViol3_14);
	$hold(posedge CK &&& (CSWEMTBYPASS[15] != 0), posedge D[15], tdh, TimingViol3_15);
	$hold(posedge CK &&& (CSWEMTBYPASS[16] != 0), posedge D[16], tdh, TimingViol3_16);
	$hold(posedge CK &&& (CSWEMTBYPASS[17] != 0), posedge D[17], tdh, TimingViol3_17);
	$hold(posedge CK &&& (CSWEMTBYPASS[18] != 0), posedge D[18], tdh, TimingViol3_18);
	$hold(posedge CK &&& (CSWEMTBYPASS[19] != 0), posedge D[19], tdh, TimingViol3_19);
	$hold(posedge CK &&& (CSWEMTBYPASS[20] != 0), posedge D[20], tdh, TimingViol3_20);
	$hold(posedge CK &&& (CSWEMTBYPASS[21] != 0), posedge D[21], tdh, TimingViol3_21);
	$hold(posedge CK &&& (CSWEMTBYPASS[22] != 0), posedge D[22], tdh, TimingViol3_22);
	$hold(posedge CK &&& (CSWEMTBYPASS[23] != 0), posedge D[23], tdh, TimingViol3_23);
	$hold(posedge CK &&& (CSWEMTBYPASS[24] != 0), posedge D[24], tdh, TimingViol3_24);
	$hold(posedge CK &&& (CSWEMTBYPASS[25] != 0), posedge D[25], tdh, TimingViol3_25);
	$hold(posedge CK &&& (CSWEMTBYPASS[26] != 0), posedge D[26], tdh, TimingViol3_26);
	$hold(posedge CK &&& (CSWEMTBYPASS[27] != 0), posedge D[27], tdh, TimingViol3_27);
	$hold(posedge CK &&& (CSWEMTBYPASS[28] != 0), posedge D[28], tdh, TimingViol3_28);
	$hold(posedge CK &&& (CSWEMTBYPASS[29] != 0), posedge D[29], tdh, TimingViol3_29);
	$hold(posedge CK &&& (CSWEMTBYPASS[30] != 0), posedge D[30], tdh, TimingViol3_30);
	$hold(posedge CK &&& (CSWEMTBYPASS[31] != 0), posedge D[31], tdh, TimingViol3_31);
	$hold(posedge CK &&& (CSWEMTBYPASS[0] != 0), negedge D[0], tdh, TimingViol3_0);
	$hold(posedge CK &&& (CSWEMTBYPASS[1] != 0), negedge D[1], tdh, TimingViol3_1);
	$hold(posedge CK &&& (CSWEMTBYPASS[2] != 0), negedge D[2], tdh, TimingViol3_2);
	$hold(posedge CK &&& (CSWEMTBYPASS[3] != 0), negedge D[3], tdh, TimingViol3_3);
	$hold(posedge CK &&& (CSWEMTBYPASS[4] != 0), negedge D[4], tdh, TimingViol3_4);
	$hold(posedge CK &&& (CSWEMTBYPASS[5] != 0), negedge D[5], tdh, TimingViol3_5);
	$hold(posedge CK &&& (CSWEMTBYPASS[6] != 0), negedge D[6], tdh, TimingViol3_6);
	$hold(posedge CK &&& (CSWEMTBYPASS[7] != 0), negedge D[7], tdh, TimingViol3_7);
	$hold(posedge CK &&& (CSWEMTBYPASS[8] != 0), negedge D[8], tdh, TimingViol3_8);
	$hold(posedge CK &&& (CSWEMTBYPASS[9] != 0), negedge D[9], tdh, TimingViol3_9);
	$hold(posedge CK &&& (CSWEMTBYPASS[10] != 0), negedge D[10], tdh, TimingViol3_10);
	$hold(posedge CK &&& (CSWEMTBYPASS[11] != 0), negedge D[11], tdh, TimingViol3_11);
	$hold(posedge CK &&& (CSWEMTBYPASS[12] != 0), negedge D[12], tdh, TimingViol3_12);
	$hold(posedge CK &&& (CSWEMTBYPASS[13] != 0), negedge D[13], tdh, TimingViol3_13);
	$hold(posedge CK &&& (CSWEMTBYPASS[14] != 0), negedge D[14], tdh, TimingViol3_14);
	$hold(posedge CK &&& (CSWEMTBYPASS[15] != 0), negedge D[15], tdh, TimingViol3_15);
	$hold(posedge CK &&& (CSWEMTBYPASS[16] != 0), negedge D[16], tdh, TimingViol3_16);
	$hold(posedge CK &&& (CSWEMTBYPASS[17] != 0), negedge D[17], tdh, TimingViol3_17);
	$hold(posedge CK &&& (CSWEMTBYPASS[18] != 0), negedge D[18], tdh, TimingViol3_18);
	$hold(posedge CK &&& (CSWEMTBYPASS[19] != 0), negedge D[19], tdh, TimingViol3_19);
	$hold(posedge CK &&& (CSWEMTBYPASS[20] != 0), negedge D[20], tdh, TimingViol3_20);
	$hold(posedge CK &&& (CSWEMTBYPASS[21] != 0), negedge D[21], tdh, TimingViol3_21);
	$hold(posedge CK &&& (CSWEMTBYPASS[22] != 0), negedge D[22], tdh, TimingViol3_22);
	$hold(posedge CK &&& (CSWEMTBYPASS[23] != 0), negedge D[23], tdh, TimingViol3_23);
	$hold(posedge CK &&& (CSWEMTBYPASS[24] != 0), negedge D[24], tdh, TimingViol3_24);
	$hold(posedge CK &&& (CSWEMTBYPASS[25] != 0), negedge D[25], tdh, TimingViol3_25);
	$hold(posedge CK &&& (CSWEMTBYPASS[26] != 0), negedge D[26], tdh, TimingViol3_26);
	$hold(posedge CK &&& (CSWEMTBYPASS[27] != 0), negedge D[27], tdh, TimingViol3_27);
	$hold(posedge CK &&& (CSWEMTBYPASS[28] != 0), negedge D[28], tdh, TimingViol3_28);
	$hold(posedge CK &&& (CSWEMTBYPASS[29] != 0), negedge D[29], tdh, TimingViol3_29);
	$hold(posedge CK &&& (CSWEMTBYPASS[30] != 0), negedge D[30], tdh, TimingViol3_30);
	$hold(posedge CK &&& (CSWEMTBYPASS[31] != 0), negedge D[31], tdh, TimingViol3_31);

	$setup(posedge M[0], edge[01,0x,x1,1x] CK &&& (CSWETBYPASSN != 'b0), tms, TimingViol12_0);
	$setup(posedge M[1], edge[01,0x,x1,1x] CK &&& (CSWETBYPASSN != 'b0), tms, TimingViol12_1);
	$setup(posedge M[2], edge[01,0x,x1,1x] CK &&& (CSWETBYPASSN != 'b0), tms, TimingViol12_2);
	$setup(posedge M[3], edge[01,0x,x1,1x] CK &&& (CSWETBYPASSN != 'b0), tms, TimingViol12_3);
	$setup(posedge M[4], edge[01,0x,x1,1x] CK &&& (CSWETBYPASSN != 'b0), tms, TimingViol12_4);
	$setup(posedge M[5], edge[01,0x,x1,1x] CK &&& (CSWETBYPASSN != 'b0), tms, TimingViol12_5);
	$setup(posedge M[6], edge[01,0x,x1,1x] CK &&& (CSWETBYPASSN != 'b0), tms, TimingViol12_6);
	$setup(posedge M[7], edge[01,0x,x1,1x] CK &&& (CSWETBYPASSN != 'b0), tms, TimingViol12_7);
	$setup(posedge M[8], edge[01,0x,x1,1x] CK &&& (CSWETBYPASSN != 'b0), tms, TimingViol12_8);
	$setup(posedge M[9], edge[01,0x,x1,1x] CK &&& (CSWETBYPASSN != 'b0), tms, TimingViol12_9);
	$setup(posedge M[10], edge[01,0x,x1,1x] CK &&& (CSWETBYPASSN != 'b0), tms, TimingViol12_10);
	$setup(posedge M[11], edge[01,0x,x1,1x] CK &&& (CSWETBYPASSN != 'b0), tms, TimingViol12_11);
	$setup(posedge M[12], edge[01,0x,x1,1x] CK &&& (CSWETBYPASSN != 'b0), tms, TimingViol12_12);
	$setup(posedge M[13], edge[01,0x,x1,1x] CK &&& (CSWETBYPASSN != 'b0), tms, TimingViol12_13);
	$setup(posedge M[14], edge[01,0x,x1,1x] CK &&& (CSWETBYPASSN != 'b0), tms, TimingViol12_14);
	$setup(posedge M[15], edge[01,0x,x1,1x] CK &&& (CSWETBYPASSN != 'b0), tms, TimingViol12_15);
	$setup(posedge M[16], edge[01,0x,x1,1x] CK &&& (CSWETBYPASSN != 'b0), tms, TimingViol12_16);
	$setup(posedge M[17], edge[01,0x,x1,1x] CK &&& (CSWETBYPASSN != 'b0), tms, TimingViol12_17);
	$setup(posedge M[18], edge[01,0x,x1,1x] CK &&& (CSWETBYPASSN != 'b0), tms, TimingViol12_18);
	$setup(posedge M[19], edge[01,0x,x1,1x] CK &&& (CSWETBYPASSN != 'b0), tms, TimingViol12_19);
	$setup(posedge M[20], edge[01,0x,x1,1x] CK &&& (CSWETBYPASSN != 'b0), tms, TimingViol12_20);
	$setup(posedge M[21], edge[01,0x,x1,1x] CK &&& (CSWETBYPASSN != 'b0), tms, TimingViol12_21);
	$setup(posedge M[22], edge[01,0x,x1,1x] CK &&& (CSWETBYPASSN != 'b0), tms, TimingViol12_22);
	$setup(posedge M[23], edge[01,0x,x1,1x] CK &&& (CSWETBYPASSN != 'b0), tms, TimingViol12_23);
	$setup(posedge M[24], edge[01,0x,x1,1x] CK &&& (CSWETBYPASSN != 'b0), tms, TimingViol12_24);
	$setup(posedge M[25], edge[01,0x,x1,1x] CK &&& (CSWETBYPASSN != 'b0), tms, TimingViol12_25);
	$setup(posedge M[26], edge[01,0x,x1,1x] CK &&& (CSWETBYPASSN != 'b0), tms, TimingViol12_26);
	$setup(posedge M[27], edge[01,0x,x1,1x] CK &&& (CSWETBYPASSN != 'b0), tms, TimingViol12_27);
	$setup(posedge M[28], edge[01,0x,x1,1x] CK &&& (CSWETBYPASSN != 'b0), tms, TimingViol12_28);
	$setup(posedge M[29], edge[01,0x,x1,1x] CK &&& (CSWETBYPASSN != 'b0), tms, TimingViol12_29);
	$setup(posedge M[30], edge[01,0x,x1,1x] CK &&& (CSWETBYPASSN != 'b0), tms, TimingViol12_30);
	$setup(posedge M[31], edge[01,0x,x1,1x] CK &&& (CSWETBYPASSN != 'b0), tms, TimingViol12_31);
	$setup(negedge M[0], edge[01,0x,x1,1x] CK &&& (CSWETBYPASSN != 'b0), tms, TimingViol12_0);
	$setup(negedge M[1], edge[01,0x,x1,1x] CK &&& (CSWETBYPASSN != 'b0), tms, TimingViol12_1);
	$setup(negedge M[2], edge[01,0x,x1,1x] CK &&& (CSWETBYPASSN != 'b0), tms, TimingViol12_2);
	$setup(negedge M[3], edge[01,0x,x1,1x] CK &&& (CSWETBYPASSN != 'b0), tms, TimingViol12_3);
	$setup(negedge M[4], edge[01,0x,x1,1x] CK &&& (CSWETBYPASSN != 'b0), tms, TimingViol12_4);
	$setup(negedge M[5], edge[01,0x,x1,1x] CK &&& (CSWETBYPASSN != 'b0), tms, TimingViol12_5);
	$setup(negedge M[6], edge[01,0x,x1,1x] CK &&& (CSWETBYPASSN != 'b0), tms, TimingViol12_6);
	$setup(negedge M[7], edge[01,0x,x1,1x] CK &&& (CSWETBYPASSN != 'b0), tms, TimingViol12_7);
	$setup(negedge M[8], edge[01,0x,x1,1x] CK &&& (CSWETBYPASSN != 'b0), tms, TimingViol12_8);
	$setup(negedge M[9], edge[01,0x,x1,1x] CK &&& (CSWETBYPASSN != 'b0), tms, TimingViol12_9);
	$setup(negedge M[10], edge[01,0x,x1,1x] CK &&& (CSWETBYPASSN != 'b0), tms, TimingViol12_10);
	$setup(negedge M[11], edge[01,0x,x1,1x] CK &&& (CSWETBYPASSN != 'b0), tms, TimingViol12_11);
	$setup(negedge M[12], edge[01,0x,x1,1x] CK &&& (CSWETBYPASSN != 'b0), tms, TimingViol12_12);
	$setup(negedge M[13], edge[01,0x,x1,1x] CK &&& (CSWETBYPASSN != 'b0), tms, TimingViol12_13);
	$setup(negedge M[14], edge[01,0x,x1,1x] CK &&& (CSWETBYPASSN != 'b0), tms, TimingViol12_14);
	$setup(negedge M[15], edge[01,0x,x1,1x] CK &&& (CSWETBYPASSN != 'b0), tms, TimingViol12_15);
	$setup(negedge M[16], edge[01,0x,x1,1x] CK &&& (CSWETBYPASSN != 'b0), tms, TimingViol12_16);
	$setup(negedge M[17], edge[01,0x,x1,1x] CK &&& (CSWETBYPASSN != 'b0), tms, TimingViol12_17);
	$setup(negedge M[18], edge[01,0x,x1,1x] CK &&& (CSWETBYPASSN != 'b0), tms, TimingViol12_18);
	$setup(negedge M[19], edge[01,0x,x1,1x] CK &&& (CSWETBYPASSN != 'b0), tms, TimingViol12_19);
	$setup(negedge M[20], edge[01,0x,x1,1x] CK &&& (CSWETBYPASSN != 'b0), tms, TimingViol12_20);
	$setup(negedge M[21], edge[01,0x,x1,1x] CK &&& (CSWETBYPASSN != 'b0), tms, TimingViol12_21);
	$setup(negedge M[22], edge[01,0x,x1,1x] CK &&& (CSWETBYPASSN != 'b0), tms, TimingViol12_22);
	$setup(negedge M[23], edge[01,0x,x1,1x] CK &&& (CSWETBYPASSN != 'b0), tms, TimingViol12_23);
	$setup(negedge M[24], edge[01,0x,x1,1x] CK &&& (CSWETBYPASSN != 'b0), tms, TimingViol12_24);
	$setup(negedge M[25], edge[01,0x,x1,1x] CK &&& (CSWETBYPASSN != 'b0), tms, TimingViol12_25);
	$setup(negedge M[26], edge[01,0x,x1,1x] CK &&& (CSWETBYPASSN != 'b0), tms, TimingViol12_26);
	$setup(negedge M[27], edge[01,0x,x1,1x] CK &&& (CSWETBYPASSN != 'b0), tms, TimingViol12_27);
	$setup(negedge M[28], edge[01,0x,x1,1x] CK &&& (CSWETBYPASSN != 'b0), tms, TimingViol12_28);
	$setup(negedge M[29], edge[01,0x,x1,1x] CK &&& (CSWETBYPASSN != 'b0), tms, TimingViol12_29);
	$setup(negedge M[30], edge[01,0x,x1,1x] CK &&& (CSWETBYPASSN != 'b0), tms, TimingViol12_30);
	$setup(negedge M[31], edge[01,0x,x1,1x] CK &&& (CSWETBYPASSN != 'b0), tms, TimingViol12_31);
	$hold(edge[01,0x,x1,x0] CK &&& (CSWETBYPASSN != 'b0), posedge M[0], tmh, TimingViol13_0);
	$hold(edge[01,0x,x1,x0] CK &&& (CSWETBYPASSN != 'b0), posedge M[1], tmh, TimingViol13_1);
	$hold(edge[01,0x,x1,x0] CK &&& (CSWETBYPASSN != 'b0), posedge M[2], tmh, TimingViol13_2);
	$hold(edge[01,0x,x1,x0] CK &&& (CSWETBYPASSN != 'b0), posedge M[3], tmh, TimingViol13_3);
	$hold(edge[01,0x,x1,x0] CK &&& (CSWETBYPASSN != 'b0), posedge M[4], tmh, TimingViol13_4);
	$hold(edge[01,0x,x1,x0] CK &&& (CSWETBYPASSN != 'b0), posedge M[5], tmh, TimingViol13_5);
	$hold(edge[01,0x,x1,x0] CK &&& (CSWETBYPASSN != 'b0), posedge M[6], tmh, TimingViol13_6);
	$hold(edge[01,0x,x1,x0] CK &&& (CSWETBYPASSN != 'b0), posedge M[7], tmh, TimingViol13_7);
	$hold(edge[01,0x,x1,x0] CK &&& (CSWETBYPASSN != 'b0), posedge M[8], tmh, TimingViol13_8);
	$hold(edge[01,0x,x1,x0] CK &&& (CSWETBYPASSN != 'b0), posedge M[9], tmh, TimingViol13_9);
	$hold(edge[01,0x,x1,x0] CK &&& (CSWETBYPASSN != 'b0), posedge M[10], tmh, TimingViol13_10);
	$hold(edge[01,0x,x1,x0] CK &&& (CSWETBYPASSN != 'b0), posedge M[11], tmh, TimingViol13_11);
	$hold(edge[01,0x,x1,x0] CK &&& (CSWETBYPASSN != 'b0), posedge M[12], tmh, TimingViol13_12);
	$hold(edge[01,0x,x1,x0] CK &&& (CSWETBYPASSN != 'b0), posedge M[13], tmh, TimingViol13_13);
	$hold(edge[01,0x,x1,x0] CK &&& (CSWETBYPASSN != 'b0), posedge M[14], tmh, TimingViol13_14);
	$hold(edge[01,0x,x1,x0] CK &&& (CSWETBYPASSN != 'b0), posedge M[15], tmh, TimingViol13_15);
	$hold(edge[01,0x,x1,x0] CK &&& (CSWETBYPASSN != 'b0), posedge M[16], tmh, TimingViol13_16);
	$hold(edge[01,0x,x1,x0] CK &&& (CSWETBYPASSN != 'b0), posedge M[17], tmh, TimingViol13_17);
	$hold(edge[01,0x,x1,x0] CK &&& (CSWETBYPASSN != 'b0), posedge M[18], tmh, TimingViol13_18);
	$hold(edge[01,0x,x1,x0] CK &&& (CSWETBYPASSN != 'b0), posedge M[19], tmh, TimingViol13_19);
	$hold(edge[01,0x,x1,x0] CK &&& (CSWETBYPASSN != 'b0), posedge M[20], tmh, TimingViol13_20);
	$hold(edge[01,0x,x1,x0] CK &&& (CSWETBYPASSN != 'b0), posedge M[21], tmh, TimingViol13_21);
	$hold(edge[01,0x,x1,x0] CK &&& (CSWETBYPASSN != 'b0), posedge M[22], tmh, TimingViol13_22);
	$hold(edge[01,0x,x1,x0] CK &&& (CSWETBYPASSN != 'b0), posedge M[23], tmh, TimingViol13_23);
	$hold(edge[01,0x,x1,x0] CK &&& (CSWETBYPASSN != 'b0), posedge M[24], tmh, TimingViol13_24);
	$hold(edge[01,0x,x1,x0] CK &&& (CSWETBYPASSN != 'b0), posedge M[25], tmh, TimingViol13_25);
	$hold(edge[01,0x,x1,x0] CK &&& (CSWETBYPASSN != 'b0), posedge M[26], tmh, TimingViol13_26);
	$hold(edge[01,0x,x1,x0] CK &&& (CSWETBYPASSN != 'b0), posedge M[27], tmh, TimingViol13_27);
	$hold(edge[01,0x,x1,x0] CK &&& (CSWETBYPASSN != 'b0), posedge M[28], tmh, TimingViol13_28);
	$hold(edge[01,0x,x1,x0] CK &&& (CSWETBYPASSN != 'b0), posedge M[29], tmh, TimingViol13_29);
	$hold(edge[01,0x,x1,x0] CK &&& (CSWETBYPASSN != 'b0), posedge M[30], tmh, TimingViol13_30);
	$hold(edge[01,0x,x1,x0] CK &&& (CSWETBYPASSN != 'b0), posedge M[31], tmh, TimingViol13_31);
	$hold(edge[01,0x,x1,x0] CK &&& (CSWETBYPASSN != 'b0), negedge M[0], tmh, TimingViol13_0);
	$hold(edge[01,0x,x1,x0] CK &&& (CSWETBYPASSN != 'b0), negedge M[1], tmh, TimingViol13_1);
	$hold(edge[01,0x,x1,x0] CK &&& (CSWETBYPASSN != 'b0), negedge M[2], tmh, TimingViol13_2);
	$hold(edge[01,0x,x1,x0] CK &&& (CSWETBYPASSN != 'b0), negedge M[3], tmh, TimingViol13_3);
	$hold(edge[01,0x,x1,x0] CK &&& (CSWETBYPASSN != 'b0), negedge M[4], tmh, TimingViol13_4);
	$hold(edge[01,0x,x1,x0] CK &&& (CSWETBYPASSN != 'b0), negedge M[5], tmh, TimingViol13_5);
	$hold(edge[01,0x,x1,x0] CK &&& (CSWETBYPASSN != 'b0), negedge M[6], tmh, TimingViol13_6);
	$hold(edge[01,0x,x1,x0] CK &&& (CSWETBYPASSN != 'b0), negedge M[7], tmh, TimingViol13_7);
	$hold(edge[01,0x,x1,x0] CK &&& (CSWETBYPASSN != 'b0), negedge M[8], tmh, TimingViol13_8);
	$hold(edge[01,0x,x1,x0] CK &&& (CSWETBYPASSN != 'b0), negedge M[9], tmh, TimingViol13_9);
	$hold(edge[01,0x,x1,x0] CK &&& (CSWETBYPASSN != 'b0), negedge M[10], tmh, TimingViol13_10);
	$hold(edge[01,0x,x1,x0] CK &&& (CSWETBYPASSN != 'b0), negedge M[11], tmh, TimingViol13_11);
	$hold(edge[01,0x,x1,x0] CK &&& (CSWETBYPASSN != 'b0), negedge M[12], tmh, TimingViol13_12);
	$hold(edge[01,0x,x1,x0] CK &&& (CSWETBYPASSN != 'b0), negedge M[13], tmh, TimingViol13_13);
	$hold(edge[01,0x,x1,x0] CK &&& (CSWETBYPASSN != 'b0), negedge M[14], tmh, TimingViol13_14);
	$hold(edge[01,0x,x1,x0] CK &&& (CSWETBYPASSN != 'b0), negedge M[15], tmh, TimingViol13_15);
	$hold(edge[01,0x,x1,x0] CK &&& (CSWETBYPASSN != 'b0), negedge M[16], tmh, TimingViol13_16);
	$hold(edge[01,0x,x1,x0] CK &&& (CSWETBYPASSN != 'b0), negedge M[17], tmh, TimingViol13_17);
	$hold(edge[01,0x,x1,x0] CK &&& (CSWETBYPASSN != 'b0), negedge M[18], tmh, TimingViol13_18);
	$hold(edge[01,0x,x1,x0] CK &&& (CSWETBYPASSN != 'b0), negedge M[19], tmh, TimingViol13_19);
	$hold(edge[01,0x,x1,x0] CK &&& (CSWETBYPASSN != 'b0), negedge M[20], tmh, TimingViol13_20);
	$hold(edge[01,0x,x1,x0] CK &&& (CSWETBYPASSN != 'b0), negedge M[21], tmh, TimingViol13_21);
	$hold(edge[01,0x,x1,x0] CK &&& (CSWETBYPASSN != 'b0), negedge M[22], tmh, TimingViol13_22);
	$hold(edge[01,0x,x1,x0] CK &&& (CSWETBYPASSN != 'b0), negedge M[23], tmh, TimingViol13_23);
	$hold(edge[01,0x,x1,x0] CK &&& (CSWETBYPASSN != 'b0), negedge M[24], tmh, TimingViol13_24);
	$hold(edge[01,0x,x1,x0] CK &&& (CSWETBYPASSN != 'b0), negedge M[25], tmh, TimingViol13_25);
	$hold(edge[01,0x,x1,x0] CK &&& (CSWETBYPASSN != 'b0), negedge M[26], tmh, TimingViol13_26);
	$hold(edge[01,0x,x1,x0] CK &&& (CSWETBYPASSN != 'b0), negedge M[27], tmh, TimingViol13_27);
	$hold(edge[01,0x,x1,x0] CK &&& (CSWETBYPASSN != 'b0), negedge M[28], tmh, TimingViol13_28);
	$hold(edge[01,0x,x1,x0] CK &&& (CSWETBYPASSN != 'b0), negedge M[29], tmh, TimingViol13_29);
	$hold(edge[01,0x,x1,x0] CK &&& (CSWETBYPASSN != 'b0), negedge M[30], tmh, TimingViol13_30);
	$hold(edge[01,0x,x1,x0] CK &&& (CSWETBYPASSN != 'b0), negedge M[31], tmh, TimingViol13_31);

        
        $setup(posedge CSN, edge[01,0x,x1,1x] CK &&& TBYPASSint != 1'b1, tps, TimingViol4);
	$setup(negedge CSN, edge[01,0x,x1,1x] CK &&& TBYPASSint != 1'b1, tps, TimingViol4);
	$hold(edge[01,0x,x1,x0] CK &&& TBYPASSint != 1'b1, posedge CSN, tph, TimingViol5);
	$hold(edge[01,0x,x1,x0] CK &&& TBYPASSint != 1'b1, negedge CSN, tph, TimingViol5);
        $setup(posedge WEN, edge[01,0x,x1,1x] CK &&& (CSTBYPASSN != 'b0), tws, TimingViol6);
        $setup(negedge WEN, edge[01,0x,x1,1x] CK &&& (CSTBYPASSN != 'b0), tws, TimingViol6);
        $hold(edge[01,0x,x1,x0] CK &&& (CSTBYPASSN != 'b0), posedge WEN, twh, TimingViol7);
        $hold(edge[01,0x,x1,x0] CK &&& (CSTBYPASSN != 'b0), negedge WEN, twh, TimingViol7);
        

        $period(posedge CK &&& (csn_tcycle != 0), tcycle, TimingViol10); 
        $period(posedge CK &&& (CS_taa != 0), tcycle_taa, TimingViol10_taa);
        $width(posedge CK &&& (csn_tckh != 'b0), tckh, 0, TimingViol8);
        $width(negedge CK &&& (csn_tckl != 'b0), tckl, 0, TimingViol9);
        
        // TBYPASS setup/hold violations
        $setup(posedge TBYPASS, posedge CK &&& (CS != 0),ttms, TimingViol_ttms_ttmh);
        $setup(negedge TBYPASS, posedge CK &&& (CS != 0),ttms, TimingViol_ttms_ttmh);

        $hold(posedge CK &&& (CS != 1'b0), posedge TBYPASS, ttmh, TimingViol_ttms_ttmh);
        $hold(posedge CK &&& (CS != 1'b0), negedge TBYPASS, ttmh, TimingViol_ttms_ttmh); 



        $period(posedge CK &&& (CS_taa_ry != 0), tcycle_taa_ry, TimingViol10_taa_ry);
        $width(negedge CK &&& (csn_tckl_ry!= 0), tckl_tck_ry, 0, TimingViol9_tck_ry);


        
	endspecify

always @(CKint)
begin
   CKreg <= CKint;
end

always @(posedge CKint)
begin
   if (CSNint !== 1)
   begin
      Dreg = Dint;
      Mreg = Mint;
      WENreg = WENint;
      Areg = Aint;
   end
   CSNreg = CSNint;
   if (CSNint === 1'b1)
      tckh_flag = 0;
   else
      tckh_flag = 1;
        
tckl_flag = 1;
end
     
always @(negedge CKint)
begin
   #0.00   tckh_flag = 1;
   if (CSNint === 1)
      tckl_flag = 0;
   else
      tckl_flag = 1;
end
     
always @(CSNint)
begin
   if (CKint !== 1)
      tckl_flag = ~CSNint;
end

always @(TimingViol10_taa)
begin
   if(debug_level < 2)
   $display("%m - %t WARNING: READ/WRITE ACCESS TIME IS GREATER THAN THE CLOCK PERIOD",$realtime);
end

// conversion from registers to array elements for mask setup violation notifiers


always @(TimingViol12_31)
begin
   TimingViol12[31] = TimingViol12_31;
end


always @(TimingViol12_30)
begin
   TimingViol12[30] = TimingViol12_30;
end


always @(TimingViol12_29)
begin
   TimingViol12[29] = TimingViol12_29;
end


always @(TimingViol12_28)
begin
   TimingViol12[28] = TimingViol12_28;
end


always @(TimingViol12_27)
begin
   TimingViol12[27] = TimingViol12_27;
end


always @(TimingViol12_26)
begin
   TimingViol12[26] = TimingViol12_26;
end


always @(TimingViol12_25)
begin
   TimingViol12[25] = TimingViol12_25;
end


always @(TimingViol12_24)
begin
   TimingViol12[24] = TimingViol12_24;
end


always @(TimingViol12_23)
begin
   TimingViol12[23] = TimingViol12_23;
end


always @(TimingViol12_22)
begin
   TimingViol12[22] = TimingViol12_22;
end


always @(TimingViol12_21)
begin
   TimingViol12[21] = TimingViol12_21;
end


always @(TimingViol12_20)
begin
   TimingViol12[20] = TimingViol12_20;
end


always @(TimingViol12_19)
begin
   TimingViol12[19] = TimingViol12_19;
end


always @(TimingViol12_18)
begin
   TimingViol12[18] = TimingViol12_18;
end


always @(TimingViol12_17)
begin
   TimingViol12[17] = TimingViol12_17;
end


always @(TimingViol12_16)
begin
   TimingViol12[16] = TimingViol12_16;
end


always @(TimingViol12_15)
begin
   TimingViol12[15] = TimingViol12_15;
end


always @(TimingViol12_14)
begin
   TimingViol12[14] = TimingViol12_14;
end


always @(TimingViol12_13)
begin
   TimingViol12[13] = TimingViol12_13;
end


always @(TimingViol12_12)
begin
   TimingViol12[12] = TimingViol12_12;
end


always @(TimingViol12_11)
begin
   TimingViol12[11] = TimingViol12_11;
end


always @(TimingViol12_10)
begin
   TimingViol12[10] = TimingViol12_10;
end


always @(TimingViol12_9)
begin
   TimingViol12[9] = TimingViol12_9;
end


always @(TimingViol12_8)
begin
   TimingViol12[8] = TimingViol12_8;
end


always @(TimingViol12_7)
begin
   TimingViol12[7] = TimingViol12_7;
end


always @(TimingViol12_6)
begin
   TimingViol12[6] = TimingViol12_6;
end


always @(TimingViol12_5)
begin
   TimingViol12[5] = TimingViol12_5;
end


always @(TimingViol12_4)
begin
   TimingViol12[4] = TimingViol12_4;
end


always @(TimingViol12_3)
begin
   TimingViol12[3] = TimingViol12_3;
end


always @(TimingViol12_2)
begin
   TimingViol12[2] = TimingViol12_2;
end


always @(TimingViol12_1)
begin
   TimingViol12[1] = TimingViol12_1;
end


always @(TimingViol12_0)
begin
   TimingViol12[0] = TimingViol12_0;
end



// conversion from registers to array elements for mask hold violation notifiers


always @(TimingViol13_31)
begin
   TimingViol13[31] = TimingViol13_31;
end


always @(TimingViol13_30)
begin
   TimingViol13[30] = TimingViol13_30;
end


always @(TimingViol13_29)
begin
   TimingViol13[29] = TimingViol13_29;
end


always @(TimingViol13_28)
begin
   TimingViol13[28] = TimingViol13_28;
end


always @(TimingViol13_27)
begin
   TimingViol13[27] = TimingViol13_27;
end


always @(TimingViol13_26)
begin
   TimingViol13[26] = TimingViol13_26;
end


always @(TimingViol13_25)
begin
   TimingViol13[25] = TimingViol13_25;
end


always @(TimingViol13_24)
begin
   TimingViol13[24] = TimingViol13_24;
end


always @(TimingViol13_23)
begin
   TimingViol13[23] = TimingViol13_23;
end


always @(TimingViol13_22)
begin
   TimingViol13[22] = TimingViol13_22;
end


always @(TimingViol13_21)
begin
   TimingViol13[21] = TimingViol13_21;
end


always @(TimingViol13_20)
begin
   TimingViol13[20] = TimingViol13_20;
end


always @(TimingViol13_19)
begin
   TimingViol13[19] = TimingViol13_19;
end


always @(TimingViol13_18)
begin
   TimingViol13[18] = TimingViol13_18;
end


always @(TimingViol13_17)
begin
   TimingViol13[17] = TimingViol13_17;
end


always @(TimingViol13_16)
begin
   TimingViol13[16] = TimingViol13_16;
end


always @(TimingViol13_15)
begin
   TimingViol13[15] = TimingViol13_15;
end


always @(TimingViol13_14)
begin
   TimingViol13[14] = TimingViol13_14;
end


always @(TimingViol13_13)
begin
   TimingViol13[13] = TimingViol13_13;
end


always @(TimingViol13_12)
begin
   TimingViol13[12] = TimingViol13_12;
end


always @(TimingViol13_11)
begin
   TimingViol13[11] = TimingViol13_11;
end


always @(TimingViol13_10)
begin
   TimingViol13[10] = TimingViol13_10;
end


always @(TimingViol13_9)
begin
   TimingViol13[9] = TimingViol13_9;
end


always @(TimingViol13_8)
begin
   TimingViol13[8] = TimingViol13_8;
end


always @(TimingViol13_7)
begin
   TimingViol13[7] = TimingViol13_7;
end


always @(TimingViol13_6)
begin
   TimingViol13[6] = TimingViol13_6;
end


always @(TimingViol13_5)
begin
   TimingViol13[5] = TimingViol13_5;
end


always @(TimingViol13_4)
begin
   TimingViol13[4] = TimingViol13_4;
end


always @(TimingViol13_3)
begin
   TimingViol13[3] = TimingViol13_3;
end


always @(TimingViol13_2)
begin
   TimingViol13[2] = TimingViol13_2;
end


always @(TimingViol13_1)
begin
   TimingViol13[1] = TimingViol13_1;
end


always @(TimingViol13_0)
begin
   TimingViol13[0] = TimingViol13_0;
end



// conversion from registers to array elements for data setup violation notifiers

always @(TimingViol2_31)
begin
   TimingViol2[31] = TimingViol2_31;
end


always @(TimingViol2_30)
begin
   TimingViol2[30] = TimingViol2_30;
end


always @(TimingViol2_29)
begin
   TimingViol2[29] = TimingViol2_29;
end


always @(TimingViol2_28)
begin
   TimingViol2[28] = TimingViol2_28;
end


always @(TimingViol2_27)
begin
   TimingViol2[27] = TimingViol2_27;
end


always @(TimingViol2_26)
begin
   TimingViol2[26] = TimingViol2_26;
end


always @(TimingViol2_25)
begin
   TimingViol2[25] = TimingViol2_25;
end


always @(TimingViol2_24)
begin
   TimingViol2[24] = TimingViol2_24;
end


always @(TimingViol2_23)
begin
   TimingViol2[23] = TimingViol2_23;
end


always @(TimingViol2_22)
begin
   TimingViol2[22] = TimingViol2_22;
end


always @(TimingViol2_21)
begin
   TimingViol2[21] = TimingViol2_21;
end


always @(TimingViol2_20)
begin
   TimingViol2[20] = TimingViol2_20;
end


always @(TimingViol2_19)
begin
   TimingViol2[19] = TimingViol2_19;
end


always @(TimingViol2_18)
begin
   TimingViol2[18] = TimingViol2_18;
end


always @(TimingViol2_17)
begin
   TimingViol2[17] = TimingViol2_17;
end


always @(TimingViol2_16)
begin
   TimingViol2[16] = TimingViol2_16;
end


always @(TimingViol2_15)
begin
   TimingViol2[15] = TimingViol2_15;
end


always @(TimingViol2_14)
begin
   TimingViol2[14] = TimingViol2_14;
end


always @(TimingViol2_13)
begin
   TimingViol2[13] = TimingViol2_13;
end


always @(TimingViol2_12)
begin
   TimingViol2[12] = TimingViol2_12;
end


always @(TimingViol2_11)
begin
   TimingViol2[11] = TimingViol2_11;
end


always @(TimingViol2_10)
begin
   TimingViol2[10] = TimingViol2_10;
end


always @(TimingViol2_9)
begin
   TimingViol2[9] = TimingViol2_9;
end


always @(TimingViol2_8)
begin
   TimingViol2[8] = TimingViol2_8;
end


always @(TimingViol2_7)
begin
   TimingViol2[7] = TimingViol2_7;
end


always @(TimingViol2_6)
begin
   TimingViol2[6] = TimingViol2_6;
end


always @(TimingViol2_5)
begin
   TimingViol2[5] = TimingViol2_5;
end


always @(TimingViol2_4)
begin
   TimingViol2[4] = TimingViol2_4;
end


always @(TimingViol2_3)
begin
   TimingViol2[3] = TimingViol2_3;
end


always @(TimingViol2_2)
begin
   TimingViol2[2] = TimingViol2_2;
end


always @(TimingViol2_1)
begin
   TimingViol2[1] = TimingViol2_1;
end


always @(TimingViol2_0)
begin
   TimingViol2[0] = TimingViol2_0;
end


// conversion from registers to array elements for data hold violation notifiers

always @(TimingViol3_31)
begin
   TimingViol3[31] = TimingViol3_31;
end


always @(TimingViol3_30)
begin
   TimingViol3[30] = TimingViol3_30;
end


always @(TimingViol3_29)
begin
   TimingViol3[29] = TimingViol3_29;
end


always @(TimingViol3_28)
begin
   TimingViol3[28] = TimingViol3_28;
end


always @(TimingViol3_27)
begin
   TimingViol3[27] = TimingViol3_27;
end


always @(TimingViol3_26)
begin
   TimingViol3[26] = TimingViol3_26;
end


always @(TimingViol3_25)
begin
   TimingViol3[25] = TimingViol3_25;
end


always @(TimingViol3_24)
begin
   TimingViol3[24] = TimingViol3_24;
end


always @(TimingViol3_23)
begin
   TimingViol3[23] = TimingViol3_23;
end


always @(TimingViol3_22)
begin
   TimingViol3[22] = TimingViol3_22;
end


always @(TimingViol3_21)
begin
   TimingViol3[21] = TimingViol3_21;
end


always @(TimingViol3_20)
begin
   TimingViol3[20] = TimingViol3_20;
end


always @(TimingViol3_19)
begin
   TimingViol3[19] = TimingViol3_19;
end


always @(TimingViol3_18)
begin
   TimingViol3[18] = TimingViol3_18;
end


always @(TimingViol3_17)
begin
   TimingViol3[17] = TimingViol3_17;
end


always @(TimingViol3_16)
begin
   TimingViol3[16] = TimingViol3_16;
end


always @(TimingViol3_15)
begin
   TimingViol3[15] = TimingViol3_15;
end


always @(TimingViol3_14)
begin
   TimingViol3[14] = TimingViol3_14;
end


always @(TimingViol3_13)
begin
   TimingViol3[13] = TimingViol3_13;
end


always @(TimingViol3_12)
begin
   TimingViol3[12] = TimingViol3_12;
end


always @(TimingViol3_11)
begin
   TimingViol3[11] = TimingViol3_11;
end


always @(TimingViol3_10)
begin
   TimingViol3[10] = TimingViol3_10;
end


always @(TimingViol3_9)
begin
   TimingViol3[9] = TimingViol3_9;
end


always @(TimingViol3_8)
begin
   TimingViol3[8] = TimingViol3_8;
end


always @(TimingViol3_7)
begin
   TimingViol3[7] = TimingViol3_7;
end


always @(TimingViol3_6)
begin
   TimingViol3[6] = TimingViol3_6;
end


always @(TimingViol3_5)
begin
   TimingViol3[5] = TimingViol3_5;
end


always @(TimingViol3_4)
begin
   TimingViol3[4] = TimingViol3_4;
end


always @(TimingViol3_3)
begin
   TimingViol3[3] = TimingViol3_3;
end


always @(TimingViol3_2)
begin
   TimingViol3[2] = TimingViol3_2;
end


always @(TimingViol3_1)
begin
   TimingViol3[1] = TimingViol3_1;
end


always @(TimingViol3_0)
begin
   TimingViol3[0] = TimingViol3_0;
end




ST_SPHDL_1216x32m16_bL_main ST_SPHDL_1216x32m16_bL_maininst ( Q_glitchint,  Q_dataint, Q_gCKint, RY_rfCKint, RY_rrCKint, RY_frCKint, ICRYint, delTBYPASSint, TBYPASS_D_Qint, TBYPASS_mainint, CKint,  CSNint , TBYPASSint, WENint,  Aint, Dint, Mint, debug_level  , TimingViol0, TimingViol1, TimingViol2, TimingViol3, TimingViol4, TimingViol5, TimingViol6, TimingViol7, TimingViol8, TimingViol9, TimingViol10, TimingViol_ttms_ttmh, TimingViol12, TimingViol13      );

ST_SPHDL_1216x32m16_bL_OPschlr ST_SPHDL_1216x32m16_bL_OPschlrinst (Qint, RYint,  Q_gCKint, Q_glitchint,  Q_dataint, RY_rfCKint, RY_rrCKint, RY_frCKint, ICRYint, delTBYPASSint, TBYPASS_D_Qint, TBYPASS_mainint  );

defparam ST_SPHDL_1216x32m16_bL_maininst.Fault_file_name = Fault_file_name;
defparam ST_SPHDL_1216x32m16_bL_maininst.ConfigFault = ConfigFault;
defparam ST_SPHDL_1216x32m16_bL_maininst.max_faults = max_faults;
defparam ST_SPHDL_1216x32m16_bL_maininst.MEM_INITIALIZE = MEM_INITIALIZE;
defparam ST_SPHDL_1216x32m16_bL_maininst.BinaryInit = BinaryInit;
defparam ST_SPHDL_1216x32m16_bL_maininst.InitFileName = InitFileName;

endmodule

`endif

`delay_mode_path
`disable_portfaults
`nosuppress_faults
`endcelldefine










/****************************************************************
--  Description         : verilog_model for ST_SPHDL cmos65
--  ModelVersion        : 4.4
--  Date                : Jun, 2008
--  Changes Made by	: DRM
--
****************************************************************/

/******************** START OF HEADER****************************
   This Header Gives Information about the parameters & options present in the Model

   words = 160
   bits  = 64
   mux   = 8 
   
   
   
   
   
   

**********************END OF HEADER ******************************/



`ifdef slm
        `define functional
`endif
`celldefine
`suppress_faults
`enable_portfaults
`ifdef functional
   `timescale 1ns / 1ns
   `delay_mode_unit
`endif

`ifdef functional



module ST_SPHDL_160x64m8_L (Q, RY,CK, CSN, TBYPASS, WEN, A, D    );   
 
    parameter
        Fault_file_name = "ST_SPHDL_160x64m8_L_faults.txt",
        ConfigFault = 0,
        max_faults = 20,
        MEM_INITIALIZE  = 1'b0,
        BinaryInit = 1'b0,
        InitFileName = "ST_SPHDL_160x64m8_L.cde",
        Corruption_Read_Violation = 1,
        Debug_mode = "all_warning_mode",
        InstancePath = "ST_SPHDL_160x64m8_L";
    
    parameter
        Words = 160,
        Bits = 64,
        Addr = 8,
        mux = 8,
        Rows = Words/mux;




   


    parameter
        WordX = 64'bx,
        AddrX = 8'bx,
        Word0 = 64'b0,
        X = 1'bx;


	output [Bits-1 : 0] Q;
        
        output RY;   
        
        input [Bits-1 : 0] D;
	input [Addr-1 : 0] A;
	        
        input CK, CSN, TBYPASS, WEN;

        
        
        

        



        reg [Bits-1 : 0] Qint;
         
           
	wire [Bits-1 : 0] Dint,Mint;
        
        assign Mint=64'b0;
        
        wire [Addr-1 : 0] Aint;
	wire CKint;
	wire CSNint;
	wire WENint;

        
        	
        wire TBYPASSint;
        

        
        wire RYint;
          
          
           buf (RY, RYint);  
         
        reg RY_outreg, RY_out;
           
        assign RYint = RY_out;

        
        
        
        // REG DECLARATION
        
	//Output Register for tbypass
        reg [Bits-1 : 0] tbydata;
        //delayed Output Register
        reg [Bits-1 : 0] delOutReg_data;
        reg [Bits-1 : 0] OutReg_data;   // Data Output register
	reg [Bits-1 : 0] tempMem;
	reg lastCK;
        reg CSNreg;	

        `ifdef slm
        `else
	reg [Bits-1 : 0] Mem [Words-1 : 0]; // RAM array
        `endif
	
	reg [Bits-1 :0] Mem_temp;
	reg ValidAddress;
	reg ValidDebugCode;
        

        
        reg WENreg;
        
        reg [1:0] debug_level;
        reg [8*10: 0] operating_mode;
        reg [8*44: 0] message_status;

        integer d, a, p, i, k, j, l;
        `ifdef slm
           integer MemAddr;
        `endif


        //************************************************************
        //****** CONFIG FAULT IMPLEMENTATION VARIABLES*************** 
        //************************************************************ 

        integer file_ptr, ret_val;
        integer fault_word;
        integer fault_bit;
        integer fcnt, Fault_in_memory;
        integer n, cnt, t;  
        integer FailureLocn [max_faults -1 :0];

        reg [100 : 0] stuck_at;
        reg [200 : 0] tempStr;
        reg [7:0] fault_char;
        reg [7:0] fault_char1; // 8 Bit File Pointer
        reg [Addr -1 : 0] std_fault_word;
        reg [max_faults -1 :0] fault_repair_flag;
        reg [max_faults -1 :0] repair_flag;
        reg [Bits - 1: 0] stuck_at_0fault [max_faults -1 : 0];
        reg [Bits - 1: 0] stuck_at_1fault [max_faults -1 : 0];
        reg [100 : 0] array_stuck_at[max_faults -1 : 0] ; 
        reg msgcnt;
        

        reg [Bits -1 : 0] stuck0;
        reg [Bits -1 : 0] stuck1;

        `ifdef slm
        reg [Bits -1 : 0] slm_temp_data;
        `endif
        

        integer flag_error;

        
          
          buf bufq [Bits-1:0] (Q,Qint);
        
        
        buf bufdata [Bits-1:0] (Dint,D);
        buf bufaddr [Addr-1:0] (Aint,A);
        
	buf (TBYPASSint, TBYPASS);
	buf (CKint, CK);
	
        //MEM_EN = CSN or  TBYPASS
        
        or (CSNint, CSN, TBYPASS);   
	
        buf (WENint, WEN);
        
        
        
        

        

// BEHAVIOURAL MODULE DESCRIPTION

task WriteMemX;
begin
   `ifdef slm
   $slm_ResetMemory(MemAddr, WordX);
   `else
    for (i = 0; i < Words; i = i + 1)
       Mem[i] = WordX;
   `endif        
end
endtask


task WriteOutX;                
begin
   OutReg_data= WordX;
end
endtask

task WriteCycle;                  
input [Addr-1 : 0] Address;
reg [Bits-1:0] tempReg1,tempReg2;
integer po,i;
begin

   tempReg1 = WordX;
   if (^Address !== X) begin
      if (ValidAddress) begin
      `ifdef slm
         $slm_ReadMemoryS(MemAddr, Address, tempReg1);
      `else
         tempReg1 = Mem[Address];
      `endif
            
         for (po=0;po<Bits;po=po+1) begin
            if (Mint[po] === 1'b0)
               tempReg1[po] = Dint[po];
            else if ((Mint[po] !== 1'b1) && (tempReg1[po] !== Dint[po]))
               tempReg1[po] = 1'bx;
         end                
      `ifdef slm
         $slm_WriteMemory(MemAddr, Address, tempReg1);
      `else
         Mem[Address] = tempReg1;
      `endif
      end//if (ValidAddress)
      else
         if(debug_level < 2) $display("%m - %t (MSG_ID 701) WARNING: Address Out Of Range. ",$realtime); 
   end //if (^Address !== X)
   else
   begin
      if(debug_level < 2) $display("%m - %t (MSG_ID 008) WARNING: Illegal Value on Address Bus. Memory Corrupted ",$realtime);
      WriteMemX;
   end
 end

endtask

task ReadCycle;
input [Addr-1 : 0] Address;
reg [Bits-1:0] MemData;
integer a;
begin
   if (ValidAddress)
   begin        
      `ifdef slm
       $slm_ReadMemory(MemAddr, Address, MemData);
      `else
      MemData = Mem[Address];
      `endif
   end //if (ValidAddress)  
                
   if(ValidAddress === X)
   begin
      if (Corruption_Read_Violation === 1)
      begin   
         if(debug_level < 2) $display("%m - %t (MSG_ID 008) WARNING: Illegal Value on Address Bus. Memory and Output Corrupted ",$realtime);
         WriteMemX;
      end
      else
         if(debug_level < 2) $display("%m - %t (MSG_ID 008) WARNING: Illegal Value on Address Bus. Output Corrupted ",$realtime);
      MemData = WordX;
   end                        
   else if (ValidAddress === 0)
   begin                        
      if(debug_level < 2) $display("%m - %t (MSG_ID 701) WARNING: Address Out Of Range. Output Corrupted ",$realtime); 
      MemData = WordX;
   end
   
   OutReg_data = MemData;
end
endtask

task wen_x_handler;
input [Addr-1 : 0] Address;
input [Bits-1 : 0] Mask;
reg [Bits-1 : 0] prev_data;
begin
   if(^Address !== X) begin
      if (Address < Words) begin
      `ifdef slm
         $slm_ReadMemoryS(MemAddr, Address, tempMem);
      `else
         tempMem = Mem[Address];
      `endif
         prev_data = tempMem;  
         for (j = 0;j< Bits; j=j+1) begin
            //calculating data to write in memory
            if (tempMem[j] !== Dint[j]) begin
               if (Mask[j] !== 1'b1) begin
                  tempMem[j] = 1'bx;
               end
            end
            //calculating data to write on output
            if (prev_data[j] !== OutReg_data[j]) begin
               OutReg_data[j]  = 1'bx;
            end
         end//for (j = 0;j< Bits;
      end
      else begin
         WriteOutX;
      end   
   end  //  if(^Address !== X)
   else begin
      WriteMemX;
      WriteOutX;
   end  //else  
`ifdef slm
   $slm_WriteMemory(MemAddr, Address, tempMem);
`else
   Mem[Address] = tempMem;
`endif
end
endtask
        

task task_insert_faults_in_memory;
begin
   Fault_in_memory = 1;
   for(i = 0;i< fcnt;i = i+ 1)
   begin
      if (fault_repair_flag[i] !== 1)
      begin
         Fault_in_memory = 0;
         if (array_stuck_at[i] === "sa0")
         begin
            `ifdef slm
            //Read first
            $slm_ReadMemoryS(MemAddr, FailureLocn[i], slm_temp_data);
            //operation
            slm_temp_data = slm_temp_data & stuck_at_0fault[i];
            //write back
            $slm_WriteMemoryS(MemAddr, FailureLocn[i], slm_temp_data);
            `else
            Mem[FailureLocn[i]] = Mem[FailureLocn[i]] & stuck_at_0fault[i];
            `endif
         end //if(array_stuck_at)
                                        
         if(array_stuck_at[i] === "sa1")
         begin
            `ifdef slm
            //Read first
            $slm_ReadMemoryS(MemAddr, FailureLocn[i], slm_temp_data);
            //operation
            slm_temp_data = slm_temp_data | stuck_at_1fault[i];
            //write back
            $slm_WriteMemoryS(MemAddr, FailureLocn[i], slm_temp_data);
            `else
            Mem[FailureLocn[i]] = Mem[FailureLocn[i]] | stuck_at_1fault[i]; 
            `endif
         end //if(array_stuck_at)
      end//if (fault_repair_flag
   end// for loop...
end
endtask






initial
begin
   // Define format for timing value
  $timeformat (-9, 2, " ns", 0);
  `ifdef slm
  $slm_RegisterMemory(MemAddr, Words, Bits);
  `endif   
  
  debug_level= 2'b0;
   message_status = "All Messages are Switched ON";
  `ifdef  NO_WARNING_MODE
     debug_level = 2'b10;
     message_status = "All Warning Messages are Switched OFF";
  `endif  
  `ifdef slm
     operating_mode = "SLM";
  `else
     operating_mode = "FUNCTIONAL";
  `endif
if(debug_level !== 2'b10) begin
  $display ("%mINFORMATION ");
  $display ("***************************************");
  $display ("The Model is Operating in %s MODE", operating_mode);
  $display ("%s", message_status);
  if(ConfigFault)
  $display ("Configurable Fault Functionality is ON");   
  else
  $display ("Configurable Fault Functionality is OFF");  
   
  $display ("***************************************");
end
  if (MEM_INITIALIZE === 1'b1)
  begin   
     `ifdef slm
        if (BinaryInit)
           $slm_LoadMemory(MemAddr, InitFileName, "VERILOG_BIN");
        else
           $slm_LoadMemory(MemAddr, InitFileName, "VERILOG_HEX");

     `else
        if (BinaryInit)
           $readmemb(InitFileName, Mem, 0, Words-1);
        else
           $readmemh(InitFileName, Mem, 0, Words-1);
     `endif
  end

  
  RY_out = 1'b1;


        
/*  -----------Implemetation for config fault starts------*/
   msgcnt = X;
   t = 0;
   fault_repair_flag = {max_faults{1'b1}};
   repair_flag = {max_faults{1'b1}};
   if(ConfigFault) 
   begin
        file_ptr = $fopen(Fault_file_name , "r");
        if(file_ptr == 0)
        begin     
          if(debug_level < 3) $display("%m - %t (MSG_ID 201) FAILURE: File cannot be opened ",$realtime);      
        end        
      else                
      begin : read_fault_file
      t = 0;
      for (i = 0; i< max_faults; i= i + 1)
      begin
         
         stuck0 = {Bits{1'b1}};
         stuck1 = {Bits{1'b0}};
         fault_char1 = $fgetc (file_ptr);
         if (fault_char1 == 8'b11111111)
                 disable read_fault_file;
         ret_val = $ungetc (fault_char1, file_ptr);
         ret_val = $fgets(tempStr, file_ptr);
         ret_val = $sscanf(tempStr, "%d %d %s",fault_word, fault_bit, stuck_at) ;
        flag_error = 0; 
         if(ret_val !== 0)
            begin         
               if(ret_val == 2 || ret_val == 3)
               begin
                  if(ret_val == 2)
                      stuck_at = "sa0";

                  if(stuck_at !== "sa0" && stuck_at !== "sa1" && stuck_at !== "none")
                  begin
                      if(debug_level < 2) $display("%m - %t (MSG_ID 203) WARNING: Wrong value for stuck at in fault file ",$realtime);
                      flag_error = 1;
                  end    
                      
                  if(fault_word > Words-1)
                  begin
                      if(debug_level < 2) $display("%m - %t (MSG_ID 206) WARNING: Address out of range in fault file ",$realtime);
                      flag_error = 1;
                  end    

                  if(fault_bit > Bits)
                  begin  
                      if(debug_level < 2) $display("%m - %t (MSG_ID 205) WARNING: Faulty bit out of range in fault file ",$realtime);
                      flag_error = 1;
                  end    

                  if(flag_error == 0)
                  //Correct Inputs
                  begin
                      if(stuck_at === "none")
                      begin
                         if(debug_level < 2) $display("%m - %t (MSG_ID 202) WARNING: No fault injected, empty fault file ",$realtime);
                      end
                      else
                      //Adding the faults
                      begin
                         FailureLocn[t] = fault_word;
                         std_fault_word = fault_word;
                         
                         fault_repair_flag[t] = 1'b0;
                         if (stuck_at === "sa0" )
                         begin
                            stuck0[fault_bit] = 1'b0;         
                            stuck_at_0fault[t] = stuck0;
                         end     
                         if (stuck_at === "sa1" )
                         begin
                            stuck1[fault_bit] = 1'b1;
                            stuck_at_1fault[t] = stuck1; 
                         end

                         array_stuck_at[t] = stuck_at;
                         t = t + 1;
                      end //if(stuck_at === "none")  
                  end //if(flag_error == 0)
               end //if(ret_val == 2 || ret_val == 3 
               else
               //wrong number of arguments
               begin
                  if(debug_level < 2)
                  $display("%m - %t WARNING :  WRONG VALUES ENTERED FOR FAULTY WORD OR FAULTY BIT OR STUCK_AT IN Fault_file_name", $realtime);
                  flag_error = 1;
               end
             end //if(ret_val !== 0)
             else
             begin
                 if(debug_level < 2) $display("%m - %t (MSG_ID 202) WARNING: No fault injected, empty fault file ",$realtime);
             end    
      end //for (i = 0; i< m
      end //begin: read_fault_file  
      $fclose (file_ptr);

      fcnt = t;
      
      //fault injection at time 0.
      task_insert_faults_in_memory;
      
   end // config_fault 
end// initial



//+++++++++++++++++++++++++++++++ CONFIG FAULT IMPLEMETATION ENDS+++++++++++++++++++++++++++++++//
        
always @(CKint)
begin
   if(CKint === 1'b1 && lastCK === 1'b0)
      CSNreg = CSNint;
   
   if(CKint === 1'b1 && lastCK === 1'b0 && CSNint === 1'b0) begin
      WENreg = WENint;
      if (^Aint === X)
         ValidAddress = X;
      else if (Aint < Words)
         ValidAddress = 1;
      else    
         ValidAddress = 0;

      if (ValidAddress)
      `ifdef slm
         $slm_ReadMemoryS(MemAddr, Aint, Mem_temp);
      `else        
         Mem_temp = Mem[Aint];
      `endif       
      else
         Mem_temp = WordX; 
         
      /*---------------------- Normal Read and Write -----------------*/
      
         RY_outreg = ~CKint;
         if (WENint === 1) begin
            ReadCycle(Aint);
         end
         else if (WENint === 0) begin
            WriteCycle(Aint);
         end
         else if (WENint === X) begin
            // Uncertain write cycle
            if (^Aint === X) begin
               WriteOutX;
               WriteMemX;
            end
            else
              wen_x_handler(Aint,Mint);
         end                 
            
      
   end // if(CKint === 1'b1...)
   // Unknown Clock Behaviour or unknown control signal
   else if((CKint === 1'b1 && CSNint === 1'bx) || (CKint === 1'bx && CSNreg !== 1'b1)) begin
      WriteOutX;
      WriteMemX;
       
      RY_out = 1'bX;
      if(CKint === 1'bx && CSNreg !== 1'b1) begin
         if(debug_level < 2) $display("%m - %t (MSG_ID 003) WARNING: Illegal Value on Clock. Memory and Output Corrupted ",$realtime);
      end
      else begin
         if(debug_level < 2) $display("%m - %t (MSG_ID 010) WARNING: Invalid control signal (chip select / memory bypass) Memory and Output Corrupted ",$realtime);
      end
   end
             
   

   if(ConfigFault) begin
      task_insert_faults_in_memory;
   
   end//if(ConfigFault)

   
   lastCK = CKint;
end // always @(CKint)
        
always @(CSNint)
begin

// Unknown Clock & CSN signal
   if (CSNint !== 1 && CKint === 1'bx)
   begin
      if(debug_level < 2) $display("%m - %t (MSG_ID 010) WARNING: Invalid control signal (chip select / memory bypass) Memory and Output Corrupted ",$realtime);
      WriteMemX;
      WriteOutX;
      
      RY_out = 1'bX;
   end

end

  



//TBYPASS functionality
always @(TBYPASSint)
begin
 
   
   delOutReg_data = WordX;
   OutReg_data = WordX;
   if(TBYPASSint !== 1'b0) begin        
      if(TBYPASSint === 1'b1) 
         tbydata = Dint;
      else
         tbydata = WordX;
   end        
   else                         // TBYPASSint = 0
   begin        
      Qint = WordX;
        // tbydata holds no relevance when tbypass is inactive
   end        


end //end of always TBYPASSint

always @(Dint)
begin

   
   if(TBYPASSint === 1'b1)
      tbydata = Dint;

   
end //end of always Dint

//assign output data
always @(OutReg_data)
   #1 delOutReg_data = OutReg_data;

always @(delOutReg_data or tbydata or TBYPASSint ) begin

if(TBYPASSint === 1'bX )
      Qint = WordX;
else if (TBYPASSint === 1'b1 )
      Qint = tbydata;    
else
      
      Qint = delOutReg_data;

end


always @(TBYPASSint)
begin
   if(TBYPASSint !== 1'b0)
    RY_outreg = 1'bx;
end

always @(negedge CKint)
begin

   
   if((TBYPASSint === 1'b0) && (CSNreg === 1'b0) && RY_out !== 1'bx)
    RY_outreg = ~CKint;


end

always @(RY_outreg)
begin
  #1 RY_out = RY_outreg;
end




 
// Power down functionality for verilog_model



endmodule

`else

`timescale 1ns / 1ps
`delay_mode_path


module ST_SPHDL_160x64m8_L_main ( Q_glitch,  Q_data, Q_gCK, RY_rfCK, RY_rrCK, RY_frCK, ICRY, delTBYPASS, TBYPASS_D_Q, TBYPASS_main, CK,  CSN, TBYPASS, WEN,  A, D, M,debug_level ,TimingViol0, TimingViol1, TimingViol2, TimingViol3, TimingViol4, TimingViol5, TimingViol6, TimingViol7, TimingViol8, TimingViol9, TimingViol10, TimingViol_ttms_ttmh, TimingViol12, TimingViol13     );
    
   parameter
        Fault_file_name = "ST_SPHDL_160x64m8_L_faults.txt",
        ConfigFault = 0,
        max_faults = 20,
        MEM_INITIALIZE  = 1'b0,
        BinaryInit = 1'b0,
        InitFileName = "ST_SPHDL_160x64m8_L.cde",
        Debug_mode = "ALL_WARNING_MODE",
        InstancePath = "ST_SPHDL_160x64m8_L";

   parameter
        Words = 160,
        Bits = 64,
        Addr = 8,
        mux = 8,
        Rows = Words/mux;


       

   


    parameter
        WordX = 64'bx,
        AddrX = 8'bx,
        X = 1'bx;

	output [Bits-1 : 0] Q_glitch;
	output [Bits-1 : 0] Q_data;
	output [Bits-1 : 0] Q_gCK;
        
        output ICRY;
        output RY_rfCK;
	output RY_rrCK;
	output RY_frCK;   
	output [Bits-1 : 0] delTBYPASS; 
	output TBYPASS_main; 
        output [Bits-1 : 0] TBYPASS_D_Q;
        
        input [Bits-1 : 0] D, M;
	input [Addr-1 : 0] A;
	input CK, CSN, TBYPASS, WEN;
        input [1 : 0] debug_level;

	input [Bits-1 : 0] TimingViol2, TimingViol3, TimingViol12, TimingViol13;
	input TimingViol0, TimingViol1, TimingViol4, TimingViol5, TimingViol6, TimingViol7, TimingViol8, TimingViol9, TimingViol10, TimingViol_ttms_ttmh;

        
        
        
       
        
        
        

	wire [Bits-1 : 0] Dint,Mint;
	wire [Addr-1 : 0] Aint;
	wire CKint;
	wire CSNint;
	wire WENint;
        
        






	wire  Mreg_0;
	wire  Mreg_1;
	wire  Mreg_2;
	wire  Mreg_3;
	wire  Mreg_4;
	wire  Mreg_5;
	wire  Mreg_6;
	wire  Mreg_7;
	wire  Mreg_8;
	wire  Mreg_9;
	wire  Mreg_10;
	wire  Mreg_11;
	wire  Mreg_12;
	wire  Mreg_13;
	wire  Mreg_14;
	wire  Mreg_15;
	wire  Mreg_16;
	wire  Mreg_17;
	wire  Mreg_18;
	wire  Mreg_19;
	wire  Mreg_20;
	wire  Mreg_21;
	wire  Mreg_22;
	wire  Mreg_23;
	wire  Mreg_24;
	wire  Mreg_25;
	wire  Mreg_26;
	wire  Mreg_27;
	wire  Mreg_28;
	wire  Mreg_29;
	wire  Mreg_30;
	wire  Mreg_31;
	wire  Mreg_32;
	wire  Mreg_33;
	wire  Mreg_34;
	wire  Mreg_35;
	wire  Mreg_36;
	wire  Mreg_37;
	wire  Mreg_38;
	wire  Mreg_39;
	wire  Mreg_40;
	wire  Mreg_41;
	wire  Mreg_42;
	wire  Mreg_43;
	wire  Mreg_44;
	wire  Mreg_45;
	wire  Mreg_46;
	wire  Mreg_47;
	wire  Mreg_48;
	wire  Mreg_49;
	wire  Mreg_50;
	wire  Mreg_51;
	wire  Mreg_52;
	wire  Mreg_53;
	wire  Mreg_54;
	wire  Mreg_55;
	wire  Mreg_56;
	wire  Mreg_57;
	wire  Mreg_58;
	wire  Mreg_59;
	wire  Mreg_60;
	wire  Mreg_61;
	wire  Mreg_62;
	wire  Mreg_63;
	
	reg [Bits-1 : 0] OutReg_glitch; // Glitch Output register
        reg [Bits-1 : 0] OutReg_data;   // Data Output register
	reg [Bits-1 : 0] Dreg,Mreg;
	reg [Bits-1 : 0] Mreg_temp;
	reg [Bits-1 : 0] tempMem;
	reg [Bits-1 : 0] prevMem;
	reg [Addr-1 : 0] Areg;
	reg [Bits-1 : 0] Q_gCKreg; 
	reg [Bits-1 : 0] lastQ_gCK;
	reg [Bits-1 : 0] last_Qdata;
	reg lastCK, CKreg;
	reg CSNreg;
	reg WENreg;
        
        reg [Bits-1 : 0] TimingViol2_last,TimingViol3_last;
        reg [Bits-1 : 0] TimingViol12_last,TimingViol13_last;
	
	reg [Bits-1 : 0] Mem [Words-1 : 0]; // RAM array
	
	reg [Bits-1 :0] Mem_temp;
	reg ValidAddress;
	reg ValidDebugCode;

	reg ICGFlag;
           
        reg Operation_Flag;
	

        
        reg [Bits-1:0] Mem_Red [2*mux-1:0];
        
        integer d, a, p, i, k, j, l;

        //************************************************************
        //****** CONFIG FAULT IMPLEMENTATION VARIABLES*************** 
        //************************************************************ 

        integer file_ptr, ret_val;
        integer fault_word;
        integer fault_bit;
        integer fcnt, Fault_in_memory;
        integer n, cnt, t;  
        integer FailureLocn [max_faults -1 :0];

        reg [100 : 0] stuck_at;
        reg [200 : 0] tempStr;
        reg [7:0] fault_char;
        reg [7:0] fault_char1; // 8 Bit File Pointer
        reg [Addr -1 : 0] std_fault_word;
        reg [max_faults -1 :0] fault_repair_flag;
        reg [max_faults -1 :0] repair_flag;
        reg [Bits - 1: 0] stuck_at_0fault [max_faults -1 : 0];
        reg [Bits - 1: 0] stuck_at_1fault [max_faults -1 : 0];
        reg [100 : 0] array_stuck_at[max_faults -1 : 0] ; 
        reg msgcnt;
        

        reg [Bits -1 : 0] stuck0;
        reg [Bits -1 : 0] stuck1;
        integer flag_error;

	assign Mreg_0 = Mreg[0];
	assign Mreg_1 = Mreg[1];
	assign Mreg_2 = Mreg[2];
	assign Mreg_3 = Mreg[3];
	assign Mreg_4 = Mreg[4];
	assign Mreg_5 = Mreg[5];
	assign Mreg_6 = Mreg[6];
	assign Mreg_7 = Mreg[7];
	assign Mreg_8 = Mreg[8];
	assign Mreg_9 = Mreg[9];
	assign Mreg_10 = Mreg[10];
	assign Mreg_11 = Mreg[11];
	assign Mreg_12 = Mreg[12];
	assign Mreg_13 = Mreg[13];
	assign Mreg_14 = Mreg[14];
	assign Mreg_15 = Mreg[15];
	assign Mreg_16 = Mreg[16];
	assign Mreg_17 = Mreg[17];
	assign Mreg_18 = Mreg[18];
	assign Mreg_19 = Mreg[19];
	assign Mreg_20 = Mreg[20];
	assign Mreg_21 = Mreg[21];
	assign Mreg_22 = Mreg[22];
	assign Mreg_23 = Mreg[23];
	assign Mreg_24 = Mreg[24];
	assign Mreg_25 = Mreg[25];
	assign Mreg_26 = Mreg[26];
	assign Mreg_27 = Mreg[27];
	assign Mreg_28 = Mreg[28];
	assign Mreg_29 = Mreg[29];
	assign Mreg_30 = Mreg[30];
	assign Mreg_31 = Mreg[31];
	assign Mreg_32 = Mreg[32];
	assign Mreg_33 = Mreg[33];
	assign Mreg_34 = Mreg[34];
	assign Mreg_35 = Mreg[35];
	assign Mreg_36 = Mreg[36];
	assign Mreg_37 = Mreg[37];
	assign Mreg_38 = Mreg[38];
	assign Mreg_39 = Mreg[39];
	assign Mreg_40 = Mreg[40];
	assign Mreg_41 = Mreg[41];
	assign Mreg_42 = Mreg[42];
	assign Mreg_43 = Mreg[43];
	assign Mreg_44 = Mreg[44];
	assign Mreg_45 = Mreg[45];
	assign Mreg_46 = Mreg[46];
	assign Mreg_47 = Mreg[47];
	assign Mreg_48 = Mreg[48];
	assign Mreg_49 = Mreg[49];
	assign Mreg_50 = Mreg[50];
	assign Mreg_51 = Mreg[51];
	assign Mreg_52 = Mreg[52];
	assign Mreg_53 = Mreg[53];
	assign Mreg_54 = Mreg[54];
	assign Mreg_55 = Mreg[55];
	assign Mreg_56 = Mreg[56];
	assign Mreg_57 = Mreg[57];
	assign Mreg_58 = Mreg[58];
	assign Mreg_59 = Mreg[59];
	assign Mreg_60 = Mreg[60];
	assign Mreg_61 = Mreg[61];
	assign Mreg_62 = Mreg[62];
	assign Mreg_63 = Mreg[63];
        buf bufdint [Bits-1:0] (Dint, D);
        buf bufmint [Bits-1:0] (Mint, M);
        buf bufaint [Addr-1:0] (Aint, A);
	
	buf (TBYPASS_main, TBYPASS);
	buf (CKint, CK);
        
        buf (CSNint, CSN);    
	buf (WENint, WEN);

        //TBYPASS functionality
        
        buf bufdeltb [Bits-1:0] (delTBYPASS, TBYPASS);
          
        
        
        buf buftbdq [Bits-1:0] (TBYPASS_D_Q, D );
         
        
        
        







        wire RY_rfCKint, RY_rrCKint, RY_frCKint, ICRYFlagint;
        reg RY_rfCKreg, RY_rrCKreg, RY_frCKreg; 
	reg InitialRYFlag, ICRYFlag;

        
        buf (RY_rfCK, RY_rfCKint);
	buf (RY_rrCK, RY_rrCKint);
	buf (RY_frCK, RY_frCKint);
        buf (ICRY, ICRYFlagint);
        assign ICRYFlagint = ICRYFlag;
        
        

    specify
        specparam

            tdq = 0.01,
            ttmq = 0.01,
            
            taa_ry = 0.01,
            th_ry = 0.009,
            tck_ry = 0.01,
            taa = 1.00,
            th = 0.009;
        /*-------------------- Propagation Delays ------------------*/

   
	if (WENreg && !ICGFlag) (CK *> (Q_data[0] : D[0])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[1] : D[1])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[2] : D[2])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[3] : D[3])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[4] : D[4])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[5] : D[5])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[6] : D[6])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[7] : D[7])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[8] : D[8])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[9] : D[9])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[10] : D[10])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[11] : D[11])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[12] : D[12])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[13] : D[13])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[14] : D[14])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[15] : D[15])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[16] : D[16])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[17] : D[17])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[18] : D[18])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[19] : D[19])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[20] : D[20])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[21] : D[21])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[22] : D[22])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[23] : D[23])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[24] : D[24])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[25] : D[25])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[26] : D[26])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[27] : D[27])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[28] : D[28])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[29] : D[29])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[30] : D[30])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[31] : D[31])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[32] : D[32])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[33] : D[33])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[34] : D[34])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[35] : D[35])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[36] : D[36])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[37] : D[37])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[38] : D[38])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[39] : D[39])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[40] : D[40])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[41] : D[41])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[42] : D[42])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[43] : D[43])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[44] : D[44])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[45] : D[45])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[46] : D[46])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[47] : D[47])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[48] : D[48])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[49] : D[49])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[50] : D[50])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[51] : D[51])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[52] : D[52])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[53] : D[53])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[54] : D[54])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[55] : D[55])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[56] : D[56])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[57] : D[57])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[58] : D[58])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[59] : D[59])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[60] : D[60])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[61] : D[61])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[62] : D[62])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[63] : D[63])) = (taa, taa); 
   

	if (!ICGFlag) (CK *> (Q_glitch[0] : D[0])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[1] : D[1])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[2] : D[2])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[3] : D[3])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[4] : D[4])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[5] : D[5])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[6] : D[6])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[7] : D[7])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[8] : D[8])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[9] : D[9])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[10] : D[10])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[11] : D[11])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[12] : D[12])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[13] : D[13])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[14] : D[14])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[15] : D[15])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[16] : D[16])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[17] : D[17])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[18] : D[18])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[19] : D[19])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[20] : D[20])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[21] : D[21])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[22] : D[22])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[23] : D[23])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[24] : D[24])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[25] : D[25])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[26] : D[26])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[27] : D[27])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[28] : D[28])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[29] : D[29])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[30] : D[30])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[31] : D[31])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[32] : D[32])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[33] : D[33])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[34] : D[34])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[35] : D[35])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[36] : D[36])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[37] : D[37])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[38] : D[38])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[39] : D[39])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[40] : D[40])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[41] : D[41])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[42] : D[42])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[43] : D[43])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[44] : D[44])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[45] : D[45])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[46] : D[46])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[47] : D[47])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[48] : D[48])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[49] : D[49])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[50] : D[50])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[51] : D[51])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[52] : D[52])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[53] : D[53])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[54] : D[54])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[55] : D[55])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[56] : D[56])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[57] : D[57])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[58] : D[58])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[59] : D[59])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[60] : D[60])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[61] : D[61])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[62] : D[62])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[63] : D[63])) = (th, th);

	if (!ICGFlag) (CK *> (Q_gCK[0] : D[0])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[1] : D[1])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[2] : D[2])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[3] : D[3])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[4] : D[4])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[5] : D[5])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[6] : D[6])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[7] : D[7])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[8] : D[8])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[9] : D[9])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[10] : D[10])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[11] : D[11])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[12] : D[12])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[13] : D[13])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[14] : D[14])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[15] : D[15])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[16] : D[16])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[17] : D[17])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[18] : D[18])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[19] : D[19])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[20] : D[20])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[21] : D[21])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[22] : D[22])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[23] : D[23])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[24] : D[24])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[25] : D[25])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[26] : D[26])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[27] : D[27])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[28] : D[28])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[29] : D[29])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[30] : D[30])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[31] : D[31])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[32] : D[32])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[33] : D[33])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[34] : D[34])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[35] : D[35])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[36] : D[36])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[37] : D[37])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[38] : D[38])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[39] : D[39])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[40] : D[40])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[41] : D[41])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[42] : D[42])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[43] : D[43])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[44] : D[44])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[45] : D[45])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[46] : D[46])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[47] : D[47])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[48] : D[48])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[49] : D[49])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[50] : D[50])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[51] : D[51])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[52] : D[52])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[53] : D[53])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[54] : D[54])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[55] : D[55])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[56] : D[56])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[57] : D[57])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[58] : D[58])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[59] : D[59])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[60] : D[60])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[61] : D[61])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[62] : D[62])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[63] : D[63])) = (th, th);

	if (!TBYPASS) (TBYPASS *> delTBYPASS[0]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[1]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[2]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[3]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[4]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[5]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[6]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[7]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[8]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[9]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[10]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[11]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[12]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[13]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[14]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[15]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[16]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[17]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[18]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[19]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[20]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[21]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[22]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[23]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[24]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[25]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[26]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[27]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[28]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[29]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[30]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[31]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[32]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[33]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[34]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[35]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[36]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[37]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[38]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[39]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[40]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[41]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[42]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[43]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[44]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[45]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[46]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[47]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[48]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[49]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[50]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[51]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[52]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[53]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[54]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[55]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[56]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[57]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[58]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[59]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[60]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[61]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[62]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[63]) = (0);
	if (TBYPASS) (TBYPASS *> delTBYPASS[0]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[1]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[2]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[3]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[4]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[5]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[6]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[7]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[8]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[9]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[10]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[11]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[12]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[13]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[14]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[15]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[16]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[17]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[18]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[19]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[20]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[21]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[22]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[23]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[24]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[25]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[26]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[27]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[28]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[29]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[30]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[31]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[32]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[33]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[34]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[35]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[36]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[37]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[38]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[39]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[40]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[41]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[42]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[43]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[44]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[45]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[46]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[47]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[48]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[49]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[50]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[51]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[52]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[53]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[54]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[55]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[56]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[57]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[58]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[59]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[60]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[61]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[62]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[63]) = (ttmq);
      (D[0] *> TBYPASS_D_Q[0]) = (tdq, tdq);
      (D[1] *> TBYPASS_D_Q[1]) = (tdq, tdq);
      (D[2] *> TBYPASS_D_Q[2]) = (tdq, tdq);
      (D[3] *> TBYPASS_D_Q[3]) = (tdq, tdq);
      (D[4] *> TBYPASS_D_Q[4]) = (tdq, tdq);
      (D[5] *> TBYPASS_D_Q[5]) = (tdq, tdq);
      (D[6] *> TBYPASS_D_Q[6]) = (tdq, tdq);
      (D[7] *> TBYPASS_D_Q[7]) = (tdq, tdq);
      (D[8] *> TBYPASS_D_Q[8]) = (tdq, tdq);
      (D[9] *> TBYPASS_D_Q[9]) = (tdq, tdq);
      (D[10] *> TBYPASS_D_Q[10]) = (tdq, tdq);
      (D[11] *> TBYPASS_D_Q[11]) = (tdq, tdq);
      (D[12] *> TBYPASS_D_Q[12]) = (tdq, tdq);
      (D[13] *> TBYPASS_D_Q[13]) = (tdq, tdq);
      (D[14] *> TBYPASS_D_Q[14]) = (tdq, tdq);
      (D[15] *> TBYPASS_D_Q[15]) = (tdq, tdq);
      (D[16] *> TBYPASS_D_Q[16]) = (tdq, tdq);
      (D[17] *> TBYPASS_D_Q[17]) = (tdq, tdq);
      (D[18] *> TBYPASS_D_Q[18]) = (tdq, tdq);
      (D[19] *> TBYPASS_D_Q[19]) = (tdq, tdq);
      (D[20] *> TBYPASS_D_Q[20]) = (tdq, tdq);
      (D[21] *> TBYPASS_D_Q[21]) = (tdq, tdq);
      (D[22] *> TBYPASS_D_Q[22]) = (tdq, tdq);
      (D[23] *> TBYPASS_D_Q[23]) = (tdq, tdq);
      (D[24] *> TBYPASS_D_Q[24]) = (tdq, tdq);
      (D[25] *> TBYPASS_D_Q[25]) = (tdq, tdq);
      (D[26] *> TBYPASS_D_Q[26]) = (tdq, tdq);
      (D[27] *> TBYPASS_D_Q[27]) = (tdq, tdq);
      (D[28] *> TBYPASS_D_Q[28]) = (tdq, tdq);
      (D[29] *> TBYPASS_D_Q[29]) = (tdq, tdq);
      (D[30] *> TBYPASS_D_Q[30]) = (tdq, tdq);
      (D[31] *> TBYPASS_D_Q[31]) = (tdq, tdq);
      (D[32] *> TBYPASS_D_Q[32]) = (tdq, tdq);
      (D[33] *> TBYPASS_D_Q[33]) = (tdq, tdq);
      (D[34] *> TBYPASS_D_Q[34]) = (tdq, tdq);
      (D[35] *> TBYPASS_D_Q[35]) = (tdq, tdq);
      (D[36] *> TBYPASS_D_Q[36]) = (tdq, tdq);
      (D[37] *> TBYPASS_D_Q[37]) = (tdq, tdq);
      (D[38] *> TBYPASS_D_Q[38]) = (tdq, tdq);
      (D[39] *> TBYPASS_D_Q[39]) = (tdq, tdq);
      (D[40] *> TBYPASS_D_Q[40]) = (tdq, tdq);
      (D[41] *> TBYPASS_D_Q[41]) = (tdq, tdq);
      (D[42] *> TBYPASS_D_Q[42]) = (tdq, tdq);
      (D[43] *> TBYPASS_D_Q[43]) = (tdq, tdq);
      (D[44] *> TBYPASS_D_Q[44]) = (tdq, tdq);
      (D[45] *> TBYPASS_D_Q[45]) = (tdq, tdq);
      (D[46] *> TBYPASS_D_Q[46]) = (tdq, tdq);
      (D[47] *> TBYPASS_D_Q[47]) = (tdq, tdq);
      (D[48] *> TBYPASS_D_Q[48]) = (tdq, tdq);
      (D[49] *> TBYPASS_D_Q[49]) = (tdq, tdq);
      (D[50] *> TBYPASS_D_Q[50]) = (tdq, tdq);
      (D[51] *> TBYPASS_D_Q[51]) = (tdq, tdq);
      (D[52] *> TBYPASS_D_Q[52]) = (tdq, tdq);
      (D[53] *> TBYPASS_D_Q[53]) = (tdq, tdq);
      (D[54] *> TBYPASS_D_Q[54]) = (tdq, tdq);
      (D[55] *> TBYPASS_D_Q[55]) = (tdq, tdq);
      (D[56] *> TBYPASS_D_Q[56]) = (tdq, tdq);
      (D[57] *> TBYPASS_D_Q[57]) = (tdq, tdq);
      (D[58] *> TBYPASS_D_Q[58]) = (tdq, tdq);
      (D[59] *> TBYPASS_D_Q[59]) = (tdq, tdq);
      (D[60] *> TBYPASS_D_Q[60]) = (tdq, tdq);
      (D[61] *> TBYPASS_D_Q[61]) = (tdq, tdq);
      (D[62] *> TBYPASS_D_Q[62]) = (tdq, tdq);
      (D[63] *> TBYPASS_D_Q[63]) = (tdq, tdq);


        // RY functionality
	if (!ICRYFlag && InitialRYFlag) (CK *> RY_rfCK) = (th_ry, th_ry);

        if (!ICRYFlag && InitialRYFlag) (CK *> RY_rrCK) = (taa_ry, taa_ry); 
	if (!ICRYFlag && InitialRYFlag) (CK *> RY_frCK) = (tck_ry, tck_ry);   

	endspecify


assign #0 Q_data = OutReg_data;
assign Q_glitch = OutReg_glitch;
assign Q_gCK = Q_gCKreg;




    // BEHAVIOURAL MODULE DESCRIPTION

task chstate;
   input [Bits-1 : 0] clkin;
   output [Bits-1 : 0] clkout;
   integer d;
begin
   if ( $realtime != 0 )
      for (d = 0; d < Bits; d = d + 1)
      begin
         if (clkin[d] === 1'b0)
            clkout[d] = 1'b1;
         else if (clkin[d] === 1'b1)
            clkout[d] = 1'bx;
         else
            clkout[d] = 1'b0;
      end
end
endtask


task task_insert_faults_in_memory;
begin
   Fault_in_memory = 1;
   for(i = 0;i< fcnt;i = i+ 1)
   begin
     if (fault_repair_flag[i] !== 1)
     begin
       Fault_in_memory = 0;
       if (array_stuck_at[i] === "sa0")
       begin
          Mem[FailureLocn[i]] = Mem[FailureLocn[i]] & stuck_at_0fault[i];
       end //if(array_stuck_at)
                                              
       if(array_stuck_at[i] === "sa1")
       begin
         Mem[FailureLocn[i]] = Mem[FailureLocn[i]] | stuck_at_1fault[i]; 
       end //if(array_stuck_at)
     end//if (fault_repair_flag
   end// for loop...
end
endtask



task WriteMemX;
begin
    for (i = 0; i < Words; i = i + 1)
       Mem[i] = WordX;
end
endtask

task WriteLocX;
   input [Addr-1 : 0] Address;
begin
   if (^Address !== X)
       Mem[Address] = WordX;
   else
      WriteMemX;
end
endtask

task WriteLocMskX;
  input [Addr-1 : 0] Address;
  input [Bits-1 : 0] Mask;
  input [Bits-1 : 0] prevMem;
  reg [Bits-1 : 0] Outdata;
begin
  if (^Address !== X)
  begin
      tempMem = Mem[Address];
     for (j = 0;j< Bits; j=j+1)
     begin
        if (prevMem[j] !== Dreg[j]) 
        begin
           if (Mask[j] !== 1'b1)
              tempMem[j] = 1'bx;
        end
     end//for (j = 0;j< Bi

     Mem[Address] = tempMem;
  end//if (^Address !== X
  else
     WriteMemX;
end
endtask

task WriteLocMskX_bwise;
   input [Addr-1 : 0] Address;
   input [Bits-1 : 0] Mask;
begin
   if (^Address !== X)
   begin
      tempMem = Mem[Address];
             
      for (j = 0;j< Bits; j=j+1)
         if (Mask[j] === 1'bx)
            tempMem[j] = 1'bx;
                    
      Mem[Address] = tempMem;

   end//if (^Address !== X
   else
      WriteMemX;
end
endtask
    
task WriteOutX;                
begin
   OutReg_data= WordX;
   OutReg_glitch= WordX;
end
endtask

task WriteOutX_bwise;
   input [Bits-1 : 0] flag;
   input [Bits-1 : 0] Delayedflag;
   input [Addr-1 : 0] Address;
   reg [Bits-1 : 0] MemData;
begin
    MemData = Mem[Address];
        
   for ( l = 0; l < Bits; l = l + 1 )
      if (Delayedflag[l] !== flag[l] && MemData[l] === 1'bx)
      begin
         OutReg_data[l] = 1'bx;
	 OutReg_glitch[l] = 1'bx;
      end
end
endtask

task WriteOut;
begin
   for (i = 0;i < Bits; i = i+1)
   begin        
   
      if (last_Qdata[i] !== Mem_temp[i])     
      begin
         OutReg_data[i] = 1'bX;
         OutReg_glitch[i] = 1'bX;
      end
      else
         OutReg_glitch[i] = OutReg_data[i];
   end   
end
endtask  

task WriteCycle;                  
   input [Addr-1 : 0] Address;
   reg [Bits-1:0] tempReg1,tempReg2;
   integer po,i;
begin

   tempReg1 = WordX;
   if (^Address !== X)
   begin
      if (ValidAddress)
      begin
         
                 tempReg1 = Mem[Address];
                 for (po=0;po<Bits;po=po+1)
                 if (Mreg[po] === 1'b0)
                       tempReg1[po] = Dreg[po];
                 else if ((Mreg[po] !== 1'b1) && (tempReg1[po] !== Dreg[po]))
                       tempReg1[po] = 1'bx;
                        
                 Mem[Address] = tempReg1;
                    
      end //if (ValidAddress)
      else
         if(debug_level < 2) $display("%m - %t (MSG_ID 701) WARNING: Write Port:  Address Out Of Range. ",$realtime);
   end//if (^Address !== X)
   else
   begin
      if(debug_level < 2) $display("%m - %t (MSG_ID 008) WARNING: Write Port:  Illegal Value on Address Bus. Memory Corrupted ",$realtime);
      WriteMemX;
   end
 end

endtask

task ReadCycle;
   input [Addr-1 : 0] Address;
   reg [Bits-1:0] MemData;
   integer a;
begin

   if (ValidAddress)
      MemData = Mem[Address];

   if(ValidAddress === X)
   begin
      if(debug_level < 2) $display("%m - %t (MSG_ID 008) WARNING: Read Port:  Illegal Value on Address Bus. Memory and Output Corrupted ",$realtime);
      WriteMemX;
      MemData = WordX;
   end                        
   else if (ValidAddress === 0)
   begin                        
      if(debug_level < 2) $display("%m - %t (MSG_ID 701) WARNING: Read Port:  Address Out Of Range. Output Corrupted ",$realtime);
      MemData = WordX;
   end

   for (a = 0; a < Bits; a = a + 1)
   begin
      if (MemData[a] !== OutReg_data[a])
         OutReg_glitch[a] = WordX[a];
      else
         OutReg_glitch[a] = MemData[a];
   end//for (a = 0; a <

   OutReg_data = MemData;
   Operation_Flag = 1;
   last_Qdata = Q_data;

end
endtask




assign RY_rfCKint = RY_rfCKreg;
assign RY_frCKint = RY_frCKreg;
assign RY_rrCKint = RY_rrCKreg;

// Define format for timing value
initial
begin
  $timeformat (-9, 2, " ns", 0);
  ICGFlag = 0;
  if (MEM_INITIALIZE === 1'b1)
  begin   
     if (BinaryInit)
        $readmemb(InitFileName, Mem, 0, Words-1);
     else
        $readmemh(InitFileName, Mem, 0, Words-1);
  end

  
  ICRYFlag = 1;
  InitialRYFlag = 0;
  ICRYFlag <= 0;
  RY_rfCKreg = 1'b1;
  RY_rrCKreg = 1'b1;
  RY_frCKreg = 1'b1;


/*  -----------Implemetation for config fault starts------*/
   msgcnt = X;
   t = 0;
   fault_repair_flag = {max_faults{1'b1}};
   repair_flag = {max_faults{1'b1}};
   if(ConfigFault) 
   begin
        file_ptr = $fopen(Fault_file_name , "r");
        if(file_ptr == 0)
        begin     
          if(debug_level < 3) $display("%m - %t (MSG_ID 201) FAILURE: File cannot be opened ",$realtime);      
        end        
      else                
      begin : read_fault_file
      t = 0;
      for (i = 0; i< max_faults; i= i + 1)
      begin
         
         stuck0 = {Bits{1'b1}};
         stuck1 = {Bits{1'b0}};
         fault_char1 = $fgetc (file_ptr);
         if (fault_char1 == 8'b11111111)
                 disable read_fault_file;
         ret_val = $ungetc (fault_char1, file_ptr);
         ret_val = $fgets(tempStr, file_ptr);
         ret_val = $sscanf(tempStr, "%d %d %s",fault_word, fault_bit, stuck_at) ;
        flag_error = 0; 
         if(ret_val !== 0)
            begin         
               if(ret_val == 2 || ret_val == 3)
               begin
                  if(ret_val == 2)
                      stuck_at = "sa0";

                  if(stuck_at !== "sa0" && stuck_at !== "sa1" && stuck_at !== "none")
                  begin
                      if(debug_level < 2) $display("%m - %t (MSG_ID 203) WARNING: Wrong value for stuck at in fault file ",$realtime);
                      flag_error = 1;
                  end    
                      
                  if(fault_word > Words-1)
                  begin
                      if(debug_level < 2) $display("%m - %t (MSG_ID 206) WARNING: Address out of range in fault file ",$realtime);
                      flag_error = 1;
                  end    

                  if(fault_bit > Bits)
                  begin  
                      if(debug_level < 2) $display("%m - %t (MSG_ID 205) WARNING: Faulty bit out of range in fault file ",$realtime);
                      flag_error = 1;
                  end    

                  if(flag_error == 0)
                  //Correct Inputs
                  begin
                      if(stuck_at === "none")
                      begin
                         if(debug_level < 2) $display("%m - %t (MSG_ID 202) WARNING: No fault injected, empty fault file ",$realtime);
                      end
                      else
                      //Adding the faults
                      begin
                         FailureLocn[t] = fault_word;
                         std_fault_word = fault_word;
                         
                         fault_repair_flag[t] = 1'b0;
                         if (stuck_at === "sa0" )
                         begin
                            stuck0[fault_bit] = 1'b0;         
                            stuck_at_0fault[t] = stuck0;
                         end     
                         if (stuck_at === "sa1" )
                         begin
                            stuck1[fault_bit] = 1'b1;
                            stuck_at_1fault[t] = stuck1; 
                         end

                         array_stuck_at[t] = stuck_at;
                         t = t + 1;
                      end //if(stuck_at === "none")  
                  end //if(flag_error == 0)
               end //if(ret_val == 2 || ret_val == 3 
               else
               //wrong number of arguments
               begin
                  if(debug_level < 2)
                  $display("%m - %t WARNING :  WRONG VALUES ENTERED FOR FAULTY WORD OR FAULTY BIT OR STUCK_AT IN Fault_file_name", $realtime);
                  flag_error = 1;
               end
             end //if(ret_val !== 0)
             else
             begin
                 if(debug_level < 2) $display("%m - %t (MSG_ID 202) WARNING: No fault injected, empty fault file ",$realtime);
             end    
      end //for (i = 0; i< m
      end //begin: read_fault_file  
      $fclose (file_ptr);
      fcnt = t;

      
      
      //fault injection at time 0.
      task_insert_faults_in_memory;
      

   end // config_fault 
end// initial



//+++++++++++++++++++++++++++++++ CONFIG FAULT IMPLEMETATION ENDS+++++++++++++++++++++++++++++++//

always @(CKint)
begin
   lastCK = CKreg;
   CKreg = CKint;
   if(CKreg === 1'b1 && lastCK === 1'b0)
   begin
     CSNreg = CSNint;
   end

   
   if (CKint !== 0 && CSNint !== 1)
   begin
     InitialRYFlag = 1;
   end
   

   
   if (CKint===1 && lastCK ===0 && CSNint === X)
       ICRYFlag = 1;
   else if (CKint === 1 && lastCK === 0 && CSNint === 0)
       ICRYFlag = 0;
   

   /*---------------------- Latching signals ----------------------*/
   if(CKreg === 1'b1 && lastCK === 1'b0)
   begin
      
      WENreg = WENint;
   end   
   if(CKreg === 1'b1 && lastCK === 1'b0 && CSNint === 1'b0) begin
      ICGFlag = 0;
      Dreg = Dint;
      Mreg = Mint;
      Areg = Aint;
      if (^Areg === X)
         ValidAddress = X;
      else if (Areg < Words)
         ValidAddress = 1;
      else
         ValidAddress = 0;

      if (ValidAddress)
         Mem_temp = Mem[Aint];
      else
         Mem_temp = WordX; 

      
      
      Operation_Flag = 0;
      last_Qdata = Q_data;
      
      /*------ Normal Read and Write --------*/
      if (WENreg === 1)
      begin
         ReadCycle(Areg);
         chstate(Q_gCKreg, Q_gCKreg);
      end//if (WENreg === 1 && C
      else if (WENreg === 0 )
      begin
         WriteCycle(Areg);
      end
      /*---------- Corruption due to faulty values on signals --------*/
      else if (WENreg === X)
      begin
         chstate(Q_gCKreg, Q_gCKreg);
         // Uncertain write cycle
         WriteLocMskX(Areg,Mreg,Mem_temp);
         WriteOut;
         if (^Areg === X || Areg > Words-1)
         begin
              WriteOutX;	// if add is unknown put X at output
         end    
      end//else if (WENreg =
      
         

      
   end//if(CKreg === 1'b1 && lastCK =   
   // Unknown Clock Behaviour
   else if (((CSNint === 1'bx) && (CKint === 1)) || (CKint=== 1'bx && CSNreg !==1)) begin
      WriteMemX;
      WriteOutX;
      ICGFlag = 1'b1;
       
      ICRYFlag = 1'b1;
      if(CKint === 1'bx && CSNreg !== 1'b1) begin
         if(debug_level < 2) $display("%m - %t (MSG_ID 003) WARNING: Illegal Value on Clock. Memory and Output Corrupted ",$realtime);
      end
      else begin
         if(debug_level < 2) $display("%m - %t (MSG_ID 010) WARNING: Invalid control signal (chip select / memory bypass) Memory and Output Corrupted ",$realtime);
      end
   end 
   if(ConfigFault) begin
      task_insert_faults_in_memory;
      
   end//if(ConfigFault)
   
 end // always @(CKint)

always @(CSNint)
begin   
   // Unknown Clock & CSN signal
      if (CSNint !== 1 && CKint === X )
      begin
         chstate(Q_gCKreg, Q_gCKreg);
       	 WriteMemX;
	 WriteOutX;
         
         ICRYFlag = 1;   
      end//if (CSNint !== 1
end      


always @(TBYPASS_main)
begin

   OutReg_data = WordX;
   OutReg_glitch = WordX;
   
   if (TBYPASS_main !== 0)
      ICRYFlag = 1;
   
end


  

        /*---------------RY Functionality-----------------*/
always @(posedge CKreg)
begin


   if ((CSNreg === 0) && (CKreg === 1 && lastCK === 0) && TBYPASS_main === 1'b0)
   begin
           RY_rfCKreg = ~RY_rfCKreg;
        RY_rrCKreg = ~RY_rrCKreg;
   end


end

always @(negedge CKreg)
begin

   
   if (TBYPASS_main === 1'b0 && (CSNreg === 1'b0) && (CKreg === 1'b0 && lastCK === 1'b1))
   begin
        RY_frCKreg = ~RY_frCKreg;
    end


end

always @(TimingViol9 or TimingViol10 or TimingViol4 or TimingViol5 or TimingViol8 )
ICRYFlag = 1;
        /*---------------------------------*/






   




   
/*---------------TBYPASS  Functionality in functional model -----------------*/

always @(TimingViol9 or TimingViol10 or TimingViol4 or TimingViol5 or TimingViol8)
begin
   if (TBYPASS !== 0)
      WriteMemX;
end

always @(TimingViol2 or TimingViol3)
// tds or tdh violation
begin
#0
   for (l = 0; l < Bits; l = l + 1)
   begin   
      if((TimingViol2[l] !== TimingViol2_last[l]))
         Mreg[l] = 1'bx;
      if((TimingViol3[l] !== TimingViol3_last[l]))
         Mreg[l] = 1'bx;   
   end   
   WriteLocMskX_bwise(Areg,Mreg);
   TimingViol2_last = TimingViol2;
   TimingViol3_last = TimingViol3;
end


        
/*---------- Corruption due to Timing Violations ---------------*/

always @(TimingViol9 or TimingViol10)
// tckl -  tcycle
begin
#0
   Dreg = WordX;
   WriteOutX;
   #0.00 WriteMemX;
end

always @(TimingViol4 or TimingViol5)
// tps or tph
begin
#0
   Dreg = WordX;
   if ((WENreg !== 0) || (lastCK === X))
      WriteOutX;
   if (lastCK === X)
      WriteMemX;  
   WriteMemX; 
   if (CSNreg === 1 && WENreg !== 0)
   begin
      chstate(Q_gCKreg, Q_gCKreg);
   end
end

always @(TimingViol8)
// tckh
begin
#0
   Dreg = WordX;
   ICGFlag = 1;
   chstate(Q_gCKreg, Q_gCKreg);
   WriteOutX;
   WriteMemX;
end

always @(TimingViol0 or TimingViol1)
// tas or tah
begin
#0
   Areg = AddrX;
   ValidAddress = X;
   if (WENreg !== 0)
      WriteOutX;
   WriteMemX;
end


always @(TimingViol6 or TimingViol7)
//tws or twh
begin
#0
   if (CSNreg === X)
   begin
      WriteMemX; 
      WriteOutX;
   end
   else
   begin
      WriteLocMskX(Areg,Mreg,Mem_temp); 
      WriteOut;
      if (^Areg === X)
         WriteOutX;	// if add is unknown put X at output
   end
end


always @(TimingViol_ttms_ttmh)
//ttms/ttmh
begin
#0
   Dreg = WordX;
   WriteOutX;
   WriteMemX;  
   
   ICRYFlag = 1; 
end





endmodule

module ST_SPHDL_160x64m8_L_OPschlr (QINT,  RYINT, Q_gCK, Q_glitch,  Q_data, RY_rfCK, RY_rrCK, RY_frCK, ICRY, delTBYPASS, TBYPASS_D_Q, TBYPASS_main  );

    parameter
        Words = 160,
        Bits = 64,
        Addr = 8;
        

    parameter
        WordX = 64'bx,
        AddrX = 8'bx,
        X = 1'bx;

	output [Bits-1 : 0] QINT;
	input [Bits-1 : 0] Q_glitch;
	input [Bits-1 : 0] Q_data;
	input [Bits-1 : 0] Q_gCK;
        input [Bits-1 : 0] TBYPASS_D_Q;
        input [Bits-1 : 0] delTBYPASS;
        input TBYPASS_main;



	integer m,a, d, n, o, p;
	wire [Bits-1 : 0] QINTint;
	wire [Bits-1 : 0] QINTERNAL;

        reg [Bits-1 : 0] OutReg;
	reg [Bits-1 : 0] lastQ_gCK, Q_gCKreg;
	reg [Bits-1 : 0] lastQ_data, Q_datareg;
	reg [Bits-1 : 0] QINTERNALreg;
	reg [Bits-1 : 0] lastQINTERNAL;

buf bufqint [Bits-1:0] (QINT, QINTint);


	assign QINTint[0] = (TBYPASS_main===0 && delTBYPASS[0]===0)?OutReg[0] : (TBYPASS_main===1 && delTBYPASS[0]===1)?TBYPASS_D_Q[0] : WordX;
	assign QINTint[1] = (TBYPASS_main===0 && delTBYPASS[1]===0)?OutReg[1] : (TBYPASS_main===1 && delTBYPASS[1]===1)?TBYPASS_D_Q[1] : WordX;
	assign QINTint[2] = (TBYPASS_main===0 && delTBYPASS[2]===0)?OutReg[2] : (TBYPASS_main===1 && delTBYPASS[2]===1)?TBYPASS_D_Q[2] : WordX;
	assign QINTint[3] = (TBYPASS_main===0 && delTBYPASS[3]===0)?OutReg[3] : (TBYPASS_main===1 && delTBYPASS[3]===1)?TBYPASS_D_Q[3] : WordX;
	assign QINTint[4] = (TBYPASS_main===0 && delTBYPASS[4]===0)?OutReg[4] : (TBYPASS_main===1 && delTBYPASS[4]===1)?TBYPASS_D_Q[4] : WordX;
	assign QINTint[5] = (TBYPASS_main===0 && delTBYPASS[5]===0)?OutReg[5] : (TBYPASS_main===1 && delTBYPASS[5]===1)?TBYPASS_D_Q[5] : WordX;
	assign QINTint[6] = (TBYPASS_main===0 && delTBYPASS[6]===0)?OutReg[6] : (TBYPASS_main===1 && delTBYPASS[6]===1)?TBYPASS_D_Q[6] : WordX;
	assign QINTint[7] = (TBYPASS_main===0 && delTBYPASS[7]===0)?OutReg[7] : (TBYPASS_main===1 && delTBYPASS[7]===1)?TBYPASS_D_Q[7] : WordX;
	assign QINTint[8] = (TBYPASS_main===0 && delTBYPASS[8]===0)?OutReg[8] : (TBYPASS_main===1 && delTBYPASS[8]===1)?TBYPASS_D_Q[8] : WordX;
	assign QINTint[9] = (TBYPASS_main===0 && delTBYPASS[9]===0)?OutReg[9] : (TBYPASS_main===1 && delTBYPASS[9]===1)?TBYPASS_D_Q[9] : WordX;
	assign QINTint[10] = (TBYPASS_main===0 && delTBYPASS[10]===0)?OutReg[10] : (TBYPASS_main===1 && delTBYPASS[10]===1)?TBYPASS_D_Q[10] : WordX;
	assign QINTint[11] = (TBYPASS_main===0 && delTBYPASS[11]===0)?OutReg[11] : (TBYPASS_main===1 && delTBYPASS[11]===1)?TBYPASS_D_Q[11] : WordX;
	assign QINTint[12] = (TBYPASS_main===0 && delTBYPASS[12]===0)?OutReg[12] : (TBYPASS_main===1 && delTBYPASS[12]===1)?TBYPASS_D_Q[12] : WordX;
	assign QINTint[13] = (TBYPASS_main===0 && delTBYPASS[13]===0)?OutReg[13] : (TBYPASS_main===1 && delTBYPASS[13]===1)?TBYPASS_D_Q[13] : WordX;
	assign QINTint[14] = (TBYPASS_main===0 && delTBYPASS[14]===0)?OutReg[14] : (TBYPASS_main===1 && delTBYPASS[14]===1)?TBYPASS_D_Q[14] : WordX;
	assign QINTint[15] = (TBYPASS_main===0 && delTBYPASS[15]===0)?OutReg[15] : (TBYPASS_main===1 && delTBYPASS[15]===1)?TBYPASS_D_Q[15] : WordX;
	assign QINTint[16] = (TBYPASS_main===0 && delTBYPASS[16]===0)?OutReg[16] : (TBYPASS_main===1 && delTBYPASS[16]===1)?TBYPASS_D_Q[16] : WordX;
	assign QINTint[17] = (TBYPASS_main===0 && delTBYPASS[17]===0)?OutReg[17] : (TBYPASS_main===1 && delTBYPASS[17]===1)?TBYPASS_D_Q[17] : WordX;
	assign QINTint[18] = (TBYPASS_main===0 && delTBYPASS[18]===0)?OutReg[18] : (TBYPASS_main===1 && delTBYPASS[18]===1)?TBYPASS_D_Q[18] : WordX;
	assign QINTint[19] = (TBYPASS_main===0 && delTBYPASS[19]===0)?OutReg[19] : (TBYPASS_main===1 && delTBYPASS[19]===1)?TBYPASS_D_Q[19] : WordX;
	assign QINTint[20] = (TBYPASS_main===0 && delTBYPASS[20]===0)?OutReg[20] : (TBYPASS_main===1 && delTBYPASS[20]===1)?TBYPASS_D_Q[20] : WordX;
	assign QINTint[21] = (TBYPASS_main===0 && delTBYPASS[21]===0)?OutReg[21] : (TBYPASS_main===1 && delTBYPASS[21]===1)?TBYPASS_D_Q[21] : WordX;
	assign QINTint[22] = (TBYPASS_main===0 && delTBYPASS[22]===0)?OutReg[22] : (TBYPASS_main===1 && delTBYPASS[22]===1)?TBYPASS_D_Q[22] : WordX;
	assign QINTint[23] = (TBYPASS_main===0 && delTBYPASS[23]===0)?OutReg[23] : (TBYPASS_main===1 && delTBYPASS[23]===1)?TBYPASS_D_Q[23] : WordX;
	assign QINTint[24] = (TBYPASS_main===0 && delTBYPASS[24]===0)?OutReg[24] : (TBYPASS_main===1 && delTBYPASS[24]===1)?TBYPASS_D_Q[24] : WordX;
	assign QINTint[25] = (TBYPASS_main===0 && delTBYPASS[25]===0)?OutReg[25] : (TBYPASS_main===1 && delTBYPASS[25]===1)?TBYPASS_D_Q[25] : WordX;
	assign QINTint[26] = (TBYPASS_main===0 && delTBYPASS[26]===0)?OutReg[26] : (TBYPASS_main===1 && delTBYPASS[26]===1)?TBYPASS_D_Q[26] : WordX;
	assign QINTint[27] = (TBYPASS_main===0 && delTBYPASS[27]===0)?OutReg[27] : (TBYPASS_main===1 && delTBYPASS[27]===1)?TBYPASS_D_Q[27] : WordX;
	assign QINTint[28] = (TBYPASS_main===0 && delTBYPASS[28]===0)?OutReg[28] : (TBYPASS_main===1 && delTBYPASS[28]===1)?TBYPASS_D_Q[28] : WordX;
	assign QINTint[29] = (TBYPASS_main===0 && delTBYPASS[29]===0)?OutReg[29] : (TBYPASS_main===1 && delTBYPASS[29]===1)?TBYPASS_D_Q[29] : WordX;
	assign QINTint[30] = (TBYPASS_main===0 && delTBYPASS[30]===0)?OutReg[30] : (TBYPASS_main===1 && delTBYPASS[30]===1)?TBYPASS_D_Q[30] : WordX;
	assign QINTint[31] = (TBYPASS_main===0 && delTBYPASS[31]===0)?OutReg[31] : (TBYPASS_main===1 && delTBYPASS[31]===1)?TBYPASS_D_Q[31] : WordX;
	assign QINTint[32] = (TBYPASS_main===0 && delTBYPASS[32]===0)?OutReg[32] : (TBYPASS_main===1 && delTBYPASS[32]===1)?TBYPASS_D_Q[32] : WordX;
	assign QINTint[33] = (TBYPASS_main===0 && delTBYPASS[33]===0)?OutReg[33] : (TBYPASS_main===1 && delTBYPASS[33]===1)?TBYPASS_D_Q[33] : WordX;
	assign QINTint[34] = (TBYPASS_main===0 && delTBYPASS[34]===0)?OutReg[34] : (TBYPASS_main===1 && delTBYPASS[34]===1)?TBYPASS_D_Q[34] : WordX;
	assign QINTint[35] = (TBYPASS_main===0 && delTBYPASS[35]===0)?OutReg[35] : (TBYPASS_main===1 && delTBYPASS[35]===1)?TBYPASS_D_Q[35] : WordX;
	assign QINTint[36] = (TBYPASS_main===0 && delTBYPASS[36]===0)?OutReg[36] : (TBYPASS_main===1 && delTBYPASS[36]===1)?TBYPASS_D_Q[36] : WordX;
	assign QINTint[37] = (TBYPASS_main===0 && delTBYPASS[37]===0)?OutReg[37] : (TBYPASS_main===1 && delTBYPASS[37]===1)?TBYPASS_D_Q[37] : WordX;
	assign QINTint[38] = (TBYPASS_main===0 && delTBYPASS[38]===0)?OutReg[38] : (TBYPASS_main===1 && delTBYPASS[38]===1)?TBYPASS_D_Q[38] : WordX;
	assign QINTint[39] = (TBYPASS_main===0 && delTBYPASS[39]===0)?OutReg[39] : (TBYPASS_main===1 && delTBYPASS[39]===1)?TBYPASS_D_Q[39] : WordX;
	assign QINTint[40] = (TBYPASS_main===0 && delTBYPASS[40]===0)?OutReg[40] : (TBYPASS_main===1 && delTBYPASS[40]===1)?TBYPASS_D_Q[40] : WordX;
	assign QINTint[41] = (TBYPASS_main===0 && delTBYPASS[41]===0)?OutReg[41] : (TBYPASS_main===1 && delTBYPASS[41]===1)?TBYPASS_D_Q[41] : WordX;
	assign QINTint[42] = (TBYPASS_main===0 && delTBYPASS[42]===0)?OutReg[42] : (TBYPASS_main===1 && delTBYPASS[42]===1)?TBYPASS_D_Q[42] : WordX;
	assign QINTint[43] = (TBYPASS_main===0 && delTBYPASS[43]===0)?OutReg[43] : (TBYPASS_main===1 && delTBYPASS[43]===1)?TBYPASS_D_Q[43] : WordX;
	assign QINTint[44] = (TBYPASS_main===0 && delTBYPASS[44]===0)?OutReg[44] : (TBYPASS_main===1 && delTBYPASS[44]===1)?TBYPASS_D_Q[44] : WordX;
	assign QINTint[45] = (TBYPASS_main===0 && delTBYPASS[45]===0)?OutReg[45] : (TBYPASS_main===1 && delTBYPASS[45]===1)?TBYPASS_D_Q[45] : WordX;
	assign QINTint[46] = (TBYPASS_main===0 && delTBYPASS[46]===0)?OutReg[46] : (TBYPASS_main===1 && delTBYPASS[46]===1)?TBYPASS_D_Q[46] : WordX;
	assign QINTint[47] = (TBYPASS_main===0 && delTBYPASS[47]===0)?OutReg[47] : (TBYPASS_main===1 && delTBYPASS[47]===1)?TBYPASS_D_Q[47] : WordX;
	assign QINTint[48] = (TBYPASS_main===0 && delTBYPASS[48]===0)?OutReg[48] : (TBYPASS_main===1 && delTBYPASS[48]===1)?TBYPASS_D_Q[48] : WordX;
	assign QINTint[49] = (TBYPASS_main===0 && delTBYPASS[49]===0)?OutReg[49] : (TBYPASS_main===1 && delTBYPASS[49]===1)?TBYPASS_D_Q[49] : WordX;
	assign QINTint[50] = (TBYPASS_main===0 && delTBYPASS[50]===0)?OutReg[50] : (TBYPASS_main===1 && delTBYPASS[50]===1)?TBYPASS_D_Q[50] : WordX;
	assign QINTint[51] = (TBYPASS_main===0 && delTBYPASS[51]===0)?OutReg[51] : (TBYPASS_main===1 && delTBYPASS[51]===1)?TBYPASS_D_Q[51] : WordX;
	assign QINTint[52] = (TBYPASS_main===0 && delTBYPASS[52]===0)?OutReg[52] : (TBYPASS_main===1 && delTBYPASS[52]===1)?TBYPASS_D_Q[52] : WordX;
	assign QINTint[53] = (TBYPASS_main===0 && delTBYPASS[53]===0)?OutReg[53] : (TBYPASS_main===1 && delTBYPASS[53]===1)?TBYPASS_D_Q[53] : WordX;
	assign QINTint[54] = (TBYPASS_main===0 && delTBYPASS[54]===0)?OutReg[54] : (TBYPASS_main===1 && delTBYPASS[54]===1)?TBYPASS_D_Q[54] : WordX;
	assign QINTint[55] = (TBYPASS_main===0 && delTBYPASS[55]===0)?OutReg[55] : (TBYPASS_main===1 && delTBYPASS[55]===1)?TBYPASS_D_Q[55] : WordX;
	assign QINTint[56] = (TBYPASS_main===0 && delTBYPASS[56]===0)?OutReg[56] : (TBYPASS_main===1 && delTBYPASS[56]===1)?TBYPASS_D_Q[56] : WordX;
	assign QINTint[57] = (TBYPASS_main===0 && delTBYPASS[57]===0)?OutReg[57] : (TBYPASS_main===1 && delTBYPASS[57]===1)?TBYPASS_D_Q[57] : WordX;
	assign QINTint[58] = (TBYPASS_main===0 && delTBYPASS[58]===0)?OutReg[58] : (TBYPASS_main===1 && delTBYPASS[58]===1)?TBYPASS_D_Q[58] : WordX;
	assign QINTint[59] = (TBYPASS_main===0 && delTBYPASS[59]===0)?OutReg[59] : (TBYPASS_main===1 && delTBYPASS[59]===1)?TBYPASS_D_Q[59] : WordX;
	assign QINTint[60] = (TBYPASS_main===0 && delTBYPASS[60]===0)?OutReg[60] : (TBYPASS_main===1 && delTBYPASS[60]===1)?TBYPASS_D_Q[60] : WordX;
	assign QINTint[61] = (TBYPASS_main===0 && delTBYPASS[61]===0)?OutReg[61] : (TBYPASS_main===1 && delTBYPASS[61]===1)?TBYPASS_D_Q[61] : WordX;
	assign QINTint[62] = (TBYPASS_main===0 && delTBYPASS[62]===0)?OutReg[62] : (TBYPASS_main===1 && delTBYPASS[62]===1)?TBYPASS_D_Q[62] : WordX;
	assign QINTint[63] = (TBYPASS_main===0 && delTBYPASS[63]===0)?OutReg[63] : (TBYPASS_main===1 && delTBYPASS[63]===1)?TBYPASS_D_Q[63] : WordX;

assign QINTERNAL = QINTERNALreg;

always @(TBYPASS_main)
begin
           
   if (TBYPASS_main === 0 || TBYPASS_main === X) 
      QINTERNALreg = WordX;
   
end


        
/*------------------ RY functionality -----------------*/
        output RYINT;
        input RY_rfCK, RY_rrCK, RY_frCK, ICRY;
        wire RYINTint;
        reg RYINTreg, RYRiseFlag;

        buf (RYINT, RYINTint);

assign RYINTint = RYINTreg;
        
initial
begin
  RYRiseFlag = 1'b0;
  RYINTreg = 1'b1;
end

always @(ICRY)
begin
   if($realtime == 0)
      RYINTreg = 1'b1;
   else
      RYINTreg = 1'bx;
end

always @(RY_rfCK)
if (ICRY !== 1)
begin
   RYINTreg = 0;
   RYRiseFlag=0;
end

always @(RY_rrCK)
if (ICRY !== 1 && $realtime != 0)
begin
   if (RYRiseFlag === 0)
   begin
      RYRiseFlag=1;
   end
   else
   begin
      RYINTreg = 1'b1;
      RYRiseFlag=0;
   end
end
always @(RY_frCK)
#0
if (ICRY !== 1 && $realtime != 0)
begin
   if (RYRiseFlag === 0)
   begin
      RYRiseFlag=1;
   end
   else
   begin
      RYINTreg = 1'b1;
      RYRiseFlag=0;
   end
end
/*------------------------------------------------ */

always @(Q_gCK)
begin
#0  //This has been used for removing races during hold time violations in MODELSIM simulator.
   lastQ_gCK = Q_gCKreg;
   Q_gCKreg <= Q_gCK;
   for (m = 0; m < Bits; m = m + 1)
   begin
     if (lastQ_gCK[m] !== Q_gCK[m])
     begin
       	lastQINTERNAL[m] = QINTERNALreg[m];
       	QINTERNALreg[m] = Q_glitch[m];
     end
   end
end

always @(Q_data)
begin
#0  //This has been used for removing races during hold time vilations in MODELSIM simulator.
   lastQ_data = Q_datareg;
   Q_datareg <= Q_data;
   for (n = 0; n < Bits; n = n + 1)
   begin
      if (lastQ_data[n] !== Q_data[n])
      begin
       	lastQINTERNAL[n] = QINTERNALreg[n];
       	QINTERNALreg[n] = Q_data[n];
      end
   end
end

always @(QINTERNAL)
begin
   for (d = 0; d < Bits; d = d + 1)
   begin
      if (OutReg[d] !== QINTERNAL[d])
          OutReg[d] = QINTERNAL[d];
   end
end



endmodule


module ST_SPHDL_160x64m8_L (Q, RY, CK, CSN, TBYPASS, WEN,  A,  D   );
   

    parameter 
        Fault_file_name = "ST_SPHDL_160x64m8_L_faults.txt",   
        ConfigFault = 0,
        max_faults = 20,
        MEM_INITIALIZE = 1'b0,
        BinaryInit     = 1'b0,
        InitFileName   = "ST_SPHDL_160x64m8_L.cde",     
        Corruption_Read_Violation = 1,
        Debug_mode = "ALL_WARNING_MODE",
        InstancePath = "ST_SPHDL_160x64m8_L";

    parameter
        Words = 160,
        Bits = 64,
        Addr = 8,
        mux = 8,
        Rows = Words/mux;
        






    parameter
        WordX = 64'bx,
        AddrX = 8'bx,
        X = 1'bx;


    output [Bits-1 : 0] Q;
    
    output RY;   
    input CK;
    input CSN;
    input WEN;
    input TBYPASS;
    input [Addr-1 : 0] A;
    input [Bits-1 : 0] D;
    
    





   
   wire [Bits-1 : 0] Q_glitchint;
   wire [Bits-1 : 0] Q_dataint;
   wire [Bits-1 : 0] Dint,Mint;
   wire [Addr-1 : 0] Aint;
   wire [Bits-1 : 0] Q_gCKint;
   wire CKint;
   wire CSNint;
   wire WENint;
   wire TBYPASSint;
   wire TBYPASS_mainint;
   wire [Bits-1 : 0]  TBYPASS_D_Qint;
   wire [Bits-1 : 0]  delTBYPASSint;






   
   wire [Bits-1 : 0] Qint, Q_out;
   wire CS_taa = !CSNint;
   wire csn_tcycle = !CSNint;
   wire csn_tcycle_DEBUG, csn_tcycle_DEBUGN;
   reg [Bits-1 : 0] Dreg,Mreg;
   reg [Addr-1 : 0] Areg;
   reg CKreg;
   reg CSNreg;
   reg WENreg;
	
   reg [Bits-1 : 0] TimingViol2, TimingViol3, TimingViol12, TimingViol13;
   reg [Bits-1 : 0] TimingViol2_last, TimingViol3_last, TimingViol12_last, TimingViol13_last;
	reg TimingViol2_0, TimingViol3_0, TimingViol12_0, TimingViol13_0;
	reg TimingViol2_1, TimingViol3_1, TimingViol12_1, TimingViol13_1;
	reg TimingViol2_2, TimingViol3_2, TimingViol12_2, TimingViol13_2;
	reg TimingViol2_3, TimingViol3_3, TimingViol12_3, TimingViol13_3;
	reg TimingViol2_4, TimingViol3_4, TimingViol12_4, TimingViol13_4;
	reg TimingViol2_5, TimingViol3_5, TimingViol12_5, TimingViol13_5;
	reg TimingViol2_6, TimingViol3_6, TimingViol12_6, TimingViol13_6;
	reg TimingViol2_7, TimingViol3_7, TimingViol12_7, TimingViol13_7;
	reg TimingViol2_8, TimingViol3_8, TimingViol12_8, TimingViol13_8;
	reg TimingViol2_9, TimingViol3_9, TimingViol12_9, TimingViol13_9;
	reg TimingViol2_10, TimingViol3_10, TimingViol12_10, TimingViol13_10;
	reg TimingViol2_11, TimingViol3_11, TimingViol12_11, TimingViol13_11;
	reg TimingViol2_12, TimingViol3_12, TimingViol12_12, TimingViol13_12;
	reg TimingViol2_13, TimingViol3_13, TimingViol12_13, TimingViol13_13;
	reg TimingViol2_14, TimingViol3_14, TimingViol12_14, TimingViol13_14;
	reg TimingViol2_15, TimingViol3_15, TimingViol12_15, TimingViol13_15;
	reg TimingViol2_16, TimingViol3_16, TimingViol12_16, TimingViol13_16;
	reg TimingViol2_17, TimingViol3_17, TimingViol12_17, TimingViol13_17;
	reg TimingViol2_18, TimingViol3_18, TimingViol12_18, TimingViol13_18;
	reg TimingViol2_19, TimingViol3_19, TimingViol12_19, TimingViol13_19;
	reg TimingViol2_20, TimingViol3_20, TimingViol12_20, TimingViol13_20;
	reg TimingViol2_21, TimingViol3_21, TimingViol12_21, TimingViol13_21;
	reg TimingViol2_22, TimingViol3_22, TimingViol12_22, TimingViol13_22;
	reg TimingViol2_23, TimingViol3_23, TimingViol12_23, TimingViol13_23;
	reg TimingViol2_24, TimingViol3_24, TimingViol12_24, TimingViol13_24;
	reg TimingViol2_25, TimingViol3_25, TimingViol12_25, TimingViol13_25;
	reg TimingViol2_26, TimingViol3_26, TimingViol12_26, TimingViol13_26;
	reg TimingViol2_27, TimingViol3_27, TimingViol12_27, TimingViol13_27;
	reg TimingViol2_28, TimingViol3_28, TimingViol12_28, TimingViol13_28;
	reg TimingViol2_29, TimingViol3_29, TimingViol12_29, TimingViol13_29;
	reg TimingViol2_30, TimingViol3_30, TimingViol12_30, TimingViol13_30;
	reg TimingViol2_31, TimingViol3_31, TimingViol12_31, TimingViol13_31;
	reg TimingViol2_32, TimingViol3_32, TimingViol12_32, TimingViol13_32;
	reg TimingViol2_33, TimingViol3_33, TimingViol12_33, TimingViol13_33;
	reg TimingViol2_34, TimingViol3_34, TimingViol12_34, TimingViol13_34;
	reg TimingViol2_35, TimingViol3_35, TimingViol12_35, TimingViol13_35;
	reg TimingViol2_36, TimingViol3_36, TimingViol12_36, TimingViol13_36;
	reg TimingViol2_37, TimingViol3_37, TimingViol12_37, TimingViol13_37;
	reg TimingViol2_38, TimingViol3_38, TimingViol12_38, TimingViol13_38;
	reg TimingViol2_39, TimingViol3_39, TimingViol12_39, TimingViol13_39;
	reg TimingViol2_40, TimingViol3_40, TimingViol12_40, TimingViol13_40;
	reg TimingViol2_41, TimingViol3_41, TimingViol12_41, TimingViol13_41;
	reg TimingViol2_42, TimingViol3_42, TimingViol12_42, TimingViol13_42;
	reg TimingViol2_43, TimingViol3_43, TimingViol12_43, TimingViol13_43;
	reg TimingViol2_44, TimingViol3_44, TimingViol12_44, TimingViol13_44;
	reg TimingViol2_45, TimingViol3_45, TimingViol12_45, TimingViol13_45;
	reg TimingViol2_46, TimingViol3_46, TimingViol12_46, TimingViol13_46;
	reg TimingViol2_47, TimingViol3_47, TimingViol12_47, TimingViol13_47;
	reg TimingViol2_48, TimingViol3_48, TimingViol12_48, TimingViol13_48;
	reg TimingViol2_49, TimingViol3_49, TimingViol12_49, TimingViol13_49;
	reg TimingViol2_50, TimingViol3_50, TimingViol12_50, TimingViol13_50;
	reg TimingViol2_51, TimingViol3_51, TimingViol12_51, TimingViol13_51;
	reg TimingViol2_52, TimingViol3_52, TimingViol12_52, TimingViol13_52;
	reg TimingViol2_53, TimingViol3_53, TimingViol12_53, TimingViol13_53;
	reg TimingViol2_54, TimingViol3_54, TimingViol12_54, TimingViol13_54;
	reg TimingViol2_55, TimingViol3_55, TimingViol12_55, TimingViol13_55;
	reg TimingViol2_56, TimingViol3_56, TimingViol12_56, TimingViol13_56;
	reg TimingViol2_57, TimingViol3_57, TimingViol12_57, TimingViol13_57;
	reg TimingViol2_58, TimingViol3_58, TimingViol12_58, TimingViol13_58;
	reg TimingViol2_59, TimingViol3_59, TimingViol12_59, TimingViol13_59;
	reg TimingViol2_60, TimingViol3_60, TimingViol12_60, TimingViol13_60;
	reg TimingViol2_61, TimingViol3_61, TimingViol12_61, TimingViol13_61;
	reg TimingViol2_62, TimingViol3_62, TimingViol12_62, TimingViol13_62;
	reg TimingViol2_63, TimingViol3_63, TimingViol12_63, TimingViol13_63;
   reg TimingViol0, TimingViol1;
   reg TimingViol4, TimingViol5, TimingViol6, TimingViol7, TimingViol_ttms_ttmh;
   reg TimingViol8, TimingViol9, TimingViol10, TimingViol10_taa;








   wire [Bits-1 : 0] MEN,CSWEMTBYPASS;
   wire CSTBYPASSN, CSWETBYPASSN;
   wire csn_tckl;
   wire csn_tckl_ry;
   wire csn_tckh;

   reg tckh_flag;
   reg tckl_flag;

   wire CS_taa_ry = !CSNint;
   
/* This register is used to force all warning messages 
** OFF during run time.
** 
*/ 
   reg [1:0] debug_level;
   reg [8*10: 0] operating_mode;
   reg [8*44: 0] message_status;





initial
begin
  debug_level = 2'b0;
  message_status = "All Messages are Switched ON";
  `ifdef  NO_WARNING_MODE
     debug_level = 2'b10;
    message_status = "All Messages are Switched OFF"; 
  `endif 
if(debug_level !== 2'b10) begin
  $display ("%m  INFORMATION");
   $display ("***************************************");
   $display ("The Model is Operating in TIMING MODE");
   $display ("Please make sure that SDF is properly annotated otherwise dummy values will be used");
   $display ("%s", message_status);
   $display ("***************************************");
   if(ConfigFault)
  $display ("Configurable Fault Functionality is ON");   
  else
  $display ("Configurable Fault Functionality is OFF"); 
  
  $display ("***************************************");
end     
end     

   buf (CKint, CK);

   //MEM_EN = CSN or  TBYPASS
   or (CSNint, CSN, TBYPASS  );

   buf (TBYPASSint, TBYPASS);
   buf (WENint, WEN);
   buf bufDint [Bits-1:0] (Dint, D);
   
   assign Mint = 64'b0;
   
   buf bufAint [Addr-1:0] (Aint, A);






   
     buf bufqint [Bits-1:0] (Q,Qint); 





	reg TimingViol9_tck_ry, TimingViol10_taa_ry;
        wire  RYint, RY_rfCKint, RY_rrCKint, RY_frCKint, RY_out;
        reg RY_outreg; 
        assign RY_out = RY_outreg;
  
     
       buf (RY, RY_out);  
       
        always @(RYint)
        begin
        RY_outreg = RYint;
        end

        
   // Only include timing checks during behavioural modelling



not (CS, CSN);    


    not (TBYPASSN, TBYPASS);
    not (WE, WEN);

    and (CSWE, CS, WE);
    and (CSWETBYPASSN, CSWE, TBYPASSN);
    and (CSTBYPASSN, CS, TBYPASSN);
    and (CSWEN, CS, WEN);
 
    assign csn_tckh = tckh_flag;
    assign csn_tckl = tckl_flag;
    assign csn_tckl_ry = tckl_flag;


        
 not (MEN[0], Mint[0]);
 not (MEN[1], Mint[1]);
 not (MEN[2], Mint[2]);
 not (MEN[3], Mint[3]);
 not (MEN[4], Mint[4]);
 not (MEN[5], Mint[5]);
 not (MEN[6], Mint[6]);
 not (MEN[7], Mint[7]);
 not (MEN[8], Mint[8]);
 not (MEN[9], Mint[9]);
 not (MEN[10], Mint[10]);
 not (MEN[11], Mint[11]);
 not (MEN[12], Mint[12]);
 not (MEN[13], Mint[13]);
 not (MEN[14], Mint[14]);
 not (MEN[15], Mint[15]);
 not (MEN[16], Mint[16]);
 not (MEN[17], Mint[17]);
 not (MEN[18], Mint[18]);
 not (MEN[19], Mint[19]);
 not (MEN[20], Mint[20]);
 not (MEN[21], Mint[21]);
 not (MEN[22], Mint[22]);
 not (MEN[23], Mint[23]);
 not (MEN[24], Mint[24]);
 not (MEN[25], Mint[25]);
 not (MEN[26], Mint[26]);
 not (MEN[27], Mint[27]);
 not (MEN[28], Mint[28]);
 not (MEN[29], Mint[29]);
 not (MEN[30], Mint[30]);
 not (MEN[31], Mint[31]);
 not (MEN[32], Mint[32]);
 not (MEN[33], Mint[33]);
 not (MEN[34], Mint[34]);
 not (MEN[35], Mint[35]);
 not (MEN[36], Mint[36]);
 not (MEN[37], Mint[37]);
 not (MEN[38], Mint[38]);
 not (MEN[39], Mint[39]);
 not (MEN[40], Mint[40]);
 not (MEN[41], Mint[41]);
 not (MEN[42], Mint[42]);
 not (MEN[43], Mint[43]);
 not (MEN[44], Mint[44]);
 not (MEN[45], Mint[45]);
 not (MEN[46], Mint[46]);
 not (MEN[47], Mint[47]);
 not (MEN[48], Mint[48]);
 not (MEN[49], Mint[49]);
 not (MEN[50], Mint[50]);
 not (MEN[51], Mint[51]);
 not (MEN[52], Mint[52]);
 not (MEN[53], Mint[53]);
 not (MEN[54], Mint[54]);
 not (MEN[55], Mint[55]);
 not (MEN[56], Mint[56]);
 not (MEN[57], Mint[57]);
 not (MEN[58], Mint[58]);
 not (MEN[59], Mint[59]);
 not (MEN[60], Mint[60]);
 not (MEN[61], Mint[61]);
 not (MEN[62], Mint[62]);
 not (MEN[63], Mint[63]);
 and (CSWEMTBYPASS[0], MEN[0], CSWETBYPASSN);
 and (CSWEMTBYPASS[1], MEN[1], CSWETBYPASSN);
 and (CSWEMTBYPASS[2], MEN[2], CSWETBYPASSN);
 and (CSWEMTBYPASS[3], MEN[3], CSWETBYPASSN);
 and (CSWEMTBYPASS[4], MEN[4], CSWETBYPASSN);
 and (CSWEMTBYPASS[5], MEN[5], CSWETBYPASSN);
 and (CSWEMTBYPASS[6], MEN[6], CSWETBYPASSN);
 and (CSWEMTBYPASS[7], MEN[7], CSWETBYPASSN);
 and (CSWEMTBYPASS[8], MEN[8], CSWETBYPASSN);
 and (CSWEMTBYPASS[9], MEN[9], CSWETBYPASSN);
 and (CSWEMTBYPASS[10], MEN[10], CSWETBYPASSN);
 and (CSWEMTBYPASS[11], MEN[11], CSWETBYPASSN);
 and (CSWEMTBYPASS[12], MEN[12], CSWETBYPASSN);
 and (CSWEMTBYPASS[13], MEN[13], CSWETBYPASSN);
 and (CSWEMTBYPASS[14], MEN[14], CSWETBYPASSN);
 and (CSWEMTBYPASS[15], MEN[15], CSWETBYPASSN);
 and (CSWEMTBYPASS[16], MEN[16], CSWETBYPASSN);
 and (CSWEMTBYPASS[17], MEN[17], CSWETBYPASSN);
 and (CSWEMTBYPASS[18], MEN[18], CSWETBYPASSN);
 and (CSWEMTBYPASS[19], MEN[19], CSWETBYPASSN);
 and (CSWEMTBYPASS[20], MEN[20], CSWETBYPASSN);
 and (CSWEMTBYPASS[21], MEN[21], CSWETBYPASSN);
 and (CSWEMTBYPASS[22], MEN[22], CSWETBYPASSN);
 and (CSWEMTBYPASS[23], MEN[23], CSWETBYPASSN);
 and (CSWEMTBYPASS[24], MEN[24], CSWETBYPASSN);
 and (CSWEMTBYPASS[25], MEN[25], CSWETBYPASSN);
 and (CSWEMTBYPASS[26], MEN[26], CSWETBYPASSN);
 and (CSWEMTBYPASS[27], MEN[27], CSWETBYPASSN);
 and (CSWEMTBYPASS[28], MEN[28], CSWETBYPASSN);
 and (CSWEMTBYPASS[29], MEN[29], CSWETBYPASSN);
 and (CSWEMTBYPASS[30], MEN[30], CSWETBYPASSN);
 and (CSWEMTBYPASS[31], MEN[31], CSWETBYPASSN);
 and (CSWEMTBYPASS[32], MEN[32], CSWETBYPASSN);
 and (CSWEMTBYPASS[33], MEN[33], CSWETBYPASSN);
 and (CSWEMTBYPASS[34], MEN[34], CSWETBYPASSN);
 and (CSWEMTBYPASS[35], MEN[35], CSWETBYPASSN);
 and (CSWEMTBYPASS[36], MEN[36], CSWETBYPASSN);
 and (CSWEMTBYPASS[37], MEN[37], CSWETBYPASSN);
 and (CSWEMTBYPASS[38], MEN[38], CSWETBYPASSN);
 and (CSWEMTBYPASS[39], MEN[39], CSWETBYPASSN);
 and (CSWEMTBYPASS[40], MEN[40], CSWETBYPASSN);
 and (CSWEMTBYPASS[41], MEN[41], CSWETBYPASSN);
 and (CSWEMTBYPASS[42], MEN[42], CSWETBYPASSN);
 and (CSWEMTBYPASS[43], MEN[43], CSWETBYPASSN);
 and (CSWEMTBYPASS[44], MEN[44], CSWETBYPASSN);
 and (CSWEMTBYPASS[45], MEN[45], CSWETBYPASSN);
 and (CSWEMTBYPASS[46], MEN[46], CSWETBYPASSN);
 and (CSWEMTBYPASS[47], MEN[47], CSWETBYPASSN);
 and (CSWEMTBYPASS[48], MEN[48], CSWETBYPASSN);
 and (CSWEMTBYPASS[49], MEN[49], CSWETBYPASSN);
 and (CSWEMTBYPASS[50], MEN[50], CSWETBYPASSN);
 and (CSWEMTBYPASS[51], MEN[51], CSWETBYPASSN);
 and (CSWEMTBYPASS[52], MEN[52], CSWETBYPASSN);
 and (CSWEMTBYPASS[53], MEN[53], CSWETBYPASSN);
 and (CSWEMTBYPASS[54], MEN[54], CSWETBYPASSN);
 and (CSWEMTBYPASS[55], MEN[55], CSWETBYPASSN);
 and (CSWEMTBYPASS[56], MEN[56], CSWETBYPASSN);
 and (CSWEMTBYPASS[57], MEN[57], CSWETBYPASSN);
 and (CSWEMTBYPASS[58], MEN[58], CSWETBYPASSN);
 and (CSWEMTBYPASS[59], MEN[59], CSWETBYPASSN);
 and (CSWEMTBYPASS[60], MEN[60], CSWETBYPASSN);
 and (CSWEMTBYPASS[61], MEN[61], CSWETBYPASSN);
 and (CSWEMTBYPASS[62], MEN[62], CSWETBYPASSN);
 and (CSWEMTBYPASS[63], MEN[63], CSWETBYPASSN);

   specify
      specparam



         tckl_tck_ry = 0.00,
         tcycle_taa_ry = 0.00,

 
         
	 tms = 0.0,
         tmh = 0.0,
         tcycle = 0.0,
         tcycle_taa = 0.0,
         tckh = 0.0,
         tckl = 0.0,
         ttms = 0.0,
         ttmh = 0.0,
         tps = 0.0,
         tph = 0.0,
         tws = 0.0,
         twh = 0.0,
         tas = 0.0,
         tah = 0.0,
         tds = 0.0,
         tdh = 0.0;
        /*---------------------- Timing Checks ---------------------*/

	$setup(posedge A[0], posedge CK &&& CSTBYPASSN, tas, TimingViol0);
	$setup(posedge A[1], posedge CK &&& CSTBYPASSN, tas, TimingViol0);
	$setup(posedge A[2], posedge CK &&& CSTBYPASSN, tas, TimingViol0);
	$setup(posedge A[3], posedge CK &&& CSTBYPASSN, tas, TimingViol0);
	$setup(posedge A[4], posedge CK &&& CSTBYPASSN, tas, TimingViol0);
	$setup(posedge A[5], posedge CK &&& CSTBYPASSN, tas, TimingViol0);
	$setup(posedge A[6], posedge CK &&& CSTBYPASSN, tas, TimingViol0);
	$setup(posedge A[7], posedge CK &&& CSTBYPASSN, tas, TimingViol0);
	$setup(negedge A[0], posedge CK &&& CSTBYPASSN, tas, TimingViol0);
	$setup(negedge A[1], posedge CK &&& CSTBYPASSN, tas, TimingViol0);
	$setup(negedge A[2], posedge CK &&& CSTBYPASSN, tas, TimingViol0);
	$setup(negedge A[3], posedge CK &&& CSTBYPASSN, tas, TimingViol0);
	$setup(negedge A[4], posedge CK &&& CSTBYPASSN, tas, TimingViol0);
	$setup(negedge A[5], posedge CK &&& CSTBYPASSN, tas, TimingViol0);
	$setup(negedge A[6], posedge CK &&& CSTBYPASSN, tas, TimingViol0);
	$setup(negedge A[7], posedge CK &&& CSTBYPASSN, tas, TimingViol0);
	$hold(posedge CK &&& CSTBYPASSN, posedge A[0], tah, TimingViol1);
	$hold(posedge CK &&& CSTBYPASSN, posedge A[1], tah, TimingViol1);
	$hold(posedge CK &&& CSTBYPASSN, posedge A[2], tah, TimingViol1);
	$hold(posedge CK &&& CSTBYPASSN, posedge A[3], tah, TimingViol1);
	$hold(posedge CK &&& CSTBYPASSN, posedge A[4], tah, TimingViol1);
	$hold(posedge CK &&& CSTBYPASSN, posedge A[5], tah, TimingViol1);
	$hold(posedge CK &&& CSTBYPASSN, posedge A[6], tah, TimingViol1);
	$hold(posedge CK &&& CSTBYPASSN, posedge A[7], tah, TimingViol1);
	$hold(posedge CK &&& CSTBYPASSN, negedge A[0], tah, TimingViol1);
	$hold(posedge CK &&& CSTBYPASSN, negedge A[1], tah, TimingViol1);
	$hold(posedge CK &&& CSTBYPASSN, negedge A[2], tah, TimingViol1);
	$hold(posedge CK &&& CSTBYPASSN, negedge A[3], tah, TimingViol1);
	$hold(posedge CK &&& CSTBYPASSN, negedge A[4], tah, TimingViol1);
	$hold(posedge CK &&& CSTBYPASSN, negedge A[5], tah, TimingViol1);
	$hold(posedge CK &&& CSTBYPASSN, negedge A[6], tah, TimingViol1);
	$hold(posedge CK &&& CSTBYPASSN, negedge A[7], tah, TimingViol1);
	$setup(posedge D[0], posedge CK &&& (CSWEMTBYPASS[0] != 0), tds, TimingViol2_0);
	$setup(posedge D[1], posedge CK &&& (CSWEMTBYPASS[1] != 0), tds, TimingViol2_1);
	$setup(posedge D[2], posedge CK &&& (CSWEMTBYPASS[2] != 0), tds, TimingViol2_2);
	$setup(posedge D[3], posedge CK &&& (CSWEMTBYPASS[3] != 0), tds, TimingViol2_3);
	$setup(posedge D[4], posedge CK &&& (CSWEMTBYPASS[4] != 0), tds, TimingViol2_4);
	$setup(posedge D[5], posedge CK &&& (CSWEMTBYPASS[5] != 0), tds, TimingViol2_5);
	$setup(posedge D[6], posedge CK &&& (CSWEMTBYPASS[6] != 0), tds, TimingViol2_6);
	$setup(posedge D[7], posedge CK &&& (CSWEMTBYPASS[7] != 0), tds, TimingViol2_7);
	$setup(posedge D[8], posedge CK &&& (CSWEMTBYPASS[8] != 0), tds, TimingViol2_8);
	$setup(posedge D[9], posedge CK &&& (CSWEMTBYPASS[9] != 0), tds, TimingViol2_9);
	$setup(posedge D[10], posedge CK &&& (CSWEMTBYPASS[10] != 0), tds, TimingViol2_10);
	$setup(posedge D[11], posedge CK &&& (CSWEMTBYPASS[11] != 0), tds, TimingViol2_11);
	$setup(posedge D[12], posedge CK &&& (CSWEMTBYPASS[12] != 0), tds, TimingViol2_12);
	$setup(posedge D[13], posedge CK &&& (CSWEMTBYPASS[13] != 0), tds, TimingViol2_13);
	$setup(posedge D[14], posedge CK &&& (CSWEMTBYPASS[14] != 0), tds, TimingViol2_14);
	$setup(posedge D[15], posedge CK &&& (CSWEMTBYPASS[15] != 0), tds, TimingViol2_15);
	$setup(posedge D[16], posedge CK &&& (CSWEMTBYPASS[16] != 0), tds, TimingViol2_16);
	$setup(posedge D[17], posedge CK &&& (CSWEMTBYPASS[17] != 0), tds, TimingViol2_17);
	$setup(posedge D[18], posedge CK &&& (CSWEMTBYPASS[18] != 0), tds, TimingViol2_18);
	$setup(posedge D[19], posedge CK &&& (CSWEMTBYPASS[19] != 0), tds, TimingViol2_19);
	$setup(posedge D[20], posedge CK &&& (CSWEMTBYPASS[20] != 0), tds, TimingViol2_20);
	$setup(posedge D[21], posedge CK &&& (CSWEMTBYPASS[21] != 0), tds, TimingViol2_21);
	$setup(posedge D[22], posedge CK &&& (CSWEMTBYPASS[22] != 0), tds, TimingViol2_22);
	$setup(posedge D[23], posedge CK &&& (CSWEMTBYPASS[23] != 0), tds, TimingViol2_23);
	$setup(posedge D[24], posedge CK &&& (CSWEMTBYPASS[24] != 0), tds, TimingViol2_24);
	$setup(posedge D[25], posedge CK &&& (CSWEMTBYPASS[25] != 0), tds, TimingViol2_25);
	$setup(posedge D[26], posedge CK &&& (CSWEMTBYPASS[26] != 0), tds, TimingViol2_26);
	$setup(posedge D[27], posedge CK &&& (CSWEMTBYPASS[27] != 0), tds, TimingViol2_27);
	$setup(posedge D[28], posedge CK &&& (CSWEMTBYPASS[28] != 0), tds, TimingViol2_28);
	$setup(posedge D[29], posedge CK &&& (CSWEMTBYPASS[29] != 0), tds, TimingViol2_29);
	$setup(posedge D[30], posedge CK &&& (CSWEMTBYPASS[30] != 0), tds, TimingViol2_30);
	$setup(posedge D[31], posedge CK &&& (CSWEMTBYPASS[31] != 0), tds, TimingViol2_31);
	$setup(posedge D[32], posedge CK &&& (CSWEMTBYPASS[32] != 0), tds, TimingViol2_32);
	$setup(posedge D[33], posedge CK &&& (CSWEMTBYPASS[33] != 0), tds, TimingViol2_33);
	$setup(posedge D[34], posedge CK &&& (CSWEMTBYPASS[34] != 0), tds, TimingViol2_34);
	$setup(posedge D[35], posedge CK &&& (CSWEMTBYPASS[35] != 0), tds, TimingViol2_35);
	$setup(posedge D[36], posedge CK &&& (CSWEMTBYPASS[36] != 0), tds, TimingViol2_36);
	$setup(posedge D[37], posedge CK &&& (CSWEMTBYPASS[37] != 0), tds, TimingViol2_37);
	$setup(posedge D[38], posedge CK &&& (CSWEMTBYPASS[38] != 0), tds, TimingViol2_38);
	$setup(posedge D[39], posedge CK &&& (CSWEMTBYPASS[39] != 0), tds, TimingViol2_39);
	$setup(posedge D[40], posedge CK &&& (CSWEMTBYPASS[40] != 0), tds, TimingViol2_40);
	$setup(posedge D[41], posedge CK &&& (CSWEMTBYPASS[41] != 0), tds, TimingViol2_41);
	$setup(posedge D[42], posedge CK &&& (CSWEMTBYPASS[42] != 0), tds, TimingViol2_42);
	$setup(posedge D[43], posedge CK &&& (CSWEMTBYPASS[43] != 0), tds, TimingViol2_43);
	$setup(posedge D[44], posedge CK &&& (CSWEMTBYPASS[44] != 0), tds, TimingViol2_44);
	$setup(posedge D[45], posedge CK &&& (CSWEMTBYPASS[45] != 0), tds, TimingViol2_45);
	$setup(posedge D[46], posedge CK &&& (CSWEMTBYPASS[46] != 0), tds, TimingViol2_46);
	$setup(posedge D[47], posedge CK &&& (CSWEMTBYPASS[47] != 0), tds, TimingViol2_47);
	$setup(posedge D[48], posedge CK &&& (CSWEMTBYPASS[48] != 0), tds, TimingViol2_48);
	$setup(posedge D[49], posedge CK &&& (CSWEMTBYPASS[49] != 0), tds, TimingViol2_49);
	$setup(posedge D[50], posedge CK &&& (CSWEMTBYPASS[50] != 0), tds, TimingViol2_50);
	$setup(posedge D[51], posedge CK &&& (CSWEMTBYPASS[51] != 0), tds, TimingViol2_51);
	$setup(posedge D[52], posedge CK &&& (CSWEMTBYPASS[52] != 0), tds, TimingViol2_52);
	$setup(posedge D[53], posedge CK &&& (CSWEMTBYPASS[53] != 0), tds, TimingViol2_53);
	$setup(posedge D[54], posedge CK &&& (CSWEMTBYPASS[54] != 0), tds, TimingViol2_54);
	$setup(posedge D[55], posedge CK &&& (CSWEMTBYPASS[55] != 0), tds, TimingViol2_55);
	$setup(posedge D[56], posedge CK &&& (CSWEMTBYPASS[56] != 0), tds, TimingViol2_56);
	$setup(posedge D[57], posedge CK &&& (CSWEMTBYPASS[57] != 0), tds, TimingViol2_57);
	$setup(posedge D[58], posedge CK &&& (CSWEMTBYPASS[58] != 0), tds, TimingViol2_58);
	$setup(posedge D[59], posedge CK &&& (CSWEMTBYPASS[59] != 0), tds, TimingViol2_59);
	$setup(posedge D[60], posedge CK &&& (CSWEMTBYPASS[60] != 0), tds, TimingViol2_60);
	$setup(posedge D[61], posedge CK &&& (CSWEMTBYPASS[61] != 0), tds, TimingViol2_61);
	$setup(posedge D[62], posedge CK &&& (CSWEMTBYPASS[62] != 0), tds, TimingViol2_62);
	$setup(posedge D[63], posedge CK &&& (CSWEMTBYPASS[63] != 0), tds, TimingViol2_63);
	$setup(negedge D[0], posedge CK &&& (CSWEMTBYPASS[0] != 0), tds, TimingViol2_0);
	$setup(negedge D[1], posedge CK &&& (CSWEMTBYPASS[1] != 0), tds, TimingViol2_1);
	$setup(negedge D[2], posedge CK &&& (CSWEMTBYPASS[2] != 0), tds, TimingViol2_2);
	$setup(negedge D[3], posedge CK &&& (CSWEMTBYPASS[3] != 0), tds, TimingViol2_3);
	$setup(negedge D[4], posedge CK &&& (CSWEMTBYPASS[4] != 0), tds, TimingViol2_4);
	$setup(negedge D[5], posedge CK &&& (CSWEMTBYPASS[5] != 0), tds, TimingViol2_5);
	$setup(negedge D[6], posedge CK &&& (CSWEMTBYPASS[6] != 0), tds, TimingViol2_6);
	$setup(negedge D[7], posedge CK &&& (CSWEMTBYPASS[7] != 0), tds, TimingViol2_7);
	$setup(negedge D[8], posedge CK &&& (CSWEMTBYPASS[8] != 0), tds, TimingViol2_8);
	$setup(negedge D[9], posedge CK &&& (CSWEMTBYPASS[9] != 0), tds, TimingViol2_9);
	$setup(negedge D[10], posedge CK &&& (CSWEMTBYPASS[10] != 0), tds, TimingViol2_10);
	$setup(negedge D[11], posedge CK &&& (CSWEMTBYPASS[11] != 0), tds, TimingViol2_11);
	$setup(negedge D[12], posedge CK &&& (CSWEMTBYPASS[12] != 0), tds, TimingViol2_12);
	$setup(negedge D[13], posedge CK &&& (CSWEMTBYPASS[13] != 0), tds, TimingViol2_13);
	$setup(negedge D[14], posedge CK &&& (CSWEMTBYPASS[14] != 0), tds, TimingViol2_14);
	$setup(negedge D[15], posedge CK &&& (CSWEMTBYPASS[15] != 0), tds, TimingViol2_15);
	$setup(negedge D[16], posedge CK &&& (CSWEMTBYPASS[16] != 0), tds, TimingViol2_16);
	$setup(negedge D[17], posedge CK &&& (CSWEMTBYPASS[17] != 0), tds, TimingViol2_17);
	$setup(negedge D[18], posedge CK &&& (CSWEMTBYPASS[18] != 0), tds, TimingViol2_18);
	$setup(negedge D[19], posedge CK &&& (CSWEMTBYPASS[19] != 0), tds, TimingViol2_19);
	$setup(negedge D[20], posedge CK &&& (CSWEMTBYPASS[20] != 0), tds, TimingViol2_20);
	$setup(negedge D[21], posedge CK &&& (CSWEMTBYPASS[21] != 0), tds, TimingViol2_21);
	$setup(negedge D[22], posedge CK &&& (CSWEMTBYPASS[22] != 0), tds, TimingViol2_22);
	$setup(negedge D[23], posedge CK &&& (CSWEMTBYPASS[23] != 0), tds, TimingViol2_23);
	$setup(negedge D[24], posedge CK &&& (CSWEMTBYPASS[24] != 0), tds, TimingViol2_24);
	$setup(negedge D[25], posedge CK &&& (CSWEMTBYPASS[25] != 0), tds, TimingViol2_25);
	$setup(negedge D[26], posedge CK &&& (CSWEMTBYPASS[26] != 0), tds, TimingViol2_26);
	$setup(negedge D[27], posedge CK &&& (CSWEMTBYPASS[27] != 0), tds, TimingViol2_27);
	$setup(negedge D[28], posedge CK &&& (CSWEMTBYPASS[28] != 0), tds, TimingViol2_28);
	$setup(negedge D[29], posedge CK &&& (CSWEMTBYPASS[29] != 0), tds, TimingViol2_29);
	$setup(negedge D[30], posedge CK &&& (CSWEMTBYPASS[30] != 0), tds, TimingViol2_30);
	$setup(negedge D[31], posedge CK &&& (CSWEMTBYPASS[31] != 0), tds, TimingViol2_31);
	$setup(negedge D[32], posedge CK &&& (CSWEMTBYPASS[32] != 0), tds, TimingViol2_32);
	$setup(negedge D[33], posedge CK &&& (CSWEMTBYPASS[33] != 0), tds, TimingViol2_33);
	$setup(negedge D[34], posedge CK &&& (CSWEMTBYPASS[34] != 0), tds, TimingViol2_34);
	$setup(negedge D[35], posedge CK &&& (CSWEMTBYPASS[35] != 0), tds, TimingViol2_35);
	$setup(negedge D[36], posedge CK &&& (CSWEMTBYPASS[36] != 0), tds, TimingViol2_36);
	$setup(negedge D[37], posedge CK &&& (CSWEMTBYPASS[37] != 0), tds, TimingViol2_37);
	$setup(negedge D[38], posedge CK &&& (CSWEMTBYPASS[38] != 0), tds, TimingViol2_38);
	$setup(negedge D[39], posedge CK &&& (CSWEMTBYPASS[39] != 0), tds, TimingViol2_39);
	$setup(negedge D[40], posedge CK &&& (CSWEMTBYPASS[40] != 0), tds, TimingViol2_40);
	$setup(negedge D[41], posedge CK &&& (CSWEMTBYPASS[41] != 0), tds, TimingViol2_41);
	$setup(negedge D[42], posedge CK &&& (CSWEMTBYPASS[42] != 0), tds, TimingViol2_42);
	$setup(negedge D[43], posedge CK &&& (CSWEMTBYPASS[43] != 0), tds, TimingViol2_43);
	$setup(negedge D[44], posedge CK &&& (CSWEMTBYPASS[44] != 0), tds, TimingViol2_44);
	$setup(negedge D[45], posedge CK &&& (CSWEMTBYPASS[45] != 0), tds, TimingViol2_45);
	$setup(negedge D[46], posedge CK &&& (CSWEMTBYPASS[46] != 0), tds, TimingViol2_46);
	$setup(negedge D[47], posedge CK &&& (CSWEMTBYPASS[47] != 0), tds, TimingViol2_47);
	$setup(negedge D[48], posedge CK &&& (CSWEMTBYPASS[48] != 0), tds, TimingViol2_48);
	$setup(negedge D[49], posedge CK &&& (CSWEMTBYPASS[49] != 0), tds, TimingViol2_49);
	$setup(negedge D[50], posedge CK &&& (CSWEMTBYPASS[50] != 0), tds, TimingViol2_50);
	$setup(negedge D[51], posedge CK &&& (CSWEMTBYPASS[51] != 0), tds, TimingViol2_51);
	$setup(negedge D[52], posedge CK &&& (CSWEMTBYPASS[52] != 0), tds, TimingViol2_52);
	$setup(negedge D[53], posedge CK &&& (CSWEMTBYPASS[53] != 0), tds, TimingViol2_53);
	$setup(negedge D[54], posedge CK &&& (CSWEMTBYPASS[54] != 0), tds, TimingViol2_54);
	$setup(negedge D[55], posedge CK &&& (CSWEMTBYPASS[55] != 0), tds, TimingViol2_55);
	$setup(negedge D[56], posedge CK &&& (CSWEMTBYPASS[56] != 0), tds, TimingViol2_56);
	$setup(negedge D[57], posedge CK &&& (CSWEMTBYPASS[57] != 0), tds, TimingViol2_57);
	$setup(negedge D[58], posedge CK &&& (CSWEMTBYPASS[58] != 0), tds, TimingViol2_58);
	$setup(negedge D[59], posedge CK &&& (CSWEMTBYPASS[59] != 0), tds, TimingViol2_59);
	$setup(negedge D[60], posedge CK &&& (CSWEMTBYPASS[60] != 0), tds, TimingViol2_60);
	$setup(negedge D[61], posedge CK &&& (CSWEMTBYPASS[61] != 0), tds, TimingViol2_61);
	$setup(negedge D[62], posedge CK &&& (CSWEMTBYPASS[62] != 0), tds, TimingViol2_62);
	$setup(negedge D[63], posedge CK &&& (CSWEMTBYPASS[63] != 0), tds, TimingViol2_63);
	$hold(posedge CK &&& (CSWEMTBYPASS[0] != 0), posedge D[0], tdh, TimingViol3_0);
	$hold(posedge CK &&& (CSWEMTBYPASS[1] != 0), posedge D[1], tdh, TimingViol3_1);
	$hold(posedge CK &&& (CSWEMTBYPASS[2] != 0), posedge D[2], tdh, TimingViol3_2);
	$hold(posedge CK &&& (CSWEMTBYPASS[3] != 0), posedge D[3], tdh, TimingViol3_3);
	$hold(posedge CK &&& (CSWEMTBYPASS[4] != 0), posedge D[4], tdh, TimingViol3_4);
	$hold(posedge CK &&& (CSWEMTBYPASS[5] != 0), posedge D[5], tdh, TimingViol3_5);
	$hold(posedge CK &&& (CSWEMTBYPASS[6] != 0), posedge D[6], tdh, TimingViol3_6);
	$hold(posedge CK &&& (CSWEMTBYPASS[7] != 0), posedge D[7], tdh, TimingViol3_7);
	$hold(posedge CK &&& (CSWEMTBYPASS[8] != 0), posedge D[8], tdh, TimingViol3_8);
	$hold(posedge CK &&& (CSWEMTBYPASS[9] != 0), posedge D[9], tdh, TimingViol3_9);
	$hold(posedge CK &&& (CSWEMTBYPASS[10] != 0), posedge D[10], tdh, TimingViol3_10);
	$hold(posedge CK &&& (CSWEMTBYPASS[11] != 0), posedge D[11], tdh, TimingViol3_11);
	$hold(posedge CK &&& (CSWEMTBYPASS[12] != 0), posedge D[12], tdh, TimingViol3_12);
	$hold(posedge CK &&& (CSWEMTBYPASS[13] != 0), posedge D[13], tdh, TimingViol3_13);
	$hold(posedge CK &&& (CSWEMTBYPASS[14] != 0), posedge D[14], tdh, TimingViol3_14);
	$hold(posedge CK &&& (CSWEMTBYPASS[15] != 0), posedge D[15], tdh, TimingViol3_15);
	$hold(posedge CK &&& (CSWEMTBYPASS[16] != 0), posedge D[16], tdh, TimingViol3_16);
	$hold(posedge CK &&& (CSWEMTBYPASS[17] != 0), posedge D[17], tdh, TimingViol3_17);
	$hold(posedge CK &&& (CSWEMTBYPASS[18] != 0), posedge D[18], tdh, TimingViol3_18);
	$hold(posedge CK &&& (CSWEMTBYPASS[19] != 0), posedge D[19], tdh, TimingViol3_19);
	$hold(posedge CK &&& (CSWEMTBYPASS[20] != 0), posedge D[20], tdh, TimingViol3_20);
	$hold(posedge CK &&& (CSWEMTBYPASS[21] != 0), posedge D[21], tdh, TimingViol3_21);
	$hold(posedge CK &&& (CSWEMTBYPASS[22] != 0), posedge D[22], tdh, TimingViol3_22);
	$hold(posedge CK &&& (CSWEMTBYPASS[23] != 0), posedge D[23], tdh, TimingViol3_23);
	$hold(posedge CK &&& (CSWEMTBYPASS[24] != 0), posedge D[24], tdh, TimingViol3_24);
	$hold(posedge CK &&& (CSWEMTBYPASS[25] != 0), posedge D[25], tdh, TimingViol3_25);
	$hold(posedge CK &&& (CSWEMTBYPASS[26] != 0), posedge D[26], tdh, TimingViol3_26);
	$hold(posedge CK &&& (CSWEMTBYPASS[27] != 0), posedge D[27], tdh, TimingViol3_27);
	$hold(posedge CK &&& (CSWEMTBYPASS[28] != 0), posedge D[28], tdh, TimingViol3_28);
	$hold(posedge CK &&& (CSWEMTBYPASS[29] != 0), posedge D[29], tdh, TimingViol3_29);
	$hold(posedge CK &&& (CSWEMTBYPASS[30] != 0), posedge D[30], tdh, TimingViol3_30);
	$hold(posedge CK &&& (CSWEMTBYPASS[31] != 0), posedge D[31], tdh, TimingViol3_31);
	$hold(posedge CK &&& (CSWEMTBYPASS[32] != 0), posedge D[32], tdh, TimingViol3_32);
	$hold(posedge CK &&& (CSWEMTBYPASS[33] != 0), posedge D[33], tdh, TimingViol3_33);
	$hold(posedge CK &&& (CSWEMTBYPASS[34] != 0), posedge D[34], tdh, TimingViol3_34);
	$hold(posedge CK &&& (CSWEMTBYPASS[35] != 0), posedge D[35], tdh, TimingViol3_35);
	$hold(posedge CK &&& (CSWEMTBYPASS[36] != 0), posedge D[36], tdh, TimingViol3_36);
	$hold(posedge CK &&& (CSWEMTBYPASS[37] != 0), posedge D[37], tdh, TimingViol3_37);
	$hold(posedge CK &&& (CSWEMTBYPASS[38] != 0), posedge D[38], tdh, TimingViol3_38);
	$hold(posedge CK &&& (CSWEMTBYPASS[39] != 0), posedge D[39], tdh, TimingViol3_39);
	$hold(posedge CK &&& (CSWEMTBYPASS[40] != 0), posedge D[40], tdh, TimingViol3_40);
	$hold(posedge CK &&& (CSWEMTBYPASS[41] != 0), posedge D[41], tdh, TimingViol3_41);
	$hold(posedge CK &&& (CSWEMTBYPASS[42] != 0), posedge D[42], tdh, TimingViol3_42);
	$hold(posedge CK &&& (CSWEMTBYPASS[43] != 0), posedge D[43], tdh, TimingViol3_43);
	$hold(posedge CK &&& (CSWEMTBYPASS[44] != 0), posedge D[44], tdh, TimingViol3_44);
	$hold(posedge CK &&& (CSWEMTBYPASS[45] != 0), posedge D[45], tdh, TimingViol3_45);
	$hold(posedge CK &&& (CSWEMTBYPASS[46] != 0), posedge D[46], tdh, TimingViol3_46);
	$hold(posedge CK &&& (CSWEMTBYPASS[47] != 0), posedge D[47], tdh, TimingViol3_47);
	$hold(posedge CK &&& (CSWEMTBYPASS[48] != 0), posedge D[48], tdh, TimingViol3_48);
	$hold(posedge CK &&& (CSWEMTBYPASS[49] != 0), posedge D[49], tdh, TimingViol3_49);
	$hold(posedge CK &&& (CSWEMTBYPASS[50] != 0), posedge D[50], tdh, TimingViol3_50);
	$hold(posedge CK &&& (CSWEMTBYPASS[51] != 0), posedge D[51], tdh, TimingViol3_51);
	$hold(posedge CK &&& (CSWEMTBYPASS[52] != 0), posedge D[52], tdh, TimingViol3_52);
	$hold(posedge CK &&& (CSWEMTBYPASS[53] != 0), posedge D[53], tdh, TimingViol3_53);
	$hold(posedge CK &&& (CSWEMTBYPASS[54] != 0), posedge D[54], tdh, TimingViol3_54);
	$hold(posedge CK &&& (CSWEMTBYPASS[55] != 0), posedge D[55], tdh, TimingViol3_55);
	$hold(posedge CK &&& (CSWEMTBYPASS[56] != 0), posedge D[56], tdh, TimingViol3_56);
	$hold(posedge CK &&& (CSWEMTBYPASS[57] != 0), posedge D[57], tdh, TimingViol3_57);
	$hold(posedge CK &&& (CSWEMTBYPASS[58] != 0), posedge D[58], tdh, TimingViol3_58);
	$hold(posedge CK &&& (CSWEMTBYPASS[59] != 0), posedge D[59], tdh, TimingViol3_59);
	$hold(posedge CK &&& (CSWEMTBYPASS[60] != 0), posedge D[60], tdh, TimingViol3_60);
	$hold(posedge CK &&& (CSWEMTBYPASS[61] != 0), posedge D[61], tdh, TimingViol3_61);
	$hold(posedge CK &&& (CSWEMTBYPASS[62] != 0), posedge D[62], tdh, TimingViol3_62);
	$hold(posedge CK &&& (CSWEMTBYPASS[63] != 0), posedge D[63], tdh, TimingViol3_63);
	$hold(posedge CK &&& (CSWEMTBYPASS[0] != 0), negedge D[0], tdh, TimingViol3_0);
	$hold(posedge CK &&& (CSWEMTBYPASS[1] != 0), negedge D[1], tdh, TimingViol3_1);
	$hold(posedge CK &&& (CSWEMTBYPASS[2] != 0), negedge D[2], tdh, TimingViol3_2);
	$hold(posedge CK &&& (CSWEMTBYPASS[3] != 0), negedge D[3], tdh, TimingViol3_3);
	$hold(posedge CK &&& (CSWEMTBYPASS[4] != 0), negedge D[4], tdh, TimingViol3_4);
	$hold(posedge CK &&& (CSWEMTBYPASS[5] != 0), negedge D[5], tdh, TimingViol3_5);
	$hold(posedge CK &&& (CSWEMTBYPASS[6] != 0), negedge D[6], tdh, TimingViol3_6);
	$hold(posedge CK &&& (CSWEMTBYPASS[7] != 0), negedge D[7], tdh, TimingViol3_7);
	$hold(posedge CK &&& (CSWEMTBYPASS[8] != 0), negedge D[8], tdh, TimingViol3_8);
	$hold(posedge CK &&& (CSWEMTBYPASS[9] != 0), negedge D[9], tdh, TimingViol3_9);
	$hold(posedge CK &&& (CSWEMTBYPASS[10] != 0), negedge D[10], tdh, TimingViol3_10);
	$hold(posedge CK &&& (CSWEMTBYPASS[11] != 0), negedge D[11], tdh, TimingViol3_11);
	$hold(posedge CK &&& (CSWEMTBYPASS[12] != 0), negedge D[12], tdh, TimingViol3_12);
	$hold(posedge CK &&& (CSWEMTBYPASS[13] != 0), negedge D[13], tdh, TimingViol3_13);
	$hold(posedge CK &&& (CSWEMTBYPASS[14] != 0), negedge D[14], tdh, TimingViol3_14);
	$hold(posedge CK &&& (CSWEMTBYPASS[15] != 0), negedge D[15], tdh, TimingViol3_15);
	$hold(posedge CK &&& (CSWEMTBYPASS[16] != 0), negedge D[16], tdh, TimingViol3_16);
	$hold(posedge CK &&& (CSWEMTBYPASS[17] != 0), negedge D[17], tdh, TimingViol3_17);
	$hold(posedge CK &&& (CSWEMTBYPASS[18] != 0), negedge D[18], tdh, TimingViol3_18);
	$hold(posedge CK &&& (CSWEMTBYPASS[19] != 0), negedge D[19], tdh, TimingViol3_19);
	$hold(posedge CK &&& (CSWEMTBYPASS[20] != 0), negedge D[20], tdh, TimingViol3_20);
	$hold(posedge CK &&& (CSWEMTBYPASS[21] != 0), negedge D[21], tdh, TimingViol3_21);
	$hold(posedge CK &&& (CSWEMTBYPASS[22] != 0), negedge D[22], tdh, TimingViol3_22);
	$hold(posedge CK &&& (CSWEMTBYPASS[23] != 0), negedge D[23], tdh, TimingViol3_23);
	$hold(posedge CK &&& (CSWEMTBYPASS[24] != 0), negedge D[24], tdh, TimingViol3_24);
	$hold(posedge CK &&& (CSWEMTBYPASS[25] != 0), negedge D[25], tdh, TimingViol3_25);
	$hold(posedge CK &&& (CSWEMTBYPASS[26] != 0), negedge D[26], tdh, TimingViol3_26);
	$hold(posedge CK &&& (CSWEMTBYPASS[27] != 0), negedge D[27], tdh, TimingViol3_27);
	$hold(posedge CK &&& (CSWEMTBYPASS[28] != 0), negedge D[28], tdh, TimingViol3_28);
	$hold(posedge CK &&& (CSWEMTBYPASS[29] != 0), negedge D[29], tdh, TimingViol3_29);
	$hold(posedge CK &&& (CSWEMTBYPASS[30] != 0), negedge D[30], tdh, TimingViol3_30);
	$hold(posedge CK &&& (CSWEMTBYPASS[31] != 0), negedge D[31], tdh, TimingViol3_31);
	$hold(posedge CK &&& (CSWEMTBYPASS[32] != 0), negedge D[32], tdh, TimingViol3_32);
	$hold(posedge CK &&& (CSWEMTBYPASS[33] != 0), negedge D[33], tdh, TimingViol3_33);
	$hold(posedge CK &&& (CSWEMTBYPASS[34] != 0), negedge D[34], tdh, TimingViol3_34);
	$hold(posedge CK &&& (CSWEMTBYPASS[35] != 0), negedge D[35], tdh, TimingViol3_35);
	$hold(posedge CK &&& (CSWEMTBYPASS[36] != 0), negedge D[36], tdh, TimingViol3_36);
	$hold(posedge CK &&& (CSWEMTBYPASS[37] != 0), negedge D[37], tdh, TimingViol3_37);
	$hold(posedge CK &&& (CSWEMTBYPASS[38] != 0), negedge D[38], tdh, TimingViol3_38);
	$hold(posedge CK &&& (CSWEMTBYPASS[39] != 0), negedge D[39], tdh, TimingViol3_39);
	$hold(posedge CK &&& (CSWEMTBYPASS[40] != 0), negedge D[40], tdh, TimingViol3_40);
	$hold(posedge CK &&& (CSWEMTBYPASS[41] != 0), negedge D[41], tdh, TimingViol3_41);
	$hold(posedge CK &&& (CSWEMTBYPASS[42] != 0), negedge D[42], tdh, TimingViol3_42);
	$hold(posedge CK &&& (CSWEMTBYPASS[43] != 0), negedge D[43], tdh, TimingViol3_43);
	$hold(posedge CK &&& (CSWEMTBYPASS[44] != 0), negedge D[44], tdh, TimingViol3_44);
	$hold(posedge CK &&& (CSWEMTBYPASS[45] != 0), negedge D[45], tdh, TimingViol3_45);
	$hold(posedge CK &&& (CSWEMTBYPASS[46] != 0), negedge D[46], tdh, TimingViol3_46);
	$hold(posedge CK &&& (CSWEMTBYPASS[47] != 0), negedge D[47], tdh, TimingViol3_47);
	$hold(posedge CK &&& (CSWEMTBYPASS[48] != 0), negedge D[48], tdh, TimingViol3_48);
	$hold(posedge CK &&& (CSWEMTBYPASS[49] != 0), negedge D[49], tdh, TimingViol3_49);
	$hold(posedge CK &&& (CSWEMTBYPASS[50] != 0), negedge D[50], tdh, TimingViol3_50);
	$hold(posedge CK &&& (CSWEMTBYPASS[51] != 0), negedge D[51], tdh, TimingViol3_51);
	$hold(posedge CK &&& (CSWEMTBYPASS[52] != 0), negedge D[52], tdh, TimingViol3_52);
	$hold(posedge CK &&& (CSWEMTBYPASS[53] != 0), negedge D[53], tdh, TimingViol3_53);
	$hold(posedge CK &&& (CSWEMTBYPASS[54] != 0), negedge D[54], tdh, TimingViol3_54);
	$hold(posedge CK &&& (CSWEMTBYPASS[55] != 0), negedge D[55], tdh, TimingViol3_55);
	$hold(posedge CK &&& (CSWEMTBYPASS[56] != 0), negedge D[56], tdh, TimingViol3_56);
	$hold(posedge CK &&& (CSWEMTBYPASS[57] != 0), negedge D[57], tdh, TimingViol3_57);
	$hold(posedge CK &&& (CSWEMTBYPASS[58] != 0), negedge D[58], tdh, TimingViol3_58);
	$hold(posedge CK &&& (CSWEMTBYPASS[59] != 0), negedge D[59], tdh, TimingViol3_59);
	$hold(posedge CK &&& (CSWEMTBYPASS[60] != 0), negedge D[60], tdh, TimingViol3_60);
	$hold(posedge CK &&& (CSWEMTBYPASS[61] != 0), negedge D[61], tdh, TimingViol3_61);
	$hold(posedge CK &&& (CSWEMTBYPASS[62] != 0), negedge D[62], tdh, TimingViol3_62);
	$hold(posedge CK &&& (CSWEMTBYPASS[63] != 0), negedge D[63], tdh, TimingViol3_63);

        
        $setup(posedge CSN, edge[01,0x,x1,1x] CK &&& TBYPASSint != 1'b1, tps, TimingViol4);
	$setup(negedge CSN, edge[01,0x,x1,1x] CK &&& TBYPASSint != 1'b1, tps, TimingViol4);
	$hold(edge[01,0x,x1,x0] CK &&& TBYPASSint != 1'b1, posedge CSN, tph, TimingViol5);
	$hold(edge[01,0x,x1,x0] CK &&& TBYPASSint != 1'b1, negedge CSN, tph, TimingViol5);
        $setup(posedge WEN, edge[01,0x,x1,1x] CK &&& (CSTBYPASSN != 'b0), tws, TimingViol6);
        $setup(negedge WEN, edge[01,0x,x1,1x] CK &&& (CSTBYPASSN != 'b0), tws, TimingViol6);
        $hold(edge[01,0x,x1,x0] CK &&& (CSTBYPASSN != 'b0), posedge WEN, twh, TimingViol7);
        $hold(edge[01,0x,x1,x0] CK &&& (CSTBYPASSN != 'b0), negedge WEN, twh, TimingViol7);
        

        $period(posedge CK &&& (csn_tcycle != 0), tcycle, TimingViol10); 
        $period(posedge CK &&& (CS_taa != 0), tcycle_taa, TimingViol10_taa);
        $width(posedge CK &&& (csn_tckh != 'b0), tckh, 0, TimingViol8);
        $width(negedge CK &&& (csn_tckl != 'b0), tckl, 0, TimingViol9);
        
        // TBYPASS setup/hold violations
        $setup(posedge TBYPASS, posedge CK &&& (CS != 0),ttms, TimingViol_ttms_ttmh);
        $setup(negedge TBYPASS, posedge CK &&& (CS != 0),ttms, TimingViol_ttms_ttmh);

        $hold(posedge CK &&& (CS != 1'b0), posedge TBYPASS, ttmh, TimingViol_ttms_ttmh);
        $hold(posedge CK &&& (CS != 1'b0), negedge TBYPASS, ttmh, TimingViol_ttms_ttmh); 



        $period(posedge CK &&& (CS_taa_ry != 0), tcycle_taa_ry, TimingViol10_taa_ry);
        $width(negedge CK &&& (csn_tckl_ry!= 0), tckl_tck_ry, 0, TimingViol9_tck_ry);


        
	endspecify

always @(CKint)
begin
   CKreg <= CKint;
end

always @(posedge CKint)
begin
   if (CSNint !== 1)
   begin
      Dreg = Dint;
      Mreg = Mint;
      WENreg = WENint;
      Areg = Aint;
   end
   CSNreg = CSNint;
   if (CSNint === 1'b1)
      tckh_flag = 0;
   else
      tckh_flag = 1;
        
tckl_flag = 1;
end
     
always @(negedge CKint)
begin
   #0.00   tckh_flag = 1;
   if (CSNint === 1)
      tckl_flag = 0;
   else
      tckl_flag = 1;
end
     
always @(CSNint)
begin
   if (CKint !== 1)
      tckl_flag = ~CSNint;
end

always @(TimingViol10_taa)
begin
   if(debug_level < 2)
   $display("%m - %t WARNING: READ/WRITE ACCESS TIME IS GREATER THAN THE CLOCK PERIOD",$realtime);
end

// conversion from registers to array elements for mask setup violation notifiers


// conversion from registers to array elements for mask hold violation notifiers


// conversion from registers to array elements for data setup violation notifiers

always @(TimingViol2_63)
begin
   TimingViol2[63] = TimingViol2_63;
end


always @(TimingViol2_62)
begin
   TimingViol2[62] = TimingViol2_62;
end


always @(TimingViol2_61)
begin
   TimingViol2[61] = TimingViol2_61;
end


always @(TimingViol2_60)
begin
   TimingViol2[60] = TimingViol2_60;
end


always @(TimingViol2_59)
begin
   TimingViol2[59] = TimingViol2_59;
end


always @(TimingViol2_58)
begin
   TimingViol2[58] = TimingViol2_58;
end


always @(TimingViol2_57)
begin
   TimingViol2[57] = TimingViol2_57;
end


always @(TimingViol2_56)
begin
   TimingViol2[56] = TimingViol2_56;
end


always @(TimingViol2_55)
begin
   TimingViol2[55] = TimingViol2_55;
end


always @(TimingViol2_54)
begin
   TimingViol2[54] = TimingViol2_54;
end


always @(TimingViol2_53)
begin
   TimingViol2[53] = TimingViol2_53;
end


always @(TimingViol2_52)
begin
   TimingViol2[52] = TimingViol2_52;
end


always @(TimingViol2_51)
begin
   TimingViol2[51] = TimingViol2_51;
end


always @(TimingViol2_50)
begin
   TimingViol2[50] = TimingViol2_50;
end


always @(TimingViol2_49)
begin
   TimingViol2[49] = TimingViol2_49;
end


always @(TimingViol2_48)
begin
   TimingViol2[48] = TimingViol2_48;
end


always @(TimingViol2_47)
begin
   TimingViol2[47] = TimingViol2_47;
end


always @(TimingViol2_46)
begin
   TimingViol2[46] = TimingViol2_46;
end


always @(TimingViol2_45)
begin
   TimingViol2[45] = TimingViol2_45;
end


always @(TimingViol2_44)
begin
   TimingViol2[44] = TimingViol2_44;
end


always @(TimingViol2_43)
begin
   TimingViol2[43] = TimingViol2_43;
end


always @(TimingViol2_42)
begin
   TimingViol2[42] = TimingViol2_42;
end


always @(TimingViol2_41)
begin
   TimingViol2[41] = TimingViol2_41;
end


always @(TimingViol2_40)
begin
   TimingViol2[40] = TimingViol2_40;
end


always @(TimingViol2_39)
begin
   TimingViol2[39] = TimingViol2_39;
end


always @(TimingViol2_38)
begin
   TimingViol2[38] = TimingViol2_38;
end


always @(TimingViol2_37)
begin
   TimingViol2[37] = TimingViol2_37;
end


always @(TimingViol2_36)
begin
   TimingViol2[36] = TimingViol2_36;
end


always @(TimingViol2_35)
begin
   TimingViol2[35] = TimingViol2_35;
end


always @(TimingViol2_34)
begin
   TimingViol2[34] = TimingViol2_34;
end


always @(TimingViol2_33)
begin
   TimingViol2[33] = TimingViol2_33;
end


always @(TimingViol2_32)
begin
   TimingViol2[32] = TimingViol2_32;
end


always @(TimingViol2_31)
begin
   TimingViol2[31] = TimingViol2_31;
end


always @(TimingViol2_30)
begin
   TimingViol2[30] = TimingViol2_30;
end


always @(TimingViol2_29)
begin
   TimingViol2[29] = TimingViol2_29;
end


always @(TimingViol2_28)
begin
   TimingViol2[28] = TimingViol2_28;
end


always @(TimingViol2_27)
begin
   TimingViol2[27] = TimingViol2_27;
end


always @(TimingViol2_26)
begin
   TimingViol2[26] = TimingViol2_26;
end


always @(TimingViol2_25)
begin
   TimingViol2[25] = TimingViol2_25;
end


always @(TimingViol2_24)
begin
   TimingViol2[24] = TimingViol2_24;
end


always @(TimingViol2_23)
begin
   TimingViol2[23] = TimingViol2_23;
end


always @(TimingViol2_22)
begin
   TimingViol2[22] = TimingViol2_22;
end


always @(TimingViol2_21)
begin
   TimingViol2[21] = TimingViol2_21;
end


always @(TimingViol2_20)
begin
   TimingViol2[20] = TimingViol2_20;
end


always @(TimingViol2_19)
begin
   TimingViol2[19] = TimingViol2_19;
end


always @(TimingViol2_18)
begin
   TimingViol2[18] = TimingViol2_18;
end


always @(TimingViol2_17)
begin
   TimingViol2[17] = TimingViol2_17;
end


always @(TimingViol2_16)
begin
   TimingViol2[16] = TimingViol2_16;
end


always @(TimingViol2_15)
begin
   TimingViol2[15] = TimingViol2_15;
end


always @(TimingViol2_14)
begin
   TimingViol2[14] = TimingViol2_14;
end


always @(TimingViol2_13)
begin
   TimingViol2[13] = TimingViol2_13;
end


always @(TimingViol2_12)
begin
   TimingViol2[12] = TimingViol2_12;
end


always @(TimingViol2_11)
begin
   TimingViol2[11] = TimingViol2_11;
end


always @(TimingViol2_10)
begin
   TimingViol2[10] = TimingViol2_10;
end


always @(TimingViol2_9)
begin
   TimingViol2[9] = TimingViol2_9;
end


always @(TimingViol2_8)
begin
   TimingViol2[8] = TimingViol2_8;
end


always @(TimingViol2_7)
begin
   TimingViol2[7] = TimingViol2_7;
end


always @(TimingViol2_6)
begin
   TimingViol2[6] = TimingViol2_6;
end


always @(TimingViol2_5)
begin
   TimingViol2[5] = TimingViol2_5;
end


always @(TimingViol2_4)
begin
   TimingViol2[4] = TimingViol2_4;
end


always @(TimingViol2_3)
begin
   TimingViol2[3] = TimingViol2_3;
end


always @(TimingViol2_2)
begin
   TimingViol2[2] = TimingViol2_2;
end


always @(TimingViol2_1)
begin
   TimingViol2[1] = TimingViol2_1;
end


always @(TimingViol2_0)
begin
   TimingViol2[0] = TimingViol2_0;
end


// conversion from registers to array elements for data hold violation notifiers

always @(TimingViol3_63)
begin
   TimingViol3[63] = TimingViol3_63;
end


always @(TimingViol3_62)
begin
   TimingViol3[62] = TimingViol3_62;
end


always @(TimingViol3_61)
begin
   TimingViol3[61] = TimingViol3_61;
end


always @(TimingViol3_60)
begin
   TimingViol3[60] = TimingViol3_60;
end


always @(TimingViol3_59)
begin
   TimingViol3[59] = TimingViol3_59;
end


always @(TimingViol3_58)
begin
   TimingViol3[58] = TimingViol3_58;
end


always @(TimingViol3_57)
begin
   TimingViol3[57] = TimingViol3_57;
end


always @(TimingViol3_56)
begin
   TimingViol3[56] = TimingViol3_56;
end


always @(TimingViol3_55)
begin
   TimingViol3[55] = TimingViol3_55;
end


always @(TimingViol3_54)
begin
   TimingViol3[54] = TimingViol3_54;
end


always @(TimingViol3_53)
begin
   TimingViol3[53] = TimingViol3_53;
end


always @(TimingViol3_52)
begin
   TimingViol3[52] = TimingViol3_52;
end


always @(TimingViol3_51)
begin
   TimingViol3[51] = TimingViol3_51;
end


always @(TimingViol3_50)
begin
   TimingViol3[50] = TimingViol3_50;
end


always @(TimingViol3_49)
begin
   TimingViol3[49] = TimingViol3_49;
end


always @(TimingViol3_48)
begin
   TimingViol3[48] = TimingViol3_48;
end


always @(TimingViol3_47)
begin
   TimingViol3[47] = TimingViol3_47;
end


always @(TimingViol3_46)
begin
   TimingViol3[46] = TimingViol3_46;
end


always @(TimingViol3_45)
begin
   TimingViol3[45] = TimingViol3_45;
end


always @(TimingViol3_44)
begin
   TimingViol3[44] = TimingViol3_44;
end


always @(TimingViol3_43)
begin
   TimingViol3[43] = TimingViol3_43;
end


always @(TimingViol3_42)
begin
   TimingViol3[42] = TimingViol3_42;
end


always @(TimingViol3_41)
begin
   TimingViol3[41] = TimingViol3_41;
end


always @(TimingViol3_40)
begin
   TimingViol3[40] = TimingViol3_40;
end


always @(TimingViol3_39)
begin
   TimingViol3[39] = TimingViol3_39;
end


always @(TimingViol3_38)
begin
   TimingViol3[38] = TimingViol3_38;
end


always @(TimingViol3_37)
begin
   TimingViol3[37] = TimingViol3_37;
end


always @(TimingViol3_36)
begin
   TimingViol3[36] = TimingViol3_36;
end


always @(TimingViol3_35)
begin
   TimingViol3[35] = TimingViol3_35;
end


always @(TimingViol3_34)
begin
   TimingViol3[34] = TimingViol3_34;
end


always @(TimingViol3_33)
begin
   TimingViol3[33] = TimingViol3_33;
end


always @(TimingViol3_32)
begin
   TimingViol3[32] = TimingViol3_32;
end


always @(TimingViol3_31)
begin
   TimingViol3[31] = TimingViol3_31;
end


always @(TimingViol3_30)
begin
   TimingViol3[30] = TimingViol3_30;
end


always @(TimingViol3_29)
begin
   TimingViol3[29] = TimingViol3_29;
end


always @(TimingViol3_28)
begin
   TimingViol3[28] = TimingViol3_28;
end


always @(TimingViol3_27)
begin
   TimingViol3[27] = TimingViol3_27;
end


always @(TimingViol3_26)
begin
   TimingViol3[26] = TimingViol3_26;
end


always @(TimingViol3_25)
begin
   TimingViol3[25] = TimingViol3_25;
end


always @(TimingViol3_24)
begin
   TimingViol3[24] = TimingViol3_24;
end


always @(TimingViol3_23)
begin
   TimingViol3[23] = TimingViol3_23;
end


always @(TimingViol3_22)
begin
   TimingViol3[22] = TimingViol3_22;
end


always @(TimingViol3_21)
begin
   TimingViol3[21] = TimingViol3_21;
end


always @(TimingViol3_20)
begin
   TimingViol3[20] = TimingViol3_20;
end


always @(TimingViol3_19)
begin
   TimingViol3[19] = TimingViol3_19;
end


always @(TimingViol3_18)
begin
   TimingViol3[18] = TimingViol3_18;
end


always @(TimingViol3_17)
begin
   TimingViol3[17] = TimingViol3_17;
end


always @(TimingViol3_16)
begin
   TimingViol3[16] = TimingViol3_16;
end


always @(TimingViol3_15)
begin
   TimingViol3[15] = TimingViol3_15;
end


always @(TimingViol3_14)
begin
   TimingViol3[14] = TimingViol3_14;
end


always @(TimingViol3_13)
begin
   TimingViol3[13] = TimingViol3_13;
end


always @(TimingViol3_12)
begin
   TimingViol3[12] = TimingViol3_12;
end


always @(TimingViol3_11)
begin
   TimingViol3[11] = TimingViol3_11;
end


always @(TimingViol3_10)
begin
   TimingViol3[10] = TimingViol3_10;
end


always @(TimingViol3_9)
begin
   TimingViol3[9] = TimingViol3_9;
end


always @(TimingViol3_8)
begin
   TimingViol3[8] = TimingViol3_8;
end


always @(TimingViol3_7)
begin
   TimingViol3[7] = TimingViol3_7;
end


always @(TimingViol3_6)
begin
   TimingViol3[6] = TimingViol3_6;
end


always @(TimingViol3_5)
begin
   TimingViol3[5] = TimingViol3_5;
end


always @(TimingViol3_4)
begin
   TimingViol3[4] = TimingViol3_4;
end


always @(TimingViol3_3)
begin
   TimingViol3[3] = TimingViol3_3;
end


always @(TimingViol3_2)
begin
   TimingViol3[2] = TimingViol3_2;
end


always @(TimingViol3_1)
begin
   TimingViol3[1] = TimingViol3_1;
end


always @(TimingViol3_0)
begin
   TimingViol3[0] = TimingViol3_0;
end




ST_SPHDL_160x64m8_L_main ST_SPHDL_160x64m8_L_maininst ( Q_glitchint,  Q_dataint, Q_gCKint, RY_rfCKint, RY_rrCKint, RY_frCKint, ICRYint, delTBYPASSint, TBYPASS_D_Qint, TBYPASS_mainint, CKint,  CSNint , TBYPASSint, WENint,  Aint, Dint, Mint, debug_level  , TimingViol0, TimingViol1, TimingViol2, TimingViol3, TimingViol4, TimingViol5, TimingViol6, TimingViol7, TimingViol8, TimingViol9, TimingViol10, TimingViol_ttms_ttmh, TimingViol12, TimingViol13      );

ST_SPHDL_160x64m8_L_OPschlr ST_SPHDL_160x64m8_L_OPschlrinst (Qint, RYint,  Q_gCKint, Q_glitchint,  Q_dataint, RY_rfCKint, RY_rrCKint, RY_frCKint, ICRYint, delTBYPASSint, TBYPASS_D_Qint, TBYPASS_mainint  );

defparam ST_SPHDL_160x64m8_L_maininst.Fault_file_name = Fault_file_name;
defparam ST_SPHDL_160x64m8_L_maininst.ConfigFault = ConfigFault;
defparam ST_SPHDL_160x64m8_L_maininst.max_faults = max_faults;
defparam ST_SPHDL_160x64m8_L_maininst.MEM_INITIALIZE = MEM_INITIALIZE;
defparam ST_SPHDL_160x64m8_L_maininst.BinaryInit = BinaryInit;
defparam ST_SPHDL_160x64m8_L_maininst.InitFileName = InitFileName;

endmodule

`endif

`delay_mode_path
`disable_portfaults
`nosuppress_faults
`endcelldefine










/****************************************************************
--  Description         : verilog_model for ST_SPHDL cmos65
--  ModelVersion        : 4.4
--  Date                : Jun, 2008
--  Changes Made by	: DRM
--
****************************************************************/

/******************** START OF HEADER****************************
   This Header Gives Information about the parameters & options present in the Model

   words = 640
   bits  = 32
   mux   = 16 
   
   
   
   
   
   

**********************END OF HEADER ******************************/



`ifdef slm
        `define functional
`endif
`celldefine
`suppress_faults
`enable_portfaults
`ifdef functional
   `timescale 1ns / 1ns
   `delay_mode_unit
`endif

`ifdef functional



module ST_SPHDL_640x32m16_L (Q, RY,CK, CSN, TBYPASS, WEN, A, D    );   
 
    parameter
        Fault_file_name = "ST_SPHDL_640x32m16_L_faults.txt",
        ConfigFault = 0,
        max_faults = 20,
        MEM_INITIALIZE  = 1'b0,
        BinaryInit = 1'b0,
        InitFileName = "ST_SPHDL_640x32m16_L.cde",
        Corruption_Read_Violation = 1,
        Debug_mode = "all_warning_mode",
        InstancePath = "ST_SPHDL_640x32m16_L";
    
    parameter
        Words = 640,
        Bits = 32,
        Addr = 10,
        mux = 16,
        Rows = Words/mux;




   


    parameter
        WordX = 32'bx,
        AddrX = 10'bx,
        Word0 = 32'b0,
        X = 1'bx;


	output [Bits-1 : 0] Q;
        
        output RY;   
        
        input [Bits-1 : 0] D;
	input [Addr-1 : 0] A;
	        
        input CK, CSN, TBYPASS, WEN;

        
        
        

        



        reg [Bits-1 : 0] Qint;
         
           
	wire [Bits-1 : 0] Dint,Mint;
        
        assign Mint=32'b0;
        
        wire [Addr-1 : 0] Aint;
	wire CKint;
	wire CSNint;
	wire WENint;

        
        	
        wire TBYPASSint;
        

        
        wire RYint;
          
          
           buf (RY, RYint);  
         
        reg RY_outreg, RY_out;
           
        assign RYint = RY_out;

        
        
        
        // REG DECLARATION
        
	//Output Register for tbypass
        reg [Bits-1 : 0] tbydata;
        //delayed Output Register
        reg [Bits-1 : 0] delOutReg_data;
        reg [Bits-1 : 0] OutReg_data;   // Data Output register
	reg [Bits-1 : 0] tempMem;
	reg lastCK;
        reg CSNreg;	

        `ifdef slm
        `else
	reg [Bits-1 : 0] Mem [Words-1 : 0]; // RAM array
        `endif
	
	reg [Bits-1 :0] Mem_temp;
	reg ValidAddress;
	reg ValidDebugCode;
        

        
        reg WENreg;
        
        reg [1:0] debug_level;
        reg [8*10: 0] operating_mode;
        reg [8*44: 0] message_status;

        integer d, a, p, i, k, j, l;
        `ifdef slm
           integer MemAddr;
        `endif


        //************************************************************
        //****** CONFIG FAULT IMPLEMENTATION VARIABLES*************** 
        //************************************************************ 

        integer file_ptr, ret_val;
        integer fault_word;
        integer fault_bit;
        integer fcnt, Fault_in_memory;
        integer n, cnt, t;  
        integer FailureLocn [max_faults -1 :0];

        reg [100 : 0] stuck_at;
        reg [200 : 0] tempStr;
        reg [7:0] fault_char;
        reg [7:0] fault_char1; // 8 Bit File Pointer
        reg [Addr -1 : 0] std_fault_word;
        reg [max_faults -1 :0] fault_repair_flag;
        reg [max_faults -1 :0] repair_flag;
        reg [Bits - 1: 0] stuck_at_0fault [max_faults -1 : 0];
        reg [Bits - 1: 0] stuck_at_1fault [max_faults -1 : 0];
        reg [100 : 0] array_stuck_at[max_faults -1 : 0] ; 
        reg msgcnt;
        

        reg [Bits -1 : 0] stuck0;
        reg [Bits -1 : 0] stuck1;

        `ifdef slm
        reg [Bits -1 : 0] slm_temp_data;
        `endif
        

        integer flag_error;

        
          
          buf bufq [Bits-1:0] (Q,Qint);
        
        
        buf bufdata [Bits-1:0] (Dint,D);
        buf bufaddr [Addr-1:0] (Aint,A);
        
	buf (TBYPASSint, TBYPASS);
	buf (CKint, CK);
	
        //MEM_EN = CSN or  TBYPASS
        
        or (CSNint, CSN, TBYPASS);   
	
        buf (WENint, WEN);
        
        
        
        

        

// BEHAVIOURAL MODULE DESCRIPTION

task WriteMemX;
begin
   `ifdef slm
   $slm_ResetMemory(MemAddr, WordX);
   `else
    for (i = 0; i < Words; i = i + 1)
       Mem[i] = WordX;
   `endif        
end
endtask


task WriteOutX;                
begin
   OutReg_data= WordX;
end
endtask

task WriteCycle;                  
input [Addr-1 : 0] Address;
reg [Bits-1:0] tempReg1,tempReg2;
integer po,i;
begin

   tempReg1 = WordX;
   if (^Address !== X) begin
      if (ValidAddress) begin
      `ifdef slm
         $slm_ReadMemoryS(MemAddr, Address, tempReg1);
      `else
         tempReg1 = Mem[Address];
      `endif
            
         for (po=0;po<Bits;po=po+1) begin
            if (Mint[po] === 1'b0)
               tempReg1[po] = Dint[po];
            else if ((Mint[po] !== 1'b1) && (tempReg1[po] !== Dint[po]))
               tempReg1[po] = 1'bx;
         end                
      `ifdef slm
         $slm_WriteMemory(MemAddr, Address, tempReg1);
      `else
         Mem[Address] = tempReg1;
      `endif
      end//if (ValidAddress)
      else
         if(debug_level < 2) $display("%m - %t (MSG_ID 701) WARNING: Address Out Of Range. ",$realtime); 
   end //if (^Address !== X)
   else
   begin
      if(debug_level < 2) $display("%m - %t (MSG_ID 008) WARNING: Illegal Value on Address Bus. Memory Corrupted ",$realtime);
      WriteMemX;
   end
 end

endtask

task ReadCycle;
input [Addr-1 : 0] Address;
reg [Bits-1:0] MemData;
integer a;
begin
   if (ValidAddress)
   begin        
      `ifdef slm
       $slm_ReadMemory(MemAddr, Address, MemData);
      `else
      MemData = Mem[Address];
      `endif
   end //if (ValidAddress)  
                
   if(ValidAddress === X)
   begin
      if (Corruption_Read_Violation === 1)
      begin   
         if(debug_level < 2) $display("%m - %t (MSG_ID 008) WARNING: Illegal Value on Address Bus. Memory and Output Corrupted ",$realtime);
         WriteMemX;
      end
      else
         if(debug_level < 2) $display("%m - %t (MSG_ID 008) WARNING: Illegal Value on Address Bus. Output Corrupted ",$realtime);
      MemData = WordX;
   end                        
   else if (ValidAddress === 0)
   begin                        
      if(debug_level < 2) $display("%m - %t (MSG_ID 701) WARNING: Address Out Of Range. Output Corrupted ",$realtime); 
      MemData = WordX;
   end
   
   OutReg_data = MemData;
end
endtask

task wen_x_handler;
input [Addr-1 : 0] Address;
input [Bits-1 : 0] Mask;
reg [Bits-1 : 0] prev_data;
begin
   if(^Address !== X) begin
      if (Address < Words) begin
      `ifdef slm
         $slm_ReadMemoryS(MemAddr, Address, tempMem);
      `else
         tempMem = Mem[Address];
      `endif
         prev_data = tempMem;  
         for (j = 0;j< Bits; j=j+1) begin
            //calculating data to write in memory
            if (tempMem[j] !== Dint[j]) begin
               if (Mask[j] !== 1'b1) begin
                  tempMem[j] = 1'bx;
               end
            end
            //calculating data to write on output
            if (prev_data[j] !== OutReg_data[j]) begin
               OutReg_data[j]  = 1'bx;
            end
         end//for (j = 0;j< Bits;
      end
      else begin
         WriteOutX;
      end   
   end  //  if(^Address !== X)
   else begin
      WriteMemX;
      WriteOutX;
   end  //else  
`ifdef slm
   $slm_WriteMemory(MemAddr, Address, tempMem);
`else
   Mem[Address] = tempMem;
`endif
end
endtask
        

task task_insert_faults_in_memory;
begin
   Fault_in_memory = 1;
   for(i = 0;i< fcnt;i = i+ 1)
   begin
      if (fault_repair_flag[i] !== 1)
      begin
         Fault_in_memory = 0;
         if (array_stuck_at[i] === "sa0")
         begin
            `ifdef slm
            //Read first
            $slm_ReadMemoryS(MemAddr, FailureLocn[i], slm_temp_data);
            //operation
            slm_temp_data = slm_temp_data & stuck_at_0fault[i];
            //write back
            $slm_WriteMemoryS(MemAddr, FailureLocn[i], slm_temp_data);
            `else
            Mem[FailureLocn[i]] = Mem[FailureLocn[i]] & stuck_at_0fault[i];
            `endif
         end //if(array_stuck_at)
                                        
         if(array_stuck_at[i] === "sa1")
         begin
            `ifdef slm
            //Read first
            $slm_ReadMemoryS(MemAddr, FailureLocn[i], slm_temp_data);
            //operation
            slm_temp_data = slm_temp_data | stuck_at_1fault[i];
            //write back
            $slm_WriteMemoryS(MemAddr, FailureLocn[i], slm_temp_data);
            `else
            Mem[FailureLocn[i]] = Mem[FailureLocn[i]] | stuck_at_1fault[i]; 
            `endif
         end //if(array_stuck_at)
      end//if (fault_repair_flag
   end// for loop...
end
endtask






initial
begin
   // Define format for timing value
  $timeformat (-9, 2, " ns", 0);
  `ifdef slm
  $slm_RegisterMemory(MemAddr, Words, Bits);
  `endif   
  
  debug_level= 2'b0;
   message_status = "All Messages are Switched ON";
  `ifdef  NO_WARNING_MODE
     debug_level = 2'b10;
     message_status = "All Warning Messages are Switched OFF";
  `endif  
  `ifdef slm
     operating_mode = "SLM";
  `else
     operating_mode = "FUNCTIONAL";
  `endif
if(debug_level !== 2'b10) begin
  $display ("%mINFORMATION ");
  $display ("***************************************");
  $display ("The Model is Operating in %s MODE", operating_mode);
  $display ("%s", message_status);
  if(ConfigFault)
  $display ("Configurable Fault Functionality is ON");   
  else
  $display ("Configurable Fault Functionality is OFF");  
   
  $display ("***************************************");
end
  if (MEM_INITIALIZE === 1'b1)
  begin   
     `ifdef slm
        if (BinaryInit)
           $slm_LoadMemory(MemAddr, InitFileName, "VERILOG_BIN");
        else
           $slm_LoadMemory(MemAddr, InitFileName, "VERILOG_HEX");

     `else
        if (BinaryInit)
           $readmemb(InitFileName, Mem, 0, Words-1);
        else
           $readmemh(InitFileName, Mem, 0, Words-1);
     `endif
  end

  
  RY_out = 1'b1;


        
/*  -----------Implemetation for config fault starts------*/
   msgcnt = X;
   t = 0;
   fault_repair_flag = {max_faults{1'b1}};
   repair_flag = {max_faults{1'b1}};
   if(ConfigFault) 
   begin
        file_ptr = $fopen(Fault_file_name , "r");
        if(file_ptr == 0)
        begin     
          if(debug_level < 3) $display("%m - %t (MSG_ID 201) FAILURE: File cannot be opened ",$realtime);      
        end        
      else                
      begin : read_fault_file
      t = 0;
      for (i = 0; i< max_faults; i= i + 1)
      begin
         
         stuck0 = {Bits{1'b1}};
         stuck1 = {Bits{1'b0}};
         fault_char1 = $fgetc (file_ptr);
         if (fault_char1 == 8'b11111111)
                 disable read_fault_file;
         ret_val = $ungetc (fault_char1, file_ptr);
         ret_val = $fgets(tempStr, file_ptr);
         ret_val = $sscanf(tempStr, "%d %d %s",fault_word, fault_bit, stuck_at) ;
        flag_error = 0; 
         if(ret_val !== 0)
            begin         
               if(ret_val == 2 || ret_val == 3)
               begin
                  if(ret_val == 2)
                      stuck_at = "sa0";

                  if(stuck_at !== "sa0" && stuck_at !== "sa1" && stuck_at !== "none")
                  begin
                      if(debug_level < 2) $display("%m - %t (MSG_ID 203) WARNING: Wrong value for stuck at in fault file ",$realtime);
                      flag_error = 1;
                  end    
                      
                  if(fault_word > Words-1)
                  begin
                      if(debug_level < 2) $display("%m - %t (MSG_ID 206) WARNING: Address out of range in fault file ",$realtime);
                      flag_error = 1;
                  end    

                  if(fault_bit > Bits)
                  begin  
                      if(debug_level < 2) $display("%m - %t (MSG_ID 205) WARNING: Faulty bit out of range in fault file ",$realtime);
                      flag_error = 1;
                  end    

                  if(flag_error == 0)
                  //Correct Inputs
                  begin
                      if(stuck_at === "none")
                      begin
                         if(debug_level < 2) $display("%m - %t (MSG_ID 202) WARNING: No fault injected, empty fault file ",$realtime);
                      end
                      else
                      //Adding the faults
                      begin
                         FailureLocn[t] = fault_word;
                         std_fault_word = fault_word;
                         
                         fault_repair_flag[t] = 1'b0;
                         if (stuck_at === "sa0" )
                         begin
                            stuck0[fault_bit] = 1'b0;         
                            stuck_at_0fault[t] = stuck0;
                         end     
                         if (stuck_at === "sa1" )
                         begin
                            stuck1[fault_bit] = 1'b1;
                            stuck_at_1fault[t] = stuck1; 
                         end

                         array_stuck_at[t] = stuck_at;
                         t = t + 1;
                      end //if(stuck_at === "none")  
                  end //if(flag_error == 0)
               end //if(ret_val == 2 || ret_val == 3 
               else
               //wrong number of arguments
               begin
                  if(debug_level < 2)
                  $display("%m - %t WARNING :  WRONG VALUES ENTERED FOR FAULTY WORD OR FAULTY BIT OR STUCK_AT IN Fault_file_name", $realtime);
                  flag_error = 1;
               end
             end //if(ret_val !== 0)
             else
             begin
                 if(debug_level < 2) $display("%m - %t (MSG_ID 202) WARNING: No fault injected, empty fault file ",$realtime);
             end    
      end //for (i = 0; i< m
      end //begin: read_fault_file  
      $fclose (file_ptr);

      fcnt = t;
      
      //fault injection at time 0.
      task_insert_faults_in_memory;
      
   end // config_fault 
end// initial



//+++++++++++++++++++++++++++++++ CONFIG FAULT IMPLEMETATION ENDS+++++++++++++++++++++++++++++++//
        
always @(CKint)
begin
   if(CKint === 1'b1 && lastCK === 1'b0)
      CSNreg = CSNint;
   
   if(CKint === 1'b1 && lastCK === 1'b0 && CSNint === 1'b0) begin
      WENreg = WENint;
      if (^Aint === X)
         ValidAddress = X;
      else if (Aint < Words)
         ValidAddress = 1;
      else    
         ValidAddress = 0;

      if (ValidAddress)
      `ifdef slm
         $slm_ReadMemoryS(MemAddr, Aint, Mem_temp);
      `else        
         Mem_temp = Mem[Aint];
      `endif       
      else
         Mem_temp = WordX; 
         
      /*---------------------- Normal Read and Write -----------------*/
      
         RY_outreg = ~CKint;
         if (WENint === 1) begin
            ReadCycle(Aint);
         end
         else if (WENint === 0) begin
            WriteCycle(Aint);
         end
         else if (WENint === X) begin
            // Uncertain write cycle
            if (^Aint === X) begin
               WriteOutX;
               WriteMemX;
            end
            else
              wen_x_handler(Aint,Mint);
         end                 
            
      
   end // if(CKint === 1'b1...)
   // Unknown Clock Behaviour or unknown control signal
   else if((CKint === 1'b1 && CSNint === 1'bx) || (CKint === 1'bx && CSNreg !== 1'b1)) begin
      WriteOutX;
      WriteMemX;
       
      RY_out = 1'bX;
      if(CKint === 1'bx && CSNreg !== 1'b1) begin
         if(debug_level < 2) $display("%m - %t (MSG_ID 003) WARNING: Illegal Value on Clock. Memory and Output Corrupted ",$realtime);
      end
      else begin
         if(debug_level < 2) $display("%m - %t (MSG_ID 010) WARNING: Invalid control signal (chip select / memory bypass) Memory and Output Corrupted ",$realtime);
      end
   end
             
   

   if(ConfigFault) begin
      task_insert_faults_in_memory;
   
   end//if(ConfigFault)

   
   lastCK = CKint;
end // always @(CKint)
        
always @(CSNint)
begin

// Unknown Clock & CSN signal
   if (CSNint !== 1 && CKint === 1'bx)
   begin
      if(debug_level < 2) $display("%m - %t (MSG_ID 010) WARNING: Invalid control signal (chip select / memory bypass) Memory and Output Corrupted ",$realtime);
      WriteMemX;
      WriteOutX;
      
      RY_out = 1'bX;
   end

end

  



//TBYPASS functionality
always @(TBYPASSint)
begin
 
   
   delOutReg_data = WordX;
   OutReg_data = WordX;
   if(TBYPASSint !== 1'b0) begin        
      if(TBYPASSint === 1'b1) 
         tbydata = Dint;
      else
         tbydata = WordX;
   end        
   else                         // TBYPASSint = 0
   begin        
      Qint = WordX;
        // tbydata holds no relevance when tbypass is inactive
   end        


end //end of always TBYPASSint

always @(Dint)
begin

   
   if(TBYPASSint === 1'b1)
      tbydata = Dint;

   
end //end of always Dint

//assign output data
always @(OutReg_data)
   #1 delOutReg_data = OutReg_data;

always @(delOutReg_data or tbydata or TBYPASSint ) begin

if(TBYPASSint === 1'bX )
      Qint = WordX;
else if (TBYPASSint === 1'b1 )
      Qint = tbydata;    
else
      
      Qint = delOutReg_data;

end


always @(TBYPASSint)
begin
   if(TBYPASSint !== 1'b0)
    RY_outreg = 1'bx;
end

always @(negedge CKint)
begin

   
   if((TBYPASSint === 1'b0) && (CSNreg === 1'b0) && RY_out !== 1'bx)
    RY_outreg = ~CKint;


end

always @(RY_outreg)
begin
  #1 RY_out = RY_outreg;
end




 
// Power down functionality for verilog_model



endmodule

`else

`timescale 1ns / 1ps
`delay_mode_path


module ST_SPHDL_640x32m16_L_main ( Q_glitch,  Q_data, Q_gCK, RY_rfCK, RY_rrCK, RY_frCK, ICRY, delTBYPASS, TBYPASS_D_Q, TBYPASS_main, CK,  CSN, TBYPASS, WEN,  A, D, M,debug_level ,TimingViol0, TimingViol1, TimingViol2, TimingViol3, TimingViol4, TimingViol5, TimingViol6, TimingViol7, TimingViol8, TimingViol9, TimingViol10, TimingViol_ttms_ttmh, TimingViol12, TimingViol13     );
    
   parameter
        Fault_file_name = "ST_SPHDL_640x32m16_L_faults.txt",
        ConfigFault = 0,
        max_faults = 20,
        MEM_INITIALIZE  = 1'b0,
        BinaryInit = 1'b0,
        InitFileName = "ST_SPHDL_640x32m16_L.cde",
        Debug_mode = "ALL_WARNING_MODE",
        InstancePath = "ST_SPHDL_640x32m16_L";

   parameter
        Words = 640,
        Bits = 32,
        Addr = 10,
        mux = 16,
        Rows = Words/mux;


       

   


    parameter
        WordX = 32'bx,
        AddrX = 10'bx,
        X = 1'bx;

	output [Bits-1 : 0] Q_glitch;
	output [Bits-1 : 0] Q_data;
	output [Bits-1 : 0] Q_gCK;
        
        output ICRY;
        output RY_rfCK;
	output RY_rrCK;
	output RY_frCK;   
	output [Bits-1 : 0] delTBYPASS; 
	output TBYPASS_main; 
        output [Bits-1 : 0] TBYPASS_D_Q;
        
        input [Bits-1 : 0] D, M;
	input [Addr-1 : 0] A;
	input CK, CSN, TBYPASS, WEN;
        input [1 : 0] debug_level;

	input [Bits-1 : 0] TimingViol2, TimingViol3, TimingViol12, TimingViol13;
	input TimingViol0, TimingViol1, TimingViol4, TimingViol5, TimingViol6, TimingViol7, TimingViol8, TimingViol9, TimingViol10, TimingViol_ttms_ttmh;

        
        
        
       
        
        
        

	wire [Bits-1 : 0] Dint,Mint;
	wire [Addr-1 : 0] Aint;
	wire CKint;
	wire CSNint;
	wire WENint;
        
        






	wire  Mreg_0;
	wire  Mreg_1;
	wire  Mreg_2;
	wire  Mreg_3;
	wire  Mreg_4;
	wire  Mreg_5;
	wire  Mreg_6;
	wire  Mreg_7;
	wire  Mreg_8;
	wire  Mreg_9;
	wire  Mreg_10;
	wire  Mreg_11;
	wire  Mreg_12;
	wire  Mreg_13;
	wire  Mreg_14;
	wire  Mreg_15;
	wire  Mreg_16;
	wire  Mreg_17;
	wire  Mreg_18;
	wire  Mreg_19;
	wire  Mreg_20;
	wire  Mreg_21;
	wire  Mreg_22;
	wire  Mreg_23;
	wire  Mreg_24;
	wire  Mreg_25;
	wire  Mreg_26;
	wire  Mreg_27;
	wire  Mreg_28;
	wire  Mreg_29;
	wire  Mreg_30;
	wire  Mreg_31;
	
	reg [Bits-1 : 0] OutReg_glitch; // Glitch Output register
        reg [Bits-1 : 0] OutReg_data;   // Data Output register
	reg [Bits-1 : 0] Dreg,Mreg;
	reg [Bits-1 : 0] Mreg_temp;
	reg [Bits-1 : 0] tempMem;
	reg [Bits-1 : 0] prevMem;
	reg [Addr-1 : 0] Areg;
	reg [Bits-1 : 0] Q_gCKreg; 
	reg [Bits-1 : 0] lastQ_gCK;
	reg [Bits-1 : 0] last_Qdata;
	reg lastCK, CKreg;
	reg CSNreg;
	reg WENreg;
        
        reg [Bits-1 : 0] TimingViol2_last,TimingViol3_last;
        reg [Bits-1 : 0] TimingViol12_last,TimingViol13_last;
	
	reg [Bits-1 : 0] Mem [Words-1 : 0]; // RAM array
	
	reg [Bits-1 :0] Mem_temp;
	reg ValidAddress;
	reg ValidDebugCode;

	reg ICGFlag;
           
        reg Operation_Flag;
	

        
        reg [Bits-1:0] Mem_Red [2*mux-1:0];
        
        integer d, a, p, i, k, j, l;

        //************************************************************
        //****** CONFIG FAULT IMPLEMENTATION VARIABLES*************** 
        //************************************************************ 

        integer file_ptr, ret_val;
        integer fault_word;
        integer fault_bit;
        integer fcnt, Fault_in_memory;
        integer n, cnt, t;  
        integer FailureLocn [max_faults -1 :0];

        reg [100 : 0] stuck_at;
        reg [200 : 0] tempStr;
        reg [7:0] fault_char;
        reg [7:0] fault_char1; // 8 Bit File Pointer
        reg [Addr -1 : 0] std_fault_word;
        reg [max_faults -1 :0] fault_repair_flag;
        reg [max_faults -1 :0] repair_flag;
        reg [Bits - 1: 0] stuck_at_0fault [max_faults -1 : 0];
        reg [Bits - 1: 0] stuck_at_1fault [max_faults -1 : 0];
        reg [100 : 0] array_stuck_at[max_faults -1 : 0] ; 
        reg msgcnt;
        

        reg [Bits -1 : 0] stuck0;
        reg [Bits -1 : 0] stuck1;
        integer flag_error;

	assign Mreg_0 = Mreg[0];
	assign Mreg_1 = Mreg[1];
	assign Mreg_2 = Mreg[2];
	assign Mreg_3 = Mreg[3];
	assign Mreg_4 = Mreg[4];
	assign Mreg_5 = Mreg[5];
	assign Mreg_6 = Mreg[6];
	assign Mreg_7 = Mreg[7];
	assign Mreg_8 = Mreg[8];
	assign Mreg_9 = Mreg[9];
	assign Mreg_10 = Mreg[10];
	assign Mreg_11 = Mreg[11];
	assign Mreg_12 = Mreg[12];
	assign Mreg_13 = Mreg[13];
	assign Mreg_14 = Mreg[14];
	assign Mreg_15 = Mreg[15];
	assign Mreg_16 = Mreg[16];
	assign Mreg_17 = Mreg[17];
	assign Mreg_18 = Mreg[18];
	assign Mreg_19 = Mreg[19];
	assign Mreg_20 = Mreg[20];
	assign Mreg_21 = Mreg[21];
	assign Mreg_22 = Mreg[22];
	assign Mreg_23 = Mreg[23];
	assign Mreg_24 = Mreg[24];
	assign Mreg_25 = Mreg[25];
	assign Mreg_26 = Mreg[26];
	assign Mreg_27 = Mreg[27];
	assign Mreg_28 = Mreg[28];
	assign Mreg_29 = Mreg[29];
	assign Mreg_30 = Mreg[30];
	assign Mreg_31 = Mreg[31];
        buf bufdint [Bits-1:0] (Dint, D);
        buf bufmint [Bits-1:0] (Mint, M);
        buf bufaint [Addr-1:0] (Aint, A);
	
	buf (TBYPASS_main, TBYPASS);
	buf (CKint, CK);
        
        buf (CSNint, CSN);    
	buf (WENint, WEN);

        //TBYPASS functionality
        
        buf bufdeltb [Bits-1:0] (delTBYPASS, TBYPASS);
          
        
        
        buf buftbdq [Bits-1:0] (TBYPASS_D_Q, D );
         
        
        
        







        wire RY_rfCKint, RY_rrCKint, RY_frCKint, ICRYFlagint;
        reg RY_rfCKreg, RY_rrCKreg, RY_frCKreg; 
	reg InitialRYFlag, ICRYFlag;

        
        buf (RY_rfCK, RY_rfCKint);
	buf (RY_rrCK, RY_rrCKint);
	buf (RY_frCK, RY_frCKint);
        buf (ICRY, ICRYFlagint);
        assign ICRYFlagint = ICRYFlag;
        
        

    specify
        specparam

            tdq = 0.01,
            ttmq = 0.01,
            
            taa_ry = 0.01,
            th_ry = 0.009,
            tck_ry = 0.01,
            taa = 1.00,
            th = 0.009;
        /*-------------------- Propagation Delays ------------------*/

   
	if (WENreg && !ICGFlag) (CK *> (Q_data[0] : D[0])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[1] : D[1])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[2] : D[2])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[3] : D[3])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[4] : D[4])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[5] : D[5])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[6] : D[6])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[7] : D[7])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[8] : D[8])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[9] : D[9])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[10] : D[10])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[11] : D[11])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[12] : D[12])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[13] : D[13])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[14] : D[14])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[15] : D[15])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[16] : D[16])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[17] : D[17])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[18] : D[18])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[19] : D[19])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[20] : D[20])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[21] : D[21])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[22] : D[22])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[23] : D[23])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[24] : D[24])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[25] : D[25])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[26] : D[26])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[27] : D[27])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[28] : D[28])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[29] : D[29])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[30] : D[30])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[31] : D[31])) = (taa, taa); 
   

	if (!ICGFlag) (CK *> (Q_glitch[0] : D[0])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[1] : D[1])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[2] : D[2])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[3] : D[3])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[4] : D[4])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[5] : D[5])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[6] : D[6])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[7] : D[7])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[8] : D[8])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[9] : D[9])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[10] : D[10])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[11] : D[11])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[12] : D[12])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[13] : D[13])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[14] : D[14])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[15] : D[15])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[16] : D[16])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[17] : D[17])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[18] : D[18])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[19] : D[19])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[20] : D[20])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[21] : D[21])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[22] : D[22])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[23] : D[23])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[24] : D[24])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[25] : D[25])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[26] : D[26])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[27] : D[27])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[28] : D[28])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[29] : D[29])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[30] : D[30])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[31] : D[31])) = (th, th);

	if (!ICGFlag) (CK *> (Q_gCK[0] : D[0])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[1] : D[1])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[2] : D[2])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[3] : D[3])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[4] : D[4])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[5] : D[5])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[6] : D[6])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[7] : D[7])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[8] : D[8])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[9] : D[9])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[10] : D[10])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[11] : D[11])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[12] : D[12])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[13] : D[13])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[14] : D[14])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[15] : D[15])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[16] : D[16])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[17] : D[17])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[18] : D[18])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[19] : D[19])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[20] : D[20])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[21] : D[21])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[22] : D[22])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[23] : D[23])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[24] : D[24])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[25] : D[25])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[26] : D[26])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[27] : D[27])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[28] : D[28])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[29] : D[29])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[30] : D[30])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[31] : D[31])) = (th, th);

	if (!TBYPASS) (TBYPASS *> delTBYPASS[0]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[1]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[2]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[3]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[4]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[5]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[6]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[7]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[8]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[9]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[10]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[11]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[12]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[13]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[14]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[15]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[16]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[17]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[18]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[19]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[20]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[21]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[22]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[23]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[24]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[25]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[26]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[27]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[28]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[29]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[30]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[31]) = (0);
	if (TBYPASS) (TBYPASS *> delTBYPASS[0]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[1]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[2]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[3]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[4]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[5]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[6]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[7]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[8]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[9]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[10]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[11]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[12]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[13]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[14]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[15]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[16]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[17]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[18]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[19]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[20]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[21]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[22]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[23]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[24]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[25]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[26]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[27]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[28]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[29]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[30]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[31]) = (ttmq);
      (D[0] *> TBYPASS_D_Q[0]) = (tdq, tdq);
      (D[1] *> TBYPASS_D_Q[1]) = (tdq, tdq);
      (D[2] *> TBYPASS_D_Q[2]) = (tdq, tdq);
      (D[3] *> TBYPASS_D_Q[3]) = (tdq, tdq);
      (D[4] *> TBYPASS_D_Q[4]) = (tdq, tdq);
      (D[5] *> TBYPASS_D_Q[5]) = (tdq, tdq);
      (D[6] *> TBYPASS_D_Q[6]) = (tdq, tdq);
      (D[7] *> TBYPASS_D_Q[7]) = (tdq, tdq);
      (D[8] *> TBYPASS_D_Q[8]) = (tdq, tdq);
      (D[9] *> TBYPASS_D_Q[9]) = (tdq, tdq);
      (D[10] *> TBYPASS_D_Q[10]) = (tdq, tdq);
      (D[11] *> TBYPASS_D_Q[11]) = (tdq, tdq);
      (D[12] *> TBYPASS_D_Q[12]) = (tdq, tdq);
      (D[13] *> TBYPASS_D_Q[13]) = (tdq, tdq);
      (D[14] *> TBYPASS_D_Q[14]) = (tdq, tdq);
      (D[15] *> TBYPASS_D_Q[15]) = (tdq, tdq);
      (D[16] *> TBYPASS_D_Q[16]) = (tdq, tdq);
      (D[17] *> TBYPASS_D_Q[17]) = (tdq, tdq);
      (D[18] *> TBYPASS_D_Q[18]) = (tdq, tdq);
      (D[19] *> TBYPASS_D_Q[19]) = (tdq, tdq);
      (D[20] *> TBYPASS_D_Q[20]) = (tdq, tdq);
      (D[21] *> TBYPASS_D_Q[21]) = (tdq, tdq);
      (D[22] *> TBYPASS_D_Q[22]) = (tdq, tdq);
      (D[23] *> TBYPASS_D_Q[23]) = (tdq, tdq);
      (D[24] *> TBYPASS_D_Q[24]) = (tdq, tdq);
      (D[25] *> TBYPASS_D_Q[25]) = (tdq, tdq);
      (D[26] *> TBYPASS_D_Q[26]) = (tdq, tdq);
      (D[27] *> TBYPASS_D_Q[27]) = (tdq, tdq);
      (D[28] *> TBYPASS_D_Q[28]) = (tdq, tdq);
      (D[29] *> TBYPASS_D_Q[29]) = (tdq, tdq);
      (D[30] *> TBYPASS_D_Q[30]) = (tdq, tdq);
      (D[31] *> TBYPASS_D_Q[31]) = (tdq, tdq);


        // RY functionality
	if (!ICRYFlag && InitialRYFlag) (CK *> RY_rfCK) = (th_ry, th_ry);

        if (!ICRYFlag && InitialRYFlag) (CK *> RY_rrCK) = (taa_ry, taa_ry); 
	if (!ICRYFlag && InitialRYFlag) (CK *> RY_frCK) = (tck_ry, tck_ry);   

	endspecify


assign #0 Q_data = OutReg_data;
assign Q_glitch = OutReg_glitch;
assign Q_gCK = Q_gCKreg;




    // BEHAVIOURAL MODULE DESCRIPTION

task chstate;
   input [Bits-1 : 0] clkin;
   output [Bits-1 : 0] clkout;
   integer d;
begin
   if ( $realtime != 0 )
      for (d = 0; d < Bits; d = d + 1)
      begin
         if (clkin[d] === 1'b0)
            clkout[d] = 1'b1;
         else if (clkin[d] === 1'b1)
            clkout[d] = 1'bx;
         else
            clkout[d] = 1'b0;
      end
end
endtask


task task_insert_faults_in_memory;
begin
   Fault_in_memory = 1;
   for(i = 0;i< fcnt;i = i+ 1)
   begin
     if (fault_repair_flag[i] !== 1)
     begin
       Fault_in_memory = 0;
       if (array_stuck_at[i] === "sa0")
       begin
          Mem[FailureLocn[i]] = Mem[FailureLocn[i]] & stuck_at_0fault[i];
       end //if(array_stuck_at)
                                              
       if(array_stuck_at[i] === "sa1")
       begin
         Mem[FailureLocn[i]] = Mem[FailureLocn[i]] | stuck_at_1fault[i]; 
       end //if(array_stuck_at)
     end//if (fault_repair_flag
   end// for loop...
end
endtask



task WriteMemX;
begin
    for (i = 0; i < Words; i = i + 1)
       Mem[i] = WordX;
end
endtask

task WriteLocX;
   input [Addr-1 : 0] Address;
begin
   if (^Address !== X)
       Mem[Address] = WordX;
   else
      WriteMemX;
end
endtask

task WriteLocMskX;
  input [Addr-1 : 0] Address;
  input [Bits-1 : 0] Mask;
  input [Bits-1 : 0] prevMem;
  reg [Bits-1 : 0] Outdata;
begin
  if (^Address !== X)
  begin
      tempMem = Mem[Address];
     for (j = 0;j< Bits; j=j+1)
     begin
        if (prevMem[j] !== Dreg[j]) 
        begin
           if (Mask[j] !== 1'b1)
              tempMem[j] = 1'bx;
        end
     end//for (j = 0;j< Bi

     Mem[Address] = tempMem;
  end//if (^Address !== X
  else
     WriteMemX;
end
endtask

task WriteLocMskX_bwise;
   input [Addr-1 : 0] Address;
   input [Bits-1 : 0] Mask;
begin
   if (^Address !== X)
   begin
      tempMem = Mem[Address];
             
      for (j = 0;j< Bits; j=j+1)
         if (Mask[j] === 1'bx)
            tempMem[j] = 1'bx;
                    
      Mem[Address] = tempMem;

   end//if (^Address !== X
   else
      WriteMemX;
end
endtask
    
task WriteOutX;                
begin
   OutReg_data= WordX;
   OutReg_glitch= WordX;
end
endtask

task WriteOutX_bwise;
   input [Bits-1 : 0] flag;
   input [Bits-1 : 0] Delayedflag;
   input [Addr-1 : 0] Address;
   reg [Bits-1 : 0] MemData;
begin
    MemData = Mem[Address];
        
   for ( l = 0; l < Bits; l = l + 1 )
      if (Delayedflag[l] !== flag[l] && MemData[l] === 1'bx)
      begin
         OutReg_data[l] = 1'bx;
	 OutReg_glitch[l] = 1'bx;
      end
end
endtask

task WriteOut;
begin
   for (i = 0;i < Bits; i = i+1)
   begin        
   
      if (last_Qdata[i] !== Mem_temp[i])     
      begin
         OutReg_data[i] = 1'bX;
         OutReg_glitch[i] = 1'bX;
      end
      else
         OutReg_glitch[i] = OutReg_data[i];
   end   
end
endtask  

task WriteCycle;                  
   input [Addr-1 : 0] Address;
   reg [Bits-1:0] tempReg1,tempReg2;
   integer po,i;
begin

   tempReg1 = WordX;
   if (^Address !== X)
   begin
      if (ValidAddress)
      begin
         
                 tempReg1 = Mem[Address];
                 for (po=0;po<Bits;po=po+1)
                 if (Mreg[po] === 1'b0)
                       tempReg1[po] = Dreg[po];
                 else if ((Mreg[po] !== 1'b1) && (tempReg1[po] !== Dreg[po]))
                       tempReg1[po] = 1'bx;
                        
                 Mem[Address] = tempReg1;
                    
      end //if (ValidAddress)
      else
         if(debug_level < 2) $display("%m - %t (MSG_ID 701) WARNING: Write Port:  Address Out Of Range. ",$realtime);
   end//if (^Address !== X)
   else
   begin
      if(debug_level < 2) $display("%m - %t (MSG_ID 008) WARNING: Write Port:  Illegal Value on Address Bus. Memory Corrupted ",$realtime);
      WriteMemX;
   end
 end

endtask

task ReadCycle;
   input [Addr-1 : 0] Address;
   reg [Bits-1:0] MemData;
   integer a;
begin

   if (ValidAddress)
      MemData = Mem[Address];

   if(ValidAddress === X)
   begin
      if(debug_level < 2) $display("%m - %t (MSG_ID 008) WARNING: Read Port:  Illegal Value on Address Bus. Memory and Output Corrupted ",$realtime);
      WriteMemX;
      MemData = WordX;
   end                        
   else if (ValidAddress === 0)
   begin                        
      if(debug_level < 2) $display("%m - %t (MSG_ID 701) WARNING: Read Port:  Address Out Of Range. Output Corrupted ",$realtime);
      MemData = WordX;
   end

   for (a = 0; a < Bits; a = a + 1)
   begin
      if (MemData[a] !== OutReg_data[a])
         OutReg_glitch[a] = WordX[a];
      else
         OutReg_glitch[a] = MemData[a];
   end//for (a = 0; a <

   OutReg_data = MemData;
   Operation_Flag = 1;
   last_Qdata = Q_data;

end
endtask




assign RY_rfCKint = RY_rfCKreg;
assign RY_frCKint = RY_frCKreg;
assign RY_rrCKint = RY_rrCKreg;

// Define format for timing value
initial
begin
  $timeformat (-9, 2, " ns", 0);
  ICGFlag = 0;
  if (MEM_INITIALIZE === 1'b1)
  begin   
     if (BinaryInit)
        $readmemb(InitFileName, Mem, 0, Words-1);
     else
        $readmemh(InitFileName, Mem, 0, Words-1);
  end

  
  ICRYFlag = 1;
  InitialRYFlag = 0;
  ICRYFlag <= 0;
  RY_rfCKreg = 1'b1;
  RY_rrCKreg = 1'b1;
  RY_frCKreg = 1'b1;


/*  -----------Implemetation for config fault starts------*/
   msgcnt = X;
   t = 0;
   fault_repair_flag = {max_faults{1'b1}};
   repair_flag = {max_faults{1'b1}};
   if(ConfigFault) 
   begin
        file_ptr = $fopen(Fault_file_name , "r");
        if(file_ptr == 0)
        begin     
          if(debug_level < 3) $display("%m - %t (MSG_ID 201) FAILURE: File cannot be opened ",$realtime);      
        end        
      else                
      begin : read_fault_file
      t = 0;
      for (i = 0; i< max_faults; i= i + 1)
      begin
         
         stuck0 = {Bits{1'b1}};
         stuck1 = {Bits{1'b0}};
         fault_char1 = $fgetc (file_ptr);
         if (fault_char1 == 8'b11111111)
                 disable read_fault_file;
         ret_val = $ungetc (fault_char1, file_ptr);
         ret_val = $fgets(tempStr, file_ptr);
         ret_val = $sscanf(tempStr, "%d %d %s",fault_word, fault_bit, stuck_at) ;
        flag_error = 0; 
         if(ret_val !== 0)
            begin         
               if(ret_val == 2 || ret_val == 3)
               begin
                  if(ret_val == 2)
                      stuck_at = "sa0";

                  if(stuck_at !== "sa0" && stuck_at !== "sa1" && stuck_at !== "none")
                  begin
                      if(debug_level < 2) $display("%m - %t (MSG_ID 203) WARNING: Wrong value for stuck at in fault file ",$realtime);
                      flag_error = 1;
                  end    
                      
                  if(fault_word > Words-1)
                  begin
                      if(debug_level < 2) $display("%m - %t (MSG_ID 206) WARNING: Address out of range in fault file ",$realtime);
                      flag_error = 1;
                  end    

                  if(fault_bit > Bits)
                  begin  
                      if(debug_level < 2) $display("%m - %t (MSG_ID 205) WARNING: Faulty bit out of range in fault file ",$realtime);
                      flag_error = 1;
                  end    

                  if(flag_error == 0)
                  //Correct Inputs
                  begin
                      if(stuck_at === "none")
                      begin
                         if(debug_level < 2) $display("%m - %t (MSG_ID 202) WARNING: No fault injected, empty fault file ",$realtime);
                      end
                      else
                      //Adding the faults
                      begin
                         FailureLocn[t] = fault_word;
                         std_fault_word = fault_word;
                         
                         fault_repair_flag[t] = 1'b0;
                         if (stuck_at === "sa0" )
                         begin
                            stuck0[fault_bit] = 1'b0;         
                            stuck_at_0fault[t] = stuck0;
                         end     
                         if (stuck_at === "sa1" )
                         begin
                            stuck1[fault_bit] = 1'b1;
                            stuck_at_1fault[t] = stuck1; 
                         end

                         array_stuck_at[t] = stuck_at;
                         t = t + 1;
                      end //if(stuck_at === "none")  
                  end //if(flag_error == 0)
               end //if(ret_val == 2 || ret_val == 3 
               else
               //wrong number of arguments
               begin
                  if(debug_level < 2)
                  $display("%m - %t WARNING :  WRONG VALUES ENTERED FOR FAULTY WORD OR FAULTY BIT OR STUCK_AT IN Fault_file_name", $realtime);
                  flag_error = 1;
               end
             end //if(ret_val !== 0)
             else
             begin
                 if(debug_level < 2) $display("%m - %t (MSG_ID 202) WARNING: No fault injected, empty fault file ",$realtime);
             end    
      end //for (i = 0; i< m
      end //begin: read_fault_file  
      $fclose (file_ptr);
      fcnt = t;

      
      
      //fault injection at time 0.
      task_insert_faults_in_memory;
      

   end // config_fault 
end// initial



//+++++++++++++++++++++++++++++++ CONFIG FAULT IMPLEMETATION ENDS+++++++++++++++++++++++++++++++//

always @(CKint)
begin
   lastCK = CKreg;
   CKreg = CKint;
   if(CKreg === 1'b1 && lastCK === 1'b0)
   begin
     CSNreg = CSNint;
   end

   
   if (CKint !== 0 && CSNint !== 1)
   begin
     InitialRYFlag = 1;
   end
   

   
   if (CKint===1 && lastCK ===0 && CSNint === X)
       ICRYFlag = 1;
   else if (CKint === 1 && lastCK === 0 && CSNint === 0)
       ICRYFlag = 0;
   

   /*---------------------- Latching signals ----------------------*/
   if(CKreg === 1'b1 && lastCK === 1'b0)
   begin
      
      WENreg = WENint;
   end   
   if(CKreg === 1'b1 && lastCK === 1'b0 && CSNint === 1'b0) begin
      ICGFlag = 0;
      Dreg = Dint;
      Mreg = Mint;
      Areg = Aint;
      if (^Areg === X)
         ValidAddress = X;
      else if (Areg < Words)
         ValidAddress = 1;
      else
         ValidAddress = 0;

      if (ValidAddress)
         Mem_temp = Mem[Aint];
      else
         Mem_temp = WordX; 

      
      
      Operation_Flag = 0;
      last_Qdata = Q_data;
      
      /*------ Normal Read and Write --------*/
      if (WENreg === 1)
      begin
         ReadCycle(Areg);
         chstate(Q_gCKreg, Q_gCKreg);
      end//if (WENreg === 1 && C
      else if (WENreg === 0 )
      begin
         WriteCycle(Areg);
      end
      /*---------- Corruption due to faulty values on signals --------*/
      else if (WENreg === X)
      begin
         chstate(Q_gCKreg, Q_gCKreg);
         // Uncertain write cycle
         WriteLocMskX(Areg,Mreg,Mem_temp);
         WriteOut;
         if (^Areg === X || Areg > Words-1)
         begin
              WriteOutX;	// if add is unknown put X at output
         end    
      end//else if (WENreg =
      
         

      
   end//if(CKreg === 1'b1 && lastCK =   
   // Unknown Clock Behaviour
   else if (((CSNint === 1'bx) && (CKint === 1)) || (CKint=== 1'bx && CSNreg !==1)) begin
      WriteMemX;
      WriteOutX;
      ICGFlag = 1'b1;
       
      ICRYFlag = 1'b1;
      if(CKint === 1'bx && CSNreg !== 1'b1) begin
         if(debug_level < 2) $display("%m - %t (MSG_ID 003) WARNING: Illegal Value on Clock. Memory and Output Corrupted ",$realtime);
      end
      else begin
         if(debug_level < 2) $display("%m - %t (MSG_ID 010) WARNING: Invalid control signal (chip select / memory bypass) Memory and Output Corrupted ",$realtime);
      end
   end 
   if(ConfigFault) begin
      task_insert_faults_in_memory;
      
   end//if(ConfigFault)
   
 end // always @(CKint)

always @(CSNint)
begin   
   // Unknown Clock & CSN signal
      if (CSNint !== 1 && CKint === X )
      begin
         chstate(Q_gCKreg, Q_gCKreg);
       	 WriteMemX;
	 WriteOutX;
         
         ICRYFlag = 1;   
      end//if (CSNint !== 1
end      


always @(TBYPASS_main)
begin

   OutReg_data = WordX;
   OutReg_glitch = WordX;
   
   if (TBYPASS_main !== 0)
      ICRYFlag = 1;
   
end


  

        /*---------------RY Functionality-----------------*/
always @(posedge CKreg)
begin


   if ((CSNreg === 0) && (CKreg === 1 && lastCK === 0) && TBYPASS_main === 1'b0)
   begin
           RY_rfCKreg = ~RY_rfCKreg;
        RY_rrCKreg = ~RY_rrCKreg;
   end


end

always @(negedge CKreg)
begin

   
   if (TBYPASS_main === 1'b0 && (CSNreg === 1'b0) && (CKreg === 1'b0 && lastCK === 1'b1))
   begin
        RY_frCKreg = ~RY_frCKreg;
    end


end

always @(TimingViol9 or TimingViol10 or TimingViol4 or TimingViol5 or TimingViol8 )
ICRYFlag = 1;
        /*---------------------------------*/






   




   
/*---------------TBYPASS  Functionality in functional model -----------------*/

always @(TimingViol9 or TimingViol10 or TimingViol4 or TimingViol5 or TimingViol8)
begin
   if (TBYPASS !== 0)
      WriteMemX;
end

always @(TimingViol2 or TimingViol3)
// tds or tdh violation
begin
#0
   for (l = 0; l < Bits; l = l + 1)
   begin   
      if((TimingViol2[l] !== TimingViol2_last[l]))
         Mreg[l] = 1'bx;
      if((TimingViol3[l] !== TimingViol3_last[l]))
         Mreg[l] = 1'bx;   
   end   
   WriteLocMskX_bwise(Areg,Mreg);
   TimingViol2_last = TimingViol2;
   TimingViol3_last = TimingViol3;
end


        
/*---------- Corruption due to Timing Violations ---------------*/

always @(TimingViol9 or TimingViol10)
// tckl -  tcycle
begin
#0
   Dreg = WordX;
   WriteOutX;
   #0.00 WriteMemX;
end

always @(TimingViol4 or TimingViol5)
// tps or tph
begin
#0
   Dreg = WordX;
   if ((WENreg !== 0) || (lastCK === X))
      WriteOutX;
   if (lastCK === X)
      WriteMemX;  
   WriteMemX; 
   if (CSNreg === 1 && WENreg !== 0)
   begin
      chstate(Q_gCKreg, Q_gCKreg);
   end
end

always @(TimingViol8)
// tckh
begin
#0
   Dreg = WordX;
   ICGFlag = 1;
   chstate(Q_gCKreg, Q_gCKreg);
   WriteOutX;
   WriteMemX;
end

always @(TimingViol0 or TimingViol1)
// tas or tah
begin
#0
   Areg = AddrX;
   ValidAddress = X;
   if (WENreg !== 0)
      WriteOutX;
   WriteMemX;
end


always @(TimingViol6 or TimingViol7)
//tws or twh
begin
#0
   if (CSNreg === X)
   begin
      WriteMemX; 
      WriteOutX;
   end
   else
   begin
      WriteLocMskX(Areg,Mreg,Mem_temp); 
      WriteOut;
      if (^Areg === X)
         WriteOutX;	// if add is unknown put X at output
   end
end


always @(TimingViol_ttms_ttmh)
//ttms/ttmh
begin
#0
   Dreg = WordX;
   WriteOutX;
   WriteMemX;  
   
   ICRYFlag = 1; 
end





endmodule

module ST_SPHDL_640x32m16_L_OPschlr (QINT,  RYINT, Q_gCK, Q_glitch,  Q_data, RY_rfCK, RY_rrCK, RY_frCK, ICRY, delTBYPASS, TBYPASS_D_Q, TBYPASS_main  );

    parameter
        Words = 640,
        Bits = 32,
        Addr = 10;
        

    parameter
        WordX = 32'bx,
        AddrX = 10'bx,
        X = 1'bx;

	output [Bits-1 : 0] QINT;
	input [Bits-1 : 0] Q_glitch;
	input [Bits-1 : 0] Q_data;
	input [Bits-1 : 0] Q_gCK;
        input [Bits-1 : 0] TBYPASS_D_Q;
        input [Bits-1 : 0] delTBYPASS;
        input TBYPASS_main;



	integer m,a, d, n, o, p;
	wire [Bits-1 : 0] QINTint;
	wire [Bits-1 : 0] QINTERNAL;

        reg [Bits-1 : 0] OutReg;
	reg [Bits-1 : 0] lastQ_gCK, Q_gCKreg;
	reg [Bits-1 : 0] lastQ_data, Q_datareg;
	reg [Bits-1 : 0] QINTERNALreg;
	reg [Bits-1 : 0] lastQINTERNAL;

buf bufqint [Bits-1:0] (QINT, QINTint);


	assign QINTint[0] = (TBYPASS_main===0 && delTBYPASS[0]===0)?OutReg[0] : (TBYPASS_main===1 && delTBYPASS[0]===1)?TBYPASS_D_Q[0] : WordX;
	assign QINTint[1] = (TBYPASS_main===0 && delTBYPASS[1]===0)?OutReg[1] : (TBYPASS_main===1 && delTBYPASS[1]===1)?TBYPASS_D_Q[1] : WordX;
	assign QINTint[2] = (TBYPASS_main===0 && delTBYPASS[2]===0)?OutReg[2] : (TBYPASS_main===1 && delTBYPASS[2]===1)?TBYPASS_D_Q[2] : WordX;
	assign QINTint[3] = (TBYPASS_main===0 && delTBYPASS[3]===0)?OutReg[3] : (TBYPASS_main===1 && delTBYPASS[3]===1)?TBYPASS_D_Q[3] : WordX;
	assign QINTint[4] = (TBYPASS_main===0 && delTBYPASS[4]===0)?OutReg[4] : (TBYPASS_main===1 && delTBYPASS[4]===1)?TBYPASS_D_Q[4] : WordX;
	assign QINTint[5] = (TBYPASS_main===0 && delTBYPASS[5]===0)?OutReg[5] : (TBYPASS_main===1 && delTBYPASS[5]===1)?TBYPASS_D_Q[5] : WordX;
	assign QINTint[6] = (TBYPASS_main===0 && delTBYPASS[6]===0)?OutReg[6] : (TBYPASS_main===1 && delTBYPASS[6]===1)?TBYPASS_D_Q[6] : WordX;
	assign QINTint[7] = (TBYPASS_main===0 && delTBYPASS[7]===0)?OutReg[7] : (TBYPASS_main===1 && delTBYPASS[7]===1)?TBYPASS_D_Q[7] : WordX;
	assign QINTint[8] = (TBYPASS_main===0 && delTBYPASS[8]===0)?OutReg[8] : (TBYPASS_main===1 && delTBYPASS[8]===1)?TBYPASS_D_Q[8] : WordX;
	assign QINTint[9] = (TBYPASS_main===0 && delTBYPASS[9]===0)?OutReg[9] : (TBYPASS_main===1 && delTBYPASS[9]===1)?TBYPASS_D_Q[9] : WordX;
	assign QINTint[10] = (TBYPASS_main===0 && delTBYPASS[10]===0)?OutReg[10] : (TBYPASS_main===1 && delTBYPASS[10]===1)?TBYPASS_D_Q[10] : WordX;
	assign QINTint[11] = (TBYPASS_main===0 && delTBYPASS[11]===0)?OutReg[11] : (TBYPASS_main===1 && delTBYPASS[11]===1)?TBYPASS_D_Q[11] : WordX;
	assign QINTint[12] = (TBYPASS_main===0 && delTBYPASS[12]===0)?OutReg[12] : (TBYPASS_main===1 && delTBYPASS[12]===1)?TBYPASS_D_Q[12] : WordX;
	assign QINTint[13] = (TBYPASS_main===0 && delTBYPASS[13]===0)?OutReg[13] : (TBYPASS_main===1 && delTBYPASS[13]===1)?TBYPASS_D_Q[13] : WordX;
	assign QINTint[14] = (TBYPASS_main===0 && delTBYPASS[14]===0)?OutReg[14] : (TBYPASS_main===1 && delTBYPASS[14]===1)?TBYPASS_D_Q[14] : WordX;
	assign QINTint[15] = (TBYPASS_main===0 && delTBYPASS[15]===0)?OutReg[15] : (TBYPASS_main===1 && delTBYPASS[15]===1)?TBYPASS_D_Q[15] : WordX;
	assign QINTint[16] = (TBYPASS_main===0 && delTBYPASS[16]===0)?OutReg[16] : (TBYPASS_main===1 && delTBYPASS[16]===1)?TBYPASS_D_Q[16] : WordX;
	assign QINTint[17] = (TBYPASS_main===0 && delTBYPASS[17]===0)?OutReg[17] : (TBYPASS_main===1 && delTBYPASS[17]===1)?TBYPASS_D_Q[17] : WordX;
	assign QINTint[18] = (TBYPASS_main===0 && delTBYPASS[18]===0)?OutReg[18] : (TBYPASS_main===1 && delTBYPASS[18]===1)?TBYPASS_D_Q[18] : WordX;
	assign QINTint[19] = (TBYPASS_main===0 && delTBYPASS[19]===0)?OutReg[19] : (TBYPASS_main===1 && delTBYPASS[19]===1)?TBYPASS_D_Q[19] : WordX;
	assign QINTint[20] = (TBYPASS_main===0 && delTBYPASS[20]===0)?OutReg[20] : (TBYPASS_main===1 && delTBYPASS[20]===1)?TBYPASS_D_Q[20] : WordX;
	assign QINTint[21] = (TBYPASS_main===0 && delTBYPASS[21]===0)?OutReg[21] : (TBYPASS_main===1 && delTBYPASS[21]===1)?TBYPASS_D_Q[21] : WordX;
	assign QINTint[22] = (TBYPASS_main===0 && delTBYPASS[22]===0)?OutReg[22] : (TBYPASS_main===1 && delTBYPASS[22]===1)?TBYPASS_D_Q[22] : WordX;
	assign QINTint[23] = (TBYPASS_main===0 && delTBYPASS[23]===0)?OutReg[23] : (TBYPASS_main===1 && delTBYPASS[23]===1)?TBYPASS_D_Q[23] : WordX;
	assign QINTint[24] = (TBYPASS_main===0 && delTBYPASS[24]===0)?OutReg[24] : (TBYPASS_main===1 && delTBYPASS[24]===1)?TBYPASS_D_Q[24] : WordX;
	assign QINTint[25] = (TBYPASS_main===0 && delTBYPASS[25]===0)?OutReg[25] : (TBYPASS_main===1 && delTBYPASS[25]===1)?TBYPASS_D_Q[25] : WordX;
	assign QINTint[26] = (TBYPASS_main===0 && delTBYPASS[26]===0)?OutReg[26] : (TBYPASS_main===1 && delTBYPASS[26]===1)?TBYPASS_D_Q[26] : WordX;
	assign QINTint[27] = (TBYPASS_main===0 && delTBYPASS[27]===0)?OutReg[27] : (TBYPASS_main===1 && delTBYPASS[27]===1)?TBYPASS_D_Q[27] : WordX;
	assign QINTint[28] = (TBYPASS_main===0 && delTBYPASS[28]===0)?OutReg[28] : (TBYPASS_main===1 && delTBYPASS[28]===1)?TBYPASS_D_Q[28] : WordX;
	assign QINTint[29] = (TBYPASS_main===0 && delTBYPASS[29]===0)?OutReg[29] : (TBYPASS_main===1 && delTBYPASS[29]===1)?TBYPASS_D_Q[29] : WordX;
	assign QINTint[30] = (TBYPASS_main===0 && delTBYPASS[30]===0)?OutReg[30] : (TBYPASS_main===1 && delTBYPASS[30]===1)?TBYPASS_D_Q[30] : WordX;
	assign QINTint[31] = (TBYPASS_main===0 && delTBYPASS[31]===0)?OutReg[31] : (TBYPASS_main===1 && delTBYPASS[31]===1)?TBYPASS_D_Q[31] : WordX;

assign QINTERNAL = QINTERNALreg;

always @(TBYPASS_main)
begin
           
   if (TBYPASS_main === 0 || TBYPASS_main === X) 
      QINTERNALreg = WordX;
   
end


        
/*------------------ RY functionality -----------------*/
        output RYINT;
        input RY_rfCK, RY_rrCK, RY_frCK, ICRY;
        wire RYINTint;
        reg RYINTreg, RYRiseFlag;

        buf (RYINT, RYINTint);

assign RYINTint = RYINTreg;
        
initial
begin
  RYRiseFlag = 1'b0;
  RYINTreg = 1'b1;
end

always @(ICRY)
begin
   if($realtime == 0)
      RYINTreg = 1'b1;
   else
      RYINTreg = 1'bx;
end

always @(RY_rfCK)
if (ICRY !== 1)
begin
   RYINTreg = 0;
   RYRiseFlag=0;
end

always @(RY_rrCK)
if (ICRY !== 1 && $realtime != 0)
begin
   if (RYRiseFlag === 0)
   begin
      RYRiseFlag=1;
   end
   else
   begin
      RYINTreg = 1'b1;
      RYRiseFlag=0;
   end
end
always @(RY_frCK)
#0
if (ICRY !== 1 && $realtime != 0)
begin
   if (RYRiseFlag === 0)
   begin
      RYRiseFlag=1;
   end
   else
   begin
      RYINTreg = 1'b1;
      RYRiseFlag=0;
   end
end
/*------------------------------------------------ */

always @(Q_gCK)
begin
#0  //This has been used for removing races during hold time violations in MODELSIM simulator.
   lastQ_gCK = Q_gCKreg;
   Q_gCKreg <= Q_gCK;
   for (m = 0; m < Bits; m = m + 1)
   begin
     if (lastQ_gCK[m] !== Q_gCK[m])
     begin
       	lastQINTERNAL[m] = QINTERNALreg[m];
       	QINTERNALreg[m] = Q_glitch[m];
     end
   end
end

always @(Q_data)
begin
#0  //This has been used for removing races during hold time vilations in MODELSIM simulator.
   lastQ_data = Q_datareg;
   Q_datareg <= Q_data;
   for (n = 0; n < Bits; n = n + 1)
   begin
      if (lastQ_data[n] !== Q_data[n])
      begin
       	lastQINTERNAL[n] = QINTERNALreg[n];
       	QINTERNALreg[n] = Q_data[n];
      end
   end
end

always @(QINTERNAL)
begin
   for (d = 0; d < Bits; d = d + 1)
   begin
      if (OutReg[d] !== QINTERNAL[d])
          OutReg[d] = QINTERNAL[d];
   end
end



endmodule


module ST_SPHDL_640x32m16_L (Q, RY, CK, CSN, TBYPASS, WEN,  A,  D   );
   

    parameter 
        Fault_file_name = "ST_SPHDL_640x32m16_L_faults.txt",   
        ConfigFault = 0,
        max_faults = 20,
        MEM_INITIALIZE = 1'b0,
        BinaryInit     = 1'b0,
        InitFileName   = "ST_SPHDL_640x32m16_L.cde",     
        Corruption_Read_Violation = 1,
        Debug_mode = "ALL_WARNING_MODE",
        InstancePath = "ST_SPHDL_640x32m16_L";

    parameter
        Words = 640,
        Bits = 32,
        Addr = 10,
        mux = 16,
        Rows = Words/mux;
        






    parameter
        WordX = 32'bx,
        AddrX = 10'bx,
        X = 1'bx;


    output [Bits-1 : 0] Q;
    
    output RY;   
    input CK;
    input CSN;
    input WEN;
    input TBYPASS;
    input [Addr-1 : 0] A;
    input [Bits-1 : 0] D;
    
    





   
   wire [Bits-1 : 0] Q_glitchint;
   wire [Bits-1 : 0] Q_dataint;
   wire [Bits-1 : 0] Dint,Mint;
   wire [Addr-1 : 0] Aint;
   wire [Bits-1 : 0] Q_gCKint;
   wire CKint;
   wire CSNint;
   wire WENint;
   wire TBYPASSint;
   wire TBYPASS_mainint;
   wire [Bits-1 : 0]  TBYPASS_D_Qint;
   wire [Bits-1 : 0]  delTBYPASSint;






   
   wire [Bits-1 : 0] Qint, Q_out;
   wire CS_taa = !CSNint;
   wire csn_tcycle = !CSNint;
   wire csn_tcycle_DEBUG, csn_tcycle_DEBUGN;
   reg [Bits-1 : 0] Dreg,Mreg;
   reg [Addr-1 : 0] Areg;
   reg CKreg;
   reg CSNreg;
   reg WENreg;
	
   reg [Bits-1 : 0] TimingViol2, TimingViol3, TimingViol12, TimingViol13;
   reg [Bits-1 : 0] TimingViol2_last, TimingViol3_last, TimingViol12_last, TimingViol13_last;
	reg TimingViol2_0, TimingViol3_0, TimingViol12_0, TimingViol13_0;
	reg TimingViol2_1, TimingViol3_1, TimingViol12_1, TimingViol13_1;
	reg TimingViol2_2, TimingViol3_2, TimingViol12_2, TimingViol13_2;
	reg TimingViol2_3, TimingViol3_3, TimingViol12_3, TimingViol13_3;
	reg TimingViol2_4, TimingViol3_4, TimingViol12_4, TimingViol13_4;
	reg TimingViol2_5, TimingViol3_5, TimingViol12_5, TimingViol13_5;
	reg TimingViol2_6, TimingViol3_6, TimingViol12_6, TimingViol13_6;
	reg TimingViol2_7, TimingViol3_7, TimingViol12_7, TimingViol13_7;
	reg TimingViol2_8, TimingViol3_8, TimingViol12_8, TimingViol13_8;
	reg TimingViol2_9, TimingViol3_9, TimingViol12_9, TimingViol13_9;
	reg TimingViol2_10, TimingViol3_10, TimingViol12_10, TimingViol13_10;
	reg TimingViol2_11, TimingViol3_11, TimingViol12_11, TimingViol13_11;
	reg TimingViol2_12, TimingViol3_12, TimingViol12_12, TimingViol13_12;
	reg TimingViol2_13, TimingViol3_13, TimingViol12_13, TimingViol13_13;
	reg TimingViol2_14, TimingViol3_14, TimingViol12_14, TimingViol13_14;
	reg TimingViol2_15, TimingViol3_15, TimingViol12_15, TimingViol13_15;
	reg TimingViol2_16, TimingViol3_16, TimingViol12_16, TimingViol13_16;
	reg TimingViol2_17, TimingViol3_17, TimingViol12_17, TimingViol13_17;
	reg TimingViol2_18, TimingViol3_18, TimingViol12_18, TimingViol13_18;
	reg TimingViol2_19, TimingViol3_19, TimingViol12_19, TimingViol13_19;
	reg TimingViol2_20, TimingViol3_20, TimingViol12_20, TimingViol13_20;
	reg TimingViol2_21, TimingViol3_21, TimingViol12_21, TimingViol13_21;
	reg TimingViol2_22, TimingViol3_22, TimingViol12_22, TimingViol13_22;
	reg TimingViol2_23, TimingViol3_23, TimingViol12_23, TimingViol13_23;
	reg TimingViol2_24, TimingViol3_24, TimingViol12_24, TimingViol13_24;
	reg TimingViol2_25, TimingViol3_25, TimingViol12_25, TimingViol13_25;
	reg TimingViol2_26, TimingViol3_26, TimingViol12_26, TimingViol13_26;
	reg TimingViol2_27, TimingViol3_27, TimingViol12_27, TimingViol13_27;
	reg TimingViol2_28, TimingViol3_28, TimingViol12_28, TimingViol13_28;
	reg TimingViol2_29, TimingViol3_29, TimingViol12_29, TimingViol13_29;
	reg TimingViol2_30, TimingViol3_30, TimingViol12_30, TimingViol13_30;
	reg TimingViol2_31, TimingViol3_31, TimingViol12_31, TimingViol13_31;
   reg TimingViol0, TimingViol1;
   reg TimingViol4, TimingViol5, TimingViol6, TimingViol7, TimingViol_ttms_ttmh;
   reg TimingViol8, TimingViol9, TimingViol10, TimingViol10_taa;








   wire [Bits-1 : 0] MEN,CSWEMTBYPASS;
   wire CSTBYPASSN, CSWETBYPASSN;
   wire csn_tckl;
   wire csn_tckl_ry;
   wire csn_tckh;

   reg tckh_flag;
   reg tckl_flag;

   wire CS_taa_ry = !CSNint;
   
/* This register is used to force all warning messages 
** OFF during run time.
** 
*/ 
   reg [1:0] debug_level;
   reg [8*10: 0] operating_mode;
   reg [8*44: 0] message_status;





initial
begin
  debug_level = 2'b0;
  message_status = "All Messages are Switched ON";
  `ifdef  NO_WARNING_MODE
     debug_level = 2'b10;
    message_status = "All Messages are Switched OFF"; 
  `endif 
if(debug_level !== 2'b10) begin
  $display ("%m  INFORMATION");
   $display ("***************************************");
   $display ("The Model is Operating in TIMING MODE");
   $display ("Please make sure that SDF is properly annotated otherwise dummy values will be used");
   $display ("%s", message_status);
   $display ("***************************************");
   if(ConfigFault)
  $display ("Configurable Fault Functionality is ON");   
  else
  $display ("Configurable Fault Functionality is OFF"); 
  
  $display ("***************************************");
end     
end     

   buf (CKint, CK);

   //MEM_EN = CSN or  TBYPASS
   or (CSNint, CSN, TBYPASS  );

   buf (TBYPASSint, TBYPASS);
   buf (WENint, WEN);
   buf bufDint [Bits-1:0] (Dint, D);
   
   assign Mint = 32'b0;
   
   buf bufAint [Addr-1:0] (Aint, A);






   
     buf bufqint [Bits-1:0] (Q,Qint); 





	reg TimingViol9_tck_ry, TimingViol10_taa_ry;
        wire  RYint, RY_rfCKint, RY_rrCKint, RY_frCKint, RY_out;
        reg RY_outreg; 
        assign RY_out = RY_outreg;
  
     
       buf (RY, RY_out);  
       
        always @(RYint)
        begin
        RY_outreg = RYint;
        end

        
   // Only include timing checks during behavioural modelling



not (CS, CSN);    


    not (TBYPASSN, TBYPASS);
    not (WE, WEN);

    and (CSWE, CS, WE);
    and (CSWETBYPASSN, CSWE, TBYPASSN);
    and (CSTBYPASSN, CS, TBYPASSN);
    and (CSWEN, CS, WEN);
 
    assign csn_tckh = tckh_flag;
    assign csn_tckl = tckl_flag;
    assign csn_tckl_ry = tckl_flag;


        
 not (MEN[0], Mint[0]);
 not (MEN[1], Mint[1]);
 not (MEN[2], Mint[2]);
 not (MEN[3], Mint[3]);
 not (MEN[4], Mint[4]);
 not (MEN[5], Mint[5]);
 not (MEN[6], Mint[6]);
 not (MEN[7], Mint[7]);
 not (MEN[8], Mint[8]);
 not (MEN[9], Mint[9]);
 not (MEN[10], Mint[10]);
 not (MEN[11], Mint[11]);
 not (MEN[12], Mint[12]);
 not (MEN[13], Mint[13]);
 not (MEN[14], Mint[14]);
 not (MEN[15], Mint[15]);
 not (MEN[16], Mint[16]);
 not (MEN[17], Mint[17]);
 not (MEN[18], Mint[18]);
 not (MEN[19], Mint[19]);
 not (MEN[20], Mint[20]);
 not (MEN[21], Mint[21]);
 not (MEN[22], Mint[22]);
 not (MEN[23], Mint[23]);
 not (MEN[24], Mint[24]);
 not (MEN[25], Mint[25]);
 not (MEN[26], Mint[26]);
 not (MEN[27], Mint[27]);
 not (MEN[28], Mint[28]);
 not (MEN[29], Mint[29]);
 not (MEN[30], Mint[30]);
 not (MEN[31], Mint[31]);
 and (CSWEMTBYPASS[0], MEN[0], CSWETBYPASSN);
 and (CSWEMTBYPASS[1], MEN[1], CSWETBYPASSN);
 and (CSWEMTBYPASS[2], MEN[2], CSWETBYPASSN);
 and (CSWEMTBYPASS[3], MEN[3], CSWETBYPASSN);
 and (CSWEMTBYPASS[4], MEN[4], CSWETBYPASSN);
 and (CSWEMTBYPASS[5], MEN[5], CSWETBYPASSN);
 and (CSWEMTBYPASS[6], MEN[6], CSWETBYPASSN);
 and (CSWEMTBYPASS[7], MEN[7], CSWETBYPASSN);
 and (CSWEMTBYPASS[8], MEN[8], CSWETBYPASSN);
 and (CSWEMTBYPASS[9], MEN[9], CSWETBYPASSN);
 and (CSWEMTBYPASS[10], MEN[10], CSWETBYPASSN);
 and (CSWEMTBYPASS[11], MEN[11], CSWETBYPASSN);
 and (CSWEMTBYPASS[12], MEN[12], CSWETBYPASSN);
 and (CSWEMTBYPASS[13], MEN[13], CSWETBYPASSN);
 and (CSWEMTBYPASS[14], MEN[14], CSWETBYPASSN);
 and (CSWEMTBYPASS[15], MEN[15], CSWETBYPASSN);
 and (CSWEMTBYPASS[16], MEN[16], CSWETBYPASSN);
 and (CSWEMTBYPASS[17], MEN[17], CSWETBYPASSN);
 and (CSWEMTBYPASS[18], MEN[18], CSWETBYPASSN);
 and (CSWEMTBYPASS[19], MEN[19], CSWETBYPASSN);
 and (CSWEMTBYPASS[20], MEN[20], CSWETBYPASSN);
 and (CSWEMTBYPASS[21], MEN[21], CSWETBYPASSN);
 and (CSWEMTBYPASS[22], MEN[22], CSWETBYPASSN);
 and (CSWEMTBYPASS[23], MEN[23], CSWETBYPASSN);
 and (CSWEMTBYPASS[24], MEN[24], CSWETBYPASSN);
 and (CSWEMTBYPASS[25], MEN[25], CSWETBYPASSN);
 and (CSWEMTBYPASS[26], MEN[26], CSWETBYPASSN);
 and (CSWEMTBYPASS[27], MEN[27], CSWETBYPASSN);
 and (CSWEMTBYPASS[28], MEN[28], CSWETBYPASSN);
 and (CSWEMTBYPASS[29], MEN[29], CSWETBYPASSN);
 and (CSWEMTBYPASS[30], MEN[30], CSWETBYPASSN);
 and (CSWEMTBYPASS[31], MEN[31], CSWETBYPASSN);

   specify
      specparam



         tckl_tck_ry = 0.00,
         tcycle_taa_ry = 0.00,

 
         
	 tms = 0.0,
         tmh = 0.0,
         tcycle = 0.0,
         tcycle_taa = 0.0,
         tckh = 0.0,
         tckl = 0.0,
         ttms = 0.0,
         ttmh = 0.0,
         tps = 0.0,
         tph = 0.0,
         tws = 0.0,
         twh = 0.0,
         tas = 0.0,
         tah = 0.0,
         tds = 0.0,
         tdh = 0.0;
        /*---------------------- Timing Checks ---------------------*/

	$setup(posedge A[0], posedge CK &&& CSTBYPASSN, tas, TimingViol0);
	$setup(posedge A[1], posedge CK &&& CSTBYPASSN, tas, TimingViol0);
	$setup(posedge A[2], posedge CK &&& CSTBYPASSN, tas, TimingViol0);
	$setup(posedge A[3], posedge CK &&& CSTBYPASSN, tas, TimingViol0);
	$setup(posedge A[4], posedge CK &&& CSTBYPASSN, tas, TimingViol0);
	$setup(posedge A[5], posedge CK &&& CSTBYPASSN, tas, TimingViol0);
	$setup(posedge A[6], posedge CK &&& CSTBYPASSN, tas, TimingViol0);
	$setup(posedge A[7], posedge CK &&& CSTBYPASSN, tas, TimingViol0);
	$setup(posedge A[8], posedge CK &&& CSTBYPASSN, tas, TimingViol0);
	$setup(posedge A[9], posedge CK &&& CSTBYPASSN, tas, TimingViol0);
	$setup(negedge A[0], posedge CK &&& CSTBYPASSN, tas, TimingViol0);
	$setup(negedge A[1], posedge CK &&& CSTBYPASSN, tas, TimingViol0);
	$setup(negedge A[2], posedge CK &&& CSTBYPASSN, tas, TimingViol0);
	$setup(negedge A[3], posedge CK &&& CSTBYPASSN, tas, TimingViol0);
	$setup(negedge A[4], posedge CK &&& CSTBYPASSN, tas, TimingViol0);
	$setup(negedge A[5], posedge CK &&& CSTBYPASSN, tas, TimingViol0);
	$setup(negedge A[6], posedge CK &&& CSTBYPASSN, tas, TimingViol0);
	$setup(negedge A[7], posedge CK &&& CSTBYPASSN, tas, TimingViol0);
	$setup(negedge A[8], posedge CK &&& CSTBYPASSN, tas, TimingViol0);
	$setup(negedge A[9], posedge CK &&& CSTBYPASSN, tas, TimingViol0);
	$hold(posedge CK &&& CSTBYPASSN, posedge A[0], tah, TimingViol1);
	$hold(posedge CK &&& CSTBYPASSN, posedge A[1], tah, TimingViol1);
	$hold(posedge CK &&& CSTBYPASSN, posedge A[2], tah, TimingViol1);
	$hold(posedge CK &&& CSTBYPASSN, posedge A[3], tah, TimingViol1);
	$hold(posedge CK &&& CSTBYPASSN, posedge A[4], tah, TimingViol1);
	$hold(posedge CK &&& CSTBYPASSN, posedge A[5], tah, TimingViol1);
	$hold(posedge CK &&& CSTBYPASSN, posedge A[6], tah, TimingViol1);
	$hold(posedge CK &&& CSTBYPASSN, posedge A[7], tah, TimingViol1);
	$hold(posedge CK &&& CSTBYPASSN, posedge A[8], tah, TimingViol1);
	$hold(posedge CK &&& CSTBYPASSN, posedge A[9], tah, TimingViol1);
	$hold(posedge CK &&& CSTBYPASSN, negedge A[0], tah, TimingViol1);
	$hold(posedge CK &&& CSTBYPASSN, negedge A[1], tah, TimingViol1);
	$hold(posedge CK &&& CSTBYPASSN, negedge A[2], tah, TimingViol1);
	$hold(posedge CK &&& CSTBYPASSN, negedge A[3], tah, TimingViol1);
	$hold(posedge CK &&& CSTBYPASSN, negedge A[4], tah, TimingViol1);
	$hold(posedge CK &&& CSTBYPASSN, negedge A[5], tah, TimingViol1);
	$hold(posedge CK &&& CSTBYPASSN, negedge A[6], tah, TimingViol1);
	$hold(posedge CK &&& CSTBYPASSN, negedge A[7], tah, TimingViol1);
	$hold(posedge CK &&& CSTBYPASSN, negedge A[8], tah, TimingViol1);
	$hold(posedge CK &&& CSTBYPASSN, negedge A[9], tah, TimingViol1);
	$setup(posedge D[0], posedge CK &&& (CSWEMTBYPASS[0] != 0), tds, TimingViol2_0);
	$setup(posedge D[1], posedge CK &&& (CSWEMTBYPASS[1] != 0), tds, TimingViol2_1);
	$setup(posedge D[2], posedge CK &&& (CSWEMTBYPASS[2] != 0), tds, TimingViol2_2);
	$setup(posedge D[3], posedge CK &&& (CSWEMTBYPASS[3] != 0), tds, TimingViol2_3);
	$setup(posedge D[4], posedge CK &&& (CSWEMTBYPASS[4] != 0), tds, TimingViol2_4);
	$setup(posedge D[5], posedge CK &&& (CSWEMTBYPASS[5] != 0), tds, TimingViol2_5);
	$setup(posedge D[6], posedge CK &&& (CSWEMTBYPASS[6] != 0), tds, TimingViol2_6);
	$setup(posedge D[7], posedge CK &&& (CSWEMTBYPASS[7] != 0), tds, TimingViol2_7);
	$setup(posedge D[8], posedge CK &&& (CSWEMTBYPASS[8] != 0), tds, TimingViol2_8);
	$setup(posedge D[9], posedge CK &&& (CSWEMTBYPASS[9] != 0), tds, TimingViol2_9);
	$setup(posedge D[10], posedge CK &&& (CSWEMTBYPASS[10] != 0), tds, TimingViol2_10);
	$setup(posedge D[11], posedge CK &&& (CSWEMTBYPASS[11] != 0), tds, TimingViol2_11);
	$setup(posedge D[12], posedge CK &&& (CSWEMTBYPASS[12] != 0), tds, TimingViol2_12);
	$setup(posedge D[13], posedge CK &&& (CSWEMTBYPASS[13] != 0), tds, TimingViol2_13);
	$setup(posedge D[14], posedge CK &&& (CSWEMTBYPASS[14] != 0), tds, TimingViol2_14);
	$setup(posedge D[15], posedge CK &&& (CSWEMTBYPASS[15] != 0), tds, TimingViol2_15);
	$setup(posedge D[16], posedge CK &&& (CSWEMTBYPASS[16] != 0), tds, TimingViol2_16);
	$setup(posedge D[17], posedge CK &&& (CSWEMTBYPASS[17] != 0), tds, TimingViol2_17);
	$setup(posedge D[18], posedge CK &&& (CSWEMTBYPASS[18] != 0), tds, TimingViol2_18);
	$setup(posedge D[19], posedge CK &&& (CSWEMTBYPASS[19] != 0), tds, TimingViol2_19);
	$setup(posedge D[20], posedge CK &&& (CSWEMTBYPASS[20] != 0), tds, TimingViol2_20);
	$setup(posedge D[21], posedge CK &&& (CSWEMTBYPASS[21] != 0), tds, TimingViol2_21);
	$setup(posedge D[22], posedge CK &&& (CSWEMTBYPASS[22] != 0), tds, TimingViol2_22);
	$setup(posedge D[23], posedge CK &&& (CSWEMTBYPASS[23] != 0), tds, TimingViol2_23);
	$setup(posedge D[24], posedge CK &&& (CSWEMTBYPASS[24] != 0), tds, TimingViol2_24);
	$setup(posedge D[25], posedge CK &&& (CSWEMTBYPASS[25] != 0), tds, TimingViol2_25);
	$setup(posedge D[26], posedge CK &&& (CSWEMTBYPASS[26] != 0), tds, TimingViol2_26);
	$setup(posedge D[27], posedge CK &&& (CSWEMTBYPASS[27] != 0), tds, TimingViol2_27);
	$setup(posedge D[28], posedge CK &&& (CSWEMTBYPASS[28] != 0), tds, TimingViol2_28);
	$setup(posedge D[29], posedge CK &&& (CSWEMTBYPASS[29] != 0), tds, TimingViol2_29);
	$setup(posedge D[30], posedge CK &&& (CSWEMTBYPASS[30] != 0), tds, TimingViol2_30);
	$setup(posedge D[31], posedge CK &&& (CSWEMTBYPASS[31] != 0), tds, TimingViol2_31);
	$setup(negedge D[0], posedge CK &&& (CSWEMTBYPASS[0] != 0), tds, TimingViol2_0);
	$setup(negedge D[1], posedge CK &&& (CSWEMTBYPASS[1] != 0), tds, TimingViol2_1);
	$setup(negedge D[2], posedge CK &&& (CSWEMTBYPASS[2] != 0), tds, TimingViol2_2);
	$setup(negedge D[3], posedge CK &&& (CSWEMTBYPASS[3] != 0), tds, TimingViol2_3);
	$setup(negedge D[4], posedge CK &&& (CSWEMTBYPASS[4] != 0), tds, TimingViol2_4);
	$setup(negedge D[5], posedge CK &&& (CSWEMTBYPASS[5] != 0), tds, TimingViol2_5);
	$setup(negedge D[6], posedge CK &&& (CSWEMTBYPASS[6] != 0), tds, TimingViol2_6);
	$setup(negedge D[7], posedge CK &&& (CSWEMTBYPASS[7] != 0), tds, TimingViol2_7);
	$setup(negedge D[8], posedge CK &&& (CSWEMTBYPASS[8] != 0), tds, TimingViol2_8);
	$setup(negedge D[9], posedge CK &&& (CSWEMTBYPASS[9] != 0), tds, TimingViol2_9);
	$setup(negedge D[10], posedge CK &&& (CSWEMTBYPASS[10] != 0), tds, TimingViol2_10);
	$setup(negedge D[11], posedge CK &&& (CSWEMTBYPASS[11] != 0), tds, TimingViol2_11);
	$setup(negedge D[12], posedge CK &&& (CSWEMTBYPASS[12] != 0), tds, TimingViol2_12);
	$setup(negedge D[13], posedge CK &&& (CSWEMTBYPASS[13] != 0), tds, TimingViol2_13);
	$setup(negedge D[14], posedge CK &&& (CSWEMTBYPASS[14] != 0), tds, TimingViol2_14);
	$setup(negedge D[15], posedge CK &&& (CSWEMTBYPASS[15] != 0), tds, TimingViol2_15);
	$setup(negedge D[16], posedge CK &&& (CSWEMTBYPASS[16] != 0), tds, TimingViol2_16);
	$setup(negedge D[17], posedge CK &&& (CSWEMTBYPASS[17] != 0), tds, TimingViol2_17);
	$setup(negedge D[18], posedge CK &&& (CSWEMTBYPASS[18] != 0), tds, TimingViol2_18);
	$setup(negedge D[19], posedge CK &&& (CSWEMTBYPASS[19] != 0), tds, TimingViol2_19);
	$setup(negedge D[20], posedge CK &&& (CSWEMTBYPASS[20] != 0), tds, TimingViol2_20);
	$setup(negedge D[21], posedge CK &&& (CSWEMTBYPASS[21] != 0), tds, TimingViol2_21);
	$setup(negedge D[22], posedge CK &&& (CSWEMTBYPASS[22] != 0), tds, TimingViol2_22);
	$setup(negedge D[23], posedge CK &&& (CSWEMTBYPASS[23] != 0), tds, TimingViol2_23);
	$setup(negedge D[24], posedge CK &&& (CSWEMTBYPASS[24] != 0), tds, TimingViol2_24);
	$setup(negedge D[25], posedge CK &&& (CSWEMTBYPASS[25] != 0), tds, TimingViol2_25);
	$setup(negedge D[26], posedge CK &&& (CSWEMTBYPASS[26] != 0), tds, TimingViol2_26);
	$setup(negedge D[27], posedge CK &&& (CSWEMTBYPASS[27] != 0), tds, TimingViol2_27);
	$setup(negedge D[28], posedge CK &&& (CSWEMTBYPASS[28] != 0), tds, TimingViol2_28);
	$setup(negedge D[29], posedge CK &&& (CSWEMTBYPASS[29] != 0), tds, TimingViol2_29);
	$setup(negedge D[30], posedge CK &&& (CSWEMTBYPASS[30] != 0), tds, TimingViol2_30);
	$setup(negedge D[31], posedge CK &&& (CSWEMTBYPASS[31] != 0), tds, TimingViol2_31);
	$hold(posedge CK &&& (CSWEMTBYPASS[0] != 0), posedge D[0], tdh, TimingViol3_0);
	$hold(posedge CK &&& (CSWEMTBYPASS[1] != 0), posedge D[1], tdh, TimingViol3_1);
	$hold(posedge CK &&& (CSWEMTBYPASS[2] != 0), posedge D[2], tdh, TimingViol3_2);
	$hold(posedge CK &&& (CSWEMTBYPASS[3] != 0), posedge D[3], tdh, TimingViol3_3);
	$hold(posedge CK &&& (CSWEMTBYPASS[4] != 0), posedge D[4], tdh, TimingViol3_4);
	$hold(posedge CK &&& (CSWEMTBYPASS[5] != 0), posedge D[5], tdh, TimingViol3_5);
	$hold(posedge CK &&& (CSWEMTBYPASS[6] != 0), posedge D[6], tdh, TimingViol3_6);
	$hold(posedge CK &&& (CSWEMTBYPASS[7] != 0), posedge D[7], tdh, TimingViol3_7);
	$hold(posedge CK &&& (CSWEMTBYPASS[8] != 0), posedge D[8], tdh, TimingViol3_8);
	$hold(posedge CK &&& (CSWEMTBYPASS[9] != 0), posedge D[9], tdh, TimingViol3_9);
	$hold(posedge CK &&& (CSWEMTBYPASS[10] != 0), posedge D[10], tdh, TimingViol3_10);
	$hold(posedge CK &&& (CSWEMTBYPASS[11] != 0), posedge D[11], tdh, TimingViol3_11);
	$hold(posedge CK &&& (CSWEMTBYPASS[12] != 0), posedge D[12], tdh, TimingViol3_12);
	$hold(posedge CK &&& (CSWEMTBYPASS[13] != 0), posedge D[13], tdh, TimingViol3_13);
	$hold(posedge CK &&& (CSWEMTBYPASS[14] != 0), posedge D[14], tdh, TimingViol3_14);
	$hold(posedge CK &&& (CSWEMTBYPASS[15] != 0), posedge D[15], tdh, TimingViol3_15);
	$hold(posedge CK &&& (CSWEMTBYPASS[16] != 0), posedge D[16], tdh, TimingViol3_16);
	$hold(posedge CK &&& (CSWEMTBYPASS[17] != 0), posedge D[17], tdh, TimingViol3_17);
	$hold(posedge CK &&& (CSWEMTBYPASS[18] != 0), posedge D[18], tdh, TimingViol3_18);
	$hold(posedge CK &&& (CSWEMTBYPASS[19] != 0), posedge D[19], tdh, TimingViol3_19);
	$hold(posedge CK &&& (CSWEMTBYPASS[20] != 0), posedge D[20], tdh, TimingViol3_20);
	$hold(posedge CK &&& (CSWEMTBYPASS[21] != 0), posedge D[21], tdh, TimingViol3_21);
	$hold(posedge CK &&& (CSWEMTBYPASS[22] != 0), posedge D[22], tdh, TimingViol3_22);
	$hold(posedge CK &&& (CSWEMTBYPASS[23] != 0), posedge D[23], tdh, TimingViol3_23);
	$hold(posedge CK &&& (CSWEMTBYPASS[24] != 0), posedge D[24], tdh, TimingViol3_24);
	$hold(posedge CK &&& (CSWEMTBYPASS[25] != 0), posedge D[25], tdh, TimingViol3_25);
	$hold(posedge CK &&& (CSWEMTBYPASS[26] != 0), posedge D[26], tdh, TimingViol3_26);
	$hold(posedge CK &&& (CSWEMTBYPASS[27] != 0), posedge D[27], tdh, TimingViol3_27);
	$hold(posedge CK &&& (CSWEMTBYPASS[28] != 0), posedge D[28], tdh, TimingViol3_28);
	$hold(posedge CK &&& (CSWEMTBYPASS[29] != 0), posedge D[29], tdh, TimingViol3_29);
	$hold(posedge CK &&& (CSWEMTBYPASS[30] != 0), posedge D[30], tdh, TimingViol3_30);
	$hold(posedge CK &&& (CSWEMTBYPASS[31] != 0), posedge D[31], tdh, TimingViol3_31);
	$hold(posedge CK &&& (CSWEMTBYPASS[0] != 0), negedge D[0], tdh, TimingViol3_0);
	$hold(posedge CK &&& (CSWEMTBYPASS[1] != 0), negedge D[1], tdh, TimingViol3_1);
	$hold(posedge CK &&& (CSWEMTBYPASS[2] != 0), negedge D[2], tdh, TimingViol3_2);
	$hold(posedge CK &&& (CSWEMTBYPASS[3] != 0), negedge D[3], tdh, TimingViol3_3);
	$hold(posedge CK &&& (CSWEMTBYPASS[4] != 0), negedge D[4], tdh, TimingViol3_4);
	$hold(posedge CK &&& (CSWEMTBYPASS[5] != 0), negedge D[5], tdh, TimingViol3_5);
	$hold(posedge CK &&& (CSWEMTBYPASS[6] != 0), negedge D[6], tdh, TimingViol3_6);
	$hold(posedge CK &&& (CSWEMTBYPASS[7] != 0), negedge D[7], tdh, TimingViol3_7);
	$hold(posedge CK &&& (CSWEMTBYPASS[8] != 0), negedge D[8], tdh, TimingViol3_8);
	$hold(posedge CK &&& (CSWEMTBYPASS[9] != 0), negedge D[9], tdh, TimingViol3_9);
	$hold(posedge CK &&& (CSWEMTBYPASS[10] != 0), negedge D[10], tdh, TimingViol3_10);
	$hold(posedge CK &&& (CSWEMTBYPASS[11] != 0), negedge D[11], tdh, TimingViol3_11);
	$hold(posedge CK &&& (CSWEMTBYPASS[12] != 0), negedge D[12], tdh, TimingViol3_12);
	$hold(posedge CK &&& (CSWEMTBYPASS[13] != 0), negedge D[13], tdh, TimingViol3_13);
	$hold(posedge CK &&& (CSWEMTBYPASS[14] != 0), negedge D[14], tdh, TimingViol3_14);
	$hold(posedge CK &&& (CSWEMTBYPASS[15] != 0), negedge D[15], tdh, TimingViol3_15);
	$hold(posedge CK &&& (CSWEMTBYPASS[16] != 0), negedge D[16], tdh, TimingViol3_16);
	$hold(posedge CK &&& (CSWEMTBYPASS[17] != 0), negedge D[17], tdh, TimingViol3_17);
	$hold(posedge CK &&& (CSWEMTBYPASS[18] != 0), negedge D[18], tdh, TimingViol3_18);
	$hold(posedge CK &&& (CSWEMTBYPASS[19] != 0), negedge D[19], tdh, TimingViol3_19);
	$hold(posedge CK &&& (CSWEMTBYPASS[20] != 0), negedge D[20], tdh, TimingViol3_20);
	$hold(posedge CK &&& (CSWEMTBYPASS[21] != 0), negedge D[21], tdh, TimingViol3_21);
	$hold(posedge CK &&& (CSWEMTBYPASS[22] != 0), negedge D[22], tdh, TimingViol3_22);
	$hold(posedge CK &&& (CSWEMTBYPASS[23] != 0), negedge D[23], tdh, TimingViol3_23);
	$hold(posedge CK &&& (CSWEMTBYPASS[24] != 0), negedge D[24], tdh, TimingViol3_24);
	$hold(posedge CK &&& (CSWEMTBYPASS[25] != 0), negedge D[25], tdh, TimingViol3_25);
	$hold(posedge CK &&& (CSWEMTBYPASS[26] != 0), negedge D[26], tdh, TimingViol3_26);
	$hold(posedge CK &&& (CSWEMTBYPASS[27] != 0), negedge D[27], tdh, TimingViol3_27);
	$hold(posedge CK &&& (CSWEMTBYPASS[28] != 0), negedge D[28], tdh, TimingViol3_28);
	$hold(posedge CK &&& (CSWEMTBYPASS[29] != 0), negedge D[29], tdh, TimingViol3_29);
	$hold(posedge CK &&& (CSWEMTBYPASS[30] != 0), negedge D[30], tdh, TimingViol3_30);
	$hold(posedge CK &&& (CSWEMTBYPASS[31] != 0), negedge D[31], tdh, TimingViol3_31);

        
        $setup(posedge CSN, edge[01,0x,x1,1x] CK &&& TBYPASSint != 1'b1, tps, TimingViol4);
	$setup(negedge CSN, edge[01,0x,x1,1x] CK &&& TBYPASSint != 1'b1, tps, TimingViol4);
	$hold(edge[01,0x,x1,x0] CK &&& TBYPASSint != 1'b1, posedge CSN, tph, TimingViol5);
	$hold(edge[01,0x,x1,x0] CK &&& TBYPASSint != 1'b1, negedge CSN, tph, TimingViol5);
        $setup(posedge WEN, edge[01,0x,x1,1x] CK &&& (CSTBYPASSN != 'b0), tws, TimingViol6);
        $setup(negedge WEN, edge[01,0x,x1,1x] CK &&& (CSTBYPASSN != 'b0), tws, TimingViol6);
        $hold(edge[01,0x,x1,x0] CK &&& (CSTBYPASSN != 'b0), posedge WEN, twh, TimingViol7);
        $hold(edge[01,0x,x1,x0] CK &&& (CSTBYPASSN != 'b0), negedge WEN, twh, TimingViol7);
        

        $period(posedge CK &&& (csn_tcycle != 0), tcycle, TimingViol10); 
        $period(posedge CK &&& (CS_taa != 0), tcycle_taa, TimingViol10_taa);
        $width(posedge CK &&& (csn_tckh != 'b0), tckh, 0, TimingViol8);
        $width(negedge CK &&& (csn_tckl != 'b0), tckl, 0, TimingViol9);
        
        // TBYPASS setup/hold violations
        $setup(posedge TBYPASS, posedge CK &&& (CS != 0),ttms, TimingViol_ttms_ttmh);
        $setup(negedge TBYPASS, posedge CK &&& (CS != 0),ttms, TimingViol_ttms_ttmh);

        $hold(posedge CK &&& (CS != 1'b0), posedge TBYPASS, ttmh, TimingViol_ttms_ttmh);
        $hold(posedge CK &&& (CS != 1'b0), negedge TBYPASS, ttmh, TimingViol_ttms_ttmh); 



        $period(posedge CK &&& (CS_taa_ry != 0), tcycle_taa_ry, TimingViol10_taa_ry);
        $width(negedge CK &&& (csn_tckl_ry!= 0), tckl_tck_ry, 0, TimingViol9_tck_ry);


        
	endspecify

always @(CKint)
begin
   CKreg <= CKint;
end

always @(posedge CKint)
begin
   if (CSNint !== 1)
   begin
      Dreg = Dint;
      Mreg = Mint;
      WENreg = WENint;
      Areg = Aint;
   end
   CSNreg = CSNint;
   if (CSNint === 1'b1)
      tckh_flag = 0;
   else
      tckh_flag = 1;
        
tckl_flag = 1;
end
     
always @(negedge CKint)
begin
   #0.00   tckh_flag = 1;
   if (CSNint === 1)
      tckl_flag = 0;
   else
      tckl_flag = 1;
end
     
always @(CSNint)
begin
   if (CKint !== 1)
      tckl_flag = ~CSNint;
end

always @(TimingViol10_taa)
begin
   if(debug_level < 2)
   $display("%m - %t WARNING: READ/WRITE ACCESS TIME IS GREATER THAN THE CLOCK PERIOD",$realtime);
end

// conversion from registers to array elements for mask setup violation notifiers


// conversion from registers to array elements for mask hold violation notifiers


// conversion from registers to array elements for data setup violation notifiers

always @(TimingViol2_31)
begin
   TimingViol2[31] = TimingViol2_31;
end


always @(TimingViol2_30)
begin
   TimingViol2[30] = TimingViol2_30;
end


always @(TimingViol2_29)
begin
   TimingViol2[29] = TimingViol2_29;
end


always @(TimingViol2_28)
begin
   TimingViol2[28] = TimingViol2_28;
end


always @(TimingViol2_27)
begin
   TimingViol2[27] = TimingViol2_27;
end


always @(TimingViol2_26)
begin
   TimingViol2[26] = TimingViol2_26;
end


always @(TimingViol2_25)
begin
   TimingViol2[25] = TimingViol2_25;
end


always @(TimingViol2_24)
begin
   TimingViol2[24] = TimingViol2_24;
end


always @(TimingViol2_23)
begin
   TimingViol2[23] = TimingViol2_23;
end


always @(TimingViol2_22)
begin
   TimingViol2[22] = TimingViol2_22;
end


always @(TimingViol2_21)
begin
   TimingViol2[21] = TimingViol2_21;
end


always @(TimingViol2_20)
begin
   TimingViol2[20] = TimingViol2_20;
end


always @(TimingViol2_19)
begin
   TimingViol2[19] = TimingViol2_19;
end


always @(TimingViol2_18)
begin
   TimingViol2[18] = TimingViol2_18;
end


always @(TimingViol2_17)
begin
   TimingViol2[17] = TimingViol2_17;
end


always @(TimingViol2_16)
begin
   TimingViol2[16] = TimingViol2_16;
end


always @(TimingViol2_15)
begin
   TimingViol2[15] = TimingViol2_15;
end


always @(TimingViol2_14)
begin
   TimingViol2[14] = TimingViol2_14;
end


always @(TimingViol2_13)
begin
   TimingViol2[13] = TimingViol2_13;
end


always @(TimingViol2_12)
begin
   TimingViol2[12] = TimingViol2_12;
end


always @(TimingViol2_11)
begin
   TimingViol2[11] = TimingViol2_11;
end


always @(TimingViol2_10)
begin
   TimingViol2[10] = TimingViol2_10;
end


always @(TimingViol2_9)
begin
   TimingViol2[9] = TimingViol2_9;
end


always @(TimingViol2_8)
begin
   TimingViol2[8] = TimingViol2_8;
end


always @(TimingViol2_7)
begin
   TimingViol2[7] = TimingViol2_7;
end


always @(TimingViol2_6)
begin
   TimingViol2[6] = TimingViol2_6;
end


always @(TimingViol2_5)
begin
   TimingViol2[5] = TimingViol2_5;
end


always @(TimingViol2_4)
begin
   TimingViol2[4] = TimingViol2_4;
end


always @(TimingViol2_3)
begin
   TimingViol2[3] = TimingViol2_3;
end


always @(TimingViol2_2)
begin
   TimingViol2[2] = TimingViol2_2;
end


always @(TimingViol2_1)
begin
   TimingViol2[1] = TimingViol2_1;
end


always @(TimingViol2_0)
begin
   TimingViol2[0] = TimingViol2_0;
end


// conversion from registers to array elements for data hold violation notifiers

always @(TimingViol3_31)
begin
   TimingViol3[31] = TimingViol3_31;
end


always @(TimingViol3_30)
begin
   TimingViol3[30] = TimingViol3_30;
end


always @(TimingViol3_29)
begin
   TimingViol3[29] = TimingViol3_29;
end


always @(TimingViol3_28)
begin
   TimingViol3[28] = TimingViol3_28;
end


always @(TimingViol3_27)
begin
   TimingViol3[27] = TimingViol3_27;
end


always @(TimingViol3_26)
begin
   TimingViol3[26] = TimingViol3_26;
end


always @(TimingViol3_25)
begin
   TimingViol3[25] = TimingViol3_25;
end


always @(TimingViol3_24)
begin
   TimingViol3[24] = TimingViol3_24;
end


always @(TimingViol3_23)
begin
   TimingViol3[23] = TimingViol3_23;
end


always @(TimingViol3_22)
begin
   TimingViol3[22] = TimingViol3_22;
end


always @(TimingViol3_21)
begin
   TimingViol3[21] = TimingViol3_21;
end


always @(TimingViol3_20)
begin
   TimingViol3[20] = TimingViol3_20;
end


always @(TimingViol3_19)
begin
   TimingViol3[19] = TimingViol3_19;
end


always @(TimingViol3_18)
begin
   TimingViol3[18] = TimingViol3_18;
end


always @(TimingViol3_17)
begin
   TimingViol3[17] = TimingViol3_17;
end


always @(TimingViol3_16)
begin
   TimingViol3[16] = TimingViol3_16;
end


always @(TimingViol3_15)
begin
   TimingViol3[15] = TimingViol3_15;
end


always @(TimingViol3_14)
begin
   TimingViol3[14] = TimingViol3_14;
end


always @(TimingViol3_13)
begin
   TimingViol3[13] = TimingViol3_13;
end


always @(TimingViol3_12)
begin
   TimingViol3[12] = TimingViol3_12;
end


always @(TimingViol3_11)
begin
   TimingViol3[11] = TimingViol3_11;
end


always @(TimingViol3_10)
begin
   TimingViol3[10] = TimingViol3_10;
end


always @(TimingViol3_9)
begin
   TimingViol3[9] = TimingViol3_9;
end


always @(TimingViol3_8)
begin
   TimingViol3[8] = TimingViol3_8;
end


always @(TimingViol3_7)
begin
   TimingViol3[7] = TimingViol3_7;
end


always @(TimingViol3_6)
begin
   TimingViol3[6] = TimingViol3_6;
end


always @(TimingViol3_5)
begin
   TimingViol3[5] = TimingViol3_5;
end


always @(TimingViol3_4)
begin
   TimingViol3[4] = TimingViol3_4;
end


always @(TimingViol3_3)
begin
   TimingViol3[3] = TimingViol3_3;
end


always @(TimingViol3_2)
begin
   TimingViol3[2] = TimingViol3_2;
end


always @(TimingViol3_1)
begin
   TimingViol3[1] = TimingViol3_1;
end


always @(TimingViol3_0)
begin
   TimingViol3[0] = TimingViol3_0;
end




ST_SPHDL_640x32m16_L_main ST_SPHDL_640x32m16_L_maininst ( Q_glitchint,  Q_dataint, Q_gCKint, RY_rfCKint, RY_rrCKint, RY_frCKint, ICRYint, delTBYPASSint, TBYPASS_D_Qint, TBYPASS_mainint, CKint,  CSNint , TBYPASSint, WENint,  Aint, Dint, Mint, debug_level  , TimingViol0, TimingViol1, TimingViol2, TimingViol3, TimingViol4, TimingViol5, TimingViol6, TimingViol7, TimingViol8, TimingViol9, TimingViol10, TimingViol_ttms_ttmh, TimingViol12, TimingViol13      );

ST_SPHDL_640x32m16_L_OPschlr ST_SPHDL_640x32m16_L_OPschlrinst (Qint, RYint,  Q_gCKint, Q_glitchint,  Q_dataint, RY_rfCKint, RY_rrCKint, RY_frCKint, ICRYint, delTBYPASSint, TBYPASS_D_Qint, TBYPASS_mainint  );

defparam ST_SPHDL_640x32m16_L_maininst.Fault_file_name = Fault_file_name;
defparam ST_SPHDL_640x32m16_L_maininst.ConfigFault = ConfigFault;
defparam ST_SPHDL_640x32m16_L_maininst.max_faults = max_faults;
defparam ST_SPHDL_640x32m16_L_maininst.MEM_INITIALIZE = MEM_INITIALIZE;
defparam ST_SPHDL_640x32m16_L_maininst.BinaryInit = BinaryInit;
defparam ST_SPHDL_640x32m16_L_maininst.InitFileName = InitFileName;

endmodule

`endif

`delay_mode_path
`disable_portfaults
`nosuppress_faults
`endcelldefine










/****************************************************************
--  Description         : verilog_model for ST_SPHDL cmos65
--  ModelVersion        : 4.4
--  Date                : Jun, 2008
--  Changes Made by	: DRM
--
****************************************************************/

/******************** START OF HEADER****************************
   This Header Gives Information about the parameters & options present in the Model

   words = 160
   bits  = 64
   mux   = 8 
   
   bit_write = yes 
   
   
   
   
   

**********************END OF HEADER ******************************/



`ifdef slm
        `define functional
`endif
`celldefine
`suppress_faults
`enable_portfaults
`ifdef functional
   `timescale 1ns / 1ns
   `delay_mode_unit
`endif

`ifdef functional



module ST_SPHDL_160x64m8_bL (Q, RY,CK, CSN, TBYPASS, WEN, A, D , M   );   
 
    parameter
        Fault_file_name = "ST_SPHDL_160x64m8_bL_faults.txt",
        ConfigFault = 0,
        max_faults = 20,
        MEM_INITIALIZE  = 1'b0,
        BinaryInit = 1'b0,
        InitFileName = "ST_SPHDL_160x64m8_bL.cde",
        Corruption_Read_Violation = 1,
        Debug_mode = "all_warning_mode",
        InstancePath = "ST_SPHDL_160x64m8_bL";
    
    parameter
        Words = 160,
        Bits = 64,
        Addr = 8,
        mux = 8,
        Rows = Words/mux;




   


    parameter
        WordX = 64'bx,
        AddrX = 8'bx,
        Word0 = 64'b0,
        X = 1'bx;


	output [Bits-1 : 0] Q;
        
        output RY;   
        
        input [Bits-1 : 0] D;
	input [Addr-1 : 0] A;
	
        input [Bits-1:0] M;         
        input CK, CSN, TBYPASS, WEN;

        
        
        

        



        reg [Bits-1 : 0] Qint;
         
           
	wire [Bits-1 : 0] Dint,Mint;
        
        wire [Addr-1 : 0] Aint;
	wire CKint;
	wire CSNint;
	wire WENint;

        
        	
        wire TBYPASSint;
        

        
        wire RYint;
          
          
           buf (RY, RYint);  
         
        reg RY_outreg, RY_out;
           
        assign RYint = RY_out;

        
        
        
        // REG DECLARATION
        
	//Output Register for tbypass
        reg [Bits-1 : 0] tbydata;
        //delayed Output Register
        reg [Bits-1 : 0] delOutReg_data;
        reg [Bits-1 : 0] OutReg_data;   // Data Output register
	reg [Bits-1 : 0] tempMem;
	reg lastCK;
        reg CSNreg;	

        `ifdef slm
        `else
	reg [Bits-1 : 0] Mem [Words-1 : 0]; // RAM array
        `endif
	
	reg [Bits-1 :0] Mem_temp;
	reg ValidAddress;
	reg ValidDebugCode;
        

        
        reg WENreg;
        
        reg [1:0] debug_level;
        reg [8*10: 0] operating_mode;
        reg [8*44: 0] message_status;

        integer d, a, p, i, k, j, l;
        `ifdef slm
           integer MemAddr;
        `endif


        //************************************************************
        //****** CONFIG FAULT IMPLEMENTATION VARIABLES*************** 
        //************************************************************ 

        integer file_ptr, ret_val;
        integer fault_word;
        integer fault_bit;
        integer fcnt, Fault_in_memory;
        integer n, cnt, t;  
        integer FailureLocn [max_faults -1 :0];

        reg [100 : 0] stuck_at;
        reg [200 : 0] tempStr;
        reg [7:0] fault_char;
        reg [7:0] fault_char1; // 8 Bit File Pointer
        reg [Addr -1 : 0] std_fault_word;
        reg [max_faults -1 :0] fault_repair_flag;
        reg [max_faults -1 :0] repair_flag;
        reg [Bits - 1: 0] stuck_at_0fault [max_faults -1 : 0];
        reg [Bits - 1: 0] stuck_at_1fault [max_faults -1 : 0];
        reg [100 : 0] array_stuck_at[max_faults -1 : 0] ; 
        reg msgcnt;
        

        reg [Bits -1 : 0] stuck0;
        reg [Bits -1 : 0] stuck1;

        `ifdef slm
        reg [Bits -1 : 0] slm_temp_data;
        `endif
        

        integer flag_error;

        
          
          buf bufq [Bits-1:0] (Q,Qint);
        
        
        buf bufdata [Bits-1:0] (Dint,D);
        buf bufaddr [Addr-1:0] (Aint,A);
        
        buf bufmask [Bits-1:0] (Mint,M);
        
	buf (TBYPASSint, TBYPASS);
	buf (CKint, CK);
	
        //MEM_EN = CSN or  TBYPASS
        
        or (CSNint, CSN, TBYPASS);   
	
        buf (WENint, WEN);
        
        
        
        

        

// BEHAVIOURAL MODULE DESCRIPTION

task WriteMemX;
begin
   `ifdef slm
   $slm_ResetMemory(MemAddr, WordX);
   `else
    for (i = 0; i < Words; i = i + 1)
       Mem[i] = WordX;
   `endif        
end
endtask


task WriteOutX;                
begin
   OutReg_data= WordX;
end
endtask

task WriteCycle;                  
input [Addr-1 : 0] Address;
reg [Bits-1:0] tempReg1,tempReg2;
integer po,i;
begin

   tempReg1 = WordX;
   if (^Address !== X) begin
      if (ValidAddress) begin
      `ifdef slm
         $slm_ReadMemoryS(MemAddr, Address, tempReg1);
      `else
         tempReg1 = Mem[Address];
      `endif
            
         for (po=0;po<Bits;po=po+1) begin
            if (Mint[po] === 1'b0)
               tempReg1[po] = Dint[po];
            else if ((Mint[po] !== 1'b1) && (tempReg1[po] !== Dint[po]))
               tempReg1[po] = 1'bx;
         end                
      `ifdef slm
         $slm_WriteMemory(MemAddr, Address, tempReg1);
      `else
         Mem[Address] = tempReg1;
      `endif
      end//if (ValidAddress)
      else
         if(debug_level < 2) $display("%m - %t (MSG_ID 701) WARNING: Address Out Of Range. ",$realtime); 
   end //if (^Address !== X)
   else
   begin
      if(debug_level < 2) $display("%m - %t (MSG_ID 008) WARNING: Illegal Value on Address Bus. Memory Corrupted ",$realtime);
      WriteMemX;
   end
 end

endtask

task ReadCycle;
input [Addr-1 : 0] Address;
reg [Bits-1:0] MemData;
integer a;
begin
   if (ValidAddress)
   begin        
      `ifdef slm
       $slm_ReadMemory(MemAddr, Address, MemData);
      `else
      MemData = Mem[Address];
      `endif
   end //if (ValidAddress)  
                
   if(ValidAddress === X)
   begin
      if (Corruption_Read_Violation === 1)
      begin   
         if(debug_level < 2) $display("%m - %t (MSG_ID 008) WARNING: Illegal Value on Address Bus. Memory and Output Corrupted ",$realtime);
         WriteMemX;
      end
      else
         if(debug_level < 2) $display("%m - %t (MSG_ID 008) WARNING: Illegal Value on Address Bus. Output Corrupted ",$realtime);
      MemData = WordX;
   end                        
   else if (ValidAddress === 0)
   begin                        
      if(debug_level < 2) $display("%m - %t (MSG_ID 701) WARNING: Address Out Of Range. Output Corrupted ",$realtime); 
      MemData = WordX;
   end
   
   OutReg_data = MemData;
end
endtask

task wen_x_handler;
input [Addr-1 : 0] Address;
input [Bits-1 : 0] Mask;
reg [Bits-1 : 0] prev_data;
begin
   if(^Address !== X) begin
      if (Address < Words) begin
      `ifdef slm
         $slm_ReadMemoryS(MemAddr, Address, tempMem);
      `else
         tempMem = Mem[Address];
      `endif
         prev_data = tempMem;  
         for (j = 0;j< Bits; j=j+1) begin
            //calculating data to write in memory
            if (tempMem[j] !== Dint[j]) begin
               if (Mask[j] !== 1'b1) begin
                  tempMem[j] = 1'bx;
               end
            end
            //calculating data to write on output
            if (prev_data[j] !== OutReg_data[j]) begin
               OutReg_data[j]  = 1'bx;
            end
         end//for (j = 0;j< Bits;
      end
      else begin
         WriteOutX;
      end   
   end  //  if(^Address !== X)
   else begin
      WriteMemX;
      WriteOutX;
   end  //else  
`ifdef slm
   $slm_WriteMemory(MemAddr, Address, tempMem);
`else
   Mem[Address] = tempMem;
`endif
end
endtask
        

task task_insert_faults_in_memory;
begin
   Fault_in_memory = 1;
   for(i = 0;i< fcnt;i = i+ 1)
   begin
      if (fault_repair_flag[i] !== 1)
      begin
         Fault_in_memory = 0;
         if (array_stuck_at[i] === "sa0")
         begin
            `ifdef slm
            //Read first
            $slm_ReadMemoryS(MemAddr, FailureLocn[i], slm_temp_data);
            //operation
            slm_temp_data = slm_temp_data & stuck_at_0fault[i];
            //write back
            $slm_WriteMemoryS(MemAddr, FailureLocn[i], slm_temp_data);
            `else
            Mem[FailureLocn[i]] = Mem[FailureLocn[i]] & stuck_at_0fault[i];
            `endif
         end //if(array_stuck_at)
                                        
         if(array_stuck_at[i] === "sa1")
         begin
            `ifdef slm
            //Read first
            $slm_ReadMemoryS(MemAddr, FailureLocn[i], slm_temp_data);
            //operation
            slm_temp_data = slm_temp_data | stuck_at_1fault[i];
            //write back
            $slm_WriteMemoryS(MemAddr, FailureLocn[i], slm_temp_data);
            `else
            Mem[FailureLocn[i]] = Mem[FailureLocn[i]] | stuck_at_1fault[i]; 
            `endif
         end //if(array_stuck_at)
      end//if (fault_repair_flag
   end// for loop...
end
endtask






initial
begin
   // Define format for timing value
  $timeformat (-9, 2, " ns", 0);
  `ifdef slm
  $slm_RegisterMemory(MemAddr, Words, Bits);
  `endif   
  
  debug_level= 2'b0;
   message_status = "All Messages are Switched ON";
  `ifdef  NO_WARNING_MODE
     debug_level = 2'b10;
     message_status = "All Warning Messages are Switched OFF";
  `endif  
  `ifdef slm
     operating_mode = "SLM";
  `else
     operating_mode = "FUNCTIONAL";
  `endif
if(debug_level !== 2'b10) begin
  $display ("%mINFORMATION ");
  $display ("***************************************");
  $display ("The Model is Operating in %s MODE", operating_mode);
  $display ("%s", message_status);
  if(ConfigFault)
  $display ("Configurable Fault Functionality is ON");   
  else
  $display ("Configurable Fault Functionality is OFF");  
   
  $display ("***************************************");
end
  if (MEM_INITIALIZE === 1'b1)
  begin   
     `ifdef slm
        if (BinaryInit)
           $slm_LoadMemory(MemAddr, InitFileName, "VERILOG_BIN");
        else
           $slm_LoadMemory(MemAddr, InitFileName, "VERILOG_HEX");

     `else
        if (BinaryInit)
           $readmemb(InitFileName, Mem, 0, Words-1);
        else
           $readmemh(InitFileName, Mem, 0, Words-1);
     `endif
  end

  
  RY_out = 1'b1;


        
/*  -----------Implemetation for config fault starts------*/
   msgcnt = X;
   t = 0;
   fault_repair_flag = {max_faults{1'b1}};
   repair_flag = {max_faults{1'b1}};
   if(ConfigFault) 
   begin
        file_ptr = $fopen(Fault_file_name , "r");
        if(file_ptr == 0)
        begin     
          if(debug_level < 3) $display("%m - %t (MSG_ID 201) FAILURE: File cannot be opened ",$realtime);      
        end        
      else                
      begin : read_fault_file
      t = 0;
      for (i = 0; i< max_faults; i= i + 1)
      begin
         
         stuck0 = {Bits{1'b1}};
         stuck1 = {Bits{1'b0}};
         fault_char1 = $fgetc (file_ptr);
         if (fault_char1 == 8'b11111111)
                 disable read_fault_file;
         ret_val = $ungetc (fault_char1, file_ptr);
         ret_val = $fgets(tempStr, file_ptr);
         ret_val = $sscanf(tempStr, "%d %d %s",fault_word, fault_bit, stuck_at) ;
        flag_error = 0; 
         if(ret_val !== 0)
            begin         
               if(ret_val == 2 || ret_val == 3)
               begin
                  if(ret_val == 2)
                      stuck_at = "sa0";

                  if(stuck_at !== "sa0" && stuck_at !== "sa1" && stuck_at !== "none")
                  begin
                      if(debug_level < 2) $display("%m - %t (MSG_ID 203) WARNING: Wrong value for stuck at in fault file ",$realtime);
                      flag_error = 1;
                  end    
                      
                  if(fault_word > Words-1)
                  begin
                      if(debug_level < 2) $display("%m - %t (MSG_ID 206) WARNING: Address out of range in fault file ",$realtime);
                      flag_error = 1;
                  end    

                  if(fault_bit > Bits)
                  begin  
                      if(debug_level < 2) $display("%m - %t (MSG_ID 205) WARNING: Faulty bit out of range in fault file ",$realtime);
                      flag_error = 1;
                  end    

                  if(flag_error == 0)
                  //Correct Inputs
                  begin
                      if(stuck_at === "none")
                      begin
                         if(debug_level < 2) $display("%m - %t (MSG_ID 202) WARNING: No fault injected, empty fault file ",$realtime);
                      end
                      else
                      //Adding the faults
                      begin
                         FailureLocn[t] = fault_word;
                         std_fault_word = fault_word;
                         
                         fault_repair_flag[t] = 1'b0;
                         if (stuck_at === "sa0" )
                         begin
                            stuck0[fault_bit] = 1'b0;         
                            stuck_at_0fault[t] = stuck0;
                         end     
                         if (stuck_at === "sa1" )
                         begin
                            stuck1[fault_bit] = 1'b1;
                            stuck_at_1fault[t] = stuck1; 
                         end

                         array_stuck_at[t] = stuck_at;
                         t = t + 1;
                      end //if(stuck_at === "none")  
                  end //if(flag_error == 0)
               end //if(ret_val == 2 || ret_val == 3 
               else
               //wrong number of arguments
               begin
                  if(debug_level < 2)
                  $display("%m - %t WARNING :  WRONG VALUES ENTERED FOR FAULTY WORD OR FAULTY BIT OR STUCK_AT IN Fault_file_name", $realtime);
                  flag_error = 1;
               end
             end //if(ret_val !== 0)
             else
             begin
                 if(debug_level < 2) $display("%m - %t (MSG_ID 202) WARNING: No fault injected, empty fault file ",$realtime);
             end    
      end //for (i = 0; i< m
      end //begin: read_fault_file  
      $fclose (file_ptr);

      fcnt = t;
      
      //fault injection at time 0.
      task_insert_faults_in_memory;
      
   end // config_fault 
end// initial



//+++++++++++++++++++++++++++++++ CONFIG FAULT IMPLEMETATION ENDS+++++++++++++++++++++++++++++++//
        
always @(CKint)
begin
   if(CKint === 1'b1 && lastCK === 1'b0)
      CSNreg = CSNint;
   
   if(CKint === 1'b1 && lastCK === 1'b0 && CSNint === 1'b0) begin
      WENreg = WENint;
      if (^Aint === X)
         ValidAddress = X;
      else if (Aint < Words)
         ValidAddress = 1;
      else    
         ValidAddress = 0;

      if (ValidAddress)
      `ifdef slm
         $slm_ReadMemoryS(MemAddr, Aint, Mem_temp);
      `else        
         Mem_temp = Mem[Aint];
      `endif       
      else
         Mem_temp = WordX; 
         
      /*---------------------- Normal Read and Write -----------------*/
      
         RY_outreg = ~CKint;
         if (WENint === 1) begin
            ReadCycle(Aint);
         end
         else if (WENint === 0) begin
            WriteCycle(Aint);
         end
         else if (WENint === X) begin
            // Uncertain write cycle
            if (^Aint === X) begin
               WriteOutX;
               WriteMemX;
            end
            else
              wen_x_handler(Aint,Mint);
         end                 
            
      
   end // if(CKint === 1'b1...)
   // Unknown Clock Behaviour or unknown control signal
   else if((CKint === 1'b1 && CSNint === 1'bx) || (CKint === 1'bx && CSNreg !== 1'b1)) begin
      WriteOutX;
      WriteMemX;
       
      RY_out = 1'bX;
      if(CKint === 1'bx && CSNreg !== 1'b1) begin
         if(debug_level < 2) $display("%m - %t (MSG_ID 003) WARNING: Illegal Value on Clock. Memory and Output Corrupted ",$realtime);
      end
      else begin
         if(debug_level < 2) $display("%m - %t (MSG_ID 010) WARNING: Invalid control signal (chip select / memory bypass) Memory and Output Corrupted ",$realtime);
      end
   end
             
   

   if(ConfigFault) begin
      task_insert_faults_in_memory;
   
   end//if(ConfigFault)

   
   lastCK = CKint;
end // always @(CKint)
        
always @(CSNint)
begin

// Unknown Clock & CSN signal
   if (CSNint !== 1 && CKint === 1'bx)
   begin
      if(debug_level < 2) $display("%m - %t (MSG_ID 010) WARNING: Invalid control signal (chip select / memory bypass) Memory and Output Corrupted ",$realtime);
      WriteMemX;
      WriteOutX;
      
      RY_out = 1'bX;
   end

end

  



//TBYPASS functionality
always @(TBYPASSint)
begin
 
   
   delOutReg_data = WordX;
   OutReg_data = WordX;
   if(TBYPASSint !== 1'b0) begin        
      if(TBYPASSint === 1'b1) 
         tbydata = Dint;
      else
         tbydata = WordX;
   end        
   else                         // TBYPASSint = 0
   begin        
      Qint = WordX;
        // tbydata holds no relevance when tbypass is inactive
   end        


end //end of always TBYPASSint

always @(Dint)
begin

   
   if(TBYPASSint === 1'b1)
      tbydata = Dint;

   
end //end of always Dint

//assign output data
always @(OutReg_data)
   #1 delOutReg_data = OutReg_data;

always @(delOutReg_data or tbydata or TBYPASSint ) begin

if(TBYPASSint === 1'bX )
      Qint = WordX;
else if (TBYPASSint === 1'b1 )
      Qint = tbydata;    
else
      
      Qint = delOutReg_data;

end


always @(TBYPASSint)
begin
   if(TBYPASSint !== 1'b0)
    RY_outreg = 1'bx;
end

always @(negedge CKint)
begin

   
   if((TBYPASSint === 1'b0) && (CSNreg === 1'b0) && RY_out !== 1'bx)
    RY_outreg = ~CKint;


end

always @(RY_outreg)
begin
  #1 RY_out = RY_outreg;
end




 
// Power down functionality for verilog_model



endmodule

`else

`timescale 1ns / 1ps
`delay_mode_path


module ST_SPHDL_160x64m8_bL_main ( Q_glitch,  Q_data, Q_gCK, RY_rfCK, RY_rrCK, RY_frCK, ICRY, delTBYPASS, TBYPASS_D_Q, TBYPASS_main, CK,  CSN, TBYPASS, WEN,  A, D, M,debug_level ,TimingViol0, TimingViol1, TimingViol2, TimingViol3, TimingViol4, TimingViol5, TimingViol6, TimingViol7, TimingViol8, TimingViol9, TimingViol10, TimingViol_ttms_ttmh, TimingViol12, TimingViol13     );
    
   parameter
        Fault_file_name = "ST_SPHDL_160x64m8_bL_faults.txt",
        ConfigFault = 0,
        max_faults = 20,
        MEM_INITIALIZE  = 1'b0,
        BinaryInit = 1'b0,
        InitFileName = "ST_SPHDL_160x64m8_bL.cde",
        Debug_mode = "ALL_WARNING_MODE",
        InstancePath = "ST_SPHDL_160x64m8_bL";

   parameter
        Words = 160,
        Bits = 64,
        Addr = 8,
        mux = 8,
        Rows = Words/mux;


       

   


    parameter
        WordX = 64'bx,
        AddrX = 8'bx,
        X = 1'bx;

	output [Bits-1 : 0] Q_glitch;
	output [Bits-1 : 0] Q_data;
	output [Bits-1 : 0] Q_gCK;
        
        output ICRY;
        output RY_rfCK;
	output RY_rrCK;
	output RY_frCK;   
	output [Bits-1 : 0] delTBYPASS; 
	output TBYPASS_main; 
        output [Bits-1 : 0] TBYPASS_D_Q;
        
        input [Bits-1 : 0] D, M;
	input [Addr-1 : 0] A;
	input CK, CSN, TBYPASS, WEN;
        input [1 : 0] debug_level;

	input [Bits-1 : 0] TimingViol2, TimingViol3, TimingViol12, TimingViol13;
	input TimingViol0, TimingViol1, TimingViol4, TimingViol5, TimingViol6, TimingViol7, TimingViol8, TimingViol9, TimingViol10, TimingViol_ttms_ttmh;

        
        
        
       
        
        
        

	wire [Bits-1 : 0] Dint,Mint;
	wire [Addr-1 : 0] Aint;
	wire CKint;
	wire CSNint;
	wire WENint;
        
        






	wire  Mreg_0;
	wire  Mreg_1;
	wire  Mreg_2;
	wire  Mreg_3;
	wire  Mreg_4;
	wire  Mreg_5;
	wire  Mreg_6;
	wire  Mreg_7;
	wire  Mreg_8;
	wire  Mreg_9;
	wire  Mreg_10;
	wire  Mreg_11;
	wire  Mreg_12;
	wire  Mreg_13;
	wire  Mreg_14;
	wire  Mreg_15;
	wire  Mreg_16;
	wire  Mreg_17;
	wire  Mreg_18;
	wire  Mreg_19;
	wire  Mreg_20;
	wire  Mreg_21;
	wire  Mreg_22;
	wire  Mreg_23;
	wire  Mreg_24;
	wire  Mreg_25;
	wire  Mreg_26;
	wire  Mreg_27;
	wire  Mreg_28;
	wire  Mreg_29;
	wire  Mreg_30;
	wire  Mreg_31;
	wire  Mreg_32;
	wire  Mreg_33;
	wire  Mreg_34;
	wire  Mreg_35;
	wire  Mreg_36;
	wire  Mreg_37;
	wire  Mreg_38;
	wire  Mreg_39;
	wire  Mreg_40;
	wire  Mreg_41;
	wire  Mreg_42;
	wire  Mreg_43;
	wire  Mreg_44;
	wire  Mreg_45;
	wire  Mreg_46;
	wire  Mreg_47;
	wire  Mreg_48;
	wire  Mreg_49;
	wire  Mreg_50;
	wire  Mreg_51;
	wire  Mreg_52;
	wire  Mreg_53;
	wire  Mreg_54;
	wire  Mreg_55;
	wire  Mreg_56;
	wire  Mreg_57;
	wire  Mreg_58;
	wire  Mreg_59;
	wire  Mreg_60;
	wire  Mreg_61;
	wire  Mreg_62;
	wire  Mreg_63;
	
	reg [Bits-1 : 0] OutReg_glitch; // Glitch Output register
        reg [Bits-1 : 0] OutReg_data;   // Data Output register
	reg [Bits-1 : 0] Dreg,Mreg;
	reg [Bits-1 : 0] Mreg_temp;
	reg [Bits-1 : 0] tempMem;
	reg [Bits-1 : 0] prevMem;
	reg [Addr-1 : 0] Areg;
	reg [Bits-1 : 0] Q_gCKreg; 
	reg [Bits-1 : 0] lastQ_gCK;
	reg [Bits-1 : 0] last_Qdata;
	reg lastCK, CKreg;
	reg CSNreg;
	reg WENreg;
        
        reg [Bits-1 : 0] TimingViol2_last,TimingViol3_last;
        reg [Bits-1 : 0] TimingViol12_last,TimingViol13_last;
	
	reg [Bits-1 : 0] Mem [Words-1 : 0]; // RAM array
	
	reg [Bits-1 :0] Mem_temp;
	reg ValidAddress;
	reg ValidDebugCode;

	reg ICGFlag;
           
        reg Operation_Flag;
	

        
        reg [Bits-1:0] Mem_Red [2*mux-1:0];
        
        integer d, a, p, i, k, j, l;

        //************************************************************
        //****** CONFIG FAULT IMPLEMENTATION VARIABLES*************** 
        //************************************************************ 

        integer file_ptr, ret_val;
        integer fault_word;
        integer fault_bit;
        integer fcnt, Fault_in_memory;
        integer n, cnt, t;  
        integer FailureLocn [max_faults -1 :0];

        reg [100 : 0] stuck_at;
        reg [200 : 0] tempStr;
        reg [7:0] fault_char;
        reg [7:0] fault_char1; // 8 Bit File Pointer
        reg [Addr -1 : 0] std_fault_word;
        reg [max_faults -1 :0] fault_repair_flag;
        reg [max_faults -1 :0] repair_flag;
        reg [Bits - 1: 0] stuck_at_0fault [max_faults -1 : 0];
        reg [Bits - 1: 0] stuck_at_1fault [max_faults -1 : 0];
        reg [100 : 0] array_stuck_at[max_faults -1 : 0] ; 
        reg msgcnt;
        

        reg [Bits -1 : 0] stuck0;
        reg [Bits -1 : 0] stuck1;
        integer flag_error;

	assign Mreg_0 = Mreg[0];
	assign Mreg_1 = Mreg[1];
	assign Mreg_2 = Mreg[2];
	assign Mreg_3 = Mreg[3];
	assign Mreg_4 = Mreg[4];
	assign Mreg_5 = Mreg[5];
	assign Mreg_6 = Mreg[6];
	assign Mreg_7 = Mreg[7];
	assign Mreg_8 = Mreg[8];
	assign Mreg_9 = Mreg[9];
	assign Mreg_10 = Mreg[10];
	assign Mreg_11 = Mreg[11];
	assign Mreg_12 = Mreg[12];
	assign Mreg_13 = Mreg[13];
	assign Mreg_14 = Mreg[14];
	assign Mreg_15 = Mreg[15];
	assign Mreg_16 = Mreg[16];
	assign Mreg_17 = Mreg[17];
	assign Mreg_18 = Mreg[18];
	assign Mreg_19 = Mreg[19];
	assign Mreg_20 = Mreg[20];
	assign Mreg_21 = Mreg[21];
	assign Mreg_22 = Mreg[22];
	assign Mreg_23 = Mreg[23];
	assign Mreg_24 = Mreg[24];
	assign Mreg_25 = Mreg[25];
	assign Mreg_26 = Mreg[26];
	assign Mreg_27 = Mreg[27];
	assign Mreg_28 = Mreg[28];
	assign Mreg_29 = Mreg[29];
	assign Mreg_30 = Mreg[30];
	assign Mreg_31 = Mreg[31];
	assign Mreg_32 = Mreg[32];
	assign Mreg_33 = Mreg[33];
	assign Mreg_34 = Mreg[34];
	assign Mreg_35 = Mreg[35];
	assign Mreg_36 = Mreg[36];
	assign Mreg_37 = Mreg[37];
	assign Mreg_38 = Mreg[38];
	assign Mreg_39 = Mreg[39];
	assign Mreg_40 = Mreg[40];
	assign Mreg_41 = Mreg[41];
	assign Mreg_42 = Mreg[42];
	assign Mreg_43 = Mreg[43];
	assign Mreg_44 = Mreg[44];
	assign Mreg_45 = Mreg[45];
	assign Mreg_46 = Mreg[46];
	assign Mreg_47 = Mreg[47];
	assign Mreg_48 = Mreg[48];
	assign Mreg_49 = Mreg[49];
	assign Mreg_50 = Mreg[50];
	assign Mreg_51 = Mreg[51];
	assign Mreg_52 = Mreg[52];
	assign Mreg_53 = Mreg[53];
	assign Mreg_54 = Mreg[54];
	assign Mreg_55 = Mreg[55];
	assign Mreg_56 = Mreg[56];
	assign Mreg_57 = Mreg[57];
	assign Mreg_58 = Mreg[58];
	assign Mreg_59 = Mreg[59];
	assign Mreg_60 = Mreg[60];
	assign Mreg_61 = Mreg[61];
	assign Mreg_62 = Mreg[62];
	assign Mreg_63 = Mreg[63];
        buf bufdint [Bits-1:0] (Dint, D);
        buf bufmint [Bits-1:0] (Mint, M);
        buf bufaint [Addr-1:0] (Aint, A);
	
	buf (TBYPASS_main, TBYPASS);
	buf (CKint, CK);
        
        buf (CSNint, CSN);    
	buf (WENint, WEN);

        //TBYPASS functionality
        
        buf bufdeltb [Bits-1:0] (delTBYPASS, TBYPASS);
          
        
        
        buf buftbdq [Bits-1:0] (TBYPASS_D_Q, D );
         
        
        
        







        wire RY_rfCKint, RY_rrCKint, RY_frCKint, ICRYFlagint;
        reg RY_rfCKreg, RY_rrCKreg, RY_frCKreg; 
	reg InitialRYFlag, ICRYFlag;

        
        buf (RY_rfCK, RY_rfCKint);
	buf (RY_rrCK, RY_rrCKint);
	buf (RY_frCK, RY_frCKint);
        buf (ICRY, ICRYFlagint);
        assign ICRYFlagint = ICRYFlag;
        
        

    specify
        specparam

            tdq = 0.01,
            ttmq = 0.01,
            
            taa_ry = 0.01,
            th_ry = 0.009,
            tck_ry = 0.01,
            taa = 1.00,
            th = 0.009;
        /*-------------------- Propagation Delays ------------------*/

   
	if (WENreg && !ICGFlag) (CK *> (Q_data[0] : D[0])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[1] : D[1])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[2] : D[2])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[3] : D[3])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[4] : D[4])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[5] : D[5])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[6] : D[6])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[7] : D[7])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[8] : D[8])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[9] : D[9])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[10] : D[10])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[11] : D[11])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[12] : D[12])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[13] : D[13])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[14] : D[14])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[15] : D[15])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[16] : D[16])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[17] : D[17])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[18] : D[18])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[19] : D[19])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[20] : D[20])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[21] : D[21])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[22] : D[22])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[23] : D[23])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[24] : D[24])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[25] : D[25])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[26] : D[26])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[27] : D[27])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[28] : D[28])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[29] : D[29])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[30] : D[30])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[31] : D[31])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[32] : D[32])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[33] : D[33])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[34] : D[34])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[35] : D[35])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[36] : D[36])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[37] : D[37])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[38] : D[38])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[39] : D[39])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[40] : D[40])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[41] : D[41])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[42] : D[42])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[43] : D[43])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[44] : D[44])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[45] : D[45])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[46] : D[46])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[47] : D[47])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[48] : D[48])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[49] : D[49])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[50] : D[50])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[51] : D[51])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[52] : D[52])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[53] : D[53])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[54] : D[54])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[55] : D[55])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[56] : D[56])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[57] : D[57])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[58] : D[58])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[59] : D[59])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[60] : D[60])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[61] : D[61])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[62] : D[62])) = (taa, taa);
	if (WENreg && !ICGFlag) (CK *> (Q_data[63] : D[63])) = (taa, taa); 
   

	if (!ICGFlag) (CK *> (Q_glitch[0] : D[0])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[1] : D[1])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[2] : D[2])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[3] : D[3])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[4] : D[4])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[5] : D[5])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[6] : D[6])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[7] : D[7])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[8] : D[8])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[9] : D[9])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[10] : D[10])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[11] : D[11])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[12] : D[12])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[13] : D[13])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[14] : D[14])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[15] : D[15])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[16] : D[16])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[17] : D[17])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[18] : D[18])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[19] : D[19])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[20] : D[20])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[21] : D[21])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[22] : D[22])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[23] : D[23])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[24] : D[24])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[25] : D[25])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[26] : D[26])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[27] : D[27])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[28] : D[28])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[29] : D[29])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[30] : D[30])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[31] : D[31])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[32] : D[32])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[33] : D[33])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[34] : D[34])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[35] : D[35])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[36] : D[36])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[37] : D[37])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[38] : D[38])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[39] : D[39])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[40] : D[40])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[41] : D[41])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[42] : D[42])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[43] : D[43])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[44] : D[44])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[45] : D[45])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[46] : D[46])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[47] : D[47])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[48] : D[48])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[49] : D[49])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[50] : D[50])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[51] : D[51])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[52] : D[52])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[53] : D[53])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[54] : D[54])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[55] : D[55])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[56] : D[56])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[57] : D[57])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[58] : D[58])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[59] : D[59])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[60] : D[60])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[61] : D[61])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[62] : D[62])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[63] : D[63])) = (th, th);

	if (!ICGFlag) (CK *> (Q_gCK[0] : D[0])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[1] : D[1])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[2] : D[2])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[3] : D[3])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[4] : D[4])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[5] : D[5])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[6] : D[6])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[7] : D[7])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[8] : D[8])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[9] : D[9])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[10] : D[10])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[11] : D[11])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[12] : D[12])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[13] : D[13])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[14] : D[14])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[15] : D[15])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[16] : D[16])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[17] : D[17])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[18] : D[18])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[19] : D[19])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[20] : D[20])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[21] : D[21])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[22] : D[22])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[23] : D[23])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[24] : D[24])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[25] : D[25])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[26] : D[26])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[27] : D[27])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[28] : D[28])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[29] : D[29])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[30] : D[30])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[31] : D[31])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[32] : D[32])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[33] : D[33])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[34] : D[34])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[35] : D[35])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[36] : D[36])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[37] : D[37])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[38] : D[38])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[39] : D[39])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[40] : D[40])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[41] : D[41])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[42] : D[42])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[43] : D[43])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[44] : D[44])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[45] : D[45])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[46] : D[46])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[47] : D[47])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[48] : D[48])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[49] : D[49])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[50] : D[50])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[51] : D[51])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[52] : D[52])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[53] : D[53])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[54] : D[54])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[55] : D[55])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[56] : D[56])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[57] : D[57])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[58] : D[58])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[59] : D[59])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[60] : D[60])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[61] : D[61])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[62] : D[62])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[63] : D[63])) = (th, th);

	if (!TBYPASS) (TBYPASS *> delTBYPASS[0]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[1]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[2]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[3]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[4]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[5]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[6]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[7]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[8]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[9]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[10]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[11]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[12]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[13]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[14]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[15]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[16]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[17]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[18]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[19]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[20]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[21]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[22]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[23]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[24]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[25]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[26]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[27]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[28]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[29]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[30]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[31]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[32]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[33]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[34]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[35]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[36]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[37]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[38]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[39]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[40]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[41]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[42]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[43]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[44]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[45]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[46]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[47]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[48]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[49]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[50]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[51]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[52]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[53]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[54]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[55]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[56]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[57]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[58]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[59]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[60]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[61]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[62]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[63]) = (0);
	if (TBYPASS) (TBYPASS *> delTBYPASS[0]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[1]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[2]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[3]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[4]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[5]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[6]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[7]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[8]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[9]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[10]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[11]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[12]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[13]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[14]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[15]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[16]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[17]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[18]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[19]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[20]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[21]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[22]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[23]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[24]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[25]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[26]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[27]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[28]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[29]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[30]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[31]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[32]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[33]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[34]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[35]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[36]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[37]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[38]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[39]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[40]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[41]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[42]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[43]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[44]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[45]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[46]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[47]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[48]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[49]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[50]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[51]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[52]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[53]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[54]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[55]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[56]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[57]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[58]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[59]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[60]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[61]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[62]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[63]) = (ttmq);
      (D[0] *> TBYPASS_D_Q[0]) = (tdq, tdq);
      (D[1] *> TBYPASS_D_Q[1]) = (tdq, tdq);
      (D[2] *> TBYPASS_D_Q[2]) = (tdq, tdq);
      (D[3] *> TBYPASS_D_Q[3]) = (tdq, tdq);
      (D[4] *> TBYPASS_D_Q[4]) = (tdq, tdq);
      (D[5] *> TBYPASS_D_Q[5]) = (tdq, tdq);
      (D[6] *> TBYPASS_D_Q[6]) = (tdq, tdq);
      (D[7] *> TBYPASS_D_Q[7]) = (tdq, tdq);
      (D[8] *> TBYPASS_D_Q[8]) = (tdq, tdq);
      (D[9] *> TBYPASS_D_Q[9]) = (tdq, tdq);
      (D[10] *> TBYPASS_D_Q[10]) = (tdq, tdq);
      (D[11] *> TBYPASS_D_Q[11]) = (tdq, tdq);
      (D[12] *> TBYPASS_D_Q[12]) = (tdq, tdq);
      (D[13] *> TBYPASS_D_Q[13]) = (tdq, tdq);
      (D[14] *> TBYPASS_D_Q[14]) = (tdq, tdq);
      (D[15] *> TBYPASS_D_Q[15]) = (tdq, tdq);
      (D[16] *> TBYPASS_D_Q[16]) = (tdq, tdq);
      (D[17] *> TBYPASS_D_Q[17]) = (tdq, tdq);
      (D[18] *> TBYPASS_D_Q[18]) = (tdq, tdq);
      (D[19] *> TBYPASS_D_Q[19]) = (tdq, tdq);
      (D[20] *> TBYPASS_D_Q[20]) = (tdq, tdq);
      (D[21] *> TBYPASS_D_Q[21]) = (tdq, tdq);
      (D[22] *> TBYPASS_D_Q[22]) = (tdq, tdq);
      (D[23] *> TBYPASS_D_Q[23]) = (tdq, tdq);
      (D[24] *> TBYPASS_D_Q[24]) = (tdq, tdq);
      (D[25] *> TBYPASS_D_Q[25]) = (tdq, tdq);
      (D[26] *> TBYPASS_D_Q[26]) = (tdq, tdq);
      (D[27] *> TBYPASS_D_Q[27]) = (tdq, tdq);
      (D[28] *> TBYPASS_D_Q[28]) = (tdq, tdq);
      (D[29] *> TBYPASS_D_Q[29]) = (tdq, tdq);
      (D[30] *> TBYPASS_D_Q[30]) = (tdq, tdq);
      (D[31] *> TBYPASS_D_Q[31]) = (tdq, tdq);
      (D[32] *> TBYPASS_D_Q[32]) = (tdq, tdq);
      (D[33] *> TBYPASS_D_Q[33]) = (tdq, tdq);
      (D[34] *> TBYPASS_D_Q[34]) = (tdq, tdq);
      (D[35] *> TBYPASS_D_Q[35]) = (tdq, tdq);
      (D[36] *> TBYPASS_D_Q[36]) = (tdq, tdq);
      (D[37] *> TBYPASS_D_Q[37]) = (tdq, tdq);
      (D[38] *> TBYPASS_D_Q[38]) = (tdq, tdq);
      (D[39] *> TBYPASS_D_Q[39]) = (tdq, tdq);
      (D[40] *> TBYPASS_D_Q[40]) = (tdq, tdq);
      (D[41] *> TBYPASS_D_Q[41]) = (tdq, tdq);
      (D[42] *> TBYPASS_D_Q[42]) = (tdq, tdq);
      (D[43] *> TBYPASS_D_Q[43]) = (tdq, tdq);
      (D[44] *> TBYPASS_D_Q[44]) = (tdq, tdq);
      (D[45] *> TBYPASS_D_Q[45]) = (tdq, tdq);
      (D[46] *> TBYPASS_D_Q[46]) = (tdq, tdq);
      (D[47] *> TBYPASS_D_Q[47]) = (tdq, tdq);
      (D[48] *> TBYPASS_D_Q[48]) = (tdq, tdq);
      (D[49] *> TBYPASS_D_Q[49]) = (tdq, tdq);
      (D[50] *> TBYPASS_D_Q[50]) = (tdq, tdq);
      (D[51] *> TBYPASS_D_Q[51]) = (tdq, tdq);
      (D[52] *> TBYPASS_D_Q[52]) = (tdq, tdq);
      (D[53] *> TBYPASS_D_Q[53]) = (tdq, tdq);
      (D[54] *> TBYPASS_D_Q[54]) = (tdq, tdq);
      (D[55] *> TBYPASS_D_Q[55]) = (tdq, tdq);
      (D[56] *> TBYPASS_D_Q[56]) = (tdq, tdq);
      (D[57] *> TBYPASS_D_Q[57]) = (tdq, tdq);
      (D[58] *> TBYPASS_D_Q[58]) = (tdq, tdq);
      (D[59] *> TBYPASS_D_Q[59]) = (tdq, tdq);
      (D[60] *> TBYPASS_D_Q[60]) = (tdq, tdq);
      (D[61] *> TBYPASS_D_Q[61]) = (tdq, tdq);
      (D[62] *> TBYPASS_D_Q[62]) = (tdq, tdq);
      (D[63] *> TBYPASS_D_Q[63]) = (tdq, tdq);


        // RY functionality
	if (!ICRYFlag && InitialRYFlag) (CK *> RY_rfCK) = (th_ry, th_ry);

        if (!ICRYFlag && InitialRYFlag) (CK *> RY_rrCK) = (taa_ry, taa_ry); 
	if (!ICRYFlag && InitialRYFlag) (CK *> RY_frCK) = (tck_ry, tck_ry);   

	endspecify


assign #0 Q_data = OutReg_data;
assign Q_glitch = OutReg_glitch;
assign Q_gCK = Q_gCKreg;




    // BEHAVIOURAL MODULE DESCRIPTION

task chstate;
   input [Bits-1 : 0] clkin;
   output [Bits-1 : 0] clkout;
   integer d;
begin
   if ( $realtime != 0 )
      for (d = 0; d < Bits; d = d + 1)
      begin
         if (clkin[d] === 1'b0)
            clkout[d] = 1'b1;
         else if (clkin[d] === 1'b1)
            clkout[d] = 1'bx;
         else
            clkout[d] = 1'b0;
      end
end
endtask


task task_insert_faults_in_memory;
begin
   Fault_in_memory = 1;
   for(i = 0;i< fcnt;i = i+ 1)
   begin
     if (fault_repair_flag[i] !== 1)
     begin
       Fault_in_memory = 0;
       if (array_stuck_at[i] === "sa0")
       begin
          Mem[FailureLocn[i]] = Mem[FailureLocn[i]] & stuck_at_0fault[i];
       end //if(array_stuck_at)
                                              
       if(array_stuck_at[i] === "sa1")
       begin
         Mem[FailureLocn[i]] = Mem[FailureLocn[i]] | stuck_at_1fault[i]; 
       end //if(array_stuck_at)
     end//if (fault_repair_flag
   end// for loop...
end
endtask



task WriteMemX;
begin
    for (i = 0; i < Words; i = i + 1)
       Mem[i] = WordX;
end
endtask

task WriteLocX;
   input [Addr-1 : 0] Address;
begin
   if (^Address !== X)
       Mem[Address] = WordX;
   else
      WriteMemX;
end
endtask

task WriteLocMskX;
  input [Addr-1 : 0] Address;
  input [Bits-1 : 0] Mask;
  input [Bits-1 : 0] prevMem;
  reg [Bits-1 : 0] Outdata;
begin
  if (^Address !== X)
  begin
      tempMem = Mem[Address];
     for (j = 0;j< Bits; j=j+1)
     begin
        if (prevMem[j] !== Dreg[j]) 
        begin
           if (Mask[j] !== 1'b1)
              tempMem[j] = 1'bx;
        end
     end//for (j = 0;j< Bi

     Mem[Address] = tempMem;
  end//if (^Address !== X
  else
     WriteMemX;
end
endtask

task WriteLocMskX_bwise;
   input [Addr-1 : 0] Address;
   input [Bits-1 : 0] Mask;
begin
   if (^Address !== X)
   begin
      tempMem = Mem[Address];
             
      for (j = 0;j< Bits; j=j+1)
         if (Mask[j] === 1'bx)
            tempMem[j] = 1'bx;
                    
      Mem[Address] = tempMem;

   end//if (^Address !== X
   else
      WriteMemX;
end
endtask
    
task WriteOutX;                
begin
   OutReg_data= WordX;
   OutReg_glitch= WordX;
end
endtask

task WriteOutX_bwise;
   input [Bits-1 : 0] flag;
   input [Bits-1 : 0] Delayedflag;
   input [Addr-1 : 0] Address;
   reg [Bits-1 : 0] MemData;
begin
    MemData = Mem[Address];
        
   for ( l = 0; l < Bits; l = l + 1 )
      if (Delayedflag[l] !== flag[l] && MemData[l] === 1'bx)
      begin
         OutReg_data[l] = 1'bx;
	 OutReg_glitch[l] = 1'bx;
      end
end
endtask

task WriteOut;
begin
   for (i = 0;i < Bits; i = i+1)
   begin        
   
      if (last_Qdata[i] !== Mem_temp[i])     
      begin
         OutReg_data[i] = 1'bX;
         OutReg_glitch[i] = 1'bX;
      end
      else
         OutReg_glitch[i] = OutReg_data[i];
   end   
end
endtask  

task WriteCycle;                  
   input [Addr-1 : 0] Address;
   reg [Bits-1:0] tempReg1,tempReg2;
   integer po,i;
begin

   tempReg1 = WordX;
   if (^Address !== X)
   begin
      if (ValidAddress)
      begin
         
                 tempReg1 = Mem[Address];
                 for (po=0;po<Bits;po=po+1)
                 if (Mreg[po] === 1'b0)
                       tempReg1[po] = Dreg[po];
                 else if ((Mreg[po] !== 1'b1) && (tempReg1[po] !== Dreg[po]))
                       tempReg1[po] = 1'bx;
                        
                 Mem[Address] = tempReg1;
                    
      end //if (ValidAddress)
      else
         if(debug_level < 2) $display("%m - %t (MSG_ID 701) WARNING: Write Port:  Address Out Of Range. ",$realtime);
   end//if (^Address !== X)
   else
   begin
      if(debug_level < 2) $display("%m - %t (MSG_ID 008) WARNING: Write Port:  Illegal Value on Address Bus. Memory Corrupted ",$realtime);
      WriteMemX;
   end
 end

endtask

task ReadCycle;
   input [Addr-1 : 0] Address;
   reg [Bits-1:0] MemData;
   integer a;
begin

   if (ValidAddress)
      MemData = Mem[Address];

   if(ValidAddress === X)
   begin
      if(debug_level < 2) $display("%m - %t (MSG_ID 008) WARNING: Read Port:  Illegal Value on Address Bus. Memory and Output Corrupted ",$realtime);
      WriteMemX;
      MemData = WordX;
   end                        
   else if (ValidAddress === 0)
   begin                        
      if(debug_level < 2) $display("%m - %t (MSG_ID 701) WARNING: Read Port:  Address Out Of Range. Output Corrupted ",$realtime);
      MemData = WordX;
   end

   for (a = 0; a < Bits; a = a + 1)
   begin
      if (MemData[a] !== OutReg_data[a])
         OutReg_glitch[a] = WordX[a];
      else
         OutReg_glitch[a] = MemData[a];
   end//for (a = 0; a <

   OutReg_data = MemData;
   Operation_Flag = 1;
   last_Qdata = Q_data;

end
endtask




assign RY_rfCKint = RY_rfCKreg;
assign RY_frCKint = RY_frCKreg;
assign RY_rrCKint = RY_rrCKreg;

// Define format for timing value
initial
begin
  $timeformat (-9, 2, " ns", 0);
  ICGFlag = 0;
  if (MEM_INITIALIZE === 1'b1)
  begin   
     if (BinaryInit)
        $readmemb(InitFileName, Mem, 0, Words-1);
     else
        $readmemh(InitFileName, Mem, 0, Words-1);
  end

  
  ICRYFlag = 1;
  InitialRYFlag = 0;
  ICRYFlag <= 0;
  RY_rfCKreg = 1'b1;
  RY_rrCKreg = 1'b1;
  RY_frCKreg = 1'b1;


/*  -----------Implemetation for config fault starts------*/
   msgcnt = X;
   t = 0;
   fault_repair_flag = {max_faults{1'b1}};
   repair_flag = {max_faults{1'b1}};
   if(ConfigFault) 
   begin
        file_ptr = $fopen(Fault_file_name , "r");
        if(file_ptr == 0)
        begin     
          if(debug_level < 3) $display("%m - %t (MSG_ID 201) FAILURE: File cannot be opened ",$realtime);      
        end        
      else                
      begin : read_fault_file
      t = 0;
      for (i = 0; i< max_faults; i= i + 1)
      begin
         
         stuck0 = {Bits{1'b1}};
         stuck1 = {Bits{1'b0}};
         fault_char1 = $fgetc (file_ptr);
         if (fault_char1 == 8'b11111111)
                 disable read_fault_file;
         ret_val = $ungetc (fault_char1, file_ptr);
         ret_val = $fgets(tempStr, file_ptr);
         ret_val = $sscanf(tempStr, "%d %d %s",fault_word, fault_bit, stuck_at) ;
        flag_error = 0; 
         if(ret_val !== 0)
            begin         
               if(ret_val == 2 || ret_val == 3)
               begin
                  if(ret_val == 2)
                      stuck_at = "sa0";

                  if(stuck_at !== "sa0" && stuck_at !== "sa1" && stuck_at !== "none")
                  begin
                      if(debug_level < 2) $display("%m - %t (MSG_ID 203) WARNING: Wrong value for stuck at in fault file ",$realtime);
                      flag_error = 1;
                  end    
                      
                  if(fault_word > Words-1)
                  begin
                      if(debug_level < 2) $display("%m - %t (MSG_ID 206) WARNING: Address out of range in fault file ",$realtime);
                      flag_error = 1;
                  end    

                  if(fault_bit > Bits)
                  begin  
                      if(debug_level < 2) $display("%m - %t (MSG_ID 205) WARNING: Faulty bit out of range in fault file ",$realtime);
                      flag_error = 1;
                  end    

                  if(flag_error == 0)
                  //Correct Inputs
                  begin
                      if(stuck_at === "none")
                      begin
                         if(debug_level < 2) $display("%m - %t (MSG_ID 202) WARNING: No fault injected, empty fault file ",$realtime);
                      end
                      else
                      //Adding the faults
                      begin
                         FailureLocn[t] = fault_word;
                         std_fault_word = fault_word;
                         
                         fault_repair_flag[t] = 1'b0;
                         if (stuck_at === "sa0" )
                         begin
                            stuck0[fault_bit] = 1'b0;         
                            stuck_at_0fault[t] = stuck0;
                         end     
                         if (stuck_at === "sa1" )
                         begin
                            stuck1[fault_bit] = 1'b1;
                            stuck_at_1fault[t] = stuck1; 
                         end

                         array_stuck_at[t] = stuck_at;
                         t = t + 1;
                      end //if(stuck_at === "none")  
                  end //if(flag_error == 0)
               end //if(ret_val == 2 || ret_val == 3 
               else
               //wrong number of arguments
               begin
                  if(debug_level < 2)
                  $display("%m - %t WARNING :  WRONG VALUES ENTERED FOR FAULTY WORD OR FAULTY BIT OR STUCK_AT IN Fault_file_name", $realtime);
                  flag_error = 1;
               end
             end //if(ret_val !== 0)
             else
             begin
                 if(debug_level < 2) $display("%m - %t (MSG_ID 202) WARNING: No fault injected, empty fault file ",$realtime);
             end    
      end //for (i = 0; i< m
      end //begin: read_fault_file  
      $fclose (file_ptr);
      fcnt = t;

      
      
      //fault injection at time 0.
      task_insert_faults_in_memory;
      

   end // config_fault 
end// initial



//+++++++++++++++++++++++++++++++ CONFIG FAULT IMPLEMETATION ENDS+++++++++++++++++++++++++++++++//

always @(CKint)
begin
   lastCK = CKreg;
   CKreg = CKint;
   if(CKreg === 1'b1 && lastCK === 1'b0)
   begin
     CSNreg = CSNint;
   end

   
   if (CKint !== 0 && CSNint !== 1)
   begin
     InitialRYFlag = 1;
   end
   

   
   if (CKint===1 && lastCK ===0 && CSNint === X)
       ICRYFlag = 1;
   else if (CKint === 1 && lastCK === 0 && CSNint === 0)
       ICRYFlag = 0;
   

   /*---------------------- Latching signals ----------------------*/
   if(CKreg === 1'b1 && lastCK === 1'b0)
   begin
      
      WENreg = WENint;
   end   
   if(CKreg === 1'b1 && lastCK === 1'b0 && CSNint === 1'b0) begin
      ICGFlag = 0;
      Dreg = Dint;
      Mreg = Mint;
      Areg = Aint;
      if (^Areg === X)
         ValidAddress = X;
      else if (Areg < Words)
         ValidAddress = 1;
      else
         ValidAddress = 0;

      if (ValidAddress)
         Mem_temp = Mem[Aint];
      else
         Mem_temp = WordX; 

      
      
      Operation_Flag = 0;
      last_Qdata = Q_data;
      
      /*------ Normal Read and Write --------*/
      if (WENreg === 1)
      begin
         ReadCycle(Areg);
         chstate(Q_gCKreg, Q_gCKreg);
      end//if (WENreg === 1 && C
      else if (WENreg === 0 )
      begin
         WriteCycle(Areg);
      end
      /*---------- Corruption due to faulty values on signals --------*/
      else if (WENreg === X)
      begin
         chstate(Q_gCKreg, Q_gCKreg);
         // Uncertain write cycle
         WriteLocMskX(Areg,Mreg,Mem_temp);
         WriteOut;
         if (^Areg === X || Areg > Words-1)
         begin
              WriteOutX;	// if add is unknown put X at output
         end    
      end//else if (WENreg =
      
         

      
   end//if(CKreg === 1'b1 && lastCK =   
   // Unknown Clock Behaviour
   else if (((CSNint === 1'bx) && (CKint === 1)) || (CKint=== 1'bx && CSNreg !==1)) begin
      WriteMemX;
      WriteOutX;
      ICGFlag = 1'b1;
       
      ICRYFlag = 1'b1;
      if(CKint === 1'bx && CSNreg !== 1'b1) begin
         if(debug_level < 2) $display("%m - %t (MSG_ID 003) WARNING: Illegal Value on Clock. Memory and Output Corrupted ",$realtime);
      end
      else begin
         if(debug_level < 2) $display("%m - %t (MSG_ID 010) WARNING: Invalid control signal (chip select / memory bypass) Memory and Output Corrupted ",$realtime);
      end
   end 
   if(ConfigFault) begin
      task_insert_faults_in_memory;
      
   end//if(ConfigFault)
   
 end // always @(CKint)

always @(CSNint)
begin   
   // Unknown Clock & CSN signal
      if (CSNint !== 1 && CKint === X )
      begin
         chstate(Q_gCKreg, Q_gCKreg);
       	 WriteMemX;
	 WriteOutX;
         
         ICRYFlag = 1;   
      end//if (CSNint !== 1
end      


always @(TBYPASS_main)
begin

   OutReg_data = WordX;
   OutReg_glitch = WordX;
   
   if (TBYPASS_main !== 0)
      ICRYFlag = 1;
   
end


  

        /*---------------RY Functionality-----------------*/
always @(posedge CKreg)
begin


   if ((CSNreg === 0) && (CKreg === 1 && lastCK === 0) && TBYPASS_main === 1'b0)
   begin
           RY_rfCKreg = ~RY_rfCKreg;
        RY_rrCKreg = ~RY_rrCKreg;
   end


end

always @(negedge CKreg)
begin

   
   if (TBYPASS_main === 1'b0 && (CSNreg === 1'b0) && (CKreg === 1'b0 && lastCK === 1'b1))
   begin
        RY_frCKreg = ~RY_frCKreg;
    end


end

always @(TimingViol9 or TimingViol10 or TimingViol4 or TimingViol5 or TimingViol8 )
ICRYFlag = 1;
        /*---------------------------------*/






   




   
/*---------------TBYPASS  Functionality in functional model -----------------*/

always @(TimingViol9 or TimingViol10 or TimingViol4 or TimingViol5 or TimingViol8)
begin
   if (TBYPASS !== 0)
      WriteMemX;
end

always @(TimingViol2 or TimingViol3)
// tds or tdh violation
begin
#0
   for (l = 0; l < Bits; l = l + 1)
   begin   
      if((TimingViol2[l] !== TimingViol2_last[l]))
         Mreg[l] = 1'bx;
      if((TimingViol3[l] !== TimingViol3_last[l]))
         Mreg[l] = 1'bx;   
   end   
   WriteLocMskX_bwise(Areg,Mreg);
   TimingViol2_last = TimingViol2;
   TimingViol3_last = TimingViol3;
end


always @(TimingViol12 or TimingViol13)
// tms or tmh violation
begin
#0
   if ((CSNint === X) || (CKint === X))
   begin
      for (i = 0; i < Bits; i = i+1)
      begin   
         if (TimingViol12_last[i] !== TimingViol12[i])
	    Mreg[i] = 1'bx;
         if (TimingViol13_last[i] !== TimingViol13[i])
	    Mreg[i] = 1'bx;
      end      
      Areg = AddrX;
   end//if ((CSNint === X)
   else
   begin
      for (i = 0; i < Bits; i = i+1)
      begin   
         if ((TimingViol12_last[i] !== TimingViol12[i]) && (Mem_temp[i] !== Dreg[i]))
            Mreg[i] = 1'bx;
         if ((TimingViol13_last[i] !== TimingViol13[i]) && (Mem_temp[i] !== Dreg[i]))
            Mreg[i] = 1'bx;
      end      
   end
   WriteLocMskX_bwise(Areg, Mreg);
   TimingViol12_last = TimingViol12;
   TimingViol13_last = TimingViol13;
end

        
/*---------- Corruption due to Timing Violations ---------------*/

always @(TimingViol9 or TimingViol10)
// tckl -  tcycle
begin
#0
   Dreg = WordX;
   WriteOutX;
   #0.00 WriteMemX;
end

always @(TimingViol4 or TimingViol5)
// tps or tph
begin
#0
   Dreg = WordX;
   if ((WENreg !== 0) || (lastCK === X))
      WriteOutX;
   if (lastCK === X)
      WriteMemX;  
   WriteMemX; 
   if (CSNreg === 1 && WENreg !== 0)
   begin
      chstate(Q_gCKreg, Q_gCKreg);
   end
end

always @(TimingViol8)
// tckh
begin
#0
   Dreg = WordX;
   ICGFlag = 1;
   chstate(Q_gCKreg, Q_gCKreg);
   WriteOutX;
   WriteMemX;
end

always @(TimingViol0 or TimingViol1)
// tas or tah
begin
#0
   Areg = AddrX;
   ValidAddress = X;
   if (WENreg !== 0)
      WriteOutX;
   WriteMemX;
end


always @(TimingViol6 or TimingViol7)
//tws or twh
begin
#0
   if (CSNreg === X)
   begin
      WriteMemX; 
      WriteOutX;
   end
   else
   begin
      WriteLocMskX(Areg,Mreg,Mem_temp); 
      WriteOut;
      if (^Areg === X)
         WriteOutX;	// if add is unknown put X at output
   end
end


always @(TimingViol_ttms_ttmh)
//ttms/ttmh
begin
#0
   Dreg = WordX;
   WriteOutX;
   WriteMemX;  
   
   ICRYFlag = 1; 
end





endmodule

module ST_SPHDL_160x64m8_bL_OPschlr (QINT,  RYINT, Q_gCK, Q_glitch,  Q_data, RY_rfCK, RY_rrCK, RY_frCK, ICRY, delTBYPASS, TBYPASS_D_Q, TBYPASS_main  );

    parameter
        Words = 160,
        Bits = 64,
        Addr = 8;
        

    parameter
        WordX = 64'bx,
        AddrX = 8'bx,
        X = 1'bx;

	output [Bits-1 : 0] QINT;
	input [Bits-1 : 0] Q_glitch;
	input [Bits-1 : 0] Q_data;
	input [Bits-1 : 0] Q_gCK;
        input [Bits-1 : 0] TBYPASS_D_Q;
        input [Bits-1 : 0] delTBYPASS;
        input TBYPASS_main;



	integer m,a, d, n, o, p;
	wire [Bits-1 : 0] QINTint;
	wire [Bits-1 : 0] QINTERNAL;

        reg [Bits-1 : 0] OutReg;
	reg [Bits-1 : 0] lastQ_gCK, Q_gCKreg;
	reg [Bits-1 : 0] lastQ_data, Q_datareg;
	reg [Bits-1 : 0] QINTERNALreg;
	reg [Bits-1 : 0] lastQINTERNAL;

buf bufqint [Bits-1:0] (QINT, QINTint);


	assign QINTint[0] = (TBYPASS_main===0 && delTBYPASS[0]===0)?OutReg[0] : (TBYPASS_main===1 && delTBYPASS[0]===1)?TBYPASS_D_Q[0] : WordX;
	assign QINTint[1] = (TBYPASS_main===0 && delTBYPASS[1]===0)?OutReg[1] : (TBYPASS_main===1 && delTBYPASS[1]===1)?TBYPASS_D_Q[1] : WordX;
	assign QINTint[2] = (TBYPASS_main===0 && delTBYPASS[2]===0)?OutReg[2] : (TBYPASS_main===1 && delTBYPASS[2]===1)?TBYPASS_D_Q[2] : WordX;
	assign QINTint[3] = (TBYPASS_main===0 && delTBYPASS[3]===0)?OutReg[3] : (TBYPASS_main===1 && delTBYPASS[3]===1)?TBYPASS_D_Q[3] : WordX;
	assign QINTint[4] = (TBYPASS_main===0 && delTBYPASS[4]===0)?OutReg[4] : (TBYPASS_main===1 && delTBYPASS[4]===1)?TBYPASS_D_Q[4] : WordX;
	assign QINTint[5] = (TBYPASS_main===0 && delTBYPASS[5]===0)?OutReg[5] : (TBYPASS_main===1 && delTBYPASS[5]===1)?TBYPASS_D_Q[5] : WordX;
	assign QINTint[6] = (TBYPASS_main===0 && delTBYPASS[6]===0)?OutReg[6] : (TBYPASS_main===1 && delTBYPASS[6]===1)?TBYPASS_D_Q[6] : WordX;
	assign QINTint[7] = (TBYPASS_main===0 && delTBYPASS[7]===0)?OutReg[7] : (TBYPASS_main===1 && delTBYPASS[7]===1)?TBYPASS_D_Q[7] : WordX;
	assign QINTint[8] = (TBYPASS_main===0 && delTBYPASS[8]===0)?OutReg[8] : (TBYPASS_main===1 && delTBYPASS[8]===1)?TBYPASS_D_Q[8] : WordX;
	assign QINTint[9] = (TBYPASS_main===0 && delTBYPASS[9]===0)?OutReg[9] : (TBYPASS_main===1 && delTBYPASS[9]===1)?TBYPASS_D_Q[9] : WordX;
	assign QINTint[10] = (TBYPASS_main===0 && delTBYPASS[10]===0)?OutReg[10] : (TBYPASS_main===1 && delTBYPASS[10]===1)?TBYPASS_D_Q[10] : WordX;
	assign QINTint[11] = (TBYPASS_main===0 && delTBYPASS[11]===0)?OutReg[11] : (TBYPASS_main===1 && delTBYPASS[11]===1)?TBYPASS_D_Q[11] : WordX;
	assign QINTint[12] = (TBYPASS_main===0 && delTBYPASS[12]===0)?OutReg[12] : (TBYPASS_main===1 && delTBYPASS[12]===1)?TBYPASS_D_Q[12] : WordX;
	assign QINTint[13] = (TBYPASS_main===0 && delTBYPASS[13]===0)?OutReg[13] : (TBYPASS_main===1 && delTBYPASS[13]===1)?TBYPASS_D_Q[13] : WordX;
	assign QINTint[14] = (TBYPASS_main===0 && delTBYPASS[14]===0)?OutReg[14] : (TBYPASS_main===1 && delTBYPASS[14]===1)?TBYPASS_D_Q[14] : WordX;
	assign QINTint[15] = (TBYPASS_main===0 && delTBYPASS[15]===0)?OutReg[15] : (TBYPASS_main===1 && delTBYPASS[15]===1)?TBYPASS_D_Q[15] : WordX;
	assign QINTint[16] = (TBYPASS_main===0 && delTBYPASS[16]===0)?OutReg[16] : (TBYPASS_main===1 && delTBYPASS[16]===1)?TBYPASS_D_Q[16] : WordX;
	assign QINTint[17] = (TBYPASS_main===0 && delTBYPASS[17]===0)?OutReg[17] : (TBYPASS_main===1 && delTBYPASS[17]===1)?TBYPASS_D_Q[17] : WordX;
	assign QINTint[18] = (TBYPASS_main===0 && delTBYPASS[18]===0)?OutReg[18] : (TBYPASS_main===1 && delTBYPASS[18]===1)?TBYPASS_D_Q[18] : WordX;
	assign QINTint[19] = (TBYPASS_main===0 && delTBYPASS[19]===0)?OutReg[19] : (TBYPASS_main===1 && delTBYPASS[19]===1)?TBYPASS_D_Q[19] : WordX;
	assign QINTint[20] = (TBYPASS_main===0 && delTBYPASS[20]===0)?OutReg[20] : (TBYPASS_main===1 && delTBYPASS[20]===1)?TBYPASS_D_Q[20] : WordX;
	assign QINTint[21] = (TBYPASS_main===0 && delTBYPASS[21]===0)?OutReg[21] : (TBYPASS_main===1 && delTBYPASS[21]===1)?TBYPASS_D_Q[21] : WordX;
	assign QINTint[22] = (TBYPASS_main===0 && delTBYPASS[22]===0)?OutReg[22] : (TBYPASS_main===1 && delTBYPASS[22]===1)?TBYPASS_D_Q[22] : WordX;
	assign QINTint[23] = (TBYPASS_main===0 && delTBYPASS[23]===0)?OutReg[23] : (TBYPASS_main===1 && delTBYPASS[23]===1)?TBYPASS_D_Q[23] : WordX;
	assign QINTint[24] = (TBYPASS_main===0 && delTBYPASS[24]===0)?OutReg[24] : (TBYPASS_main===1 && delTBYPASS[24]===1)?TBYPASS_D_Q[24] : WordX;
	assign QINTint[25] = (TBYPASS_main===0 && delTBYPASS[25]===0)?OutReg[25] : (TBYPASS_main===1 && delTBYPASS[25]===1)?TBYPASS_D_Q[25] : WordX;
	assign QINTint[26] = (TBYPASS_main===0 && delTBYPASS[26]===0)?OutReg[26] : (TBYPASS_main===1 && delTBYPASS[26]===1)?TBYPASS_D_Q[26] : WordX;
	assign QINTint[27] = (TBYPASS_main===0 && delTBYPASS[27]===0)?OutReg[27] : (TBYPASS_main===1 && delTBYPASS[27]===1)?TBYPASS_D_Q[27] : WordX;
	assign QINTint[28] = (TBYPASS_main===0 && delTBYPASS[28]===0)?OutReg[28] : (TBYPASS_main===1 && delTBYPASS[28]===1)?TBYPASS_D_Q[28] : WordX;
	assign QINTint[29] = (TBYPASS_main===0 && delTBYPASS[29]===0)?OutReg[29] : (TBYPASS_main===1 && delTBYPASS[29]===1)?TBYPASS_D_Q[29] : WordX;
	assign QINTint[30] = (TBYPASS_main===0 && delTBYPASS[30]===0)?OutReg[30] : (TBYPASS_main===1 && delTBYPASS[30]===1)?TBYPASS_D_Q[30] : WordX;
	assign QINTint[31] = (TBYPASS_main===0 && delTBYPASS[31]===0)?OutReg[31] : (TBYPASS_main===1 && delTBYPASS[31]===1)?TBYPASS_D_Q[31] : WordX;
	assign QINTint[32] = (TBYPASS_main===0 && delTBYPASS[32]===0)?OutReg[32] : (TBYPASS_main===1 && delTBYPASS[32]===1)?TBYPASS_D_Q[32] : WordX;
	assign QINTint[33] = (TBYPASS_main===0 && delTBYPASS[33]===0)?OutReg[33] : (TBYPASS_main===1 && delTBYPASS[33]===1)?TBYPASS_D_Q[33] : WordX;
	assign QINTint[34] = (TBYPASS_main===0 && delTBYPASS[34]===0)?OutReg[34] : (TBYPASS_main===1 && delTBYPASS[34]===1)?TBYPASS_D_Q[34] : WordX;
	assign QINTint[35] = (TBYPASS_main===0 && delTBYPASS[35]===0)?OutReg[35] : (TBYPASS_main===1 && delTBYPASS[35]===1)?TBYPASS_D_Q[35] : WordX;
	assign QINTint[36] = (TBYPASS_main===0 && delTBYPASS[36]===0)?OutReg[36] : (TBYPASS_main===1 && delTBYPASS[36]===1)?TBYPASS_D_Q[36] : WordX;
	assign QINTint[37] = (TBYPASS_main===0 && delTBYPASS[37]===0)?OutReg[37] : (TBYPASS_main===1 && delTBYPASS[37]===1)?TBYPASS_D_Q[37] : WordX;
	assign QINTint[38] = (TBYPASS_main===0 && delTBYPASS[38]===0)?OutReg[38] : (TBYPASS_main===1 && delTBYPASS[38]===1)?TBYPASS_D_Q[38] : WordX;
	assign QINTint[39] = (TBYPASS_main===0 && delTBYPASS[39]===0)?OutReg[39] : (TBYPASS_main===1 && delTBYPASS[39]===1)?TBYPASS_D_Q[39] : WordX;
	assign QINTint[40] = (TBYPASS_main===0 && delTBYPASS[40]===0)?OutReg[40] : (TBYPASS_main===1 && delTBYPASS[40]===1)?TBYPASS_D_Q[40] : WordX;
	assign QINTint[41] = (TBYPASS_main===0 && delTBYPASS[41]===0)?OutReg[41] : (TBYPASS_main===1 && delTBYPASS[41]===1)?TBYPASS_D_Q[41] : WordX;
	assign QINTint[42] = (TBYPASS_main===0 && delTBYPASS[42]===0)?OutReg[42] : (TBYPASS_main===1 && delTBYPASS[42]===1)?TBYPASS_D_Q[42] : WordX;
	assign QINTint[43] = (TBYPASS_main===0 && delTBYPASS[43]===0)?OutReg[43] : (TBYPASS_main===1 && delTBYPASS[43]===1)?TBYPASS_D_Q[43] : WordX;
	assign QINTint[44] = (TBYPASS_main===0 && delTBYPASS[44]===0)?OutReg[44] : (TBYPASS_main===1 && delTBYPASS[44]===1)?TBYPASS_D_Q[44] : WordX;
	assign QINTint[45] = (TBYPASS_main===0 && delTBYPASS[45]===0)?OutReg[45] : (TBYPASS_main===1 && delTBYPASS[45]===1)?TBYPASS_D_Q[45] : WordX;
	assign QINTint[46] = (TBYPASS_main===0 && delTBYPASS[46]===0)?OutReg[46] : (TBYPASS_main===1 && delTBYPASS[46]===1)?TBYPASS_D_Q[46] : WordX;
	assign QINTint[47] = (TBYPASS_main===0 && delTBYPASS[47]===0)?OutReg[47] : (TBYPASS_main===1 && delTBYPASS[47]===1)?TBYPASS_D_Q[47] : WordX;
	assign QINTint[48] = (TBYPASS_main===0 && delTBYPASS[48]===0)?OutReg[48] : (TBYPASS_main===1 && delTBYPASS[48]===1)?TBYPASS_D_Q[48] : WordX;
	assign QINTint[49] = (TBYPASS_main===0 && delTBYPASS[49]===0)?OutReg[49] : (TBYPASS_main===1 && delTBYPASS[49]===1)?TBYPASS_D_Q[49] : WordX;
	assign QINTint[50] = (TBYPASS_main===0 && delTBYPASS[50]===0)?OutReg[50] : (TBYPASS_main===1 && delTBYPASS[50]===1)?TBYPASS_D_Q[50] : WordX;
	assign QINTint[51] = (TBYPASS_main===0 && delTBYPASS[51]===0)?OutReg[51] : (TBYPASS_main===1 && delTBYPASS[51]===1)?TBYPASS_D_Q[51] : WordX;
	assign QINTint[52] = (TBYPASS_main===0 && delTBYPASS[52]===0)?OutReg[52] : (TBYPASS_main===1 && delTBYPASS[52]===1)?TBYPASS_D_Q[52] : WordX;
	assign QINTint[53] = (TBYPASS_main===0 && delTBYPASS[53]===0)?OutReg[53] : (TBYPASS_main===1 && delTBYPASS[53]===1)?TBYPASS_D_Q[53] : WordX;
	assign QINTint[54] = (TBYPASS_main===0 && delTBYPASS[54]===0)?OutReg[54] : (TBYPASS_main===1 && delTBYPASS[54]===1)?TBYPASS_D_Q[54] : WordX;
	assign QINTint[55] = (TBYPASS_main===0 && delTBYPASS[55]===0)?OutReg[55] : (TBYPASS_main===1 && delTBYPASS[55]===1)?TBYPASS_D_Q[55] : WordX;
	assign QINTint[56] = (TBYPASS_main===0 && delTBYPASS[56]===0)?OutReg[56] : (TBYPASS_main===1 && delTBYPASS[56]===1)?TBYPASS_D_Q[56] : WordX;
	assign QINTint[57] = (TBYPASS_main===0 && delTBYPASS[57]===0)?OutReg[57] : (TBYPASS_main===1 && delTBYPASS[57]===1)?TBYPASS_D_Q[57] : WordX;
	assign QINTint[58] = (TBYPASS_main===0 && delTBYPASS[58]===0)?OutReg[58] : (TBYPASS_main===1 && delTBYPASS[58]===1)?TBYPASS_D_Q[58] : WordX;
	assign QINTint[59] = (TBYPASS_main===0 && delTBYPASS[59]===0)?OutReg[59] : (TBYPASS_main===1 && delTBYPASS[59]===1)?TBYPASS_D_Q[59] : WordX;
	assign QINTint[60] = (TBYPASS_main===0 && delTBYPASS[60]===0)?OutReg[60] : (TBYPASS_main===1 && delTBYPASS[60]===1)?TBYPASS_D_Q[60] : WordX;
	assign QINTint[61] = (TBYPASS_main===0 && delTBYPASS[61]===0)?OutReg[61] : (TBYPASS_main===1 && delTBYPASS[61]===1)?TBYPASS_D_Q[61] : WordX;
	assign QINTint[62] = (TBYPASS_main===0 && delTBYPASS[62]===0)?OutReg[62] : (TBYPASS_main===1 && delTBYPASS[62]===1)?TBYPASS_D_Q[62] : WordX;
	assign QINTint[63] = (TBYPASS_main===0 && delTBYPASS[63]===0)?OutReg[63] : (TBYPASS_main===1 && delTBYPASS[63]===1)?TBYPASS_D_Q[63] : WordX;

assign QINTERNAL = QINTERNALreg;

always @(TBYPASS_main)
begin
           
   if (TBYPASS_main === 0 || TBYPASS_main === X) 
      QINTERNALreg = WordX;
   
end


        
/*------------------ RY functionality -----------------*/
        output RYINT;
        input RY_rfCK, RY_rrCK, RY_frCK, ICRY;
        wire RYINTint;
        reg RYINTreg, RYRiseFlag;

        buf (RYINT, RYINTint);

assign RYINTint = RYINTreg;
        
initial
begin
  RYRiseFlag = 1'b0;
  RYINTreg = 1'b1;
end

always @(ICRY)
begin
   if($realtime == 0)
      RYINTreg = 1'b1;
   else
      RYINTreg = 1'bx;
end

always @(RY_rfCK)
if (ICRY !== 1)
begin
   RYINTreg = 0;
   RYRiseFlag=0;
end

always @(RY_rrCK)
if (ICRY !== 1 && $realtime != 0)
begin
   if (RYRiseFlag === 0)
   begin
      RYRiseFlag=1;
   end
   else
   begin
      RYINTreg = 1'b1;
      RYRiseFlag=0;
   end
end
always @(RY_frCK)
#0
if (ICRY !== 1 && $realtime != 0)
begin
   if (RYRiseFlag === 0)
   begin
      RYRiseFlag=1;
   end
   else
   begin
      RYINTreg = 1'b1;
      RYRiseFlag=0;
   end
end
/*------------------------------------------------ */

always @(Q_gCK)
begin
#0  //This has been used for removing races during hold time violations in MODELSIM simulator.
   lastQ_gCK = Q_gCKreg;
   Q_gCKreg <= Q_gCK;
   for (m = 0; m < Bits; m = m + 1)
   begin
     if (lastQ_gCK[m] !== Q_gCK[m])
     begin
       	lastQINTERNAL[m] = QINTERNALreg[m];
       	QINTERNALreg[m] = Q_glitch[m];
     end
   end
end

always @(Q_data)
begin
#0  //This has been used for removing races during hold time vilations in MODELSIM simulator.
   lastQ_data = Q_datareg;
   Q_datareg <= Q_data;
   for (n = 0; n < Bits; n = n + 1)
   begin
      if (lastQ_data[n] !== Q_data[n])
      begin
       	lastQINTERNAL[n] = QINTERNALreg[n];
       	QINTERNALreg[n] = Q_data[n];
      end
   end
end

always @(QINTERNAL)
begin
   for (d = 0; d < Bits; d = d + 1)
   begin
      if (OutReg[d] !== QINTERNAL[d])
          OutReg[d] = QINTERNAL[d];
   end
end



endmodule


module ST_SPHDL_160x64m8_bL (Q, RY, CK, CSN, TBYPASS, WEN,  A,  D, M   );
   

    parameter 
        Fault_file_name = "ST_SPHDL_160x64m8_bL_faults.txt",   
        ConfigFault = 0,
        max_faults = 20,
        MEM_INITIALIZE = 1'b0,
        BinaryInit     = 1'b0,
        InitFileName   = "ST_SPHDL_160x64m8_bL.cde",     
        Corruption_Read_Violation = 1,
        Debug_mode = "ALL_WARNING_MODE",
        InstancePath = "ST_SPHDL_160x64m8_bL";

    parameter
        Words = 160,
        Bits = 64,
        Addr = 8,
        mux = 8,
        Rows = Words/mux;
        






    parameter
        WordX = 64'bx,
        AddrX = 8'bx,
        X = 1'bx;


    output [Bits-1 : 0] Q;
    
    output RY;   
    input CK;
    input CSN;
    input WEN;
    input TBYPASS;
    input [Addr-1 : 0] A;
    input [Bits-1 : 0] D;
    
    input [Bits-1 : 0] M;
    





   
   wire [Bits-1 : 0] Q_glitchint;
   wire [Bits-1 : 0] Q_dataint;
   wire [Bits-1 : 0] Dint,Mint;
   wire [Addr-1 : 0] Aint;
   wire [Bits-1 : 0] Q_gCKint;
   wire CKint;
   wire CSNint;
   wire WENint;
   wire TBYPASSint;
   wire TBYPASS_mainint;
   wire [Bits-1 : 0]  TBYPASS_D_Qint;
   wire [Bits-1 : 0]  delTBYPASSint;






   
   wire [Bits-1 : 0] Qint, Q_out;
   wire CS_taa = !CSNint;
   wire csn_tcycle = !CSNint;
   wire csn_tcycle_DEBUG, csn_tcycle_DEBUGN;
   reg [Bits-1 : 0] Dreg,Mreg;
   reg [Addr-1 : 0] Areg;
   reg CKreg;
   reg CSNreg;
   reg WENreg;
	
   reg [Bits-1 : 0] TimingViol2, TimingViol3, TimingViol12, TimingViol13;
   reg [Bits-1 : 0] TimingViol2_last, TimingViol3_last, TimingViol12_last, TimingViol13_last;
	reg TimingViol2_0, TimingViol3_0, TimingViol12_0, TimingViol13_0;
	reg TimingViol2_1, TimingViol3_1, TimingViol12_1, TimingViol13_1;
	reg TimingViol2_2, TimingViol3_2, TimingViol12_2, TimingViol13_2;
	reg TimingViol2_3, TimingViol3_3, TimingViol12_3, TimingViol13_3;
	reg TimingViol2_4, TimingViol3_4, TimingViol12_4, TimingViol13_4;
	reg TimingViol2_5, TimingViol3_5, TimingViol12_5, TimingViol13_5;
	reg TimingViol2_6, TimingViol3_6, TimingViol12_6, TimingViol13_6;
	reg TimingViol2_7, TimingViol3_7, TimingViol12_7, TimingViol13_7;
	reg TimingViol2_8, TimingViol3_8, TimingViol12_8, TimingViol13_8;
	reg TimingViol2_9, TimingViol3_9, TimingViol12_9, TimingViol13_9;
	reg TimingViol2_10, TimingViol3_10, TimingViol12_10, TimingViol13_10;
	reg TimingViol2_11, TimingViol3_11, TimingViol12_11, TimingViol13_11;
	reg TimingViol2_12, TimingViol3_12, TimingViol12_12, TimingViol13_12;
	reg TimingViol2_13, TimingViol3_13, TimingViol12_13, TimingViol13_13;
	reg TimingViol2_14, TimingViol3_14, TimingViol12_14, TimingViol13_14;
	reg TimingViol2_15, TimingViol3_15, TimingViol12_15, TimingViol13_15;
	reg TimingViol2_16, TimingViol3_16, TimingViol12_16, TimingViol13_16;
	reg TimingViol2_17, TimingViol3_17, TimingViol12_17, TimingViol13_17;
	reg TimingViol2_18, TimingViol3_18, TimingViol12_18, TimingViol13_18;
	reg TimingViol2_19, TimingViol3_19, TimingViol12_19, TimingViol13_19;
	reg TimingViol2_20, TimingViol3_20, TimingViol12_20, TimingViol13_20;
	reg TimingViol2_21, TimingViol3_21, TimingViol12_21, TimingViol13_21;
	reg TimingViol2_22, TimingViol3_22, TimingViol12_22, TimingViol13_22;
	reg TimingViol2_23, TimingViol3_23, TimingViol12_23, TimingViol13_23;
	reg TimingViol2_24, TimingViol3_24, TimingViol12_24, TimingViol13_24;
	reg TimingViol2_25, TimingViol3_25, TimingViol12_25, TimingViol13_25;
	reg TimingViol2_26, TimingViol3_26, TimingViol12_26, TimingViol13_26;
	reg TimingViol2_27, TimingViol3_27, TimingViol12_27, TimingViol13_27;
	reg TimingViol2_28, TimingViol3_28, TimingViol12_28, TimingViol13_28;
	reg TimingViol2_29, TimingViol3_29, TimingViol12_29, TimingViol13_29;
	reg TimingViol2_30, TimingViol3_30, TimingViol12_30, TimingViol13_30;
	reg TimingViol2_31, TimingViol3_31, TimingViol12_31, TimingViol13_31;
	reg TimingViol2_32, TimingViol3_32, TimingViol12_32, TimingViol13_32;
	reg TimingViol2_33, TimingViol3_33, TimingViol12_33, TimingViol13_33;
	reg TimingViol2_34, TimingViol3_34, TimingViol12_34, TimingViol13_34;
	reg TimingViol2_35, TimingViol3_35, TimingViol12_35, TimingViol13_35;
	reg TimingViol2_36, TimingViol3_36, TimingViol12_36, TimingViol13_36;
	reg TimingViol2_37, TimingViol3_37, TimingViol12_37, TimingViol13_37;
	reg TimingViol2_38, TimingViol3_38, TimingViol12_38, TimingViol13_38;
	reg TimingViol2_39, TimingViol3_39, TimingViol12_39, TimingViol13_39;
	reg TimingViol2_40, TimingViol3_40, TimingViol12_40, TimingViol13_40;
	reg TimingViol2_41, TimingViol3_41, TimingViol12_41, TimingViol13_41;
	reg TimingViol2_42, TimingViol3_42, TimingViol12_42, TimingViol13_42;
	reg TimingViol2_43, TimingViol3_43, TimingViol12_43, TimingViol13_43;
	reg TimingViol2_44, TimingViol3_44, TimingViol12_44, TimingViol13_44;
	reg TimingViol2_45, TimingViol3_45, TimingViol12_45, TimingViol13_45;
	reg TimingViol2_46, TimingViol3_46, TimingViol12_46, TimingViol13_46;
	reg TimingViol2_47, TimingViol3_47, TimingViol12_47, TimingViol13_47;
	reg TimingViol2_48, TimingViol3_48, TimingViol12_48, TimingViol13_48;
	reg TimingViol2_49, TimingViol3_49, TimingViol12_49, TimingViol13_49;
	reg TimingViol2_50, TimingViol3_50, TimingViol12_50, TimingViol13_50;
	reg TimingViol2_51, TimingViol3_51, TimingViol12_51, TimingViol13_51;
	reg TimingViol2_52, TimingViol3_52, TimingViol12_52, TimingViol13_52;
	reg TimingViol2_53, TimingViol3_53, TimingViol12_53, TimingViol13_53;
	reg TimingViol2_54, TimingViol3_54, TimingViol12_54, TimingViol13_54;
	reg TimingViol2_55, TimingViol3_55, TimingViol12_55, TimingViol13_55;
	reg TimingViol2_56, TimingViol3_56, TimingViol12_56, TimingViol13_56;
	reg TimingViol2_57, TimingViol3_57, TimingViol12_57, TimingViol13_57;
	reg TimingViol2_58, TimingViol3_58, TimingViol12_58, TimingViol13_58;
	reg TimingViol2_59, TimingViol3_59, TimingViol12_59, TimingViol13_59;
	reg TimingViol2_60, TimingViol3_60, TimingViol12_60, TimingViol13_60;
	reg TimingViol2_61, TimingViol3_61, TimingViol12_61, TimingViol13_61;
	reg TimingViol2_62, TimingViol3_62, TimingViol12_62, TimingViol13_62;
	reg TimingViol2_63, TimingViol3_63, TimingViol12_63, TimingViol13_63;
   reg TimingViol0, TimingViol1;
   reg TimingViol4, TimingViol5, TimingViol6, TimingViol7, TimingViol_ttms_ttmh;
   reg TimingViol8, TimingViol9, TimingViol10, TimingViol10_taa;








   wire [Bits-1 : 0] MEN,CSWEMTBYPASS;
   wire CSTBYPASSN, CSWETBYPASSN;
   wire csn_tckl;
   wire csn_tckl_ry;
   wire csn_tckh;

   reg tckh_flag;
   reg tckl_flag;

   wire CS_taa_ry = !CSNint;
   
/* This register is used to force all warning messages 
** OFF during run time.
** 
*/ 
   reg [1:0] debug_level;
   reg [8*10: 0] operating_mode;
   reg [8*44: 0] message_status;





initial
begin
  debug_level = 2'b0;
  message_status = "All Messages are Switched ON";
  `ifdef  NO_WARNING_MODE
     debug_level = 2'b10;
    message_status = "All Messages are Switched OFF"; 
  `endif 
if(debug_level !== 2'b10) begin
  $display ("%m  INFORMATION");
   $display ("***************************************");
   $display ("The Model is Operating in TIMING MODE");
   $display ("Please make sure that SDF is properly annotated otherwise dummy values will be used");
   $display ("%s", message_status);
   $display ("***************************************");
   if(ConfigFault)
  $display ("Configurable Fault Functionality is ON");   
  else
  $display ("Configurable Fault Functionality is OFF"); 
  
  $display ("***************************************");
end     
end     

   buf (CKint, CK);

   //MEM_EN = CSN or  TBYPASS
   or (CSNint, CSN, TBYPASS  );

   buf (TBYPASSint, TBYPASS);
   buf (WENint, WEN);
   buf bufDint [Bits-1:0] (Dint, D);
   
   buf bufMint [Bits-1:0] (Mint, M);
   
   buf bufAint [Addr-1:0] (Aint, A);






   
     buf bufqint [Bits-1:0] (Q,Qint); 





	reg TimingViol9_tck_ry, TimingViol10_taa_ry;
        wire  RYint, RY_rfCKint, RY_rrCKint, RY_frCKint, RY_out;
        reg RY_outreg; 
        assign RY_out = RY_outreg;
  
     
       buf (RY, RY_out);  
       
        always @(RYint)
        begin
        RY_outreg = RYint;
        end

        
   // Only include timing checks during behavioural modelling



not (CS, CSN);    


    not (TBYPASSN, TBYPASS);
    not (WE, WEN);

    and (CSWE, CS, WE);
    and (CSWETBYPASSN, CSWE, TBYPASSN);
    and (CSTBYPASSN, CS, TBYPASSN);
    and (CSWEN, CS, WEN);
 
    assign csn_tckh = tckh_flag;
    assign csn_tckl = tckl_flag;
    assign csn_tckl_ry = tckl_flag;


        
 not (MEN[0], Mint[0]);
 not (MEN[1], Mint[1]);
 not (MEN[2], Mint[2]);
 not (MEN[3], Mint[3]);
 not (MEN[4], Mint[4]);
 not (MEN[5], Mint[5]);
 not (MEN[6], Mint[6]);
 not (MEN[7], Mint[7]);
 not (MEN[8], Mint[8]);
 not (MEN[9], Mint[9]);
 not (MEN[10], Mint[10]);
 not (MEN[11], Mint[11]);
 not (MEN[12], Mint[12]);
 not (MEN[13], Mint[13]);
 not (MEN[14], Mint[14]);
 not (MEN[15], Mint[15]);
 not (MEN[16], Mint[16]);
 not (MEN[17], Mint[17]);
 not (MEN[18], Mint[18]);
 not (MEN[19], Mint[19]);
 not (MEN[20], Mint[20]);
 not (MEN[21], Mint[21]);
 not (MEN[22], Mint[22]);
 not (MEN[23], Mint[23]);
 not (MEN[24], Mint[24]);
 not (MEN[25], Mint[25]);
 not (MEN[26], Mint[26]);
 not (MEN[27], Mint[27]);
 not (MEN[28], Mint[28]);
 not (MEN[29], Mint[29]);
 not (MEN[30], Mint[30]);
 not (MEN[31], Mint[31]);
 not (MEN[32], Mint[32]);
 not (MEN[33], Mint[33]);
 not (MEN[34], Mint[34]);
 not (MEN[35], Mint[35]);
 not (MEN[36], Mint[36]);
 not (MEN[37], Mint[37]);
 not (MEN[38], Mint[38]);
 not (MEN[39], Mint[39]);
 not (MEN[40], Mint[40]);
 not (MEN[41], Mint[41]);
 not (MEN[42], Mint[42]);
 not (MEN[43], Mint[43]);
 not (MEN[44], Mint[44]);
 not (MEN[45], Mint[45]);
 not (MEN[46], Mint[46]);
 not (MEN[47], Mint[47]);
 not (MEN[48], Mint[48]);
 not (MEN[49], Mint[49]);
 not (MEN[50], Mint[50]);
 not (MEN[51], Mint[51]);
 not (MEN[52], Mint[52]);
 not (MEN[53], Mint[53]);
 not (MEN[54], Mint[54]);
 not (MEN[55], Mint[55]);
 not (MEN[56], Mint[56]);
 not (MEN[57], Mint[57]);
 not (MEN[58], Mint[58]);
 not (MEN[59], Mint[59]);
 not (MEN[60], Mint[60]);
 not (MEN[61], Mint[61]);
 not (MEN[62], Mint[62]);
 not (MEN[63], Mint[63]);
 and (CSWEMTBYPASS[0], MEN[0], CSWETBYPASSN);
 and (CSWEMTBYPASS[1], MEN[1], CSWETBYPASSN);
 and (CSWEMTBYPASS[2], MEN[2], CSWETBYPASSN);
 and (CSWEMTBYPASS[3], MEN[3], CSWETBYPASSN);
 and (CSWEMTBYPASS[4], MEN[4], CSWETBYPASSN);
 and (CSWEMTBYPASS[5], MEN[5], CSWETBYPASSN);
 and (CSWEMTBYPASS[6], MEN[6], CSWETBYPASSN);
 and (CSWEMTBYPASS[7], MEN[7], CSWETBYPASSN);
 and (CSWEMTBYPASS[8], MEN[8], CSWETBYPASSN);
 and (CSWEMTBYPASS[9], MEN[9], CSWETBYPASSN);
 and (CSWEMTBYPASS[10], MEN[10], CSWETBYPASSN);
 and (CSWEMTBYPASS[11], MEN[11], CSWETBYPASSN);
 and (CSWEMTBYPASS[12], MEN[12], CSWETBYPASSN);
 and (CSWEMTBYPASS[13], MEN[13], CSWETBYPASSN);
 and (CSWEMTBYPASS[14], MEN[14], CSWETBYPASSN);
 and (CSWEMTBYPASS[15], MEN[15], CSWETBYPASSN);
 and (CSWEMTBYPASS[16], MEN[16], CSWETBYPASSN);
 and (CSWEMTBYPASS[17], MEN[17], CSWETBYPASSN);
 and (CSWEMTBYPASS[18], MEN[18], CSWETBYPASSN);
 and (CSWEMTBYPASS[19], MEN[19], CSWETBYPASSN);
 and (CSWEMTBYPASS[20], MEN[20], CSWETBYPASSN);
 and (CSWEMTBYPASS[21], MEN[21], CSWETBYPASSN);
 and (CSWEMTBYPASS[22], MEN[22], CSWETBYPASSN);
 and (CSWEMTBYPASS[23], MEN[23], CSWETBYPASSN);
 and (CSWEMTBYPASS[24], MEN[24], CSWETBYPASSN);
 and (CSWEMTBYPASS[25], MEN[25], CSWETBYPASSN);
 and (CSWEMTBYPASS[26], MEN[26], CSWETBYPASSN);
 and (CSWEMTBYPASS[27], MEN[27], CSWETBYPASSN);
 and (CSWEMTBYPASS[28], MEN[28], CSWETBYPASSN);
 and (CSWEMTBYPASS[29], MEN[29], CSWETBYPASSN);
 and (CSWEMTBYPASS[30], MEN[30], CSWETBYPASSN);
 and (CSWEMTBYPASS[31], MEN[31], CSWETBYPASSN);
 and (CSWEMTBYPASS[32], MEN[32], CSWETBYPASSN);
 and (CSWEMTBYPASS[33], MEN[33], CSWETBYPASSN);
 and (CSWEMTBYPASS[34], MEN[34], CSWETBYPASSN);
 and (CSWEMTBYPASS[35], MEN[35], CSWETBYPASSN);
 and (CSWEMTBYPASS[36], MEN[36], CSWETBYPASSN);
 and (CSWEMTBYPASS[37], MEN[37], CSWETBYPASSN);
 and (CSWEMTBYPASS[38], MEN[38], CSWETBYPASSN);
 and (CSWEMTBYPASS[39], MEN[39], CSWETBYPASSN);
 and (CSWEMTBYPASS[40], MEN[40], CSWETBYPASSN);
 and (CSWEMTBYPASS[41], MEN[41], CSWETBYPASSN);
 and (CSWEMTBYPASS[42], MEN[42], CSWETBYPASSN);
 and (CSWEMTBYPASS[43], MEN[43], CSWETBYPASSN);
 and (CSWEMTBYPASS[44], MEN[44], CSWETBYPASSN);
 and (CSWEMTBYPASS[45], MEN[45], CSWETBYPASSN);
 and (CSWEMTBYPASS[46], MEN[46], CSWETBYPASSN);
 and (CSWEMTBYPASS[47], MEN[47], CSWETBYPASSN);
 and (CSWEMTBYPASS[48], MEN[48], CSWETBYPASSN);
 and (CSWEMTBYPASS[49], MEN[49], CSWETBYPASSN);
 and (CSWEMTBYPASS[50], MEN[50], CSWETBYPASSN);
 and (CSWEMTBYPASS[51], MEN[51], CSWETBYPASSN);
 and (CSWEMTBYPASS[52], MEN[52], CSWETBYPASSN);
 and (CSWEMTBYPASS[53], MEN[53], CSWETBYPASSN);
 and (CSWEMTBYPASS[54], MEN[54], CSWETBYPASSN);
 and (CSWEMTBYPASS[55], MEN[55], CSWETBYPASSN);
 and (CSWEMTBYPASS[56], MEN[56], CSWETBYPASSN);
 and (CSWEMTBYPASS[57], MEN[57], CSWETBYPASSN);
 and (CSWEMTBYPASS[58], MEN[58], CSWETBYPASSN);
 and (CSWEMTBYPASS[59], MEN[59], CSWETBYPASSN);
 and (CSWEMTBYPASS[60], MEN[60], CSWETBYPASSN);
 and (CSWEMTBYPASS[61], MEN[61], CSWETBYPASSN);
 and (CSWEMTBYPASS[62], MEN[62], CSWETBYPASSN);
 and (CSWEMTBYPASS[63], MEN[63], CSWETBYPASSN);

   specify
      specparam



         tckl_tck_ry = 0.00,
         tcycle_taa_ry = 0.00,

 
         
	 tms = 0.0,
         tmh = 0.0,
         tcycle = 0.0,
         tcycle_taa = 0.0,
         tckh = 0.0,
         tckl = 0.0,
         ttms = 0.0,
         ttmh = 0.0,
         tps = 0.0,
         tph = 0.0,
         tws = 0.0,
         twh = 0.0,
         tas = 0.0,
         tah = 0.0,
         tds = 0.0,
         tdh = 0.0;
        /*---------------------- Timing Checks ---------------------*/

	$setup(posedge A[0], posedge CK &&& CSTBYPASSN, tas, TimingViol0);
	$setup(posedge A[1], posedge CK &&& CSTBYPASSN, tas, TimingViol0);
	$setup(posedge A[2], posedge CK &&& CSTBYPASSN, tas, TimingViol0);
	$setup(posedge A[3], posedge CK &&& CSTBYPASSN, tas, TimingViol0);
	$setup(posedge A[4], posedge CK &&& CSTBYPASSN, tas, TimingViol0);
	$setup(posedge A[5], posedge CK &&& CSTBYPASSN, tas, TimingViol0);
	$setup(posedge A[6], posedge CK &&& CSTBYPASSN, tas, TimingViol0);
	$setup(posedge A[7], posedge CK &&& CSTBYPASSN, tas, TimingViol0);
	$setup(negedge A[0], posedge CK &&& CSTBYPASSN, tas, TimingViol0);
	$setup(negedge A[1], posedge CK &&& CSTBYPASSN, tas, TimingViol0);
	$setup(negedge A[2], posedge CK &&& CSTBYPASSN, tas, TimingViol0);
	$setup(negedge A[3], posedge CK &&& CSTBYPASSN, tas, TimingViol0);
	$setup(negedge A[4], posedge CK &&& CSTBYPASSN, tas, TimingViol0);
	$setup(negedge A[5], posedge CK &&& CSTBYPASSN, tas, TimingViol0);
	$setup(negedge A[6], posedge CK &&& CSTBYPASSN, tas, TimingViol0);
	$setup(negedge A[7], posedge CK &&& CSTBYPASSN, tas, TimingViol0);
	$hold(posedge CK &&& CSTBYPASSN, posedge A[0], tah, TimingViol1);
	$hold(posedge CK &&& CSTBYPASSN, posedge A[1], tah, TimingViol1);
	$hold(posedge CK &&& CSTBYPASSN, posedge A[2], tah, TimingViol1);
	$hold(posedge CK &&& CSTBYPASSN, posedge A[3], tah, TimingViol1);
	$hold(posedge CK &&& CSTBYPASSN, posedge A[4], tah, TimingViol1);
	$hold(posedge CK &&& CSTBYPASSN, posedge A[5], tah, TimingViol1);
	$hold(posedge CK &&& CSTBYPASSN, posedge A[6], tah, TimingViol1);
	$hold(posedge CK &&& CSTBYPASSN, posedge A[7], tah, TimingViol1);
	$hold(posedge CK &&& CSTBYPASSN, negedge A[0], tah, TimingViol1);
	$hold(posedge CK &&& CSTBYPASSN, negedge A[1], tah, TimingViol1);
	$hold(posedge CK &&& CSTBYPASSN, negedge A[2], tah, TimingViol1);
	$hold(posedge CK &&& CSTBYPASSN, negedge A[3], tah, TimingViol1);
	$hold(posedge CK &&& CSTBYPASSN, negedge A[4], tah, TimingViol1);
	$hold(posedge CK &&& CSTBYPASSN, negedge A[5], tah, TimingViol1);
	$hold(posedge CK &&& CSTBYPASSN, negedge A[6], tah, TimingViol1);
	$hold(posedge CK &&& CSTBYPASSN, negedge A[7], tah, TimingViol1);
	$setup(posedge D[0], posedge CK &&& (CSWEMTBYPASS[0] != 0), tds, TimingViol2_0);
	$setup(posedge D[1], posedge CK &&& (CSWEMTBYPASS[1] != 0), tds, TimingViol2_1);
	$setup(posedge D[2], posedge CK &&& (CSWEMTBYPASS[2] != 0), tds, TimingViol2_2);
	$setup(posedge D[3], posedge CK &&& (CSWEMTBYPASS[3] != 0), tds, TimingViol2_3);
	$setup(posedge D[4], posedge CK &&& (CSWEMTBYPASS[4] != 0), tds, TimingViol2_4);
	$setup(posedge D[5], posedge CK &&& (CSWEMTBYPASS[5] != 0), tds, TimingViol2_5);
	$setup(posedge D[6], posedge CK &&& (CSWEMTBYPASS[6] != 0), tds, TimingViol2_6);
	$setup(posedge D[7], posedge CK &&& (CSWEMTBYPASS[7] != 0), tds, TimingViol2_7);
	$setup(posedge D[8], posedge CK &&& (CSWEMTBYPASS[8] != 0), tds, TimingViol2_8);
	$setup(posedge D[9], posedge CK &&& (CSWEMTBYPASS[9] != 0), tds, TimingViol2_9);
	$setup(posedge D[10], posedge CK &&& (CSWEMTBYPASS[10] != 0), tds, TimingViol2_10);
	$setup(posedge D[11], posedge CK &&& (CSWEMTBYPASS[11] != 0), tds, TimingViol2_11);
	$setup(posedge D[12], posedge CK &&& (CSWEMTBYPASS[12] != 0), tds, TimingViol2_12);
	$setup(posedge D[13], posedge CK &&& (CSWEMTBYPASS[13] != 0), tds, TimingViol2_13);
	$setup(posedge D[14], posedge CK &&& (CSWEMTBYPASS[14] != 0), tds, TimingViol2_14);
	$setup(posedge D[15], posedge CK &&& (CSWEMTBYPASS[15] != 0), tds, TimingViol2_15);
	$setup(posedge D[16], posedge CK &&& (CSWEMTBYPASS[16] != 0), tds, TimingViol2_16);
	$setup(posedge D[17], posedge CK &&& (CSWEMTBYPASS[17] != 0), tds, TimingViol2_17);
	$setup(posedge D[18], posedge CK &&& (CSWEMTBYPASS[18] != 0), tds, TimingViol2_18);
	$setup(posedge D[19], posedge CK &&& (CSWEMTBYPASS[19] != 0), tds, TimingViol2_19);
	$setup(posedge D[20], posedge CK &&& (CSWEMTBYPASS[20] != 0), tds, TimingViol2_20);
	$setup(posedge D[21], posedge CK &&& (CSWEMTBYPASS[21] != 0), tds, TimingViol2_21);
	$setup(posedge D[22], posedge CK &&& (CSWEMTBYPASS[22] != 0), tds, TimingViol2_22);
	$setup(posedge D[23], posedge CK &&& (CSWEMTBYPASS[23] != 0), tds, TimingViol2_23);
	$setup(posedge D[24], posedge CK &&& (CSWEMTBYPASS[24] != 0), tds, TimingViol2_24);
	$setup(posedge D[25], posedge CK &&& (CSWEMTBYPASS[25] != 0), tds, TimingViol2_25);
	$setup(posedge D[26], posedge CK &&& (CSWEMTBYPASS[26] != 0), tds, TimingViol2_26);
	$setup(posedge D[27], posedge CK &&& (CSWEMTBYPASS[27] != 0), tds, TimingViol2_27);
	$setup(posedge D[28], posedge CK &&& (CSWEMTBYPASS[28] != 0), tds, TimingViol2_28);
	$setup(posedge D[29], posedge CK &&& (CSWEMTBYPASS[29] != 0), tds, TimingViol2_29);
	$setup(posedge D[30], posedge CK &&& (CSWEMTBYPASS[30] != 0), tds, TimingViol2_30);
	$setup(posedge D[31], posedge CK &&& (CSWEMTBYPASS[31] != 0), tds, TimingViol2_31);
	$setup(posedge D[32], posedge CK &&& (CSWEMTBYPASS[32] != 0), tds, TimingViol2_32);
	$setup(posedge D[33], posedge CK &&& (CSWEMTBYPASS[33] != 0), tds, TimingViol2_33);
	$setup(posedge D[34], posedge CK &&& (CSWEMTBYPASS[34] != 0), tds, TimingViol2_34);
	$setup(posedge D[35], posedge CK &&& (CSWEMTBYPASS[35] != 0), tds, TimingViol2_35);
	$setup(posedge D[36], posedge CK &&& (CSWEMTBYPASS[36] != 0), tds, TimingViol2_36);
	$setup(posedge D[37], posedge CK &&& (CSWEMTBYPASS[37] != 0), tds, TimingViol2_37);
	$setup(posedge D[38], posedge CK &&& (CSWEMTBYPASS[38] != 0), tds, TimingViol2_38);
	$setup(posedge D[39], posedge CK &&& (CSWEMTBYPASS[39] != 0), tds, TimingViol2_39);
	$setup(posedge D[40], posedge CK &&& (CSWEMTBYPASS[40] != 0), tds, TimingViol2_40);
	$setup(posedge D[41], posedge CK &&& (CSWEMTBYPASS[41] != 0), tds, TimingViol2_41);
	$setup(posedge D[42], posedge CK &&& (CSWEMTBYPASS[42] != 0), tds, TimingViol2_42);
	$setup(posedge D[43], posedge CK &&& (CSWEMTBYPASS[43] != 0), tds, TimingViol2_43);
	$setup(posedge D[44], posedge CK &&& (CSWEMTBYPASS[44] != 0), tds, TimingViol2_44);
	$setup(posedge D[45], posedge CK &&& (CSWEMTBYPASS[45] != 0), tds, TimingViol2_45);
	$setup(posedge D[46], posedge CK &&& (CSWEMTBYPASS[46] != 0), tds, TimingViol2_46);
	$setup(posedge D[47], posedge CK &&& (CSWEMTBYPASS[47] != 0), tds, TimingViol2_47);
	$setup(posedge D[48], posedge CK &&& (CSWEMTBYPASS[48] != 0), tds, TimingViol2_48);
	$setup(posedge D[49], posedge CK &&& (CSWEMTBYPASS[49] != 0), tds, TimingViol2_49);
	$setup(posedge D[50], posedge CK &&& (CSWEMTBYPASS[50] != 0), tds, TimingViol2_50);
	$setup(posedge D[51], posedge CK &&& (CSWEMTBYPASS[51] != 0), tds, TimingViol2_51);
	$setup(posedge D[52], posedge CK &&& (CSWEMTBYPASS[52] != 0), tds, TimingViol2_52);
	$setup(posedge D[53], posedge CK &&& (CSWEMTBYPASS[53] != 0), tds, TimingViol2_53);
	$setup(posedge D[54], posedge CK &&& (CSWEMTBYPASS[54] != 0), tds, TimingViol2_54);
	$setup(posedge D[55], posedge CK &&& (CSWEMTBYPASS[55] != 0), tds, TimingViol2_55);
	$setup(posedge D[56], posedge CK &&& (CSWEMTBYPASS[56] != 0), tds, TimingViol2_56);
	$setup(posedge D[57], posedge CK &&& (CSWEMTBYPASS[57] != 0), tds, TimingViol2_57);
	$setup(posedge D[58], posedge CK &&& (CSWEMTBYPASS[58] != 0), tds, TimingViol2_58);
	$setup(posedge D[59], posedge CK &&& (CSWEMTBYPASS[59] != 0), tds, TimingViol2_59);
	$setup(posedge D[60], posedge CK &&& (CSWEMTBYPASS[60] != 0), tds, TimingViol2_60);
	$setup(posedge D[61], posedge CK &&& (CSWEMTBYPASS[61] != 0), tds, TimingViol2_61);
	$setup(posedge D[62], posedge CK &&& (CSWEMTBYPASS[62] != 0), tds, TimingViol2_62);
	$setup(posedge D[63], posedge CK &&& (CSWEMTBYPASS[63] != 0), tds, TimingViol2_63);
	$setup(negedge D[0], posedge CK &&& (CSWEMTBYPASS[0] != 0), tds, TimingViol2_0);
	$setup(negedge D[1], posedge CK &&& (CSWEMTBYPASS[1] != 0), tds, TimingViol2_1);
	$setup(negedge D[2], posedge CK &&& (CSWEMTBYPASS[2] != 0), tds, TimingViol2_2);
	$setup(negedge D[3], posedge CK &&& (CSWEMTBYPASS[3] != 0), tds, TimingViol2_3);
	$setup(negedge D[4], posedge CK &&& (CSWEMTBYPASS[4] != 0), tds, TimingViol2_4);
	$setup(negedge D[5], posedge CK &&& (CSWEMTBYPASS[5] != 0), tds, TimingViol2_5);
	$setup(negedge D[6], posedge CK &&& (CSWEMTBYPASS[6] != 0), tds, TimingViol2_6);
	$setup(negedge D[7], posedge CK &&& (CSWEMTBYPASS[7] != 0), tds, TimingViol2_7);
	$setup(negedge D[8], posedge CK &&& (CSWEMTBYPASS[8] != 0), tds, TimingViol2_8);
	$setup(negedge D[9], posedge CK &&& (CSWEMTBYPASS[9] != 0), tds, TimingViol2_9);
	$setup(negedge D[10], posedge CK &&& (CSWEMTBYPASS[10] != 0), tds, TimingViol2_10);
	$setup(negedge D[11], posedge CK &&& (CSWEMTBYPASS[11] != 0), tds, TimingViol2_11);
	$setup(negedge D[12], posedge CK &&& (CSWEMTBYPASS[12] != 0), tds, TimingViol2_12);
	$setup(negedge D[13], posedge CK &&& (CSWEMTBYPASS[13] != 0), tds, TimingViol2_13);
	$setup(negedge D[14], posedge CK &&& (CSWEMTBYPASS[14] != 0), tds, TimingViol2_14);
	$setup(negedge D[15], posedge CK &&& (CSWEMTBYPASS[15] != 0), tds, TimingViol2_15);
	$setup(negedge D[16], posedge CK &&& (CSWEMTBYPASS[16] != 0), tds, TimingViol2_16);
	$setup(negedge D[17], posedge CK &&& (CSWEMTBYPASS[17] != 0), tds, TimingViol2_17);
	$setup(negedge D[18], posedge CK &&& (CSWEMTBYPASS[18] != 0), tds, TimingViol2_18);
	$setup(negedge D[19], posedge CK &&& (CSWEMTBYPASS[19] != 0), tds, TimingViol2_19);
	$setup(negedge D[20], posedge CK &&& (CSWEMTBYPASS[20] != 0), tds, TimingViol2_20);
	$setup(negedge D[21], posedge CK &&& (CSWEMTBYPASS[21] != 0), tds, TimingViol2_21);
	$setup(negedge D[22], posedge CK &&& (CSWEMTBYPASS[22] != 0), tds, TimingViol2_22);
	$setup(negedge D[23], posedge CK &&& (CSWEMTBYPASS[23] != 0), tds, TimingViol2_23);
	$setup(negedge D[24], posedge CK &&& (CSWEMTBYPASS[24] != 0), tds, TimingViol2_24);
	$setup(negedge D[25], posedge CK &&& (CSWEMTBYPASS[25] != 0), tds, TimingViol2_25);
	$setup(negedge D[26], posedge CK &&& (CSWEMTBYPASS[26] != 0), tds, TimingViol2_26);
	$setup(negedge D[27], posedge CK &&& (CSWEMTBYPASS[27] != 0), tds, TimingViol2_27);
	$setup(negedge D[28], posedge CK &&& (CSWEMTBYPASS[28] != 0), tds, TimingViol2_28);
	$setup(negedge D[29], posedge CK &&& (CSWEMTBYPASS[29] != 0), tds, TimingViol2_29);
	$setup(negedge D[30], posedge CK &&& (CSWEMTBYPASS[30] != 0), tds, TimingViol2_30);
	$setup(negedge D[31], posedge CK &&& (CSWEMTBYPASS[31] != 0), tds, TimingViol2_31);
	$setup(negedge D[32], posedge CK &&& (CSWEMTBYPASS[32] != 0), tds, TimingViol2_32);
	$setup(negedge D[33], posedge CK &&& (CSWEMTBYPASS[33] != 0), tds, TimingViol2_33);
	$setup(negedge D[34], posedge CK &&& (CSWEMTBYPASS[34] != 0), tds, TimingViol2_34);
	$setup(negedge D[35], posedge CK &&& (CSWEMTBYPASS[35] != 0), tds, TimingViol2_35);
	$setup(negedge D[36], posedge CK &&& (CSWEMTBYPASS[36] != 0), tds, TimingViol2_36);
	$setup(negedge D[37], posedge CK &&& (CSWEMTBYPASS[37] != 0), tds, TimingViol2_37);
	$setup(negedge D[38], posedge CK &&& (CSWEMTBYPASS[38] != 0), tds, TimingViol2_38);
	$setup(negedge D[39], posedge CK &&& (CSWEMTBYPASS[39] != 0), tds, TimingViol2_39);
	$setup(negedge D[40], posedge CK &&& (CSWEMTBYPASS[40] != 0), tds, TimingViol2_40);
	$setup(negedge D[41], posedge CK &&& (CSWEMTBYPASS[41] != 0), tds, TimingViol2_41);
	$setup(negedge D[42], posedge CK &&& (CSWEMTBYPASS[42] != 0), tds, TimingViol2_42);
	$setup(negedge D[43], posedge CK &&& (CSWEMTBYPASS[43] != 0), tds, TimingViol2_43);
	$setup(negedge D[44], posedge CK &&& (CSWEMTBYPASS[44] != 0), tds, TimingViol2_44);
	$setup(negedge D[45], posedge CK &&& (CSWEMTBYPASS[45] != 0), tds, TimingViol2_45);
	$setup(negedge D[46], posedge CK &&& (CSWEMTBYPASS[46] != 0), tds, TimingViol2_46);
	$setup(negedge D[47], posedge CK &&& (CSWEMTBYPASS[47] != 0), tds, TimingViol2_47);
	$setup(negedge D[48], posedge CK &&& (CSWEMTBYPASS[48] != 0), tds, TimingViol2_48);
	$setup(negedge D[49], posedge CK &&& (CSWEMTBYPASS[49] != 0), tds, TimingViol2_49);
	$setup(negedge D[50], posedge CK &&& (CSWEMTBYPASS[50] != 0), tds, TimingViol2_50);
	$setup(negedge D[51], posedge CK &&& (CSWEMTBYPASS[51] != 0), tds, TimingViol2_51);
	$setup(negedge D[52], posedge CK &&& (CSWEMTBYPASS[52] != 0), tds, TimingViol2_52);
	$setup(negedge D[53], posedge CK &&& (CSWEMTBYPASS[53] != 0), tds, TimingViol2_53);
	$setup(negedge D[54], posedge CK &&& (CSWEMTBYPASS[54] != 0), tds, TimingViol2_54);
	$setup(negedge D[55], posedge CK &&& (CSWEMTBYPASS[55] != 0), tds, TimingViol2_55);
	$setup(negedge D[56], posedge CK &&& (CSWEMTBYPASS[56] != 0), tds, TimingViol2_56);
	$setup(negedge D[57], posedge CK &&& (CSWEMTBYPASS[57] != 0), tds, TimingViol2_57);
	$setup(negedge D[58], posedge CK &&& (CSWEMTBYPASS[58] != 0), tds, TimingViol2_58);
	$setup(negedge D[59], posedge CK &&& (CSWEMTBYPASS[59] != 0), tds, TimingViol2_59);
	$setup(negedge D[60], posedge CK &&& (CSWEMTBYPASS[60] != 0), tds, TimingViol2_60);
	$setup(negedge D[61], posedge CK &&& (CSWEMTBYPASS[61] != 0), tds, TimingViol2_61);
	$setup(negedge D[62], posedge CK &&& (CSWEMTBYPASS[62] != 0), tds, TimingViol2_62);
	$setup(negedge D[63], posedge CK &&& (CSWEMTBYPASS[63] != 0), tds, TimingViol2_63);
	$hold(posedge CK &&& (CSWEMTBYPASS[0] != 0), posedge D[0], tdh, TimingViol3_0);
	$hold(posedge CK &&& (CSWEMTBYPASS[1] != 0), posedge D[1], tdh, TimingViol3_1);
	$hold(posedge CK &&& (CSWEMTBYPASS[2] != 0), posedge D[2], tdh, TimingViol3_2);
	$hold(posedge CK &&& (CSWEMTBYPASS[3] != 0), posedge D[3], tdh, TimingViol3_3);
	$hold(posedge CK &&& (CSWEMTBYPASS[4] != 0), posedge D[4], tdh, TimingViol3_4);
	$hold(posedge CK &&& (CSWEMTBYPASS[5] != 0), posedge D[5], tdh, TimingViol3_5);
	$hold(posedge CK &&& (CSWEMTBYPASS[6] != 0), posedge D[6], tdh, TimingViol3_6);
	$hold(posedge CK &&& (CSWEMTBYPASS[7] != 0), posedge D[7], tdh, TimingViol3_7);
	$hold(posedge CK &&& (CSWEMTBYPASS[8] != 0), posedge D[8], tdh, TimingViol3_8);
	$hold(posedge CK &&& (CSWEMTBYPASS[9] != 0), posedge D[9], tdh, TimingViol3_9);
	$hold(posedge CK &&& (CSWEMTBYPASS[10] != 0), posedge D[10], tdh, TimingViol3_10);
	$hold(posedge CK &&& (CSWEMTBYPASS[11] != 0), posedge D[11], tdh, TimingViol3_11);
	$hold(posedge CK &&& (CSWEMTBYPASS[12] != 0), posedge D[12], tdh, TimingViol3_12);
	$hold(posedge CK &&& (CSWEMTBYPASS[13] != 0), posedge D[13], tdh, TimingViol3_13);
	$hold(posedge CK &&& (CSWEMTBYPASS[14] != 0), posedge D[14], tdh, TimingViol3_14);
	$hold(posedge CK &&& (CSWEMTBYPASS[15] != 0), posedge D[15], tdh, TimingViol3_15);
	$hold(posedge CK &&& (CSWEMTBYPASS[16] != 0), posedge D[16], tdh, TimingViol3_16);
	$hold(posedge CK &&& (CSWEMTBYPASS[17] != 0), posedge D[17], tdh, TimingViol3_17);
	$hold(posedge CK &&& (CSWEMTBYPASS[18] != 0), posedge D[18], tdh, TimingViol3_18);
	$hold(posedge CK &&& (CSWEMTBYPASS[19] != 0), posedge D[19], tdh, TimingViol3_19);
	$hold(posedge CK &&& (CSWEMTBYPASS[20] != 0), posedge D[20], tdh, TimingViol3_20);
	$hold(posedge CK &&& (CSWEMTBYPASS[21] != 0), posedge D[21], tdh, TimingViol3_21);
	$hold(posedge CK &&& (CSWEMTBYPASS[22] != 0), posedge D[22], tdh, TimingViol3_22);
	$hold(posedge CK &&& (CSWEMTBYPASS[23] != 0), posedge D[23], tdh, TimingViol3_23);
	$hold(posedge CK &&& (CSWEMTBYPASS[24] != 0), posedge D[24], tdh, TimingViol3_24);
	$hold(posedge CK &&& (CSWEMTBYPASS[25] != 0), posedge D[25], tdh, TimingViol3_25);
	$hold(posedge CK &&& (CSWEMTBYPASS[26] != 0), posedge D[26], tdh, TimingViol3_26);
	$hold(posedge CK &&& (CSWEMTBYPASS[27] != 0), posedge D[27], tdh, TimingViol3_27);
	$hold(posedge CK &&& (CSWEMTBYPASS[28] != 0), posedge D[28], tdh, TimingViol3_28);
	$hold(posedge CK &&& (CSWEMTBYPASS[29] != 0), posedge D[29], tdh, TimingViol3_29);
	$hold(posedge CK &&& (CSWEMTBYPASS[30] != 0), posedge D[30], tdh, TimingViol3_30);
	$hold(posedge CK &&& (CSWEMTBYPASS[31] != 0), posedge D[31], tdh, TimingViol3_31);
	$hold(posedge CK &&& (CSWEMTBYPASS[32] != 0), posedge D[32], tdh, TimingViol3_32);
	$hold(posedge CK &&& (CSWEMTBYPASS[33] != 0), posedge D[33], tdh, TimingViol3_33);
	$hold(posedge CK &&& (CSWEMTBYPASS[34] != 0), posedge D[34], tdh, TimingViol3_34);
	$hold(posedge CK &&& (CSWEMTBYPASS[35] != 0), posedge D[35], tdh, TimingViol3_35);
	$hold(posedge CK &&& (CSWEMTBYPASS[36] != 0), posedge D[36], tdh, TimingViol3_36);
	$hold(posedge CK &&& (CSWEMTBYPASS[37] != 0), posedge D[37], tdh, TimingViol3_37);
	$hold(posedge CK &&& (CSWEMTBYPASS[38] != 0), posedge D[38], tdh, TimingViol3_38);
	$hold(posedge CK &&& (CSWEMTBYPASS[39] != 0), posedge D[39], tdh, TimingViol3_39);
	$hold(posedge CK &&& (CSWEMTBYPASS[40] != 0), posedge D[40], tdh, TimingViol3_40);
	$hold(posedge CK &&& (CSWEMTBYPASS[41] != 0), posedge D[41], tdh, TimingViol3_41);
	$hold(posedge CK &&& (CSWEMTBYPASS[42] != 0), posedge D[42], tdh, TimingViol3_42);
	$hold(posedge CK &&& (CSWEMTBYPASS[43] != 0), posedge D[43], tdh, TimingViol3_43);
	$hold(posedge CK &&& (CSWEMTBYPASS[44] != 0), posedge D[44], tdh, TimingViol3_44);
	$hold(posedge CK &&& (CSWEMTBYPASS[45] != 0), posedge D[45], tdh, TimingViol3_45);
	$hold(posedge CK &&& (CSWEMTBYPASS[46] != 0), posedge D[46], tdh, TimingViol3_46);
	$hold(posedge CK &&& (CSWEMTBYPASS[47] != 0), posedge D[47], tdh, TimingViol3_47);
	$hold(posedge CK &&& (CSWEMTBYPASS[48] != 0), posedge D[48], tdh, TimingViol3_48);
	$hold(posedge CK &&& (CSWEMTBYPASS[49] != 0), posedge D[49], tdh, TimingViol3_49);
	$hold(posedge CK &&& (CSWEMTBYPASS[50] != 0), posedge D[50], tdh, TimingViol3_50);
	$hold(posedge CK &&& (CSWEMTBYPASS[51] != 0), posedge D[51], tdh, TimingViol3_51);
	$hold(posedge CK &&& (CSWEMTBYPASS[52] != 0), posedge D[52], tdh, TimingViol3_52);
	$hold(posedge CK &&& (CSWEMTBYPASS[53] != 0), posedge D[53], tdh, TimingViol3_53);
	$hold(posedge CK &&& (CSWEMTBYPASS[54] != 0), posedge D[54], tdh, TimingViol3_54);
	$hold(posedge CK &&& (CSWEMTBYPASS[55] != 0), posedge D[55], tdh, TimingViol3_55);
	$hold(posedge CK &&& (CSWEMTBYPASS[56] != 0), posedge D[56], tdh, TimingViol3_56);
	$hold(posedge CK &&& (CSWEMTBYPASS[57] != 0), posedge D[57], tdh, TimingViol3_57);
	$hold(posedge CK &&& (CSWEMTBYPASS[58] != 0), posedge D[58], tdh, TimingViol3_58);
	$hold(posedge CK &&& (CSWEMTBYPASS[59] != 0), posedge D[59], tdh, TimingViol3_59);
	$hold(posedge CK &&& (CSWEMTBYPASS[60] != 0), posedge D[60], tdh, TimingViol3_60);
	$hold(posedge CK &&& (CSWEMTBYPASS[61] != 0), posedge D[61], tdh, TimingViol3_61);
	$hold(posedge CK &&& (CSWEMTBYPASS[62] != 0), posedge D[62], tdh, TimingViol3_62);
	$hold(posedge CK &&& (CSWEMTBYPASS[63] != 0), posedge D[63], tdh, TimingViol3_63);
	$hold(posedge CK &&& (CSWEMTBYPASS[0] != 0), negedge D[0], tdh, TimingViol3_0);
	$hold(posedge CK &&& (CSWEMTBYPASS[1] != 0), negedge D[1], tdh, TimingViol3_1);
	$hold(posedge CK &&& (CSWEMTBYPASS[2] != 0), negedge D[2], tdh, TimingViol3_2);
	$hold(posedge CK &&& (CSWEMTBYPASS[3] != 0), negedge D[3], tdh, TimingViol3_3);
	$hold(posedge CK &&& (CSWEMTBYPASS[4] != 0), negedge D[4], tdh, TimingViol3_4);
	$hold(posedge CK &&& (CSWEMTBYPASS[5] != 0), negedge D[5], tdh, TimingViol3_5);
	$hold(posedge CK &&& (CSWEMTBYPASS[6] != 0), negedge D[6], tdh, TimingViol3_6);
	$hold(posedge CK &&& (CSWEMTBYPASS[7] != 0), negedge D[7], tdh, TimingViol3_7);
	$hold(posedge CK &&& (CSWEMTBYPASS[8] != 0), negedge D[8], tdh, TimingViol3_8);
	$hold(posedge CK &&& (CSWEMTBYPASS[9] != 0), negedge D[9], tdh, TimingViol3_9);
	$hold(posedge CK &&& (CSWEMTBYPASS[10] != 0), negedge D[10], tdh, TimingViol3_10);
	$hold(posedge CK &&& (CSWEMTBYPASS[11] != 0), negedge D[11], tdh, TimingViol3_11);
	$hold(posedge CK &&& (CSWEMTBYPASS[12] != 0), negedge D[12], tdh, TimingViol3_12);
	$hold(posedge CK &&& (CSWEMTBYPASS[13] != 0), negedge D[13], tdh, TimingViol3_13);
	$hold(posedge CK &&& (CSWEMTBYPASS[14] != 0), negedge D[14], tdh, TimingViol3_14);
	$hold(posedge CK &&& (CSWEMTBYPASS[15] != 0), negedge D[15], tdh, TimingViol3_15);
	$hold(posedge CK &&& (CSWEMTBYPASS[16] != 0), negedge D[16], tdh, TimingViol3_16);
	$hold(posedge CK &&& (CSWEMTBYPASS[17] != 0), negedge D[17], tdh, TimingViol3_17);
	$hold(posedge CK &&& (CSWEMTBYPASS[18] != 0), negedge D[18], tdh, TimingViol3_18);
	$hold(posedge CK &&& (CSWEMTBYPASS[19] != 0), negedge D[19], tdh, TimingViol3_19);
	$hold(posedge CK &&& (CSWEMTBYPASS[20] != 0), negedge D[20], tdh, TimingViol3_20);
	$hold(posedge CK &&& (CSWEMTBYPASS[21] != 0), negedge D[21], tdh, TimingViol3_21);
	$hold(posedge CK &&& (CSWEMTBYPASS[22] != 0), negedge D[22], tdh, TimingViol3_22);
	$hold(posedge CK &&& (CSWEMTBYPASS[23] != 0), negedge D[23], tdh, TimingViol3_23);
	$hold(posedge CK &&& (CSWEMTBYPASS[24] != 0), negedge D[24], tdh, TimingViol3_24);
	$hold(posedge CK &&& (CSWEMTBYPASS[25] != 0), negedge D[25], tdh, TimingViol3_25);
	$hold(posedge CK &&& (CSWEMTBYPASS[26] != 0), negedge D[26], tdh, TimingViol3_26);
	$hold(posedge CK &&& (CSWEMTBYPASS[27] != 0), negedge D[27], tdh, TimingViol3_27);
	$hold(posedge CK &&& (CSWEMTBYPASS[28] != 0), negedge D[28], tdh, TimingViol3_28);
	$hold(posedge CK &&& (CSWEMTBYPASS[29] != 0), negedge D[29], tdh, TimingViol3_29);
	$hold(posedge CK &&& (CSWEMTBYPASS[30] != 0), negedge D[30], tdh, TimingViol3_30);
	$hold(posedge CK &&& (CSWEMTBYPASS[31] != 0), negedge D[31], tdh, TimingViol3_31);
	$hold(posedge CK &&& (CSWEMTBYPASS[32] != 0), negedge D[32], tdh, TimingViol3_32);
	$hold(posedge CK &&& (CSWEMTBYPASS[33] != 0), negedge D[33], tdh, TimingViol3_33);
	$hold(posedge CK &&& (CSWEMTBYPASS[34] != 0), negedge D[34], tdh, TimingViol3_34);
	$hold(posedge CK &&& (CSWEMTBYPASS[35] != 0), negedge D[35], tdh, TimingViol3_35);
	$hold(posedge CK &&& (CSWEMTBYPASS[36] != 0), negedge D[36], tdh, TimingViol3_36);
	$hold(posedge CK &&& (CSWEMTBYPASS[37] != 0), negedge D[37], tdh, TimingViol3_37);
	$hold(posedge CK &&& (CSWEMTBYPASS[38] != 0), negedge D[38], tdh, TimingViol3_38);
	$hold(posedge CK &&& (CSWEMTBYPASS[39] != 0), negedge D[39], tdh, TimingViol3_39);
	$hold(posedge CK &&& (CSWEMTBYPASS[40] != 0), negedge D[40], tdh, TimingViol3_40);
	$hold(posedge CK &&& (CSWEMTBYPASS[41] != 0), negedge D[41], tdh, TimingViol3_41);
	$hold(posedge CK &&& (CSWEMTBYPASS[42] != 0), negedge D[42], tdh, TimingViol3_42);
	$hold(posedge CK &&& (CSWEMTBYPASS[43] != 0), negedge D[43], tdh, TimingViol3_43);
	$hold(posedge CK &&& (CSWEMTBYPASS[44] != 0), negedge D[44], tdh, TimingViol3_44);
	$hold(posedge CK &&& (CSWEMTBYPASS[45] != 0), negedge D[45], tdh, TimingViol3_45);
	$hold(posedge CK &&& (CSWEMTBYPASS[46] != 0), negedge D[46], tdh, TimingViol3_46);
	$hold(posedge CK &&& (CSWEMTBYPASS[47] != 0), negedge D[47], tdh, TimingViol3_47);
	$hold(posedge CK &&& (CSWEMTBYPASS[48] != 0), negedge D[48], tdh, TimingViol3_48);
	$hold(posedge CK &&& (CSWEMTBYPASS[49] != 0), negedge D[49], tdh, TimingViol3_49);
	$hold(posedge CK &&& (CSWEMTBYPASS[50] != 0), negedge D[50], tdh, TimingViol3_50);
	$hold(posedge CK &&& (CSWEMTBYPASS[51] != 0), negedge D[51], tdh, TimingViol3_51);
	$hold(posedge CK &&& (CSWEMTBYPASS[52] != 0), negedge D[52], tdh, TimingViol3_52);
	$hold(posedge CK &&& (CSWEMTBYPASS[53] != 0), negedge D[53], tdh, TimingViol3_53);
	$hold(posedge CK &&& (CSWEMTBYPASS[54] != 0), negedge D[54], tdh, TimingViol3_54);
	$hold(posedge CK &&& (CSWEMTBYPASS[55] != 0), negedge D[55], tdh, TimingViol3_55);
	$hold(posedge CK &&& (CSWEMTBYPASS[56] != 0), negedge D[56], tdh, TimingViol3_56);
	$hold(posedge CK &&& (CSWEMTBYPASS[57] != 0), negedge D[57], tdh, TimingViol3_57);
	$hold(posedge CK &&& (CSWEMTBYPASS[58] != 0), negedge D[58], tdh, TimingViol3_58);
	$hold(posedge CK &&& (CSWEMTBYPASS[59] != 0), negedge D[59], tdh, TimingViol3_59);
	$hold(posedge CK &&& (CSWEMTBYPASS[60] != 0), negedge D[60], tdh, TimingViol3_60);
	$hold(posedge CK &&& (CSWEMTBYPASS[61] != 0), negedge D[61], tdh, TimingViol3_61);
	$hold(posedge CK &&& (CSWEMTBYPASS[62] != 0), negedge D[62], tdh, TimingViol3_62);
	$hold(posedge CK &&& (CSWEMTBYPASS[63] != 0), negedge D[63], tdh, TimingViol3_63);

	$setup(posedge M[0], edge[01,0x,x1,1x] CK &&& (CSWETBYPASSN != 'b0), tms, TimingViol12_0);
	$setup(posedge M[1], edge[01,0x,x1,1x] CK &&& (CSWETBYPASSN != 'b0), tms, TimingViol12_1);
	$setup(posedge M[2], edge[01,0x,x1,1x] CK &&& (CSWETBYPASSN != 'b0), tms, TimingViol12_2);
	$setup(posedge M[3], edge[01,0x,x1,1x] CK &&& (CSWETBYPASSN != 'b0), tms, TimingViol12_3);
	$setup(posedge M[4], edge[01,0x,x1,1x] CK &&& (CSWETBYPASSN != 'b0), tms, TimingViol12_4);
	$setup(posedge M[5], edge[01,0x,x1,1x] CK &&& (CSWETBYPASSN != 'b0), tms, TimingViol12_5);
	$setup(posedge M[6], edge[01,0x,x1,1x] CK &&& (CSWETBYPASSN != 'b0), tms, TimingViol12_6);
	$setup(posedge M[7], edge[01,0x,x1,1x] CK &&& (CSWETBYPASSN != 'b0), tms, TimingViol12_7);
	$setup(posedge M[8], edge[01,0x,x1,1x] CK &&& (CSWETBYPASSN != 'b0), tms, TimingViol12_8);
	$setup(posedge M[9], edge[01,0x,x1,1x] CK &&& (CSWETBYPASSN != 'b0), tms, TimingViol12_9);
	$setup(posedge M[10], edge[01,0x,x1,1x] CK &&& (CSWETBYPASSN != 'b0), tms, TimingViol12_10);
	$setup(posedge M[11], edge[01,0x,x1,1x] CK &&& (CSWETBYPASSN != 'b0), tms, TimingViol12_11);
	$setup(posedge M[12], edge[01,0x,x1,1x] CK &&& (CSWETBYPASSN != 'b0), tms, TimingViol12_12);
	$setup(posedge M[13], edge[01,0x,x1,1x] CK &&& (CSWETBYPASSN != 'b0), tms, TimingViol12_13);
	$setup(posedge M[14], edge[01,0x,x1,1x] CK &&& (CSWETBYPASSN != 'b0), tms, TimingViol12_14);
	$setup(posedge M[15], edge[01,0x,x1,1x] CK &&& (CSWETBYPASSN != 'b0), tms, TimingViol12_15);
	$setup(posedge M[16], edge[01,0x,x1,1x] CK &&& (CSWETBYPASSN != 'b0), tms, TimingViol12_16);
	$setup(posedge M[17], edge[01,0x,x1,1x] CK &&& (CSWETBYPASSN != 'b0), tms, TimingViol12_17);
	$setup(posedge M[18], edge[01,0x,x1,1x] CK &&& (CSWETBYPASSN != 'b0), tms, TimingViol12_18);
	$setup(posedge M[19], edge[01,0x,x1,1x] CK &&& (CSWETBYPASSN != 'b0), tms, TimingViol12_19);
	$setup(posedge M[20], edge[01,0x,x1,1x] CK &&& (CSWETBYPASSN != 'b0), tms, TimingViol12_20);
	$setup(posedge M[21], edge[01,0x,x1,1x] CK &&& (CSWETBYPASSN != 'b0), tms, TimingViol12_21);
	$setup(posedge M[22], edge[01,0x,x1,1x] CK &&& (CSWETBYPASSN != 'b0), tms, TimingViol12_22);
	$setup(posedge M[23], edge[01,0x,x1,1x] CK &&& (CSWETBYPASSN != 'b0), tms, TimingViol12_23);
	$setup(posedge M[24], edge[01,0x,x1,1x] CK &&& (CSWETBYPASSN != 'b0), tms, TimingViol12_24);
	$setup(posedge M[25], edge[01,0x,x1,1x] CK &&& (CSWETBYPASSN != 'b0), tms, TimingViol12_25);
	$setup(posedge M[26], edge[01,0x,x1,1x] CK &&& (CSWETBYPASSN != 'b0), tms, TimingViol12_26);
	$setup(posedge M[27], edge[01,0x,x1,1x] CK &&& (CSWETBYPASSN != 'b0), tms, TimingViol12_27);
	$setup(posedge M[28], edge[01,0x,x1,1x] CK &&& (CSWETBYPASSN != 'b0), tms, TimingViol12_28);
	$setup(posedge M[29], edge[01,0x,x1,1x] CK &&& (CSWETBYPASSN != 'b0), tms, TimingViol12_29);
	$setup(posedge M[30], edge[01,0x,x1,1x] CK &&& (CSWETBYPASSN != 'b0), tms, TimingViol12_30);
	$setup(posedge M[31], edge[01,0x,x1,1x] CK &&& (CSWETBYPASSN != 'b0), tms, TimingViol12_31);
	$setup(posedge M[32], edge[01,0x,x1,1x] CK &&& (CSWETBYPASSN != 'b0), tms, TimingViol12_32);
	$setup(posedge M[33], edge[01,0x,x1,1x] CK &&& (CSWETBYPASSN != 'b0), tms, TimingViol12_33);
	$setup(posedge M[34], edge[01,0x,x1,1x] CK &&& (CSWETBYPASSN != 'b0), tms, TimingViol12_34);
	$setup(posedge M[35], edge[01,0x,x1,1x] CK &&& (CSWETBYPASSN != 'b0), tms, TimingViol12_35);
	$setup(posedge M[36], edge[01,0x,x1,1x] CK &&& (CSWETBYPASSN != 'b0), tms, TimingViol12_36);
	$setup(posedge M[37], edge[01,0x,x1,1x] CK &&& (CSWETBYPASSN != 'b0), tms, TimingViol12_37);
	$setup(posedge M[38], edge[01,0x,x1,1x] CK &&& (CSWETBYPASSN != 'b0), tms, TimingViol12_38);
	$setup(posedge M[39], edge[01,0x,x1,1x] CK &&& (CSWETBYPASSN != 'b0), tms, TimingViol12_39);
	$setup(posedge M[40], edge[01,0x,x1,1x] CK &&& (CSWETBYPASSN != 'b0), tms, TimingViol12_40);
	$setup(posedge M[41], edge[01,0x,x1,1x] CK &&& (CSWETBYPASSN != 'b0), tms, TimingViol12_41);
	$setup(posedge M[42], edge[01,0x,x1,1x] CK &&& (CSWETBYPASSN != 'b0), tms, TimingViol12_42);
	$setup(posedge M[43], edge[01,0x,x1,1x] CK &&& (CSWETBYPASSN != 'b0), tms, TimingViol12_43);
	$setup(posedge M[44], edge[01,0x,x1,1x] CK &&& (CSWETBYPASSN != 'b0), tms, TimingViol12_44);
	$setup(posedge M[45], edge[01,0x,x1,1x] CK &&& (CSWETBYPASSN != 'b0), tms, TimingViol12_45);
	$setup(posedge M[46], edge[01,0x,x1,1x] CK &&& (CSWETBYPASSN != 'b0), tms, TimingViol12_46);
	$setup(posedge M[47], edge[01,0x,x1,1x] CK &&& (CSWETBYPASSN != 'b0), tms, TimingViol12_47);
	$setup(posedge M[48], edge[01,0x,x1,1x] CK &&& (CSWETBYPASSN != 'b0), tms, TimingViol12_48);
	$setup(posedge M[49], edge[01,0x,x1,1x] CK &&& (CSWETBYPASSN != 'b0), tms, TimingViol12_49);
	$setup(posedge M[50], edge[01,0x,x1,1x] CK &&& (CSWETBYPASSN != 'b0), tms, TimingViol12_50);
	$setup(posedge M[51], edge[01,0x,x1,1x] CK &&& (CSWETBYPASSN != 'b0), tms, TimingViol12_51);
	$setup(posedge M[52], edge[01,0x,x1,1x] CK &&& (CSWETBYPASSN != 'b0), tms, TimingViol12_52);
	$setup(posedge M[53], edge[01,0x,x1,1x] CK &&& (CSWETBYPASSN != 'b0), tms, TimingViol12_53);
	$setup(posedge M[54], edge[01,0x,x1,1x] CK &&& (CSWETBYPASSN != 'b0), tms, TimingViol12_54);
	$setup(posedge M[55], edge[01,0x,x1,1x] CK &&& (CSWETBYPASSN != 'b0), tms, TimingViol12_55);
	$setup(posedge M[56], edge[01,0x,x1,1x] CK &&& (CSWETBYPASSN != 'b0), tms, TimingViol12_56);
	$setup(posedge M[57], edge[01,0x,x1,1x] CK &&& (CSWETBYPASSN != 'b0), tms, TimingViol12_57);
	$setup(posedge M[58], edge[01,0x,x1,1x] CK &&& (CSWETBYPASSN != 'b0), tms, TimingViol12_58);
	$setup(posedge M[59], edge[01,0x,x1,1x] CK &&& (CSWETBYPASSN != 'b0), tms, TimingViol12_59);
	$setup(posedge M[60], edge[01,0x,x1,1x] CK &&& (CSWETBYPASSN != 'b0), tms, TimingViol12_60);
	$setup(posedge M[61], edge[01,0x,x1,1x] CK &&& (CSWETBYPASSN != 'b0), tms, TimingViol12_61);
	$setup(posedge M[62], edge[01,0x,x1,1x] CK &&& (CSWETBYPASSN != 'b0), tms, TimingViol12_62);
	$setup(posedge M[63], edge[01,0x,x1,1x] CK &&& (CSWETBYPASSN != 'b0), tms, TimingViol12_63);
	$setup(negedge M[0], edge[01,0x,x1,1x] CK &&& (CSWETBYPASSN != 'b0), tms, TimingViol12_0);
	$setup(negedge M[1], edge[01,0x,x1,1x] CK &&& (CSWETBYPASSN != 'b0), tms, TimingViol12_1);
	$setup(negedge M[2], edge[01,0x,x1,1x] CK &&& (CSWETBYPASSN != 'b0), tms, TimingViol12_2);
	$setup(negedge M[3], edge[01,0x,x1,1x] CK &&& (CSWETBYPASSN != 'b0), tms, TimingViol12_3);
	$setup(negedge M[4], edge[01,0x,x1,1x] CK &&& (CSWETBYPASSN != 'b0), tms, TimingViol12_4);
	$setup(negedge M[5], edge[01,0x,x1,1x] CK &&& (CSWETBYPASSN != 'b0), tms, TimingViol12_5);
	$setup(negedge M[6], edge[01,0x,x1,1x] CK &&& (CSWETBYPASSN != 'b0), tms, TimingViol12_6);
	$setup(negedge M[7], edge[01,0x,x1,1x] CK &&& (CSWETBYPASSN != 'b0), tms, TimingViol12_7);
	$setup(negedge M[8], edge[01,0x,x1,1x] CK &&& (CSWETBYPASSN != 'b0), tms, TimingViol12_8);
	$setup(negedge M[9], edge[01,0x,x1,1x] CK &&& (CSWETBYPASSN != 'b0), tms, TimingViol12_9);
	$setup(negedge M[10], edge[01,0x,x1,1x] CK &&& (CSWETBYPASSN != 'b0), tms, TimingViol12_10);
	$setup(negedge M[11], edge[01,0x,x1,1x] CK &&& (CSWETBYPASSN != 'b0), tms, TimingViol12_11);
	$setup(negedge M[12], edge[01,0x,x1,1x] CK &&& (CSWETBYPASSN != 'b0), tms, TimingViol12_12);
	$setup(negedge M[13], edge[01,0x,x1,1x] CK &&& (CSWETBYPASSN != 'b0), tms, TimingViol12_13);
	$setup(negedge M[14], edge[01,0x,x1,1x] CK &&& (CSWETBYPASSN != 'b0), tms, TimingViol12_14);
	$setup(negedge M[15], edge[01,0x,x1,1x] CK &&& (CSWETBYPASSN != 'b0), tms, TimingViol12_15);
	$setup(negedge M[16], edge[01,0x,x1,1x] CK &&& (CSWETBYPASSN != 'b0), tms, TimingViol12_16);
	$setup(negedge M[17], edge[01,0x,x1,1x] CK &&& (CSWETBYPASSN != 'b0), tms, TimingViol12_17);
	$setup(negedge M[18], edge[01,0x,x1,1x] CK &&& (CSWETBYPASSN != 'b0), tms, TimingViol12_18);
	$setup(negedge M[19], edge[01,0x,x1,1x] CK &&& (CSWETBYPASSN != 'b0), tms, TimingViol12_19);
	$setup(negedge M[20], edge[01,0x,x1,1x] CK &&& (CSWETBYPASSN != 'b0), tms, TimingViol12_20);
	$setup(negedge M[21], edge[01,0x,x1,1x] CK &&& (CSWETBYPASSN != 'b0), tms, TimingViol12_21);
	$setup(negedge M[22], edge[01,0x,x1,1x] CK &&& (CSWETBYPASSN != 'b0), tms, TimingViol12_22);
	$setup(negedge M[23], edge[01,0x,x1,1x] CK &&& (CSWETBYPASSN != 'b0), tms, TimingViol12_23);
	$setup(negedge M[24], edge[01,0x,x1,1x] CK &&& (CSWETBYPASSN != 'b0), tms, TimingViol12_24);
	$setup(negedge M[25], edge[01,0x,x1,1x] CK &&& (CSWETBYPASSN != 'b0), tms, TimingViol12_25);
	$setup(negedge M[26], edge[01,0x,x1,1x] CK &&& (CSWETBYPASSN != 'b0), tms, TimingViol12_26);
	$setup(negedge M[27], edge[01,0x,x1,1x] CK &&& (CSWETBYPASSN != 'b0), tms, TimingViol12_27);
	$setup(negedge M[28], edge[01,0x,x1,1x] CK &&& (CSWETBYPASSN != 'b0), tms, TimingViol12_28);
	$setup(negedge M[29], edge[01,0x,x1,1x] CK &&& (CSWETBYPASSN != 'b0), tms, TimingViol12_29);
	$setup(negedge M[30], edge[01,0x,x1,1x] CK &&& (CSWETBYPASSN != 'b0), tms, TimingViol12_30);
	$setup(negedge M[31], edge[01,0x,x1,1x] CK &&& (CSWETBYPASSN != 'b0), tms, TimingViol12_31);
	$setup(negedge M[32], edge[01,0x,x1,1x] CK &&& (CSWETBYPASSN != 'b0), tms, TimingViol12_32);
	$setup(negedge M[33], edge[01,0x,x1,1x] CK &&& (CSWETBYPASSN != 'b0), tms, TimingViol12_33);
	$setup(negedge M[34], edge[01,0x,x1,1x] CK &&& (CSWETBYPASSN != 'b0), tms, TimingViol12_34);
	$setup(negedge M[35], edge[01,0x,x1,1x] CK &&& (CSWETBYPASSN != 'b0), tms, TimingViol12_35);
	$setup(negedge M[36], edge[01,0x,x1,1x] CK &&& (CSWETBYPASSN != 'b0), tms, TimingViol12_36);
	$setup(negedge M[37], edge[01,0x,x1,1x] CK &&& (CSWETBYPASSN != 'b0), tms, TimingViol12_37);
	$setup(negedge M[38], edge[01,0x,x1,1x] CK &&& (CSWETBYPASSN != 'b0), tms, TimingViol12_38);
	$setup(negedge M[39], edge[01,0x,x1,1x] CK &&& (CSWETBYPASSN != 'b0), tms, TimingViol12_39);
	$setup(negedge M[40], edge[01,0x,x1,1x] CK &&& (CSWETBYPASSN != 'b0), tms, TimingViol12_40);
	$setup(negedge M[41], edge[01,0x,x1,1x] CK &&& (CSWETBYPASSN != 'b0), tms, TimingViol12_41);
	$setup(negedge M[42], edge[01,0x,x1,1x] CK &&& (CSWETBYPASSN != 'b0), tms, TimingViol12_42);
	$setup(negedge M[43], edge[01,0x,x1,1x] CK &&& (CSWETBYPASSN != 'b0), tms, TimingViol12_43);
	$setup(negedge M[44], edge[01,0x,x1,1x] CK &&& (CSWETBYPASSN != 'b0), tms, TimingViol12_44);
	$setup(negedge M[45], edge[01,0x,x1,1x] CK &&& (CSWETBYPASSN != 'b0), tms, TimingViol12_45);
	$setup(negedge M[46], edge[01,0x,x1,1x] CK &&& (CSWETBYPASSN != 'b0), tms, TimingViol12_46);
	$setup(negedge M[47], edge[01,0x,x1,1x] CK &&& (CSWETBYPASSN != 'b0), tms, TimingViol12_47);
	$setup(negedge M[48], edge[01,0x,x1,1x] CK &&& (CSWETBYPASSN != 'b0), tms, TimingViol12_48);
	$setup(negedge M[49], edge[01,0x,x1,1x] CK &&& (CSWETBYPASSN != 'b0), tms, TimingViol12_49);
	$setup(negedge M[50], edge[01,0x,x1,1x] CK &&& (CSWETBYPASSN != 'b0), tms, TimingViol12_50);
	$setup(negedge M[51], edge[01,0x,x1,1x] CK &&& (CSWETBYPASSN != 'b0), tms, TimingViol12_51);
	$setup(negedge M[52], edge[01,0x,x1,1x] CK &&& (CSWETBYPASSN != 'b0), tms, TimingViol12_52);
	$setup(negedge M[53], edge[01,0x,x1,1x] CK &&& (CSWETBYPASSN != 'b0), tms, TimingViol12_53);
	$setup(negedge M[54], edge[01,0x,x1,1x] CK &&& (CSWETBYPASSN != 'b0), tms, TimingViol12_54);
	$setup(negedge M[55], edge[01,0x,x1,1x] CK &&& (CSWETBYPASSN != 'b0), tms, TimingViol12_55);
	$setup(negedge M[56], edge[01,0x,x1,1x] CK &&& (CSWETBYPASSN != 'b0), tms, TimingViol12_56);
	$setup(negedge M[57], edge[01,0x,x1,1x] CK &&& (CSWETBYPASSN != 'b0), tms, TimingViol12_57);
	$setup(negedge M[58], edge[01,0x,x1,1x] CK &&& (CSWETBYPASSN != 'b0), tms, TimingViol12_58);
	$setup(negedge M[59], edge[01,0x,x1,1x] CK &&& (CSWETBYPASSN != 'b0), tms, TimingViol12_59);
	$setup(negedge M[60], edge[01,0x,x1,1x] CK &&& (CSWETBYPASSN != 'b0), tms, TimingViol12_60);
	$setup(negedge M[61], edge[01,0x,x1,1x] CK &&& (CSWETBYPASSN != 'b0), tms, TimingViol12_61);
	$setup(negedge M[62], edge[01,0x,x1,1x] CK &&& (CSWETBYPASSN != 'b0), tms, TimingViol12_62);
	$setup(negedge M[63], edge[01,0x,x1,1x] CK &&& (CSWETBYPASSN != 'b0), tms, TimingViol12_63);
	$hold(edge[01,0x,x1,x0] CK &&& (CSWETBYPASSN != 'b0), posedge M[0], tmh, TimingViol13_0);
	$hold(edge[01,0x,x1,x0] CK &&& (CSWETBYPASSN != 'b0), posedge M[1], tmh, TimingViol13_1);
	$hold(edge[01,0x,x1,x0] CK &&& (CSWETBYPASSN != 'b0), posedge M[2], tmh, TimingViol13_2);
	$hold(edge[01,0x,x1,x0] CK &&& (CSWETBYPASSN != 'b0), posedge M[3], tmh, TimingViol13_3);
	$hold(edge[01,0x,x1,x0] CK &&& (CSWETBYPASSN != 'b0), posedge M[4], tmh, TimingViol13_4);
	$hold(edge[01,0x,x1,x0] CK &&& (CSWETBYPASSN != 'b0), posedge M[5], tmh, TimingViol13_5);
	$hold(edge[01,0x,x1,x0] CK &&& (CSWETBYPASSN != 'b0), posedge M[6], tmh, TimingViol13_6);
	$hold(edge[01,0x,x1,x0] CK &&& (CSWETBYPASSN != 'b0), posedge M[7], tmh, TimingViol13_7);
	$hold(edge[01,0x,x1,x0] CK &&& (CSWETBYPASSN != 'b0), posedge M[8], tmh, TimingViol13_8);
	$hold(edge[01,0x,x1,x0] CK &&& (CSWETBYPASSN != 'b0), posedge M[9], tmh, TimingViol13_9);
	$hold(edge[01,0x,x1,x0] CK &&& (CSWETBYPASSN != 'b0), posedge M[10], tmh, TimingViol13_10);
	$hold(edge[01,0x,x1,x0] CK &&& (CSWETBYPASSN != 'b0), posedge M[11], tmh, TimingViol13_11);
	$hold(edge[01,0x,x1,x0] CK &&& (CSWETBYPASSN != 'b0), posedge M[12], tmh, TimingViol13_12);
	$hold(edge[01,0x,x1,x0] CK &&& (CSWETBYPASSN != 'b0), posedge M[13], tmh, TimingViol13_13);
	$hold(edge[01,0x,x1,x0] CK &&& (CSWETBYPASSN != 'b0), posedge M[14], tmh, TimingViol13_14);
	$hold(edge[01,0x,x1,x0] CK &&& (CSWETBYPASSN != 'b0), posedge M[15], tmh, TimingViol13_15);
	$hold(edge[01,0x,x1,x0] CK &&& (CSWETBYPASSN != 'b0), posedge M[16], tmh, TimingViol13_16);
	$hold(edge[01,0x,x1,x0] CK &&& (CSWETBYPASSN != 'b0), posedge M[17], tmh, TimingViol13_17);
	$hold(edge[01,0x,x1,x0] CK &&& (CSWETBYPASSN != 'b0), posedge M[18], tmh, TimingViol13_18);
	$hold(edge[01,0x,x1,x0] CK &&& (CSWETBYPASSN != 'b0), posedge M[19], tmh, TimingViol13_19);
	$hold(edge[01,0x,x1,x0] CK &&& (CSWETBYPASSN != 'b0), posedge M[20], tmh, TimingViol13_20);
	$hold(edge[01,0x,x1,x0] CK &&& (CSWETBYPASSN != 'b0), posedge M[21], tmh, TimingViol13_21);
	$hold(edge[01,0x,x1,x0] CK &&& (CSWETBYPASSN != 'b0), posedge M[22], tmh, TimingViol13_22);
	$hold(edge[01,0x,x1,x0] CK &&& (CSWETBYPASSN != 'b0), posedge M[23], tmh, TimingViol13_23);
	$hold(edge[01,0x,x1,x0] CK &&& (CSWETBYPASSN != 'b0), posedge M[24], tmh, TimingViol13_24);
	$hold(edge[01,0x,x1,x0] CK &&& (CSWETBYPASSN != 'b0), posedge M[25], tmh, TimingViol13_25);
	$hold(edge[01,0x,x1,x0] CK &&& (CSWETBYPASSN != 'b0), posedge M[26], tmh, TimingViol13_26);
	$hold(edge[01,0x,x1,x0] CK &&& (CSWETBYPASSN != 'b0), posedge M[27], tmh, TimingViol13_27);
	$hold(edge[01,0x,x1,x0] CK &&& (CSWETBYPASSN != 'b0), posedge M[28], tmh, TimingViol13_28);
	$hold(edge[01,0x,x1,x0] CK &&& (CSWETBYPASSN != 'b0), posedge M[29], tmh, TimingViol13_29);
	$hold(edge[01,0x,x1,x0] CK &&& (CSWETBYPASSN != 'b0), posedge M[30], tmh, TimingViol13_30);
	$hold(edge[01,0x,x1,x0] CK &&& (CSWETBYPASSN != 'b0), posedge M[31], tmh, TimingViol13_31);
	$hold(edge[01,0x,x1,x0] CK &&& (CSWETBYPASSN != 'b0), posedge M[32], tmh, TimingViol13_32);
	$hold(edge[01,0x,x1,x0] CK &&& (CSWETBYPASSN != 'b0), posedge M[33], tmh, TimingViol13_33);
	$hold(edge[01,0x,x1,x0] CK &&& (CSWETBYPASSN != 'b0), posedge M[34], tmh, TimingViol13_34);
	$hold(edge[01,0x,x1,x0] CK &&& (CSWETBYPASSN != 'b0), posedge M[35], tmh, TimingViol13_35);
	$hold(edge[01,0x,x1,x0] CK &&& (CSWETBYPASSN != 'b0), posedge M[36], tmh, TimingViol13_36);
	$hold(edge[01,0x,x1,x0] CK &&& (CSWETBYPASSN != 'b0), posedge M[37], tmh, TimingViol13_37);
	$hold(edge[01,0x,x1,x0] CK &&& (CSWETBYPASSN != 'b0), posedge M[38], tmh, TimingViol13_38);
	$hold(edge[01,0x,x1,x0] CK &&& (CSWETBYPASSN != 'b0), posedge M[39], tmh, TimingViol13_39);
	$hold(edge[01,0x,x1,x0] CK &&& (CSWETBYPASSN != 'b0), posedge M[40], tmh, TimingViol13_40);
	$hold(edge[01,0x,x1,x0] CK &&& (CSWETBYPASSN != 'b0), posedge M[41], tmh, TimingViol13_41);
	$hold(edge[01,0x,x1,x0] CK &&& (CSWETBYPASSN != 'b0), posedge M[42], tmh, TimingViol13_42);
	$hold(edge[01,0x,x1,x0] CK &&& (CSWETBYPASSN != 'b0), posedge M[43], tmh, TimingViol13_43);
	$hold(edge[01,0x,x1,x0] CK &&& (CSWETBYPASSN != 'b0), posedge M[44], tmh, TimingViol13_44);
	$hold(edge[01,0x,x1,x0] CK &&& (CSWETBYPASSN != 'b0), posedge M[45], tmh, TimingViol13_45);
	$hold(edge[01,0x,x1,x0] CK &&& (CSWETBYPASSN != 'b0), posedge M[46], tmh, TimingViol13_46);
	$hold(edge[01,0x,x1,x0] CK &&& (CSWETBYPASSN != 'b0), posedge M[47], tmh, TimingViol13_47);
	$hold(edge[01,0x,x1,x0] CK &&& (CSWETBYPASSN != 'b0), posedge M[48], tmh, TimingViol13_48);
	$hold(edge[01,0x,x1,x0] CK &&& (CSWETBYPASSN != 'b0), posedge M[49], tmh, TimingViol13_49);
	$hold(edge[01,0x,x1,x0] CK &&& (CSWETBYPASSN != 'b0), posedge M[50], tmh, TimingViol13_50);
	$hold(edge[01,0x,x1,x0] CK &&& (CSWETBYPASSN != 'b0), posedge M[51], tmh, TimingViol13_51);
	$hold(edge[01,0x,x1,x0] CK &&& (CSWETBYPASSN != 'b0), posedge M[52], tmh, TimingViol13_52);
	$hold(edge[01,0x,x1,x0] CK &&& (CSWETBYPASSN != 'b0), posedge M[53], tmh, TimingViol13_53);
	$hold(edge[01,0x,x1,x0] CK &&& (CSWETBYPASSN != 'b0), posedge M[54], tmh, TimingViol13_54);
	$hold(edge[01,0x,x1,x0] CK &&& (CSWETBYPASSN != 'b0), posedge M[55], tmh, TimingViol13_55);
	$hold(edge[01,0x,x1,x0] CK &&& (CSWETBYPASSN != 'b0), posedge M[56], tmh, TimingViol13_56);
	$hold(edge[01,0x,x1,x0] CK &&& (CSWETBYPASSN != 'b0), posedge M[57], tmh, TimingViol13_57);
	$hold(edge[01,0x,x1,x0] CK &&& (CSWETBYPASSN != 'b0), posedge M[58], tmh, TimingViol13_58);
	$hold(edge[01,0x,x1,x0] CK &&& (CSWETBYPASSN != 'b0), posedge M[59], tmh, TimingViol13_59);
	$hold(edge[01,0x,x1,x0] CK &&& (CSWETBYPASSN != 'b0), posedge M[60], tmh, TimingViol13_60);
	$hold(edge[01,0x,x1,x0] CK &&& (CSWETBYPASSN != 'b0), posedge M[61], tmh, TimingViol13_61);
	$hold(edge[01,0x,x1,x0] CK &&& (CSWETBYPASSN != 'b0), posedge M[62], tmh, TimingViol13_62);
	$hold(edge[01,0x,x1,x0] CK &&& (CSWETBYPASSN != 'b0), posedge M[63], tmh, TimingViol13_63);
	$hold(edge[01,0x,x1,x0] CK &&& (CSWETBYPASSN != 'b0), negedge M[0], tmh, TimingViol13_0);
	$hold(edge[01,0x,x1,x0] CK &&& (CSWETBYPASSN != 'b0), negedge M[1], tmh, TimingViol13_1);
	$hold(edge[01,0x,x1,x0] CK &&& (CSWETBYPASSN != 'b0), negedge M[2], tmh, TimingViol13_2);
	$hold(edge[01,0x,x1,x0] CK &&& (CSWETBYPASSN != 'b0), negedge M[3], tmh, TimingViol13_3);
	$hold(edge[01,0x,x1,x0] CK &&& (CSWETBYPASSN != 'b0), negedge M[4], tmh, TimingViol13_4);
	$hold(edge[01,0x,x1,x0] CK &&& (CSWETBYPASSN != 'b0), negedge M[5], tmh, TimingViol13_5);
	$hold(edge[01,0x,x1,x0] CK &&& (CSWETBYPASSN != 'b0), negedge M[6], tmh, TimingViol13_6);
	$hold(edge[01,0x,x1,x0] CK &&& (CSWETBYPASSN != 'b0), negedge M[7], tmh, TimingViol13_7);
	$hold(edge[01,0x,x1,x0] CK &&& (CSWETBYPASSN != 'b0), negedge M[8], tmh, TimingViol13_8);
	$hold(edge[01,0x,x1,x0] CK &&& (CSWETBYPASSN != 'b0), negedge M[9], tmh, TimingViol13_9);
	$hold(edge[01,0x,x1,x0] CK &&& (CSWETBYPASSN != 'b0), negedge M[10], tmh, TimingViol13_10);
	$hold(edge[01,0x,x1,x0] CK &&& (CSWETBYPASSN != 'b0), negedge M[11], tmh, TimingViol13_11);
	$hold(edge[01,0x,x1,x0] CK &&& (CSWETBYPASSN != 'b0), negedge M[12], tmh, TimingViol13_12);
	$hold(edge[01,0x,x1,x0] CK &&& (CSWETBYPASSN != 'b0), negedge M[13], tmh, TimingViol13_13);
	$hold(edge[01,0x,x1,x0] CK &&& (CSWETBYPASSN != 'b0), negedge M[14], tmh, TimingViol13_14);
	$hold(edge[01,0x,x1,x0] CK &&& (CSWETBYPASSN != 'b0), negedge M[15], tmh, TimingViol13_15);
	$hold(edge[01,0x,x1,x0] CK &&& (CSWETBYPASSN != 'b0), negedge M[16], tmh, TimingViol13_16);
	$hold(edge[01,0x,x1,x0] CK &&& (CSWETBYPASSN != 'b0), negedge M[17], tmh, TimingViol13_17);
	$hold(edge[01,0x,x1,x0] CK &&& (CSWETBYPASSN != 'b0), negedge M[18], tmh, TimingViol13_18);
	$hold(edge[01,0x,x1,x0] CK &&& (CSWETBYPASSN != 'b0), negedge M[19], tmh, TimingViol13_19);
	$hold(edge[01,0x,x1,x0] CK &&& (CSWETBYPASSN != 'b0), negedge M[20], tmh, TimingViol13_20);
	$hold(edge[01,0x,x1,x0] CK &&& (CSWETBYPASSN != 'b0), negedge M[21], tmh, TimingViol13_21);
	$hold(edge[01,0x,x1,x0] CK &&& (CSWETBYPASSN != 'b0), negedge M[22], tmh, TimingViol13_22);
	$hold(edge[01,0x,x1,x0] CK &&& (CSWETBYPASSN != 'b0), negedge M[23], tmh, TimingViol13_23);
	$hold(edge[01,0x,x1,x0] CK &&& (CSWETBYPASSN != 'b0), negedge M[24], tmh, TimingViol13_24);
	$hold(edge[01,0x,x1,x0] CK &&& (CSWETBYPASSN != 'b0), negedge M[25], tmh, TimingViol13_25);
	$hold(edge[01,0x,x1,x0] CK &&& (CSWETBYPASSN != 'b0), negedge M[26], tmh, TimingViol13_26);
	$hold(edge[01,0x,x1,x0] CK &&& (CSWETBYPASSN != 'b0), negedge M[27], tmh, TimingViol13_27);
	$hold(edge[01,0x,x1,x0] CK &&& (CSWETBYPASSN != 'b0), negedge M[28], tmh, TimingViol13_28);
	$hold(edge[01,0x,x1,x0] CK &&& (CSWETBYPASSN != 'b0), negedge M[29], tmh, TimingViol13_29);
	$hold(edge[01,0x,x1,x0] CK &&& (CSWETBYPASSN != 'b0), negedge M[30], tmh, TimingViol13_30);
	$hold(edge[01,0x,x1,x0] CK &&& (CSWETBYPASSN != 'b0), negedge M[31], tmh, TimingViol13_31);
	$hold(edge[01,0x,x1,x0] CK &&& (CSWETBYPASSN != 'b0), negedge M[32], tmh, TimingViol13_32);
	$hold(edge[01,0x,x1,x0] CK &&& (CSWETBYPASSN != 'b0), negedge M[33], tmh, TimingViol13_33);
	$hold(edge[01,0x,x1,x0] CK &&& (CSWETBYPASSN != 'b0), negedge M[34], tmh, TimingViol13_34);
	$hold(edge[01,0x,x1,x0] CK &&& (CSWETBYPASSN != 'b0), negedge M[35], tmh, TimingViol13_35);
	$hold(edge[01,0x,x1,x0] CK &&& (CSWETBYPASSN != 'b0), negedge M[36], tmh, TimingViol13_36);
	$hold(edge[01,0x,x1,x0] CK &&& (CSWETBYPASSN != 'b0), negedge M[37], tmh, TimingViol13_37);
	$hold(edge[01,0x,x1,x0] CK &&& (CSWETBYPASSN != 'b0), negedge M[38], tmh, TimingViol13_38);
	$hold(edge[01,0x,x1,x0] CK &&& (CSWETBYPASSN != 'b0), negedge M[39], tmh, TimingViol13_39);
	$hold(edge[01,0x,x1,x0] CK &&& (CSWETBYPASSN != 'b0), negedge M[40], tmh, TimingViol13_40);
	$hold(edge[01,0x,x1,x0] CK &&& (CSWETBYPASSN != 'b0), negedge M[41], tmh, TimingViol13_41);
	$hold(edge[01,0x,x1,x0] CK &&& (CSWETBYPASSN != 'b0), negedge M[42], tmh, TimingViol13_42);
	$hold(edge[01,0x,x1,x0] CK &&& (CSWETBYPASSN != 'b0), negedge M[43], tmh, TimingViol13_43);
	$hold(edge[01,0x,x1,x0] CK &&& (CSWETBYPASSN != 'b0), negedge M[44], tmh, TimingViol13_44);
	$hold(edge[01,0x,x1,x0] CK &&& (CSWETBYPASSN != 'b0), negedge M[45], tmh, TimingViol13_45);
	$hold(edge[01,0x,x1,x0] CK &&& (CSWETBYPASSN != 'b0), negedge M[46], tmh, TimingViol13_46);
	$hold(edge[01,0x,x1,x0] CK &&& (CSWETBYPASSN != 'b0), negedge M[47], tmh, TimingViol13_47);
	$hold(edge[01,0x,x1,x0] CK &&& (CSWETBYPASSN != 'b0), negedge M[48], tmh, TimingViol13_48);
	$hold(edge[01,0x,x1,x0] CK &&& (CSWETBYPASSN != 'b0), negedge M[49], tmh, TimingViol13_49);
	$hold(edge[01,0x,x1,x0] CK &&& (CSWETBYPASSN != 'b0), negedge M[50], tmh, TimingViol13_50);
	$hold(edge[01,0x,x1,x0] CK &&& (CSWETBYPASSN != 'b0), negedge M[51], tmh, TimingViol13_51);
	$hold(edge[01,0x,x1,x0] CK &&& (CSWETBYPASSN != 'b0), negedge M[52], tmh, TimingViol13_52);
	$hold(edge[01,0x,x1,x0] CK &&& (CSWETBYPASSN != 'b0), negedge M[53], tmh, TimingViol13_53);
	$hold(edge[01,0x,x1,x0] CK &&& (CSWETBYPASSN != 'b0), negedge M[54], tmh, TimingViol13_54);
	$hold(edge[01,0x,x1,x0] CK &&& (CSWETBYPASSN != 'b0), negedge M[55], tmh, TimingViol13_55);
	$hold(edge[01,0x,x1,x0] CK &&& (CSWETBYPASSN != 'b0), negedge M[56], tmh, TimingViol13_56);
	$hold(edge[01,0x,x1,x0] CK &&& (CSWETBYPASSN != 'b0), negedge M[57], tmh, TimingViol13_57);
	$hold(edge[01,0x,x1,x0] CK &&& (CSWETBYPASSN != 'b0), negedge M[58], tmh, TimingViol13_58);
	$hold(edge[01,0x,x1,x0] CK &&& (CSWETBYPASSN != 'b0), negedge M[59], tmh, TimingViol13_59);
	$hold(edge[01,0x,x1,x0] CK &&& (CSWETBYPASSN != 'b0), negedge M[60], tmh, TimingViol13_60);
	$hold(edge[01,0x,x1,x0] CK &&& (CSWETBYPASSN != 'b0), negedge M[61], tmh, TimingViol13_61);
	$hold(edge[01,0x,x1,x0] CK &&& (CSWETBYPASSN != 'b0), negedge M[62], tmh, TimingViol13_62);
	$hold(edge[01,0x,x1,x0] CK &&& (CSWETBYPASSN != 'b0), negedge M[63], tmh, TimingViol13_63);

        
        $setup(posedge CSN, edge[01,0x,x1,1x] CK &&& TBYPASSint != 1'b1, tps, TimingViol4);
	$setup(negedge CSN, edge[01,0x,x1,1x] CK &&& TBYPASSint != 1'b1, tps, TimingViol4);
	$hold(edge[01,0x,x1,x0] CK &&& TBYPASSint != 1'b1, posedge CSN, tph, TimingViol5);
	$hold(edge[01,0x,x1,x0] CK &&& TBYPASSint != 1'b1, negedge CSN, tph, TimingViol5);
        $setup(posedge WEN, edge[01,0x,x1,1x] CK &&& (CSTBYPASSN != 'b0), tws, TimingViol6);
        $setup(negedge WEN, edge[01,0x,x1,1x] CK &&& (CSTBYPASSN != 'b0), tws, TimingViol6);
        $hold(edge[01,0x,x1,x0] CK &&& (CSTBYPASSN != 'b0), posedge WEN, twh, TimingViol7);
        $hold(edge[01,0x,x1,x0] CK &&& (CSTBYPASSN != 'b0), negedge WEN, twh, TimingViol7);
        

        $period(posedge CK &&& (csn_tcycle != 0), tcycle, TimingViol10); 
        $period(posedge CK &&& (CS_taa != 0), tcycle_taa, TimingViol10_taa);
        $width(posedge CK &&& (csn_tckh != 'b0), tckh, 0, TimingViol8);
        $width(negedge CK &&& (csn_tckl != 'b0), tckl, 0, TimingViol9);
        
        // TBYPASS setup/hold violations
        $setup(posedge TBYPASS, posedge CK &&& (CS != 0),ttms, TimingViol_ttms_ttmh);
        $setup(negedge TBYPASS, posedge CK &&& (CS != 0),ttms, TimingViol_ttms_ttmh);

        $hold(posedge CK &&& (CS != 1'b0), posedge TBYPASS, ttmh, TimingViol_ttms_ttmh);
        $hold(posedge CK &&& (CS != 1'b0), negedge TBYPASS, ttmh, TimingViol_ttms_ttmh); 



        $period(posedge CK &&& (CS_taa_ry != 0), tcycle_taa_ry, TimingViol10_taa_ry);
        $width(negedge CK &&& (csn_tckl_ry!= 0), tckl_tck_ry, 0, TimingViol9_tck_ry);


        
	endspecify

always @(CKint)
begin
   CKreg <= CKint;
end

always @(posedge CKint)
begin
   if (CSNint !== 1)
   begin
      Dreg = Dint;
      Mreg = Mint;
      WENreg = WENint;
      Areg = Aint;
   end
   CSNreg = CSNint;
   if (CSNint === 1'b1)
      tckh_flag = 0;
   else
      tckh_flag = 1;
        
tckl_flag = 1;
end
     
always @(negedge CKint)
begin
   #0.00   tckh_flag = 1;
   if (CSNint === 1)
      tckl_flag = 0;
   else
      tckl_flag = 1;
end
     
always @(CSNint)
begin
   if (CKint !== 1)
      tckl_flag = ~CSNint;
end

always @(TimingViol10_taa)
begin
   if(debug_level < 2)
   $display("%m - %t WARNING: READ/WRITE ACCESS TIME IS GREATER THAN THE CLOCK PERIOD",$realtime);
end

// conversion from registers to array elements for mask setup violation notifiers


always @(TimingViol12_63)
begin
   TimingViol12[63] = TimingViol12_63;
end


always @(TimingViol12_62)
begin
   TimingViol12[62] = TimingViol12_62;
end


always @(TimingViol12_61)
begin
   TimingViol12[61] = TimingViol12_61;
end


always @(TimingViol12_60)
begin
   TimingViol12[60] = TimingViol12_60;
end


always @(TimingViol12_59)
begin
   TimingViol12[59] = TimingViol12_59;
end


always @(TimingViol12_58)
begin
   TimingViol12[58] = TimingViol12_58;
end


always @(TimingViol12_57)
begin
   TimingViol12[57] = TimingViol12_57;
end


always @(TimingViol12_56)
begin
   TimingViol12[56] = TimingViol12_56;
end


always @(TimingViol12_55)
begin
   TimingViol12[55] = TimingViol12_55;
end


always @(TimingViol12_54)
begin
   TimingViol12[54] = TimingViol12_54;
end


always @(TimingViol12_53)
begin
   TimingViol12[53] = TimingViol12_53;
end


always @(TimingViol12_52)
begin
   TimingViol12[52] = TimingViol12_52;
end


always @(TimingViol12_51)
begin
   TimingViol12[51] = TimingViol12_51;
end


always @(TimingViol12_50)
begin
   TimingViol12[50] = TimingViol12_50;
end


always @(TimingViol12_49)
begin
   TimingViol12[49] = TimingViol12_49;
end


always @(TimingViol12_48)
begin
   TimingViol12[48] = TimingViol12_48;
end


always @(TimingViol12_47)
begin
   TimingViol12[47] = TimingViol12_47;
end


always @(TimingViol12_46)
begin
   TimingViol12[46] = TimingViol12_46;
end


always @(TimingViol12_45)
begin
   TimingViol12[45] = TimingViol12_45;
end


always @(TimingViol12_44)
begin
   TimingViol12[44] = TimingViol12_44;
end


always @(TimingViol12_43)
begin
   TimingViol12[43] = TimingViol12_43;
end


always @(TimingViol12_42)
begin
   TimingViol12[42] = TimingViol12_42;
end


always @(TimingViol12_41)
begin
   TimingViol12[41] = TimingViol12_41;
end


always @(TimingViol12_40)
begin
   TimingViol12[40] = TimingViol12_40;
end


always @(TimingViol12_39)
begin
   TimingViol12[39] = TimingViol12_39;
end


always @(TimingViol12_38)
begin
   TimingViol12[38] = TimingViol12_38;
end


always @(TimingViol12_37)
begin
   TimingViol12[37] = TimingViol12_37;
end


always @(TimingViol12_36)
begin
   TimingViol12[36] = TimingViol12_36;
end


always @(TimingViol12_35)
begin
   TimingViol12[35] = TimingViol12_35;
end


always @(TimingViol12_34)
begin
   TimingViol12[34] = TimingViol12_34;
end


always @(TimingViol12_33)
begin
   TimingViol12[33] = TimingViol12_33;
end


always @(TimingViol12_32)
begin
   TimingViol12[32] = TimingViol12_32;
end


always @(TimingViol12_31)
begin
   TimingViol12[31] = TimingViol12_31;
end


always @(TimingViol12_30)
begin
   TimingViol12[30] = TimingViol12_30;
end


always @(TimingViol12_29)
begin
   TimingViol12[29] = TimingViol12_29;
end


always @(TimingViol12_28)
begin
   TimingViol12[28] = TimingViol12_28;
end


always @(TimingViol12_27)
begin
   TimingViol12[27] = TimingViol12_27;
end


always @(TimingViol12_26)
begin
   TimingViol12[26] = TimingViol12_26;
end


always @(TimingViol12_25)
begin
   TimingViol12[25] = TimingViol12_25;
end


always @(TimingViol12_24)
begin
   TimingViol12[24] = TimingViol12_24;
end


always @(TimingViol12_23)
begin
   TimingViol12[23] = TimingViol12_23;
end


always @(TimingViol12_22)
begin
   TimingViol12[22] = TimingViol12_22;
end


always @(TimingViol12_21)
begin
   TimingViol12[21] = TimingViol12_21;
end


always @(TimingViol12_20)
begin
   TimingViol12[20] = TimingViol12_20;
end


always @(TimingViol12_19)
begin
   TimingViol12[19] = TimingViol12_19;
end


always @(TimingViol12_18)
begin
   TimingViol12[18] = TimingViol12_18;
end


always @(TimingViol12_17)
begin
   TimingViol12[17] = TimingViol12_17;
end


always @(TimingViol12_16)
begin
   TimingViol12[16] = TimingViol12_16;
end


always @(TimingViol12_15)
begin
   TimingViol12[15] = TimingViol12_15;
end


always @(TimingViol12_14)
begin
   TimingViol12[14] = TimingViol12_14;
end


always @(TimingViol12_13)
begin
   TimingViol12[13] = TimingViol12_13;
end


always @(TimingViol12_12)
begin
   TimingViol12[12] = TimingViol12_12;
end


always @(TimingViol12_11)
begin
   TimingViol12[11] = TimingViol12_11;
end


always @(TimingViol12_10)
begin
   TimingViol12[10] = TimingViol12_10;
end


always @(TimingViol12_9)
begin
   TimingViol12[9] = TimingViol12_9;
end


always @(TimingViol12_8)
begin
   TimingViol12[8] = TimingViol12_8;
end


always @(TimingViol12_7)
begin
   TimingViol12[7] = TimingViol12_7;
end


always @(TimingViol12_6)
begin
   TimingViol12[6] = TimingViol12_6;
end


always @(TimingViol12_5)
begin
   TimingViol12[5] = TimingViol12_5;
end


always @(TimingViol12_4)
begin
   TimingViol12[4] = TimingViol12_4;
end


always @(TimingViol12_3)
begin
   TimingViol12[3] = TimingViol12_3;
end


always @(TimingViol12_2)
begin
   TimingViol12[2] = TimingViol12_2;
end


always @(TimingViol12_1)
begin
   TimingViol12[1] = TimingViol12_1;
end


always @(TimingViol12_0)
begin
   TimingViol12[0] = TimingViol12_0;
end



// conversion from registers to array elements for mask hold violation notifiers


always @(TimingViol13_63)
begin
   TimingViol13[63] = TimingViol13_63;
end


always @(TimingViol13_62)
begin
   TimingViol13[62] = TimingViol13_62;
end


always @(TimingViol13_61)
begin
   TimingViol13[61] = TimingViol13_61;
end


always @(TimingViol13_60)
begin
   TimingViol13[60] = TimingViol13_60;
end


always @(TimingViol13_59)
begin
   TimingViol13[59] = TimingViol13_59;
end


always @(TimingViol13_58)
begin
   TimingViol13[58] = TimingViol13_58;
end


always @(TimingViol13_57)
begin
   TimingViol13[57] = TimingViol13_57;
end


always @(TimingViol13_56)
begin
   TimingViol13[56] = TimingViol13_56;
end


always @(TimingViol13_55)
begin
   TimingViol13[55] = TimingViol13_55;
end


always @(TimingViol13_54)
begin
   TimingViol13[54] = TimingViol13_54;
end


always @(TimingViol13_53)
begin
   TimingViol13[53] = TimingViol13_53;
end


always @(TimingViol13_52)
begin
   TimingViol13[52] = TimingViol13_52;
end


always @(TimingViol13_51)
begin
   TimingViol13[51] = TimingViol13_51;
end


always @(TimingViol13_50)
begin
   TimingViol13[50] = TimingViol13_50;
end


always @(TimingViol13_49)
begin
   TimingViol13[49] = TimingViol13_49;
end


always @(TimingViol13_48)
begin
   TimingViol13[48] = TimingViol13_48;
end


always @(TimingViol13_47)
begin
   TimingViol13[47] = TimingViol13_47;
end


always @(TimingViol13_46)
begin
   TimingViol13[46] = TimingViol13_46;
end


always @(TimingViol13_45)
begin
   TimingViol13[45] = TimingViol13_45;
end


always @(TimingViol13_44)
begin
   TimingViol13[44] = TimingViol13_44;
end


always @(TimingViol13_43)
begin
   TimingViol13[43] = TimingViol13_43;
end


always @(TimingViol13_42)
begin
   TimingViol13[42] = TimingViol13_42;
end


always @(TimingViol13_41)
begin
   TimingViol13[41] = TimingViol13_41;
end


always @(TimingViol13_40)
begin
   TimingViol13[40] = TimingViol13_40;
end


always @(TimingViol13_39)
begin
   TimingViol13[39] = TimingViol13_39;
end


always @(TimingViol13_38)
begin
   TimingViol13[38] = TimingViol13_38;
end


always @(TimingViol13_37)
begin
   TimingViol13[37] = TimingViol13_37;
end


always @(TimingViol13_36)
begin
   TimingViol13[36] = TimingViol13_36;
end


always @(TimingViol13_35)
begin
   TimingViol13[35] = TimingViol13_35;
end


always @(TimingViol13_34)
begin
   TimingViol13[34] = TimingViol13_34;
end


always @(TimingViol13_33)
begin
   TimingViol13[33] = TimingViol13_33;
end


always @(TimingViol13_32)
begin
   TimingViol13[32] = TimingViol13_32;
end


always @(TimingViol13_31)
begin
   TimingViol13[31] = TimingViol13_31;
end


always @(TimingViol13_30)
begin
   TimingViol13[30] = TimingViol13_30;
end


always @(TimingViol13_29)
begin
   TimingViol13[29] = TimingViol13_29;
end


always @(TimingViol13_28)
begin
   TimingViol13[28] = TimingViol13_28;
end


always @(TimingViol13_27)
begin
   TimingViol13[27] = TimingViol13_27;
end


always @(TimingViol13_26)
begin
   TimingViol13[26] = TimingViol13_26;
end


always @(TimingViol13_25)
begin
   TimingViol13[25] = TimingViol13_25;
end


always @(TimingViol13_24)
begin
   TimingViol13[24] = TimingViol13_24;
end


always @(TimingViol13_23)
begin
   TimingViol13[23] = TimingViol13_23;
end


always @(TimingViol13_22)
begin
   TimingViol13[22] = TimingViol13_22;
end


always @(TimingViol13_21)
begin
   TimingViol13[21] = TimingViol13_21;
end


always @(TimingViol13_20)
begin
   TimingViol13[20] = TimingViol13_20;
end


always @(TimingViol13_19)
begin
   TimingViol13[19] = TimingViol13_19;
end


always @(TimingViol13_18)
begin
   TimingViol13[18] = TimingViol13_18;
end


always @(TimingViol13_17)
begin
   TimingViol13[17] = TimingViol13_17;
end


always @(TimingViol13_16)
begin
   TimingViol13[16] = TimingViol13_16;
end


always @(TimingViol13_15)
begin
   TimingViol13[15] = TimingViol13_15;
end


always @(TimingViol13_14)
begin
   TimingViol13[14] = TimingViol13_14;
end


always @(TimingViol13_13)
begin
   TimingViol13[13] = TimingViol13_13;
end


always @(TimingViol13_12)
begin
   TimingViol13[12] = TimingViol13_12;
end


always @(TimingViol13_11)
begin
   TimingViol13[11] = TimingViol13_11;
end


always @(TimingViol13_10)
begin
   TimingViol13[10] = TimingViol13_10;
end


always @(TimingViol13_9)
begin
   TimingViol13[9] = TimingViol13_9;
end


always @(TimingViol13_8)
begin
   TimingViol13[8] = TimingViol13_8;
end


always @(TimingViol13_7)
begin
   TimingViol13[7] = TimingViol13_7;
end


always @(TimingViol13_6)
begin
   TimingViol13[6] = TimingViol13_6;
end


always @(TimingViol13_5)
begin
   TimingViol13[5] = TimingViol13_5;
end


always @(TimingViol13_4)
begin
   TimingViol13[4] = TimingViol13_4;
end


always @(TimingViol13_3)
begin
   TimingViol13[3] = TimingViol13_3;
end


always @(TimingViol13_2)
begin
   TimingViol13[2] = TimingViol13_2;
end


always @(TimingViol13_1)
begin
   TimingViol13[1] = TimingViol13_1;
end


always @(TimingViol13_0)
begin
   TimingViol13[0] = TimingViol13_0;
end



// conversion from registers to array elements for data setup violation notifiers

always @(TimingViol2_63)
begin
   TimingViol2[63] = TimingViol2_63;
end


always @(TimingViol2_62)
begin
   TimingViol2[62] = TimingViol2_62;
end


always @(TimingViol2_61)
begin
   TimingViol2[61] = TimingViol2_61;
end


always @(TimingViol2_60)
begin
   TimingViol2[60] = TimingViol2_60;
end


always @(TimingViol2_59)
begin
   TimingViol2[59] = TimingViol2_59;
end


always @(TimingViol2_58)
begin
   TimingViol2[58] = TimingViol2_58;
end


always @(TimingViol2_57)
begin
   TimingViol2[57] = TimingViol2_57;
end


always @(TimingViol2_56)
begin
   TimingViol2[56] = TimingViol2_56;
end


always @(TimingViol2_55)
begin
   TimingViol2[55] = TimingViol2_55;
end


always @(TimingViol2_54)
begin
   TimingViol2[54] = TimingViol2_54;
end


always @(TimingViol2_53)
begin
   TimingViol2[53] = TimingViol2_53;
end


always @(TimingViol2_52)
begin
   TimingViol2[52] = TimingViol2_52;
end


always @(TimingViol2_51)
begin
   TimingViol2[51] = TimingViol2_51;
end


always @(TimingViol2_50)
begin
   TimingViol2[50] = TimingViol2_50;
end


always @(TimingViol2_49)
begin
   TimingViol2[49] = TimingViol2_49;
end


always @(TimingViol2_48)
begin
   TimingViol2[48] = TimingViol2_48;
end


always @(TimingViol2_47)
begin
   TimingViol2[47] = TimingViol2_47;
end


always @(TimingViol2_46)
begin
   TimingViol2[46] = TimingViol2_46;
end


always @(TimingViol2_45)
begin
   TimingViol2[45] = TimingViol2_45;
end


always @(TimingViol2_44)
begin
   TimingViol2[44] = TimingViol2_44;
end


always @(TimingViol2_43)
begin
   TimingViol2[43] = TimingViol2_43;
end


always @(TimingViol2_42)
begin
   TimingViol2[42] = TimingViol2_42;
end


always @(TimingViol2_41)
begin
   TimingViol2[41] = TimingViol2_41;
end


always @(TimingViol2_40)
begin
   TimingViol2[40] = TimingViol2_40;
end


always @(TimingViol2_39)
begin
   TimingViol2[39] = TimingViol2_39;
end


always @(TimingViol2_38)
begin
   TimingViol2[38] = TimingViol2_38;
end


always @(TimingViol2_37)
begin
   TimingViol2[37] = TimingViol2_37;
end


always @(TimingViol2_36)
begin
   TimingViol2[36] = TimingViol2_36;
end


always @(TimingViol2_35)
begin
   TimingViol2[35] = TimingViol2_35;
end


always @(TimingViol2_34)
begin
   TimingViol2[34] = TimingViol2_34;
end


always @(TimingViol2_33)
begin
   TimingViol2[33] = TimingViol2_33;
end


always @(TimingViol2_32)
begin
   TimingViol2[32] = TimingViol2_32;
end


always @(TimingViol2_31)
begin
   TimingViol2[31] = TimingViol2_31;
end


always @(TimingViol2_30)
begin
   TimingViol2[30] = TimingViol2_30;
end


always @(TimingViol2_29)
begin
   TimingViol2[29] = TimingViol2_29;
end


always @(TimingViol2_28)
begin
   TimingViol2[28] = TimingViol2_28;
end


always @(TimingViol2_27)
begin
   TimingViol2[27] = TimingViol2_27;
end


always @(TimingViol2_26)
begin
   TimingViol2[26] = TimingViol2_26;
end


always @(TimingViol2_25)
begin
   TimingViol2[25] = TimingViol2_25;
end


always @(TimingViol2_24)
begin
   TimingViol2[24] = TimingViol2_24;
end


always @(TimingViol2_23)
begin
   TimingViol2[23] = TimingViol2_23;
end


always @(TimingViol2_22)
begin
   TimingViol2[22] = TimingViol2_22;
end


always @(TimingViol2_21)
begin
   TimingViol2[21] = TimingViol2_21;
end


always @(TimingViol2_20)
begin
   TimingViol2[20] = TimingViol2_20;
end


always @(TimingViol2_19)
begin
   TimingViol2[19] = TimingViol2_19;
end


always @(TimingViol2_18)
begin
   TimingViol2[18] = TimingViol2_18;
end


always @(TimingViol2_17)
begin
   TimingViol2[17] = TimingViol2_17;
end


always @(TimingViol2_16)
begin
   TimingViol2[16] = TimingViol2_16;
end


always @(TimingViol2_15)
begin
   TimingViol2[15] = TimingViol2_15;
end


always @(TimingViol2_14)
begin
   TimingViol2[14] = TimingViol2_14;
end


always @(TimingViol2_13)
begin
   TimingViol2[13] = TimingViol2_13;
end


always @(TimingViol2_12)
begin
   TimingViol2[12] = TimingViol2_12;
end


always @(TimingViol2_11)
begin
   TimingViol2[11] = TimingViol2_11;
end


always @(TimingViol2_10)
begin
   TimingViol2[10] = TimingViol2_10;
end


always @(TimingViol2_9)
begin
   TimingViol2[9] = TimingViol2_9;
end


always @(TimingViol2_8)
begin
   TimingViol2[8] = TimingViol2_8;
end


always @(TimingViol2_7)
begin
   TimingViol2[7] = TimingViol2_7;
end


always @(TimingViol2_6)
begin
   TimingViol2[6] = TimingViol2_6;
end


always @(TimingViol2_5)
begin
   TimingViol2[5] = TimingViol2_5;
end


always @(TimingViol2_4)
begin
   TimingViol2[4] = TimingViol2_4;
end


always @(TimingViol2_3)
begin
   TimingViol2[3] = TimingViol2_3;
end


always @(TimingViol2_2)
begin
   TimingViol2[2] = TimingViol2_2;
end


always @(TimingViol2_1)
begin
   TimingViol2[1] = TimingViol2_1;
end


always @(TimingViol2_0)
begin
   TimingViol2[0] = TimingViol2_0;
end


// conversion from registers to array elements for data hold violation notifiers

always @(TimingViol3_63)
begin
   TimingViol3[63] = TimingViol3_63;
end


always @(TimingViol3_62)
begin
   TimingViol3[62] = TimingViol3_62;
end


always @(TimingViol3_61)
begin
   TimingViol3[61] = TimingViol3_61;
end


always @(TimingViol3_60)
begin
   TimingViol3[60] = TimingViol3_60;
end


always @(TimingViol3_59)
begin
   TimingViol3[59] = TimingViol3_59;
end


always @(TimingViol3_58)
begin
   TimingViol3[58] = TimingViol3_58;
end


always @(TimingViol3_57)
begin
   TimingViol3[57] = TimingViol3_57;
end


always @(TimingViol3_56)
begin
   TimingViol3[56] = TimingViol3_56;
end


always @(TimingViol3_55)
begin
   TimingViol3[55] = TimingViol3_55;
end


always @(TimingViol3_54)
begin
   TimingViol3[54] = TimingViol3_54;
end


always @(TimingViol3_53)
begin
   TimingViol3[53] = TimingViol3_53;
end


always @(TimingViol3_52)
begin
   TimingViol3[52] = TimingViol3_52;
end


always @(TimingViol3_51)
begin
   TimingViol3[51] = TimingViol3_51;
end


always @(TimingViol3_50)
begin
   TimingViol3[50] = TimingViol3_50;
end


always @(TimingViol3_49)
begin
   TimingViol3[49] = TimingViol3_49;
end


always @(TimingViol3_48)
begin
   TimingViol3[48] = TimingViol3_48;
end


always @(TimingViol3_47)
begin
   TimingViol3[47] = TimingViol3_47;
end


always @(TimingViol3_46)
begin
   TimingViol3[46] = TimingViol3_46;
end


always @(TimingViol3_45)
begin
   TimingViol3[45] = TimingViol3_45;
end


always @(TimingViol3_44)
begin
   TimingViol3[44] = TimingViol3_44;
end


always @(TimingViol3_43)
begin
   TimingViol3[43] = TimingViol3_43;
end


always @(TimingViol3_42)
begin
   TimingViol3[42] = TimingViol3_42;
end


always @(TimingViol3_41)
begin
   TimingViol3[41] = TimingViol3_41;
end


always @(TimingViol3_40)
begin
   TimingViol3[40] = TimingViol3_40;
end


always @(TimingViol3_39)
begin
   TimingViol3[39] = TimingViol3_39;
end


always @(TimingViol3_38)
begin
   TimingViol3[38] = TimingViol3_38;
end


always @(TimingViol3_37)
begin
   TimingViol3[37] = TimingViol3_37;
end


always @(TimingViol3_36)
begin
   TimingViol3[36] = TimingViol3_36;
end


always @(TimingViol3_35)
begin
   TimingViol3[35] = TimingViol3_35;
end


always @(TimingViol3_34)
begin
   TimingViol3[34] = TimingViol3_34;
end


always @(TimingViol3_33)
begin
   TimingViol3[33] = TimingViol3_33;
end


always @(TimingViol3_32)
begin
   TimingViol3[32] = TimingViol3_32;
end


always @(TimingViol3_31)
begin
   TimingViol3[31] = TimingViol3_31;
end


always @(TimingViol3_30)
begin
   TimingViol3[30] = TimingViol3_30;
end


always @(TimingViol3_29)
begin
   TimingViol3[29] = TimingViol3_29;
end


always @(TimingViol3_28)
begin
   TimingViol3[28] = TimingViol3_28;
end


always @(TimingViol3_27)
begin
   TimingViol3[27] = TimingViol3_27;
end


always @(TimingViol3_26)
begin
   TimingViol3[26] = TimingViol3_26;
end


always @(TimingViol3_25)
begin
   TimingViol3[25] = TimingViol3_25;
end


always @(TimingViol3_24)
begin
   TimingViol3[24] = TimingViol3_24;
end


always @(TimingViol3_23)
begin
   TimingViol3[23] = TimingViol3_23;
end


always @(TimingViol3_22)
begin
   TimingViol3[22] = TimingViol3_22;
end


always @(TimingViol3_21)
begin
   TimingViol3[21] = TimingViol3_21;
end


always @(TimingViol3_20)
begin
   TimingViol3[20] = TimingViol3_20;
end


always @(TimingViol3_19)
begin
   TimingViol3[19] = TimingViol3_19;
end


always @(TimingViol3_18)
begin
   TimingViol3[18] = TimingViol3_18;
end


always @(TimingViol3_17)
begin
   TimingViol3[17] = TimingViol3_17;
end


always @(TimingViol3_16)
begin
   TimingViol3[16] = TimingViol3_16;
end


always @(TimingViol3_15)
begin
   TimingViol3[15] = TimingViol3_15;
end


always @(TimingViol3_14)
begin
   TimingViol3[14] = TimingViol3_14;
end


always @(TimingViol3_13)
begin
   TimingViol3[13] = TimingViol3_13;
end


always @(TimingViol3_12)
begin
   TimingViol3[12] = TimingViol3_12;
end


always @(TimingViol3_11)
begin
   TimingViol3[11] = TimingViol3_11;
end


always @(TimingViol3_10)
begin
   TimingViol3[10] = TimingViol3_10;
end


always @(TimingViol3_9)
begin
   TimingViol3[9] = TimingViol3_9;
end


always @(TimingViol3_8)
begin
   TimingViol3[8] = TimingViol3_8;
end


always @(TimingViol3_7)
begin
   TimingViol3[7] = TimingViol3_7;
end


always @(TimingViol3_6)
begin
   TimingViol3[6] = TimingViol3_6;
end


always @(TimingViol3_5)
begin
   TimingViol3[5] = TimingViol3_5;
end


always @(TimingViol3_4)
begin
   TimingViol3[4] = TimingViol3_4;
end


always @(TimingViol3_3)
begin
   TimingViol3[3] = TimingViol3_3;
end


always @(TimingViol3_2)
begin
   TimingViol3[2] = TimingViol3_2;
end


always @(TimingViol3_1)
begin
   TimingViol3[1] = TimingViol3_1;
end


always @(TimingViol3_0)
begin
   TimingViol3[0] = TimingViol3_0;
end




ST_SPHDL_160x64m8_bL_main ST_SPHDL_160x64m8_bL_maininst ( Q_glitchint,  Q_dataint, Q_gCKint, RY_rfCKint, RY_rrCKint, RY_frCKint, ICRYint, delTBYPASSint, TBYPASS_D_Qint, TBYPASS_mainint, CKint,  CSNint , TBYPASSint, WENint,  Aint, Dint, Mint, debug_level  , TimingViol0, TimingViol1, TimingViol2, TimingViol3, TimingViol4, TimingViol5, TimingViol6, TimingViol7, TimingViol8, TimingViol9, TimingViol10, TimingViol_ttms_ttmh, TimingViol12, TimingViol13      );

ST_SPHDL_160x64m8_bL_OPschlr ST_SPHDL_160x64m8_bL_OPschlrinst (Qint, RYint,  Q_gCKint, Q_glitchint,  Q_dataint, RY_rfCKint, RY_rrCKint, RY_frCKint, ICRYint, delTBYPASSint, TBYPASS_D_Qint, TBYPASS_mainint  );

defparam ST_SPHDL_160x64m8_bL_maininst.Fault_file_name = Fault_file_name;
defparam ST_SPHDL_160x64m8_bL_maininst.ConfigFault = ConfigFault;
defparam ST_SPHDL_160x64m8_bL_maininst.max_faults = max_faults;
defparam ST_SPHDL_160x64m8_bL_maininst.MEM_INITIALIZE = MEM_INITIALIZE;
defparam ST_SPHDL_160x64m8_bL_maininst.BinaryInit = BinaryInit;
defparam ST_SPHDL_160x64m8_bL_maininst.InitFileName = InitFileName;

endmodule

`endif

`delay_mode_path
`disable_portfaults
`nosuppress_faults
`endcelldefine





