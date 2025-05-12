//  
//  
//  ------------------------------------------------------------
//    STMicroelectronics N.V. 2010
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
//    Project        : CMP_EIT_100909          
//    Division       : Not known               
//    Creation date  : 09 September 2010       
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

   words = 2048
   bits  = 8
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



module ST_SPHDL_2048x8m8_L (Q, RY,CK, CSN, TBYPASS, WEN, A, D    );   
 
    parameter
        Fault_file_name = "ST_SPHDL_2048x8m8_L_faults.txt",
        ConfigFault = 0,
        max_faults = 20,
        MEM_INITIALIZE  = 1'b0,
        BinaryInit = 1'b0,
        InitFileName = "ST_SPHDL_2048x8m8_L.cde",
        Corruption_Read_Violation = 1,
        Debug_mode = "all_warning_mode",
        InstancePath = "ST_SPHDL_2048x8m8_L";
    
    parameter
        Words = 2048,
        Bits = 8,
        Addr = 11,
        mux = 8,
        Rows = Words/mux;




   


    parameter
        WordX = 8'bx,
        AddrX = 11'bx,
        Word0 = 8'b0,
        X = 1'bx;


	output [Bits-1 : 0] Q;
        
        output RY;   
        
        input [Bits-1 : 0] D;
	input [Addr-1 : 0] A;
	        
        input CK, CSN, TBYPASS, WEN;

        
        
        

        



        reg [Bits-1 : 0] Qint;
         
           
	wire [Bits-1 : 0] Dint,Mint;
        
        assign Mint=8'b0;
        
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


module ST_SPHDL_2048x8m8_L_main ( Q_glitch,  Q_data, Q_gCK, RY_rfCK, RY_rrCK, RY_frCK, ICRY, delTBYPASS, TBYPASS_D_Q, TBYPASS_main, CK,  CSN, TBYPASS, WEN,  A, D, M,debug_level ,TimingViol0, TimingViol1, TimingViol2, TimingViol3, TimingViol4, TimingViol5, TimingViol6, TimingViol7, TimingViol8, TimingViol9, TimingViol10, TimingViol_ttms_ttmh, TimingViol12, TimingViol13     );
    
   parameter
        Fault_file_name = "ST_SPHDL_2048x8m8_L_faults.txt",
        ConfigFault = 0,
        max_faults = 20,
        MEM_INITIALIZE  = 1'b0,
        BinaryInit = 1'b0,
        InitFileName = "ST_SPHDL_2048x8m8_L.cde",
        Debug_mode = "ALL_WARNING_MODE",
        InstancePath = "ST_SPHDL_2048x8m8_L";

   parameter
        Words = 2048,
        Bits = 8,
        Addr = 11,
        mux = 8,
        Rows = Words/mux;


       

   


    parameter
        WordX = 8'bx,
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
   

	if (!ICGFlag) (CK *> (Q_glitch[0] : D[0])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[1] : D[1])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[2] : D[2])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[3] : D[3])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[4] : D[4])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[5] : D[5])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[6] : D[6])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[7] : D[7])) = (th, th);

	if (!ICGFlag) (CK *> (Q_gCK[0] : D[0])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[1] : D[1])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[2] : D[2])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[3] : D[3])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[4] : D[4])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[5] : D[5])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[6] : D[6])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[7] : D[7])) = (th, th);

	if (!TBYPASS) (TBYPASS *> delTBYPASS[0]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[1]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[2]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[3]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[4]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[5]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[6]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[7]) = (0);
	if (TBYPASS) (TBYPASS *> delTBYPASS[0]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[1]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[2]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[3]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[4]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[5]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[6]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[7]) = (ttmq);
      (D[0] *> TBYPASS_D_Q[0]) = (tdq, tdq);
      (D[1] *> TBYPASS_D_Q[1]) = (tdq, tdq);
      (D[2] *> TBYPASS_D_Q[2]) = (tdq, tdq);
      (D[3] *> TBYPASS_D_Q[3]) = (tdq, tdq);
      (D[4] *> TBYPASS_D_Q[4]) = (tdq, tdq);
      (D[5] *> TBYPASS_D_Q[5]) = (tdq, tdq);
      (D[6] *> TBYPASS_D_Q[6]) = (tdq, tdq);
      (D[7] *> TBYPASS_D_Q[7]) = (tdq, tdq);


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

