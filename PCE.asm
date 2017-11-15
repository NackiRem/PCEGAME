.386
.model flat, stdcall
option casemap:none

include			windows.inc
include 		gdi32.inc 
includelib		gdi32.lib
include 		user32.inc 
includelib		user32.lib
include 		kernel32.inc 
includelib 		kernel32.lib

;---------------------------
;equ等值定义
;---------------------------
IDB_START			equ 	100
IDB_BACKGROUND  	equ 	101
IDB_BLUE_BRICK  	equ  	102
IDB_GREEN_BRICK  	equ  	103
IDB_RED_BRICK  		equ  	104
IDB_STONE_BRICK  	equ 	105
IDB_YELLOW_BRICK  	equ  	106
IDB_HERO  			equ 	107

WINDOWS_WIDTH	equ 	500
WINDOWS_HEIGHT 	equ 	700

TIMER_ID 		equ 	1
TIMER_ELAPSE 	equ 	10

HERO_SIZE_X 		equ 	40
HERO_SIZE_Y 		equ 	65
HERO_MAX_FRAME_NUM 	equ 	12
BRICK_SIZE_X 		equ 	75
BRICK_SIZE_Y 		equ 	75
BACKGROUND_SIZE_X 	equ 	500
BACKGROUND_SIZE_Y 	equ 	700
BLOCK_COLOR_NUM 	equ 	5
BLOCK_NUM_X 		equ 	10
BLOCK_NUM_Y 		equ 	20


;---------------------------
;结构体定义
;---------------------------
Hero struct
  hBmp 			HBITMAP ?
  pos 			POINT 	<>
  h_size		_SIZE 	<>
  curFrameIndex dd 	 	?
  maxFrameSize 	dd 		?
  speed_x 		dd 		?
  speed_y		dd 		?
  g 			dd 		?
Hero ends

Brick struct
  hBmp 			HBITMAP ?
  pos 			POINT 	<>
  b_size		_SIZE 	<>
  color 		dd 		?
  clicked 		dd 		?
  speed_x		dd 		?
  speed_y 		dd 		?
  g 			dd 		?
Brick ends


;---------------------------
;数据段
;---------------------------
.data?
hInstance 		dd		?
hWinMain 		dd  	?
;位图句柄
;---------------------------
m_hBackBmp				dd 	?
m_hHeroBmp				dd 	?
m_hBlueBlockBmp			dd 	?
m_hGreenBlockBmp		dd 	?
m_hPurpleBlockBmp		dd 	?
m_hStoneBlockBmp		dd 	?
m_hYellowBlockBmp		dd 	?



.data
szClassName		db		'Myclass', 0
szCaptionMain	db		'My first Window!', 0

;全局变量：
;GameState: 0--游戏开始界面, 1--游戏中，2--游戏结束
GameState		dd 		0
TotalGrade  	dd  	0
MapStartX  		dd      -125
MapStartY  		dd  	300
m_brickBmpNames dd  IDB_BLUE_BRICK, IDB_RED_BRICK, IDB_GREEN_BRICK, IDB_STONE_BRICK, IDB_YELLOW_BRICK

m_hero 			Hero 	<>
m_Map 			Brick 	10 	DUP(<>)


;---------------------------
;代码段
;---------------------------
.code
CreateHero proc
  pushad
  ;mov m_hero.hBmp, m_HeroBmp
  mov eax, m_HeroBmp
  mov m_hero.hBmp, eax
  mov m_hero.pos.x, 250
  mov m_hero.pos.y, 235
  mov m_hero.h_size.x, HERO_SIZE_X
  mov m_hero.h_size.y, HERO_SIZE_Y
  mov m_hero.curFrameIndex, 0
  mov m_hero.maxFrameSize, HERO_MAX_FRAME_NUM
  mov m_hero.speed_x, 0
  mov m_hero.speed_y, 0
  mov m_hero.g, 1
  popad
  ret
CreateHero endp

CreateMap proc
  pushad
  mov ecx, 20
  xor esi, esi
    L1:
      push ecx
      mov ecx, 10
      xor ebx, ebx
        L2:
          mov ax, RowSize
          mul esi
          add eax, ebx
          ;mov eax,m_Map[eax]
          ;call WriteInt
          mov edx, m_BrickBmp[0]
          mov m_Map[eax].hBmp, edx
          

          xor eax, eax
          add ebx, TYPE Brick
        LOOP L2
        add esi, 1
       pop ecx
      LOOP L1
  popad
  ret
