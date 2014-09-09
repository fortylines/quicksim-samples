/* Copyright (c) 2014, Fortylines LLC
   All rights reserved.

 Redistribution and use in source and binary forms, with or without
 modification, are permitted provided that the following conditions are met:

 1. Redistributions of source code must retain the above copyright notice,
    this list of conditions and the following disclaimer.
 2. Redistributions in binary form must reproduce the above copyright
    notice, this list of conditions and the following disclaimer in the
    documentation and/or other materials provided with the distribution.

 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED
 TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
 PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR
 CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
 EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
 PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
 OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
 WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
 OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
 ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

/*
 This file implements a 4-bit carry look-ahead adder bundled with an exhaustive
 testbench.

 Simulate with iverilog:

     $ iverilog 4-bit-carry-look-ahead-adder.v
     $ ./a.out

*/

module sum(
   output result,
   input left, right, carry_in
);
   assign result = left ^ right ^ carry_in;
endmodule // sum


module carry_block_4bit(
   output [3:0] carry,
   input [3:0]  left, right,
   input        carry_in
);

   wire [3:0]   gen, prp; /* generate and propagate */

   assign gen[0] = left[0] & right[0];
   assign prp[0] = left[0] ^ right[0];
   assign gen[1] = left[1] & right[1];
   assign prp[1] = left[1] ^ right[1];
   assign gen[2] = left[2] & right[2];
   assign prp[2] = left[2] ^ right[2];
   assign gen[3] = left[3] & right[3];
   assign prp[3] = left[3] ^ right[3];
   assign carry[0] = gen[0] | (prp[0] & carry_in);
   assign carry[1] = gen[1] | prp[1]
     & (gen[0] | (prp[0] & carry_in));
   assign carry[2] = gen[2] | prp[2]
     & (gen[1] | prp[1] & (gen[0] | (prp[0] & carry_in)));
   assign carry[3] = gen[3] | prp[3]
     & (gen[2] | prp[2] & (gen[1] | prp[1] & (gen[0] | (prp[0] & carry_in))));

endmodule // carry_block_4bit


module carry_lookahead_adder_4bit(
    output [3:0] sum,
    output carry_out,
    input [3:0] left, right,
    input carry_in
);
   wire [4:1] carry;

   carry_block_4bit b0(carry[4:1], left[3:0], right[3:0], carry_in);
   sum a0(sum[0], left[0], right[0], carry_in);
   sum a1(sum[1], left[1], right[1], carry[1]);
   sum a2(sum[2], left[2], right[2], carry[2]);
   sum a3(sum[3], left[3], right[3], carry[3]);
   assign carry_out = carry[4];

endmodule // carry_lookahead_adder


module test_adder_4bit;
   // inputs
   reg [3:0] left;
   reg [3:0] right;
   reg carry_in;
   // outputs
   wire [3:0] sum;
   wire       cary_out;

   carry_lookahead_adder_4bit adder(
                           .sum(sum),
                           .carry_out(carry_out),
                           .left(left),
                           .right(right),
                           .carry_in(carry_in)
                           );

   initial begin
      left = 0;
      right = 0;
      carry_in = 0;

      #50; // wait for reset to complete

      // exhaustive testing, going through all combinations.
      while (left < 15) begin
         while (right < 15) begin
            #10 right = right + 1;
         end
         #10 left = left + 1; right = right + 1;
      end
      while (right < 15) begin
         #10 right = right + 1;
      end
      #10 left = left + 1; right = right + 1; carry_in = 1;
      while (left < 15) begin
         while (right < 15) begin
            #10 right = right + 1;
         end
         #10 left = left + 1; right = right + 1;
      end
      while (right < 15) begin
         #10 right = right + 1;
      end

   end // initial begin

   initial begin
      $monitor("time=", $time,,
               "left=%b right=%b carry_in=%b : sum=%b carry_out=%b",
               left, right, carry_in, sum, carry_out);
      /* The following statement will (by default) create a dump.vcd
       when the testbench is executed by iverilog. */
      $dumpvars(0, test_adder_4bit);
   end

endmodule // test_adder_4bit
