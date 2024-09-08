import { DataTypes } from "sequelize";

/**
 * Tworzy modele.
 *
 * @param {Sequelize} sequelize - instancja klasy Sequelize do stworzenia modeli
 */
function defineModels(sequelize) {
  const Planet = sequelize.define(
    "Planet",
    {
      name: {
        type: DataTypes.STRING(128),
        allowNull: false,
        primaryKey: true,
      },
      imageUrl: {
        type: DataTypes.STRING(1024),
        allowNull: false,
      },
      docksA: DataTypes.INTEGER,
      docksB: DataTypes.INTEGER,
      docksC: DataTypes.INTEGER,
    },
    {
      timestamps: false,
    }
  );

  const Spaceship = sequelize.define(
    "Spaceship",
    {
      name: {
        type: DataTypes.STRING(128),
        allowNull: false,
        primaryKey: true,
      },
      class: {
        type: DataTypes.STRING(1),
        allowNull: false,
      },
    },
    {
      timestamps: false,
    }
  );

  const Stopover = sequelize.define(
    "Stopover",
    {
      from: DataTypes.BIGINT,
      till: DataTypes.BIGINT,
    },
    {
      timestamps: false,
    }
  );

  Stopover.belongsTo(Planet);
  Planet.hasMany(Stopover);

  Stopover.belongsTo(Spaceship);
  Spaceship.hasMany(Stopover);

  return { Planet, Spaceship, Stopover };
}

export default defineModels;
