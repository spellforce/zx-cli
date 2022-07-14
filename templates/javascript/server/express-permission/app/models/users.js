const { DataTypes, Op } = require("sequelize");
const _ = require("lodash");
const ApplicationRecord = require("./application");

module.exports = (sequelize) => {
  const attributes = {
    id: {
      type: DataTypes.BIGINT,
      allowNull: false,
      defaultValue: null,
      primaryKey: true,
      autoIncrement: true,
      comment: null,
      field: "id",
    },
    email: {
      type: DataTypes.STRING(255),
      allowNull: false,
      defaultValue: "",
      primaryKey: false,
      autoIncrement: false,
      comment: null,
      field: "email",
      unique: "index_users_on_email",
    },
    encrypted_password: {
      type: DataTypes.STRING(255),
      allowNull: false,
      defaultValue: "",
      primaryKey: false,
      autoIncrement: false,
      comment: null,
      field: "encrypted_password",
    },
    reset_password_token: {
      type: DataTypes.STRING(255),
      allowNull: true,
      defaultValue: null,
      primaryKey: false,
      autoIncrement: false,
      comment: null,
      field: "reset_password_token",
      unique: "index_users_on_reset_password_token",
    },
    reset_password_sent_at: {
      type: DataTypes.DATE,
      allowNull: true,
      defaultValue: null,
      primaryKey: false,
      autoIncrement: false,
      comment: null,
      field: "reset_password_sent_at",
    },
    remember_created_at: {
      type: DataTypes.DATE,
      allowNull: true,
      defaultValue: null,
      primaryKey: false,
      autoIncrement: false,
      comment: null,
      field: "remember_created_at",
    },
    sign_in_count: {
      type: DataTypes.INTEGER(11),
      allowNull: false,
      defaultValue: "0",
      primaryKey: false,
      autoIncrement: false,
      comment: null,
      field: "sign_in_count",
    },
    current_sign_in_at: {
      type: DataTypes.DATE,
      allowNull: true,
      defaultValue: null,
      primaryKey: false,
      autoIncrement: false,
      comment: null,
      field: "current_sign_in_at",
    },
    last_sign_in_at: {
      type: DataTypes.DATE,
      allowNull: true,
      defaultValue: null,
      primaryKey: false,
      autoIncrement: false,
      comment: null,
      field: "last_sign_in_at",
    },
    current_sign_in_ip: {
      type: DataTypes.STRING(255),
      allowNull: true,
      defaultValue: null,
      primaryKey: false,
      autoIncrement: false,
      comment: null,
      field: "current_sign_in_ip",
    },
    last_sign_in_ip: {
      type: DataTypes.STRING(255),
      allowNull: true,
      defaultValue: null,
      primaryKey: false,
      autoIncrement: false,
      comment: null,
      field: "last_sign_in_ip",
    },
    username: {
      type: DataTypes.STRING(255),
      allowNull: true,
      defaultValue: null,
      primaryKey: false,
      autoIncrement: false,
      comment: null,
      field: "username",
      unique: "index_users_on_username",
    },
    active: {
      type: DataTypes.INTEGER(1),
      allowNull: false,
      defaultValue: "0",
      primaryKey: false,
      autoIncrement: false,
      comment: null,
      field: "active",
    },
    created_at: {
      type: DataTypes.DATE,
      allowNull: false,
    },
    updated_at: {
      type: DataTypes.DATE,
      allowNull: false,
    },
    failed_attempts: {
      type: DataTypes.INTEGER(11),
      allowNull: false,
      defaultValue: "0",
      primaryKey: false,
      autoIncrement: false,
      comment: null,
      field: "failed_attempts",
    },
    unlock_token: {
      type: DataTypes.STRING(255),
      allowNull: true,
      defaultValue: null,
      primaryKey: false,
      autoIncrement: false,
      comment: null,
      field: "unlock_token",
      unique: "index_users_on_unlock_token",
    },
    locked_at: {
      type: DataTypes.DATE,
      allowNull: true,
      defaultValue: null,
      primaryKey: false,
      autoIncrement: false,
      comment: null,
      field: "locked_at",
    },
    pass_changed: {
      type: DataTypes.DATE,
      allowNull: true,
      defaultValue: null,
      primaryKey: false,
      autoIncrement: false,
      comment: null,
      field: "pass_changed",
    },
    confirmation_token: {
      type: DataTypes.STRING(255),
      allowNull: true,
      defaultValue: null,
      primaryKey: false,
      autoIncrement: false,
      comment: null,
      field: "confirmation_token",
      unique: "index_users_on_confirmation_token",
    },
    confirmed_at: {
      type: DataTypes.DATE,
      allowNull: true,
      defaultValue: null,
      primaryKey: false,
      autoIncrement: false,
      comment: null,
      field: "confirmed_at",
    },
    confirmation_sent_at: {
      type: DataTypes.DATE,
      allowNull: true,
      defaultValue: null,
      primaryKey: false,
      autoIncrement: false,
      comment: null,
    },
    approved: {
      type: DataTypes.INTEGER(1),
      allowNull: true,
      defaultValue: "1",
      primaryKey: false,
      autoIncrement: false,
      comment: null,
    },
  };

  const options = {
    tableName: "users",
    comment: "",
    indexes: [],
    timestamps: false,
  };
  // const Permission = require('./permissions')(sequelize);
  // const Role = require('./roles')(sequelize);
  const UsersRole = require('./users_roles')(sequelize);

  class User extends ApplicationRecord {
    static _model = User;

    constructor(...args) {
      super(...args);
    }
    
    async getPermissions() {
      let permissions = [];
      const temp = await sequelize.query("SELECT `permissions`.`code`, `permissions`.`name` FROM `permissions` INNER JOIN `permissions_roles` ON `permissions_roles`.`permission_id` = `permissions`.`id` INNER JOIN `roles` ON `roles`.`id` = `permissions_roles`.`role_id` INNER JOIN `users_roles` ON `users_roles`.`role_id` = `roles`.`id` INNER JOIN `users` ON `users`.`id` = `users_roles`.`user_id` WHERE `users`.`email` = '" + this.email + "'")

      for (let i in temp) {
        for (let j in temp[i]) {
          permissions.push(temp[i][j]["code"]);
        }
      }

      return _.uniq(permissions);
    }
    
    static search({ search }) {
      const filter = search || {};
      const where = {};
      if (filter.email) {
        where.email = {
          [Op.like]: "%" + filter.email + "%",
        };
      }

      if (filter.username) {
        where.username = {
          [Op.like]: "%" + filter.username + "%",
        };
      }

      return where;
    }

    static async pageTable(params) {
      const result = await super.pageTable(params);

      for (let i in result.results) {
        const temp = await UsersRole.findAll({ where: { user_id: result.results[i]["id"] }});
        result.results[i]["dataValues"]["role_ids"] = temp.map(v => v.role_id);
      }
      return result;
    }

  }

  User.init(attributes, { sequelize, tableName: "users", 
    timestamps: true,
    createdAt: 'created_at',
    updatedAt: 'updated_at', 
  });
  User.sequelize = sequelize;
  // const UsersModel = sequelize.define("users_model", attributes, options);

  return User;
};
