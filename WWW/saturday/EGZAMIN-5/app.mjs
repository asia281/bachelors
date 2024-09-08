import express from "express";
import getDb from "./src/database.mjs";
import { Op } from "sequelize";
// import stuff from database

// our app
const app = express();
// we're listening at port 8080
const port = 8080;

// adds a middleware for serving static files to your Express app
app.use(express.static("."));

// configures pug
app.set("view engine", "pug");
app.set("views", "./views");

// obsluga getDB
getDb().then((db) => {
  // obsluga strony glownej
  app.get("/", async (req, res) => {
    const context = {};
    context.list = await db.Planet.findAll({
      attributes: [
        "name",
        "imageUrl",
        "docksA",
        "docksB",
        "docksC",
        [db.sequelize.fn("COUNT", db.sequelize.col("PlanetName")), "pn"],
      ],
      order: ["name"],
      group: "name",
      include: [
        {
          model: db.Stopover,
          group: "PlanetName",
          attributes: [],
        },
      ],
    });

    res.render("main", { context });
  });

  // obsluga sciezki planety
  app.get("/planet/:planet_name", async (req, res) => {
    const planets = await db.Planet.findAll({
      attributes: ["name", "imageUrl", "docksA", "docksB", "docksC"],
    });
    const response = {};
    response.name = req.params.planet_name;
    for (let i = 0; i < planets.length; i += 1) {
      if (planets[i].name === response.name) {
        response.imageUrl = planets[i].imageUrl;
        response.docksA = planets[i].docksA;
        response.docksB = planets[i].docksB;
        response.docksC = planets[i].docksC;
        break;
      }
    }

    console.log(response);

    response.stopovers = await db.Stopover.findAll({
      attributes: ["SpaceshipName", "from", "till"],
      where: {
        PlanetName: response.name,
      },
      include: [
        {
          model: db.Spaceship,
          attributes: ["class"],
        },
      ],
      order: ["from", "till"],
    });

    res.render("planet", { response });
  });

  app.listen(port, () => {
    console.log(`App listening on port ${port}`);
  });
});
