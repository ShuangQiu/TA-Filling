// Verilog pattern output written by  TetraMAX (TM)  D-2010.03-SP5-i101014_173458 
// Date: Wed Feb 22 15:36:54 2012
// Module tested: b01

//     Uncollapsed Stuck Fault Summary Report
// -----------------------------------------------
// fault class                     code   #faults
// ------------------------------  ----  ---------
// Detected                         DT        208
// Possibly detected                PT          4
// Undetectable                     UD          0
// ATPG untestable                  AU          0
// Not detected                     ND          0
// -----------------------------------------------
// total faults                               212
// test coverage                            99.06%
// -----------------------------------------------
// 
//            Pattern Summary Report
// -----------------------------------------------
// #internal patterns                          12
//     #full_sequential patterns               12
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

pattern = 1; // 3200
#0 PI = 4'b1011;
#100; // 3300
XPCT = 2'b00;
MASK = 2'b11;
#0 ->measurePO_default_WFT;
#100; // 3400
#0 PI = 4'b0100;
#100; // 3500
XPCT = 2'b00;
MASK = 2'b11;
#0 ->measurePO_default_WFT;
#100; // 3600
#0 PI = 4'b0001;
#100; // 3700
XPCT = 2'b10;
MASK = 2'b11;
#0 ->measurePO_default_WFT;
#100; // 3800
#0 PI = 4'b1000;
#100; // 3900
XPCT = 2'b10;
MASK = 2'b11;
#0 ->measurePO_default_WFT;
#100; // 4000
#0 PI = 4'b1000;
#100; // 4100
XPCT = 2'b10;
MASK = 2'b11;
#0 ->measurePO_default_WFT;
#100; // 4200
#0 PI = 4'b1100;
#100; // 4300
XPCT = 2'b10;
MASK = 2'b11;
#0 ->measurePO_default_WFT;
#100; // 4400
#0 PI = 4'b1101;
#100; // 4500
XPCT = 2'b00;
MASK = 2'b11;
#0 ->measurePO_default_WFT;
#100; // 4600
#0 PI = 4'b1000;
#100; // 4700
XPCT = 2'b00;
MASK = 2'b11;
#0 ->measurePO_default_WFT;
#100; // 4800
#0 PI = 4'b1001;
#100; // 4900
XPCT = 2'b00;
MASK = 2'b11;
#0 ->measurePO_default_WFT;
#100; // 5000
#0 PI = 4'b1000;
#100; // 5100
XPCT = 2'b00;
MASK = 2'b11;
#0 ->measurePO_default_WFT;
#100; // 5200
#0 PI = 4'b0100;
#100; // 5300
XPCT = 2'b00;
MASK = 2'b11;
#0 ->measurePO_default_WFT;
#100; // 5400
#0 PI = 4'b0000;
#100; // 5500
XPCT = 2'b00;
MASK = 2'b11;
#0 ->measurePO_default_WFT;
#100; // 5600
#0 PI = 4'b1100;
#100; // 5700
XPCT = 2'b00;
MASK = 2'b11;
#0 ->measurePO_default_WFT;
#100; // 5800
#0 PI = 4'b1101;
#100; // 5900
XPCT = 2'b10;
MASK = 2'b11;
#0 ->measurePO_default_WFT;
#100; // 6000
#0 PI = 4'b0100;
#100; // 6100
XPCT = 2'b10;
MASK = 2'b11;
#0 ->measurePO_default_WFT;
#100; // 6200
#0 PI = 4'b1101;
#100; // 6300
XPCT = 2'b11;
MASK = 2'b11;
#0 ->measurePO_default_WFT;
#100; // 6400

