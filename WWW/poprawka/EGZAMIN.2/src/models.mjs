import { DataTypes } from "sequelize";

/**
 * Tworzy modele.
 *
 * @param {Sequelize} sequelize - instancja klasy Sequelize do stworzenia modeli
 */
function defineModels(sequelize) {
  const Meme = sequelize.define(
    "Meme",
    {
      id: {
        type: DataTypes.INTEGER,
        allowNull: false,
        primaryKey: true,
        autoIncrement: true,
      },
      title: {
        type: DataTypes.STRING(128),
        allowNull: false,
      },
      imageUrl: {
        type: DataTypes.STRING(1024),
        allowNull: false,
      },
      description: DataTypes.TEXT,
    },
    {
      timestamps: false,
    }
  );

  const Gallery = sequelize.define(
    "Gallery",
    {
      name: {
        type: DataTypes.STRING(128),
        allowNull: false,
        primaryKey: true,
      },
      address: DataTypes.STRING(128),
    },
    {
      timestamps: false,
    }
  );

  const Display = sequelize.define(
    "Display",
    {
      from: DataTypes.DATEONLY,
      till: DataTypes.DATEONLY,
    },
    {
      timestamps: false,
    }
  );

  Display.belongsTo(Meme);
  Meme.hasMany(Display);

  Display.belongsTo(Gallery);
  Gallery.hasMany(Display);

  return { Meme, Gallery, Display };
}

export default defineModels;
