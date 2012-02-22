// Verilog pattern output written by  TetraMAX (TM)  D-2010.03-SP5-i101014_173458 
// Date: Wed Feb 22 16:39:30 2012
// Module tested: b01

//     Uncollapsed Stuck Fault Summary Report
// -----------------------------------------------
// fault class                     code   #faults
// ------------------------------  ----  ---------
// Detected                         DT        101
// Possibly detected                PT          8
// Undetectable                     UD          0
// ATPG untestable                  AU          0
// Not detected                     ND        103
// -----------------------------------------------
// total faults                               212
// test coverage                            49.53%
// -----------------------------------------------
// 
//            Pattern Summary Report
// -----------------------------------------------
// #internal patterns                           1
//     #full_sequential patterns                1
// -----------------------------------------------
// 
// rule  severity  #fails  description
// ----  --------  ------  ---------------------------------
// N20   warning        1  underspecified UDP
// C2    warning        5  unstable nonscan DFF when clocks off
// 
// There are no clocks
// There are no constraint ports
// There are no equivalent pins
// There are no net connections

`timescale 1 ns / 1 ns

//
// --- NOTE: Remove the comment to define 'tmax_iddq' to activate processing of IDDQ events
//     Or use '+define+tmax_iddq' on the verilog compile line
//
//`define tmax_iddq

