;TODO:
;Tokenize elements of json file
;Match tokens with predefined strings
;perform actions based on those

section .data
	
	
	file_descriptor dq 0
	
	
	mapstart dq 0
	
	
	
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
%DEFINE SYS_MMAP 9
%DEFINE SYS_MUNMAP 11

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

	fail_mmap db 'SYS_MMAP failed', 0xA
	fail_mmapLen equ $- fail_mmap
	
	fail_close db 'SYS_CLOSE failed', 0xA
	fail_closeLen equ $- fail_close
	
	fail_munmap db 'SYS_MUNMAP failed', 0xA
	fail_munmapLen equ $- fail_munmap
	
	
	
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
	
	;map memory using mmap
	MOV RAX, SYS_MMAP
	MOV RDI, 0
	MOV RSI, QWORD [file_stat + 48]
	MOV RDX, 0x3 ; PROT_READ | PROT_WRITE
	MOV R10, 0x22 ;MAP_ANONYMOUS | MAP_PRIVATE
	MOV R8, -1
	MOV R9, 0
	SYSCALL
	
	MOV QWORD [mapstart], RAX
	
	;align stack for exit call
	MOV R14, 15
	MOV R15, RSP
	OR R15, 0x0F
	SUB R14, R15
	SUB RSP, R14
	
	;jump to exit if error with sys_stat, setup print call
	MOV RSI, fail_mmap
	MOV RDX, fail_mmapLen
	
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
	
	
	;move file descriptor into RDI and file_descriptor
	MOV RDI, RAX
	MOV [file_descriptor], QWORD RDI
	
	
	
	;sys_read
	MOV RAX, SYS_READ
	;rdi already set
	;Suspicious that this line below is causing me an error, yep, it is, fixed with correct permissions in MMAP
	MOV RSI, QWORD [mapstart]
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

	
	;close file
	MOV RAX, SYS_CLOSE
	MOV RDI, QWORD [file_descriptor]
	SYSCALL
	
	;error handling
	MOV R14, 15
	MOV R15, RSP
	OR R15, 0x0F
	SUB R14, R15
	SUB RSP, R14
	
	;jump to exit if error with sys_read, setup print call
	MOV RSI, fail_close
	MOV RDX, fail_closeLen
	
	CMP RAX, 0
	JL exit
	
	;clear registers R14, R15 and free space on stack
	ADD RSP, R14
	XOR R14, R14
	XOR R15, R15
	
	;print mapped buffer
	MOV RAX, SYS_WRITE
	MOV RDI, STDOUT
	MOV RSI, QWORD [mapstart]
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
	
	
	;unmap buffer from memory
	MOV RAX, SYS_MUNMAP
	MOV RDI, QWORD [mapstart]
	MOV RSI, QWORD [file_stat+48]
	SYSCALL
	
	;error handling
	MOV R14, 15
	MOV R15, RSP
	OR R15, 0x0F
	SUB R14, R15
	SUB RSP, R14
	
	;jump to exit if error with sys_read, setup print call
	MOV RSI, fail_munmap
	MOV RDX, fail_munmapLen
	
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
	