const {
  DataTypes
} = require('sequelize');
const ApplicationRecord = require("./application");

module.exports = sequelize => {
  const attributes = {
    id: {
      type: DataTypes.BIGINT,
      allowNull: false,
      defaultValue: null,
      primaryKey: true,
      autoIncrement: true,
      comment: null,
      field: "id"
    },
    name: {
      type: DataTypes.STRING(255),
      allowNull: true,
      defaultValue: null,
      primaryKey: false,
      autoIncrement: false,
      comment: null,
      field: "name"
    },
    created_at: {
      type: DataTypes.DATE,
      allowNull: false,
      defaultValue: null,
      primaryKey: false,
      autoIncrement: false,
      comment: null,
      field: "created_at"
    },
    updated_at: {
      type: DataTypes.DATE,
      allowNull: false,
      defaultValue: null,
      primaryKey: false,
      autoIncrement: false,
      comment: null,
      field: "updated_at"
    }
  };
  const options = {
    sequelize,
    tableName: "roles",
    comment: "",
    timestamps: true,
    indexes: [{
      name: "index_roles_on_name",
      unique: false,
      type: "BTREE",
      fields: ["name"],
      timestamps: false
    }],
    createdAt: 'created_at',
    updatedAt: 'updated_at', 
  };

  class Role extends ApplicationRecord {
    static _model = Role;

    static search({ search }) {
      const filter = search || {};
      const where = {};
      if (filter.name) {
        where.email = {
          [Op.like]: "%" + filter.name + "%",
        };
      }

      if (filter.code) {
        where.username = {
          [Op.like]: "%" + filter.code + "%",
        };
      }

      return where;
    }
  }

  Role.init(attributes, options);
  return Role;
};