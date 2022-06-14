.386
.model flat, stdcall
.stack 10448576
option casemap:none

; ========== LIBRERIAS =============
include masm32\include\windows.inc 
include masm32\include\kernel32.inc
include masm32\include\user32.inc
includelib masm32\lib\kernel32.lib
includelib masm32\lib\user32.lib
include masm32\include\gdi32.inc
includelib masm32\lib\Gdi32.lib
include masm32\include\msimg32.inc
includelib masm32\lib\msimg32.lib
include masm32\include\winmm.inc
includelib masm32\lib\winmm.lib
include Estructuras.inc
include masm32\include\masm32.inc
includelib masm32\lib\masm32.lib

; ================ PROTOTIPOS ======================================
; Delcaramos los prototipos que no están declarados en las librerias
; (Son funciones que nosotros hicimos)
main			proto
Ppause			proto	:DWORD
playMusic		proto
joystickError	proto
WinMain			proto	:DWORD, :DWORD, :DWORD, :DWORD
TimeProcBola	proto
UpdateCollisionBarra proto
UpdateCollisionBlock proto :SPRITE
GenRandomNumber	proto
ChecarNumAl		proto
ReStartGame		proto
ReiniciarBlockes proto
ReiniciarBB proto
CleanArrayNums proto
;LevelSelector proto

; =========================================== DECLARACION DE VARIABLES =====================================================
.data
; ==========================================================================================================================
; =============================== VARIABLES QUE NORMALMENTE NO VAN A TENER QUE CAMBIAR =====================================
; ==========================================================================================================================
className				db			"ProyectoEnsamblador",0		; Se usa para declarar el nombre del "estilo" de la ventana.
classNameI				db			"Arkanoid",0		; Se usa para declarar el nombre del "estilo" de la ventana.
windowHandler			dword		?							; Un HWND auxiliar
windowHandlerI			dword		?							; Un HWND auxiliar
windowClass				WNDCLASSEX	<>							; Aqui es en donde registramos la "clase" de la ventana.
windowClassI			WNDCLASSEX	<>							; Aqui es en donde registramos la "clase" de la ventana.
windowMessage			MSG			<>							; Sirve pare el ciclo de mensajes (los del WHILE infinito)
clientRect				RECT		<>							; Un RECT auxilar, representa el área usable de la ventana
clientRectV2			RECT		<>							; Un RECT auxilar, representa el área usable de la ventana
windowContext			HDC			?							; El contexto de la ventana
windowContextV2			HDC			?							; El contexto de la ventana
layer					HBITMAP		?							; El lienzo, donde dibujaremos cosas
layerContext			HDC			?							; El contexto del lienzo
auxiliarLayer			HBITMAP		?							; Un lienzo auxiliar
auxiliarLayerContext	HBITMAP		?							; El contexto del lienzo auxiliar
layerV2					HBITMAP		?							; El lienzo, donde dibujaremos cosas
layerContextV2			HDC			?							; El contexto del lienzo
auxiliarLayerV2			HBITMAP		?							; Un lienzo auxiliar
auxiliarLayerContextV2	HBITMAP		?							; El contexto del lienzo auxiliar
clearColor				HBRUSH		?							; El color de limpiado de pantalla
windowPaintstruct		PAINTSTRUCT	<>							; El paintstruct de la ventana.
windowPaintstructV2		PAINTSTRUCT	<>							; El paintstruct de la ventana.
joystickInfo			JOYINFO		<>							; Información sobre el joystick
; Mensajes de error:
errorTitle				byte		'Error',0
joystickErrorText		byte		'No se pudo inicializar el joystick',0
; ==========================================================================================================================
; ========================================== VARIABLES QUE PROBABLEMENTE QUIERAN CAMBIAR ===================================
; ==========================================================================================================================
; El título de la ventana
windowTitle				db			"Plantilla Ensamblador",0
Boton					db			"Button",0
BotonTitle				db			"Jugar",0
BotonTitleR				db			"Iniciar",0
; El ancho de la venata CON TODO Y LA BARRA DE TITULO Y LOS MARGENES
windowWidth				DWORD		715
; El alto de la ventana CON TODO Y LA BARRA DE TITULO Y LOS MARGENES
windowHeight			DWORD		720							
; Un string, se usa como título del messagebox NOTESE QUE TRAS ESCRIBIR EL STRING, SE LE CONCATENA UN 0
messageBoxTitle			byte		'Pause',0	
; Se usa como texto de un mensaje, el 10 es para hacer un salto de linea
; (Ya que 10 es el valor ascii de \n)
messageBoxText			byte		'Presione "Aceptar" para continuar',0
messageBoxTitleI		byte		'Nuevo Nivel',0	
messageBoxTextI			byte		'Presione "Aceptar" para continuar',0
messageBoxGameTI		byte		'Error',0	
messageBoxGameI			byte		'No se pude iniciar otro nivel sin acabar, el nivel anterior',0
; El nombre de la música a reproducir.
; Asegúrense de que sea .wav
musicFilename			byte		'Music.wav',0
; El manejador de la imagen a manuplar, pueden agregar tantos como necesiten.
image					HBITMAP		?
; El nombre de la imagen a cargar
imageFilename			byte		'ArkanoidFondo.bmp',0
; El manejador de la imagen a manuplar, pueden agregar tantos como necesiten.
image2					HBITMAP		?
; El nombre de la imagen a cargar
imageFilename2			byte		'SpritesaColor.bmp',0
; El manejador de la imagen a manuplar, pueden agregar tantos como necesiten.
imageI					HBITMAP		?
; El nombre de la imagen a cargar
imageFilenameI			byte		'ArkanoidInicioI.bmp',0

