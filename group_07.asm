;跳棋程式
INCLUDE Irvine32.inc

;繪出棋盤
print PROTO 

;棋盤座標與小黑窗座標轉換
Transfer PROTO,
	X1:sbyte,
	Y1:sbyte
	
;判斷輸入的座標是否在棋盤內
Boundary PROTO,
	x:sbyte,y:sbyte
	
;判斷有無玩家勝利
Iswin PROTO

;判斷輸入的位置是否有棋子
IsChess PROTO,
	boolx:sbyte,booly:sbyte

;選擇棋子
Choose PROTO

;移動游標
movecursor PROTO

;移動棋子
movechess PROTO

;棋子座標結構(帶正負的座標)
COOR STRUCT 
	X sbyte 0
	Y sbyte 0
COOR ENDS

.data
;15隻紅棋位置
R COOR <-4, 8>, <-4, 7>, <-3, 7>, <-4, 6>, <-3, 6>, <-2, 6>, <-4, 5>, <-3, 5>, <-2, 5>, <-1, 5>, <-4, 4>, <-3, 4>, <-2, 4>, <-1, 4>, < 0, 4> 
;15隻綠棋位置
G COOR <-4, 0>, <-4,-1>, <-3,-1>, <-4,-2>, <-3,-2>, <-2,-2>, <-4,-3>, <-3,-3>, <-2,-3>, <-1,-3>, <-4,-4>, <-3,-4>, <-2,-4>, <-1,-4>, < 0,-4>
;15隻黃棋位置
Y COOR < 4, 0>, < 4,-1>, < 5,-1>, < 4,-2>, < 5,-2>, < 6,-2>, < 4,-3>, < 5,-3>, < 6,-3>, < 7,-3>, < 4,-4>, < 5,-4>, < 6,-4>, < 7,-4>, < 8,-4>

;快贏的15隻紅棋位置
;R COOR <4, -8>, <4, -7>, <3, -7>, <4, -6>, <3, -6>, <2, -6>, <4, -5>, <2, -3>, <2, -5>, <1, -5>, <4, -4>, <3, -4>, <2, -4>, <1, -4>, < 0, -4> 
;快贏的15隻綠棋位置
;G COOR <4, 0>, <4,1>, <4,2>, <4,3>, <4,4>, <3,0>, <3,2>, <3,3>, <3,4>, <2,2>, <2,3>, <2,4>, <1,3>, <1,4>, < 0,4>
;快贏的15隻黃棋位置
;Y COOR <-4, 0>, <-4,1>, <-4,2>, <-4,3>, <-4,4>, <-3,1>, <-5,2>, <-5,3>, <-5,4>, <-6,2>, <-6,3>, <-6,4>, <-7,3>, <-7,4>, <-8,4>

;棋盤樣式
dot byte "o"

;游標位置
cursor COOR < 0, 0>

;控制權
control byte 1

;遊戲狀態
chos   byte "choose",0
unchos byte "unlock",0
En     byte "end",0
redwin		byte "The winner is red!!!",0
greenwin	byte "The winner is green!!!",0
yellowwin	byte "The winner is yellow!!!",0
jumporstop  byte "Choose another position to arrive, or press Enter again to stop the chess here. ",0
havechess	byte "This position has a chess. ",0
cantjump    byte "You can't jump to the position",0
chooseyourschess byte "You Can't choose other's chess or choose Nothing. Please choose your own chess! ",0

