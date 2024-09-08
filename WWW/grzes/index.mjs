import express from "express";

import getDb from "./src/database.mjs";

const app = express();
const port = 8080;

app.use(express.static("static"));

// W views są pugowe szablony generujące semantyczny html. As semantic as it gets.
// Starałem się korzystać z sematycznych znaczników mając w głowie maksymę z wykładu:
//     ,,Gdy żaden znacznik semantyczny nie pasuje (np. pudełko
//       potrzebne z powodów technicznych), to pozostaje <div>''
app.set("view engine", "pug");
app.set("views", "./views");

getDb().then((db) => {
  app.get("/", async (req, res) => {
    console.log("get /");

    const context = {};
    let planets = await db.Planet.findAll({
      attributes: ["name", "imageUrl", "docksA", "docksB", "docksC"],
      order: ["name"],
    });

    // finding each planets stop's in a js monkey way
    planets = await Promise.all(
      planets.map(async (pl) => ({
        ...pl.dataValues,
        reservations: await db.Stopover.count({
          where: {
            PlanetName: pl.name,
          },
        }),
      }))
    );

    // This single query does the same that the map above.
    const counts = await db.Planet.findAll({
      include: [
        {
          model: db.Stopover,
          attributes: [],
          require: true,
        },
      ],
      attributes: [
        "name",
        "imageUrl",
        "docksA",
        "docksB",
        "docksC",
        [
          db.sequelize.fn("COUNT", db.sequelize.col("Stopovers.id")),
          "reservations",
        ],
      ],
      group: ["name", "imageUrl", "docksA", "docksB", "docksC"],
      order: ["name"],
    });
    // note: clearly the "reservations" field is set correctly and this way
    // I get everything with a single query. So why the reservations do not get
    // rendered then?? I have no idea: if the following console.log was uncommented
    // then it is visible that the reservtions are there!!! But for some reason this
    // does not work so I gave up and chosen the less sql-profficient js solution. :(
    // console.log(counts);

    // Why doesn;t this work? Pug doesn't see reservations???!
    context.planets = counts;

    // This works.
    context.planets = planets;

    res.render("main", { context });
  });

  app.get("/planet/:planet_name", async (req, res) => {
    console.log("planetka's");
    const planetName = req.params.planet_name;
    console.log(planetName);
    const planet = await db.Planet.findByPk(planetName);
    if (!planet) {
      res.render("planet_not_found");
      return;
    }

    const stopships = await db.Stopover.findAll({
      include: [
        {
          model: db.Spaceship,
          required: true,
        },
        {
          model: db.Planet,
          where: { name: planetName },
        },
      ],
      order: ["from", "till"],
    });

    res.render("planet", { planet, stopships });
  });

  app.listen(port, () => {
    console.log(`App listening on http://localhost:${port}`);
  });
});