Barra SPRITE {12,120,280,585,76,23,0} 
Bola SPRITE {145,80,305,569,16,2,1}
LevelInd Nums {235,155,20,45}, {30,155,20,45}, {50,155,20,45}, {75,155,20,45}, {95,155,20,45}, {120,155,20,45}, {145,155,20,45}, {165,155,20,45}, {190,155,20,45}, {215,155,20,45}
Blocks SPRITE 15 dup ({125,5,0,0,55,16,0},{5,30,0,0,55,16,1});,{124,4,0,0,55,16,0},{185,4,0,0,55,16,0},{245,4,0,0,55,16,0},{305,4,0,0,55,16,0},{365,4,0,0,55,16,0},{245,4,0,0,55,16,0},{365,4,0,0,55,16,0},{245,4,0,0,55,16,0}
;Blocks SPRITE 15 dup ({5,30,0,0,55,16,0},{125,5,0,0,55,16,1})
GameOver Nums {47,223,97,86}
Numeros NumerosA 15 dup ({0,0})
repetido byte 0
Game byte 0
GameStart byte 0
auxI WORD 0
auxauxI WORD 0
;level byte 4
;level WORD 4
level WORD 1
Auxebx WORD 0
Auxedx WORD 0
Auxecx DWORD 0
Auxeax WORD 0
AuxColision byte 5
CantBlocks WORD 12
AuxCantBlocks WORD 12
;CantBlocks WORD 20
;AuxCantBlocks WORD 18
score WORD 0
;;;;;;;;;;;;;;;
NumMenor DWORD 40
NumMayor DWORD 700
;;;;;;;;;;;;;;;

; =============== MACROS ===================
RGB MACRO red, green, blue
	exitm % blue shl 16 + green shl 8 + red
endm 

.code

main proc
	; El programa comienza aquí.
	; Le pedimos a un hilo que reprodusca la música
	invoke	CreateThread, 0, 0, playMusic, 0, 0, 0
	; Obtenemos nuestro HINSTANCE.
	; NOTA IMPORTANTE: Las funciones de WinAPI normalmente ponen el resultado de sus funciones en el registro EAX
	invoke	GetModuleHandleA, NULL   
	; Mandamos a llamar a WinMain
	; Noten que, como GetModuleHandleA nos regresa nuestro HINSTANCE y los resultados de las funciones de WinAPI
	; suelen estar en EAX, entonces puedo pasar a EAX como el HINSTANCE
	invoke	WinMain, eax, NULL, NULL, SW_SHOWDEFAULT
	; Cierra el programa
	invoke ExitProcess,0
main endp

; Este es el WinMain, donde se crea la ventana y se hace el ciclo de mensajes.
WinMain proc hInstance:dword, hPrevInst:dword, cmdLine:dword, cmdShow:DWORD
	; ============== INICIALIZACION DE LA CLASE ====================
	; Establecemos nuestro callback procedure, que en este caso se llama WindowCallback
	mov		windowClass.lpfnWndProc, OFFSET WindowCallback
	; Tenemos que decir el tamaño de nuestra estructura, si no se lo dicen no se podrá crear la ventana.
	mov		windowClass.cbSize, SIZEOF WNDCLASSEX
	; Le asignamos nuestro HINSTANCE
	mov		eax, hInstance
	mov		windowClass.hInstance, eax
	; Asignamos el nombre de nuestra "clase"

	mov		windowClass.lpszClassName, OFFSET className
	; Registramos la clase
	invoke RegisterClassExA, addr windowClass        
	xor		ebx, ebx
	mov		ebx, WS_OVERLAPPED
	or		ebx, WS_CAPTION
	or		ebx, WS_SYSMENU
	invoke CreateWindowExA, NULL, ADDR className, ADDR windowTitle, ebx, CW_USEDEFAULT, CW_USEDEFAULT, windowWidth, windowHeight, NULL, NULL, hInstance, NULL
    ; Guardamos el resultado en una variable auxilar y mostramos la ventana.
	mov		windowHandler, eax
    invoke ShowWindow, windowHandler,SWP_HIDEWINDOW             
    invoke UpdateWindow, windowHandler            
	
	mov		windowClassI.lpfnWndProc, OFFSET WindowCallbackI
	; Tenemos que decir el tamaño de nuestra estructura, si no se lo dicen no se podrá crear la ventana.
	mov		windowClassI.cbSize, SIZEOF WNDCLASSEX
	; Le asignamos nuestro HINSTANCE
	mov		eax, hInstance
	mov		windowClassI.hInstance, eax
	; Asignamos el nombre de nuestra "clase"
	mov		windowClassI.lpszClassName, OFFSET classNameI
	; Registramos la clase
	invoke RegisterClassExA, addr windowClassI                
    
	; ========== CREACIÓN DE LA VENATANA =============
	; Creamos la ventana.
	; Le asignamos los estilos para que se pueda crear pero que NO se pueda alterar su tamaño, maximizar ni minimizar
	xor		ebx, ebx
	mov		ebx, WS_OVERLAPPED
	or		ebx, WS_CAPTION
	or		ebx, WS_SYSMENU
	invoke CreateWindowExA, NULL, ADDR classNameI, ADDR windowTitle, ebx, CW_USEDEFAULT, CW_USEDEFAULT, 500, 500, NULL, NULL, hInstance, NULL
    ; Guardamos el resultado en una variable auxilar y mostramos la ventana.
	mov		windowHandlerI, eax
    invoke ShowWindow, windowHandlerI,cmdShow               
    invoke UpdateWindow, windowHandlerI                   

	; ============= EL CICLO DE MENSAJES =======================
    invoke	GetMessageA, ADDR windowMessage, NULL, 0, 0
	.WHILE eax != 0                                  
        invoke	TranslateMessage, ADDR windowMessage
        invoke	DispatchMessageA, ADDR windowMessage
		invoke	GetMessageA, ADDR windowMessage, NULL, 0, 0
   .ENDW
    mov eax, windowMessage.wParam
	ret
WinMain endp


