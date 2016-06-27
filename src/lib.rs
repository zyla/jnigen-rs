extern crate jni_sys;
use jni_sys::*;

mod java;
use java::*;

#[allow(non_snake_case)]
#[no_mangle]
pub unsafe fn Java_main_nativeInit(env: *mut JNIEnv) {
    java::native_init(env);
}

#[allow(non_snake_case)]
#[no_mangle]
pub unsafe fn Java_main_main(env: *mut JNIEnv, cls: jclass) {
    real_main(env);
}

unsafe fn real_main(env: *mut JNIEnv) {
    let frame = javax_swing_JFrame::new(env);

    frame.setVisible(1);
}
