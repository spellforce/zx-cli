import { Command } from 'commander';
import chalk from 'chalk';

export default(methodName, log) => {
  Command.prototype[methodName] = function(...args) {
    if (methodName === 'unknownOption' && this._allowUnknowOption) {
      return false;
    }
    this.outputHelp();
    console.log();
    console.log(chalk.red(log(...args)));
    console.log();
    process.exit(1);
  };
};