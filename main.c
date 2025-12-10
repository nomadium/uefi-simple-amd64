#include <efi.h>
#include <efilib.h>

/* https://wiki.osdev.org/GNU-EFI#Creating_an_EFI_executable */

EFI_STATUS
EFIAPI
efi_main(EFI_HANDLE ImageHandle, EFI_SYSTEM_TABLE *SystemTable)
{
    InitializeLib(ImageHandle, SystemTable);
    Print(L"Hello World!\n");
    while (1);
    return EFI_SUCCESS;
}
