TITLE final project          
INCLUDE Irvine32.inc
main	EQU start@0

.data
menuS   BYTE "1. Start", 0Dh, 0Ah,"2. Speed", 0Dh, 0Ah,
             "3. Mode", 0Dh, 0Ah, "ESC Exit",0Dh, 0Ah, 0
modeS  BYTE "1. Box", 0Dh, 0Ah, "2. Rooms", 0Dh, 0Ah, 0
speedS  BYTE "1. Slow", 0Dh, 0Ah, "2. Normal", 0Dh, 0Ah, "3. Faster",0Dh, 0Ah,0
gameoverS    BYTE "Game Over!", 0
scoreS  BYTE "Score: 0", 0
screen_width = 80
screen_height = 25
map word 2000 dup(0)
mode word '1'
initxy COORD<10,5>
deltime dword 150
goalrow byte 0
goalcol byte 0
traprow byte 0
trapcol byte 0
tailc byte 44
_tailc byte 44
tailr byte 13
_tailr byte 13
headc byte 41
_headc byte 41
headr byte 13
_headr byte 13

twoplayer byte 0
eat byte 0
_eat byte 0
eat_t byte 0
_eat_t byte 0
end_game byte 0

snake_d byte 'a'
_snake_d byte 0

searchr byte 0 
searchc byte 0
search word 0
.code
main PROC
    menu:
		MOV EAX, white + (black * 16)
        CALL SetTextColor
        CALL Randomize             
        CALL Clrscr                
        MOV EDX, OFFSET menuS     
        CALL WriteString 
    
    lobby:
        CALL ReadChar
    
        cmp al,'1'
        je startgame
        cmp al,'2'
        je select_speed
        cmp al,'3'
        je select_mode
        cmp al,'4'
        jne lobby
        exit
    
    ;開始遊戲
    startgame:
        MOV EAX, white + (black * 16)      
        CALL SetTextColor
        MOV DH, 25                         
        MOV DL, 0                          
        CALL GotoXY                        
        MOV EDX, OFFSET scoreS
        CALL WriteString
        
        MOV EAX, 0                  
        MOV EDX, 0
        Call init_parameter
        CALL Clrscr  
        call clear_map
		call generate_map
        call draw_map
        call init_snake 
        call create_goal
        call start_game
		MOV EAX, black + (black * 16)
        CALL SetTextColor
		CALL Clrscr  
        jmp menu
    
    select_speed:
        CALL Clrscr
        MOV EDX, OFFSET speedS
        CALL WriteString
    
    wait_speed:
        call Readchar
        CMP AL,'1'
        JE Slow
    
        CMP AL,'2'
        JE Normal

        CMP AL,'3'
        JE Faster
    
        Slow:
        mov deltime,200
        jmp menu

        Normal:
        mov deltime,100
        jmp menu

        Faster:
        mov deltime,50
        jmp menu
    
    
	
    select_mode:
        CALL Clrscr
        mov edx , offset modeS
        call WriteString
    
    waitmode:
        call ReadChar
    
    cmp al,'1'
        mov mode , 1;
        jmp menu;
    
    cmp al,'2'
        mov mode , 2;
        jmp menu;
    
    
    exit
main ENDP

init_parameter PROC
    mov end_game,0
    mov snake_d,'a'
    mov twoplayer , 0
    mov _snake_d , 0
    ret
init_parameter ENDP