CreateMap endp

Init	proc 	uses ebx edi esi, hWnd, wParam, lParam
		invoke	LoadBitmap, hInstance, IDB_BACK
		mov 	m_hBackBmp, eax
		invoke	LoadBitmap, hInstance, IDB_BRICK_BLUE
		mov 	m_hBlueBlockBmp, eax
		invoke	LoadBitmap, hInstance, IDB_BRICK_GREEN
		mov 	m_hGreenBlockBmp, eax
		invoke	LoadBitmap, hInstance, IDB_BRICK_PURPLE
		mov 	m_hPurpleBlockBmp, eax
		invoke	LoadBitmap, hInstance, IDB_BRICK_STONE
		mov 	m_hStoneBlockBmp, eax
		invoke	LoadBitmap, hInstance, IDB_BRICK_YELLOW
		mov 	m_hYellowBlockBmp, eax
		invoke	LoadBitmap, hInstance, IDB_HERO
		mov 	m_hHeroBmp, eax


		invoke	InvalidateRect, hWnd, NULL, FALSE
		ret
Init 	endp


_StartRender 	proc uses ebx edi esi, hWnd
		local	@stPs:PAINTSTRUCT, @hdc, @hdcBmp, @hdcBuffer
		local	@cptBmp, @m_hStartBmp
		pushad

		invoke 	BeginPaint, hWnd, addr @stPs
		mov 	@hdc, eax
		invoke	CreateCompatibleBitmap, @hdc, WINDOWS_WIDTH, WINDOWS_HEIGHT
		mov		@cptBmp, eax
		invoke	CreateCompatibleDC, @hdc
		mov 	@hdcBmp, eax
		invoke	CreateCompatibleDC, @hdc
		mov		@hdcBuffer, eax
		invoke 	LoadBitmap, hInstance, IDB_START
		mov		@m_hStartBmp, eax

		invoke	SelectObject, @hdcBuffer, @cptBmp
		invoke 	SelectObject, @hdcBmp, @m_hStartBmp
		invoke 	BitBlt, @hdcBuffer, 0, 0, WINDOWS_WIDTH, WINDOWS_HEIGHT, @hdcBmp, 0, 0, SRCCOPY
		invoke	BitBlt, @hdc, 0, 0, WINDOWS_WIDTH, WINDOWS_HEIGHT, @hdcBuffer, 0, 0, SRCCOPY

		invoke	DeleteObject, @cptBmp
		invoke 	DeleteObject, @m_hStartBmp
		invoke	DeleteDC, @hdcBuffer
		invoke 	DeleteDC, @hdcBmp

		invoke 	EndPaint, hWnd, addr @stPs
		popad
		ret
_StartRender endp


Render proc uses ebx edi esi, hWnd
		local 	@stPs:PAINTSTRUCT, @hdc, @hdcBmp, @hdcBuffer
		local 	@cptBmp
		pushad



		popad
		ret
Render endp


OverRender proc uses ebx edi esi, hWnd
		ret
OverRender endp


KeyDown proc uses ebx edi esi, hWnd, wParam, lParam
  .if wParam == VK_UP
    ;人物位置改变
    invoke InvalidateRect, hWnd, NULL, FALSE

  .elseif wParam == VK_DOWN
    ;人物位置改变
    invoke InvalidateRect, hWnd, NULL, FALSE

  .elseif wParam == VK_RIGHT
    ;人物位置改变
    invoke InvalidateRect, hWnd, NULL, FALSE

  .elseif wParam == VK_LEFT
    ;人物位置改变
    invoke InvalidateRect, hWnd, NULL, FALSE

  .endif
  ret
KeyDown endp


KeyUp proc uses ebx edi esi, hWnd, wParam, lParam
.if wParam == VK_UP
  ;人物位置改变
  invoke InvalidateRect, hWnd, NULL, FALSE

.elseif wParam == VK_DOWN
  ;人物位置改变
  invoke InvalidateRect, hWnd, NULL, FALSE

.elseif wParam == VK_RIGHT
  ;人物位置改变
  invoke InvalidateRect, hWnd, NULL, FALSE

.elseif wParam == VK_LEFT
  ;人物位置改变
  invoke InvalidateRect, hWnd, NULL, FALSE

