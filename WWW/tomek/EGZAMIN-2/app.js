import express from "express";
import { Op } from "sequelize";
import getDb from "./src/database.mjs";

const app = express();
const port = 8080;

app.use(express.static("."));
app.set("view engine", "pug");
app.set("views", "./views");

getDb().then((db) => {
  app.get("/", async (req, res) => {
    const context = {};
    context.list = await db.planet.findAll({
      attributes: [
        "name",
        "imageUrl",
        "docksA",
        "docksB",
        "docksC",
        [db.sequelize.fn("COUNT", db.sequelize.col("PlanetName")), "ct"],
      ],
      order: ["name"],
      group: "name",
      include: [
        {
          model: db.stopover,
          group: "PlanetName",
          attributes: [],
        },
      ],
    });
    console.log(context.list);
    res.render("main", { context });
  });

  app.get("/planet/:planet_name", async (req, res) => {
    const context = {};
    const planetName = req.params.planet_name;
    const planets = await db.planet.findAll({
      attributes: ["name", "imageUrl", "docksA", "docksB", "docksC"],
    });
    for (let i = 0; i < planets.length; i += 1) {
      if (planets[i].name === planetName) {
        context.imageUrl = planets[i].imageUrl;
        context.docksA = planets[i].docksA;
        context.docksB = planets[i].docksB;
        context.docksC = planets[i].docksC;
      }
    }
    context.planetName = planetName;
    console.log("Name: ", planetName);
    console.log("Image: ", context.imageUrl);
    context.list = await db.stopover.findAll({
      where: {
        PlanetName: planetName,
      },
      attributes: ["SpaceshipName", "from", "till", "PlanetName"],
      include: [
        {
          model: db.spaceship,
          attributes: ["class"],
        },
      ],
      order: ["from", "till"],
    });
    console.log(context.list[0].Spaceship);
    res.render("planet", { context });
  });

  app.listen(port, () => {
    console.log(`App listening on port ${port}`);
  });
});