pattern = 2; // 6400
#0 PI = 4'b1011;
#100; // 6500
XPCT = 2'b00;
MASK = 2'b11;
#0 ->measurePO_default_WFT;
#100; // 6600
#0 PI = 4'b1100;
#100; // 6700
XPCT = 2'b00;
MASK = 2'b11;
#0 ->measurePO_default_WFT;
#100; // 6800
#0 PI = 4'b1001;
#100; // 6900
XPCT = 2'b00;
MASK = 2'b11;
#0 ->measurePO_default_WFT;
#100; // 7000
#0 PI = 4'b1000;
#100; // 7100
XPCT = 2'b00;
MASK = 2'b11;
#0 ->measurePO_default_WFT;
#100; // 7200
#0 PI = 4'b1101;
#100; // 7300
XPCT = 2'b00;
MASK = 2'b11;
#0 ->measurePO_default_WFT;
#100; // 7400
#0 PI = 4'b1000;
#100; // 7500
XPCT = 2'b00;
MASK = 2'b11;
#0 ->measurePO_default_WFT;
#100; // 7600
#0 PI = 4'b0001;
#100; // 7700
XPCT = 2'b00;
MASK = 2'b11;
#0 ->measurePO_default_WFT;
#100; // 7800

pattern = 3; // 7800
#0 PI = 4'b0111;
#100; // 7900
XPCT = 2'b00;
MASK = 2'b11;
#0 ->measurePO_default_WFT;
#100; // 8000
#0 PI = 4'b0100;
#100; // 8100
XPCT = 2'b00;
MASK = 2'b11;
#0 ->measurePO_default_WFT;
#100; // 8200
#0 PI = 4'b0001;
#100; // 8300
XPCT = 2'b10;
MASK = 2'b11;
#0 ->measurePO_default_WFT;
#100; // 8400
#0 PI = 4'b0100;
#100; // 8500
XPCT = 2'b10;
MASK = 2'b11;
#0 ->measurePO_default_WFT;
#100; // 8600
#0 PI = 4'b1001;
#100; // 8700
XPCT = 2'b10;
MASK = 2'b11;
#0 ->measurePO_default_WFT;
#100; // 8800
#0 PI = 4'b0100;
#100; // 8900
XPCT = 2'b10;
MASK = 2'b11;
#0 ->measurePO_default_WFT;
#100; // 9000
#0 PI = 4'b0101;
#100; // 9100
XPCT = 2'b10;
MASK = 2'b11;
#0 ->measurePO_default_WFT;
#100; // 9200
#0 PI = 4'b1101;
#100; // 9300
XPCT = 2'b10;
MASK = 2'b11;
#0 ->measurePO_default_WFT;
#100; // 9400
#0 PI = 4'b0000;
#100; // 9500
XPCT = 2'b10;
MASK = 2'b11;
#0 ->measurePO_default_WFT;
#100; // 9600
#0 PI = 4'b1000;
#100; // 9700
XPCT = 2'b10;
MASK = 2'b11;
#0 ->measurePO_default_WFT;
#100; // 9800
#0 PI = 4'b1001;
#100; // 9900
XPCT = 2'b10;
MASK = 2'b11;
#0 ->measurePO_default_WFT;
#100; // 10000
#0 PI = 4'b0100;
#100; // 10100
XPCT = 2'b10;
MASK = 2'b11;
#0 ->measurePO_default_WFT;
#100; // 10200
#0 PI = 4'b0101;
#100; // 10300
XPCT = 2'b10;
MASK = 2'b11;
#0 ->measurePO_default_WFT;
#100; // 10400