; El callback de la ventana.
; La mayoria de la lógica de su proyecto se encontrará aquí.
; (O desde aquí se mandarán a llamar a otras funciones)
WindowCallback proc handler:dword, message:dword, wParam:dword, lParam:dword
	.IF message == WM_CREATE
		; Lo que sucede al crearse la ventana.
		; Normalmente se usa para inicializar variables.
		; Obtiene las dimenciones del área de trabajo de la ventana.
		invoke	GetClientRect, handler, addr clientRect
		; Obtenemos el contexto de la ventana.
		invoke	GetDC, handler
		mov		windowContext, eax
		; Creamos un bitmap del tamaño del área de trabajo de nuestra ventana.
		invoke	CreateCompatibleBitmap, windowContext, clientRect.right, clientRect.bottom
		mov		layer, eax
		; Y le creamos un contexto
		invoke	CreateCompatibleDC, windowContext
		mov		layerContext, eax
		; Liberamos windowContext para poder trabajar con lo demás
		invoke	ReleaseDC, handler, windowContext
		; Le decimos que el contexto layerContext le pertenece a layer
		invoke	SelectObject, layerContext, layer
		invoke	DeleteObject, layer
		; Asignamos un color de limpiado de pantalla
		invoke	CreateSolidBrush, RGB(0,0,0)
		mov		clearColor, eax
		;Cargamos la imagen
		invoke	LoadImage, NULL, addr imageFilename, IMAGE_BITMAP, 0, 0, LR_LOADFROMFILE
		mov		image, eax
		invoke	LoadImage, NULL, addr imageFilename2, IMAGE_BITMAP, 0, 0, LR_LOADFROMFILE
		mov		image2, eax
		; Habilitamos el joystick
		invoke	joyGetNumDevs
		.IF eax == 0
			invoke joystickError	
		.ELSE
			invoke	joyGetPos, JOYSTICKID1, addr joystickInfo
			.IF eax != JOYERR_NOERROR
				invoke joystickError
			.ELSE
				invoke	joySetCapture, handler, JOYSTICKID1, NULL, FALSE
				.IF eax != 0
					invoke joystickError
				.ENDIF
			.ENDIF
		.ENDIF
		; Habilita el timer
		invoke	SetTimer, handler, 100, 10, NULL

	.ELSEIF message == WM_PAINT
		; El proceso de dibujado
		; Iniciamos nuestro windowContext
		invoke	BeginPaint, handler, addr windowPaintstruct
		mov		windowContext, eax
		; Creamos un bitmap auxilar. Esto es, para evitar el efecto de parpadeo
		invoke	CreateCompatibleBitmap, layerContext, clientRect.right, clientRect.bottom
		mov		auxiliarLayer, eax
		; Le creamos su contetxo
		invoke	CreateCompatibleDC, layerContext
		mov		auxiliarLayerContext, eax
		; Lo asociamos
		invoke	SelectObject, auxiliarLayerContext, auxiliarLayer
		invoke	DeleteObject, auxiliarLayer
		; Llenamos nuestro auxiliar con nuestro color de borrado, sirve para limpiar la pantalla
		invoke	FillRect, auxiliarLayerContext, addr clientRect, clearColor
		; Elegimos la imagen
		invoke	SelectObject, layerContext, image
		; Aquí pueden poner las cosas que deseen dibujar
		invoke	TransparentBlt, auxiliarLayerContext, 0, 0, 700, 700, layerContext, 0, 0, 700, 700, 000000000h
		invoke	SelectObject, layerContext, image2
		;Dibujado de la barra
		invoke	TransparentBlt, auxiliarLayerContext, Barra.posx, Barra.posy, Barra.lenx, Barra.leny, layerContext, Barra.dibx, Barra.diby, Barra.lenx, Barra.leny, 000000000h

		invoke	TransparentBlt, auxiliarLayerContext, Bola.posx, Bola.posy, Bola.lenx, Bola.lenx, layerContext, Bola.dibx, Bola.diby, Bola.lenx, Bola.lenx, 000000000h
		
		push ebx
		push eax
		push edx
		xor edx,edx
		xor eax,eax
		xor ebx,ebx
		;centenas
		mov bx,0
		invoke	TransparentBlt, auxiliarLayerContext, 585,100, LevelInd[bx].lx, LevelInd[bx].ly, layerContext, LevelInd[bx].x,LevelInd[bx].y, LevelInd[bx].lx, LevelInd[bx].ly, 000000000h
		;decenas
		.IF(CantBlocks == 12)
		mov level, 1
		.ELSEIF(CantBlocks == 14)
		mov level, 2
		.ELSEIF(CantBlocks == 16)
		mov level, 3
		.ELSEIF(CantBlocks == 18)
		mov level, 4
		.ELSEIF(CantBlocks == 20)
		mov level, 5
		.ENDIF
		mov ax,level
		mov bx, 8
		mul bx
		mov bl,80
		div bl
		xor ebx,ebx
		xor ah,ah
		mov bx, 8
		mul bx
		mov bx,ax
		invoke	TransparentBlt, auxiliarLayerContext, 605,100, LevelInd[bx].lx, LevelInd[bx].ly, layerContext, LevelInd[bx].x,LevelInd[bx].y, LevelInd[bx].lx, LevelInd[bx].ly, 000000000h
		;unidades
		mov ax,level
		mov bx, 8
		mul bx
		mov bx,ax
		.IF (ax >= 80)
		sub bx,80
		.ENDIF
		invoke	TransparentBlt, auxiliarLayerContext, 625,100, LevelInd[bx].lx, LevelInd[bx].ly, layerContext, LevelInd[bx].x,LevelInd[bx].y, LevelInd[bx].lx, LevelInd[bx].ly, 000000000h
		pop eax
		pop ebx
		pop edx

		;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

		push ebx
		push eax
		push edx
		xor edx,edx
		xor eax,eax
		xor ebx,ebx
		;centenas
		mov ax,score
		mov bx, 8
		mul bx
		mov bl,80
		div bl
		xor ebx,ebx
		xor ah,ah
		mov bx, 8
		mul bx
		mov bx,ax
		invoke	TransparentBlt, auxiliarLayerContext, 580,220, LevelInd[bx].lx, LevelInd[bx].ly, layerContext, LevelInd[bx].x,LevelInd[bx].y, LevelInd[bx].lx, LevelInd[bx].ly, 000000000h
		;decenas
		mov ax,score
		mov bx, 8
		mul bx
		mov bx,ax
		.IF (ax >= 80 && ax < 160) ;10-19
		sub bx,80
		.ELSEIF( ax >= 160 && ax < 240) ;20-29
		sub bx,160
		.ELSEIF( ax >= 240 && ax < 320) ;30-39
		sub bx, 240
		.ELSEIF( ax >= 320 && ax < 400) ;40-49
		sub bx, 320
		.ELSEIF( ax >= 400 && ax < 480) ;50-59
		sub bx, 400
		.ELSEIF( ax >= 480 && ax < 560) ;60-69
		sub bx, 480
		.ELSEIF( ax >= 560 && ax < 640) ;70-79
		sub bx, 560
		.ELSEIF( ax >= 640 && ax < 720) ;80-89
		sub bx, 640
		.ELSEIF( ax >= 720 && ax < 800) ;90-99
		sub bx, 720
		.ELSEIF (ax >= 800)
		mov score, 99
		.ENDIF
		invoke	TransparentBlt, auxiliarLayerContext, 600,220, LevelInd[bx].lx, LevelInd[bx].ly, layerContext, LevelInd[bx].x,LevelInd[bx].y, LevelInd[bx].lx, LevelInd[bx].ly, 000000000h
		;unidades
		mov bx,0
		invoke	TransparentBlt, auxiliarLayerContext, 620,220, LevelInd[bx].lx, LevelInd[bx].ly, layerContext, LevelInd[bx].x,LevelInd[bx].y, LevelInd[bx].lx, LevelInd[bx].ly, 000000000h
		pop eax
		pop ebx
		pop edx

	push ebx
		.IF(Game == 2 || Game == 3)
		invoke ShowWindow, windowHandlerI, SW_SHOW
		invoke ShowWindow, handler, SW_HIDE
	.ENDIF
	pop ebx

		;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
		push ebx
		push eax
		push edx
		push ecx
		xor edx,edx
		xor eax,eax
		xor ebx,ebx
		xor ecx,ecx

		;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
		mov ax, CantBlocks
		;inc ax
		mov auxI,ax
		mov cx, auxI
		ciclo:	
		mov auxI,cx
		mov ax, auxI
		dec ax
		mov bl,25
		mul bl
		mov bx,ax
		;push ecx
		mov Auxebx, cx
		invoke TransparentBlt, auxiliarLayerContext, Blocks[bx].posx,  Blocks[bx].posy,  Blocks[bx].lenx,  Blocks[bx].leny, layerContext,  Blocks[bx].dibx,  Blocks[bx].diby,  Blocks[bx].lenx,  Blocks[bx].leny, 000000000h
		xor ecx,ecx
		mov cx, Auxebx
		;pop ecx
		;xor ecx,ecx		
		;mov cx, auxI
		;sub cx,1
		loop ciclo 

		pop ebx
		pop eax
		pop edx
		pop ecx 
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
		; Ya que terminamos de dibujarlas, las mostramos en pantalla
		invoke	BitBlt, windowContext, 0, 0, clientRect.right, clientRect.bottom, auxiliarLayerContext, 0, 0, SRCCOPY
		invoke  EndPaint, handler, addr windowPaintstruct
		; Es MUY importante liberar los recursos al terminar de usuarlos, si no se liberan la aplicación se quedará trabada con el tiempo
		invoke	DeleteDC, windowContext
		invoke	DeleteDC, auxiliarLayerContext
		.IF(Game == 0)
			invoke	Ppause, handler
		.ENDIF
	.ELSEIF message == WM_KEYDOWN
		; Lo que hace cuando una tecla se presiona
		; Deben especificar las teclas de acuerdo a su código ASCII
		; Pueden consultarlo aquí: https://elcodigoascii.com.ar/
		; Movemos wParam a EAX para que AL contenga el valor ASCII de la tecla presionada.
		mov	eax, wParam
		; Esto es un ejemplo: Si presionamos la tecla P mostrará los créditos
		.IF (al == ' ')
			invoke	Ppause, handler
		.ENDIF

			.IF (al == 'D')
			
					;mov ebx, 5
					add Barra.posx, 5
					mov Barra.Movim,2
					.IF (Barra.posx > 470)  ;es el limite de ventana internamente para que se mueva Ryu
					sub Barra.posx, 5
					.ENDIF

				.ELSEIF (al == 'A')

				;mov ebx, 5
				sub Barra.posx, 5
				mov Barra.Movim,1
				.IF Barra.posx < 40  ;es el limite de ventana internamente para que se mueva Ryu
					add Barra.posx, 5
				.ENDIF
			.ENDIF
	.ELSEIF message == MM_JOY1MOVE
		; Lo que pasa cuando mueves la palanca del joystick
		xor	ebx, ebx
		xor edx, edx
		mov	edx, lParam
		mov bx, dx
		and	dx, 0
		ror edx, 16
		; En este punto, BX contiene la coordenada de la palanca en x
		; Y DX la coordenada y
		; Las coordenadas se dan relativas al la esquina superior izquierda de la palanca.
		; En escala del 0 a 0FFFFh
		; Lo que significa que si la palanca está en medio, la coordenada en X será 07FFFh
		; Y la coordenada Y también.
		; Lo máximo hacia arriba es 0 en Y
		; Lo máximo hacia abajo en FFFF en Y
		; Lo máximo hacia la derecha es FFFF en X
		; Lo máximo hacia la izquierda es 0 en X
		; Si la palanca no está en ningún extremo, será un valor intermedio
		; Este es un ejemplo: Si la palanca está al máximo a la derecha, mostrará los créditos
		
		.IF (bx == 0FFFFh)
			
					;mov ebx, 5
					add Barra.posx, 4
					mov Barra.Movim,2
					.IF (Barra.posx > 470)  ;es el limite de ventana internamente para que se mueva Ryu
					sub Barra.posx, 4
					.ENDIF

		.ELSEIF (bx == 00000h)

				;mov ebx, 5
				sub Barra.posx, 4
				mov Barra.Movim,1
				.IF Barra.posx < 40  ;es el limite de ventana internamente para que se mueva Ryu
					add Barra.posx, 4
				.ENDIF
			.ENDIF
	.ELSEIF message == WM_TIMER

	push ebx
	push ecx
	push edx
	push eax	
	invoke UpdateCollisionBarra
	.IF( ecx == 1 )
			;.IF (Barra.Movim == 0)
			;mov posiy,011b
			.IF (Bola.Movim == 1 && Barra.Movim == 1)
			mov Bola.Movim,1 
			.ELSEIF (Bola.Movim == 1 && Barra.Movim == 2)
			mov Bola.Movim,2
			.ELSEIF(Bola.Movim == 2 && Barra.Movim == 2)
			mov Bola.Movim,2
			.ELSEIF(Bola.Movim == 2 && Barra.Movim == 1)
			mov Bola.Movim,1 
			.ENDIF
			mov Bola.leny,2
			.ENDIF
	pop ebx
	pop ecx
	pop edx
	pop eax

		push eax
		push ebx
		push edx
		push ecx
			xor eax, eax
			xor ebx, ebx
			xor ecx, ecx
			xor edx, edx

			mov ax,CantBlocks
			mov auxI,ax
			mov cx, auxI

				cicloC:	
				mov ax, cx
				dec ax
				mov bl,25
				mul bl
				mov bx,ax
				mov Auxebx, bx
				mov auxI, cx
				invoke UpdateCollisionBlock, Blocks[bx]
				mov cx, auxI
				.IF(AuxColision != 5)
				mov bx, Auxebx
				mov ecx,1
				.ENDIF
				loop cicloC
			.IF(AuxColision != 5)
			mov bx, Auxebx
			.IF(Blocks[bx].Movim == 0)
			mov Blocks[bx].posx, 750	
			dec AuxCantBlocks
			mov ecx,1
			.ELSE
			mov Blocks[bx].diby, 55
			dec Blocks[bx].Movim
			.ENDIF
			.ENDIF
			.IF(AuxColision == 1)
			mov Bola.leny,1
			.ELSEIF(AuxColision == 2)
			mov Bola.leny,2
			.elseif (AuxColision == 3)
			mov Bola.Movim, 1
			.ELSEIF (AuxColision == 4)
			mov Bola.Movim, 2
			.ENDIF
			.IF(AuxColision != 5)
			inc score
			.ENDIF
			mov AuxColision, 5
		pop eax
		pop ebx
		pop edx
		pop ecx

	.IF (Bola.posx >= 525)
		mov Bola.Movim,1
		.ELSEIF (Bola.posx <= 41) 
		mov Bola.Movim, 2
		.ENDIF
		
		.IF(Bola.posy <= 36)
		mov Bola.leny, 1
		.ELSEIF (Bola.posy >= 630)
		mov Bola.leny, 2
		;mov Bola.posy, 630
		mov Game, 2
		.ENDIF

		.IF (AuxCantBlocks == 0)
		mov Game, 3
		.ENDIF

	invoke TimeProcBola
		; Lo que hace cada tick (cada vez que se ejecute el timer)
		invoke	InvalidateRect, handler, NULL, FALSE
	.ELSEIF message == WM_DESTROY
		; Lo que debe suceder al intentar cerrar la ventana.   
        invoke PostQuitMessage, NULL
    .ENDIF
	; Este es un fallback.
	; NOTA IMPORTANTE: Normalmente WinAPI espera que se le regrese ciertos valores dependiendo del mensaje que se esté procesando.
	; Como varia mucho entre mensaje y mensaje, entonces DefWindowProcA se encarga de regresar el mensaje predeterminado como si las cosas
	; fueran con normalidad. Pero en realidad pueden devolver otras cosas y el comportamiento de WinAPI cambiará.
	; (Por ejemplo, si regresan -1 en EAX al procesar WM_CREATE, la ventana no se creará)
    invoke DefWindowProcA, handler, message, wParam, lParam      
    ret
