TITLE Lab of week2              (week2.ASM)

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

.data
	
.code
main PROC
	mov al,01100111b ;67
	mov ah,67			
	mov ax,2067h		
	mov dx,0eeeah		
	sub dx,ax	
	exit
	
main ENDP
END main