pattern = 4; // 10400
#0 PI = 4'b0011;
#100; // 10500
XPCT = 2'b00;
MASK = 2'b11;
#0 ->measurePO_default_WFT;
#100; // 10600
#0 PI = 4'b0100;
#100; // 10700
XPCT = 2'b00;
MASK = 2'b11;
#0 ->measurePO_default_WFT;
#100; // 10800
#0 PI = 4'b0001;
#100; // 10900
XPCT = 2'b10;
MASK = 2'b11;
#0 ->measurePO_default_WFT;
#100; // 11000
#0 PI = 4'b1100;
#100; // 11100
XPCT = 2'b10;
MASK = 2'b11;
#0 ->measurePO_default_WFT;
#100; // 11200
#0 PI = 4'b1001;
#100; // 11300
XPCT = 2'b00;
MASK = 2'b11;
#0 ->measurePO_default_WFT;
#100; // 11400
#0 PI = 4'b1100;
#100; // 11500
XPCT = 2'b00;
MASK = 2'b11;
#0 ->measurePO_default_WFT;
#100; // 11600
#0 PI = 4'b0101;
#100; // 11700
XPCT = 2'b10;
MASK = 2'b11;
#0 ->measurePO_default_WFT;
#100; // 11800
#0 PI = 4'b1000;
#100; // 11900
XPCT = 2'b10;
MASK = 2'b11;
#0 ->measurePO_default_WFT;
#100; // 12000
#0 PI = 4'b1001;
#100; // 12100
XPCT = 2'b00;
MASK = 2'b11;
#0 ->measurePO_default_WFT;
#100; // 12200
#0 PI = 4'b0100;
#100; // 12300
XPCT = 2'b00;
MASK = 2'b11;
#0 ->measurePO_default_WFT;
#100; // 12400
#0 PI = 4'b0001;
#100; // 12500
XPCT = 2'b11;
MASK = 2'b11;
#0 ->measurePO_default_WFT;
#100; // 12600
#0 PI = 4'b1101;
#100; // 12700
XPCT = 2'b11;
MASK = 2'b11;
#0 ->measurePO_default_WFT;
#100; // 12800
#0 PI = 4'b1000;
#100; // 12900
XPCT = 2'b11;
MASK = 2'b11;
#0 ->measurePO_default_WFT;
#100; // 13000
#0 PI = 4'b1100;
#100; // 13100
XPCT = 2'b11;
MASK = 2'b11;
#0 ->measurePO_default_WFT;
#100; // 13200
#0 PI = 4'b1001;
#100; // 13300
XPCT = 2'b00;
MASK = 2'b11;
#0 ->measurePO_default_WFT;
#100; // 13400
#0 PI = 4'b1000;
#100; // 13500
XPCT = 2'b00;
MASK = 2'b11;
#0 ->measurePO_default_WFT;
#100; // 13600
#0 PI = 4'b1000;
#100; // 13700
XPCT = 2'b00;
MASK = 2'b11;
#0 ->measurePO_default_WFT;
#100; // 13800
#0 PI = 4'b0000;
#100; // 13900
XPCT = 2'b00;
MASK = 2'b11;
#0 ->measurePO_default_WFT;
#100; // 14000
#0 PI = 4'b0101;
#100; // 14100
XPCT = 2'b10;
MASK = 2'b11;
#0 ->measurePO_default_WFT;
#100; // 14200
#0 PI = 4'b0000;
#100; // 14300
XPCT = 2'b10;
MASK = 2'b11;
#0 ->measurePO_default_WFT;
#100; // 14400
#0 PI = 4'b0100;
#100; // 14500
XPCT = 2'b10;
MASK = 2'b11;
#0 ->measurePO_default_WFT;
#100; // 14600
#0 PI = 4'b0100;
#100; // 14700
XPCT = 2'b10;
MASK = 2'b11;
#0 ->measurePO_default_WFT;
#100; // 14800
#0 PI = 4'b1001;
#100; // 14900
XPCT = 2'b10;
MASK = 2'b11;
#0 ->measurePO_default_WFT;
#100; // 15000
#0 PI = 4'b0000;
#100; // 15100
XPCT = 2'b10;
MASK = 2'b11;
#0 ->measurePO_default_WFT;
#100; // 15200
#0 PI = 4'b1000;
#100; // 15300
XPCT = 2'b10;
MASK = 2'b11;
#0 ->measurePO_default_WFT;
#100; // 15400
#0 PI = 4'b1100;
#100; // 15500
XPCT = 2'b10;
MASK = 2'b11;
#0 ->measurePO_default_WFT;
#100; // 15600
#0 PI = 4'b1001;
#100; // 15700
XPCT = 2'b00;
MASK = 2'b11;
#0 ->measurePO_default_WFT;
#100; // 15800
#0 PI = 4'b1101;
#100; // 15900
XPCT = 2'b00;
MASK = 2'b11;
#0 ->measurePO_default_WFT;
#100; // 16000
#0 PI = 4'b1100;
#100; // 16100
XPCT = 2'b00;
MASK = 2'b11;
#0 ->measurePO_default_WFT;
#100; // 16200
#0 PI = 4'b0100;
#100; // 16300
XPCT = 2'b00;
MASK = 2'b11;
#0 ->measurePO_default_WFT;
#100; // 16400
#0 PI = 4'b1001;
#100; // 16500
XPCT = 2'b00;
MASK = 2'b11;
#0 ->measurePO_default_WFT;
#100; // 16600