.code
main PROC
		
		INVOKE print							;印出初始棋盤

	gameconti:
		INVOKE Iswin							;判斷有無玩家勝利
		cmp  ax,1								
		jz somebodywin							;有玩家勝利
		INVOKE Choose 							;選擇棋子
		mov  edx, OFFSET chos					
		call WriteString						;輸出"choose"狀態
		INVOKE movechess						;移動棋子
		cmp  ax, 0
		jz   unchoose							;重新選擇棋子
		INVOKE print							;繪出棋盤
		mov  edx, OFFSET En						
		call WriteString						;輸出"end"狀態
		
		add control, 1							;control = (control + 1) % 3 + 1
		cmp control, 3
		jng gameconti
		add control, -3
		mov al,control
		jmp gameconti							;遊戲繼續

	unchoose:									;重新選擇棋子
		INVOKE print							;繪出棋盤
		mov  edx, OFFSET unchos					
		call WriteString						;輸出"unlock"狀態
		jmp  gameconti
				
	somebodywin:								;有玩家勝利
		cmp  bx,1
		jz   wred
		cmp  bx,2
		jz   wgreen
		cmp  bx,3
		jz   wyellow
		
	wred:										;紅棋勝利
		mov  dh, 0
		mov  dl, 0
		call Gotoxy
		mov  edx, OFFSET redwin					;印出"The winner is red!!!"狀態
		call WriteString
		jmp  endgame
		
	wgreen:										;綠棋勝利
		mov  dh, 0
		mov  dl, 0
		call Gotoxy
		mov  edx, OFFSET greenwin				;印出"The winner is green!!!"狀態
		call WriteString
		jmp  endgame

	wyellow:									;黃棋勝利
		mov  dh, 0
		mov  dl, 0
		call Gotoxy
		mov  edx, OFFSET yellowwin				;印出"The winner is yellow!!!"狀態
		call WriteString
		jmp  endgame
		
	endgame:									;遊戲結束
		call readchar
		exit
main ENDP
;----------------------------------------------print----------------------------------------------
print PROC

		call clrscr								;清空螢幕
	
		push eax								;將會用到的暫存器內容放入堆疊
		push ebx
		push ecx
		push esi
		
	;---繪製大棋盤白點---
	;雙層迴圈 -8 <= i,j <= 8
	;透過 Boundary 以及透過 Transfer 轉換，繪出棋盤上的點出棋盤上的點
		mov  ecx, 17
	outter:
		mov   bh , cl
		sub   bh , 9
		
		push  ecx
			
		mov   ecx, 17
	inner:
		mov   bl , cl
		sub   bl , 9
		INVOKE Boundary, bh, bl
		cmp  ax , 0
		jz   outofbound							;點出界 --> 不印出
		
		INVOKE Transfer, bh, bl
		call Gotoxy								;游標位置已經由 Transfer 算好，並放入適當的暫存器 (dl,dh)
		mov  eax, white + ( black*16 )			;設定前景為白色，背景為黑色
		call SetTextColor
		
		mov  al , dot
		call Writechar							;印出點點

	outofbound:
		
		loop inner
		
		pop ecx
		
		loop outter
		
	;---大棋盤紅點---
	;按照矩陣的內容，透過 Transfer 轉換後繪出
		mov  ecx, 15
		mov  esi, OFFSET R
		
	printred:
		mov  bh , (COOR PTR [esi]).X
		mov  bl , (COOR PTR [esi]).Y
		INVOKE Transfer, bh, bl
		call Gotoxy
		mov  eax, 12 + ( black*16 )			;設定前景為淡紅色，背景為黑色
		call SetTextColor
		
		mov  al , 3h
		call Writechar 						;印出愛心
		
		add  esi, TYPE COOR
		loop printred

	;---大棋盤綠點---
	;按照矩陣的內容，透過 Transfer 轉換後繪出
		mov  ecx, 15
		mov  esi, OFFSET G
		
	printgreen:
		mov  bh , (COOR PTR [esi]).X
		mov  bl , (COOR PTR [esi]).Y
		INVOKE Transfer, bh, bl
		call Gotoxy
		mov  eax, 10 + ( black*16 )			;設定前景為淡綠色，背景為黑色
		call SetTextColor
		
		mov  al , 6h
		call Writechar						;印出黑桃
		
		add  esi, TYPE COOR
		loop printgreen	
		
	;---大棋盤黃點---
	;按照矩陣的內容，透過 Transfer 轉換後繪出
		mov  ecx, 15
		mov  esi, OFFSET Y
		
	printyellow:
		mov  bh , (COOR PTR [esi]).X
		mov  bl , (COOR PTR [esi]).Y
		INVOKE Transfer, bh, bl
		call Gotoxy
		mov  eax, yellow + ( black*16 )		;設定前景為黃色，背景為黑色
		call SetTextColor
		
		mov  al , 4h
		call Writechar						;印出菱形
		add  esi, TYPE COOR
		loop printyellow
		
	;---大棋盤游標---
		mov  bh , cursor.X
		mov  bl , cursor.Y
		INVOKE Transfer, bh, bl
		
		;繪製"[" ，淡青綠色
		sub  dl ,1
		call Gotoxy
		mov  eax, 11 + ( black*16 )
		call SetTextColor
		mov  al , "["
		call Writechar
		
		;繪製"[" ，淡青綠色
		add  dl ,2
		call Gotoxy
		mov  eax, 11 + ( black*16 )
		call SetTextColor
		mov  al , "]"
		call Writechar
		
	;從堆疊取回暫存器內容
		pop  esi
		pop  ecx
		pop  ebx
		pop  eax

		ret
		