module AAA_tmax_testbench_1_16 ;
   parameter NAMELENGTH = 200; // max length of names reported in fails
   integer nofails, bit, pattern, lastpattern;
   integer error_banner; // flag for tracking displayed error banner
   integer loads;        // number of load_unloads for current pattern
   integer patm1;        // pattern - 1
   integer patp1;        // pattern + lastpattern
   integer prev_pat;     // previous pattern number
   integer report_interval; // report pattern progress every Nth pattern
   integer verbose;      // message verbosity level
   parameter NINPUTS = 4, NOUTPUTS = 2;
   wire [0:NOUTPUTS-1] PO; reg [0:NOUTPUTS-1] ALLPOS, XPCT, MASK;
   reg [0:NINPUTS-1] PI, ALLPIS;
   reg [0:8*(NAMELENGTH-1)] POnames [0:NOUTPUTS-1];
   event IDDQ;

   wire line1;
   wire line2;
   wire reset;
   wire outp;
   wire overflw;
   wire clock;

   // map PI[] vector to DUT inputs and bidis
   assign line1 = PI[0];
   assign line2 = PI[1];
   assign reset = PI[2];
   assign clock = PI[3];

   // map DUT outputs and bidis to PO[] vector
   assign
      PO[0] = outp ,
      PO[1] = overflw ;

   // instantiate the design into the testbench
   b01 dut (
      .line1(line1),
      .line2(line2),
      .reset(reset),
      .outp(outp),
      .overflw(overflw),
      .clock(clock)   );


   integer errshown;
   event measurePO;
   always @ measurePO begin
      if (((XPCT&MASK) !== (ALLPOS&MASK)) || (XPCT !== (~(~XPCT)))) begin
         errshown = 0;
         for (bit = 0; bit < NOUTPUTS; bit=bit + 1) begin
            if (MASK[bit]==1'b1) begin
               if (XPCT[bit] !== ALLPOS[bit]) begin
                  if (errshown==0) $display("\n// *** ERROR during capture pattern %0d, T=%t", pattern, $time);
                  $display("  %0d %0s (exp=%b, got=%b)", pattern, POnames[bit], XPCT[bit], ALLPOS[bit]);
                  nofails = nofails + 1; errshown = 1;
               end
            end
         end
      end
   end

   event forcePI_default_WFT;
   always @ forcePI_default_WFT begin
      PI = ALLPIS;
   end
   event measurePO_default_WFT;
   always @ measurePO_default_WFT begin
      #40;
      ALLPOS = PO;
      #0; #0 -> measurePO;
      `ifdef tmax_iddq
         #0; ->IDDQ;
      `endif
   end

   always @ IDDQ begin
   `ifdef tmax_iddq
      $ssi_iddq("strobe_try");
      $ssi_iddq("status drivers leaky AAA_tmax_testbench_1_16.leaky");
   `endif
   end

   event capture;
   always @ capture begin
      ->forcePI_default_WFT;
      #100; ->measurePO_default_WFT;
   end


   initial begin

      //
      // --- establish a default time format for %t
      //
      $timeformat(-9,2," ns",18);

      //
      // --- default verbosity to 2 but also allow user override by
      //     using '+define+tmax_msg=N' on verilog compile line.
      //
      `ifdef tmax_msg
         verbose = `tmax_msg ;
      `else
         verbose = 2 ;
      `endif

      //
      // --- default pattern reporting interval to 5 but also allow user
      //     override by using '+define+tmax_rpt=N' on verilog compile line.
      //
      `ifdef tmax_rpt
         report_interval = `tmax_rpt ;
      `else
         report_interval = 5 ;
      `endif

      //
      // --- support generating Extened VCD output by using
      //     '+define+tmax_vcde' on verilog compile line.
      //
      `ifdef tmax_vcde
         // extended VCD, see IEEE Verilog P1364.1-1999 Draft 2
         if (verbose >= 2) $display("// %t : opening Extended VCD output file", $time);
         $dumpports( dut, "sim_vcde.out");
      `endif

      //
      // --- IDDQ PLI initialization
      //     User may activite by using '+define+tmax_iddq' on verilog compile line.
      //     Or by defining `tmax_iddq in this file.
      //
      `ifdef tmax_iddq
         if (verbose >= 3) $display("// %t : Initializing IDDQ PLI", $time);
         $ssi_iddq("dut AAA_tmax_testbench_1_16.dut");
         $ssi_iddq("verb on");
         $ssi_iddq("cycle 0");
         //
         // --- User may select one of the following two methods for fault seeding:
         //     #1 faults seeded by PLI (default)
         //     #2 faults supplied in a file
         //     Comment out the unused lines as needed (precede with '//').
         //     Replace the 'FAULTLIST_FILE' string with the actual file pathname.
         //
         $ssi_iddq("seed SA AAA_tmax_testbench_1_16.dut");   // no file, faults seeded by PLI
         //
         // $ssi_iddq("scope AAA_tmax_testbench_1_16.dut");   // set scope for faults from a file
         // $ssi_iddq("read_tmax FAULTLIST_FILE"); // read faults from a file
         //
      `endif

      POnames[0] = "outp";
      POnames[1] = "overflw";
      nofails = 0; pattern = -1; lastpattern = 0;
      prev_pat = -2; error_banner = -2;
      /*** No test setup procedure ***/


      /*** Non-scan test ***/

      if (verbose >= 1) $display("// %t : Begin patterns, first pattern = 0", $time);
pattern = 0; // 0
#0 PI = 4'b1111;
#100; // 100
XPCT = 2'b00;
MASK = 2'b11;
#0 ->measurePO_default_WFT;
#100; // 200
#0 PI = 4'b1100;
#100; // 300
XPCT = 2'b00;
MASK = 2'b11;
#0 ->measurePO_default_WFT;
#100; // 400
#0 PI = 4'b0001;
#100; // 500
XPCT = 2'b00;
MASK = 2'b11;
#0 ->measurePO_default_WFT;
#100; // 600
#0 PI = 4'b1001;
#100; // 700
XPCT = 2'b00;
MASK = 2'b11;
#0 ->measurePO_default_WFT;
#100; // 800
#0 PI = 4'b1000;
#100; // 900
XPCT = 2'b00;
MASK = 2'b11;
#0 ->measurePO_default_WFT;
#100; // 1000
#0 PI = 4'b0000;
#100; // 1100
XPCT = 2'b00;
MASK = 2'b11;
#0 ->measurePO_default_WFT;
#100; // 1200
#0 PI = 4'b0001;
#100; // 1300
XPCT = 2'b10;
MASK = 2'b11;
#0 ->measurePO_default_WFT;
#100; // 1400
#0 PI = 4'b1000;
#100; // 1500
XPCT = 2'b10;
MASK = 2'b11;
#0 ->measurePO_default_WFT;
#100; // 1600
#0 PI = 4'b1000;
#100; // 1700
XPCT = 2'b10;
MASK = 2'b11;
#0 ->measurePO_default_WFT;
#100; // 1800
#0 PI = 4'b1100;
#100; // 1900
XPCT = 2'b10;
MASK = 2'b11;
#0 ->measurePO_default_WFT;
#100; // 2000
#0 PI = 4'b1101;
#100; // 2100
XPCT = 2'b00;
MASK = 2'b11;
#0 ->measurePO_default_WFT;
#100; // 2200
#0 PI = 4'b0100;
#100; // 2300
XPCT = 2'b00;
MASK = 2'b11;
#0 ->measurePO_default_WFT;
#100; // 2400
#0 PI = 4'b1000;
#100; // 2500
XPCT = 2'b00;
MASK = 2'b11;
#0 ->measurePO_default_WFT;
#100; // 2600
#0 PI = 4'b0000;
#100; // 2700
XPCT = 2'b00;
MASK = 2'b11;
#0 ->measurePO_default_WFT;
#100; // 2800
#0 PI = 4'b1100;
#100; // 2900
XPCT = 2'b00;
MASK = 2'b11;
#0 ->measurePO_default_WFT;
#100; // 3000
#0 PI = 4'b1101;
#100; // 3100
XPCT = 2'b10;
MASK = 2'b11;
#0 ->measurePO_default_WFT;
#100; // 3200

      $display("// %t : Simulation of %0d patterns completed with %0d errors\n", $time, pattern+1, nofails);
      if (verbose >=2) $finish(2);
      /* else */ $finish(0);
   end
endmodule
