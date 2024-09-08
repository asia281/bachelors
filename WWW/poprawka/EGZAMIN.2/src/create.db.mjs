/* eslint-disable no-await-in-loop */

import Sequelize from "sequelize";
import models from "./models.mjs";
import { getDbString } from "./utils.mjs";

// Informacje dotyczące bazy danych
const userName = "jw429677";
const password = "iks";
const host = "localhost";
const port = "11212";
const db = "bd";

// Poniżej nic nie zmieniać!
//
// Poważnie, jeśli myślisz, że potrzebujesz coś zmienić poniżej, to raczej
// robisz coś źle. Spytaj któregoś z prowadzących, może będzie mógł pomóc.

const sequelize = new Sequelize(
  getDbString(`postgres://${userName}:${password}@${host}:${port}/${db}`)
);

const { Meme, Gallery, Display } = models(sequelize);
await sequelize.sync({ force: true });

console.log("Podłączyłem się do bazy.");

const memes = [
  {
    id: 1,
    title: "Fixes in production",
    imageUrl: "/img/m01.jpg",
    description: `(Opis mema 1) Sed ut perspiciatis unde omnis iste natus error sit voluptatem accusantium doloremque laudantium,
totam rem aperiam, eaque ipsa quae ab illo inventore veritatis et quasi architecto beatae vitae dicta sunt explicabo.
Nemo enim ipsam voluptatem quia voluptas sit aspernatur aut odit aut fugit, sed quia consequuntur magni dolores eos
qui ratione voluptatem sequi nesciunt. Neque porro quisquam est, qui dolorem ipsum quia dolor sit amet, consectetur,
adipisci velit, sed quia non numquam eius modi tempora incidunt ut labore et dolore magnam aliquam quaerat voluptatem.
Ut enim ad minima veniam, quis nostrum exercitationem ullam corporis suscipit laboriosam, nisi ut aliquid ex ea commodi
consequatur? Quis autem vel eum iure reprehenderit qui in ea voluptate velit esse quam nihil molestiae consequatur,
vel illum qui dolorem eum fugiat quo voluptas nulla pariatur?`,
  },
  {
    id: 2,
    title: "Exception / Crash",
    imageUrl: "/img/m02.jpg",
    description: `Wyjątek... wyjątek można rzucić, później przechwycić, wszyscy to robią, chyba że zapomną. Porządna
katastrofa - nad tym warto się pochylić. Gdyby każdy umiał wywrócić system świat byłby chyba mniej
przyjemny. Dobrze, że nie jesteśmy tacy sami.`,
  },
  {
    id: 3,
    title: "Why doesn't it work?",
    imageUrl: "/img/m03.jpg",
    description: `(Opis mema 3) Sed ut perspiciatis unde omnis iste natus error sit voluptatem accusantium doloremque laudantium,
totam rem aperiam, eaque ipsa quae ab illo inventore veritatis et quasi architecto beatae vitae dicta sunt explicabo.
Nemo enim ipsam voluptatem quia voluptas sit aspernatur aut odit aut fugit, sed quia consequuntur magni dolores eos
qui ratione voluptatem sequi nesciunt. Neque porro quisquam est, qui dolorem ipsum quia dolor sit amet, consectetur,
adipisci velit, sed quia non numquam eius modi tempora incidunt ut labore et dolore magnam aliquam quaerat voluptatem.
Ut enim ad minima veniam, quis nostrum exercitationem ullam corporis suscipit laboriosam, nisi ut aliquid ex ea commodi
consequatur? Quis autem vel eum iure reprehenderit qui in ea voluptate velit esse quam nihil molestiae consequatur,
vel illum qui dolorem eum fugiat quo voluptas nulla pariatur?`,
  },
  {
    id: 4,
    title: "Scrum Master",
    imageUrl: "/img/m04.jpg",
    description: `(Opis mema 4) Sed ut perspiciatis unde omnis iste natus error sit voluptatem accusantium doloremque laudantium,
totam rem aperiam, eaque ipsa quae ab illo inventore veritatis et quasi architecto beatae vitae dicta sunt explicabo.
Nemo enim ipsam voluptatem quia voluptas sit aspernatur aut odit aut fugit, sed quia consequuntur magni dolores eos
qui ratione voluptatem sequi nesciunt. Neque porro quisquam est, qui dolorem ipsum quia dolor sit amet, consectetur,
adipisci velit, sed quia non numquam eius modi tempora incidunt ut labore et dolore magnam aliquam quaerat voluptatem.
Ut enim ad minima veniam, quis nostrum exercitationem ullam corporis suscipit laboriosam, nisi ut aliquid ex ea commodi
consequatur? Quis autem vel eum iure reprehenderit qui in ea voluptate velit esse quam nihil molestiae consequatur,
vel illum qui dolorem eum fugiat quo voluptas nulla pariatur?`,
  },
  {
    id: 5,
    title: "Functional programming",
    imageUrl: "/img/m05.jpg",
    description: `(Opis mema 5) Sed ut perspiciatis unde omnis iste natus error sit voluptatem accusantium doloremque laudantium,
totam rem aperiam, eaque ipsa quae ab illo inventore veritatis et quasi architecto beatae vitae dicta sunt explicabo.
Nemo enim ipsam voluptatem quia voluptas sit aspernatur aut odit aut fugit, sed quia consequuntur magni dolores eos
qui ratione voluptatem sequi nesciunt. Neque porro quisquam est, qui dolorem ipsum quia dolor sit amet, consectetur,
adipisci velit, sed quia non numquam eius modi tempora incidunt ut labore et dolore magnam aliquam quaerat voluptatem.
Ut enim ad minima veniam, quis nostrum exercitationem ullam corporis suscipit laboriosam, nisi ut aliquid ex ea commodi
consequatur? Quis autem vel eum iure reprehenderit qui in ea voluptate velit esse quam nihil molestiae consequatur,
vel illum qui dolorem eum fugiat quo voluptas nulla pariatur?`,
  },
  {
    id: 6,
    title: "Middle button",
    imageUrl: "/img/m06.jpg",
    description: `(Opis mema 6) Sed ut perspiciatis unde omnis iste natus error sit voluptatem accusantium doloremque laudantium,
totam rem aperiam, eaque ipsa quae ab illo inventore veritatis et quasi architecto beatae vitae dicta sunt explicabo.
Nemo enim ipsam voluptatem quia voluptas sit aspernatur aut odit aut fugit, sed quia consequuntur magni dolores eos
qui ratione voluptatem sequi nesciunt. Neque porro quisquam est, qui dolorem ipsum quia dolor sit amet, consectetur,
adipisci velit, sed quia non numquam eius modi tempora incidunt ut labore et dolore magnam aliquam quaerat voluptatem.
Ut enim ad minima veniam, quis nostrum exercitationem ullam corporis suscipit laboriosam, nisi ut aliquid ex ea commodi
consequatur? Quis autem vel eum iure reprehenderit qui in ea voluptate velit esse quam nihil molestiae consequatur,
vel illum qui dolorem eum fugiat quo voluptas nulla pariatur?`,
  },
  {
    id: 7,
    title: "Compilers?",
    imageUrl: "/img/m07.jpg",
    description: `(Opis mema 7) Sed ut perspiciatis unde omnis iste natus error sit voluptatem accusantium doloremque laudantium,
totam rem aperiam, eaque ipsa quae ab illo inventore veritatis et quasi architecto beatae vitae dicta sunt explicabo.
Nemo enim ipsam voluptatem quia voluptas sit aspernatur aut odit aut fugit, sed quia consequuntur magni dolores eos
qui ratione voluptatem sequi nesciunt. Neque porro quisquam est, qui dolorem ipsum quia dolor sit amet, consectetur,
adipisci velit, sed quia non numquam eius modi tempora incidunt ut labore et dolore magnam aliquam quaerat voluptatem.
Ut enim ad minima veniam, quis nostrum exercitationem ullam corporis suscipit laboriosam, nisi ut aliquid ex ea commodi
consequatur? Quis autem vel eum iure reprehenderit qui in ea voluptate velit esse quam nihil molestiae consequatur,
vel illum qui dolorem eum fugiat quo voluptas nulla pariatur?`,
  },
  {
    id: 8,
    title: "The Web?",
    imageUrl: "/img/m08.jpg",
    description: `(Opis mema 8) Sed ut perspiciatis unde omnis iste natus error sit voluptatem accusantium doloremque laudantium,
totam rem aperiam, eaque ipsa quae ab illo inventore veritatis et quasi architecto beatae vitae dicta sunt explicabo.
Nemo enim ipsam voluptatem quia voluptas sit aspernatur aut odit aut fugit, sed quia consequuntur magni dolores eos
qui ratione voluptatem sequi nesciunt. Neque porro quisquam est, qui dolorem ipsum quia dolor sit amet, consectetur,
adipisci velit, sed quia non numquam eius modi tempora incidunt ut labore et dolore magnam aliquam quaerat voluptatem.
Ut enim ad minima veniam, quis nostrum exercitationem ullam corporis suscipit laboriosam, nisi ut aliquid ex ea commodi
consequatur? Quis autem vel eum iure reprehenderit qui in ea voluptate velit esse quam nihil molestiae consequatur,
vel illum qui dolorem eum fugiat quo voluptas nulla pariatur?`,
  },
  {
    id: 9,
    title: "Oneliners",
    imageUrl: "/img/m09.jpg",
    description: `(Opis mema 9) Sed ut perspiciatis unde omnis iste natus error sit voluptatem accusantium doloremque laudantium,
totam rem aperiam, eaque ipsa quae ab illo inventore veritatis et quasi architecto beatae vitae dicta sunt explicabo.
Nemo enim ipsam voluptatem quia voluptas sit aspernatur aut odit aut fugit, sed quia consequuntur magni dolores eos
qui ratione voluptatem sequi nesciunt. Neque porro quisquam est, qui dolorem ipsum quia dolor sit amet, consectetur,
adipisci velit, sed quia non numquam eius modi tempora incidunt ut labore et dolore magnam aliquam quaerat voluptatem.
Ut enim ad minima veniam, quis nostrum exercitationem ullam corporis suscipit laboriosam, nisi ut aliquid ex ea commodi
consequatur? Quis autem vel eum iure reprehenderit qui in ea voluptate velit esse quam nihil molestiae consequatur,
vel illum qui dolorem eum fugiat quo voluptas nulla pariatur?`,
  },
  {
    id: 10,
    title: "The new feature",
    imageUrl: "/img/m10.jpg",
    description: `(Opis mema 10) Sed ut perspiciatis unde omnis iste natus error sit voluptatem accusantium doloremque laudantium,
totam rem aperiam, eaque ipsa quae ab illo inventore veritatis et quasi architecto beatae vitae dicta sunt explicabo.
Nemo enim ipsam voluptatem quia voluptas sit aspernatur aut odit aut fugit, sed quia consequuntur magni dolores eos
qui ratione voluptatem sequi nesciunt. Neque porro quisquam est, qui dolorem ipsum quia dolor sit amet, consectetur,
adipisci velit, sed quia non numquam eius modi tempora incidunt ut labore et dolore magnam aliquam quaerat voluptatem.
Ut enim ad minima veniam, quis nostrum exercitationem ullam corporis suscipit laboriosam, nisi ut aliquid ex ea commodi
consequatur? Quis autem vel eum iure reprehenderit qui in ea voluptate velit esse quam nihil molestiae consequatur,
vel illum qui dolorem eum fugiat quo voluptas nulla pariatur?`,
  },
  {
    id: 11,
    title: "Git",
    imageUrl: "/img/m11.jpg",
    description: `(Opis mema 11) Sed ut perspiciatis unde omnis iste natus error sit voluptatem accusantium doloremque laudantium,
totam rem aperiam, eaque ipsa quae ab illo inventore veritatis et quasi architecto beatae vitae dicta sunt explicabo.
Nemo enim ipsam voluptatem quia voluptas sit aspernatur aut odit aut fugit, sed quia consequuntur magni dolores eos
qui ratione voluptatem sequi nesciunt. Neque porro quisquam est, qui dolorem ipsum quia dolor sit amet, consectetur,
adipisci velit, sed quia non numquam eius modi tempora incidunt ut labore et dolore magnam aliquam quaerat voluptatem.
Ut enim ad minima veniam, quis nostrum exercitationem ullam corporis suscipit laboriosam, nisi ut aliquid ex ea commodi
consequatur? Quis autem vel eum iure reprehenderit qui in ea voluptate velit esse quam nihil molestiae consequatur,
vel illum qui dolorem eum fugiat quo voluptas nulla pariatur?`,
  },
  {
    id: 12,
    title: "A bug",
    imageUrl: "/img/m12.jpg",
    description: `(Opis mema 12) Sed ut perspiciatis unde omnis iste natus error sit voluptatem accusantium doloremque laudantium,
totam rem aperiam, eaque ipsa quae ab illo inventore veritatis et quasi architecto beatae vitae dicta sunt explicabo.
Nemo enim ipsam voluptatem quia voluptas sit aspernatur aut odit aut fugit, sed quia consequuntur magni dolores eos
qui ratione voluptatem sequi nesciunt. Neque porro quisquam est, qui dolorem ipsum quia dolor sit amet, consectetur,
adipisci velit, sed quia non numquam eius modi tempora incidunt ut labore et dolore magnam aliquam quaerat voluptatem.
Ut enim ad minima veniam, quis nostrum exercitationem ullam corporis suscipit laboriosam, nisi ut aliquid ex ea commodi
consequatur? Quis autem vel eum iure reprehenderit qui in ea voluptate velit esse quam nihil molestiae consequatur,
vel illum qui dolorem eum fugiat quo voluptas nulla pariatur?`,
  },
  {
    id: 13,
    title: "10 lines",
    imageUrl: "/img/m13.jpg",
    description: `(Opis mema 13) Sed ut perspiciatis unde omnis iste natus error sit voluptatem accusantium doloremque laudantium,
totam rem aperiam, eaque ipsa quae ab illo inventore veritatis et quasi architecto beatae vitae dicta sunt explicabo.
Nemo enim ipsam voluptatem quia voluptas sit aspernatur aut odit aut fugit, sed quia consequuntur magni dolores eos
qui ratione voluptatem sequi nesciunt. Neque porro quisquam est, qui dolorem ipsum quia dolor sit amet, consectetur,
adipisci velit, sed quia non numquam eius modi tempora incidunt ut labore et dolore magnam aliquam quaerat voluptatem.
Ut enim ad minima veniam, quis nostrum exercitationem ullam corporis suscipit laboriosam, nisi ut aliquid ex ea commodi
consequatur? Quis autem vel eum iure reprehenderit qui in ea voluptate velit esse quam nihil molestiae consequatur,
vel illum qui dolorem eum fugiat quo voluptas nulla pariatur?`,
  },
  {
    id: 14,
    title: "Documentation",
    imageUrl: "/img/m14.jpg",
    description: `(Opis mema 14) Sed ut perspiciatis unde omnis iste natus error sit voluptatem accusantium doloremque laudantium,
totam rem aperiam, eaque ipsa quae ab illo inventore veritatis et quasi architecto beatae vitae dicta sunt explicabo.
Nemo enim ipsam voluptatem quia voluptas sit aspernatur aut odit aut fugit, sed quia consequuntur magni dolores eos
qui ratione voluptatem sequi nesciunt. Neque porro quisquam est, qui dolorem ipsum quia dolor sit amet, consectetur,
adipisci velit, sed quia non numquam eius modi tempora incidunt ut labore et dolore magnam aliquam quaerat voluptatem.
Ut enim ad minima veniam, quis nostrum exercitationem ullam corporis suscipit laboriosam, nisi ut aliquid ex ea commodi
consequatur? Quis autem vel eum iure reprehenderit qui in ea voluptate velit esse quam nihil molestiae consequatur,
vel illum qui dolorem eum fugiat quo voluptas nulla pariatur?`,
  },
];