print ENDP

;----------------------------------------------Transfer----------------------------------------------
Transfer PROC,
	X1:sbyte, Y1:sbyte
	
	;將會用到的暫存器內容放入堆疊
	push eax
	push ebx

	mov al, X1;
	mov bl, Y1;
	
	;2*x1 + y1 + 13 =x2
	
	add al, al
	add al, bl
	add al, 13
	mov dl, al
	
	;-y1 + 9 = y2
	neg bl
	add bl, 9
	mov dh, bl
	
	;從堆疊取回暫存器內容
	pop ebx
	pop eax
	
	ret

Transfer ENDP
;----------------------------------------------Boundary----------------------------------------------
Boundary PROC, ux:SBYTE, uy:SBYTE
		push ebx
	test_uptri: 
		
		;判斷是否在上三角裡，只要有一項不符合，
		;就直接跳去判斷是不是下三角里
		cmp uy, -4
		jl test_downtri  ;y<-4
		cmp ux, -4 
		jl test_downtri  ;x<-4
		mov bl, ux
		add bl, uy
		cmp bl, 4  
		jg test_downtri  ;x+y>4
		jmp Istrue
		
		;三項都符合，所以在上三角裡
		;就直接跳去Istrue，回傳true(ax=1)，結束程式

	test_downtri:
		;判斷是否在下三角裡，只要有一項不符合，
		;就直接跳去Isfalse，回傳false(ax=0)，結束程式
		cmp uy, 4 
		jg Isfalse  ;y > 4
		cmp ux, 4 
		jg Isfalse  ;x > 4
		mov bl, ux
		add bl, uy
		cmp bl, -4
		jl Isfalse  ;x+y>=-4
		
		;三項都符合，所以在下三角裡就
		;到Istrue，回傳true(ax=1)，結束程式
		
	Istrue:
		mov ax, 1
		jmp existBoundary
	Isfalse:
		mov ax, 0
	existBoundary:
		pop ebx
		ret
		