start_game PROC
    ;call Readchar

    gameloop:
        cmp end_game,1
        je endgame
        call Readkey
        .IF ax == 1177h	
            .IF snake_d == 'a'
                jmp change1
            .ENDIF
            .IF snake_d == 'd'
                jmp change1
            .ENDIF
            jmp next1
            change1:
                mov snake_d , 'w'
	    .ENDIF
        
        next1:
        .IF ax == 1F73h	
            .IF snake_d == 'a'
                jmp change2
            .ENDIF
            .IF snake_d == 'd'
                jmp change2
            .ENDIF
            jmp next2
            change2:
                mov snake_d , 's'
	    .ENDIF
        
        next2:
        .IF ax == 1E61H	
            .IF snake_d == 'w'
                jmp change3
            .ENDIF
            .IF snake_d == 's'
                jmp change3
            .ENDIF
            jmp next3
            change3:
                mov snake_d , 'a'
	    .ENDIF
        
        next3:
        .IF ax == 2064H	
            .IF snake_d == 'w'
                jmp change4
            .ENDIF
            .IF snake_d == 's'
                jmp change4
            .ENDIF
            jmp twop
            change4:
                mov snake_d , 'd'
	    .ENDIF
 
        twop:
        cmp twoplayer ,0
        je notwoplayer
          .IF ax == 4800h	
            .IF _snake_d == 'a'
                jmp _change1
            .ENDIF
            .IF snake_d == 'd'
                jmp _change1
            .ENDIF
            .IF _snake_d == 0
                jmp _change1
            .ENDIF
            jmp _next1
            _change1:
                mov _snake_d , 'w'
	    .ENDIF
        _next1:
        .IF ax == 5000h	
            .IF _snake_d == 'a'
                jmp _change2
            .ENDIF
            .IF _snake_d == 'd'
                jmp _change2
            .ENDIF
            .IF _snake_d == 0
                jmp _change2
            .ENDIF
            jmp _next2
            _change2:
                mov _snake_d , 's'
	    .ENDIF
        
        _next2:
        .IF ax == 4b00h	
            .IF _snake_d == 'w'
                jmp _change3
            .ENDIF
            .IF _snake_d == 's'
                jmp _change3
            .ENDIF
            .IF _snake_d == 0
                jmp _change3
            .ENDIF
            jmp _next3
            _change3:
                mov _snake_d , 'a'
	    .ENDIF
        
        _next3:
        .IF ax == 4d00h	
            .IF _snake_d == 'w'
                jmp _change4
            .ENDIF
            .IF _snake_d == 's'
                jmp _change4
            .ENDIF
            .IF _snake_d == 0
                jmp _change4
            .ENDIF
            jmp notwoplayer
            _change4:
                mov _snake_d , 'd'
	    .ENDIF
        
        cmp _snake_d,0
        je  notwoplayer
        call _move_snake

    notwoplayer:
        .IF ax == 011Bh	
            jmp endgame
	    .ENDIF
        call move_snake
        mov dl , 80
        mov dh ,25
        call GotoXY
        mov eax , deltime
        call delay
		jmp gameloop
        endgame:
        ret
	
start_game endp

    
search_segment PROC uses edx ebx
    mov searchc,dl
    mov searchr,dh
    dec searchr
    
    mov dh , searchr
    mov dl ,searchc
    call get_map
    cmp bx , search
    je leavef
    
    add searchr ,2
    mov dh , searchr
    mov dl ,searchc
    call get_map
    cmp bx , search
    je leavef
    
    dec searchr
    dec searchc
    mov dh , searchr
    mov dl ,searchc
    call get_map
    cmp bx , search
    je leavef
    
    add searchc ,2
    mov dh , searchr
    mov dl ,searchc
    call get_map
    cmp bx , search
    je leavef
    
    leavef:
        ret
        
    
search_segment ENDP

move_snake PROC
    noerase:
		mov eat,0
        mov eat_t,0
        mov ecx,1
		mov al , tailr
        mov searchr , al
		mov al , tailc
        mov searchc , al
        
        move_segment:
            mov dh , searchr
            mov dl , searchc
            call get_map
            dec bx
            mov search , bx
            add bx ,2
            call save_map
            cmp bx , 2
            je leavewhile
            
            call search_segment
            jmp move_segment
        leavewhile:
            mov bx ,1
            cmp snake_d,'w'
            je d1
            cmp snake_d,'s'
            je d2
            cmp snake_d,'a'
            je d3
            cmp snake_d,'d'
            je d4
            d1:
                dec headr
                jmp checkgoal
            d2:
                inc headr
                jmp checkgoal
            d3:
                dec headc
                jmp checkgoal
            d4:
                inc headc
                jmp checkgoal
                
        checkgoal:
            mov al , headr
            cmp al , goalrow
            jne checktrap
            mov al , headc
            cmp al , goalcol
            jne checktrap
            mov eat,1
            call create_goal
			call create_trap
            jmp create_head

        checktrap:
            mov al , headr
            cmp al , traprow
            jne checkwall
            mov al , headc
            cmp al , trapcol
            jne checkwall
            mov eat_t,2
            mov ecx,2
            jmp create_head
            
        checkwall:
            mov al , headr
            cmp al , 0
            je dead
            cmp al , screen_height-1
            je dead
            mov al, headc
            cmp al,  0
            je dead
            cmp al , screen_width-1
            je dead
            mov dh , headr
            mov dl , headc
            call get_map
            cmp bx,0AAAAh
            je dead
            cmp bx,0
            jne next_dead
            jmp create_head
            next_dead:
            cmp twoplayer,1
            je dead

            newplayer:
            call create_newplayer
        create_head:
            mov dh , headr
            mov dl , headc
            mov bx,1
            call save_map
            CALL GotoXY         
            MOV EAX, white + (white * 16)
            CALL SetTextColor
            MOV AL, ' '
            CALL WriteChar
            cmp eat ,1
            jne erase
            ret
        dead:
            mov end_game,1
            ret
        erase:
            mov dh , tailr
            mov dl , tailc
            call get_map
            mov search, bx
            dec search
            mov bx , 0
            call save_map
            CALL GotoXY         
            MOV EAX, white + (black * 16)
            CALL SetTextColor
            MOV AL, ' '
            CALL WriteChar
            ; mov searchr , dh
            ; mov searchc, dl
            call search_segment
            mov al , searchr
            mov tailr , al
            mov al , searchc
            mov tailc , al
            loop erase
	ret
