package com.company;

public class RotationData {
    private final int rot;
    private final int layer;
    private final int side;

    public RotationData(int rot, int layer, int side) {
        this.rot = rot;
        this.layer = layer;
        this.side = side;
    }

    public int getSide() {
        return side;
    }
    public int getLayer() {
        return layer;
    }
    public int getRot() {
        return rot;
    }
}