Boundary ENDP
;----------------------------------------------Iswin----------------------------------------------
Iswin PROC
		push edi
		push ecx
		mov ecx, 15
		mov edi, 0
	checkR:
		cmp (COOR PTR R[edi]).Y, -4   		;R的每個棋子的Y都必須小於等於-4
		jg checkG                     		;只要有一顆沒有，R就不可能贏，就直接跳去check G
		cmp (COOR PTR R[edi]).X, 0			;R的每個棋子的X都必須大於等於0
		jl checkG                     		;只要有一顆沒有，R就不可能贏，就直接跳去check G
		cmp (COOR PTR R[edi]).X, 4			;R的每個棋子的X都必須小於等於4
		jg checkG                  	   		;只要有一顆沒有，R就不可能贏，就直接跳去check G
		add edi, TYPE COOR
		loop checkR
		mov bx, 1
		jmp Win                        		;R每顆棋子的Y都小於等於-4，則R贏了
		
	checkG:
		mov ecx, 15
		mov edi, 0
	Gloop:
		mov bl, (COOR PTR G[edi]).X    		;G的每個棋子都必須x+y>=4
		add bl, (COOR PTR G[edi]).Y
		cmp bl, 4 
		jl checkY                      		;只要有一顆沒有，G就不可能贏，就直接跳去check Y
		cmp (COOR PTR G[edi]).Y, 0     		;G的每個棋子的Y都必須大於等於0
		jl checkY                     		;只要有一顆沒有，G就不可能贏，就直接跳去check Y
		cmp (COOR PTR G[edi]).Y, 4    		;G的每個棋子的Y都必須小於等於4
		jg checkY                      		;只要有一顆沒有，G不可能贏，就直接跳去check Y
		add edi, TYPE COOR
		loop Gloop
		mov bx, 2
		jmp Win                       		;G的每個棋子都x+y>=4，則G贏了
		
	checkY:
		mov ecx, 15
		mov edi, 0
	Yloop:
		cmp (COOR PTR Y[edi]).X, -4    		;Y的每個棋子的X都必須小於等於-4
		jg Conti                       		;只要有一顆沒有，Y就不可能贏，即R,G,Y都沒有人贏
		cmp (COOR PTR Y[edi]).Y, 0    		;G的每個棋子的Y都必須大於等於0
		jl Conti                      		;只要有一顆沒有，Y就不可能贏，即R,G,Y都沒有人贏 Y
		cmp (COOR PTR Y[edi]).Y, 4    		;G的每個棋子的Y都必須小於等於4
		jg Conti                      		;只要有一顆沒有，Y就不可能贏，即R,G,Y都沒有人贏
		add edi, TYPE COOR
		loop Yloop
		mov bx, 3
		jmp Win								;Y每顆棋子的X都小於等於-4，則Y贏了
		
	Win:									;有玩家勝利 ax = 1
		mov ax, 1
		jmp existIswin
		
	Conti:									;無玩家勝利 ax = 0
		mov ax, 0;
		
	existIswin:
		pop ecx
		pop edi
		ret
		
Iswin ENDP
;----------------------------------------------movecursor----------------------------------------------
movecursor PROC

		push eax
		push ebx
	
	;等待輸入上、下、左、右、enter
	WaitInput:
		call readchar
		cmp  eax, 4800h						;上
		jz   UP
		cmp  eax, 5000h						;下
		jz   DOWN
		cmp  eax, 4B00h						;左
		jz   LEFT
		cmp  eax, 4D00h						;右
		jz   RIGHT
		cmp  eax, 1C0Dh						;enter
		jz   OUTFUN
		jmp  WaitInput
	
	;上 -> Y座標+1 並判斷位置是否超出邊界
	UP:
		mov  bh, cursor.X
		mov  bl, cursor.Y
		add  bl, 1
		INVOKE Boundary, bh, bl
		cmp  ax , 0
		jz   WaitInput
		mov  cursor.X, bh
		mov  cursor.Y, bl
		INVOKE print
		jmp  WaitInput
	
	;下 -> Y座標-1 並判斷位置是否超出邊界
	DOWN:
		mov  bh, cursor.X
		mov  bl, cursor.Y
		add  bl, -1
		INVOKE Boundary, bh, bl
		cmp  ax , 0
		jz   WaitInput
		mov  cursor.X, bh
		mov  cursor.Y, bl
		INVOKE print
		jmp  WaitInput
	
	;左 -> X座標-1 並判斷位置是否超出邊界
	LEFT:
		mov  bh, cursor.X
		mov  bl, cursor.Y
		add  bh, -1
		INVOKE Boundary, bh, bl
		cmp  ax , 0
		jz   WaitInput
		mov  cursor.X, bh
		mov  cursor.Y, bl
		INVOKE print
		jmp  WaitInput
	
	;右 -> X座標+1 並判斷位置是否超出邊界
	RIGHT:
		mov  bh, cursor.X
		mov  bl, cursor.Y
		add  bh, 1
		INVOKE Boundary, bh, bl
		cmp  ax , 0
		jz   WaitInput
		mov  cursor.X, bh
		mov  cursor.Y, bl
		INVOKE print
		jmp  WaitInput
	
	;enter 跳出函式
	OUTFUN:
		pop  ebx
		pop  eax
		ret
		
