CC = x86_64-w64-mingw32-gcc
CFLAGS = -shared -nostdlib -mno-red-zone -fno-stack-protector -Wall \
         -e EfiMain
OVMF = /usr/share/ovmf/OVMF.fd

all: main.efi

%.efi: %.dll
	objcopy --target=efi-app-x86_64 $< $@

%.dll: %.c
	$(CC) $(CFLAGS) $< -o $@

qemu: main.efi image/EFI/BOOT/BOOTX64.EFI
	qemu-system-x86_64 -nographic -bios $(OVMF) \
		-drive file=fat:rw:image,media=disk,format=raw

image/EFI/BOOT/BOOTX64.EFI:
	mkdir -p image/EFI/BOOT
	ln -sf ../../../main.efi image/EFI/BOOT/BOOTX64.EFI

clean:
	rm -f main.efi
	rm -rf image