.endif
  ret
KeyUp endp


LButtonDown 	proc, 	hWnd, wParam, lParam
		local	@ptMouse:POINT
		pushad

		invoke 	LOWORD, lParam
		mov		ptMouse, eax
		invoke 	HIWORD, lParam
		mov 	ptMouse, eax

		.if  GameState == 0
			mov 	eax, 1
			mov 	GameState, eax
			invoke	Render, hWnd
		.endif

		popad
		ret
LButtonDown 	endp

HeroUpdate proc
ret
HeroUpdate endp


MapUpdate proc
ret
MapUpdate endp


GameStateUpdate proc
ret
GameStateUpdate endp


TimerUpdate proc uses ebx edi esi, hWnd, wParam, lParam
  invoke HeroUpdate
  invoke MapUpdate
  invoke GameStateUpdate
  invoke InvalidateRect, hWnd, NULL, FALSE

  .if GameState == 2
    invoke KillTimer, hWnd, TIMER_ID
  .endif
  ret
TimerUpdate endp


_ProcWinMain 	proc	uses ebx edi esi ebp, hWnd, uMsg,wParam,lParam
		local	@stPs:PAINTSTRUCT
		local	@stRect:RECT
		local	@hDc
		
		mov	eax,uMsg
		.if eax == WM_CREATE
			invoke	Init, hWnd, wParam, lParam
		.elseif	eax == WM_PAINT
			.if GameState == 0
				invoke _StartRender, hWnd
			.elseif GameState == 1
				invoke Render,hWnd
			.elseif GameState == 2
				invoke OverRender, hWnd
			.endif
		.elseif eax == WM_KEYDOWN
			invoke KeyDown, hWnd, wParam, lParam
		.elseif eax == WM_KEYUP
			invoke KeyUp, hWnd, wParam, lParam
		.elseif eax == WM_LBUTTONDOWN
			invoke 	LButtonDown, hWnd, wParam, lParam
		.elseif eax == WM_TIMER
			invoke TimerUpdate, hWnd, wParam, lParam
		.elseif	eax == WM_CLOSE
			invoke	DestroyWindow, hWinMain
			invoke	PostQuitMessage, NULL
		.else
			invoke	DefWindowProc, hWnd, uMsg, wParam, lParam
			ret
		.endif
		
		xor	eax,eax
		ret
_ProcWinMain	endp

_WinMain	proc
		local	@stWndClass:WNDCLASSEX
		local	@stMsg:MSG

		invoke	GetModuleHandle, NULL
		mov 	hInstance, eax
		invoke	RtlZeroMemory, addr @stWndClass, sizeof @stWndClass
;------------------------
;注册窗口类
;------------------------
		invoke 	LoadCursor, 0, IDC_ARROW
		mov		@stWndClass.hCursor,eax
		push	hInstance
		pop		@stWndClass.hInstance
		mov 	@stWndClass.cbSize, sizeof WNDCLASSEX
		mov    	@stWndClass.style, CS_HREDRAW or CS_VREDRAW
		mov  	@stWndClass.lpfnWndProc, offset _ProcWinMain
		mov 	@stWndClass.hbrBackground, COLOR_WINDOW + 1
		mov 	@stWndClass.lpszClassName, offset szClassName
		invoke	RegisterClassEx, addr @stWndClass
;-----------------------
;建立并显示窗口
;-----------------------
		invoke	CreateWindowEx, WS_EX_CLIENTEDGE, offset szClassName, offset szCaptionMain, WS_OVERLAPPEDWINDOW, WINDOWS_X, WINDOWS_Y, WINDOWS_WIDTH, WINDOWS_HEIGHT, NULL, NULL, hInstance, NULL
		mov 	hWinMain, eax
		invoke	ShowWindow, hWinMain, SW_SHOWNORMAL
		invoke 	UpdateWindow, hWinMain
;-----------------------
;消息循环
;-----------------------
		.while	TRUE
			invoke	GetMessage, addr @stMsg, NULL, 0, 0
			.break	.if eax == 0
			invoke 	TranslateMessage, addr @stMsg
			invoke 	DispatchMessage, addr @stMsg
		.endw
		ret
_WinMain 	endp

start:
		call 	_WinMain
		invoke 	ExitProcess, NULL
end 	start














