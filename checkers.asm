IDEAL
MODEL small
STACK 100h
DATASEG


ROW 	   DB ?
COL		   DB ?
ROWI 	   DW ?
COLI 	   DW ?
ROWF 	   DW ?
COLF 	   DW ?
ROWXI      DW ?
COLXI      DW ?
ROWXF      DW ?
COLXF      DW ?
ROWSI      DW ?
COLSI      DW ?
ROWSF      DW ?
COLSF      DW ?
x dw ?
y dw ?
color db 45
squareSize dw 12
squareColor db 15
Board dw 128 dup (0)
yplace dw ?
xplace dw ?
mouse_x dw ?
mouse_y dw ?
mouse_cell dw ?
from_cell dw ?
to_cell dw ?
is_error dw ?
add_x dw ?
add_y dw ?
forb_cell dw ?
legallMove dw ?
currPlayer dw 1
countWhite dw 12 
countred dw 12 ;TODO: change to 12
GAMEOVER dw 0
enemy_cell dw ?

shaar_filename db 'shaar.bmp',0
over_filename db 'over.bmp',0
ins_filename db 'ins.bmp',0
filehandle dw ?
Header db 54 dup (0)
Palette db 256*4 dup (0)
ScrLine db 320 dup (0)
ErrorMsg db 'Error', 13, 10,'$'

CODESEG
proc OpenFileShaar ;;took from barak gonen's book
; Open file
mov ah, 3Dh
xor al, al
mov dx, offset shaar_filename
int 21h
jc openerrorshaar
mov [filehandle], ax
ret
openerrorshaar:
mov dx, offset ErrorMsg
mov ah, 9h
int 21h
ret
endp OpenFileShaar 

proc OpenFileIns ;;took from barak gonen's book
; Open file
mov ah, 3Dh
xor al, al
mov dx, offset ins_filename
int 21h
jc openerrorins
mov [filehandle], ax
ret
openerrorins:
mov dx, offset ErrorMsg
mov ah, 9h
int 21h
ret
endp OpenFileIns 

proc OpenFileOver ;;took from barak gonen's book
; Open file
mov ah, 3Dh
xor al, al
mov dx, offset over_filename	
int 21h
jc openerror
mov [filehandle], ax
ret
openerror:
mov dx, offset ErrorMsg
mov ah, 9h
int 21h
ret
endp OpenFileOver

proc ReadHeader ;;took from barak gonen's book
; Read BMP file header, 54 bytes
mov ah,3fh
mov bx, [filehandle]
mov cx,54
mov dx,offset Header
int 21h
ret
endp ReadHeader
proc ReadPalette ;;took from barak gonen's book
; Read BMP file color  , 256 colors * 4 bytes (400h)
mov ah,3fh
mov cx,400h
mov dx,offset Palette
int 21h
ret
endp ReadPalette
proc CopyPal ;;took from barak gonen's book
; Copy the colors palette to the video memory registers
; The number of the first color should be sent to port 3C8h
; The palette is sent to port 3C9h
mov si,offset Palette
mov cx,256
mov dx,3C8h
mov al,0
; Copy starting color to port 3C8h
out dx,al
; Copy palette itself to port 3C9h
inc dx
PalLoop:
; Note: Colors in a BMP file are saved as BGR values rather than RGB.
mov al,[si+2] ; Get red value.
shr al,2 ; Max. is 255, but video palette maximal
 ; value is 63. Therefore dividing by 4.
out dx,al ; Send it.
mov al,[si+1] ; Get green value.
shr al,2
out dx,al ; Send it.
mov al,[si] ; Get blue value.
shr al,2
out dx,al ; Send it.
add si,4 ; Point to next color
loop PalLoop
ret
endp CopyPal
proc CopyBitmap ;;took from barak gonen's book
; BMP graphics are saved upside-down.
; Read the graphic line by line (200 lines in VGA format),
; displaying the lines from bottom to top.
mov ax, 0A000h
mov es, ax
mov cx,200
PrintBMPLoop:
push cx
; di = cx*320, point to the correct screen line
mov di,cx
shl cx,6
shl di,8
add di,cx
; Read one line
mov ah,3fh
mov cx,320
mov dx,offset ScrLine
int 21h
; Copy one line into video memory
cld ; Clear direction flag, for movsb
mov cx,320
mov si,offset ScrLine
rep movsb ; Copy line to the screen
 ;rep movsb is same as the following code:
 ;mov es:di, ds:si
 ;inc si
 ;inc di
 ;dec cx
 ;loop until cx=0
