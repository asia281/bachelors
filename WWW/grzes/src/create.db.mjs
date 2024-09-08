/* eslint-disable no-await-in-loop */

import Sequelize from "sequelize";
import defineModels from "./models.mjs";
import { getDbString, stopoverPossible } from "./utils.mjs";

// Informacje dotyczące bazy danych
const userName = "????";
const password = "????";
const host = "lkdb";
const port = "5432";
const db = "bd";

// Poniżej nie zmieniać

const sequelize = new Sequelize(
  getDbString(`postgres://${userName}:${password}@${host}:${port}/${db}`)
);

const { Planet, Spaceship, Stopover } = defineModels(sequelize);
await sequelize.sync({ force: true });

const planets = [
  {
    name: "Bila I",
    imageUrl: "/img/Bila.I.jpg",
    docksA: 0,
    docksB: 4,
    docksC: 8,
  },
  {
    name: "Cepitol III",
    imageUrl: "/img/Cepitol.III.jpg",
    docksA: 2,
    docksB: 3,
    docksC: 5,
  },
  {
    name: "Himaqua V",
    imageUrl: "/img/Himaqua.V.jpg",
    docksA: 14,
    docksB: 1,
    docksC: 23,
  },
  {
    name: "Hololia V",
    imageUrl: "/img/Hololia.V.jpg",
    docksA: 1,
    docksB: 0,
    docksC: 2,
  },
  {
    name: "Jutuqua IV",
    imageUrl: "/img/Jutuqua.IV.jpg",
    docksA: 8,
    docksB: 11,
    docksC: 5,
  },
  {
    name: "Kalalm IV",
    imageUrl: "/img/Kalalm.IV.jpg",
    docksA: 3,
    docksB: 5,
    docksC: 7,
  },
  {
    name: "Laragig III",
    imageUrl: "/img/Laragig.III.jpg",
    docksA: 17,
    docksB: 0,
    docksC: 0,
  },
  {
    name: "Mipip III",
    imageUrl: "/img/Mipip.III.jpg",
    docksA: 5,
    docksB: 10,
    docksC: 15,
  },
  {
    name: "Piporr IV",
    imageUrl: "/img/Piporr.IV.jpg",
    docksA: 8,
    docksB: 8,
    docksC: 8,
  },
  {
    name: "Xommon I",
    imageUrl: "/img/Xommon.I.jpg",
    docksA: 1,
    docksB: 1,
    docksC: 1,
  },
];

const spaceships = [
  {
    name: "Rocinante",
    class: "B",
  },
  {
    name: "The Dark Rustah",
    class: "A",
  },
  {
    name: "JMC Farenheit",
    class: "C",
  },
  {
    name: "Wandering Kozlov",
    class: "A",
  },
  {
    name: "Drowned Artemis",
    class: "B",
  },
  {
    name: "JMC Naddoddur",
    class: "B",
  },
  {
    name: "The IKS Engel",
    class: "C",
  },
  {
    name: "UNS Blazing Aces",
    class: "A",
  },
  {
    name: "Victoria",
    class: "B",
  },
  {
    name: "The Fresh Silver",
    class: "C",
  },
  {
    name: "The Scrap X",
    class: "A",
  },
  {
    name: "Stealthy Calypso",
    class: "C",
  },
];

const planetObjects = {};
for (const p of planets) {
  planetObjects[p.name] = await Planet.create(p);
}

const shipObjects = {};
for (const s of spaceships) {
  shipObjects[s.name] = await Spaceship.create(s);
}

const stopovers = [
  {
    PlanetName: "Himaqua V",
    SpaceshipName: "Rocinante",
    from: 1500,
    till: 2900,
  },
  {
    PlanetName: "Himaqua V",
    SpaceshipName: "The Dark Rustah",
    from: 1600,
    till: 1800,
  },
  {
    PlanetName: "Himaqua V",
    SpaceshipName: "JMC Farenheit",
    from: 1600,
    till: 2900,
  },
  {
    PlanetName: "Himaqua V",
    SpaceshipName: "Wandering Kozlov",
    from: 1601,
    till: 1603,
  },
  {
    PlanetName: "Himaqua V",
    SpaceshipName: "Drowned Artemis",
    from: 2001,
    till: 2100,
  },
  {
    PlanetName: "Himaqua V",
    SpaceshipName: "JMC Naddoddur",
    from: 3417,
    till: 5200,
  },
  {
    PlanetName: "Himaqua V",
    SpaceshipName: "The IKS Engel",
    from: 3418,
    till: 4400,
  },
  {
    PlanetName: "Himaqua V",
    SpaceshipName: "Wandering Kozlov",
    from: 3500,
    till: 16000,
  },
];

