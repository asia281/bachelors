public class isprime {
    private static volatile boolean isP = true;

    private static class Thr implements Runnable {
        private int n, var;

        public Thr(int n, int var) {
            this.n = n;
            this.var = var;
        }

        @Override
        public void run() {
            while (var < n && isP) {
                if (n % var == 0) {
                    isP = false;
                    break;
                }
                var += 30;
            }
        }
    }

    private static boolean isPrime(int n) {
        int[] firstPrimes = {2, 3, 5, 7, 11, 13, 17, 19, 23, 29};
        for (int i: firstPrimes) {
            if (n <= i) break;
            if (n % i == 0) return false;
        }

        isP = true;

        int[] secondPrimes = { 31, 37, 41, 43, 47, 49, 53, 59};
        for (int i: secondPrimes) {
            Thread t = new Thread(new Thr(n, i));
            t.start();
            try {
                t.join();
            } catch (InterruptedException e) {
                Thread.currentThread().interrupt();
            }
        }
        return isP;
    }

    public static void main(String[] args) {
        int cnt = 0;
        for (int i = 2; i <= 10000; i++) {

            if (isPrime(i)) cnt++;
        }
        System.out.println(cnt);
    }
}
