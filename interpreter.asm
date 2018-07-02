; interpreter.asm
; Name: Ericsson Schroeter
; Date: Novemeber 23, 2016
; CSE 2421 5:20 PM
; oxo5194c41

USE32

section .data
	
	stack	: times 1000 dd 0	; alloted stack

	pa	: times 30000 db 0	; program array
	ma	: times 30000 db 0	; memory array
	dp	: times 30000 dd 0	; data pointer variable
	ip	: times 30000 dd 0	; instruction pointer variable

	l	: dd 0			; counter varible

	lar	: times 30000 dd 0	; arrays to keep track of nested loops
	lear	: times 30000 dd 0

section .text

global _start

_start:

	; code
	
	call read_program		; read in program syntax into array pa			

	.main_loop:
	mov ebx, dword [ip]		; while element isn't NUL
	cmp [pa+ebx], dword 0
	je .end_loop

	push dword [pa+ebx]		; push BY instruction

	call execute_instr		; evaluate instruction

	add esp, dword 4		; restore stack
	
	inc dword [ip]			; increment instruction pointer

	jmp .main_loop
	.end_loop:

	; exit
	xor ebx, ebx
	mov eax, 1
	int 80h

; functions

read_byte:

	push ebp			; save current stack
	mov ebp, esp

	push ebx			; save current reg values
	push ecx
	push edx

	mov eax, 3			; std in one byte of info
	mov ebx, 0
	sub esp, 1
	mov ecx, esp
	mov edx, 1
	int 80h
	xor eax, eax
	mov al, byte [esp]
	add esp, 1

	pop edx				; restore reg values
	pop ecx
	pop ebx

	mov esp, ebp			; restore stack
	pop ebp

	ret				; return

write_byte:
					; save current stack
	push ebp
        mov ebp, esp

        push ebx			; save current reg values
        push ecx
        push edx

					; push parameter onto local stack
        push dword [ebp+8]

					; stdout byte 
        mov eax, 4
        mov ebx, 1
        mov ecx, esp    
        mov edx, 1
        int 80h

	add esp, 4			; restore local stack

        pop edx				; restore reg values
        pop ecx
        pop ebx

        mov esp, ebp			; restore stack
        pop ebp

        ret				; return

read_program:

	push ebp			; save current stack
	mov ebp, esp

        push ebx			; save current reg values
        push ecx
        push edx

	mov eax, dword 0		; zero out eax
        lea ebx, [pa]			; point ebx to pa

        .loop:				; while element isn't '#'
	cmp edx, dword '#'
        je .end

        call read_byte			; read in byte

        mov [ebx], al			; save byte into pa
        mov edx, eax			; move byte into edx for comparison
        inc ebx				; increment ebx and ecx
        inc ecx

        jmp .loop
        .end:

        pop edx				; restore reg values
	pop ecx
        pop ebx

        mov esp, ebp			; restore stack
        pop ebp

        ret				; return

execute_instr:

	push ebp			; save current stack
	mov ebp, esp

	push ebx			; save current reg values
        push ecx
        push edx

	cmp [ebp+8], byte '>'		; if '>'
	jne .case2

	inc dword [dp]			; increment data pointer

	jmp .end

	.case2:
	cmp [ebp+8], byte '<'		; if '<'
	jne .case3

	dec dword [dp]			; decrement data pointer

	jmp .end

	.case3:
	cmp [ebp+8], byte '+'		; if '+'
	jne .case4

	mov ebx, dword [dp]		; increment element at pointer

	inc byte [ma+ebx]

	jmp .end

	.case4:
	cmp [ebp+8], byte '-'		; if '-'
	jne .case5

        mov ebx, dword [dp]		; decrement element at pointer

        dec byte [ma+ebx]

	jmp .end

	.case5:
	cmp [ebp+8], byte '.'		; if '.'
	jne .case6

	mov ebx, [dp]			; write byte
	push dword [ma+ebx] 
	
	call write_byte

	add esp, 4
	xor ebx, ebx

	jmp .end

	.case6:
	cmp [ebp+8], byte ','		; if ','
	jne .case7

	call read_byte			; read byte
	
	mov ebx, [dp]
	mov [ma+ebx], eax

	jmp .end

	.case7:
	cmp [ebp+8], byte '['		; if '['
	jne .case8
	
	inc dword [l]			; save current position in instruction array
	mov ebx, [ip]
	mov ecx, [l]
	mov [lar+ecx*4], ebx
		
	.loop:
	mov ecx, [l]			; Every loop return ip to saved position
	mov ebx, dword [lar+ecx*4]
	mov [ip], ebx

	mov ebx, [dp]			; loop while value in data is not 0
	mov cl, [ma+ebx]
	cmp cl, byte 0
	je .false	

	jmp .end

	.case8:
	cmp [ebp+8], byte ']'		; if ']'
	jne .default

	mov ecx, [l]			; save end position of loop in instruction array
	mov ebx, dword [ip]
	mov [lear+ecx*4], ebx

	jmp .loop

	.false:

	mov ecx, [l]			; return to end position if false
	mov ebx, [lear+ecx*4]
	mov [ip],  ebx

	mov [lar+ecx*4], dword 0
	mov [lear+ecx*4], dword 0
	dec dword [l] 

	jmp .end

	.default:

	.end:

        pop edx
        pop ecx
        pop ebx

	mov esp, ebp
	pop ebp

	ret

