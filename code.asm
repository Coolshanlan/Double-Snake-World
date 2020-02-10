TITLE final project          
INCLUDE Irvine32.inc
main	EQU start@0
recHeight = 7
recWidth = 2
wwidth = 98
height = 29
.data
rec	BYTE recWidth DUP(0B3h)
ball	BYTE 0FEh
Uline	BYTE 0DAh, (wwidth-2) DUP(0C4h), 0BFh
Dline	BYTE 0C0h, (wwidth-2) DUP(0C4h),0D9h
LRline	BYTE 0B3h
outputHandle DWORD 0
bytesWritten DWORD 0
outHandle DWORD 0
count DWORD 0

consoleInfo CONSOLE_SCREEN_BUFFER_INFO <>
UBound COORD <1,0>
DBound COORD <1,30>
LBound COORD <1,1>
RBound COORD <98,1>
lrxy COORD <2,12>
rrxy COORD <96,12>
bxy COORD <4,15>
windowsize COORD <100,30>

cellsWritten DWORD ?
lcolor WORD recWidth DUP(0Eh)
rcolor WORD recWidth DUP(0Ah)
bcolor  WORD 0Bh
erase WORD 00h
drawR PROTO, color: PTR WORD, len: DWORD, xy: COORD
drawC PROTO, color: PTR WORD, len: DWORD, xy: COORD


.code
main PROC
	INVOKE GetConsoleScreenBufferInfo,outHandle,ADDR consoleInfo
   	INVOKE SetConsoleScreenBufferSize,outHandle,windowsize
	INVOKE GetStdHandle,STD_OUTPUT_HANDLE
	mov outputHandle, eax
	call Clrscr
	xor eax, eax
	call drawW
	mov ecx, recHeight
	invoke drawR, ADDR lcolor,LENGTHOF lcolor, lrxy
	invoke drawR, ADDR rcolor,LENGTHOF rcolor, rrxy
	invoke drawC, ADDR bcolor, LENGTHOF bcolor, bxy
MOVE:
	call ReadChar
	.IF ax == 4800h	;RUP
		.IF rrxy.y == 1	;right up bound
			jmp MOVE
		.ENDIF
		invoke drawR, ADDR erase,LENGTHOF rcolor, rrxy
		dec rrxy.y
		invoke drawR, ADDR rcolor,LENGTHOF rcolor, rrxy
	.ENDIF
	.IF ax == 5000h	;RDOWN
		.IF rrxy.y == 23	;right down bound
			jmp MOVE
		.ENDIF
		invoke drawR, ADDR erase,LENGTHOF rcolor, rrxy
		inc rrxy.y
		invoke drawR, ADDR rcolor,LENGTHOF rcolor, rrxy
	.ENDIF
	.IF ax == 1177h	;LUP
		.IF lrxy.y == 1	;left up bound
			jmp MOVE
		.ENDIF
		invoke drawR, ADDR erase,LENGTHOF lcolor, lrxy
		dec lrxy.y
		invoke drawR, ADDR lcolor,LENGTHOF lcolor, lrxy
	.ENDIF
	.IF ax == 1F73h	;LDOWN
		.IF lrxy.y == 23	;left down bound
			jmp MOVE
		.ENDIF
		invoke drawR, ADDR erase,LENGTHOF lcolor, lrxy
		inc lrxy.y
		invoke drawR, ADDR lcolor,LENGTHOF lcolor, lrxy
	.ENDIF
	.IF ax == 011Bh	;ESC
		jmp END_FUNC
	.ENDIF
	
	
	jmp MOVE
END_FUNC:
	call Waitmsg
	call Clrscr
	exit
main ENDP

drawW PROC
	push ecx
	INVOKE WriteConsoleOutputCharacter,outputHandle, ADDR Uline, lengthof Uline, Ubound,ADDR cellsWritten
	pop ecx
	mov ecx, height
L:	push ecx
	INVOKE WriteConsoleOutputCharacter,outputHandle, ADDR LRline, lengthof LRline, Lbound,ADDR cellsWritten
	inc Lbound.y
	pop ecx
	loop L
	mov ecx, height
L2:	push ecx
	INVOKE WriteConsoleOutputCharacter,outputHandle, ADDR LRline, lengthof LRline, Rbound,ADDR cellsWritten
	inc Rbound.y
	pop ecx
	loop L2
	push ecx
	INVOKE WriteConsoleOutputCharacter,outputHandle, ADDR Dline, lengthof Dline, Dbound,ADDR cellsWritten
	pop ecx
	ret
drawW ENDP

drawR PROC color: PTR WORD, len: DWORD, xy: COORD
L1:	push ecx
	INVOKE WriteConsoleOutputAttribute,outputHandle, color, len, xy, ADDR cellsWritten
	INVOKE WriteConsoleOutputCharacter,outputHandle, ADDR rec, lengthof rec, xy,ADDR cellsWritten
	inc xy.y
	pop ecx
	loop L1
	mov ecx, RecHeight
	sub xy.y, RecHeight
	ret
drawR ENDP

drawC PROC color: PTR WORD, len: DWORD, xy: COORD
	push ecx
	INVOKE WriteConsoleOutputAttribute,outputHandle, color, len, xy ,ADDR cellsWritten
	INVOKE WriteConsoleOutputCharacter, outputHandle,ADDR ball,lengthof ball,bxy ,ADDR cellsWritten  
	pop ecx
	ret
drawC ENDP

END main

