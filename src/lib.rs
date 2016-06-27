extern crate jni_sys;
use jni_sys::*;

mod java;
use java::X;

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
    let x = X::new(env, 1);

    x.print(); // 1

    x.add(&X::new(env, 5));

    x.print(); // 6
}