module ST_SPHDL_2048x8m8_L_OPschlr (QINT,  RYINT, Q_gCK, Q_glitch,  Q_data, RY_rfCK, RY_rrCK, RY_frCK, ICRY, delTBYPASS, TBYPASS_D_Q, TBYPASS_main  );

    parameter
        Words = 2048,
        Bits = 8,
        Addr = 11;
        

    parameter
        WordX = 8'bx,
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


module ST_SPHDL_2048x8m8_L (Q, RY, CK, CSN, TBYPASS, WEN,  A,  D   );
   

    parameter 
        Fault_file_name = "ST_SPHDL_2048x8m8_L_faults.txt",   
        ConfigFault = 0,
        max_faults = 20,
        MEM_INITIALIZE = 1'b0,
        BinaryInit     = 1'b0,
        InitFileName   = "ST_SPHDL_2048x8m8_L.cde",     
        Corruption_Read_Violation = 1,
        Debug_mode = "ALL_WARNING_MODE",
        InstancePath = "ST_SPHDL_2048x8m8_L";

    parameter
        Words = 2048,
        Bits = 8,
        Addr = 11,
        mux = 8,
        Rows = Words/mux;
        






    parameter
        WordX = 8'bx,
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
   
   assign Mint = 8'b0;
   
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
 and (CSWEMTBYPASS[0], MEN[0], CSWETBYPASSN);
 and (CSWEMTBYPASS[1], MEN[1], CSWETBYPASSN);
 and (CSWEMTBYPASS[2], MEN[2], CSWETBYPASSN);
 and (CSWEMTBYPASS[3], MEN[3], CSWETBYPASSN);
 and (CSWEMTBYPASS[4], MEN[4], CSWETBYPASSN);
 and (CSWEMTBYPASS[5], MEN[5], CSWETBYPASSN);
 and (CSWEMTBYPASS[6], MEN[6], CSWETBYPASSN);
 and (CSWEMTBYPASS[7], MEN[7], CSWETBYPASSN);

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
	$setup(negedge D[0], posedge CK &&& (CSWEMTBYPASS[0] != 0), tds, TimingViol2_0);
	$setup(negedge D[1], posedge CK &&& (CSWEMTBYPASS[1] != 0), tds, TimingViol2_1);
	$setup(negedge D[2], posedge CK &&& (CSWEMTBYPASS[2] != 0), tds, TimingViol2_2);
	$setup(negedge D[3], posedge CK &&& (CSWEMTBYPASS[3] != 0), tds, TimingViol2_3);
	$setup(negedge D[4], posedge CK &&& (CSWEMTBYPASS[4] != 0), tds, TimingViol2_4);
	$setup(negedge D[5], posedge CK &&& (CSWEMTBYPASS[5] != 0), tds, TimingViol2_5);
	$setup(negedge D[6], posedge CK &&& (CSWEMTBYPASS[6] != 0), tds, TimingViol2_6);
	$setup(negedge D[7], posedge CK &&& (CSWEMTBYPASS[7] != 0), tds, TimingViol2_7);
	$hold(posedge CK &&& (CSWEMTBYPASS[0] != 0), posedge D[0], tdh, TimingViol3_0);
	$hold(posedge CK &&& (CSWEMTBYPASS[1] != 0), posedge D[1], tdh, TimingViol3_1);
	$hold(posedge CK &&& (CSWEMTBYPASS[2] != 0), posedge D[2], tdh, TimingViol3_2);
	$hold(posedge CK &&& (CSWEMTBYPASS[3] != 0), posedge D[3], tdh, TimingViol3_3);
	$hold(posedge CK &&& (CSWEMTBYPASS[4] != 0), posedge D[4], tdh, TimingViol3_4);
	$hold(posedge CK &&& (CSWEMTBYPASS[5] != 0), posedge D[5], tdh, TimingViol3_5);
	$hold(posedge CK &&& (CSWEMTBYPASS[6] != 0), posedge D[6], tdh, TimingViol3_6);
	$hold(posedge CK &&& (CSWEMTBYPASS[7] != 0), posedge D[7], tdh, TimingViol3_7);
	$hold(posedge CK &&& (CSWEMTBYPASS[0] != 0), negedge D[0], tdh, TimingViol3_0);
	$hold(posedge CK &&& (CSWEMTBYPASS[1] != 0), negedge D[1], tdh, TimingViol3_1);
	$hold(posedge CK &&& (CSWEMTBYPASS[2] != 0), negedge D[2], tdh, TimingViol3_2);
	$hold(posedge CK &&& (CSWEMTBYPASS[3] != 0), negedge D[3], tdh, TimingViol3_3);
	$hold(posedge CK &&& (CSWEMTBYPASS[4] != 0), negedge D[4], tdh, TimingViol3_4);
	$hold(posedge CK &&& (CSWEMTBYPASS[5] != 0), negedge D[5], tdh, TimingViol3_5);
	$hold(posedge CK &&& (CSWEMTBYPASS[6] != 0), negedge D[6], tdh, TimingViol3_6);
	$hold(posedge CK &&& (CSWEMTBYPASS[7] != 0), negedge D[7], tdh, TimingViol3_7);

        
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




