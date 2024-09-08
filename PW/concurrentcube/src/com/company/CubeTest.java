package com.company;

import org.junit.jupiter.api.Test;

import java.util.*;
import java.util.concurrent.BlockingQueue;
import java.util.concurrent.atomic.AtomicBoolean;
import java.util.function.Consumer;

import static org.junit.jupiter.api.Assertions.assertEquals;


public class CubeTest {
    private Cube c;

    public class test {
        private int n;
        private int[] layer;
        private int[] side;
        test(int n, int[] side, int[] layer) {
            this.n = n;
            this.layer = layer;
            this.side = side;
        }
        int getN() {
            return n;
        }
        int getSize() {
            return layer.length;
        }
        int getLayer(int i) {
            return layer[i];
        }
        int getSide(int i) {
            return side[i];
        }
    }


    private static void testThreads(int timeoutMs, Consumer<List<Thread>> testBody) {
        List<Thread> threads = new ArrayList<>();
        AtomicBoolean ok = new AtomicBoolean(true);

        testBody.accept(threads);

        for (Thread t : threads) {
            t.setUncaughtExceptionHandler((thread, exception) -> {
                ok.set(false);
                exception.printStackTrace();
            });
        }

        for (Thread t : threads) {
            t.start();
        }

        try {
            Thread.sleep(timeoutMs);
        } catch (InterruptedException e) {
            e.printStackTrace();
        }

        for (Thread t : threads) {
            if (t.isAlive()) {
                ok.set(false);
            }
        }

        for (Thread t : threads) {
            try {
                t.interrupt();
                t.join();
            } catch (InterruptedException e) {
                e.printStackTrace();
            }
        }

        if (ok.get()) {
            System.out.println("OK");
        } else {
            System.out.println("FAIL");
        }

    }


    @Test
   /* public void testDivide(test t) {
        int size = t.getN();
        var counter = new Object() { int[][] value = new int[size][size]; };
        var counterShow = new Object() { int value = 0; };

        Cube c = new Cube(size,
                (x, y) -> { ++counter.value[x][y]; },
                (x, y) -> { ++counter.value[x][y]; },
                () -> { ++counterShow.value; },
                () -> { ++counterShow.value; }
        );
        String start = "";
        String end = "";
        try {
            start = c.show();
        } catch (InterruptedException e) {
            e.printStackTrace();
        }

        testThreads(50, threads -> {
            for (int i = 0; i < t.getSize(); i++) {
                threads.add(new Thread(() -> {
                    try {
                        for (int j = 0; j < 2; j++) {
                            c.rotate(t.getSide(k), t.getLayer(i));
                        }
                    } catch (InterruptedException e) {
                        throw new RuntimeException(e);
                    }
                }));
            }
        });

        try {
            end = c.show();
        } catch (InterruptedException e) {
            e.printStackTrace();
        }
        assertEquals(start, end);
    }*/

    public void calosc(test t) throws InterruptedException {
        var counter = new Object() { int[][] value = new int[t.getN()][t.getN()]; };
        var counterShow = new Object() { int value = 0; };

        c = new Cube(t.getN(),
                (x, y) -> { ++counter.value[x][y]; },
                (x, y) -> { ++counter.value[x][y]; },
                () -> { ++counterShow.value; },
                () -> { ++counterShow.value; }
        );
        String start = c.show();
        for (int j = 0; j < t.getSize(); j++){

            for (int i = 0; i < 4; i++) {
                c.rotate(t.getSide(j), t.getLayer(j));
            }
        }
        String end = c.show();
        assertEquals(start, end);
    }
    public void caloscConcurrent(test t) throws InterruptedException {
        var counter = new Object() { int[][] value = new int[t.getN()][t.getN()]; };
        var counterShow = new Object() { int value = 0; };

        c = new Cube(t.getN(),
                (x, y) -> { ++counter.value[x][y]; },
                (x, y) -> { ++counter.value[x][y]; },
                () -> { ++counterShow.value; },
                () -> { ++counterShow.value; }
        );
        String start = c.show();
        testThreads(50, threads -> {

                    for (int j: t) {
                        threads.add(new Thread(() -> {
                            try {
                                for (int i = 0; i < 4; i++) {
                                    c.rotate(t.getSide(j), t.getLayer(j));
                                }
                            } catch (InterruptedException e) {
                                throw new RuntimeException(e);
                            }
                        }));
                    }
                });
        String end = c.show();
        assertEquals(start, end);
    }

    @Test
    void rotateUpperLayer() throws InterruptedException {
        Cube cube1 = new Cube(3, (x, y) -> {}, (x, y) -> {}, () -> {}, () -> {} );
        cube1.rotate(0, 0);
        assertEquals(cube1.show(), "000000000222111111333222222444333333111444444555555555");
    }

    @Test
    void rotateLeftLayer() throws InterruptedException {
        Cube cube1 = new Cube(3, (x, y) -> {}, (x, y) -> {}, () -> {}, () -> {} );
        cube1.rotate(1, 0);
        assertEquals(cube1.show(), "400400400111111111022022022333333333445445445255255255");
    }

