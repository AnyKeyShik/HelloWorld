; nasm -f bin -o hello.exe hello.asm
; chmod 755 hello.exe  # For QEMU Samba server.
; ndisasm -b 32 -e 0x114 -o 0x403000 hello.exe

bits 32
imagebase equ 0x400000  
textbase equ imagebase + 0x3000
file_alignment equ 0x200
bits 32
org 0  

_filestart:
_text:

IMAGE_DOS_HEADER:  
	db 'MZ'
	_KERNEL32_str: db 'kernel32', 0  
	times 0xc - ($-$$) db 0

IMAGE_NT_HEADERS:
	Signature: dw 'PE', 0

IMAGE_FILE_HEADER:
	Machine: dw 0x14c  
	NumberOfSections: dw (_headers_end - _sechead) / 40  
	TimeDateStamp: dd 0x00000000
	PointerToSymbolTable: dd 0x00000000
	NumberOfSymbols: dd 0x00000000
	SizeOfOptionalHeader: dw _datadir_end - _opthd  
	Characteristics: dw 0x030f

_opthd:
IMAGE_OPTIONAL_HEADER32:
	Magic: dw 0x10b  
	MajorLinkerVersion: db 0
	MinorLinkerVersion: db 0
	SizeOfCode: dd 0x00000000
	SizeOfInitializedData: dd 0x00000000
	SizeOfUninitializedData: dd 0x00000000
	AddressOfEntryPoint: dd (textbase - imagebase) + (_entry - _text)
	BaseOfCode: dd 0x00000000
	BaseOfData: dd (IMAGE_NT_HEADERS - _filestart)  
	ImageBase: dd imagebase
	SectionAlignment: dd 0x1000  
	
	%if file_alignment == 0 || file_alignment & (file_alignment - 1)
		%fatal Invalid file_alignment, must be a power of 2.
	%endif
	%if file_alignment < 0x200
		%fatal Windows XP needs file_alignment >= 0x200
	%endif
	
	FileAlignment: dd file_alignment  
	MajorOperatingSystemVersion: dw 4
	MinorOperatingSystemVersion: dw 0
	MajorImageVersion: dw 1
	MinorImageVersion: dw 0
	MajorSubsystemVersion: dw 4
	MinorSubsystemVersion: dw 0
	Win32VersionValue: dd 0
	SizeOfImage: dd (textbase - imagebase) + (_eof + bss_size - _text)  
	SizeOfHeaders: dd _headers_end - _filestart  
	CheckSum: dd 0
	Subsystem: dw 3  
	DllCharacteristics: dw 0
	SizeOfStackReserve: dd 0x00100000
	SizeOfStackCommit: dd 0x00001000
	SizeOfHeapReserve: dd 0
	SizeOfHeapCommit: dd 0
	LoaderFlags: dd 0
	NumberOfRvaAndSizes: dd 2

_datadir:
DataDirectory:
IMAGE_DIRECTORY_ENTRY_EXPORT:
	.VirtualAddress: dd 0x00000000
	.Size: dd 0x00000000

IMAGE_DIRECTORY_ENTRY_IMPORT:
	.VirtualAddress: dd (textbase - imagebase) + (_idescs - _text)
	.Size: dd _idata_data_end - _idata

IMAGE_DIRECTORY_ENTRY_RESOURCE:

IMAGE_IMPORT_BY_NAME_GetStdHandle:
	.Hint: dw 0
	.VirtualAddress_AndSize: db 'GetStd'

	%if 0
		IMAGE_DIRECTORY_ENTRY_EXCEPTION:
			.VirtualAddress: dd 0x78787878
			.Size: dd 0x78787878
		IMAGE_DIRECTORY_ENTRY_SECURITY:
			.VirtualAddress: dd 0x78787878
			.Size: dd 0x78787878
		IMAGE_DIRECTORY_ENTRY_BASERELOC:
			.VirtualAddress: dd 0x78787878
			.Size: dd 0x78787878
		IMAGE_DIRECTORY_ENTRY_DEBUG:
			.VirtualAddress: dd 0x78787878
			.Size: dd 0x00000000
		IMAGE_DIRECTORY_ENTRY_ARCHITECTURE:
			.VirtualAddress: dd 0x00000000
			.Size: dd 0x00000000
		IMAGE_DIRECTORY_ENTRY_GLOBALPTR:
			.VirtualAddress: dd 0x00000000
			.Size: dd 0x78787878
		IMAGE_DIRECTORY_ENTRY_TLS:
			.VirtualAddress: dd 0x78787878
			.Size: dd 0x78787878
		IMAGE_DIRECTORY_ENTRY_LOAD_CONFIG:
			.VirtualAddress: dd 0x78787878
			.Size: dd 0x78787878
		IMAGE_DIRECTORY_ENTRY_BOUND_IMPORT:
			.VirtualAddress: dd 0x78787878
			.Size: dd 0x78787878
		IMAGE_DIRECTORY_ENTRY_IAT:
			.VirtualAddress: dd 0x78787878
			.Size: dd 0x78787878
		IMAGE_DIRECTORY_ENTRY_DELAY_IMPORT:
			.VirtualAddress: dd 0x78787878
			.Size: dd 0x78787878
 	Missing:
		IMAGE_DIRECTORY_ENTRY_COM_DESCRIPTOR:
			.VirtualAddress: dd 0x78787878
			.Size: dd 0x78787878
		IMAGE_DIRECTORY_ENTRY_RESERVED:
			.VirtualAddress: dd 0x78787878
			.Size: dd 0x78787878
	%endif
