[BITS 16]
[ORG 0x0000]

mov ah, 0x0E
        mov al, 'P'
        int 0x10

jmp OSmain

BackWidth db 0         ; Variável: largura da tela (em colunas)
BackHeight db 0        ; Variável: altura da tela (em linhas)
Pagination db 0        ; Será usado futuramente!!
KernelMessage db "Kernel em execucao", 0

OSmain:
    ; Configura a stack primeiro (Inline para não quebrar o ret)
    cli                 ; Desativa interrupções durante a troca de stack
    mov ax, 9000h
    mov ss, ax
    mov sp, 0FFFFh
    sti                 ; Reativa interrupções

    call ConfigSegment

    call textsetVideoMode

    jmp ShowMessage


; -----------------------------
; Configuração de segmentos
; -----------------------------
ConfigSegment:
    mov ax, es         ; Copia o valor do segmento ES para AX
    mov ds, ax         ; Define DS = ES (alinha segmento de dados com ES)
ret                    ; Retorna para quem chamou

; -----------------------------
; Configuração de vídeo (modo texto)
; -----------------------------
textsetVideoMode:

    mov ah, 00h        ; Função 0 da BIOS de vídeo (int 10h) → setar modo de vídeo
    mov al, 03h        ; Modo 03h = texto 80x25 (modo padrão VGA)
    int 10h            ; Chama BIOS para aplicar o modo de vídeo

    mov BYTE [BackWidth], 80   ; Armazena largura da tela (80 colunas)
    mov BYTE [BackHeight], 25  ; Armazena altura da tela (25 linhas)
ret                    ; Retorna

MoveCursor:
    mov ah, 02h
    mov bh, [Pagination]
    inc dl
    int 10h
ret

SetLineColumn:
    mov dh, 3
    mov dl, 2
ret

ShowMessage:
    mov ah, 0x0E
        mov al, 'H'
        int 0x10
    call SetLineColumn
    call MoveCursor
    mov si, KernelMessage
    call MakeString
    jmp END

MakeString:
    mov ah, 09h
    mov bh, [Pagination]
    mov bl, 40h
    mov cx, 1
    mov al, [si]
    print:
        int 10h
        inc si
        call MoveCursor
        mov ah, 09h
        mov al, [si]
        cmp al, 0
        jne print
ret

END:
 jmp $