/* eslint-disable no-await-in-loop */

import Sequelize from "sequelize";
import defineModels from "./models.mjs";
import { getDbString } from "./utils.mjs";

// Informacje dotyczące bazy danych
const userName = "jw429677";
const password = "iks";
const host = "localhost";
const port = "11212";
const db = "bd";

// Poniżej nie zmieniać

const sequelize = new Sequelize(
  getDbString(`postgres://${userName}:${password}@${host}:${port}/${db}`)
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
      console.error("Nie udalo sie nawiazac polaczenia");
      throw error;
    }
  };