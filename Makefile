INCLUDE_DIRS = -I/usr/include/efi
LIB_DIRS     = -L/usr/lib
LDSCRIPT     = /usr/lib/elf_x86_64_efi.lds
CRT_EFI      = /usr/lib/crt0-efi-x86_64.o

CFLAGS  =  $(INCLUDE_DIRS) -fpic -ffreestanding -fno-stack-protector
CFLAGS += -fno-stack-check -fshort-wchar -mno-red-zone
CFLAGS += -maccumulate-outgoing-args -Wall
LDFLAGS = -shared -Bsymbolic $(LIB_DIRS) -T$(LDSCRIPT) $(CRT_EFI) -lgnuefi -lefi

OVMF = /usr/share/ovmf/OVMF.fd

all: main.efi

%.efi: %.so
	objcopy -j .text -j .sdata -j .data  -j .rodata -j .dynamic -j .dynsym \
		-j .rel  -j .rela  -j .rel.* -j .rela.* -j .reloc \
		--target efi-app-x86_64 --subsystem=10 $< $@

%.o: %.c
	$(CC) $(CFLAGS) -c $<

%.so: %.o
	$(LD) $(LDFLAGS) $< -o $@

qemu: main.efi image/EFI/BOOT/BOOTX64.EFI
	qemu-system-x86_64 -nographic -bios $(OVMF) \
		-drive file=fat:rw:image,media=disk,format=raw

image/EFI/BOOT/BOOTX64.EFI:
	mkdir -p image/EFI/BOOT
	ln -sf ../../../main.efi image/EFI/BOOT/BOOTX64.EFI

clean:
	rm -f main.efi main.so main.o
	rm -rf image