pop cx
loop PrintBMPLoop
ret
endp CopyBitmap


proc drawpic_shaar  ;; טענת כניסה : מכניסים את המשתנה שמכיל בתוכו את שם הקובץ של התמונה
;;טענת יציאה : התמונה מוצגת על המסך
push ax
push bx
push cx
push dx
push di
push si
push es

call OpenFileShaar
call ReadHeader
call ReadPalette
call CopyPal
call CopyBitmap
pop es
pop si
pop di
pop dx
pop cx
pop bx
pop ax

ret
endp drawpic_shaar


proc drawpic_ins ;; טענת כניסה : מכניסים את המשתנה שמכיל בתוכו את שם הקובץ של התמונה
;;טענת יציאה : התמונה מוצגת על המסך
push ax
push bx
push cx
push dx
push di
push si
push es

call OpenFileIns
call ReadHeader
call ReadPalette
call CopyPal
call CopyBitmap
pop es
pop si
pop di
pop dx
pop cx
pop bx
pop ax
ret
endp drawpic_ins

proc drawpic_over ;; טענת כניסה : מכניסים את המשתנה שמכיל בתוכו את שם הקובץ של התמונה
;;טענת יציאה : התמונה מוצגת על המסך
push ax
push bx
push cx
push dx
push di
push si
push es

call OpenFileOver
call ReadHeader
call ReadPalette
call CopyPal
call CopyBitmap
pop es
pop si
pop di
pop dx
pop cx
pop bx
pop ax


ret
endp drawpic_over


PROC VERT ;; טענת כניסה : הפרוצדורה מקבלת צבע נקודת התחלה ואורך קו אנכי
;;טענת יציאה : הקו מצוייר על המסך
;PROCEDURE TO DRAW VERTICAL LINES
	PUSH AX
	PUSH CX
	PUSH DX
	MOV AH,0CH						   ;write pixel function
	MOV AL,[color]
	MOV CX,[COLI]
	MOV DX,[ROWI]
L2:	INT 10H
	INC DX
	CMP DX,[ROWF]
	JLE L2
	POP DX
	POP CX
	POP AX
	RET 
ENDP VERT

PROC HORIZ ;;  טענת כניסה : הפרוצדורה מקבלת צבע נקודת התחלה ואורך קו אופקי
;;טענת יציאה : הקו מצוייר על המסך
;PROCEDURE TO DRAW HORIZONTAL LINES
	PUSH AX
	PUSH CX
	PUSH DX
	MOV AH,0CH						   ;write pixel function
	MOV AL,[color]
	MOV CX,[COLI]
	MOV DX,[ROWI]
L3:	INT 10H
	INC CX
	CMP CX,[COLF]
	JLE L3
	POP DX
	POP CX
	POP AX
	RET 
ENDP HORIZ  

proc square ;;טענת כניסה : התכנית מקבלת את צבע הריבוע גודלו ומיקומו במסך
;;טענת יציאה : התכנית מציירת ריבוע
	PUSH AX
	PUSH CX
	PUSH DX
	
	mov al, [squareColor]
	mov [color], al
	
	mov cx, [squareSize]
	
	
	
	mov ax, [x]
	mov dx, [y]
	mov [ROWI], dx
	mov [COLI], ax
	add ax, [squareSize]
	mov [COLF], ax

	
	drawlines:
		CALL HORIZ
		inc dx
		mov [ROWI], dx
	loop drawlines
	
	
	POP DX
	POP CX
	POP AX
ret
endp square


