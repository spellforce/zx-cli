import { execSync } from 'child_process';
import semver from 'semver';
import inquirer from'inquirer';
import { createRequire } from "module";
const require = createRequire(import.meta.url);
const currentVerison = require('../package.json').version;

const release = async () => {
  console.log(`Current zx cli version is ${currentVerison}`);
  const releaseActions = ['patch', 'minor', 'major'];
  const versions = {};
  //  生成预发布版本标示
  releaseActions.map(r => (versions[r] = semver.inc(currentVerison, r)));
  const releaseChoices = releaseActions.map(r => ({
    name: `${r} (${versions[r]})`,
    value: r
  }));
  // 选择发布方式
  const { release, isCommit } = await inquirer.prompt([
    {
      name: 'release',
      message: 'Select a release type',
      type: 'list',
      choices: [...releaseChoices]
    },
    {
      name: 'isCommit',
      message: 'Confirm whether to submit the code',
      type: 'confirm'
    }
  ]);
  // 优先自定义版本
  // const version = versions[release];

  if (isCommit) {
    const { message } = await inquirer.prompt([
      {
        name: 'message',
        message: 'Write your commit message',
        type: 'input'
      }
    ]);
    execSync(`git add . && git commit -m "[Upgrade ${release}] ${message}" && git push`, {
      stdio: 'inherit'
    });
    execSync(`npm version ${release}`, {
      stdio: 'inherit'
    });
  } else {
    execSync(`npm version ${release} --no-git-tag-version`, {
      stdio: 'inherit'
    });
  }
};

release().catch(err => {
  console.error(err);
  process.exit(1);
});