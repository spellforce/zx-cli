#!/usr/bin/env node

import { program } from 'commander'; // command line tool
import chalk from 'chalk'; // pretty command line
import didYouMean from 'didyoumean';
import inquirer from 'inquirer';
import path from 'path';
import ora from 'ora';
import download from 'download-git-repo';
import { createRequire } from "module";
import { fileURLToPath } from 'url';
import fs from "fs";
const require = createRequire(import.meta.url);
const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
const packageInfo = require("../package.json");
// const enhanceErrorMessages = require('../lib/util/enhanceErrorMessages.js');

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
    result[source[count]] = "";
  }else {
    result[source[count]] = result[source[count]] || {};
    path2obj(source, result[source[count]], count + 1)
  }
};

const getTemplateObject = () => {
  const paths = getTemplatePath(templateDir);
  // console.log(paths)
  let result = {};
  paths.map(item => {
    const temp = item.replace(templateDir + "/", "");
    const tempArr = temp.split("/");
    
    path2obj(tempArr, result);
  });
  return result;
};

// zx自写插件，根据Json生成Inquirer
const generateInquirer = async (templates, result = []) => {
  const choices = Object.keys(templates);
  const answer = await inquirer.prompt([{
    type: 'list',
    name: 'language',
    message: 'Please select class',
    choices: choices
  }]);
  result.push(answer.language);
  if (templates[answer.language] !== ""){
    await generateInquirer(templates[answer.language], result)
  }
  return result;
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
    const templates = getTemplateObject();
    const result = await generateInquirer(templates);
    const templatePath = path.resolve(templateDir, result.join('/'));
    download('spellforce/zx-cli', 'templates/' + result.join('/'), function (err) {
      console.log(err ? 'Error' : 'Success')
    })
    console.log(templatePath)
    // 输入参数校验
    // validateArgsLen(process.argv.length, 5);
    // require('../lib/easy-create')(lowercase(templateName), projectName);
  });

// program
//   .command('create <template-name> <project-name>')
//   .description('create a new project from a template')
//   .action((templateName, projectName, cmd) => {
//     console.log(templateName, projectName, cmd)
//     // 输入参数校验
//     // validateArgsLen(process.argv.length, 5);
//     // require('../lib/easy-create')(lowercase(templateName), projectName);
//   });

// // 添加一个项目模板
// program
//   .command('add <template-name> <git-repo-address>')
//   .description('add a project template')
//   .action((templateName, gitRepoAddress, cmd) => {
//     validateArgsLen(process.argv.length, 5);
//     require('../lib/add-template')(lowercase(templateName), gitRepoAddress);
//   });

// 列出支持的项目模板
// program
//   .command('list')
//   .description('list all available project template')
//   .action(cmd => {
//     validateArgsLen(process.argv.length, 3);
//     require('../lib/list-template')();
//   });

// // 处理非法命令
// program.arguments('<command>').action(cmd => {
//   // 不退出输出帮助信息
//   program.outputHelp();
//   console.log(`  ` + chalk.red(`Unknown command ${chalk.yellow(cmd)}.`));
//   console.log();
//   suggestCommands(cmd);
// });

// // 重写commander某些事件
// // enhanceErrorMessages('missingArgument', argsName => {
// //   return `Missing required argument ${chalk.yellow(`<${argsName}>`)}`;
// // });



// // 输入easy显示帮助信息
// if (!process.argv.slice(2).length) {
//   program.outputHelp();
// }

// // // easy支持的命令
// function suggestCommands(cmd) {
//   const avaliableCommands = program.commands.map(cmd => {
//     return cmd._name;
//   });
//   // 简易智能匹配用户命令
//   const suggestion = didYouMean(cmd, avaliableCommands);
//   if (suggestion) {
//     console.log(`  ` + chalk.red(`Did you mean ${chalk.yellow(suggestion)}?`));
//   }
// }

// function lowercase(str) {
//   return str.toLocaleLowerCase();
// }

// function validateArgsLen(argvLen, maxArgvLens) {
//   if (argvLen > maxArgvLens) {
//     console.log(
//       chalk.yellow(
//         '\n Info: You provided more than argument. the rest are ignored.'
//       )
//     );
//   }
// }

program.parse(); // 把命令行参数传给commander解析