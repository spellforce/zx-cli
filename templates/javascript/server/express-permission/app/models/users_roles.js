const {
  DataTypes
} = require('sequelize');

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
    role_id: {
      type: DataTypes.INTEGER(11),
      allowNull: true,
      defaultValue: null,
      primaryKey: false,
      autoIncrement: false,
      comment: null,
      field: "role_id"
    },
    user_id: {
      type: DataTypes.INTEGER(11),
      allowNull: true,
      defaultValue: null,
      primaryKey: false,
      autoIncrement: false,
      comment: null,
      field: "user_id"
    },
    created_at: {
      type: DataTypes.DATE,
      allowNull: false,
    },
    updated_at: {
      type: DataTypes.DATE,
      allowNull: false,
    },
  };
  const options = {
    tableName: "users_roles",
    comment: "",
    indexes: [],
    timestamps: true,
    createdAt: 'created_at',
    updatedAt: 'updated_at', 
  };
  // const User = require('./users')(sequelize);
  // const Role = require('./roles')(sequelize);
  const UsersRole = sequelize.define("UsersRole", attributes, options);
  // UsersRole.User = UsersRole.belongsTo(User);
  // UsersRole.Role = UsersRole.belongsTo(Role);

  return UsersRole;
};