pattern = 5; // 16600
#0 PI = 4'b0010;
#100; // 16700
XPCT = 2'b00;
MASK = 2'b11;
#0 ->measurePO_default_WFT;
#100; // 16800
#0 PI = 4'b0100;
#100; // 16900
XPCT = 2'b00;
MASK = 2'b11;
#0 ->measurePO_default_WFT;
#100; // 17000
#0 PI = 4'b1001;
#100; // 17100
XPCT = 2'b10;
MASK = 2'b11;
#0 ->measurePO_default_WFT;
#100; // 17200
#0 PI = 4'b1100;
#100; // 17300
XPCT = 2'b10;
MASK = 2'b11;
#0 ->measurePO_default_WFT;
#100; // 17400
#0 PI = 4'b1101;
#100; // 17500
XPCT = 2'b00;
MASK = 2'b11;
#0 ->measurePO_default_WFT;
#100; // 17600
#0 PI = 4'b1100;
#100; // 17700
XPCT = 2'b00;
MASK = 2'b11;
#0 ->measurePO_default_WFT;
#100; // 17800
#0 PI = 4'b1101;
#100; // 17900
XPCT = 2'b10;
MASK = 2'b11;
#0 ->measurePO_default_WFT;
#100; // 18000
#0 PI = 4'b1000;
#100; // 18100
XPCT = 2'b10;
MASK = 2'b11;
#0 ->measurePO_default_WFT;
#100; // 18200
#0 PI = 4'b1001;
#100; // 18300
XPCT = 2'b00;
MASK = 2'b11;
#0 ->measurePO_default_WFT;
#100; // 18400
#0 PI = 4'b1100;
#100; // 18500
XPCT = 2'b00;
MASK = 2'b11;
#0 ->measurePO_default_WFT;
#100; // 18600
#0 PI = 4'b0001;
#100; // 18700
XPCT = 2'b01;
MASK = 2'b11;
#0 ->measurePO_default_WFT;
#100; // 18800
#0 PI = 4'b0000;
#100; // 18900
XPCT = 2'b01;
MASK = 2'b11;
#0 ->measurePO_default_WFT;
#100; // 19000
#0 PI = 4'b0101;
#100; // 19100
XPCT = 2'b10;
MASK = 2'b11;
#0 ->measurePO_default_WFT;
#100; // 19200
#0 PI = 4'b1100;
#100; // 19300
XPCT = 2'b10;
MASK = 2'b11;
#0 ->measurePO_default_WFT;
#100; // 19400
#0 PI = 4'b0001;
#100; // 19500
XPCT = 2'b00;
MASK = 2'b11;
#0 ->measurePO_default_WFT;
#100; // 19600
#0 PI = 4'b1101;
#100; // 19700
XPCT = 2'b00;
MASK = 2'b11;
#0 ->measurePO_default_WFT;
#100; // 19800
#0 PI = 4'b1000;
#100; // 19900
XPCT = 2'b00;
MASK = 2'b11;
#0 ->measurePO_default_WFT;
#100; // 20000
#0 PI = 4'b0000;
#100; // 20100
XPCT = 2'b00;
MASK = 2'b11;
#0 ->measurePO_default_WFT;
#100; // 20200
#0 PI = 4'b0001;
#100; // 20300
XPCT = 2'b10;
MASK = 2'b11;
#0 ->measurePO_default_WFT;
#100; // 20400

