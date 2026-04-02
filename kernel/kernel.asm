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
    call BackgroundColor
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

BackgroundColor:
   mov ah, 06h         ; Função BIOS: scroll up / limpar área da tela
   mov al, 0           ; 0 = limpar completamente (clear screen)
   mov bh, 0001_1111b  ; Atributo de cor (fundo azul + texto branco)
   mov ch, 0           ; Linha inicial (topo)
   mov cl, 0           ; Coluna inicial
   mov dh, 5           ; Linha final (limita área)
   mov dl, 80          ; Coluna final
   int 10h             ; Executa limpeza/coloração da área
ret

MoveCursor:
    mov ah, 02h        ; Função BIOS: mover cursor
    mov bh, [Pagination] ; Página de vídeo
    inc dl             ; Move cursor uma coluna à direita
    int 0x10           ; Aplica posição do cursor
ret

SetLineColumn:
    mov dh, 3
    mov dl, 2
ret

ShowMessage:
    call SetLineColumn ; Define posição inicial do cursor
    call MoveCursor    ; Move cursor para posição definida

    mov si, KernelMessage ; SI aponta para string
    call MakeString    ; Imprime string

    jmp END            ; Loop final (trava execução)

MakeString:
    mov ah, 09h        ; Função BIOS: escrever caractere com atributo
    mov bh, [Pagination] ; Página
    mov bl, 40h        ; Atributo de cor
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