    @Test
    void rotateFrontLayer() throws InterruptedException {
        Cube cube1 = new Cube(3, (x, y) -> {}, (x, y) -> {}, () -> {}, () -> {} );
        cube1.rotate(2, 0);
        assertEquals(cube1.show(), "000000111115115115222222222033033033444444444333555555");
    }

    @Test
    void rotateRightLayer() throws InterruptedException {
        Cube cube1 = new Cube(3, (x, y) -> {}, (x, y) -> {}, () -> {}, () -> {} );
        cube1.rotate(3, 0);
        assertEquals(cube1.show(), "002002002111111111225225225333333333044044044554554554");
    }

    @Test
    void rotateBackLayer() throws InterruptedException {
        Cube cube1 = new Cube(3, (x, y) -> {}, (x, y) -> {}, () -> {}, () -> {} );
        cube1.rotate(4, 0);
        assertEquals(cube1.show(), "333000000011011011222222222335335335444444444555555111");
    }

    @Test
    void rotateBottomLayer() throws InterruptedException {
        Cube cube1 = new Cube(3, (x, y) -> {}, (x, y) -> {}, () -> {}, () -> {} );
        cube1.rotate(5, 0);
        assertEquals(cube1.show(), "000000000111111444222222111333333222444444333555555555");
    }

    @Test
    void bigRotateTest() throws InterruptedException {
        StringBuilder expected = new StringBuilder();
        for(int j = 0; j < 6; j++) {
            for(int i = 0; i < 20 * 20; i++) {
                expected.append(j);
            }
        }
        var counter = new Object() { int value = 0; };
        var counterShow = new Object() { int value = 0; };

        Cube cube1 = new Cube(20,
                (x, y) -> { ++counter.value; },
                (x, y) -> { ++counter.value; },
                () -> { ++counterShow.value; },
                () -> { ++counterShow.value; }
        );
        Cube cube2 = new Cube(3,
                (x, y) -> { ++counter.value; },
                (x, y) -> { ++counter.value; },
                () -> { ++counterShow.value; },
                () -> { ++counterShow.value; }
        );
        Queue<Rotation> q = new LinkedList<>();
        for(int j = 0; j < 166; j++) {
           // System.out.println("nana");
            for (int i = 0; i < 6; i++) {
                cube1.rotate(3, 0);
                cube1.rotate(0, 0);
                cube1.rotate(1, 19);
                cube1.rotate(5, 19);
            }
        }
        assertEquals(cube1.show(), expected.toString());
    }

    private static void assertThat(boolean predicate) {
        if (!predicate) {
            throw new AssertionError();
        }
    }

    @Test
    public void testQueue() {
        int size = 10;
        var counter = new Object() { int[][] value = new int[size][size]; };
        var counterShow = new Object() { int value = 0; };

        Cube c = new Cube(size,
                (x, y) -> { ++counter.value[x][y]; },
                (x, y) -> { ++counter.value[x][y]; },
                () -> { ++counterShow.value; },
                () -> { ++counterShow.value; }
        );
        String start = "";
        String end = "";
        try {
            start = c.show();
        } catch (InterruptedException e) {
            e.printStackTrace();
        }

        testThreads(50, threads -> {
            threads.add(new Thread(() -> {
                try {
                    for (int i = 0; i < 2; i++) {
                        c.rotate(1, 5);
                    }
                } catch (InterruptedException e) {
                    throw new RuntimeException(e);
                }
            }));

            threads.add(new Thread(() -> {
                try {
                    for (int i = 0; i < 4; i++) {
                        c.rotate(3, 4);
                    }
                } catch (InterruptedException e) {
                    throw new RuntimeException(e);
                }
            }));

            threads.add(new Thread(() -> {
                try {
                    for (int i = 0; i < 4; i++) {
                        c.rotate(1, 5);
                    }
                } catch (InterruptedException e) {
                    throw new RuntimeException(e);
                }
            }));
            threads.add(new Thread(() -> {
                try {
                    for (int i = 0; i < 2; i++) {
                        c.rotate(3, 4);
                    }
                } catch (InterruptedException e) {
                    throw new RuntimeException(e);
                }
            }));
        });

        try {
            end = c.show();
        } catch (InterruptedException e) {
            e.printStackTrace();
        }
        assertEquals(start, end);
    }



    @Test
    public void testCalosc() throws InterruptedException {
        calosc(new test(4, new int[]{1, 3}, new int[]{2, 1}));
        calosc(new test(8, new int[]{1, 1, 3, 1, 3}, new int[]{4, 3, 3, 4, 4}));
        calosc(new test(5, new int[]{0}, new int[]{0}));
        calosc(new test(6, new int[]{4}, new int[]{5}));
        calosc(new test(21, new int[]{3}, new int[]{20}));
        calosc(new test(6, new int[]{2}, new int[]{1}));

        final int cons = 1000;
        int[] s2 = new int[cons];
        int[] l2 = new int[cons];
        Random r = new Random();
        for (int i = 0; i < 1000; i++) {
            s2[i] = r.nextInt(5);
            l2[i] = r.nextInt(cons - 1);
        }
        calosc(new test(cons, s2, l2));
    }

}