WindowCallback endp

WindowCallbackI proc handler:dword, message:dword, wParam:dword, lParam:dword
	.IF message == WM_CREATE
	; Lo que sucede al crearse la ventana.
		; Normalmente se usa para inicializar variables.
		; Obtiene las dimenciones del área de trabajo de la ventana.
		invoke	GetClientRect, handler, addr clientRectV2
		; Obtenemos el contexto de la ventana.
		invoke	GetDC, handler
		mov		windowContextV2, eax
		; Creamos un bitmap del tamaño del área de trabajo de nuestra ventana.
		invoke	CreateCompatibleBitmap, windowContextV2, clientRectV2.right, clientRectV2.bottom
		mov		layerV2, eax
		; Y le creamos un contexto
		invoke	CreateCompatibleDC, windowContextV2
		mov		layerContextV2, eax
		; Liberamos windowContext para poder trabajar con lo demás
		invoke	ReleaseDC, handler, windowContextV2
		; Le decimos que el contexto layerContext le pertenece a layer
		invoke	SelectObject, layerContextV2, layerV2
		invoke	DeleteObject, layerV2
		; Asignamos un color de limpiado de pantalla
		invoke	CreateSolidBrush, RGB(0,0,0)
		mov		clearColor, eax
		;Cargamos la imagen
		invoke	LoadImage, NULL, addr imageFilenameI, IMAGE_BITMAP, 0, 0, LR_LOADFROMFILE
		mov		imageI, eax

	xor ebx,ebx
	mov ebx, WS_VISIBLE
	or ebx, WS_CHILD
	or ebx, WS_TABSTOP
	invoke CreateWindowExA, NULL, ADDR Boton, ADDR BotonTitle, ebx, 175 ,275 , 50, 20, handler , 222 , NULL, NULL
	xor ebx,ebx
	mov ebx, WS_VISIBLE
	or ebx, WS_CHILD
	or ebx, WS_TABSTOP
	invoke CreateWindowExA, NULL, ADDR Boton, ADDR BotonTitleR, ebx, 250 ,275 , 65, 20, handler , 111 , NULL, NULL
	
	.ELSEIF message == WM_PAINT
	; El proceso de dibujado
		; Iniciamos nuestro windowContext
		invoke	BeginPaint, handler, addr windowPaintstructV2
		mov		windowContextV2, eax
		; Creamos un bitmap auxilar. Esto es, para evitar el efecto de parpadeo
		invoke	CreateCompatibleBitmap, layerContextV2, clientRectV2.right, clientRectV2.bottom
		mov		auxiliarLayerV2, eax
		; Le creamos su contetxo
		invoke	CreateCompatibleDC, layerContextV2
		mov		auxiliarLayerContextV2, eax
		; Lo asociamos
		invoke	SelectObject, auxiliarLayerContextV2, auxiliarLayerV2
		invoke	DeleteObject, auxiliarLayerV2
		; Llenamos nuestro auxiliar con nuestro color de borrado, sirve para limpiar la pantalla
		invoke	FillRect, auxiliarLayerContextV2, addr clientRectV2, clearColor
		; Elegimos la imagen
		invoke	SelectObject, layerContextV2, imageI
		; Aquí pueden poner las cosas que deseen dibujar
	;	invoke TransparentBlt, auxiliarLayerContext, Blocks[bx].posx,  Blocks[bx].posy,  Blocks[bx].lenx,  Blocks[bx].leny, layerContext,  Blocks[bx].dibx,  Blocks[bx].diby,  Blocks[bx].lenx,  Blocks[bx].leny, 000000000h
		.IF (Game == 0 || Game == 3)
		invoke	TransparentBlt, auxiliarLayerContextV2, 0, 0, 500, 500, layerContextV2, 0, 0, 500, 500, 0000000FFh
		.ELSEIF(Game == 2)
		invoke	TransparentBlt, auxiliarLayerContextV2, 0, 0, 500, 500, layerContextV2, 500, 0, 500, 500, 0000000FFh
		.ENDIF
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
		; Ya que terminamos de dibujarlas, las mostramos en pantalla
		invoke	BitBlt, windowContextV2, 0, 0, clientRectV2.right, clientRectV2.bottom, auxiliarLayerContextV2, 0, 0, SRCCOPY
		invoke  EndPaint, handler, addr windowPaintstructV2
		; Es MUY importante liberar los recursos al terminar de usuarlos, si no se liberan la aplicación se quedará trabada con el tiempo
		invoke	DeleteDC, windowContextV2
		invoke	DeleteDC, auxiliarLayerContextV2
	
	.ELSEIF message == WM_COMMAND
		mov eax, wParam

		.IF(al == 222)
		.IF(AuxCantBlocks == 0)
		xor ecx,ecx
		.IF(CantBlocks == 20)
		mov CantBlocks,12
		mov level,1
		mov score,0
		.ELSE
		add CantBlocks,2
		add level,1
		mov cx, CantBlocks
		;mov AuxCantBlocks, cx
		.ENDIF
		invoke ShowWindow, windowHandler, SW_SHOW
		invoke ShowWindow, handler, SW_HIDE
		push ebx
		push eax
		push edx
		push ecx	
		invoke GetTickCount
		invoke nseed, eax
		invoke ReStartGame
		pop eax
		pop ebx
		pop ecx
		pop edx
		mov Game,0
		.ELSE
		xor ebx,ebx
		mov ebx, MB_ICONERROR 
		invoke	MessageBoxA, handler, addr messageBoxGameI, addr messageBoxGameTI, ebx
		.ENDIF
		.ENDIF

		.IF(al == 111)
		invoke ShowWindow, windowHandler, SW_SHOW
		invoke ShowWindow, handler, SW_HIDE
		push ebx
		push eax
		push edx
		push ecx	
		invoke GetTickCount
		invoke nseed, eax
		invoke ReStartGame
		pop eax
		pop ebx
		pop ecx
		pop edx
		mov Game,0
		.ENDIF
	.ELSEIF message == WM_DESTROY
		; Lo que debe suceder al intentar cerrar la ventana.   
        invoke PostQuitMessage, NULL
    .ENDIF
	; Este es un fallback.
	; NOTA IMPORTANTE: Normalmente WinAPI espera que se le regrese ciertos valores dependiendo del mensaje que se esté procesando.
	; Como varia mucho entre mensaje y mensaje, entonces DefWindowProcA se encarga de regresar el mensaje predeterminado como si las cosas
	; fueran con normalidad. Pero en realidad pueden devolver otras cosas y el comportamiento de WinAPI cambiará.
	; (Por ejemplo, si regresan -1 en EAX al procesar WM_CREATE, la ventana no se creará)
    invoke DefWindowProcA, handler, message, wParam, lParam      
    ret