pattern = 6; // 20400
#0 PI = 4'b0011;
#100; // 20500
XPCT = 2'b00;
MASK = 2'b11;
#0 ->measurePO_default_WFT;
#100; // 20600
#0 PI = 4'b1100;
#100; // 20700
XPCT = 2'b00;
MASK = 2'b11;
#0 ->measurePO_default_WFT;
#100; // 20800
#0 PI = 4'b0101;
#100; // 20900
XPCT = 2'b00;
MASK = 2'b11;
#0 ->measurePO_default_WFT;
#100; // 21000
#0 PI = 4'b1100;
#100; // 21100
XPCT = 2'b00;
MASK = 2'b11;
#0 ->measurePO_default_WFT;
#100; // 21200
#0 PI = 4'b0101;
#100; // 21300
XPCT = 2'b10;
MASK = 2'b11;
#0 ->measurePO_default_WFT;
#100; // 21400
#0 PI = 4'b0101;
#100; // 21500
XPCT = 2'b10;
MASK = 2'b11;
#0 ->measurePO_default_WFT;
#100; // 21600
#0 PI = 4'b0100;
#100; // 21700
XPCT = 2'b10;
MASK = 2'b11;
#0 ->measurePO_default_WFT;
#100; // 21800
#0 PI = 4'b1100;
#100; // 21900
XPCT = 2'b10;
MASK = 2'b11;
#0 ->measurePO_default_WFT;
#100; // 22000
#0 PI = 4'b0101;
#100; // 22100
XPCT = 2'b10;
MASK = 2'b11;
#0 ->measurePO_default_WFT;
#100; // 22200
#0 PI = 4'b0100;
#100; // 22300
XPCT = 2'b10;
MASK = 2'b11;
#0 ->measurePO_default_WFT;
#100; // 22400
#0 PI = 4'b1001;
#100; // 22500
XPCT = 2'b00;
MASK = 2'b11;
#0 ->measurePO_default_WFT;
#100; // 22600

pattern = 7; // 22600
#0 PI = 4'b1011;
#100; // 22700
XPCT = 2'b00;
MASK = 2'b11;
#0 ->measurePO_default_WFT;
#100; // 22800
#0 PI = 4'b0100;
#100; // 22900
XPCT = 2'b00;
MASK = 2'b11;
#0 ->measurePO_default_WFT;
#100; // 23000
#0 PI = 4'b0001;
#100; // 23100
XPCT = 2'b10;
MASK = 2'b11;
#0 ->measurePO_default_WFT;
#100; // 23200
#0 PI = 4'b0000;
#100; // 23300
XPCT = 2'b10;
MASK = 2'b11;
#0 ->measurePO_default_WFT;
#100; // 23400
#0 PI = 4'b1001;
#100; // 23500
XPCT = 2'b00;
MASK = 2'b11;
#0 ->measurePO_default_WFT;
#100; // 23600
#0 PI = 4'b1001;
#100; // 23700
XPCT = 2'b00;
MASK = 2'b11;
#0 ->measurePO_default_WFT;
#100; // 23800
#0 PI = 4'b0100;
#100; // 23900
XPCT = 2'b00;
MASK = 2'b11;
#0 ->measurePO_default_WFT;
#100; // 24000
#0 PI = 4'b1100;
#100; // 24100
XPCT = 2'b00;
MASK = 2'b11;
#0 ->measurePO_default_WFT;
#100; // 24200
#0 PI = 4'b0101;
#100; // 24300
XPCT = 2'b00;
MASK = 2'b11;
#0 ->measurePO_default_WFT;
#100; // 24400
#0 PI = 4'b0000;
#100; // 24500
XPCT = 2'b00;
MASK = 2'b11;
#0 ->measurePO_default_WFT;
#100; // 24600
#0 PI = 4'b0001;
#100; // 24700
XPCT = 2'b10;
MASK = 2'b11;
#0 ->measurePO_default_WFT;
#100; // 24800
#0 PI = 4'b1100;
#100; // 24900
XPCT = 2'b10;
MASK = 2'b11;
#0 ->measurePO_default_WFT;
#100; // 25000
#0 PI = 4'b1001;
#100; // 25100
XPCT = 2'b00;
MASK = 2'b11;
#0 ->measurePO_default_WFT;
#100; // 25200
#0 PI = 4'b0100;
#100; // 25300
XPCT = 2'b00;
MASK = 2'b11;
#0 ->measurePO_default_WFT;
#100; // 25400
#0 PI = 4'b0000;
#100; // 25500
XPCT = 2'b00;
MASK = 2'b11;
#0 ->measurePO_default_WFT;
#100; // 25600
#0 PI = 4'b1100;
#100; // 25700
XPCT = 2'b00;
MASK = 2'b11;
#0 ->measurePO_default_WFT;
#100; // 25800
#0 PI = 4'b1101;
#100; // 25900
XPCT = 2'b10;
MASK = 2'b11;
#0 ->measurePO_default_WFT;
#100; // 26000
#0 PI = 4'b1000;
#100; // 26100
XPCT = 2'b10;
MASK = 2'b11;
#0 ->measurePO_default_WFT;
#100; // 26200
#0 PI = 4'b1001;
#100; // 26300
XPCT = 2'b00;
MASK = 2'b11;
#0 ->measurePO_default_WFT;
#100; // 26400

