nasm -f bin boot1.asm -o boot.bin
dd if=/dev/zero of=os.img bs=512 count=2880
dd if=boot1.bin of=os.img conv=notrunc
qemu-system-i386 -fda os.img