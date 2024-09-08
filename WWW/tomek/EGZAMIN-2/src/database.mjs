import Sequelize from "sequelize";
import defineModels from "./models.mjs";
import { getDbString } from "./utils.mjs";

// Informacje dotyczące bazy danych
const userName = "jw429677";
const password = "iks";
const host = "localhost";
const port = "11212";
const db = "bd";

const sequelize = new Sequelize(
  getDbString(`postgres://${userName}:${password}@${host}:${port}/${db}`)
);

const { Planet, Spaceship, Stopover } = defineModels(sequelize);

await sequelize.sync();

export default async () => {
  const base = {};
  base.sequelize = sequelize;
  base.planet = Planet;
  base.spaceship = Spaceship;
  base.stopover = Stopover;

  return base;
};