pattern = 8; // 26400
#0 PI = 4'b1011;
#100; // 26500
XPCT = 2'b00;
MASK = 2'b11;
#0 ->measurePO_default_WFT;
#100; // 26600
#0 PI = 4'b0000;
#100; // 26700
XPCT = 2'b00;
MASK = 2'b11;
#0 ->measurePO_default_WFT;
#100; // 26800
#0 PI = 4'b0101;
#100; // 26900
XPCT = 2'b00;
MASK = 2'b11;
#0 ->measurePO_default_WFT;
#100; // 27000
#0 PI = 4'b0000;
#100; // 27100
XPCT = 2'b00;
MASK = 2'b11;
#0 ->measurePO_default_WFT;
#100; // 27200
#0 PI = 4'b1100;
#100; // 27300
XPCT = 2'b00;
MASK = 2'b11;
#0 ->measurePO_default_WFT;
#100; // 27400
#0 PI = 4'b1100;
#100; // 27500
XPCT = 2'b00;
MASK = 2'b11;
#0 ->measurePO_default_WFT;
#100; // 27600
#0 PI = 4'b1001;
#100; // 27700
XPCT = 2'b00;
MASK = 2'b11;
#0 ->measurePO_default_WFT;
#100; // 27800
#0 PI = 4'b0000;
#100; // 27900
XPCT = 2'b00;
MASK = 2'b11;
#0 ->measurePO_default_WFT;
#100; // 28000
#0 PI = 4'b0001;
#100; // 28100
XPCT = 2'b10;
MASK = 2'b11;
#0 ->measurePO_default_WFT;
#100; // 28200
#0 PI = 4'b0000;
#100; // 28300
XPCT = 2'b10;
MASK = 2'b11;
#0 ->measurePO_default_WFT;
#100; // 28400
#0 PI = 4'b0001;
#100; // 28500
XPCT = 2'b00;
MASK = 2'b11;
#0 ->measurePO_default_WFT;
#100; // 28600
#0 PI = 4'b1001;
#100; // 28700
XPCT = 2'b00;
MASK = 2'b11;
#0 ->measurePO_default_WFT;
#100; // 28800
#0 PI = 4'b0100;
#100; // 28900
XPCT = 2'b00;
MASK = 2'b11;
#0 ->measurePO_default_WFT;
#100; // 29000
#0 PI = 4'b0100;
#100; // 29100
XPCT = 2'b00;
MASK = 2'b11;
#0 ->measurePO_default_WFT;
#100; // 29200
#0 PI = 4'b1001;
#100; // 29300
XPCT = 2'b10;
MASK = 2'b11;
#0 ->measurePO_default_WFT;
#100; // 29400
#0 PI = 4'b0000;
#100; // 29500
XPCT = 2'b10;
MASK = 2'b11;
#0 ->measurePO_default_WFT;
#100; // 29600
#0 PI = 4'b1100;
#100; // 29700
XPCT = 2'b10;
MASK = 2'b11;
#0 ->measurePO_default_WFT;
#100; // 29800
#0 PI = 4'b1100;
#100; // 29900
XPCT = 2'b10;
MASK = 2'b11;
#0 ->measurePO_default_WFT;
#100; // 30000
#0 PI = 4'b0001;
#100; // 30100
XPCT = 2'b00;
MASK = 2'b11;
#0 ->measurePO_default_WFT;
#100; // 30200
#0 PI = 4'b1000;
#100; // 30300
XPCT = 2'b00;
MASK = 2'b11;
#0 ->measurePO_default_WFT;
#100; // 30400
#0 PI = 4'b1100;
#100; // 30500
XPCT = 2'b00;
MASK = 2'b11;
#0 ->measurePO_default_WFT;
#100; // 30600
#0 PI = 4'b0100;
#100; // 30700
XPCT = 2'b00;
MASK = 2'b11;
#0 ->measurePO_default_WFT;
#100; // 30800
#0 PI = 4'b0001;
#100; // 30900
XPCT = 2'b00;
MASK = 2'b11;
#0 ->measurePO_default_WFT;
#100; // 31000