movecursor ENDP
;----------------------------------------------movechess----------------------------------------------
movechess PROC

		;宣告區域變數  isjmp:判斷是否為"跳"棋  chessx:棋子X座標  chessy:棋子Y座標
		LOCAL isjmp : byte, chessx : sbyte,chessy : sbyte
		push ebx
		push edx
		
		;isjmp預設為0
		mov  isjmp, 0
		
	moveagain:
		
		;移動游標
		INVOKE movecursor
		
		;將棋子原始位置寫入 (bh, bl)
		mov  bh, (COOR PTR [esi]).X
		mov  chessx, bh
		mov  bl, (COOR PTR [esi]).Y
		mov  chessy, bl

		;檢查游標位置是否有棋子
		INVOKE IsChess, cursor.X, cursor.Y
		cmp  al, 0
		jz   startmove						;該位置無棋子
		
		;如果(bh, bl) == (cursor.X, cursor.Y) => 處理跳棋結束 或者 取消選取
		cmp  bh, cursor.X
		jnz  haschess
		cmp  bl, cursor.Y
		jnz  haschess
		jmp  startmove
	
	haschess:
		mov  dh, 0
		mov  dl, 0
		call Gotoxy
		mov  edx, OFFSET havechess			;印出"This position has a chess."狀態
		call WriteString
		jnz  moveagain	
		
	startmove:	
		;(bh, bl) 紀錄後來位置與原始位置的差
		mov  bh, cursor.X
		mov  bl, cursor.Y
		sub  bh, chessx
		sub  bl, chessy
		
		;跳過的棋子不用判斷移動
		cmp  isjmp, 0
		jnz  jump							;處理"跳"棋
		
		cmp  bh, 1
		jz   xplusone						;X座標差 = +1(走、跳)
		cmp  bh, 0
		jz   xremain1						;X座標差 = 0 (走、跳、取消選取)
		cmp  bh, -1
		jz   xminusone						;X座標差 = -1(走、跳)
		cmp  bh, 2
		jz   xplustwo						;X座標差 = +2(跳)
		cmp  bh, -2
		jz   xminustwo						;X座標差 = -2(跳)
		jmp  invalidmove					;X座標差超出範圍(非法移動)
	
	;X座標差 = +1(走、跳)
	xplusone:
		cmp  bl, 0
		jz   moveright;						;Y座標差 = 0 (向右走)
		cmp  bl, -1	
		jz   moverightdown					;Y座標差 = -1(向右下走)
		jmp  invalidmove					;Y座標差超出範圍(非法移動)
	
	;向右走
	moveright:
		mov  bh, chessx
		add  bh, 1
		mov  (COOR PTR [esi]).X, bh			;改變旗子X座標
		INVOKE print
		mov  ax, 1
		pop  ebx
		ret
	
	;向右下走
	moverightdown:
		mov  bh, chessx
		add  bh, 1
		mov  (COOR PTR [esi]).X, bh			;改變旗子X座標
		mov  bl, chessy
		add  bl, -1
		mov  (COOR PTR [esi]).Y, bl			;改變旗子Y座標
		INVOKE print
		mov  ax, 1
		pop  ebx
		ret

	;X座標差 = 0 (走、跳、取消選取)
	xremain1:
		cmp  bl, 1
		jz   moverightup					;Y座標差 = 1 (向右上走)
		cmp  bl, -1						
		jz   moveleftdown					;Y座標差 = -1 (向左下走)
		cmp  bl, 0
		jz   unlock							;Y座標差 = 0 (取消選取)
		cmp  bl, 2
		jz   jumprightup					;Y座標差 = 2 (向右上跳)
		cmp  bl, -2
		jz   jumpleftdown					;Y座標差 = -2 (向左下跳)
		jmp  invalidmove					;Y座標差超出範圍(非法移動)

	;取消選取
	unlock:
		mov  ax, 0							;設定 ax = 0 供主程式判斷控制權轉移
		pop  ebx
		ret
	
	;向右上走
	moverightup:
		mov  bh, chessx
		mov  (COOR PTR [esi]).X, bh			;改變旗子X座標
		mov  bl, chessy
		add  bl, 1
		mov  (COOR PTR [esi]).Y, bl			;改變旗子Y座標
		INVOKE print
		mov  ax, 1
		pop  ebx
		ret
	
	;向左下走
	moveleftdown:
		mov  bh, chessx
		mov  (COOR PTR [esi]).X, bh			;改變旗子X座標
		mov  bl, chessy
		sub  bl, 1
		mov  (COOR PTR [esi]).Y, bl			;改變旗子Y座標
		INVOKE print
		mov  ax, 1
		pop  ebx
		ret
	
	;X座標差 = -1 (走、跳)
	xminusone:
		cmp  bl, 0
		jz   moveleft						;Y座標差 = 0 (向左走)
		cmp  bl, 1
		jz   moveleftup						;Y座標差 = 1 (向左上走)
		jmp  invalidmove					;Y座標差超出範圍(非法移動)
		
	;向左走
	moveleft:
		mov  bh, chessx
		add  bh, -1
		mov  (COOR PTR [esi]).X, bh			;改變旗子X座標
		INVOKE print
		mov  ax, 1
		pop  ebx
		ret
	
	;向左上走
	moveleftup:
		mov  bh, chessx
		add  bh, -1
		mov  (COOR PTR [esi]).X, bh			;改變旗子X座標
		mov  bl, chessy
		add  bl, 1
		mov  (COOR PTR [esi]).Y, bl			;改變旗子Y座標
		INVOKE print
		mov  ax, 1
		pop  ebx
		ret

	;這裡處理"跳"棋
	jump:
		cmp  bh, 2
		jz   xplustwo						;X座標差 = +2(跳)
		cmp  bh, 0
		jz   xremain2						;X座標差 = 0 (跳)
		cmp  bh, -2
		jz   xminustwo						;X座標差 = -2(跳)
		jmp  invalidmove					;X座標差超出範圍(非法移動)
		
	xplustwo:
		cmp  bl, 0
		jz   jumpright						;Y座標差 = 0 (向右跳)
		cmp  bl, -2
		jz   jumprightdown					;Y座標差 = -2 (向右下跳)
		jmp  invalidmove					;Y座標差超出範圍(非法移動)
		
	jumpright:
		mov  bh, cursor.X
		add  bh, -1
		mov  bl, cursor.Y
		INVOKE IsChess, bh, bl				;判斷要跳的方向是否有棋子
		cmp  al, 0
		jz   invalidmove					;要跳的方向無棋子
		mov  bh, chessx
		add  bh, 2
		mov  (COOR PTR [esi]).X, bh			;改變旗子X座標
		mov  isjmp, 1						;設定 isjmp = 1
		INVOKE print
		jmp  jumpagain

	jumprightdown:
		mov  bh, cursor.X
		add  bh, -1
		mov  bl, cursor.Y
		add  bl, 1
		INVOKE IsChess, bh, bl				;判斷要跳的方向是否有棋子
		cmp  al, 0
		jz   invalidmove					;要跳的方向無棋子
		mov  bh, chessx
		add  bh, 2
		mov  (COOR PTR [esi]).X, bh			;改變旗子X座標
		mov  bl, chessy
		add  bl, -2
		mov  (COOR PTR [esi]).Y, bl			;改變旗子Y座標
		mov  isjmp, 1						;設定 isjmp = 1
		INVOKE print
		jmp  jumpagain
		
	xremain2:
		cmp  bl, 2	
		jz   jumprightup					;Y座標差 = 2 (向右上跳)
		cmp  bl, -2
		jz   jumpleftdown					;Y座標差 = -2 (向左下跳)
		cmp  bl, 0
		jz   jumpend						;Y座標差 = 0 (跳棋結束)
		jmp  invalidmove					;Y座標差超出範圍(非法移動)

	jumprightup:
		mov  bh, cursor.X
		mov  bl, cursor.Y
		add  bl, -1
		INVOKE IsChess, bh, bl				;判斷要跳的方向是否有棋子
		cmp  al, 0
		jz   invalidmove					;要跳的方向無棋子
		mov  bh, chessx
		mov  (COOR PTR [esi]).X, bh			;改變旗子X座標
		mov  bl, chessy
		add  bl, 2
		mov  (COOR PTR [esi]).Y, bl			;改變旗子Y座標
		mov  isjmp, 1						;設定 isjmp = 1
		INVOKE print
		jmp  jumpagain

	jumpleftdown:
		mov  bh, cursor.X
		mov  bl, cursor.Y
		add  bl, 1
		INVOKE IsChess, bh, bl				;判斷要跳的方向是否有棋子
		cmp  al, 0
		jz   invalidmove					;要跳的方向無棋子
		mov  bh, chessx
		mov  (COOR PTR [esi]).X, bh			;改變旗子X座標
		mov  bl, chessy
		add  bl, -2
		mov  (COOR PTR [esi]).Y, bl			;改變旗子Y座標
		mov  isjmp, 1						;設定 isjmp = 1
		INVOKE print
		jmp  jumpagain
		
	xminustwo:
		cmp  bl, 2							;Y座標差 = 2 (向左上跳)
		jz   jumpleftup
		cmp  bl, 0							;Y座標差 = 0 (向左跳)
		jz   jumpleft
		jmp  invalidmove					;Y座標差超出範圍(非法移動)

	jumpleftup:
		mov  bh, cursor.X
		add  bh, 1
		mov  bl, cursor.Y
		add  bl, -1
		INVOKE IsChess, bh, bl				;判斷要跳的方向是否有棋子
		cmp  al, 0
		jz   invalidmove					;要跳的方向無棋子
		mov  bh, chessx
		add  bh, -2
		mov  (COOR PTR [esi]).X, bh			;改變旗子X座標
		mov  bl, chessy
		add  bl, 2
		mov  (COOR PTR [esi]).Y, bl			;改變旗子Y座標
		mov  isjmp, 1						;設定 isjmp = 1
		INVOKE print
		jmp  jumpagain

	jumpleft:
		mov  bh, cursor.X
		add  bh, 1
		mov  bl, cursor.Y
		INVOKE IsChess, bh, bl				;判斷要跳的方向是否有棋子
		cmp  al, 0
		jz   invalidmove					;要跳的方向無棋子
		mov  bh, chessx
		add  bh, -2
		mov  (COOR PTR [esi]).X, bh			;改變旗子X座標
		mov  bl, chessy
		mov  isjmp, 1						;設定 isjmp = 1
		INVOKE print
		jmp  jumpagain

	;跳棋可以決定是否要繼續跳
	jumpagain:
		mov  dh, 0
		mov  dl, 0
		call Gotoxy
		mov  edx, OFFSET jumporstop
		call WriteString
		jmp  moveagain
	
	;非法移動
	invalidmove:	
		mov  dh, 0
		mov  dl, 0
		call Gotoxy
		mov  edx, OFFSET cantjump
		call WriteString
		jmp  moveagain
	
	;結束移動
	jumpend:
		mov  ax, 1
		pop  edx
		pop  ebx
		ret

