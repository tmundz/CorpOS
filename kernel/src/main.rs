#![no_std]
#![no_main]

use core::panic::PanicInfo;

fn panic(_info: &PanicInfo) -> ! {
    loop {}
}

#[no_mangle]
pub extern "C" fn kernel_main() -> ! {
    loop {}
}
