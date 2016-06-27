class main {
    static {
        System.loadLibrary("foo");
        nativeInit();
    }

    public static native void nativeInit();

    public static native void main(String[] args);
}