proc initBoard ;;טענת כניסה : אין
;;טענת יציאה : מחזירה מערך מאותחילם בערכים 0-3

push cx
push bx

mov cx, 64
zero :
mov bx, cx
add bx, bx
mov  [board+bx],0
loop zero

mov [countred], 12
mov [countWhite], 12
mov [currPlayer], 1

mov [Board+2],1
mov [Board+6],1
mov [Board+10],1
mov [Board+14],1
mov [Board+16],1
mov [Board+20],1
mov [Board+24],1
mov [Board+28],1
mov [Board+34],1
mov [Board+38],1
mov [Board+42],1
mov [Board+46],1

mov [Board+80],2
mov [Board+84],2
mov [Board+88],2
mov [Board+92],2
mov [Board+98],2
mov [Board+102],2
mov [Board+106],2
mov [Board+110],2
mov [Board+112],2
mov [Board+116],2
mov [Board+120],2
mov [Board+124],2

mov [Board+0],3
mov [Board+4],3
mov [Board+8],3
mov [Board+12],3
mov [Board+18],3
mov [Board+22],3
mov [Board+26],3
mov [Board+30],3
mov [Board+32],3
mov [Board+36],3
mov [Board+40],3
mov [Board+44],3
mov [Board+50],3
mov [Board+54],3
mov [Board+58],3
mov [Board+62],3
mov [Board+64],3
mov [Board+68],3
mov [Board+72],3
mov [Board+76],3
mov [Board+82],3
mov [Board+86],3
mov [Board+90],3
mov [Board+94],3
mov [Board+96],3
mov [Board+100],3
mov [Board+104],3
mov [Board+108],3
mov [Board+114],3
mov [Board+118],3
mov [Board+122],3
mov [Board+126],3

pop bx
pop cx
ret
endp initBoard

proc forbiddenCells ;; טענת כניסה : התכנית מקבלת מיקומים במסך וצבעם
;;טענת ייבאה : ממלאת את המיקום בצע שקיבלה

	PUSH AX
	PUSH CX
	PUSH DX
	
	mov al, [squareColor]
	mov [color], al
	
	mov cx, 20
		
	mov ax, [x]
	mov dx, [y]
	mov [ROWI], dx
	mov [COLI], ax
	add ax, 35
	mov [COLF], ax

	drawlinesf:
		CALL HORIZ
		inc dx
		mov [ROWI], dx
	loop drawlinesf
	
	
	POP DX
	POP CX
	POP AX

ret
endp forbiddenCells




PROC drawBoard ;;טענת כניסה : מערך מאותחך
;;טענת יציאה : הלוח מצוייר על המסך

push ax
push cx

mov [color], 45
mov [COLI],20
MOV [ROWI],20
MOV [ROWF],180
CALL VERT
mov [COLI],55
CALL VERT
mov [COLI],90
CALL VERT
mov [COLI],125
CALL VERT
mov [COLI],160
CALL VERT
mov [COLI],195
CALL VERT
mov [COLI],230
CALL VERT
mov [COLI],265
CALL VERT
mov [COLI],300
CALL VERT


mov [ROWI], 20
mov [COLI], 20
mov [COLF], 300
call HORIZ
mov [ROWI], 40
call HORIZ
mov [ROWI], 60
call HORIZ
mov [ROWI], 80
call HORIZ
mov [ROWI], 100
call HORIZ
mov [ROWI], 120
call HORIZ
mov [ROWI], 140
call HORIZ
mov [ROWI], 160
call HORIZ
mov [ROWI], 180
call HORIZ


MOV [x], 5
mov [y], 5
cmp [currPlayer], 1
je whiteturn 
jmp balckturn

whiteturn: 
mov [squareColor], 15
jmp drawturn

balckturn: 
mov [squareColor], 40

drawturn:
call square


mov cx, 64
mov si,0
boardloop:

	;bx = 2*si;
	push si
	add si,si
	mov bx, [Board+si]
	pop si
	cmp bx, 1
	je drawwhite
	cmp bx, 2
	je draw_red
	cmp bx, 3
	je forbidden_cell
	
	jne continue_drawing
