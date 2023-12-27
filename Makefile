



all: ./bin/boot.bin
	rm -rf ./bin/os.bin
	dd if=./bin/boot.bin >> ./bin/os.bin

./bin/boot.bin: ./kernel/src/arch/x86_64/boot.asm
	nasm -f bin ./kernel/src/arch/x86_64/boot.asm -o ./bin/boot.bin

clean:
	rm -rf ./bin/boot.bin
	rm -rf ./bin/kernel.bin
