package com.company;
import java.util.*;
import java.util.concurrent.*;
import java.util.concurrent.atomic.AtomicBoolean;
import java.util.concurrent.atomic.AtomicInteger;
import java.util.function.BiConsumer;



public class Cube {
    private final int SIDES = 6;
    private final int size;
    public int[][][] colors;
    public AtomicInteger currSide;
    private ConcurrentHashMap<Integer, Integer> rotations;
    private BiConsumer<Integer, Integer> beforeRotation;
    private BiConsumer<Integer, Integer> afterRotation;
    private Runnable beforeShowing;
    private Runnable afterShowing;
    private BlockingQueue<Rotation> q;
    private Semaphore s;
    private AtomicInteger waitTilShow;
    private AtomicInteger occ;
    private AtomicBoolean isRunning;
    private Semaphore OCHRONA;
    private CompletableFuture<Void>[] threads;
    public Semaphore sideChange;
    private CompletableFuture<Void> barman;

    public Cube(int size,
                BiConsumer<Integer, Integer> beforeRotation,
                BiConsumer<Integer, Integer> afterRotation,
                Runnable beforeShowing,
                Runnable afterShowing) {
        this.sideChange = new Semaphore(0);
        this.threads = new CompletableFuture[size];
        this.barman = CompletableFuture.supplyAsync(() -> {return null;});
        for (int i = 0; i < size; i++) {
            this.threads[i] = CompletableFuture.supplyAsync(() -> {return null;});
        }
        this.OCHRONA = new Semaphore(1);
        this.isRunning = new AtomicBoolean(false);
        this.occ = new AtomicInteger(0);
        this.waitTilShow = new AtomicInteger(0);
        this.s = new Semaphore(0);
        this.q = new LinkedBlockingQueue<>();
        this.beforeRotation = beforeRotation;
        this.afterRotation = afterRotation;
        this.beforeShowing = beforeShowing;
        this.afterShowing = afterShowing;
        this.colors = new int[SIDES][size][size];
        this.rotations = new ConcurrentHashMap<>();
        for (int i = 0; i < SIDES; i++) {
            for (int s1 = 0; s1 < size; s1++) {
                for (int s2 = 0; s2 < size; s2++) {
                    this.colors[i][s1][s2] = i;
                }
            }
        }
        this.currSide = new AtomicInteger(-1);
        this.size = size;
    }

    public void entireSideCW(int i) {
        this.colors[i] = rotateCW(this.colors[i]);
    }

    public void entireSideCounter(int i) {
        this.colors[i] = rotateCW(this.colors[i]);
        this.colors[i] = rotateCW(this.colors[i]);
        this.colors[i] = rotateCW(this.colors[i]);
    }

    static int[][] rotateCW(int[][] mat) {
        final int M = mat.length;
        final int N = mat[0].length;
        int[][] ret = new int[N][M];
        for (int r = 0; r < M; r++) {
            for (int c = 0; c < N; c++) {
                ret[c][M-1-r] = mat[r][c];
            }
        }
        return ret;
    }



    public int getOcc() {
        return occ.decrementAndGet();
    }

    public int getSize() {
        return size;
    }

    public int getVal(int side, int i, int j) {
        return colors[side][i][j];
    }

    public void swap (int[] sides, int[] x, int[] y) {
        int curr = getVal(sides[0], x[0], y[0]);
        for (int i = 0; i < sides.length - 1; i++) {
            colors[sides[i]][x[i]][y[i]] = getVal(sides[i+1], x[i+1], y[i+1]);
        }
        colors[sides[sides.length-1]][x[x.length-1]][y[y.length-1]] = curr;
    }

    public void swap (int side, int[] x, int[] y) {
        int curr = getVal(side, x[0], y[0]);
        for (int i = 0; i < x.length - 1; i++) {
            colors[side][x[i]][y[i]] = getVal(side, x[i+1], y[i+1]);

        }
        colors[side][x[x.length-1]][y[y.length-1]] = curr;
    }

    public void rotate(int side, int layer) throws InterruptedException {   // od 0 do size-1
        beforeRotation.accept(side, layer);
        int rot;
        if (side > 2) {
            side -= 2;
            rot = 3;
            layer = size - layer - 1;
        }
        else {
            rot = 1;
        }
        if (side == 3) side = 0;
        OCHRONA.acquire();
        q.add(new Rotation(side, rot, layer, this));

        barman.thenAccept(r -> {
            try {
                rotateConcurrent();
            } catch (InterruptedException e) {
                e.printStackTrace();
            }
        });
        OCHRONA.release();
        afterRotation.accept(side, layer);
    }

    public void rotateConcurrent() throws InterruptedException {
        while (!q.isEmpty()) {
            Rotation curr = q.take();
            if (currSide.intValue() != -1 && currSide.intValue() != curr.getSide() ) {
                sideChange.acquire();
            }
            currSide.set(curr.getSide());
            occ.incrementAndGet();
           // System.out.println(curr.getSide() + "nana " + curr.getLayer());
            threads[curr.getLayer()].thenRun(curr);
        }
    }

    public String show() throws InterruptedException {
        OCHRONA.acquire();
        barman.thenAccept(r -> {
            try {
                rotateConcurrent();
            } catch (InterruptedException e) {
                e.printStackTrace();
            }
        });
        beforeShowing.run();
        StringBuilder res = new StringBuilder();
        try {
            barman.get();
        } catch (ExecutionException e) {
            e.printStackTrace();
        }
        for (int i = 0; i < size; i++) {
            try {
                threads[i].get();
            } catch (ExecutionException e) {
                e.printStackTrace();
            }
        }
        for (int s = 0; s < SIDES; s++) {
            for (int i = 0; i < size; i++) {
                for (int j = 0; j < size; j++) {
                    res.append(getVal(s, i, j));
                }
            }
        }
        while (waitTilShow.intValue() > 0) {
            waitTilShow.getAndDecrement();
            s.release();
        }
        afterShowing.run();
        OCHRONA.release();
        return res.toString();
    }


    public String rotateSeq(int size, Queue<Rotation> q) throws InterruptedException {
        String s = "";
        while (!q.isEmpty()) {
            Rotation r = q.remove();
            if (r.side > 2) {
                r.side -= 2;
                r.rot = 3;
                r.layer = size - r.layer - 1;
            }
            else {
                r.rot = 1;
            }
            if (r.side == 3) r.side = 0;
            System.out.println(r.getSide() + " " + r.getLayer() + " " + r.getRot());
            r.run();
            System.out.println(r.getCube().show());
            if (q.size() == 1) {
                s = r.getCube().show();
            }
        }
        return s;
    }

}
