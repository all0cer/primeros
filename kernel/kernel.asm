[BITS 16]
[ORG 0x0000]


jmp OSmain

; INCLUSIONS --------------------------------------
%INCLUDE "hardware/monitor.lib"


; START KERNEL---------------------------------------------------------
OSmain:
    ; Configura a stack primeiro (Inline para não quebrar o ret)
    cli                 ; Desativa interrupções durante a troca de stack
    mov ax, 9000h
    mov ss, ax
    mov sp, 0FFFFh
    sti                 ; Reativa interrupções

    call ConfigSegment
    call VGA.SetVideoMode
    call DrawBackGround
    call EffectInit
    jmp END
ConfigSegment:
    mov ax, es         ; Copia o valor do segmento ES para AX
    mov ds, ax         ; Define DS = ES (alinha segmento de dados com ES)
ret                    ; Retorna para quem chamou
; -----------------------------------------------------------------------




END:
   mov ah, 00h
   int 16h
   mov ax, 0040h
   mov ds, ax
   mov ax, 1234h
   mov [0072h], ax
   jmp 0FFFFh:0000h