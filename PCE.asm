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
IDB_START		equ 	100


;---------------------------
;数据段
;---------------------------
.data?
hInstance 		dd		?
hWinMain 		dd  	?

.data
szClassName		db		'Myclass', 0
szCaptionMain	db		'My first Window!', 0
szText			db		'Win32 Assembly, Simple and powerful !', 0
gameStatus		dd 		0

.const
WINDOWS_X		dd 		100
WINDOWS_Y		dd 		100
WINDOWS_WIDTH	dd		600
WINDOWS_HEIGHT	dd		400

;---------------------------
;代码段
;---------------------------
.code
_InitWindows	proc 	hWnd, wParam, lParam
		invoke	InvalidateRect, hWnd, NULL, FALSE
		ret
_InitWindows 	endp


_StartRender proc uses ebx edi esi, hWnd
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
		ret
Render endp


OverRender proc uses ebx edi esi, hWnd
		ret
OverRender endp


_ProcWinMain 	proc	uses ebx edi esi ebp, hWnd, uMsg,wParam,lParam
		local	@stPs:PAINTSTRUCT
		local	@stRect:RECT
		local	@hDc
		
		mov	eax,uMsg
		.if eax == WM_CREATE
			invoke	_InitWindows, hWnd, wParam, lParam
		.elseif	eax == WM_PAINT
			.if gameStatus == 0
				invoke _StartRender, hWnd
			.endif
			; invoke	BeginPaint, hWnd, addr @stPs
			; mov	@hDc, eax

			; invoke	GetClientRect, hWnd, addr @stRect
			; invoke	DrawText, @hDc, addr szText,-1, addr @stRect, DT_SINGLELINE or DT_CENTER or DT_VCENTER
			; invoke	EndPaint, hWnd, addr @stPs
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












