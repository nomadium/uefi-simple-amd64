# UEFI Application Makefile for Ubuntu 24.04
# Builds an EFI application for amd64 architecture

ARCH            = x86_64
INCLUDE_DIRS    = -I/usr/include/efi -I/usr/include/efi/$(ARCH)
LDSCRIPT        = /usr/lib/elf_$(ARCH)_efi.lds
CRT_EFI         = /usr/lib/crt0-efi-$(ARCH).o
LIBEFI          = /usr/lib/libefi.a
LIBGNUEFI       = /usr/lib/libgnuefi.a

# Compiler flags:
# - HAVE_USE_MS_ABI: Required so UEFI function pointer calls use MS calling convention
# - fno-plt: Prevent PLT stub generation (PLT doesn't work without dynamic linker)
# - fPIC: Position Independent Code required for EFI
# - ffreestanding: Freestanding environment (no standard library)
# - fno-stack-protector/fno-stack-check: No stack canaries (unavailable in EFI)
# - fshort-wchar: UEFI uses 16-bit wchar_t
# - mno-red-zone: Disable red zone (required for interrupt safety)
# - maccumulate-outgoing-args: Required by gnu-efi
CFLAGS   = $(INCLUDE_DIRS)
CFLAGS  += -DHAVE_USE_MS_ABI
CFLAGS  += -fno-plt
CFLAGS  += -fPIC -ffreestanding -fno-stack-protector -fno-stack-check
CFLAGS  += -fshort-wchar -mno-red-zone -maccumulate-outgoing-args
CFLAGS  += -Wall

# Linker flags:
# - nostdlib: No standard library
# - shared: Build as shared object (later converted to PE)
# - Bsymbolic: Bind references to global symbols locally
LDFLAGS  = -nostdlib -shared -Bsymbolic
LDFLAGS += -T$(LDSCRIPT)

OVMF = /usr/share/ovmf/OVMF.fd

all: main.efi

# Convert ELF shared object to PE/COFF EFI application
%.efi: %.so
	objcopy -j .text -j .sdata -j .data -j .rodata \
		-j .dynamic -j .dynsym -j .rel -j .rela -j .reloc \
		--target efi-app-$(ARCH) --subsystem=10 $< $@

%.o: %.c
	$(CC) $(CFLAGS) -c $< -o $@

# Link order matters: crt0 first, then user code, then libraries
%.so: %.o
	$(LD) $(LDFLAGS) $(CRT_EFI) $< $(LIBGNUEFI) $(LIBEFI) -o $@

image/EFI/BOOT/BOOTX64.EFI: main.efi
	mkdir -p image/EFI/BOOT
	cp main.efi image/EFI/BOOT/BOOTX64.EFI

qemu: main.efi image/EFI/BOOT/BOOTX64.EFI
	qemu-system-x86_64 -machine q35 -nographic -bios $(OVMF) \
		-drive file=fat:rw:image,media=disk,format=raw

clean:
	rm -f main.efi main.so main.o
	rm -rf image

.PHONY: all clean qemu
.PRECIOUS: %.so %.o
