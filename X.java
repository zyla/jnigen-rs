public class X {
    int counter;

    public X(int counter) {
        this.counter = counter;
    }

    public void add(X n) {
        counter += n.counter;
    }

    public X copy() {
        return new X(counter);
    }

    public void print() {
        System.out.println(counter);
    }
}
