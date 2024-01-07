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

stage_1:
  cli               ; disable interrupts
  mov ax, 0         ; setup segments
  mov ds, ax        ; init the data segment
  mov es, ax        ; init the extra segment
  mov ss, ax        ; setup stack
  mov sp, 0x7c00    ; stack grows downwards from 0x7C00
  call enable_a20
  jmp intro

; A20 line represents the 21st bit
; the fast A20 Gate
enable_a20:
  
  in al, 0x92      ; read the status from the system control port
  or al, 0x02      ; set the second bit to 1 to enable A20
  out 0x92, al     ; write the the modified value to back to the port
  sti              ; re-enable interrupts
  ret              ; return 

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
