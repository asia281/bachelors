import java.util.concurrent.CyclicBarrier;
import java.util.concurrent.Semaphore;
import java.util.function.IntBinaryOperator;

public class Matric {

    private static final int ROWS = 10;
    private static final int COLUMNS = 100;

    public static volatile int[] res;
    private static final Semaphore[] s = new Semaphore[ROWS];

    private static class Matrix {

        private final int rows;
        private final int columns;
        private final CyclicBarrier barrier = new CyclicBarrier(COLUMNS);
        private final IntBinaryOperator definition;
        public Matrix(int rows, int columns, IntBinaryOperator definition) {
            this.rows = rows;
            this.columns = columns;
            this.definition = definition;
        }

        public int getRows() {
            return rows;
        }

        public int getDefinition(int r, int c) {
            return definition.applyAsInt(r, c);
        }

        public int[] rowSums() {
            int[] rowSums = new int[rows];
            for (int row = 0; row < rows; ++row) {
                int sum = 0;
                for (int column = 0; column < columns; ++column) {
                    sum += definition.applyAsInt(row, column);
                }
                rowSums[row] = sum;
            }
            return rowSums;
        }

        public int[] rowSumsConcurrent() {
            for (int i = 0; i < rows; i++) {
                s[i] = new Semaphore(1);
            }
            res = new int[rows];

            Thread[] threads = new Thread[columns];

            for (int i = 0; i < columns; i++) {
                threads[i] = new Thread(new cnt(i, this));
                threads[i].start();
            }

            for (int i = 0; i < columns; i++) {
                try {
                    threads[i].join();
                } catch (InterruptedException e) {
                    e.printStackTrace();
                }
            }

            return res;
        }
    }


    public static class cnt implements Runnable {
        private final int myCol;
        private final Matrix m;
        public cnt(int myCol, Matrix m) {
            this.myCol = myCol;
            this.m = m;
        }

        @Override
        public void run() {
            for (int i = 0; i < m.getRows(); i++) {
                int curr = m.getDefinition(i, myCol);
                try {
                    s[i].acquire();
                } catch (InterruptedException e) {
                    e.printStackTrace();
                }
                res[i] += curr;
                s[i].release();
            }
        }
    }


    public static void main(String[] args) {
        Matrix matrix = new Matrix(ROWS, COLUMNS, (row, column) -> {
            int a = 2 * column + 1;
            return (row + 10) * (a % 4 - 2) * a;
        });

        int[] rowSums = matrix.rowSums(), rs = matrix.rowSumsConcurrent();

        for (int i = 0; i < rowSums.length; i++) {
            System.out.println(i + " -> " + rowSums[i]);
            System.out.println(i + " -> " + rs[i]);
        }
    }

}
