extern crate jni_sys; use jni_sys::*;
static mut class_X: jclass = 0 as jclass;
static mut method_X_new : jmethodID = 0 as jmethodID;
static mut method_X_add : jmethodID = 0 as jmethodID;
static mut method_X_copy : jmethodID = 0 as jmethodID;
static mut method_X_print : jmethodID = 0 as jmethodID;
pub struct X(*mut JNIEnv, jobject);
impl X {
	pub unsafe fn wrap(env: *mut JNIEnv, obj: jobject) -> X {
		X(env, obj)
	}
	pub fn jobject(&self) -> jobject { self.1 }
	pub fn new(env: *mut JNIEnv, p0: jint) -> X {
		unsafe { X(env, ((**env).NewObject)(env, class_X, method_X_new, p0)) }
	}
	pub fn add(&self, p0: &X) -> () {
		unsafe { ((**self.0).CallVoidMethod)(self.0, self.1, method_X_add, p0.1) }
	}
	pub fn copy(&self) -> X {
		unsafe { X(self.0, ((**self.0).CallObjectMethod)(self.0, self.1, method_X_copy)) }
	}
	pub fn print(&self) -> () {
		unsafe { ((**self.0).CallVoidMethod)(self.0, self.1, method_X_print) }
	}
}
pub unsafe fn native_init(env: *mut JNIEnv) {
	class_X = ((**env).NewGlobalRef)(env, ((**env).FindClass)(env, "X\0".as_ptr() as *const i8));
	method_X_new = ((**env).GetMethodID)(env, class_X, "<init>\0".as_ptr() as *const i8, "(I)V\0".as_ptr() as *const i8);
	method_X_add = ((**env).GetMethodID)(env, class_X, "add\0".as_ptr() as *const i8, "(LX;)V\0".as_ptr() as *const i8);
	method_X_copy = ((**env).GetMethodID)(env, class_X, "copy\0".as_ptr() as *const i8, "()LX;\0".as_ptr() as *const i8);
	method_X_print = ((**env).GetMethodID)(env, class_X, "print\0".as_ptr() as *const i8, "()V\0".as_ptr() as *const i8);
}
