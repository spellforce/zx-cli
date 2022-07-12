#!/usr/bin/env node

import { program } from 'commander';
import chalk from 'chalk';
import didYouMean from 'didyoumean';
import inquirer from 'inquirer';
import process from 'process';
import path from 'path';
import ora from 'ora';
import { createRequire } from "module";
import { fileURLToPath } from 'url';
import childProcess from 'child_process';
import fs from "fs-extra";
const require = createRequire(import.meta.url);
const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
const packageInfo = require("../package.json");
import prettyErrorMessages from '../utils/prettyErrorMessages.js';

didYouMean.threshold = 0.6;

const templateDir = path.join(__dirname, "../templates");

const getTemplatePath = (p, results = []) => {
  const temp = p;
  const flag = fs.existsSync(path.join(temp, "README.md"));
  
  if (flag) {
    results.push(temp);
    return results;
  } else {
    const paths = fs.readdirSync(temp);
    const arr = paths.map(pa => getTemplatePath(path.join(temp, pa), results));
    results.concat(arr);
    return results;
  }
};

const path2obj = (source, result, count = 0) => {
  if (source.length - 1 === count) {
    result[source[count]] = "This is a template.";
  }else {
    result[source[count]] = result[source[count]] || {};
    path2obj(source, result[source[count]], count + 1)
  }
};

const getTemplateObject = () => {
  const paths = getTemplatePath(templateDir);
  let result = {};
  paths.map(item => {
    const temp = item.replace(templateDir + path.sep, "");
    const tempArr = temp.split(path.sep);
    
    path2obj(tempArr, result);
  });
  return result;
};

// By zx，convert Json to Inquirer
const generateInquirer = async (templates, result = []) => {
  const choices = Object.keys(templates);
  const answer = await inquirer.prompt([{
    type: 'list',
    name: 'language',
    message: '>>',
    choices: choices
  }]);
  result.push(answer.language);
  if (templates[answer.language] instanceof Object) {
    await generateInquirer(templates[answer.language], result)
  }
  return result;
}

const checkUpdate = (isShow) => {
  const spinner = ora('Checking').start();
  const result = childProcess.spawnSync("npm", ["update", "-g", "zx-cli"], {
    // stdio: 'inherit', 当前进程和子进程联通
    shell: process.platform === 'win32'
  });
  
  if (result.error) {
    spinner.fail("Check finished");
    isShow && console.error(result.error);
  } else {
    spinner.succeed("Check finished");
    isShow && console.log(String(result.stdout));
  }
}
// console.dir(getTemplateObject());

program
  .version(packageInfo.version, '-v, --version') // version
  .usage('<command> [options]'); // usage info

// Initialize the project template
program
  .command('create')
  .description('create a new project from a template')
  .action(async () => {
    try {
      checkUpdate(false);
      const templates = getTemplateObject(); // template json
      const result = await generateInquirer(templates);
      const templatePath = path.resolve(templateDir, result.join('/'));
      fs.copySync(templatePath, './');
      console.log(chalk.green('Create successed!'));
    } catch (err) {
      console.error(err);
    }
  });

program
  .command('list')
  .description('list all available project template')
  .action(() => {
    const templates = getTemplateObject();
    console.log(chalk.green(JSON.stringify(templates, null, 2)));
  });

program
  .command('update')
  .description('update zx-cli tool')
  .action(() => {
    checkUpdate(true);
  });

// Handling illegal commands
program.arguments('<command>').action(cmd => {
  program.outputHelp();
  console.log();
  console.log(chalk.red(`Unknown command ${chalk.yellow(cmd)}.`));
  console.log();
  suggestCommands(cmd);
});

prettyErrorMessages('missingArgument', argsName => {
  return `Missing required argument ${chalk.yellow(`<${argsName}>`)}`;
});

if (!process.argv.slice(2).length) {
  program.outputHelp();
}

const suggestCommands = cmd => {
  const avaliableCommands = program.commands.map(cmd => {
    return cmd._name;
  });
  // Simple intelligent match user commands
  const suggestion = didYouMean(cmd, avaliableCommands);
  if (suggestion) {
    console.log(chalk.red(`Did you mean ${chalk.yellow(suggestion)}?`));
  }
}

// must have this, or commander will not work.
program.parse();