for (const s of stopovers) {
  await Stopover.create(s);
}

const shipNames = Object.keys(shipObjects);
const preShipSO = {};
for (const sn of shipNames) preShipSO[sn] = [];

const planetNames = Object.keys(planetObjects);
const prePlanetSO = {};
for (const pn of planetNames) prePlanetSO[pn] = [];

const [shipSO, planetSO] = stopovers.reduce(
  (acc, b) => {
    acc[0][b.SpaceshipName].push(b);
    acc[1][b.PlanetName].push(b);
    return acc;
  },
  [preShipSO, prePlanetSO]
);

const randoms = [
  10, 1, 9138, 277, 7, 5, 10895, 464, 1, 8, 2859, 731, 0, 8, 4035, 180, 9, 3,
  10314, 427, 4, 4, 12669, 689, 11, 2, 10519, 728, 0, 0, 4365, 906, 9, 2, 9512,
  96, 7, 3, 14178, 81, 2, 3, 282, 120, 7, 5, 9491, 860, 0, 4, 9055, 583, 8, 7,
  15080, 579, 4, 8, 3464, 631, 7, 3, 15299, 417, 4, 5, 8952, 159, 7, 6, 2288,
  868, 10, 7, 10506, 123, 2, 9, 14796, 468, 9, 0, 2289, 532, 4, 1, 13401, 801,
  2, 5, 10906, 751, 11, 4, 3666, 24, 7, 7, 5396, 695, 5, 1, 7264, 982, 4, 9,
  10265, 967, 7, 2, 10383, 357, 11, 8, 15531, 962, 6, 9, 8675, 104, 9, 9, 7042,
  995, 11, 8, 429, 56, 8, 0, 9947, 72, 6, 0, 5419, 579, 11, 7, 2372, 734, 6, 1,
  15733, 56, 6, 2, 12332, 579, 1, 5, 9794, 328, 11, 4, 8089, 953, 7, 2, 13117,
  550, 11, 7, 1159, 486, 4, 4, 11922, 35, 3, 9, 1787, 433, 6, 0, 465, 801, 6, 4,
  10337, 653, 8, 7, 13586, 846, 9, 0, 13289, 947, 9, 5, 8862, 389, 10, 6, 14914,
  899, 7, 2, 25, 22, 0, 0, 11075, 221, 8, 8, 10121, 40, 3, 8, 2515, 475, 10, 7,
  11592, 606, 8, 8, 7714, 778, 6, 4, 6508, 719, 7, 8, 14763, 535, 6, 1, 1651,
  515, 7, 1, 4004, 297, 10, 6, 14199, 602, 6, 4, 8830, 43, 9, 5, 3364, 63, 9, 9,
  3708, 898, 10, 6, 13918, 83, 2, 8, 7538, 677, 6, 8, 4408, 248, 10, 8, 9481,
  383, 10, 9, 2698, 939, 0, 5, 343, 934, 5, 7, 15681, 702, 0, 8, 2990, 129, 2,
  1, 3805, 99, 1, 3, 4372, 561, 5, 8, 2133, 285, 8, 4, 5144, 752, 10, 3, 1818,
  190, 0, 7, 7911, 203, 9, 5, 14264, 758, 2, 0, 3175, 538, 1, 3, 11029, 744, 5,
  4, 11823, 335, 0, 0, 12565, 859, 10, 3, 2047, 81, 11, 9, 6199, 165, 11, 1,
  12097, 557, 6, 3, 7562, 517, 3, 4, 527, 439, 5, 7, 8486, 679, 10, 6, 8039,
  468, 2, 7, 12942, 218, 1, 8, 8447, 402, 4, 4, 5985, 136, 2, 8, 9729, 815, 11,
  1, 5123, 375, 7, 2, 976, 325, 0, 5, 14328, 659, 5, 7, 5803, 339, 9, 5, 5929,
  610, 9, 0, 10958, 153, 4, 8, 8379, 299,
].reverse();

while (randoms.length > 0) {
  const s = shipNames[randoms.pop()];
  const p = planetNames[randoms.pop()];
  const from = randoms.pop();
  const till = Math.min(from + randoms.pop(), 16000);

  const so = Stopover.build({
    PlanetName: p,
    SpaceshipName: s,
    from,
    till,
  });

  if (
    stopoverPossible(
      so,
      shipSO[s],
      planetSO[p],
      shipObjects[s],
      planetObjects[p]
    )
  ) {
    shipSO[s].push(so);
    planetSO[p].push(so);
    await so.save();
  }
}