drawwhite: 
	mov [squareColor], 15
	mov [add_x], 11
	mov [add_y], 4
	mov [forb_cell], 0
	jmp calc_draw_location
	
draw_red:
	call drawred
	jmp calc_draw_location
	
forbidden_cell:
		mov [squareColor], 93
		mov [add_x], 0
		mov [add_y], 0
		mov [forb_cell], 1
		
calc_draw_location:
	call calcDrawLocation

	
	mov ax, [forb_cell]
	cmp ax, 1
	je forb
	
	call square
	jmp continue_drawing
forb:	 
	call forbiddenCells
	 
continue_drawing:
inc si	
loop boardloop

pop cx
pop ax 

ret
ENDP drawBoard

proc drawred ;; טענת כניסה : אין
;;טענת יציאה :מאתחלת את המשתנים ליצירת כלי אדום
	mov [squareColor], 40
	mov [add_x], 11
	mov [add_y], 4
	mov [forb_cell], 0
	ret
endp drawred

proc  calcDrawLocation ;; טענת כניסה :מקבלת את מספר התא בלוח 
;;טענת יציאה : מחזירה את מיקומו על המסך

		mov ax, si
	mov bl, 8
	div bl
	mov ah, 0
	mov [yplace], ax
	
	mov bl, 8
	mul bl	
	
	mov dx, si
	sub si, ax
	mov [xplace], si
	mov si, dx
	
	;x = 20 + xplace*35
	;y = 20 + yplace*20
	 mov [x],20
	 mov [y],20
	 mov ax,0
	 
	 mov ax, [xplace]
	 mov bx, 35
	 mul bx
	 add ax, [x] 
	  add ax, [add_x]
	; add ax,11
	 mov [x], ax
	 
	 mov ax, [yplace]
	 mov bx, 20
	 mul bx
	 add ax, [y] 
	 add ax, [add_y]
	; add ax,4
	 mov [y], ax
	
ret
endp calcDrawLocation


proc initMouse ;;took from barak gonen's book
	push ax
	mov ax,0h
	int 33h
	; Show mouse
	mov ax,1h
	int 33h
	pop ax
	ret
endp initMouse



proc WaitForClick ;;took from barak gonen's book
	
	push ax
	push bx
	; loop until mouse click
	MouseLP:
	mov ax,3h
	int 33h
	cmp bx, 01h ; check left mouse click
	jne MouseLP
;MouseLR:	
;	mov ax, 6
;	mov bx, 0
;	int 33h
;	cmp ax, 1
;	jne MouseLR
	pop bx
	pop ax
	ret
endp WaitForClick


proc mouseto_cell ;;טענת כניסה : מיקום במסך
;;טענת יציאה : התא בלוח שבו נמצא אותו מיקום
	push ax
	push bx
	push cx
	push dx
	
	mov ax,[mouse_y]
	sub ax, 20
	mov bl, 20
	div bl
	mov cl,al
	
	mov ax,[mouse_x]
	sub ax, 20
	mov bl, 35
	div bl
	mov dl,al
	
	mov ch,00h
	mov dh,00h
	mov bl,8
	mov al,cl
	mul bl
	add ax,dx
	mov [mouse_cell],ax

	pop dx
	pop cx
	pop bx
	pop ax
	ret
endp mouseto_cell

proc setfrom_cell ;טענת כניסה : מיקום על המסך שבו נלחת העכבר 
;;טענת יציאה : מעדכנת את התא שממנו מתבצע מהלך
	push ax
	
	shr cx,1
	mov [mouse_x], cx
	mov [mouse_y], dx
	
;		cmp cx,20
;		jl badPlay
;		
;		cmp cx,300
;		jg badPlay
;		
;		cmp dx,20
;		jl badPlay
;		
;		cmp dx,180
;		jg badPlay
;		
;		jmp goodPlay
;	badPlay:
;		mov [is_error], 1
;		;;call showError
;		pop ax 
;		ret
		
    goodPlay:
	call mouseto_cell
	mov ax, [mouse_cell]
	mov [from_cell], ax
	pop ax
