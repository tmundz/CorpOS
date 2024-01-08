
# Define directories and files
ASM_SRC := ./kernel/src/arch/x86_64/boot.asm
ASM_BIN := ./bin/boot.bin
RUST_TARGET := x86_64-hippos.json
RUST_BIN := ./kernel/target/x86_64-hippos/debug/kernel
FINAL_BIN := ./bin/os.bin

# Default target
all: $(ASM_BIN) $(RUST_BIN)
	cat $(ASM_BIN) $(RUST_BIN) > $(FINAL_BIN)
	dd if=/dev/zero bs=512 count=100 >> $(FINAL_BIN)

# Compile assembly file into a flat binary
$(ASM_BIN): $(ASM_SRC)
	mkdir -p ./bin
	nasm -f bin $(ASM_SRC) -o $(ASM_BIN)

# Build the Rust kernel
$(RUST_BIN):
	cd ./kernel && cargo build -Z build-std=core --target $(RUST_TARGET)

# Clean build artifacts
clean:
	rm -rf ./bin/*
	cd ./kernel && cargo clean

.PHONY: all clean