const galleries = [
  {
    name: "Przestrzeń Elektrownia Opadowa",
    address: "ul. Makuszyńskiego Kornela 8, Kraków",
  },
  {
    name: "Gmach Komisji Rządowej",
    address: "ul. Bieńczaka Władysława 30, Warszawa",
  },
  {
    name: "Galeria Przemyśleń i Obserwacji",
    address: "ul. Urbanowska 129, Poznań",
  },
  {
    name: "Galeria Ezoterycznych Obrazków Zabawnych",
    address: "ul. Pomyślna 131, Gdańsk",
  },
  {
    name: "Przestrzeń Obrazowotwórcza",
    address: "ul. Wybickiego 73, Grudziądz",
  },
];

console.log("Wstawiam memy...");

const memeObjects = {};
for (const m of memes) {
  memeObjects[m.id] = await Meme.create(m);
}

console.log("Wstawione.");

console.log("Wstawiam galerie...");

const galleryObjects = {};
for (const g of galleries) {
  galleryObjects[g.name] = await Gallery.create(g);
}

console.log("Wstawione.");

const staticDisplays = [
  {
    MemeId: 2,
    GalleryName: "Przestrzeń Elektrownia Opadowa",
    from: "2022-01-10",
    till: "2022-06-07",
  },
  {
    MemeId: 2,
    GalleryName: "Gmach Komisji Rządowej",
    from: "2022-06-21",
    till: "2023-01-06",
  },
  {
    MemeId: 2,
    GalleryName: "Galeria Przemyśleń i Obserwacji",
    from: "2023-03-11",
    till: "2023-05-18",
  },
  {
    MemeId: 2,
    GalleryName: "Galeria Ezoterycznych Obrazków Zabawnych",
    from: "2023-10-21",
    till: "2023-12-01",
  },
  {
    MemeId: 14,
    GalleryName: "Przestrzeń Obrazowotwórcza",
    from: "2022-12-09",
    till: "2023-03-10",
  },
  {
    MemeId: 14,
    GalleryName: "Przestrzeń Obrazowotwórcza",
    from: "2023-05-30",
    till: "2023-07-26",
  },
  {
    MemeId: 14,
    GalleryName: "Przestrzeń Elektrownia Opadowa",
    from: "2023-11-27",
    till: "2024-01-03",
  },
  {
    MemeId: 14,
    GalleryName: "Gmach Komisji Rządowej",
    from: "2024-02-04",
    till: "2024-05-01",
  },
  {
    MemeId: 13,
    GalleryName: "Przestrzeń Obrazowotwórcza",
    from: "2023-08-12",
    till: "2023-11-01",
  },
  {
    MemeId: 13,
    GalleryName: "Galeria Przemyśleń i Obserwacji",
    from: "2024-04-28",
    till: "2024-05-06",
  },
  {
    MemeId: 13,
    GalleryName: "Przestrzeń Obrazowotwórcza",
    from: "2024-09-17",
    till: "2024-12-25",
  },
  {
    MemeId: 13,
    GalleryName: "Przestrzeń Elektrownia Opadowa",
    from: "2025-02-08",
    till: "2025-05-14",
  },
  {
    MemeId: 13,
    GalleryName: "Galeria Ezoterycznych Obrazków Zabawnych",
    from: "2025-08-01",
    till: "2025-09-11",
  },
  {
    MemeId: 13,
    GalleryName: "Galeria Ezoterycznych Obrazków Zabawnych",
    from: "2026-01-19",
    till: "2026-04-26",
  },
  {
    MemeId: 13,
    GalleryName: "Galeria Ezoterycznych Obrazków Zabawnych",
    from: "2026-11-03",
    till: "2026-11-13",
  },
  {
    MemeId: 13,
    GalleryName: "Galeria Ezoterycznych Obrazków Zabawnych",
    from: "2026-12-29",
    till: "2027-01-12",
  },
  {
    MemeId: 12,
    GalleryName: "Gmach Komisji Rządowej",
    from: "2022-12-30",
    till: "2023-01-18",
  },
  {
    MemeId: 12,
    GalleryName: "Galeria Przemyśleń i Obserwacji",
    from: "2023-06-27",
    till: "2023-09-02",
  },
  {
    MemeId: 12,
    GalleryName: "Galeria Przemyśleń i Obserwacji",
    from: "2023-09-13",
    till: "2023-10-15",
  },
  {
    MemeId: 12,
    GalleryName: "Galeria Przemyśleń i Obserwacji",
    from: "2024-02-14",
    till: "2024-04-06",
  },
  {
    MemeId: 12,
    GalleryName: "Przestrzeń Elektrownia Opadowa",
    from: "2024-07-16",
    till: "2024-09-19",
  },
  {
    MemeId: 12,
    GalleryName: "Przestrzeń Elektrownia Opadowa",
    from: "2025-01-26",
    till: "2025-03-26",
  },
  {
    MemeId: 12,
    GalleryName: "Gmach Komisji Rządowej",
    from: "2025-08-04",
    till: "2025-09-07",
  },
  {
    MemeId: 12,
    GalleryName: "Galeria Przemyśleń i Obserwacji",
    from: "2026-01-08",
    till: "2026-02-22",
  },
  {
    MemeId: 12,
    GalleryName: "Galeria Przemyśleń i Obserwacji",
    from: "2026-07-12",
    till: "2026-08-06",
  },
  {
    MemeId: 12,
    GalleryName: "Przestrzeń Obrazowotwórcza",
    from: "2026-09-07",
    till: "2026-12-12",
  },
  {
    MemeId: 12,
    GalleryName: "Galeria Przemyśleń i Obserwacji",
    from: "2027-04-01",
    till: "2027-06-27",
  },
  {
    MemeId: 11,
    GalleryName: "Przestrzeń Obrazowotwórcza",
    from: "2023-04-26",
    till: "2023-07-07",
  },
  {
    MemeId: 11,
    GalleryName: "Galeria Ezoterycznych Obrazków Zabawnych",
    from: "2023-10-13",
    till: "2023-11-24",
  },
  {
    MemeId: 11,
    GalleryName: "Przestrzeń Elektrownia Opadowa",
    from: "2024-06-09",
    till: "2024-08-01",
  },
  {
    MemeId: 11,
    GalleryName: "Przestrzeń Obrazowotwórcza",
    from: "2024-10-16",
    till: "2025-01-20",
  },
  {
    MemeId: 11,
    GalleryName: "Przestrzeń Obrazowotwórcza",
    from: "2025-07-24",
    till: "2025-08-28",
  },
  {
    MemeId: 11,
    GalleryName: "Galeria Przemyśleń i Obserwacji",
    from: "2026-03-10",
    till: "2026-05-07",
  },
  {
    MemeId: 11,
    GalleryName: "Przestrzeń Elektrownia Opadowa",
    from: "2026-11-16",
    till: "2026-11-18",
  },
  {
    MemeId: 11,
    GalleryName: "Galeria Przemyśleń i Obserwacji",
    from: "2027-02-28",
    till: "2027-05-28",
  },
  {
    MemeId: 11,
    GalleryName: "Galeria Przemyśleń i Obserwacji",
    from: "2027-09-18",
    till: "2027-12-21",
  },
  {
    MemeId: 11,
    GalleryName: "Przestrzeń Elektrownia Opadowa",
    from: "2027-12-30",
    till: "2028-02-25",
  },
  {
    MemeId: 10,
    GalleryName: "Przestrzeń Obrazowotwórcza",
    from: "2023-02-22",
    till: "2023-03-26",
  },
  {
    MemeId: 10,
    GalleryName: "Przestrzeń Elektrownia Opadowa",
    from: "2023-05-19",
    till: "2023-08-15",
  },
  {
    MemeId: 10,
    GalleryName: "Galeria Ezoterycznych Obrazków Zabawnych",
    from: "2024-01-04",
    till: "2024-02-01",
  },
  {
    MemeId: 10,
    GalleryName: "Przestrzeń Elektrownia Opadowa",
    from: "2024-03-07",
    till: "2024-06-06",
  },
  {
    MemeId: 9,
    GalleryName: "Przestrzeń Obrazowotwórcza",
    from: "2023-06-17",
    till: "2023-08-13",
  },
  {
    MemeId: 9,
    GalleryName: "Galeria Przemyśleń i Obserwacji",
    from: "2023-11-18",
    till: "2023-12-12",
  },
  {
    MemeId: 9,
    GalleryName: "Przestrzeń Elektrownia Opadowa",
    from: "2024-05-18",
    till: "2024-07-04",
  },
  {
    MemeId: 9,
    GalleryName: "Gmach Komisji Rządowej",
    from: "2024-11-11",
    till: "2025-02-17",
  },
  {
    MemeId: 9,
    GalleryName: "Galeria Przemyśleń i Obserwacji",
    from: "2025-07-13",
    till: "2025-09-18",
  },
  {
    MemeId: 9,
    GalleryName: "Galeria Przemyśleń i Obserwacji",
    from: "2026-02-22",
    till: "2026-05-29",
  },
  {
    MemeId: 9,
    GalleryName: "Gmach Komisji Rządowej",
    from: "2026-07-10",
    till: "2026-08-26",
  },
  {
    MemeId: 8,
    GalleryName: "Gmach Komisji Rządowej",
    from: "2022-11-12",
    till: "2023-02-01",
  },
  {
    MemeId: 8,
    GalleryName: "Galeria Przemyśleń i Obserwacji",
    from: "2023-04-15",
    till: "2023-05-04",
  },
  {
    MemeId: 8,
    GalleryName: "Galeria Przemyśleń i Obserwacji",
    from: "2023-08-18",
    till: "2023-10-06",
  },
  {
    MemeId: 8,
    GalleryName: "Galeria Ezoterycznych Obrazków Zabawnych",
    from: "2023-11-12",
    till: "2023-12-18",
  },
  {
    MemeId: 8,
    GalleryName: "Przestrzeń Obrazowotwórcza",
    from: "2024-02-11",
    till: "2024-02-18",
  },
  {
    MemeId: 8,
    GalleryName: "Galeria Ezoterycznych Obrazków Zabawnych",
    from: "2024-08-14",
    till: "2024-10-18",
  },
  {
    MemeId: 8,
    GalleryName: "Przestrzeń Obrazowotwórcza",
    from: "2024-11-02",
    till: "2024-12-30",
  },
  {
    MemeId: 7,
    GalleryName: "Przestrzeń Elektrownia Opadowa",
    from: "2023-05-04",
    till: "2023-05-05",
  },
  {
    MemeId: 6,
    GalleryName: "Przestrzeń Elektrownia Opadowa",
    from: "2023-04-08",
    till: "2023-07-02",
  },
  {
    MemeId: 5,
    GalleryName: "Przestrzeń Elektrownia Opadowa",
    from: "2023-03-02",
    till: "2023-04-01",
  },
  {
    MemeId: 5,
    GalleryName: "Przestrzeń Elektrownia Opadowa",
    from: "2023-10-05",
    till: "2023-11-11",
  },
  {
    MemeId: 5,
    GalleryName: "Gmach Komisji Rządowej",
    from: "2024-02-14",
    till: "2024-03-29",
  },
  {
    MemeId: 5,
    GalleryName: "Gmach Komisji Rządowej",
    from: "2024-09-28",
    till: "2024-12-02",
  },
  {
    MemeId: 4,
    GalleryName: "Gmach Komisji Rządowej",
    from: "2022-10-14",
    till: "2022-12-05",
  },
  {
    MemeId: 4,
    GalleryName: "Gmach Komisji Rządowej",
    from: "2023-05-18",
    till: "2023-06-23",
  },
  {
    MemeId: 3,
    GalleryName: "Przestrzeń Elektrownia Opadowa",
    from: "2023-04-30",
    till: "2023-07-04",
  },
  {
    MemeId: 3,
    GalleryName: "Galeria Przemyśleń i Obserwacji",
    from: "2023-08-06",
    till: "2023-11-11",
  },
  {
    MemeId: 3,
    GalleryName: "Gmach Komisji Rządowej",
    from: "2023-12-25",
    till: "2024-03-17",
  },
  {
    MemeId: 3,
    GalleryName: "Przestrzeń Elektrownia Opadowa",
    from: "2024-08-16",
    till: "2024-11-10",
  },
  {
    MemeId: 3,
    GalleryName: "Gmach Komisji Rządowej",
    from: "2025-02-14",
    till: "2025-02-27",
  },
  {
    MemeId: 3,
    GalleryName: "Przestrzeń Elektrownia Opadowa",
    from: "2025-08-04",
    till: "2025-08-10",
  },
  {
    MemeId: 3,
    GalleryName: "Galeria Ezoterycznych Obrazków Zabawnych",
    from: "2025-09-19",
    till: "2025-11-21",
  },
  {
    MemeId: 3,
    GalleryName: "Galeria Ezoterycznych Obrazków Zabawnych",
    from: "2026-01-20",
    till: "2026-02-18",
  },
  {
    MemeId: 3,
    GalleryName: "Przestrzeń Obrazowotwórcza",
    from: "2026-07-30",
    till: "2026-09-24",
  },
  {
    MemeId: 3,
    GalleryName: "Przestrzeń Elektrownia Opadowa",
    from: "2027-03-24",
    till: "2027-04-08",
  },
];

console.log("Wstawiam wystawienia...");

for (const d of staticDisplays) {
  await Display.create(d);
}

console.log("Wstawione.");

await sequelize.close();
