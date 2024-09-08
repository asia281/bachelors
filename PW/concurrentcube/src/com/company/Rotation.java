package com.company;

import java.util.function.Consumer;


public class Rotation implements Runnable{
    public int side;
    public int rot;
    public int layer;
    private Cube c;

    public Rotation(int side, int rot, int layer, Cube c) {
        this.side = side;
        this.rot = rot;
        this.layer = layer;
        this.c = c;
    }
    public int getSize() { return c.getSize(); }
    public int getSide() { return side; }
    public int getLayer() { return layer; }
    public Cube getCube() { return c; }
    public int getRot() { return rot; }


    public void runSideRotation() throws InterruptedException {
        int s = side, r = rot;
        if (layer == getSize() - 1) {
            s += 2;
            r = (r + 2) % 4;
        }

        if (s == 2) {
            s = 5;
            r = (r + 2) % 4;
        }

        if (r == 1) {
            c.entireSideCW(s);
        }
        else {
            c.entireSideCounter(s);
        }

    }

    private int turned(int i) {
        return getSize() - 1 - i;
    }

    private void rotate0(int i) {
        int[] sides = new int[]{1, 2, 3, 4};
        int[] x = new int[]{layer, layer, layer, layer};
        int[] y = new int[]{i, i, i, i};
        if (rot == 3) {
            sides[1] = 4; sides[3] = 2;
        }
        c.swap(sides, x, y);
    }

    private void rotate1(int i) {
        int[] sides = new int[]{0, 2, 5, 4};
        int[] x = new int[]{i, i, i, turned(i)};
        int[] y = new int[]{layer, layer, layer, turned(layer)};
        if (rot == 1) {
            sides[1] = 4; sides[3] = 2;
            x[1] = x[3]; x[3] = i;
            y[1] = y[3]; y[3] = layer;
        }
        c.swap(sides, x, y);  // TODO
    }

    private void rotate2(int i) {
        int[] sides = new int[]{0, 3, 5, 1};
        int[] x = new int[]{turned(layer), i, layer, turned(i)};
        int[] y = new int[]{i, layer, turned(i), turned(layer)};
        if (rot == 1) {
            sides[1] = 1; sides[3] = 3;
            x[1] = x[3]; x[3] = i;
            y[1] = y[3]; y[3] = layer;
        }
        c.swap(sides, x, y);  // TODO
    }

    public void run() {
        //System.out.println(side + "sl" +layer);
        if (layer == 0 || layer == getSize() - 1) {
            try {
                runSideRotation();
            } catch (InterruptedException e) {
                e.printStackTrace();
            }
        }
        for (int i = 0; i < getSize(); i++) {
            if (side == 0) { // Patrzymy na gore kostki.
                rotate0(i);
            }
            else if (side == 1) { // Patrzymy na lewa sciane.
                rotate1(i);
            }
            else { // I na przod.
                rotate2(i);
            }
        }
        if (c.getOcc() == 0) {
            c.currSide.set(-1);
            c.sideChange.release();
        }
    }
}