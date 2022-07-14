/**
 * Case controller
 * @date: 2021/01/11
 */

"use strict";
const env = process.env.NODE_ENV || "development";
const label = process.env.LOG_LABEL || "local:dev";
const logger = require("../../../config/logger");
const emailAlertService = require("../../../lib/email-internal-alert");
const util = require("../../../lib/util/common");
const Role = require('../models/role');

const getAllRoles = async (req, res) => {
  try {
    const models = req.app.config.databaseGroups[`${env}`].uo.models;
    let result = await Role.getAllRoles({ params: req.body, models });
    res.send({
      meta: {
        code: 200,
        message: "success"
      },
      data: result
    });
  } catch (err) {
    logger.error(`getAllRoles error: ${err}`);
    res.status(500).send({
      meta: {
        code: 500,
        message: err.message
      },
    });
  }
};

const getRoles = async (req, res) => {
  try {
    const models = req.app.config.databaseGroups[`${env}`].uo.models;
    let result = await Role.getRoles({ params: req.body, models });
    res.send({
      meta: {
        code: 200,
        message: "success"
      },
      data: result
    });
  } catch (err) {
    logger.error(`getRoles error: ${err}`);
    res.status(500).send({
      meta: {
        code: 500,
        message: err.message
      },
    });
  }
};

const destroy = async (req, res) => {
  try {
    const models = req.app.config.databaseGroups[`${env}`].uo.models;
    let result = await Role.destroy({ params: req.body, models });
    res.send({
      meta: {
        code: 200,
        message: "success"
      },
      data: result
    });
  } catch (err) {
    logger.error(`destroy error: ${err}`);
    res.status(500).send({
      meta: {
        code: 500,
        message: err.message
      },
    });
  }
};

const create = async (req, res) => {
  try {
    const models = req.app.config.databaseGroups[`${env}`].uo.models;
    let result = await Role.create({ params: req.body, models });
    res.send({
      meta: {
        code: 200,
        message: "success"
      },
      data: result
    });
  } catch (err) {
    logger.error(`create error: ${err}`);
    res.status(500).send({
      meta: {
        code: 500,
        message: err.message
      },
    });
  }
};

const update = async (req, res) => {
  try {
    const models = req.app.config.databaseGroups[`${env}`].uo.models;
    let result = await Role.update({ params: req.body, models });
    res.send({
      meta: {
        code: 200,
        message: "success"
      },
      data: result
    });
  } catch (err) {
    logger.error(`update error: ${err}`);
    res.status(500).send({
      meta: {
        code: 500,
        message: err.message
      },
    });
  }
};

const getRelatedPermission = async (req, res) => {
  try {
    const models = req.app.config.databaseGroups[`${env}`].uo.models;
    let result = await Role.getRelatedPermission({ params: req.body, models });
    res.send({
      meta: {
        code: 200,
        message: "success"
      },
      data: result
    });
  } catch (err) {
    logger.error(`getRelatedPermission error: ${err}`);
    res.status(500).send({
      meta: {
        code: 500,
        message: err.message
      },
    });
  }
};

module.exports = {
  getRoles,
  getAllRoles,
  destroy,
  create,
  update,
  getRelatedPermission,
};