ret
endp setfrom_cell

proc setto_cell ;;טענת כניסה : מקבלת מיקום על המסך שבו נלחץ העכבר 
;;טענת יציאה : מעדכנת את התא שאליו מגיע הכלי
push ax
	shr cx,1
	mov [mouse_x], cx
	mov [mouse_y], dx
	call mouseto_cell
	mov ax, [mouse_cell]
	mov [to_cell], ax
	pop ax
ret
endp setto_cell

proc updateBoard ;;טענת כניסה : מקבלת את התא שממנו הכלי הולך ואליו הוא מגיע
;;טענת יציאה : הלוח מעודכן בהתאם
push ax
push bx

mov bx,[from_cell]
add bx,bx
mov ax,[Board+bx]

mov [Board+bx], 0

mov bx,[to_cell]
add bx,bx
mov [Board+bx], ax

pop bx
pop ax
ret
endp updateBoard


proc clearscrean ;;טענת כניסה : אין
;;טענת יציאה : צובית את המסך בשחור
push ax
push es
push di
push cx

mov ax,0A000h
mov es,ax
xor al,al
xor di,di
mov cx,64000
loopclear:
mov [byte ptr es:di],al
inc di
loop loopclear

pop cx
pop di
pop es
pop ax
ret 
endp


proc simpleEatCheckWhite ;;טענת כניסה : התא שממנו התבצע המהלך והמיקום אליו הגיע
;;טענת יציאה : בודקת האם התבצע אכילה של כלי אדום ומעדכנת את הלוח בהתאם

	push ax
	push bx
	
	mov bx, [from_cell]
	add bx, 7
	mov [enemy_cell], bx
	add bx, bx
	mov ax, [Board+bx]
	cmp ax, 2
	je red7
	
	mov bx, [from_cell]
	add bx, 9
	mov [enemy_cell], bx
	add bx, bx
	mov ax, [Board+bx]
	cmp ax, 2
	je red9

jmp endSimpleEatCheckWhite
	
	red7:
		mov ax, [from_cell]
		add ax, 14
		cmp ax, [to_cell]
		je eatMoveOKWhite
	jmp endSimpleEatCheckWhite
	
	red9:
		mov ax, [from_cell]
		add ax, 18
		cmp ax, [to_cell]
		je eatMoveOKWhite
	jmp endSimpleEatCheckWhite
	
eatMoveOKWhite:
		mov bx, [enemy_cell]
		add bx, bx
		mov [Board+bx], 0
		mov [legallMove], 1
		dec [countred]
		jmp endSimpleEatCheckWhite
	
endSimpleEatCheckWhite:		
	pop bx
	pop ax
	ret 
endp simpleEatCheckWhite

proc simpleEatCheckred ;;טענת כניסה : התא שממנו התבצע המהלך והמיקום שאליו הגיע
;;טענת יציאה : בודקת האם התרחשה אכילה של כלי לבן ומעדכנת את הלוח

	push ax
	push bx
	
	mov bx, [from_cell]
	sub bx, 7
	mov [enemy_cell], bx
	add bx, bx
	mov ax, [Board+bx]
	cmp ax, 1
	je White7
	
	mov bx, [from_cell]
	sub bx, 9
	mov [enemy_cell], bx
	add bx, bx
	mov ax, [Board+bx]
	cmp ax, 1
	je White9
	
	White7:
		mov ax, [from_cell]
		sub ax, 14
		cmp ax, [to_cell]
		je eatMoveOKred
		jmp endSimpleEatCheckred
	
	White9:
		mov ax, [from_cell]
		sub ax, 18
		cmp ax, [to_cell]
		je eatMoveOKred		
		jmp endSimpleEatCheckred
		
	eatMoveOKred:
		mov bx, [enemy_cell]
		add bx, bx
		mov [Board+bx], 0
		mov [legallMove], 1
		dec [countWhite]
		jmp endSimpleEatCheckred
		
