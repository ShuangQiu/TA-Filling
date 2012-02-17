// Verilog pattern output written by  TetraMAX (TM)  D-2010.03-SP5-i101014_173458 
// Date: Fri Feb 17 15:47:05 2012
// Module tested: alu

//     Uncollapsed Stuck Fault Summary Report
// -----------------------------------------------
// fault class                     code   #faults
// ------------------------------  ----  ---------
// Detected                         DT         54
// Possibly detected                PT          0
// Undetectable                     UD          0
// ATPG untestable                  AU          0
// Not detected                     ND         22
// -----------------------------------------------
// total faults                                76
// test coverage                            71.05%
// -----------------------------------------------
// 
//            Pattern Summary Report
// -----------------------------------------------
// #internal patterns                           7
//     #basic_scan patterns                     7
// #external patterns (tmax_patterns6.v)        6
//     #basic_scan patterns                     6
// -----------------------------------------------
// 
// There are no rule fails
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
   parameter NINPUTS = 5, NOUTPUTS = 2;
   wire [0:NOUTPUTS-1] PO; reg [0:NOUTPUTS-1] ALLPOS, XPCT, MASK;
   reg [0:NINPUTS-1] PI, ALLPIS;
   reg [0:8*(NAMELENGTH-1)] POnames [0:NOUTPUTS-1];
   event IDDQ;

   wire sel;
   wire [1:0] ain;
   wire [1:0] bin;
   wire [1:0] zout;

   // map PI[] vector to DUT inputs and bidis
   assign ain = PI[0:1];
   assign bin = PI[2:3];
   assign sel = PI[4];

   // map DUT outputs and bidis to PO[] vector
   assign
      PO[0] = zout[1] ,
      PO[1] = zout[0] ;

   // instantiate the design into the testbench
   alu dut (
      .ain(ain),
      .bin(bin),
      .sel(sel),
      .zout(zout)   );


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

      POnames[0] = "zout[1]";
      POnames[1] = "zout[0]";
      nofails = 0; pattern = -1; lastpattern = 0;
      prev_pat = -2; error_banner = -2;
      /*** No test setup procedure ***/


      /*** Non-scan test ***/

      if (verbose >= 1) $display("// %t : Begin patterns, first pattern = 0", $time);
pattern = 0; // 0
ALLPIS = 5'b11101;
XPCT = 2'b10;
MASK = 2'b11;
#0 ->capture;
#200; // 200

pattern = 1; // 200
ALLPIS = 5'b01101;
XPCT = 2'b00;
MASK = 2'b11;
#0 ->capture;
#200; // 400

pattern = 2; // 400
ALLPIS = 5'b01111;
XPCT = 2'b01;
MASK = 2'b11;
#0 ->capture;
#200; // 600

pattern = 3; // 600
ALLPIS = 5'b10011;
XPCT = 2'b00;
MASK = 2'b11;
#0 ->capture;
#200; // 800

pattern = 4; // 800
ALLPIS = 5'b11010;
XPCT = 2'b00;
MASK = 2'b11;
#0 ->capture;
#200; // 1000

pattern = 5; // 1000
ALLPIS = 5'b11010;
XPCT = 2'b00;
MASK = 2'b11;
#0 ->capture;
#200; // 1200

pattern = 6; // 1200
ALLPIS = 5'b01110;
XPCT = 2'b00;
MASK = 2'b11;
#0 ->capture;
#200; // 1400

      $display("// %t : Simulation of %0d patterns completed with %0d errors\n", $time, pattern+1, nofails);
      if (verbose >=2) $finish(2);
      /* else */ $finish(0);
   end
endmodule