WindowCallbackI endp

; Reproduce la música
playMusic proc
	xor		ebx, ebx
	mov		ebx, SND_FILENAME
	or		ebx, SND_LOOP
	or		ebx, SND_ASYNC
	invoke	PlaySound, addr musicFilename, NULL, ebx
	ret
playMusic endp

; Muestra el error del joystick
joystickError proc
	xor		ebx, ebx
	mov		ebx, MB_OK
	or		ebx, MB_ICONERROR
	invoke	MessageBoxA, NULL, addr joystickErrorText, addr errorTitle, ebx
	ret
joystickError endp

; Muestra los créditos
Ppause	proc handler:DWORD
	; Estoy matando al timer para que no haya problemas al mostrar el Messagebox.
	; Veanlo como un sistema de pausa
	invoke KillTimer, handler, 100
	xor ebx, ebx
	mov ebx, MB_OK
	;or ebx, MB_ICONCANCEL
	or	ebx, MB_ICONINFORMATION
	.IF(Game == 0)
	invoke	MessageBoxA, handler, addr messageBoxTextI, addr messageBoxTitleI, ebx
	mov Game,1
	.ELSE
	invoke	MessageBoxA, handler, addr messageBoxText, addr messageBoxTitle, ebx
	.ENDIF
	; Volvemos a habilitar el timer
	invoke SetTimer, handler, 100, 10, NULL
	ret