movechess ENDP
;----------------------------------------------Choose----------------------------------------------
Choose PROC
		push eax;
		push ecx;
		push ebx;
		push edx;
		push edi;
	stage_move:
		INVOKE Movecursor                   ;移動游標
		INVOKE print
		INVOKE Boundary, cursor.X, cursor.Y ;確認游標有沒有在棋盤內
		cmp ax, 1
		jne stage_move                      ;沒有的話回到移動游標的狀態 
		INVOKE IsChess, cursor.X, cursor.Y  ;確認選到的是不是正確的棋子(是不是和control相同)
		cmp al, control
		jne invalidchoose                 	;選錯的話回到移動游標的狀態  
		mov bl, al
		mov ecx, 15                         ;count=15
		mov ah, cursor.X                    ;把游標的XY傳進ax
		mov al, cursor.Y
		cmp bl, 1                           ;是紅棋
		je chessR
		cmp bl, 2                           ;是綠棋
		je chessG
		cmp bl, 3                           ;是黃棋
		je chessY
		
	chessR: 
		mov edi, OFFSET R                   ;edi指到R(紅棋)的起始位置
		jmp stage_return
		
	chessG:
		mov edi, OFFSET G                   ;edi指到G(綠棋)的起始位置	
		jmp stage_return
		
	chessY:
		mov edi, OFFSET Y                   ;edi指到Y(黃棋)的起始位置	
		jmp stage_return
		
	stage_return:
		cmp ah, (COOR PTR [edi]).X
		jnz reloop							;X座標不符
		cmp al, (COOR PTR [edi]).Y
		jnz reloop							;Y座標不符
		jmp stage_find						;找到相符位置的棋子
		
	reloop:
		add edi, TYPE COOR					;判斷選取的是否為下一隻棋子
		loop stage_return
		
	stage_find:
		mov esi, edi                        ;回傳esi=edi
		pop eax;
		pop ecx;
		pop ebx;
		pop edx;
		pop edi;
		ret
		
	;非法選取棋子
	invalidchoose:
		mov  dh, 0
		mov  dl, 0
		call Gotoxy
		mov  edx, OFFSET chooseyourschess
		call WriteString					;印出"You Can't choose other's chess or choose Nothing. Please choose your own chess! "狀態
		INVOKE Transfer, cursor.X, cursor.Y
		call Gotoxy
		jmp stage_move                      ;選錯的話回到移動游標的狀態	
		
