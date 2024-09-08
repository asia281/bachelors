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
app.set('view engine', 'pug'); 
app.set('views', './views');

// obsluga getDB
getDb().then((db) => {
    // obsluga strony glownej
    app.get('/', async (req, res) => {
        const context = {};
        context.list = await db.Planet.findAll({
            attributes: ["name", "imageUrl", "docksA", "docksB", "docksC"],
            order: ["name"],
        });
        res.render('main', { context });
    });


    // obsluga sciezki planety
    app.get('/planet/:planet_name', async (req, res) => {
        const p = {};
        const pName = req.params.planet_name;
        p.name = pName;
        const ships = await db.Planet.findAll({
            attributes: ["name", "imageUrl", "docksA", "docksB", "docksC"],
        });
        for (let i = 0; i < ships.length; i += 1) {
            if (pName == ships[i].name) {
                p.imageUrl = ships[i].imageUrl;
                p.docksA = ships[i].docksA;
                p.docksB = ships[i].docksB;
                p.docksC = ships[i].docksC;
                break
            }
        }
        p.ships = await db.Stopover.findAll({
            attributes: ["SpaceshipName", "from", "till", "PlanetName"],
            where: {
                PlanetName: pName,
            },
            include: [
                {
                  model: db.Spaceship,
                  attributes: ["class"],
                },
            ],
            order: ["from", "till"],
        });
        

        console.log(`blah`);

        res.render('planet', { p });
    });

    

    app.listen(port, () => {
        console.log(`App listening on port ${port}`);
    });
});