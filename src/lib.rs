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
pub unsafe fn Java_main_go(env: *mut JNIEnv, cls: jclass, x_: jobject) {
    let x = X::wrap(env, x_);

    x.print(); // 1

    x.add(&x);

    x.print(); // 2

    let y = x.copy();

    x.add(&y);
    x.print(); // 4
    y.print(); // 2
}