Ppause endp

ReStartGame proc
		xor edx,edx
		xor eax,eax
		xor ebx,ebx
		xor ecx,ecx
		invoke CleanArrayNums
		mov score,0
		mov bx, CantBlocks
		mov AuxCantBlocks, bx
		mov ax,CantBlocks
		mov auxI,ax
		mov cx, auxI
		cicloP:		
		mov auxI,cx
		mov ax, auxI
		dec ax
		mov bl,25
		mul bl
		mov Auxebx, ax
		mov Auxecx, ecx
		invoke GenRandomNumber
		mov bx, Auxebx
		mov ecx,Auxecx
		mov ax, Auxeax
		mov Blocks[bx].posx, edx
		mov Blocks[bx].posy, eax	
		;mov cx, auxI
		;sub cx,1
		loop cicloP
		invoke ReiniciarBlockes
		invoke ReiniciarBB 
		ret
ReStartGame endp

TimeProcBola proc
.IF(Game != 0)
.IF (Bola.Movim == 1)
sub Bola.posx, 2
.ELSEIF (Bola.Movim == 2)
add Bola.posx, 2
.ENDIF
.IF (Bola.leny == 1)
add Bola.posy, 2
.ELSEIF (Bola.leny == 2)
sub Bola.posy, 2
.ENDIF
.ENDIF
ret
TimeProcBola endp