Choose ENDP
;----------------------------------------------IsChess----------------------------------------------
IsChess PROC,
		boolx: sbyte, booly: sbyte
		
		;將使用的暫存器的值存到堆疊
		push ecx							
		push ebx
		push edi
		
		mov ecx, 45							;設定迴圈次數
		mov edi, OFFSET R					;設定edi指到R的記憶體位置
	find:
		mov bl, (COOR PTR [edi]).X
		mov bh, (COOR PTR [edi]).Y
		
		cmp boolx, bl
		jnz addpointer						;X座標不符
		cmp booly, bh
		jnz addpointer						;Y座標不符
		jz lookecx
		
	addpointer:
		add edi, TYPE COOR
		loop find
		
	;找到對應位置的棋子 判斷ecx範圍 取的棋子的所有者
	lookecx:
		cmp ecx, 30
		jg findr							;紅棋
		cmp ecx, 15
		jg findg							;綠棋
		cmp ecx, 0
		jg findy							;黃棋
		cmp ecx, 0
		jz nofind							;無棋子
		
	;紅棋  al = 1
	findr:
		mov al, 1
		pop  edi
		pop  ebx
		pop  ecx
		ret
		
	;綠棋	al = 2
	findg:
		mov al, 2
		pop  edi
		pop  ebx
		pop  ecx
		ret
		
	;黃棋  al = 3
	findy:
		mov al, 3
		pop  edi
		pop  ebx
		pop  ecx
		ret
		
	;無棋子	 al = 0
	nofind:
		mov al, 0
		pop  edi
		pop  ebx
		pop  ecx
		ret
		
IsChess ENDP
END main