pattern = 9; // 31000
#0 PI = 4'b1011;
#100; // 31100
XPCT = 2'b00;
MASK = 2'b11;
#0 ->measurePO_default_WFT;
#100; // 31200
#0 PI = 4'b1100;
#100; // 31300
XPCT = 2'b00;
MASK = 2'b11;
#0 ->measurePO_default_WFT;
#100; // 31400
#0 PI = 4'b0101;
#100; // 31500
XPCT = 2'b00;
MASK = 2'b11;
#0 ->measurePO_default_WFT;
#100; // 31600
#0 PI = 4'b1100;
#100; // 31700
XPCT = 2'b00;
MASK = 2'b11;
#0 ->measurePO_default_WFT;
#100; // 31800
#0 PI = 4'b1100;
#100; // 31900
XPCT = 2'b00;
MASK = 2'b11;
#0 ->measurePO_default_WFT;
#100; // 32000
#0 PI = 4'b0000;
#100; // 32100
XPCT = 2'b00;
MASK = 2'b11;
#0 ->measurePO_default_WFT;
#100; // 32200
#0 PI = 4'b1001;
#100; // 32300
XPCT = 2'b10;
MASK = 2'b11;
#0 ->measurePO_default_WFT;
#100; // 32400
#0 PI = 4'b1100;
#100; // 32500
XPCT = 2'b10;
MASK = 2'b11;
#0 ->measurePO_default_WFT;
#100; // 32600
#0 PI = 4'b0001;
#100; // 32700
XPCT = 2'b00;
MASK = 2'b11;
#0 ->measurePO_default_WFT;
#100; // 32800
#0 PI = 4'b0100;
#100; // 32900
XPCT = 2'b00;
MASK = 2'b11;
#0 ->measurePO_default_WFT;
#100; // 33000
#0 PI = 4'b1000;
#100; // 33100
XPCT = 2'b00;
MASK = 2'b11;
#0 ->measurePO_default_WFT;
#100; // 33200
#0 PI = 4'b1000;
#100; // 33300
XPCT = 2'b00;
MASK = 2'b11;
#0 ->measurePO_default_WFT;
#100; // 33400
#0 PI = 4'b1101;
#100; // 33500
XPCT = 2'b00;
MASK = 2'b11;
#0 ->measurePO_default_WFT;
#100; // 33600
#0 PI = 4'b0100;
#100; // 33700
XPCT = 2'b00;
MASK = 2'b11;
#0 ->measurePO_default_WFT;
#100; // 33800
#0 PI = 4'b0001;
#100; // 33900
XPCT = 2'b11;
MASK = 2'b11;
#0 ->measurePO_default_WFT;
#100; // 34000

