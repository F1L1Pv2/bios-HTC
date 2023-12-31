ASM=nasm
SRC_DIR=src
BUILD_DIR=build

.PHONY: all bios-htc kernel bootloader clean always iso


iso: $(BUILD_DIR)/bios-htc.iso

$(BUILD_DIR)/bios-htc.iso: bios-htc
	genisoimage -quiet -V 'HTC' -input-charset iso8859-1 -o $(BUILD_DIR)/bios-htc.iso -b bios-htc.img     -hide bios-htc.img $(BUILD_DIR)

bios-htc: $(BUILD_DIR)/bios-htc.img

$(BUILD_DIR)/bios-htc.img: bootloader kernel
	dd if=/dev/zero of=$(BUILD_DIR)/bios-htc.img bs=512 count=2880
	mkfs.fat -F 12 -n "NBOS" $(BUILD_DIR)/bios-htc.img
	dd if=$(BUILD_DIR)/bootloader.bin of=$(BUILD_DIR)/bios-htc.img conv=notrunc
	mcopy -i $(BUILD_DIR)/bios-htc.img $(BUILD_DIR)/kernel.bin "::kernel.bin"

bootloader: $(BUILD_DIR)/bootloader.bin

$(BUILD_DIR)/bootloader.bin: always
	$(ASM) $(SRC_DIR)/bootloader/boot.asm -f bin -o $(BUILD_DIR)/bootloader.bin 

kernel: $(BUILD_DIR)/kernel.bin

$(BUILD_DIR)/kernel.bin: always
	$(ASM) $(SRC_DIR)/kernel/main.asm -f bin -o $(BUILD_DIR)/kernel.bin -I $(SRC_DIR)/kernel

always:
	mkdir -p $(BUILD_DIR)

clean:
	rm -rf $(BUILD_DIR)/*