endSimpleEatCheckred:		
	pop bx
	pop ax
	ret 
endp simpleEatCheckred


proc check_eat  ;;טענת כניסה : התא שממנו התבצע המהלך והמיקום שאליו הגיע
;; טענת יציאה : בודקת האם המהלך חוקי 
	
	push ax
	push bx
		
	mov bx,[from_cell]
	add bx, bx
	mov ax,[Board+bx]
	cmp ax, [currPlayer]
	jne badMove
	
	mov bx, [to_cell]
	add bx, bx
	mov ax, [Board+bx]
	cmp ax, 0
	jne badMove
	
	mov bx, [from_cell]
	add bx, bx
	mov ax, [Board+bx]
	cmp ax, 1
	je White
	jmp red
	
	badMove:
		mov [legallMove], 0
		jmp endCheck
	
	White:
	
		; simple move
		mov ax, [from_cell]
		add ax, 9
		cmp ax, [to_cell]
		je goodMove
		
		mov ax, [from_cell]
		add ax, 7
		cmp ax, [to_cell]
		je goodMove
		
		; simple eat move
		call simpleEatCheckWhite
		mov ax, [legallMove]
		cmp ax, 1
		je goodMove
		
		
	red:
		mov ax, [from_cell]
		sub ax, 9
		cmp ax, [to_cell]
		je goodMove
		
		
		mov ax, [from_cell]
		sub ax, 7
		cmp ax, [to_cell]
		je goodMove
	
		call simpleEatCheckred
		mov ax, [legallMove]
		cmp ax, 1
		je goodMove
		

	
	goodMove:
		mov [legallMove], 1
		jmp endCheck
	
		
	
	endCheck:
	pop bx
	pop ax
	ret 
endp check_eat


proc isGameEnded ;; טענת כניסה : מקבלת את כמות הכלים שנשארו במשחק 
;;טענת יציאה : בודקת אם המשחק נגמר
cmp [countWhite],0
je finish
cmp [countred],0
je finish
jne nofinish
finish:
mov [GAMEOVER],1
ret
nofinish:
mov [GAMEOVER],0
ret
endp isGameEnded


proc damka ;;מקבלת לוח מאותחל
;;מתחילה את המשחק
push ax
push cx
game:


newTurn:
	call WaitForClick
	nop
	call setfrom_cell
	
	
	mov ah,00h
	int 16h
	
	call initMouse

	
	
	call WaitForClick

	nop
	call setto_cell

	call check_eat	
	
	call updateBoard
	
	call clearscrean
	
	; hide mouse
	mov ax, 2
	int 33h 
	
	;curr_player = 2-curr_player + 1
	mov ax,[currPlayer]
	mov cx,2
	sub cx,ax
	inc cx
	mov [currPlayer], cx 
	
	call drawBoard
	;show mouse
	mov ax, 1
	int 33h
	


	call isGameEnded
		call isGameEnded
	cmp [GAMEOVER], 0
	je game

pop cx
pop ax	
	
ret
endp damka

;;;;;;

start:
mov ax, @data
mov ds, ax

start_game:
; Graphic mode
mov ax, 13h
int 10h
;  ess BMP file

call drawpic_shaar
; Wait for key press
mov ah,1
int 21h


call clearscrean   

call drawpic_ins
; Wait for key press
mov ah,1
int 21h


call clearscrean   

mov ax, 13h
int 10h

call initBoard
call drawBoard
call initMouse

call damka



; Press any key to continue
mov ah,00h
int 16h

	; hide mouse
mov ax, 2
int 33h 

call clearscrean
call drawpic_over

; Press any key to continue
;mov ah,00h
;int 16h


mov AH,0CH
mov AL,1
int 21H
cmp al,'y'
je start_game
cmp al,'Y'
je start_game
;cmp al,'n'
;je end_main
;cmp al,'N'
;jne @exit_main

end_main:
;exit from graphic mode
mov ah, 0
mov al, 2
int 10h




exit:	
mov ax, 4c00h
int 21h
END start