# FPGA Playground

This repository hosts the code I wrote when playing around with FPGAs.
Specifically, the Verilog code I wrote describes a "System on Chip" for the
[DE0-CV](https://www.terasic.com.tw/cgi-bin/page/archive.pl?Language=English&No=921)
based on the [picoRV32](https://github.com/cliffordwolf/picorv32) softcore.


## Directory Structure

* The `src/` folder has the Verilog code.
    * The `hdl/` subfolder has the code describing the SoC.
    * The `test/` subfolder contains a very simple testbench (if you can call it
      that)
* The `mem/` folder has initialization files for some of the Block RAMs used by
  the SoC
    * The `program_ram/` subfolder has RISC-V code to be loaded and run into the
      primary BRAM.
    * The `char_rom/` subfolder describes a character set used by the VGA
      subsystem.
* The `ip/` folder would contain all the IP blocks used. Their files have been
  ignored, so check the `ip/.gitignore` file for descriptions of the components.


## Memory Map

This mapping is implicitly defined in `src/hdl/soc.v` in the code instantiating
an `arbiter` module.

* Main Memory: `0x0000_0000 - 0x0000_ffff`
    * Readable, Writeable, Executable
    * Initialized from `mem/program_ram/program.mem`
    * Starts execution at address zero
* Video Memory: `0x0001_0000 - 0x0001_ffff`
    * Writeable
    * Initialized to zeros
    * Contains a text buffer of length `3200` starting at `0x0001_0000`
    * CAN ONLY BE USED WITH `SB`. USING `SH` AND `SW` WILL FAIL.
* Keys MMIO: `0xffff_fff8 - 0xffff_fffb`
    * Readable
    * Describes the switches and buttons pressed as a 32-bit vector
        * Bits `31-28` are `~KEY[3]-~KEY[0]`. Note that `1` means pressed.
        * Bits `9-0` are `SW[9]-SW[0]`.
        * All other bits are zero.
* Seven Segment MMIO: `0xffff_fffc - 0xffff_ffff`
    * Writeable
    * Bits `23-0` of the word at these locations is shown on the seven segment
      display.
