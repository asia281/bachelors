package com.company;

import java.sql.SQLSyntaxErrorException;

public class SideRotation implements Runnable {
    private int side;
    private int rot;
    private int curr;
    private Cube c;

    public SideRotation(int side, int curr, int rot, Cube c) {
        super();
        this.side = side;
        this.curr = curr;
        this.rot = rot;
        this.c = c;
    }

    public int getSize() {
        return c.getSize();
    }

    @Override
    public void run() {
        for (int i = curr; i <= (getSize() - curr) / 2; i++) {
            int[] y = new int[]{curr, getSize() - 1 - i, getSize() - 1 - curr, i};
            int[] x = new int[]{i, getSize() - 1 - curr,  getSize() - 1 - i, curr};
            c.swap(side, x, y);
            if (rot == 1) {

                c.swap(side, x, y);
                c.swap(side, x, y);
               /* int currX = x[1];
                x[1] = x[3];
                x[3] = currX;
                int currY = y[1];
                y[1] = y[3];
                y[3] = currY;*/

            }
        }
    }
}