pattern = 10; // 34000
#0 PI = 4'b0010;
#100; // 34100
XPCT = 2'b00;
MASK = 2'b11;
#0 ->measurePO_default_WFT;
#100; // 34200
#0 PI = 4'b0000;
#100; // 34300
XPCT = 2'b00;
MASK = 2'b11;
#0 ->measurePO_default_WFT;
#100; // 34400
#0 PI = 4'b1001;
#100; // 34500
XPCT = 2'b00;
MASK = 2'b11;
#0 ->measurePO_default_WFT;
#100; // 34600
#0 PI = 4'b0000;
#100; // 34700
XPCT = 2'b00;
MASK = 2'b11;
#0 ->measurePO_default_WFT;
#100; // 34800
#0 PI = 4'b0000;
#100; // 34900
XPCT = 2'b00;
MASK = 2'b11;
#0 ->measurePO_default_WFT;
#100; // 35000
#0 PI = 4'b0001;
#100; // 35100
XPCT = 2'b00;
MASK = 2'b11;
#0 ->measurePO_default_WFT;
#100; // 35200
#0 PI = 4'b0000;
#100; // 35300
XPCT = 2'b00;
MASK = 2'b11;
#0 ->measurePO_default_WFT;
#100; // 35400
#0 PI = 4'b0100;
#100; // 35500
XPCT = 2'b00;
MASK = 2'b11;
#0 ->measurePO_default_WFT;
#100; // 35600
#0 PI = 4'b1101;
#100; // 35700
XPCT = 2'b10;
MASK = 2'b11;
#0 ->measurePO_default_WFT;
#100; // 35800
#0 PI = 4'b1001;
#100; // 35900
XPCT = 2'b10;
MASK = 2'b11;
#0 ->measurePO_default_WFT;
#100; // 36000
#0 PI = 4'b1000;
#100; // 36100
XPCT = 2'b10;
MASK = 2'b11;
#0 ->measurePO_default_WFT;
#100; // 36200
#0 PI = 4'b1100;
#100; // 36300
XPCT = 2'b10;
MASK = 2'b11;
#0 ->measurePO_default_WFT;
#100; // 36400
#0 PI = 4'b0101;
#100; // 36500
XPCT = 2'b00;
MASK = 2'b11;
#0 ->measurePO_default_WFT;
#100; // 36600
#0 PI = 4'b0100;
#100; // 36700
XPCT = 2'b00;
MASK = 2'b11;
#0 ->measurePO_default_WFT;
#100; // 36800
#0 PI = 4'b0101;
#100; // 36900
XPCT = 2'b11;
MASK = 2'b11;
#0 ->measurePO_default_WFT;
#100; // 37000

pattern = 11; // 37000
#0 PI = 4'b1011;
#100; // 37100
XPCT = 2'b00;
MASK = 2'b11;
#0 ->measurePO_default_WFT;
#100; // 37200
#0 PI = 4'b1100;
#100; // 37300
XPCT = 2'b00;
MASK = 2'b11;
#0 ->measurePO_default_WFT;
#100; // 37400
#0 PI = 4'b0101;
#100; // 37500
XPCT = 2'b00;
MASK = 2'b11;
#0 ->measurePO_default_WFT;
#100; // 37600
#0 PI = 4'b0100;
#100; // 37700
XPCT = 2'b00;
MASK = 2'b11;
#0 ->measurePO_default_WFT;
#100; // 37800
#0 PI = 4'b0101;
#100; // 37900
XPCT = 2'b00;
MASK = 2'b11;
#0 ->measurePO_default_WFT;
#100; // 38000
#0 PI = 4'b0100;
#100; // 38100
XPCT = 2'b00;
MASK = 2'b11;
#0 ->measurePO_default_WFT;
#100; // 38200
#0 PI = 4'b0001;
#100; // 38300
XPCT = 2'b00;
MASK = 2'b11;
#0 ->measurePO_default_WFT;
#100; // 38400

      $display("// %t : Simulation of %0d patterns completed with %0d errors\n", $time, pattern+1, nofails);
      if (verbose >=2) $finish(2);
      /* else */ $finish(0);
   end
endmodule
