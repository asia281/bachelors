import { Sequelize } from "sequelize";

import defineModels from "./models.mjs";
import { getDbString } from "./utils.mjs";

// I set the env var WWW2022_DB to my pgsql credentials as this is how the function
// is intended to be used, innit.
const sequelize = new Sequelize(
  getDbString("this does not matter")
);

// accessing the database, a neat handle for that
export default async () => {
  try {
    await sequelize.authenticate();
    console.log(
      "Connection to the database has been established successfully."
    );

    const db = {};

    db.sequelize = sequelize;

    const { Planet, Spaceship, Stopover } = defineModels(sequelize);

    db.Planet = Planet;
    db.Spaceship = Spaceship;
    db.Stopover = Stopover;

    // Synchronizacja
    await db.sequelize.sync();

    return db;
  } catch (error) {
    console.error("Nie udalo siie nawiazac polaczenia");
    throw error;
  }
};
