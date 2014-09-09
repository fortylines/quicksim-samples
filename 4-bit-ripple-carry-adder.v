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
 This file implements a 4-bit ripple carry adder bundled with an exhaustive
 testbench.

 Simulate with iverilog:

     $ iverilog 4-bit-ripple-carry-adder.v
     $ ./a.out

*/

module half_adder(
    output sum, carry_out,
    input  left, right
);
   assign sum = left ^ right;
   assign carry_out = left & right;

endmodule // half_adder


module full_adder(
    output sum, carry_out,
    input left, right, carry_in
);
   wire   sum1, carry1, carry2;
   half_adder ha1(sum1, carry1, left, right);
   half_adder ha2(sum, carry2, sum1, carry_in);
   assign carry_out = carry1 | carry2;

endmodule // full_adder


module ripple_adder_4bit(
    output [3:0] sum,
    output carry_out,
    input [3:0] left, right,
    input carry_in
);
   wire   carry1, carry2, carry3;
   full_adder fa1(sum[0], carry1, left[0], right[0], carry_in);
   full_adder fa2(sum[1], carry2, left[1], right[1], carry1);
   full_adder fa3(sum[2], carry3, left[2], right[2], carry2);
   full_adder fa4(sum[3], carry_out, left[3], right[3], carry3);

endmodule // ripple_adder_4bit


module test_adder_4bit;
   // inputs
   reg [3:0] left;
   reg [3:0] right;
   reg carry_in;
   // outputs
   wire [3:0] sum;
   wire       cary_out;

   ripple_adder_4bit adder(
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

