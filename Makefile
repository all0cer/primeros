all: run

BOOT_SRC = bootloader/boot1.asm
BOOT_BIN = bootloader/bins/boot.bin
BOOT_KERNEL_SRC = kernel/kernel.asm
BOOT_KERNEL_BIN = kernel/bins/kernel.bin
IMG = build/os.img

$(BOOT_BIN): $(BOOT_SRC)
	@echo "Compilando boot1ASM..."
	mkdir -p bootloader/bins
	nasm -f bin $(BOOT_SRC) -o $(BOOT_BIN)

$(BOOT_KERNEL_BIN): $(BOOT_KERNEL_SRC)
	@echo "Compilando kernelASM..."
	mkdir -p kernel/bins
	nasm -f bin $(BOOT_KERNEL_SRC) -o $(BOOT_KERNEL_BIN)

$(IMG): $(BOOT_BIN) $(BOOT_KERNEL_BIN)
	@echo "Criando build com dd..."
	mkdir -p build
	dd if=/dev/zero of=$(IMG) bs=512 count=2880 2> /dev/null
	dd if=$(BOOT_BIN) of=$(IMG) conv=notrunc 2> /dev/null

run: $(IMG)
	qemu-system-i386 -drive format=raw,file=$(IMG)

clean:
	rm -rf bootloader/bins/*.bin build/*.img