ST_SPHDL_2048x8m8_L_main ST_SPHDL_2048x8m8_L_maininst ( Q_glitchint,  Q_dataint, Q_gCKint, RY_rfCKint, RY_rrCKint, RY_frCKint, ICRYint, delTBYPASSint, TBYPASS_D_Qint, TBYPASS_mainint, CKint,  CSNint , TBYPASSint, WENint,  Aint, Dint, Mint, debug_level  , TimingViol0, TimingViol1, TimingViol2, TimingViol3, TimingViol4, TimingViol5, TimingViol6, TimingViol7, TimingViol8, TimingViol9, TimingViol10, TimingViol_ttms_ttmh, TimingViol12, TimingViol13      );

ST_SPHDL_2048x8m8_L_OPschlr ST_SPHDL_2048x8m8_L_OPschlrinst (Qint, RYint,  Q_gCKint, Q_glitchint,  Q_dataint, RY_rfCKint, RY_rrCKint, RY_frCKint, ICRYint, delTBYPASSint, TBYPASS_D_Qint, TBYPASS_mainint  );

defparam ST_SPHDL_2048x8m8_L_maininst.Fault_file_name = Fault_file_name;
defparam ST_SPHDL_2048x8m8_L_maininst.ConfigFault = ConfigFault;
defparam ST_SPHDL_2048x8m8_L_maininst.max_faults = max_faults;
defparam ST_SPHDL_2048x8m8_L_maininst.MEM_INITIALIZE = MEM_INITIALIZE;
defparam ST_SPHDL_2048x8m8_L_maininst.BinaryInit = BinaryInit;
defparam ST_SPHDL_2048x8m8_L_maininst.InitFileName = InitFileName;

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

   words = 1024
   bits  = 8
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



module ST_SPHDL_1024x8m8_L (Q, RY,CK, CSN, TBYPASS, WEN, A, D    );   
 
    parameter
        Fault_file_name = "ST_SPHDL_1024x8m8_L_faults.txt",
        ConfigFault = 0,
        max_faults = 20,
        MEM_INITIALIZE  = 1'b0,
        BinaryInit = 1'b0,
        InitFileName = "ST_SPHDL_1024x8m8_L.cde",
        Corruption_Read_Violation = 1,
        Debug_mode = "all_warning_mode",
        InstancePath = "ST_SPHDL_1024x8m8_L";
    
    parameter
        Words = 1024,
        Bits = 8,
        Addr = 10,
        mux = 8,
        Rows = Words/mux;




   


    parameter
        WordX = 8'bx,
        AddrX = 10'bx,
        Word0 = 8'b0,
        X = 1'bx;


	output [Bits-1 : 0] Q;
        
        output RY;   
        
        input [Bits-1 : 0] D;
	input [Addr-1 : 0] A;
	        
        input CK, CSN, TBYPASS, WEN;

        
        
        

        



        reg [Bits-1 : 0] Qint;
         
           
	wire [Bits-1 : 0] Dint,Mint;
        
        assign Mint=8'b0;
        
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


