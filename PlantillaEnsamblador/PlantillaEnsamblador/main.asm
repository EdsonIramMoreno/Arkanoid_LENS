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

; ================ PROTOTIPOS ======================================
; Delcaramos los prototipos que no est�n declarados en las librerias
; (Son funciones que nosotros hicimos)
main			proto
credits			proto	:DWORD
playMusic		proto
joystickError	proto
WinMain			proto	:DWORD, :DWORD, :DWORD, :DWORD

; =========================================== DECLARACION DE VARIABLES =====================================================
.data
; ==========================================================================================================================
; =============================== VARIABLES QUE NORMALMENTE NO VAN A TENER QUE CAMBIAR =====================================
; ==========================================================================================================================
className				db			"ProyectoEnsamblador",0		; Se usa para declarar el nombre del "estilo" de la ventana.
windowHandler			dword		?							; Un HWND auxiliar
windowClass				WNDCLASSEX	<>							; Aqui es en donde registramos la "clase" de la ventana.
windowMessage			MSG			<>							; Sirve pare el ciclo de mensajes (los del WHILE infinito)
clientRect				RECT		<>							; Un RECT auxilar, representa el �rea usable de la ventana
windowContext			HDC			?							; El contexto de la ventana
layer					HBITMAP		?							; El lienzo, donde dibujaremos cosas
layerContext			HDC			?							; El contexto del lienzo
auxiliarLayer			HBITMAP		?							; Un lienzo auxiliar
auxiliarLayerContext	HBITMAP		?							; El contexto del lienzo auxiliar
clearColor				HBRUSH		?							; El color de limpiado de pantalla
windowPaintstruct		PAINTSTRUCT	<>							; El paintstruct de la ventana.
joystickInfo			JOYINFO		<>							; Informaci�n sobre el joystick
; Mensajes de error:
errorTitle				byte		'Error',0
joystickErrorText		byte		'No se pudo inicializar el joystick',0
; ==========================================================================================================================
; ========================================== VARIABLES QUE PROBABLEMENTE QUIERAN CAMBIAR ===================================
; ==========================================================================================================================
; El t�tulo de la ventana
windowTitle				db			"Plantilla Ensamblador",0
; El ancho de la venata CON TODO Y LA BARRA DE TITULO Y LOS MARGENES
windowWidth				DWORD		287	
; El alto de la ventana CON TODO Y LA BARRA DE TITULO Y LOS MARGENES
windowHeight			DWORD		229							
; Un string, se usa como t�tulo del messagebox NOTESE QUE TRAS ESCRIBIR EL STRING, SE LE CONCATENA UN 0
messageBoxTitle			byte		'Plantilla ensamblador: Cr�ditos',0	
; Se usa como texto de un mensaje, el 10 es para hacer un salto de linea
; (Ya que 10 es el valor ascii de \n)
messageBoxText			byte		'Programaci�n: Edgar Abraham Santos Cervantes',10,'Arte: Est�dio Vaca Roxa',10,'https://bakudas.itch.io/generic-rpg-pack',0
; El nombre de la m�sica a reproducir.
; Aseg�rense de que sea .wav
musicFilename			byte		'01.wav',0
; El manejador de la imagen a manuplar, pueden agregar tantos como necesiten.
image					HBITMAP		?
; El nombre de la imagen a cargar
imageFilename			byte		'atlas.bmp',0

; =============== MACROS ===================
RGB MACRO red, green, blue
	exitm % blue shl 16 + green shl 8 + red
endm 

.code

