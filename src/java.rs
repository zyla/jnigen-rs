extern crate jni_sys; use jni_sys::*; extern crate libc; use self::libc::c_uint;
static mut class_javax_swing_JFrame: jclass = 0 as jclass;
static mut method_javax_swing_JFrame_new : jmethodID = 0 as jmethodID;
static mut method_javax_swing_JFrame_setVisible : jmethodID = 0 as jmethodID;
pub struct javax_swing_JFrame(*mut JNIEnv, jobject);
impl javax_swing_JFrame {
	pub unsafe fn wrap(env: *mut JNIEnv, obj: jobject) -> javax_swing_JFrame {
		javax_swing_JFrame(env, obj)
	}
	pub fn jobject(&self) -> jobject { self.1 }
	pub fn new(env: *mut JNIEnv) -> javax_swing_JFrame {
		unsafe { javax_swing_JFrame(env, ((**env).NewObject)(env, class_javax_swing_JFrame, method_javax_swing_JFrame_new)) }
	}
	pub fn setVisible(&self, p0: jboolean) -> () {
		unsafe { ((**self.0).CallVoidMethod)(self.0, self.1, method_javax_swing_JFrame_setVisible, p0 as c_uint) }
	}
}
pub unsafe fn native_init(env: *mut JNIEnv) {
	class_javax_swing_JFrame = ((**env).NewGlobalRef)(env, ((**env).FindClass)(env, "javax/swing/JFrame\0".as_ptr() as *const i8));
	method_javax_swing_JFrame_new = ((**env).GetMethodID)(env, class_javax_swing_JFrame, "<init>\0".as_ptr() as *const i8, "()V\0".as_ptr() as *const i8);
	method_javax_swing_JFrame_setVisible = ((**env).GetMethodID)(env, class_javax_swing_JFrame, "setVisible\0".as_ptr() as *const i8, "(Z)V\0".as_ptr() as *const i8);
}