module ST_SPHDL_1024x8m8_L_main ( Q_glitch,  Q_data, Q_gCK, RY_rfCK, RY_rrCK, RY_frCK, ICRY, delTBYPASS, TBYPASS_D_Q, TBYPASS_main, CK,  CSN, TBYPASS, WEN,  A, D, M,debug_level ,TimingViol0, TimingViol1, TimingViol2, TimingViol3, TimingViol4, TimingViol5, TimingViol6, TimingViol7, TimingViol8, TimingViol9, TimingViol10, TimingViol_ttms_ttmh, TimingViol12, TimingViol13     );
    
   parameter
        Fault_file_name = "ST_SPHDL_1024x8m8_L_faults.txt",
        ConfigFault = 0,
        max_faults = 20,
        MEM_INITIALIZE  = 1'b0,
        BinaryInit = 1'b0,
        InitFileName = "ST_SPHDL_1024x8m8_L.cde",
        Debug_mode = "ALL_WARNING_MODE",
        InstancePath = "ST_SPHDL_1024x8m8_L";

   parameter
        Words = 1024,
        Bits = 8,
        Addr = 10,
        mux = 8,
        Rows = Words/mux;


       

   


    parameter
        WordX = 8'bx,
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
   

	if (!ICGFlag) (CK *> (Q_glitch[0] : D[0])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[1] : D[1])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[2] : D[2])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[3] : D[3])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[4] : D[4])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[5] : D[5])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[6] : D[6])) = (th, th);
	if (!ICGFlag) (CK *> (Q_glitch[7] : D[7])) = (th, th);

	if (!ICGFlag) (CK *> (Q_gCK[0] : D[0])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[1] : D[1])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[2] : D[2])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[3] : D[3])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[4] : D[4])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[5] : D[5])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[6] : D[6])) = (th, th);
	if (!ICGFlag) (CK *> (Q_gCK[7] : D[7])) = (th, th);

	if (!TBYPASS) (TBYPASS *> delTBYPASS[0]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[1]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[2]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[3]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[4]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[5]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[6]) = (0);
	if (!TBYPASS) (TBYPASS *> delTBYPASS[7]) = (0);
	if (TBYPASS) (TBYPASS *> delTBYPASS[0]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[1]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[2]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[3]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[4]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[5]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[6]) = (ttmq);
	if (TBYPASS) (TBYPASS *> delTBYPASS[7]) = (ttmq);
      (D[0] *> TBYPASS_D_Q[0]) = (tdq, tdq);
      (D[1] *> TBYPASS_D_Q[1]) = (tdq, tdq);
      (D[2] *> TBYPASS_D_Q[2]) = (tdq, tdq);
      (D[3] *> TBYPASS_D_Q[3]) = (tdq, tdq);
      (D[4] *> TBYPASS_D_Q[4]) = (tdq, tdq);
      (D[5] *> TBYPASS_D_Q[5]) = (tdq, tdq);
      (D[6] *> TBYPASS_D_Q[6]) = (tdq, tdq);
      (D[7] *> TBYPASS_D_Q[7]) = (tdq, tdq);


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

module ST_SPHDL_1024x8m8_L_OPschlr (QINT,  RYINT, Q_gCK, Q_glitch,  Q_data, RY_rfCK, RY_rrCK, RY_frCK, ICRY, delTBYPASS, TBYPASS_D_Q, TBYPASS_main  );

    parameter
        Words = 1024,
        Bits = 8,
        Addr = 10;
        

    parameter
        WordX = 8'bx,
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


