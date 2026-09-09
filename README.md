# Pipelined-RISC-V
Pipelined RISC-V (BOOK) design written on SystemVerilog

BOOK Version

Unsupported Instructions:
- LB, LH, LBU, LHU
- SLLI, SRAI, SRLI
- AUIPC
- SB, SH
- SLL, SRA, SRL
- LUI
- BNE, BLT, BGE, BLTU, BGEU
- JALR

Change the .hex file name that needs to run to "program.hex"

Currently checked:
- load-use handling worked well enough to get the right result
- forwarding worked
- taken branches/ JAL prevented wrong register writes
- memory results were corrected

Stress TB:
- long forwarding chains
- multiple load-use hazards
- load -> branch dependencies
- ALU -> branch dependencies
- taken not taken branches
- JAL redirection
- register flush side effects
- memory flush side effects
- store-data forwarding

Flow TB:
- EX/MEM -> EX forwarding
- MEM/WB -> EX forwarding
- store-data forwarding
- load-use detection
- exactly one load-use stall
- PC hold during stall
- IF/ID hold during stall
- bubble injection into EX
- branch operand forwarding
- taken branch detection
- Decode flush
- Execute flush
- correct target-PC redirect
- final architectural result

============================
Check Timing
============================