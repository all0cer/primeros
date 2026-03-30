[BITS 16]
[ORG 0x0000]

jmp OSmain

BackWidth db 0         ; Variável: largura da tela (em colunas)
BackHeight db 0        ; Variável: altura da tela (em linhas)
Pagination db 0        ; Será usado futuramente!!

OSmain:
    call ConfigSegment
    call ConfigStack
    call TEXT.setVideoMode

; -----------------------------
; Configuração de segmentos
; -----------------------------
ConfigSegment:
    mov ax, es         ; Copia o valor do segmento ES para AX
    mov ds, ax         ; Define DS = ES (alinha segmento de dados com ES)
ret                    ; Retorna para quem chamou

; -----------------------------
; Configuração da stack
; -----------------------------
ConfigStack:
    mov ax, 9000h      ; Define o segmento da stack (0x9000)
    mov ss, ax         ; SS = 0x9000 (segmento da stack)
    mov sp, 0FFFFh      ; SP = 0xFFFF (topo da stack, cresce para baixo)
ret                    ; Retorna

; -----------------------------
; Configuração de vídeo (modo texto)
; -----------------------------
TEXT.setVideoMode:
    mov ah, 00h        ; Função 0 da BIOS de vídeo (int 10h) → setar modo de vídeo
    mov al, 03h        ; Modo 03h = texto 80x25 (modo padrão VGA)
    int 10h            ; Chama BIOS para aplicar o modo de vídeo

    mov BYTE [BackWidth], 80   ; Armazena largura da tela (80 colunas)
    mov BYTE [BackHeight], 25  ; Armazena altura da tela (25 linhas)
ret                    ; Retorna
