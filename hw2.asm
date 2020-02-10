TITLE Example of ASM              (helloword.ASM)
.486
; This program locates the cursor and displays the
; system time. It uses two Win32 API structures.
; Last update: 6/30/2005

INCLUDE Irvine32.inc

; Redefine external symbols for convenience
; Redifinition is necessary for using stdcall in .model directive 
; using "start" is because for linking to WinDbg.  added by Huang
 
main          EQU start@0

;Comment @
;Definitions copied from SmallWin.inc:
;20" " 2a"*" 
.data
Array1 sdword 2,  4, -3, -9, 7, 1, 8
Array2 sdword 2, -3,  6,  0, 7, 8, 5
count dword 0
String Byte " matches",0
.code
search PROC 
	mov eax,0
	mov ecx ,lengthof Array1
	L4:
	push ecx
	mov ecx,lengthof Array1
	L1:
	mov edx , count
	shl edx , 2
	mov ebx ,[Array1+edx]
	mov edx,lengthof Array1
	sub edx , ecx
	shl edx , 2
	cmp ebx, [Array2+edx]
	je L2
	jmp L3
	L2:
	inc eax
	L3:
	loop L1
	pop ecx
	inc count
	loop L4
	RET
search ENDP 
main PROC
	call search
	call     WriteInt 
	mov edx, offset String
	call WriteString
	call crlf
	call     WaitMsg
main ENDP
END main
