/* eslint-disable prefer-arrow-callback */
/* eslint-disable func-names */

import assert from "assert";
// eslint-disable-next-line
import { describe, it, beforeEach } from "mocha";

import { Sequelize } from "sequelize";

import defineModels from "../src/models.mjs";
import { stopoverCmp, stopoverPossible } from "../src/utils.mjs";

const sequelize = new Sequelize("sqlite::memory");
const { Planet, Spaceship, Stopover } = defineModels(sequelize);

describe("stopoverCmp", function () {
  beforeEach(function () {
    this.currentTest.planet1 = Planet.build({
      name: "PL1",
      imageUrl: "URL",
      docksA: 1,
      docksB: 2,
      docksC: 3,
    });
    this.currentTest.ship1 = Spaceship.build({
      name: "SPS1",
      class: "A",
    });

    this.currentTest.so1 = Stopover.build({
      SpaceshipName: this.currentTest.ship1.name,
      PlanetName: this.currentTest.planet1.name,
      from: 1500,
      till: 2900,
    });
  });

  it("should compare properly", function () {
    const so2 = Stopover.build({
      SpaceshipName: this.test.ship1.name,
      PlanetName: this.test.planet1.name,
      from: 1600,
      till: 2700,
    });

    assert(stopoverCmp(this.test.so1, so2) < 0);
    assert(stopoverCmp(so2, this.test.so1) > 0);
    assert(stopoverCmp(so2, so2) === 0);
  });

  it("should work fine when equal on from", function () {
    const so2 = Stopover.build({
      SpaceshipName: this.test.ship1.name,
      PlanetName: this.test.planet1.name,
      from: 1500,
      till: 2800,
    });

    assert(stopoverCmp(this.test.so1, so2) > 0);
  });
});

describe("stopoverPossible", function () {
  beforeEach(function () {
    this.currentTest.planet1 = Planet.build({
      name: "PL1",
      imageUrl: "URL",
      docksA: 1,
      docksB: 2,
      docksC: 3,
    });
    this.currentTest.ship1 = Spaceship.build({
      name: "SPS1",
      class: "A",
    });
    this.currentTest.so1 = Stopover.build({
      SpaceshipName: this.currentTest.ship1.name,
      PlanetName: this.currentTest.planet1.name,
      from: 1500,
      till: 2900,
    });
  });

  it("should say ok for empty lists", function () {
    assert(
      stopoverPossible(
        this.test.so1,
        [],
        [],
        this.test.ship1,
        this.test.planet1
      ) === true
    );
  });

  it("should say no for planet with no docks", function () {
    this.test.planet1.docksA = 0;
    assert(
      stopoverPossible(
        this.test.so1,
        [],
        [],
        this.test.ship1,
        this.test.planet1
      ) === false
    );
  });

  it("should say ok for dock's full before and after", function () {
    const so2 = Stopover.build({
      SpaceshipName: this.test.ship1.name,
      PlanetName: this.test.planet1.name,
      from: 1,
      till: 1499,
    });
    const so3 = Stopover.build({
      SpaceshipName: this.test.ship1.name,
      PlanetName: this.test.planet1.name,
      from: 2901,
      till: 3500,
    });
    assert(
      stopoverPossible(
        this.test.so1,
        [],
        [so3, so2],
        this.test.ship1,
        this.test.planet1
      ) === true
    );
  });

  it("should say no when there is no space in dock", function () {
    const so2 = Stopover.build({
      SpaceshipName: this.test.ship1.name,
      PlanetName: this.test.planet1.name,
      from: 1,
      till: 1501,
    });
    const so3 = Stopover.build({
      SpaceshipName: this.test.ship1.name,
      PlanetName: this.test.planet1.name,
      from: 1600,
      till: 1800,
    });
    const so4 = Stopover.build({
      SpaceshipName: this.test.ship1.name,
      PlanetName: this.test.planet1.name,
      from: 2899,
      till: 3000,
    });

    assert(
      stopoverPossible(
        this.test.so1,
        [],
        [so2],
        this.test.ship1,
        this.test.planet1
      ) === false
    );

    assert(
      stopoverPossible(
        this.test.so1,
        [],
        [so3],
        this.test.ship1,
        this.test.planet1
      ) === false
    );

    assert(
      stopoverPossible(
        this.test.so1,
        [],
        [so4],
        this.test.ship1,
        this.test.planet1
      ) === false
    );
  });

  it("should say no when there is no space in dock - border case", function () {
    const so2 = Stopover.build({
      SpaceshipName: this.test.ship1.name,
      PlanetName: this.test.planet1.name,
      from: 1,
      till: 1500,
    });
    const so3 = Stopover.build({
      SpaceshipName: this.test.ship1.name,
      PlanetName: this.test.planet1.name,
      from: 2900,
      till: 3000,
    });

    assert(
      stopoverPossible(
        this.test.so1,
        [],
        [so2],
        this.test.ship1,
        this.test.planet1
      ) === false
    );

    assert(
      stopoverPossible(
        this.test.so1,
        [],
        [so3],
        this.test.ship1,
        this.test.planet1
      ) === false
    );
  });

  it("Should break if ship is not available", function () {
    const so2 = Stopover.build({
      SpaceshipName: this.test.ship1.name,
      PlanetName: this.test.planet1.name,
      from: 1,
      till: 1500,
    });
    const so3 = Stopover.build({
      SpaceshipName: this.test.ship1.name,
      PlanetName: this.test.planet1.name,
      from: 1,
      till: 1501,
    });
    const so4 = Stopover.build({
      SpaceshipName: this.test.ship1.name,
      PlanetName: this.test.planet1.name,
      from: 1,
      till: 3000,
    });
    const so5 = Stopover.build({
      SpaceshipName: this.test.ship1.name,
      PlanetName: this.test.planet1.name,
      from: 1800,
      till: 1900,
    });
    const so6 = Stopover.build({
      SpaceshipName: this.test.ship1.name,
      PlanetName: this.test.planet1.name,
      from: 1800,
      till: 3000,
    });
    const so7 = Stopover.build({
      SpaceshipName: this.test.ship1.name,
      PlanetName: this.test.planet1.name,
      from: 2900,
      till: 3000,
    });

    assert(
      stopoverPossible(
        this.test.so1,
        [so2],
        [],
        this.test.ship1,
        this.test.planet1
      ) === false
    );
    assert(
      stopoverPossible(
        this.test.so1,
        [so3],
        [],
        this.test.ship1,
        this.test.planet1
      ) === false
    );
    assert(
      stopoverPossible(
        this.test.so1,
        [so4],
        [],
        this.test.ship1,
        this.test.planet1
      ) === false
    );
    assert(
      stopoverPossible(
        this.test.so1,
        [so5],
        [],
        this.test.ship1,
        this.test.planet1
      ) === false
    );
    assert(
      stopoverPossible(
        this.test.so1,
        [so6],
        [],
        this.test.ship1,
        this.test.planet1
      ) === false
    );
    assert(
      stopoverPossible(
        this.test.so1,
        [so7],
        [],
        this.test.ship1,
        this.test.planet1
      ) === false
    );
  });
});
