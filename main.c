#include <efi.h>
#include <efilib.h>

/*
 * efi_main - UEFI application entry point
 *
 * Note: Do NOT use EFIAPI attribute here. gnu-efi's crt0 converts from
 * MS x64 ABI to System V AMD64 ABI before calling efi_main.
 * EFIAPI is only for function pointers that call into UEFI firmware.
 */
EFI_STATUS
efi_main(EFI_HANDLE ImageHandle, EFI_SYSTEM_TABLE *SystemTable)
{
    InitializeLib(ImageHandle, SystemTable);
    Print(L"Hello World!\n");
    while (1);
    return EFI_SUCCESS;
}
