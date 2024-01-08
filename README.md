# HippOS

## 64Bit OS for x86_64

## Notes

Will end up making grub2 config but for now write a basic bootloader

# Build Instructions

`rustup default nightly`
`rustup target add x86_64-hippos`
`rustup component add rust-src --toolchain nightly-x86_64-unknown-linux-gnu`
`cargo build -Z build-std=core --target x86_64-hippos.json`

## Future Plans

- risc-V version
- networking
