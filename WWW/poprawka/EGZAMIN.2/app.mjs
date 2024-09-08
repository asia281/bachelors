import express from "express";
import { Op } from "sequelize";
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
    let memes = await db.Meme.findAll({
      attributes: ["id", "title", "imageUrl", "description"],
      order: ["id"],
    });
    const date = new Date();
    // finding each planets stop's in a js monkey way
    memes = await Promise.all(
      memes.map(async (pl) => ({
        // eslint-disable-next-line node/no-unsupported-features/es-syntax
        ...pl.dataValues,
        displayCount: await db.Display.count({
          where: {
            MemeId: pl.id,
            till: { [Op.gte]: date },
          },
        }),
      }))
    );
    context.memes = memes;
    console.log(memes);

    console.log(date);
    res.render("main", { context });
  });

  app.get("/mem/:meme_id", async (req, res) => {
    console.log("meme");
    const id = req.params.meme_id;
    console.log(id);
    const mem = await db.Meme.findByPk(id);
    if (!mem) {
      console.log("not found");
      res.render("mem_not_found");
      return;
    }
    console.log("found!");

    const displays = await db.Display.findAll({
      where: { MemeId: id },
      attributes: ["MemeId", "GalleryName", "from", "till"],
      order: ["from", "till"],
    });

    res.render("mem", { mem, displays });
  });

  app.listen(port, () => {
    console.log(`App listening on http://localhost:${port}`);
  });
});
