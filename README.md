#tiny os - bootloader to kernerl shell

this is a small project implementing a unix-like operating system from scratch tarting at the BIOS boot sector and progressing toward a
modular kernel with a basic shell.

goals of this project are to learn os interals and assembly code

----current features-----
 Custom **16-bit real-mode bootloader**
kernel loading using BIOS `int 13h`
Kernel execution at `0x1000`
Text output using BIOS `int 10h`
Keyboard input using BIOS `int 16h`
Simple interactive shell with:
`cls` — clear screen
`echo <text>` — echo user input
Command parsing and input buffer
Backspace and Enter handling
Modular structure preparing for C integration

----Architecture overview-----
Bootloader (0x7C00)
    Initializes segments and stack
    Loads kernel (multiple sectors)
    Jumps to kernel entry point

Kernel (0x1000)
  Initializes its own stack
  Clears screen and prints welcome message
  Runs interactive shell loop
  Handles commands and input

-- progress log --
Bootloader implemented
Kernel loaded into memory
Shell added with cls and echo
Multi-sector kernel loading enabled