ReiniciarBlockes proc
	xor edx,edx
	xor eax,eax
	xor ebx,ebx
	xor ecx,ecx
	mov bx, CantBlocks
	;mov AuxCantBlocks, bx
	mov ax,CantBlocks
	mov auxI,ax
	mov cx, auxI
	;mov auxauxI,cx
	cicloBlo:		
	mov auxI,cx
	mov ax, auxI
	dec ax
	mov bl,25
	mul bl
	mov bx,ax
	.IF(Blocks[bx].diby == 55 && Blocks[bx].dibx == 5)
	mov Blocks[bx].diby, 30
	mov Blocks[bx].Movim, 1
	.ENDIF
	loop cicloBlo

	ret
ReiniciarBlockes endp

ReiniciarBB proc
	;xor ebx,ebx
	invoke nrandom, 2
	inc eax
	mov Bola.Movim, al
	mov Bola.leny, 2
	mov Barra.posx, 280
	mov Barra.posy, 585
	mov Bola.posx, 305
	mov Bola.posy, 569
	ret
ReiniciarBB endp

UpdateCollisionBarra proc 
	mov ebx, Bola.posy
	.IF(ebx >= 580 && ebx <= 590)
	mov eax, Barra.posx
	mov ebx, Bola.posx
	add ebx, Bola.leny
	mov edx,eax
	add edx, Barra.lenx
	.IF(eax < ebx && edx > ebx )
	mov ecx, 1
	.ENDIF
	.ENDIF
	
	ret
UpdateCollisionBarra endp

;UpdateCollisionBlock proc
;	xor eax,eax
;	xor ecx,ecx
;	xor edx,edx
;	mov ecx, Bola.posy
;	.IF(ecx < 580)
;	mov eax, Blocks[bx].posx
;	mov edx,eax
;	add edx, Blocks[bx].lenx
;	mov ecx, Bola.posx
;	sub ecx, Bola.lenx
	;;Podria disminuri lenx, para que fuera más preciso
;	.IF(eax <= Bola.posx && edx >= Bola.posx || eax <= ecx && edx >= Bola.posx) ;debe de estar bien
;	mov eax, Blocks[bx].posy
;	mov edx,eax
;	add edx, Blocks[bx].lenx
;	mov ecx, Bola.posy
;	add ecx, Bola.lenx
	;;.IF(eax < Bola.posy && edx > Bola.posy || Blocks[bx].posy < ecx && edx > ecx)
;	.IF(eax < Bola.posy || Blocks[bx].posy < ecx)
;	mov eax, Bola.posx
;	add eax, Bola.lenx
;	mov ecx, Blocks[bx].posx
;	mov edx,ecx
;	add edx, Blocks[bx].lenx
	;;	.IF( Bola.posx > ecx && Bola.posx < edx || Blocks[bx].posx < edx)
;	.IF( eax >= Blocks[bx].posx && Bola.posx <= edx )
;	mov ecx, Bola.posy
;	add ecx, Bola.lenx ;y
;	mov edx, Blocks[bx].posy
;	mov eax, edx
;	add edx, Blocks[bx].leny
;	;.IF(Blocks[bx].posy < edx && Blocks[bx].posy > eax)
;	.IF(Blocks[bx].posy >= ecx )
;	mov AuxColision,2
;	;.ELSEIF (Bola.posy < ecx && ecx > edx)
;	.ELSEIF (Bola.posy <= edx) ;;Ya esta
;	mov AuxColision,1 ;;Ya esta
;	.ENDIF
;	mov eax, Bola.posx
;	mov ecx, eax
;	add eax, Bola.lenx
;	mov edx, Blocks[bx].posx
;	;mov edx, ebx
;	add edx, Blocks[bx].lenx
;	.IF(Blocks[bx].posx > ecx)
;	;;;;;;;;;;;;;;;;;
;	mov eax, Bola.posy
;	;mov ebx, eax
;	add eax, Bola.lenx
;	mov ecx, Blocks[bx].posy
;	add ecx, Blocks[bx].leny
;	mov edx, Blocks[bx].posy
;	.IF(Blocks[bx].posy < eax && ecx > eax || Blocks[bx].posy < ebx && ecx > Bola.posy)
;	mov AuxColision,3
;	.ENDIF
;	.ENDIF
;	mov ecx, Blocks[bx].posx
;	add ecx, Blocks[bx].lenx
;;	.IF (Bola.posx >= ecx)
;	mov eax, Bola.posy
;	mov edx, eax
;	add edx, Bola.lenx
;	mov ecx, Blocks[bx].posy
;;	add ecx, Blocks[bx].leny
	;.IF(Blocks[bx].posy < eax && ecx > eax || Blocks[bx].posy < ebx && ecx > edx)
;	mov AuxColision,4
;	.ENDIF
;	.ENDIF
;	.ENDIF
;	.ENDIF
;	.ENDIF
;	.ENDIF
;	ret
;UpdateCollisionBlock endp
;UpdateCollisionBlock proc
;xor eax,eax
;xor ecx,ecx
;xor edx,edx
;.IF(Blocks[bx].posy < 580)
;mov eax, Bola.posx
;add eax, Bola.lenx
;mov ecx, Blocks[bx].posx
;add ecx, Blocks[bx].lenx
;.IF(Blocks[bx].posx >= Bola.posx+lenx && Blocks[bx].posx+lenx <= Bola.posx)
;.IF(Blocks[bx].posx <= eax && ecx >= Bola.posx)
;mov eax, Bola.posy
;add eax, Bola.lenx
;mov ecx, Blocks[bx].posy
;add ecx, Blocks[bx].leny
;mov edx, Blocks[bx].posy
;.IF (Blocks[bx].posy >= Bola.posy+Bola.lenx && Bola.posy+Bola.lenx < Blocks.posy+Blocks.leny)
;.IF (Blocks[bx].posy >= eax && eax < ecx)
;mov AuxColision, 2
;.IF (Blocks[bx].posy+Blocks.leny <= Bola.posy&& Bola.posy > Blocks.posy)
;.ELSEIF (ecx <= Bola.posy && Bola.posy > edx)
;mov AuxColision,1
;.ENDIF
;.ENDIF
;.ENDIF
;ret
;UpdateCollisionBlock endp