module ST_SPHDL_1024x8m8_L (Q, RY, CK, CSN, TBYPASS, WEN,  A,  D   );
   

    parameter 
        Fault_file_name = "ST_SPHDL_1024x8m8_L_faults.txt",   
        ConfigFault = 0,
        max_faults = 20,
        MEM_INITIALIZE = 1'b0,
        BinaryInit     = 1'b0,
        InitFileName   = "ST_SPHDL_1024x8m8_L.cde",     
        Corruption_Read_Violation = 1,
        Debug_mode = "ALL_WARNING_MODE",
        InstancePath = "ST_SPHDL_1024x8m8_L";

    parameter
        Words = 1024,
        Bits = 8,
        Addr = 10,
        mux = 8,
        Rows = Words/mux;
        






    parameter
        WordX = 8'bx,
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
   
   assign Mint = 8'b0;
   
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
 and (CSWEMTBYPASS[0], MEN[0], CSWETBYPASSN);
 and (CSWEMTBYPASS[1], MEN[1], CSWETBYPASSN);
 and (CSWEMTBYPASS[2], MEN[2], CSWETBYPASSN);
 and (CSWEMTBYPASS[3], MEN[3], CSWETBYPASSN);
 and (CSWEMTBYPASS[4], MEN[4], CSWETBYPASSN);
 and (CSWEMTBYPASS[5], MEN[5], CSWETBYPASSN);
 and (CSWEMTBYPASS[6], MEN[6], CSWETBYPASSN);
 and (CSWEMTBYPASS[7], MEN[7], CSWETBYPASSN);

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
	$setup(negedge D[0], posedge CK &&& (CSWEMTBYPASS[0] != 0), tds, TimingViol2_0);
	$setup(negedge D[1], posedge CK &&& (CSWEMTBYPASS[1] != 0), tds, TimingViol2_1);
	$setup(negedge D[2], posedge CK &&& (CSWEMTBYPASS[2] != 0), tds, TimingViol2_2);
	$setup(negedge D[3], posedge CK &&& (CSWEMTBYPASS[3] != 0), tds, TimingViol2_3);
	$setup(negedge D[4], posedge CK &&& (CSWEMTBYPASS[4] != 0), tds, TimingViol2_4);
	$setup(negedge D[5], posedge CK &&& (CSWEMTBYPASS[5] != 0), tds, TimingViol2_5);
	$setup(negedge D[6], posedge CK &&& (CSWEMTBYPASS[6] != 0), tds, TimingViol2_6);
	$setup(negedge D[7], posedge CK &&& (CSWEMTBYPASS[7] != 0), tds, TimingViol2_7);
	$hold(posedge CK &&& (CSWEMTBYPASS[0] != 0), posedge D[0], tdh, TimingViol3_0);
	$hold(posedge CK &&& (CSWEMTBYPASS[1] != 0), posedge D[1], tdh, TimingViol3_1);
	$hold(posedge CK &&& (CSWEMTBYPASS[2] != 0), posedge D[2], tdh, TimingViol3_2);
	$hold(posedge CK &&& (CSWEMTBYPASS[3] != 0), posedge D[3], tdh, TimingViol3_3);
	$hold(posedge CK &&& (CSWEMTBYPASS[4] != 0), posedge D[4], tdh, TimingViol3_4);
	$hold(posedge CK &&& (CSWEMTBYPASS[5] != 0), posedge D[5], tdh, TimingViol3_5);
	$hold(posedge CK &&& (CSWEMTBYPASS[6] != 0), posedge D[6], tdh, TimingViol3_6);
	$hold(posedge CK &&& (CSWEMTBYPASS[7] != 0), posedge D[7], tdh, TimingViol3_7);
	$hold(posedge CK &&& (CSWEMTBYPASS[0] != 0), negedge D[0], tdh, TimingViol3_0);
	$hold(posedge CK &&& (CSWEMTBYPASS[1] != 0), negedge D[1], tdh, TimingViol3_1);
	$hold(posedge CK &&& (CSWEMTBYPASS[2] != 0), negedge D[2], tdh, TimingViol3_2);
	$hold(posedge CK &&& (CSWEMTBYPASS[3] != 0), negedge D[3], tdh, TimingViol3_3);
	$hold(posedge CK &&& (CSWEMTBYPASS[4] != 0), negedge D[4], tdh, TimingViol3_4);
	$hold(posedge CK &&& (CSWEMTBYPASS[5] != 0), negedge D[5], tdh, TimingViol3_5);
	$hold(posedge CK &&& (CSWEMTBYPASS[6] != 0), negedge D[6], tdh, TimingViol3_6);
	$hold(posedge CK &&& (CSWEMTBYPASS[7] != 0), negedge D[7], tdh, TimingViol3_7);

        
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




ST_SPHDL_1024x8m8_L_main ST_SPHDL_1024x8m8_L_maininst ( Q_glitchint,  Q_dataint, Q_gCKint, RY_rfCKint, RY_rrCKint, RY_frCKint, ICRYint, delTBYPASSint, TBYPASS_D_Qint, TBYPASS_mainint, CKint,  CSNint , TBYPASSint, WENint,  Aint, Dint, Mint, debug_level  , TimingViol0, TimingViol1, TimingViol2, TimingViol3, TimingViol4, TimingViol5, TimingViol6, TimingViol7, TimingViol8, TimingViol9, TimingViol10, TimingViol_ttms_ttmh, TimingViol12, TimingViol13      );

ST_SPHDL_1024x8m8_L_OPschlr ST_SPHDL_1024x8m8_L_OPschlrinst (Qint, RYint,  Q_gCKint, Q_glitchint,  Q_dataint, RY_rfCKint, RY_rrCKint, RY_frCKint, ICRYint, delTBYPASSint, TBYPASS_D_Qint, TBYPASS_mainint  );

defparam ST_SPHDL_1024x8m8_L_maininst.Fault_file_name = Fault_file_name;
defparam ST_SPHDL_1024x8m8_L_maininst.ConfigFault = ConfigFault;
defparam ST_SPHDL_1024x8m8_L_maininst.max_faults = max_faults;
defparam ST_SPHDL_1024x8m8_L_maininst.MEM_INITIALIZE = MEM_INITIALIZE;
defparam ST_SPHDL_1024x8m8_L_maininst.BinaryInit = BinaryInit;
defparam ST_SPHDL_1024x8m8_L_maininst.InitFileName = InitFileName;

endmodule

`endif

`delay_mode_path
`disable_portfaults
`nosuppress_faults
`endcelldefine





