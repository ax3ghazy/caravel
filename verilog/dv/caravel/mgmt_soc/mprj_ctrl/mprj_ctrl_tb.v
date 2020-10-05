
`timescale 1 ns / 1 ps

`include "caravel.v"
`include "spiflash.v"

module mprj_ctrl_tb;
	reg clock;

	reg SDI, CSB, SCK, RSTB;

	wire [1:0] gpio;
	wire flash_csb;
	wire flash_clk;
	wire flash_io0;
	wire flash_io1;
	wire flash_io2;
	wire flash_io3;
	wire SDO;

	// External clock is used by default.  Make this artificially fast for the
	// simulation.  Normally this would be a slow clock and the digital PLL
	// would be the fast clock.

	always #10 clock <= (clock === 1'b0);

	initial begin
		clock = 0;
	end

	initial begin
		$dumpfile("mprj_ctrl_tb.vcd");
		$dumpvars(0, mprj_ctrl_tb);
		repeat (25) begin
			repeat (1000) @(posedge XCLK);
			$display("+1000 cycles");
		end
		$display("%c[1;31m",27);
		$display ("Monitor: Timeout, Test Mega-Project (RTL) Failed");
		 $display("%c[0m",27);
		$finish;
	end

	always @(gpio) begin
		if(gpio == 16'hA040) begin
			$display("Mega-Project control Test started");
		end
		else if(gpio == 16'hAB40) begin
			$display("%c[1;31m",27);
			$display("Monitor: IO control R/W failed");
			$display("%c[0m",27);
			$finish;
		end
		else if(gpio == 16'hAB41) begin
			$display("Monitor: IO control R/W passed");
		end
        else if(gpio == 16'hAB50) begin
            $display("%c[1;31m",27);
			$display("Monitor: power control R/W failed");
			$display("%c[0m",27);
			$finish;
        end else if(gpio == 16'hAB51) begin
			$display("Monitor: power control R/W passed");
            $display("Monitor: Mega-Project control (RTL) test passed.");
            $finish;
        end			
	end

	initial begin
		CSB <= 1'b1;
		SCK <= 1'b0;
		SDI <= 1'b0;
		RSTB <= 1'b0;
		#1000;
		RSTB <= 1'b1;	    // Release reset
		#2000;
		CSB <= 1'b0;	    // Apply CSB to start transmission
	end

	always @(gpio) begin
		#1 $display("GPIO state = %b ", gpio);
	end

	wire VDD3V3;
	wire VDD1V8;
	wire VSS;
	
	assign VSS = 1'b0;
	assign VDD1V8 = 1'b1;
	assign VDD3V3 = 1'b1;

	caravel uut (
		.vdd3v3	  (VDD3V3),
		.vdd1v8	  (VDD1V8),
		.vss	  (VSS),
		.clock	  (clock),
		.xclk	  (XCLK),
		.SDI	  (SDI),
		.SDO	  (SDO),
		.CSB	  (CSB),
		.SCK	  (SCK),
		.ser_rx	  (1'b0),
		.ser_tx	  (),
		.irq	  (1'b0),
		.gpio     (gpio),
		.flash_csb(flash_csb),
		.flash_clk(flash_clk),
		.flash_io0(flash_io0),
		.flash_io1(flash_io1),
		.flash_io2(flash_io2),
		.flash_io3(flash_io3),
		.RSTB	  (RSTB)
	);

	spiflash #(
		.FILENAME("mprj_ctrl.hex")
	) spiflash (
		.csb(flash_csb),
		.clk(flash_clk),
		.io0(flash_io0),
		.io1(flash_io1),
		.io2(flash_io2),
		.io3(flash_io3)
	);

endmodule