move_snake endp
_move_snake PROC
 noerase:
		mov _eat,0
        mov _eat_t,0
        mov ecx,1
		mov al , _tailr
        mov searchr , al
		mov al , _tailc
        mov searchc , al
        
        move_segment:
            mov dh , searchr
            mov dl , searchc
            call get_map
            inc bx
            mov search , bx
            sub bx ,2
            call save_map
            cmp bx , -2
            je leavewhile
            
            call search_segment
            jmp move_segment
        leavewhile:
            mov bx ,1
            cmp _snake_d,'w'
            je d1
            cmp _snake_d,'s'
            je d2
            cmp _snake_d,'a'
            je d3
            cmp _snake_d,'d'
            je d4
            d1:
                dec _headr
                jmp checkgoal
            d2:
                inc _headr
                jmp checkgoal
            d3:
                dec _headc
                jmp checkgoal
            d4:
                inc _headc
                jmp checkgoal
                
        checkgoal:
            mov al , _headr
            cmp al , goalrow
            jne checktrap
            mov al , _headc
            cmp al , goalcol
            jne checktrap
            mov _eat,1
            call create_goal
			call create_trap
            jmp create_head

        checktrap:
            mov al , _headr
            cmp al , traprow
            jne checkwall
            mov al , _headc
            cmp al , trapcol
            jne checkwall
            mov _eat_t,2
            mov ecx,2
            jmp create_head
            
            
        checkwall:
            mov al , _headr
            cmp al , 0
            je dead
            cmp al , screen_height-1
            je dead
            mov al, _headc
            cmp al,  0
            je dead
            cmp al , screen_width-1
            je dead
            mov dh , _headr
            mov dl , _headc
            call get_map
            cmp bx,0AAAAh
            je dead
            cmp bx,0
            jne dead
            jmp create_head
            ; newplayer:
            ; call create_newplayer
        create_head:
            mov dh , _headr
            mov dl , _headc
            mov bx,-1
            call save_map
            CALL GotoXY         
            MOV EAX, white + (yellow * 16)
            CALL SetTextColor
            MOV AL, ' '
            CALL WriteChar
            cmp _eat ,1
            jne erase
            ret
        dead:
            mov end_game,1
            ret
        erase:
            mov dh , _tailr
            mov dl , _tailc
            call get_map
            mov search, bx
            inc search
            mov bx , 0
            call save_map
            CALL GotoXY         
            MOV EAX, white + (black * 16)
            CALL SetTextColor
            MOV AL, ' '
            CALL WriteChar
            
            ; mov searchr , dh
            ; mov searchc, dl
            call search_segment
            mov al , searchr
            mov _tailr , al
            mov al , searchc
            mov _tailc , al
            loop erase
	ret
_move_snake endp
create_newplayer PROC uses eax ebx edx ecx

    mov ecx, 0
    mov dl , tailc
    mov _headc ,dl
    mov dh , tailr
    mov _headr ,dh
    call get_map
    mov cx , bx

    mov dl ,headc
    mov dh , headr
    call get_map
    dec bx
    mov search , bx
    call search_segment

    mov al , searchc
    mov tailc , al
    mov al , searchr
    mov tailr,al

    add bx ,2
    mov search , bx
    call search_segment
    mov dl , searchc
    mov _tailc , dl
    mov dh , searchr
    mov _tailr , dh


    mov eax , -2
    mov dl , _headc
    mov dh , _headr
    mov bx , -1
    call save_map

    mov searchc,dl
    mov searchr,dh
    mov search , cx
    changenum:
        mov dl , searchc
        mov dh , searchr
        dec search  
        call search_segment
        mov dl , searchc
        mov dh ,searchr
        mov bx , ax 
        call save_map
        dec ax
        cmp dl , _tailc
        jne changenum
        cmp dh , _tailr
        jne changenum
    mov twoplayer,1
    ret
