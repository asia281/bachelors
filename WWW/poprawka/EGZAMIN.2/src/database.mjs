import Sequelize from "sequelize";
import defineModels from "./models.mjs";
import { getDbString } from "./utils.mjs";

// Informacje dotyczące bazy danych
const userName = "jw429677";
const password = "iks";
const host = "localhost";
const port = "11212";
const bd = "bd";

const sequelize = new Sequelize(
  getDbString(`postgres://${userName}:${password}@${host}:${port}/${bd}`)
);

await sequelize.sync();

// accessing the database, a neat handle for that
export default async () => {
  try {
    await sequelize.authenticate();
    console.log(
      "Connection to the database has been established successfully."
    );

    const db = {};

    db.sequelize = sequelize;

    const { Meme, Gallery, Display } = defineModels(sequelize);

    db.Meme = Meme;
    db.Gallery = Gallery;
    db.Display = Display;

    // Synchronizacja
    await db.sequelize.sync();

    return db;
  } catch (error) {
    console.error("Nie udalo siie nawiazac polaczenia");
    throw error;
  }
};
