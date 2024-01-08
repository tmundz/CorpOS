; BASIC STEPS FOR BOOTLOADER
; setup 16 bit seg and stack reg
; check for PCI CPUID MSRs
; enable A20
; load GDTR
; inform BIOS of target processor
; get memory map from BIOS
; locate kernel in filesystem
; enable long mode for 64 bit

ORG 0x7c00
BITS 16
CODE_SEG equ 0x08
DATA_SEG equ 0x10
stage_1:
  cli               ; disable interrupts
  mov ax, 0         ; setup segments
  mov ds, ax        ; init the data segment
  mov es, ax        ; init the extra segment
  mov ss, ax        ; setup stack
  mov sp, 0x7c00    ; stack grows downwards from 0x7C00
  call enable_a20

; A20 line represents the 21st bit
; the fast A20 Gate
enable_a20:
  
  in al, 0x92      ; read the status from the system control port
  or al, 0x02      ; set the second bit to 1 to enable A20
  out 0x92, al     ; write the the modified value to back to the port
  ret              ; return 


gdt_start:
  gdt_null:
  dd 0x0
  dd 0x0

  ; Code segment descriptor
  dw 0xFFFF
  dw 0x0           ; base
  db 0x0           ; Base (16-23)
  db 10011010b     ; Access byte
  db 11001111b     ; limit (bits 16-19)
  db 0x02          ; Base (bits 24-31)

  ; Data segment descriptor
  dw 0xFFFF
  dw 0x0
  dw 0x0
  db 10010010b     ; access byte: 1 present
  db 11001111b
  db 0x0

gdt_end:

gdt_descriptor:
  dw gdt_end - gdt_start - 1    ; size of the GDT 
  dw gdt_start                  ; Address of the GDT


load32:
  lgdt[gdt_descriptor]          ; Load the GDT
  mov eax, cr0                  ; load cr0 register into EAX
  or eax , 0x1                  ; set the PE bit enable protection
  mov cr0, eax                  ; Write back to cr0
  sti
  jmp 08h:init_32

[bits 32]
init_32:
  mov ax, DATA_SEG
  mov ds, ax
  mov ss, ax
  mov es, ax
  mov fs, ax 
  mov gs, ax

; entering Long Mode
enable_long:
  ; enable PAE
  mov eax, cr4
  or eax, 0x20      ; set the 5th bit aka PAE bit
  mov cr4, eax

  ; enable paging
  PML4_ADDR equ 0x1000
  PDPT_ADDR equ 0x2000
  PDT_ADDR equ 0x3000

  mov eax, PDPT_ADDR | 0x3
  mov dword [PML4_ADDR], eax

  mov eax, PDT_ADDR | 0x3
  mov dword [PDPT_ADDR], eax

  mov eax, 0x183
  mov dword [PDT_ADDR], eax

  mov eax, PML4_ADDR
  mov cr3, eax

  ; enable long mode
  mov ecx, 0xc0000080       ; EFER MSR number
  rdmsr                     ; read MSR into EDX:EAX
  or eax, 0x1000             ; set LME
  wrmsr                     ; Write back to msr
  
  ; Enable paging
  mov eax, cr0
  or eax, 0x80000000        ; set PG paging bit to enable paging
  mov cr0, eax

  jmp 0x08:start64


start64:
  mov ax, 0x10
  mov ds, ax
  mov ss, ax
  mov es, ax
  mov fs, ax
  mov gs, ax

  mov rsp, 0x7C00   ; Point RSP to a known location

  ;extern kernel_main
  ;call kernel_main
  hlt

intro:
  mov si, hipp
  call print_string

  print_string:
    lodsb           ; get byte from SI
    or al, al       ; logical od al by itself
    jz .done        ; if the result is 0 jump to done
    mov ah, 0x0E    ; move 0x0E into ah
    int 0x10        ; otherwise, print out the char
    jmp print_string; jump to the top of the function
    .done:
      ret


hipp db 'This is HippOS!!', 0x0D, 0x0A, 0


times 510-($-$$) db 0
dw 0AA55h ; bios sig 