create_newplayer ENDP

init_snake PROC

    mov dx,0
    mov dl,44
    mov dh,13
    mov bx,4
    mov tailc,dl
    mov tailr,dh
    call save_map 
    
    dec bx
    dec dl
    call save_map 
    
    dec bx
    dec dl
    call save_map 
    
    dec bx
    dec dl
    call save_map 
    
    mov headc , dl
    mov headr , dh
    ret
init_snake ENDP


generate_map PROC 
    
    cmp mode,'1'
    je Boxmap
    cmp mode,'2'
    je Crossmap
    cmp mode,'3'
    je Randommap
    
    Boxmap:
        mov bx , 0AAAAh
        mov dx,0
        udloop:
            cmp dl ,80
            je endudloop
            
            mov dh,0
            call save_map
            mov dh,24
            call save_map
            inc dl
            jmp udloop
            
            endudloop:
        mov dx,0
        
        lrloop:
            cmp dh,25
            je endlr
            
            mov dl,0
            call save_map
            mov dl , 79
            call save_map
            inc dh
            jmp lrloop
            
            endlr:
    
    Crossmap:
    Randommap:
	ret
generate_map ENDP


clear_map PROC
    MOV DH, 0              
    MOV BX, 0              

    iloop:                  
        CMP DH, 25                  
        JE endiloop
        MOV DL, 0  
        
        jloop:             
            CMP DL, 80     
            JE endjloop    
            CALL save_map           
            INC DL          
            JMP jloop       

    endjloop:              
        INC DH             
        JMP iloop          

endiloop: 
    ret
clear_map endp

;dh=row dl=colum
;store index to esi
get_index PROC USES ebx eax edx
    mov ebx,0
    mov eax,0
    mov bl,dh
    mov al,80
    mul bl
    mov dh,0
    add ax,dx
    mov esi,0
    mov si , ax
    shl si,1 ; word
    ret
get_index ENDP

;bx = value
;dh=row dl=colum
save_map PROC
    push ebx
    call get_index
    pop ebx
    mov map[si],bx
    ret
save_map ENDP

get_map PROC
    call get_index
    mov bx,map[si]
    ret
get_map ENDP

create_goal PROC USES eax ebx edx
    C1:
        mov eax,25
        call RandomRange
        mov dh,al

        mov eax,80
        call RandomRange
        mov dl,al

        call get_map
        cmp bx,0
        jne C1
    
        mov goalrow,dh
        mov goalcol,dl
    
        mov eax,white+(green*16)
        call setTextColor
        call Gotoxy
        mov al,' '
        call WriteChar
        
        RET
create_goal ENDP
create_trap PROC USES eax ebx edx
	C2:
		mov eax,25
		call RandomRange
		mov dh,al
		
		mov eax,80
		call RandomRange
		mov dl,al
		
		call get_map
		cmp bx,0
		jne C2
		
		mov traprow,dh
		mov trapcol,dl
		
		mov eax,white+(red*16)
		call setTextColor
		call Gotoxy
		mov al,' '
		call WriteChar
		RET
create_trap ENDP	
draw_map PROC
    mov eax,blue + (white * 16)
    call setTextColor
    mov dh,0
    L1:
        cmp dh,25
        JNL endL1
        mov dl,0
        
        L2:
            cmp dl,80
            JNL endL2
            call Gotoxy
            call get_map
            
            cmp bx,0
            je noprint
            
            cmp bx,0AAAAh
            je printwall
            
            mov al,' '
            call WriteChar
            jmp noprint
            
        printwall:
            mov eax,blue + (blue * 16)
            call setTextColor
            mov al,' '
            call WriteChar

            MOV EAX, blue + (white * 16)    ; Change the text color back to
            CALL SetTextColor  
        noprint:
            inc dl
            jmp L2
    endL2:
        inc dh
        jmp L1
endL1:

RET
draw_map ENDP
END main