_datadir_end:

_sechead:
IMAGE_SECTION_HEADER__0:
	.Name: db 'Handle', 0, 0  
	.VirtualSize: dd 1  
	.VirtualAddress: dd 0x1000  
	.SizeOfRawData: dd 0
	.PointerToRawData: dd 0
	.PointerToRelocations: dd 0
	.PointerToLineNumbers: dd 0
	.NumberOfRelocations: dw 0
	.NumberOfLineNumbers: dw 0
	.Characteristics: dd 0xc0300040

IMAGE_SECTION_HEADER__1:
	.Name: db 'xxxxxxx', 0  
	.VirtualSize: dd 1  
	.VirtualAddress: dd 0x2000  
	.SizeOfRawData: dd 0
	.PointerToRawData: dd 0
	.PointerToRelocations: dd 0
	.PointerToLineNumbers: dd 0
	.NumberOfRelocations: dw 0
	.NumberOfLineNumbers: dw 0
	.Characteristics: dd 0xc0300040

IMAGE_SECTION_HEADER__2:
	.Name: db 'xxxxxxx', 0  
	.VirtualSize: dd (_eof - _text) + bss_size
	%if (textbase - imagebase) & 0xfff
		%fatal _text doesn't start at page boundary, needed by Windows XP.
	%endif

	%if (textbase - imagebase) <= 0x2000
		%fatal _text doesn't start later than the previous sections, needed by Windows XP.
	%endif
	.VirtualAddress: dd textbase - imagebase
	.SizeOfRawData: dd _eof - _text - 2 * !(_text - _filestart)
	.PointerToRawData: dd _text - _filestart + 2 * !(_text - _filestart)
	.PointerToRelocations: dd 0
	.PointerToLineNumbers: dd 0
	.NumberOfRelocations: dw 0
	.NumberOfLineNumbers: dw 0
	.Characteristics: dd 0xe0300020

_headers_end:

%if (_headers_end - _sechead) % 40 != 0
	%fatal Multiples of IMAGE_SECTION_HEADER needed.
%endif

%if (_headers_end - _sechead) / 40 < 3
	%fatal Windows XP needs at least 3 sections.
%endif


_entry:
push byte -11                
call [textbase + (__imp__GetStdHandle@4 - _text)]

push eax                     
mov ecx, esp
push byte 0                  
push ecx                     
push byte (_msg_end - _msg)  
push textbase + (_msg - _text)  
push eax                     
call [textbase + (__imp__WriteFile@20 - _text)]

push byte 0                  
call [textbase + (__imp__ExitProcess@4 - _text)]


_data:
_msg:
	db 'Hello, World!', 13, 10
_msg_end:

_idata:  
_hintnames:
	dd (textbase - imagebase) + (IMAGE_IMPORT_BY_NAME_ExitProcess - _text)
	dd (textbase - imagebase) + (IMAGE_IMPORT_BY_NAME_GetStdHandle - _text)
	dd (textbase - imagebase) + (IMAGE_IMPORT_BY_NAME_WriteFile - _text)
	dd 0  
_iat:  
	__imp__ExitProcess@4:  dd (textbase - imagebase) + (IMAGE_IMPORT_BY_NAME_ExitProcess - _text)
	__imp__GetStdHandle@4: dd (textbase - imagebase) + (IMAGE_IMPORT_BY_NAME_GetStdHandle - _text)
	__imp__WriteFile@20:   dd (textbase - imagebase) + (IMAGE_IMPORT_BY_NAME_WriteFile - _text)
	dw 0  
IMAGE_IMPORT_BY_NAME_ExitProcess:
	.Hint: dw 0
	.Name: db 'ExitProcess'  
IMAGE_IMPORT_BY_NAME_WriteFile:
	.Hint: dw 0
	.Name: db 'WriteFile'  
	db 0  

_idescs:
	IMAGE_IMPORT_DESCRIPTOR__0:
	.OriginalFirstThunk: dd (textbase - imagebase) + (_hintnames - _text)
	.TimeDateStamp: dd 0
	.ForwarderChain: dd 0
	.Name: dd (textbase - imagebase) + (_KERNEL32_str - _text)
	.FirstThunk: dd (textbase - imagebase) + (_iat - _text)

_idata_data_end:
_eof:

bss_size equ 20  

%if (_text - _filestart) & (file_alignment - 1)
	%fatal _text is not aligned to file_alignment, needed by Windows XP.
%endif