UpdateCollisionBlock proc Block:SPRITE
	xor eax,eax
	xor ebx,ebx
	xor ecx,ecx
	xor edx,edx
	.IF( Bola.posy < 580)
	mov eax, Block.posx
	mov ebx, Bola.posx
	mov ecx, ebx
	add ebx, Bola.lenx
	mov edx,eax
	add edx, Block.lenx
	.IF(Block.posx <= ebx && edx >= ebx || eax <= ecx && edx >= ecx)
	mov eax, Block.posy
	mov ebx, Bola.posy
	mov edx,eax
	add edx, Block.leny
	mov ecx,ebx
	add ecx, Bola.lenx
	.IF(Block.posy <= ebx && edx >= ebx || Block.posy <= ecx && edx >= ecx)
	mov eax, Bola.posx
	mov ebx,eax
	add ebx, Bola.lenx
	mov ecx, Block.posx
	mov edx,ecx
	add edx, Block.lenx
	.IF( Bola.posx >= ecx && Bola.posx <= edx || Block.posx <= edx)
	mov eax, Bola.posy
	mov ebx,eax
	add ebx, Bola.lenx
	mov ecx, Block.posy
	mov edx,ecx
	add edx, Block.leny
	;Blockposy < bolaposy y Blockposy+leny < Bolaposy+lenx(y)
	.IF(ecx >= Bola.posy && edx >= ebx)
	mov AuxColision,2 ;arriba
	.ENDIF
	;Bolaposy < Blockleny && bolaposy+lenx(y) > Blockposy+leny
	.IF (Bola.posy < edx && ebx >= edx)
	mov AuxColision,1 ;abajo
	.ENDIF
	mov eax, Bola.posx
	mov ecx, eax
	add eax, Bola.lenx
	mov ebx, Block.posx
	mov edx, ebx
	add ebx, Block.lenx
	;Block.posx > Bolaposx y Bolapox+lenx <= Block.posx+lenx
	.IF(Block.posx > ecx && eax <= Block.posx)
	mov eax, Bola.posy
	mov ebx, eax
	add ebx, Bola.lenx
	mov ecx, Block.posy
	add ecx, Block.leny
	mov edx, Block.posy
	; Blockposy < Bolaposy y block.posy+leny > Bolaposy
	;O Blockposy < bolaposy+lenx(y) y blockposy+leny >bolaposy+leny
	.IF(Block.posy <= eax && ecx >= eax || Block.posy <= ebx && ecx >= ebx)
	mov AuxColision,3
	.ENDIF
	.ENDIF
	;Bola.posx >= Blockposx+lenx &&  Blockposx+lenx > blockposx+lenx
	.IF (Bola.posx >= ebx && eax >= ebx);Block.posx
	mov eax, Bola.posy
	mov ebx, eax
	add ebx, Bola.lenx
	mov ecx, Block.posy
	add ecx, Block.leny
	.IF(Block.posy <= eax && ecx >= eax || Block.posy <= ebx && ecx >= ebx)
	mov AuxColision,4
	.ENDIF
	.ENDIF
	.ENDIF
	.ENDIF
	.ENDIF
	.ENDIF
	mov al, AuxColision
	ret
UpdateCollisionBlock endp

GenRandomNumber proc
mov cx, 10
cicloNume:
	invoke nrandom, 10
	mov bl,50
	mul bl
	mov dx,ax
	mov Auxedx, dx
	invoke nrandom, 17
	mov bl,16
	mul bl
	mov dx, Auxedx 
	.IF (dx > 50 && ax > 32)
	invoke ChecarNumAl
		.IF( repetido != 1 )
		mov ecx,1
		.ELSE
		mov cx,10
		.ENDIF
	mov repetido,0
	.ENDIF
loop cicloNume
	ret
GenRandomNumber endp

ChecarNumAl proc
	mov Auxeax, ax
	mov ax, auxI
	mov ecx,eax
	ChecarNums:
		mov ax,cx;;Cambio
		dec ax
		;mov bx,8
		mov bl, 4
		mul bl
		mov bx, ax
		xor eax,eax
		mov ax, Auxeax
		.IF(Numeros[bx].Ex == dx || Numeros[bx].Ey == ax)
		mov repetido, 1
		.ENDIF
		;mov ax,cx;
	.IF(repetido == 1)
	mov ecx, 1
	.ENDIF
	loop ChecarNums
	.IF(repetido != 1)
	mov ax,auxI
	mov cx,ax
	;;;;;;;;Recorrer el arreglo y llenar si el valor es 0
	CLlenarANumR:
	mov ax,cx
	dec ax
	;mov bl, 8
	mov bl, 4
	mul bl
	mov bx,ax
	mov ax, Auxeax
	.IF(Numeros[bx].Ex == 0 );&& Numeros[bx].Ey == 0
	mov Numeros[bx].Ex, dx
	mov Numeros[bx].Ey, ax
	mov cx,1
	.ENDIF
	loop CLlenarANumR
	.ENDIF
	ret
ChecarNumAl endp

CleanArrayNums proc 
	xor eax, eax
	xor ebx, ebx
	xor ecx, ecx
	mov ax,CantBlocks
	mov cx,ax
	;;;;;;;;Recorrer el arreglo y limpiartlo
	CCleanANumR:
	mov ax,cx
	dec ax
	mov bl, 4
	mul bl
	mov bx,ax
	;mov Numeros[bx].Ey, 0
	mov Numeros[bx].Ex, 0
	;mov ax,cx
	loop CCleanANumR
	ret
CleanArrayNums endp

;LevelSelector proc
;lvl selector	
;LevelSelector endp

end main