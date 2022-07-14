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
const User = require("../models/user");
const promisify = require("bluebird").promisify;

const getUsers = async (req, res) => {
  try {
    const models = req.app.config.databaseGroups[`${env}`].uo.models;
    let result = await User.getUsers({ params: req.body, models });
    res.send({
      meta: {
        code: 200,
        message: "success"
      },
      data: result
    });
  } catch (err) {
    logger.error(`getUsers error: ${err}`);
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
    let result = await User.destroy({ params: req.body, models });
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
    let result = await User.create({ params: req.body, models });
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
    let result = await User.update({ params: req.body, models });
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

const lock = async (req, res) => {
  try {
    const models = req.app.config.databaseGroups[`${env}`].uo.models;
    let result = await User.lock({ params: req.body, models });
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

const unlock = async (req, res) => {
  try {
    const models = req.app.config.databaseGroups[`${env}`].uo.models;
    let result = await User.unlock({ params: req.body, models });
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

const approve = async (req, res) => {
  try {
    const models = req.app.config.databaseGroups[`${env}`].uo.models;
    let result = await User.approve({ params: req.body, models });
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

const resetPassword = async (req, res) => {
  const models = req.app.config.databaseGroups[`${env}`].uo.models; //.models;
  let result = await User.resetPassword(req.body, models, req.permission);
  res.status(200).send(result);
};

const updatePassword = async (req, res) => {
  const models = req.app.config.databaseGroups[`${env}`].uo.models; //.models;
  let result = await User.updatePassword(req.body, models, req.permission);
  res.status(200).send(result);
};

const getUser = async (req, res) => {
  const models = req.app.config.databaseGroups[`${env}`].uo.models; //.models;
  let result = await User.getUser(req.body, models, req.permission);
  res.status(200).send(result);
};

const saveRole = async (req, res) => {
  const models = req.app.config.databaseGroups[`${env}`].uo.models; //.models;
  let result = await User.saveRole(req.body, models, req.permission);
  res.status(200).send(result);
};

const test = async (req, res) => {
  const models = req.app.config.databaseGroups[`${env}`].uo.models; //.models;
  let result = await User.test(req.body, models);
  res.status(200).send(result);
};

const signIn = async (req, res) => {
  const models = req.app.config.databaseGroups[`${env}`].uo.models; //.models;
  let result = await User.signIn(req.body, models);
  if (result.meta.code == 200) {
    res.cookie("token", result.data.token, {
      maxAge: 60 * 1000 * 60 * 4,
      httpOnly: true,
      secure: true,
      // signed: config.isUseCookieSign,
    });
    res.status(200).send({ ...result });
  } else {
    res.status(200).send(result);
  }
};

const getUserInfo = async (req, res) => {
  let result = await User.getUserInfo(req);
  res.status(200).send(result);
};

const logout = async (req, res) => {
  res.clearCookie("token");
  res.status(200).send({
    meta: {
      code: 200,
      message: "Logout successfully.",
    },
  });
};

const forgotPassword = async (req, res) => {
  const models = req.app.config.databaseGroups[`${env}`].uo.models;
  const body = req.body;
  if (body.user && body.user.email) {
    const userEmail = body.user.email;
    const domainConfig = body.InstanceConfigData;
    let result = await User.forgotPassword(models, userEmail, domainConfig);
    res.status(200).send(result);
  } else {
    res.status(200).send({
      meta: {
        code: 10400,
        message: "Invalid parameters",
      },
    });
  }

  // const promisifyForgotPassword = promisify(User.forgotPassword);
  // promisifyForgotPassword(models, userEmail, domainConfig)
  //   .then((result) => {
  //     res.status(200).send(result);
  //   })
  //   .catch((err) => {
  //     res.status(500).send(err);
  //   });
};

const resetPasswordByEmail = async (req, res) => {
  const body = req.body;
  const domainConfig = body.InstanceConfigData;


  const models = req.app.config.databaseGroups[`${env}`].uo.models; //.models;
  let result = await User.resetPasswordByEmail(req.body, models, domainConfig);
  res.status(200).send(result);
};



module.exports = {
  forgotPassword,
  resetPasswordByEmail,
  getUsers,
  destroy,
  create,
  lock,
  unlock,
  approve,
  resetPassword,
  getUser,
  saveRole,
  update,
  test,
  signIn,
  getUserInfo,
  logout,
  updatePassword,
};