main proc
	; El programa comienza aqu�.
	; Le pedimos a un hilo que reprodusca la m�sica
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
	; Tenemos que decir el tama�o de nuestra estructura, si no se lo dicen no se podr� crear la ventana.
	mov		windowClass.cbSize, SIZEOF WNDCLASSEX
	; Le asignamos nuestro HINSTANCE
	mov		eax, hInstance
	mov		windowClass.hInstance, eax
	; Asignamos el nombre de nuestra "clase"
	mov		windowClass.lpszClassName, OFFSET className
	; Registramos la clase
	invoke RegisterClassExA, addr windowClass                      
    
	; ========== CREACI�N DE LA VENATANA =============
	; Creamos la ventana.
	; Le asignamos los estilos para que se pueda crear pero que NO se pueda alterar su tama�o, maximizar ni minimizar
	xor		ebx, ebx
	mov		ebx, WS_OVERLAPPED
	or		ebx, WS_CAPTION
	or		ebx, WS_SYSMENU
	invoke CreateWindowExA, NULL, ADDR className, ADDR windowTitle, ebx, CW_USEDEFAULT, CW_USEDEFAULT, windowWidth, windowHeight, NULL, NULL, hInstance, NULL
    ; Guardamos el resultado en una variable auxilar y mostramos la ventana.
	mov		windowHandler, eax
    invoke ShowWindow, windowHandler,cmdShow               
    invoke UpdateWindow, windowHandler                    

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
; La mayoria de la l�gica de su proyecto se encontrar� aqu�.
; (O desde aqu� se mandar�n a llamar a otras funciones)
WindowCallback proc handler:dword, message:dword, wParam:dword, lParam:dword
	.IF message == WM_CREATE
		; Lo que sucede al crearse la ventana.
		; Normalmente se usa para inicializar variables.
		; Obtiene las dimenciones del �rea de trabajo de la ventana.
		invoke	GetClientRect, handler, addr clientRect
		; Obtenemos el contexto de la ventana.
		invoke	GetDC, handler
		mov		windowContext, eax
		; Creamos un bitmap del tama�o del �rea de trabajo de nuestra ventana.
		invoke	CreateCompatibleBitmap, windowContext, clientRect.right, clientRect.bottom
		mov		layer, eax
		; Y le creamos un contexto
		invoke	CreateCompatibleDC, windowContext
		mov		layerContext, eax
		; Liberamos windowContext para poder trabajar con lo dem�s
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
		; Aqu� pueden poner las cosas que deseen dibujar
		invoke	TransparentBlt, auxiliarLayerContext, 0, 0, 271, 191, layerContext, 65, 257, 271, 191, 00000FF00h
		invoke	TransparentBlt, auxiliarLayerContext, 224, -24, 48, 74, layerContext, 144, 166, 48, 74, 00000FF00h
		invoke	TransparentBlt, auxiliarLayerContext, 224-48, -36, 48, 74, layerContext, 144, 166, 48, 74, 00000FF00h
		invoke	TransparentBlt, auxiliarLayerContext, 224-48*2, -24, 48, 74, layerContext, 144, 166, 48, 74, 00000FF00h
		invoke	TransparentBlt, auxiliarLayerContext, 200-48*3, -24, 48, 74, layerContext, 144, 166, 48, 74, 00000FF00h
		invoke	TransparentBlt, auxiliarLayerContext, 200-48*4, -24, 48, 74, layerContext, 144, 166, 48, 74, 00000FF00h
		invoke	TransparentBlt, auxiliarLayerContext, 200-48*5, -24, 48, 74, layerContext, 144, 166, 48, 74, 00000FF00h
		invoke	TransparentBlt, auxiliarLayerContext, 200-48*6, -24, 48, 74, layerContext, 144, 166, 48, 74, 00000FF00h
		invoke	TransparentBlt, auxiliarLayerContext, 24, 80, 48, 74, layerContext, 144, 166, 48, 74, 00000FF00h
		invoke	TransparentBlt, auxiliarLayerContext, 0, 100, 48, 74, layerContext, 144, 166, 48, 74, 00000FF00h
		invoke	TransparentBlt, auxiliarLayerContext, 32, 112, 48, 74, layerContext, 144, 166, 48, 74, 00000FF00h
		invoke	TransparentBlt, auxiliarLayerContext, 96, 100, 14, 20, layerContext, 272, 187, 14, 20, 00000FF00h
		invoke	TransparentBlt, auxiliarLayerContext, 177, 100, 14, 20, layerContext, 272, 187, 14, 20, 00000FF00h
		; Ya que terminamos de dibujarlas, las mostramos en pantalla
		invoke	BitBlt, windowContext, 0, 0, clientRect.right, clientRect.bottom, auxiliarLayerContext, 0, 0, SRCCOPY
		invoke  EndPaint, handler, addr windowPaintstruct
		; Es MUY importante liberar los recursos al terminar de usuarlos, si no se liberan la aplicaci�n se quedar� trabada con el tiempo
		invoke	DeleteDC, windowContext
		invoke	DeleteDC, auxiliarLayerContext
	.ELSEIF message == WM_KEYDOWN
		; Lo que hace cuando una tecla se presiona
		; Deben especificar las teclas de acuerdo a su c�digo ASCII
		; Pueden consultarlo aqu�: https://elcodigoascii.com.ar/
		; Movemos wParam a EAX para que AL contenga el valor ASCII de la tecla presionada.
		mov	eax, wParam
		; Esto es un ejemplo: Si presionamos la tecla P mostrar� los cr�ditos
		.IF al == 80
			invoke	credits, handler
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
		; Lo que significa que si la palanca est� en medio, la coordenada en X ser� 07FFFh
		; Y la coordenada Y tambi�n.
		; Lo m�ximo hacia arriba es 0 en Y
		; Lo m�ximo hacia abajo en FFFF en Y
		; Lo m�ximo hacia la derecha es FFFF en X
		; Lo m�ximo hacia la izquierda es 0 en X
		; Si la palanca no est� en ning�n extremo, ser� un valor intermedio
		; Este es un ejemplo: Si la palanca est� al m�ximo a la derecha, mostrar� los cr�ditos
		.IF bx == 0FFFFh
			invoke credits, handler
		.ENDIF 
	.ELSEIF message == MM_JOY1BUTTONDOWN
		; Lo que hace cuando presionas un bot�n del joystick
		; Pueden comparar que bot�n se presion� haciendo un AND
		xor	ebx, ebx
		mov	ebx, wParam
		and	ebx, JOY_BUTTON1
		; Esto es un ejemplo, si presionamos el bot�n 1 del joystick, mostrar� los cr�ditos
		.IF	ebx != 0
			invoke credits, handler
		.ENDIF
	.ELSEIF message == WM_TIMER
		; Lo que hace cada tick (cada vez que se ejecute el timer)
		invoke	InvalidateRect, handler, NULL, FALSE
	.ELSEIF message == WM_DESTROY
		; Lo que debe suceder al intentar cerrar la ventana.   
        invoke PostQuitMessage, NULL
    .ENDIF
	; Este es un fallback.
	; NOTA IMPORTANTE: Normalmente WinAPI espera que se le regrese ciertos valores dependiendo del mensaje que se est� procesando.
	; Como varia mucho entre mensaje y mensaje, entonces DefWindowProcA se encarga de regresar el mensaje predeterminado como si las cosas
	; fueran con normalidad. Pero en realidad pueden devolver otras cosas y el comportamiento de WinAPI cambiar�.
	; (Por ejemplo, si regresan -1 en EAX al procesar WM_CREATE, la ventana no se crear�)
    invoke DefWindowProcA, handler, message, wParam, lParam      
    ret
WindowCallback endp

; Reproduce la m�sica
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

; Muestra los cr�ditos
credits	proc handler:DWORD
	; Estoy matando al timer para que no haya problemas al mostrar el Messagebox.
	; Veanlo como un sistema de pausa
	invoke KillTimer, handler, 100
	xor ebx, ebx
	mov ebx, MB_OK
	or	ebx, MB_ICONINFORMATION
	invoke	MessageBoxA, handler, addr messageBoxText, addr messageBoxTitle, ebx
	; Volvemos a habilitar el timer
	invoke SetTimer, handler, 100, 10, NULL
	ret
credits endp

end main