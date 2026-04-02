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

; START KERNEL---------------------------------------------------------
OSmain:
    ; Configura a stack primeiro (Inline para não quebrar o ret)
    cli                 ; Desativa interrupções durante a troca de stack
    mov ax, 9000h
    mov ss, ax
    mov sp, 0FFFFh
    sti                 ; Reativa interrupções

    call ConfigSegment
    jmp ShowMessage

ConfigSegment:
    mov ax, es         ; Copia o valor do segmento ES para AX
    mov ds, ax         ; Define DS = ES (alinha segmento de dados com ES)
ret                    ; Retorna para quem chamou
; -----------------------------------------------------------------------


MoveCursor:
    mov ah, 02h        ; Função BIOS: mover cursor
    mov bh, [Pagination] ; Página de vídeo
    inc dl             ; Move cursor uma coluna à direita
    int 0x10           ; Aplica posição do cursor
ret


MakeString:
    mov ah, 09h        ; Função BIOS: escrever caractere com atributo
    mov bh, [Pagination] ; Página
    mov bl, 20h        ; Atributo de cor
    mov cx, 1          ; Quantidade de repetições
    mov al, [si]       ; Caractere atual

    print:
        int 10h            ; Imprime caractere com cor
        inc si             ; Avança para próximo caractere
        call MoveCursor    ; Move cursor manualmente
        mov ah, 09h        ; Reconfigura função (BIOS pode alterar AH)
        mov al, [si]       ; Próximo caractere
        cmp al, 0          ; Verifica fim da string (null terminator)
        jne print          ; Se não for fim, continua loop
ret

END:
 jmp $