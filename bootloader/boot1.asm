[BITS 16]
[ORG 0x7C00]

call PrepHelloWorld
call PrintAll

call PrepKernelPhrase
call PrintAll

call LoadingKernel

jmp $

PrepHelloWorld:
   mov si, FirstPhrase
   ret
PrepKernelPhrase:
    mov si, KernelPrepPhrase
    ret

PrintAll:
    mov ah, 0eh
    mov al, [si]
    print:
        int 10h
        inc si
        mov al, [si]
        cmp al, 0
        jne print
    ret

LoadingKernel:
    mov ah, 02h        ; função 0x02 da BIOS (int 13h) → ler setores do disco
    mov al, 1          ; quantidade de setores a ler (1 setor = 512 bytes)
    mov ch, 0          ; cilindro (track) = 0
    mov cl, 2          ; setor = 2 (setor 1 é o bootloader, então começa no 2
    mov dh, 0          ; head (cabeça) = 0 (primeira cabeça do disco)
    mov dl, 80h        ; drive = 0x80 (primeiro HD) | 0x00 seria disquete
    mov bx, 0800h      ; prepara segmento onde os dados serão carregados
    mov es, bx         ; ES = 0x0800 → segmento de destino na memória
    mov bx, 0000h      ; offset dentro do segmento (ES:BX → 0x0800:0000)
    int 13h            ; chama BIOS → lê o setor e coloca em ES:BX
    ret                ; retorna da função

FirstPhrase db "Iniciando processo de boot....", 0
KernelPrepPhrase db "Carregando Kernel...", 0
times 510 - ($-$$) db 0
dw 0xAA55

