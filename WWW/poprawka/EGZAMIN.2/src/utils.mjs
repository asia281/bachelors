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
  return process.env.WWW2022_DB ? process.env.WWW2022_DB : str;
}

export { getDbString };
