# zx-cli
Personal cli tool

To facilitate build project startup

## 教程

```
npm install -g spellforce-zx-cli
zx-cli create
```

```
Usage: zx-cli <command> [options]

Options:
  -v, --version  output the version number
  -h, --help     display help for command

Commands:
  create         create a new project from a template
  list           list all available project template
  update         update zx-cli tool
```
## Q&F

### 更新模版还需要改代码吗？
不需要，cli自动遍历模版文件，inquirer也是动态的.
只需要在模版文件夹中加模版就行，无需另外操作

### 怎么保证每次的模版都是新的？
1. 每次运行自动检查版本，有更新先自己更新

### 为什么不是远程模版和远程拷贝，这样就不需要再更新cli了？
1. clone下来之后再操作，比每次遍历线上repo目录要快，更方便
2. 自己使用，不需要太过麻烦
3. 断网也能用

### 个别模版需要初始化怎么办？
在模版文件夹下面建立自己的init.js文件，里面写自己的初始化脚本，每个语言都是这样