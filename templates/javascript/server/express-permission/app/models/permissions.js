const { Model, DataTypes } = require("sequelize");


module.exports = (sequelize) => {
  const attributes = {
    id: {
      type: DataTypes.BIGINT,
      allowNull: false,
      defaultValue: null,
      primaryKey: true,
      autoIncrement: true,
      comment: null,
    },
    kind: {
      type: DataTypes.STRING(255),
    },
    name: {
      type: DataTypes.STRING(255),
    },
    code: {
      type: DataTypes.STRING(255),
    },
    parent_id: {
      type: DataTypes.BIGINT,
    },
    description: {
      type: DataTypes.TEXT,
    },
    url: {
      type: DataTypes.STRING(255),
    },
    created_at: {
      type: DataTypes.DATE,
      allowNull: false,
      defaultValue: null,
      primaryKey: false,
      autoIncrement: false,
      comment: null,
      field: "created_at",
    },
    updated_at: {
      type: DataTypes.DATE,
      allowNull: false,
      defaultValue: null,
      primaryKey: false,
      autoIncrement: false,
      comment: null,
      field: "updated_at",
    },
  };
  
  class Permission extends Model {}

  Permission.init(attributes, { sequelize, tableName: "permissions" });
  // const UsersModel = sequelize.define("users_model", attributes, options);

  return Permission;
};
