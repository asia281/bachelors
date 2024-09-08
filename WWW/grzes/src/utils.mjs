/**
 * Zmienia parametr database konstruktora Sequelize
 *
 * Funkcja służy do modyfikacji argumentu database postaci `postgres://user:iks@lkdb:5432/bd`,
 * podstawiając zamiast niego inną wartość jeśli w środowisku jest zdefiniowana zmienna
 * `WWW2022_DB`.
 *
 * @param {string} str - napis przekazywany do konstruktora Sequelize
 */

function getDbString(str) {
  console.log(process.env.WWW2022_DB ? process.env.WWW2022_DB : str);
  return process.env.WWW2022_DB ? process.env.WWW2022_DB : str;
}

const stopoverCmp = (a, b) =>
  a.from !== b.from ? a.from - b.from : a.till - b.till;

const rnd = (max) => Math.floor(Math.random() * max);

/**
 * Sprawdza, czy statek kosmiczny może się zatrzymać na planecie w wybranych terminach.
 *
 * Dokładniej sprawdza dostępność doku w podanych terminach i czy statek nie ma już
 * zaplanwanych postojów nakładających się na sprawdzany.
 *
 * Sprawdza tylko, czy daty są zajęte - nie próbuje ustalić, czy stopover odnosi się do
 * istniejącego statku czy planety, tym bardziej czy jako argumenty zostały dostarczone
 * pasujące statek i planeta.
 *
 * @param {Stopover} stopover - stopover, który ma być sprawdzony
 * @param {Stopover[]} shipsStopovers - pozostałe stopovers dla tego statku kosmicznego
 * @param {Stopover[]} planetsStopovers - stopovers dla tej planety, dla doku właściwej wielkości
 * @param {Spaceship} ship - statek kosmiczny
 * @param {Planet} planet - planeta
 */
function stopoverPossible(
  stopover,
  shipsStopovers,
  planetsStopovers,
  ship,
  planet
) {
  // 1. Czy w ogóle jest poprawny?
  if (stopover.from >= stopover.till) return false;

  // 2. Czy statek ma w tym czasie wolne?
  for (const so of [...shipsStopovers].sort(stopoverCmp)) {
    if (so.from > stopover.till) break;
    if (
      (so.from <= stopover.from && so.till >= stopover.from) ||
      (stopover.from <= so.from && stopover.till >= so.from)
    )
      return false;
  }

  // 3. trzeba sprawdzić miejsce na planecie
  // 3a. czy w ogóle są takie doki?
  const cls = ship.class;
  let docksCnt = planet[`docks${cls}`];
  if (docksCnt === 0) return false;

  // 3b. a teraz sprawdźmy, czy przez cały czas stopoveru co najmniej jeden dok jest wolny
  const docksUsage = [];
  for (const so of planetsStopovers) {
    docksUsage.push([so.from, -1], [so.till, 1]);
  }
  docksUsage.push([stopover.from, 0], [stopover.till, 0]);
  docksUsage.sort((a, b) => (a[0] - b[0] ? a[0] - b[0] : a[1] - b[1]));
  for (const [t, diff] of docksUsage) {
    docksCnt += diff;
    if (t > stopover.till) break;
    if (t >= stopover.from && docksCnt === 0) return false;
  }

  return true;
}

export { getDbString, rnd, stopoverCmp, stopoverPossible };
