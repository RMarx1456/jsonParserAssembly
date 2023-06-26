;TODO:
;Tokenize elements of json file
;Match tokens with predefined strings
;perform actions based on those

;I'm now using mmap instead of brk but I want to keep this file.

section .data
	
	heapstart dq 0
	
;files
%DEFINE SYS_READ 0
%DEFINE SYS_WRITE 1
%DEFINE STDIN 0
%DEFINE STDOUT 1


%DEFINE SYS_OPEN 2
%DEFINE RDONLY 0

%DEFINE SYS_CLOSE 3

%DEFINE SYS_STAT 4

;memory
%DEFINE SYS_BRK 12


;exit
%DEFINE SYS_EXIT 60


section .rodata
	filename db 'jsonFile.json', 0
	filenameLen equ $- filename


	;errors
	success db 'Ran successfully', 0xA
	successLen equ $- success
	
	fail_stat db 'SYS_STAT failed', 0xA
	fail_statLen equ $- fail_stat
	
	fail_brk db 'SYS_BRK failed', 0xA
	fail_brkLen equ $- fail_brk
	
	fail_read db 'SYS_READ failed', 0xA
	fail_readLen equ $- fail_read
	
	fail_open db 'SYS_OPEN failed', 0xA
	fail_openLen equ $- fail_open
	
	fail_write db 'SYS_WRITE failed', 0xA
	fail_writeLen equ $- fail_write

section .bss

file_stat resb 144

jsonLength resb 8

section .text

global _start

_start:

	;find file size
	

	;SYS_STAT
	MOV RAX, SYS_STAT
	MOV RDI, filename
	MOV RSI, file_stat
	SYSCALL
	
	;align stack for exit call
	MOV R14, 15
	MOV R15, RSP
	OR R15, 0x0F
	SUB R14, R15
	SUB RSP, R14
	
	;jump to exit if error with sys_stat, setup print call
	MOV RSI, fail_stat
	MOV RDX, fail_statLen
	
	CMP RAX, 0
	JL exit
	
	
	;clear registers R14, R15 and free space on stack
	ADD RSP, R14
	XOR R14, R14
	XOR R15, R15
	
	;allocate memory for file buffer
	
	;find ending address of .data section
	MOV RAX, SYS_BRK
	XOR RDI, RDI
	SYSCALL
	
	;align stack for exit call
	MOV R14, 15
	MOV R15, RSP
	OR R15, 0x0F
	SUB R14, R15
	SUB RSP, R14
	
	;jump to exit if error with sys_stat, setup print call
	MOV RSI, fail_brk
	MOV RDX, fail_brkLen
	
	CMP RAX, 0
	JL exit
	
	;clear registers R14, R15 and free space on stack
	ADD RSP, R14
	XOR R14, R14
	XOR R15, R15
	
	;create address offset and move to heapstart
	ADD RAX, QWORD [file_stat + 48]
	MOV QWORD [heapstart], RAX
	
	;allocate memory according to file size
	MOV RAX, SYS_BRK
	MOV RDI, QWORD [heapstart]
	SYSCALL
	
	;align stack for exit call
	MOV R14, 15
	MOV R15, RSP
	OR R15, 0x0F
	SUB R14, R15
	SUB RSP, R14
	
	;jump to exit if error with sys_stat, setup print call
	MOV RSI, fail_brk
	MOV RDX, fail_brkLen
	
	CMP RAX, 0
	JL exit
	
	;clear registers R14, R15 and free space on stack
	ADD RSP, R14
	XOR R14, R14
	XOR R15, R15
	
	
	;open the .json file
	
	
	;sys_open
	MOV RAX, SYS_OPEN
	MOV RDI, filename
	MOV RSI, 0
	MOV RDX, 0
	SYSCALL
	
	;error handling
	MOV R14, 15
	MOV R15, RSP
	OR R15, 0x0F
	SUB R14, R15
	SUB RSP, R14
	
	;jump to exit if error with sys_read, setup print call
	MOV RSI, fail_open
	MOV RDX, fail_openLen
	
	CMP RAX, 0
	JL exit
	
	;clear registers R14, R15 and free space on stack
	ADD RSP, R14
	XOR R14, R14
	XOR R15, R15
	
	;move file descriptor into RDI
	MOV RDI, RAX
	
	MOV RSI, QWORD [heapstart]
	SUB RSI, QWORD [file_stat + 48]
	
	;sys_read
	MOV RAX, SYS_READ
	;rdi already set
	;rsi already set
	MOV RDX, QWORD [file_stat+48]
	SYSCALL
	
	
	;error handling
	MOV R14, 15
	MOV R15, RSP
	OR R15, 0x0F
	SUB R14, R15
	SUB RSP, R14
	
	;jump to exit if error with sys_read, setup print call
	MOV RSI, fail_read
	MOV RDX, fail_readLen
	
	CMP RAX, 0
	JL exit
	
	;clear registers R14, R15 and free space on stack
	ADD RSP, R14
	XOR R14, R14
	XOR R15, R15
	
	
	;print buffer
	MOV RAX, SYS_WRITE
	MOV RDI, STDOUT
	
	MOV RSI, QWORD [heapstart]
	SUB RSI, QWORD [file_stat+48]
	
	MOV RDX, QWORD [file_stat+48]
	SYSCALL
	
	;error handling
	MOV R14, 15
	MOV R15, RSP
	OR R15, 0x0F
	SUB R14, R15
	SUB RSP, R14
	
	;jump to exit if error with sys_read, setup print call
	MOV RSI, fail_write
	MOV RDX, fail_writeLen
	
	CMP RAX, 0
	JL exit
	
	;clear registers R14, R15 and free space on stack
	ADD RSP, R14
	XOR R14, R14
	XOR R15, R15
	
	
	;prepare for exiting successfully
	MOV R14, 15
	MOV R15, RSP
	OR R15, 0x0F
	SUB R14, R15
	SUB RSP, R14
	
	
	MOV RSI, success
	MOV RDX, successLen
	
	jmp exit
	
	;tokenize(char[]* token, int length
	tokenize:
	
	
	exit:
		;print exit message
		MOV RAX, SYS_WRITE
		MOV RDI, STDOUT
		SYSCALL
	
		;exit
		MOV RAX, SYS_EXIT
		XOR RDI, RDI
		SYSCALL
	
