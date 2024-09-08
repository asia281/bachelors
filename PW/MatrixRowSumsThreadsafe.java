import java.util.concurrent.*;
import java.util.function.IntBinaryOperator;

class MatrixRowsSumsThreadsafe {

    private static final int ROWS = 10;
    private static final int COLUMNS = 100;
    private static final ConcurrentMap<Integer, Integer> sumRows = new ConcurrentHashMap<>();
    private static final ConcurrentMap<Integer, Integer> cntColumns = new ConcurrentHashMap<>();


    private static class Matrix {

        private final int rows;
        private final int columns;
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
                    sum += getDefinition(row, column);
                }
                rowSums[row] = sum;
            }
            return rowSums;
        }

        public void rowSumsConcurrent() {
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
                sumRows.putIfAbsent(i, 0);
                cntColumns.putIfAbsent(i, 0);
                int curr = m.getDefinition(i, myCol);
                sumRows.computeIfPresent(i, (k, v) -> v + curr);
                cntColumns.computeIfPresent(i, (k, v) -> v + 1);

                if (cntColumns.getOrDefault(i, 0).equals(COLUMNS)) {
                    System.out.println("Suma wiersza " + i + ": " + sumRows.get(i));
                    sumRows.remove(i);
                    cntColumns.remove(i);
                }
            }
        }
    }

    public static void main(String[] args) {
        Matrix matrix = new Matrix(ROWS, COLUMNS, (row, column) -> {
            int a = 2 * column + 1;
            return (row + 1) * (a % 4 - 2) * a;
        });

        int[] rowSums = matrix.rowSums();

        for (int i = 0; i < rowSums.length; i++) {
            System.out.println(i + " -> " + rowSums[i]);
        }
        matrix.rowSumsConcurrent();
    }

}