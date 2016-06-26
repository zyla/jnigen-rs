class main {
    static {
        System.loadLibrary("foo");
        nativeInit();
    }

    public static native void nativeInit();

    public static native void go(X x);

    public static void main(String[] args) {
        go(new X(1));
    }
}
