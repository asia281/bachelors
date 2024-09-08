import java.util.*;

public class Vectors {

    public static volatile int[] resSum;
    public static volatile long[] resDot;

    public static void func(int elem1, int elem2, int idx, boolean type) {
        if (type) {
            resDot[idx / 10] += elem1 * elem2;
            return;
        }
        resSum[idx] = elem1 + elem2;
    }

    public static class split implements Runnable {
        private vector v1, v2;
        private int start;
        private static boolean type;
        public split(vector v1, vector v2, int start, boolean type) {
            this.start = start;
            this.v1 = v1;
            this.v2 = v2;
            this.type = type;
        }
        @Override
        public void run() {
            int cnt = 10;
            while (cnt > 0 && v1.getLen() > start) {
                func(v1.getIthElement(start), v2.getIthElement(start), start, type);
                cnt--;
                start++;
            }
        }
    }

    public static class vector {
        private int[] vars;

        public int getIthElement (int i) {
            return vars[i];
        }

        public int getLen() {
            return vars.length;
        }

        public vector(int[] vars) {
            this.vars = vars;
        }

        public boolean diff(vector v) {
            if (getLen() != v.getLen()) return true;
            for (int i = 0; i < getLen(); i++) {
                if (getIthElement(i) != v.getIthElement(i)) return true;
            }
            return false;
        }

    }

    public static long sumOf(long[] array) {
        long sum = 0;
        for (int i = 0; i < array.length; i++) {
            sum += array[i];
        }
        return sum;
    }

    public static long dotProd(vector v1, vector v2)  {
        resDot = new long[v1.getLen() / 10 + 1];
        Thread[] t = new Thread[v1.getLen() / 10 + 1];
        for (int i = 0; i < v1.getLen(); i += 10) {
            t[i / 10] = new Thread(new split(v1, v2, i, true));
            t[i / 10].start();
        }
        for (int i = 0; i < v1.getLen(); i += 10) {
            try {
                t[i / 10].join();
            } catch (InterruptedException e) {
                Thread.currentThread().interrupt();
            }
        }

        return sumOf(resDot);
    }
    public static vector sum(vector v1, vector v2)  {
        resSum = new int[v1.getLen()];
        Thread[] t = new Thread[v1.getLen() / 10 + 1];
        for (int i = 0; i < v1.getLen(); i += 10) {
            t[i / 10] = new Thread(new split(v1, v2, i, false));
            t[i / 10].start();
        }
        for (int i = 0; i < v1.getLen(); i += 10) {
            try {
                t[i / 10].join();
            } catch (InterruptedException e) {
                Thread.currentThread().interrupt();
            }
        }
        return new vector(resSum);
    }

    private static final Random rand = new Random();

    public static vector getRandomVector(int len) {
        int[] vec = new int[len];
        for (int i = 0; i < len; i++) {
            vec[i] = rand.nextInt(20);
        }
        return new vector(vec);
    }


    public static vector sumSeq(vector v1, vector v2) {
        int[] res = new int[v1.getLen()];
        for (int i = 0; i < v1.getLen(); i++) {
            res[i] = v1.getIthElement(i) + v2.getIthElement(i);
        }
        return new vector(res);
    }

    public static long dotSeq(vector v1, vector v2) {
        long res = 0;
        for (int i = 0; i < v1.getLen(); i++) {
            res += v1.getIthElement(i) * v2.getIthElement(i);
        }
        return res;
    }

    public static void main(String[] args) {
        final int maxn = 40;
        for (int i = 1; i < maxn; i++) {
            vector v1 = getRandomVector(i), v2 = getRandomVector(i);

            if (dotProd(v1, v2) != dotSeq(v1, v2)) {
                System.out.println("Incorrect dot product");
            }
            if (sum(v1, v2).diff(sumSeq(v1, v2))) {
                System.out.println("Incorrect sum");
            }
        }
        System.out.println("Everything is working:)");
    }
}