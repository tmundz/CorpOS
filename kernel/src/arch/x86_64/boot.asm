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




