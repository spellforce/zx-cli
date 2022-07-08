// 引入Express模块
const express = require('express');

// 创建应用程序
const app = express();

app.use('/public', express.static('public'));
// 处理用户请求
// use() 使用的整体就是所谓的中间件
app.use((req, res) => {

    // res.send('<h1>首页</h1>');
    res.send({
        name: '小城',
        age: 23
    })
});

app.listen(3000, () => console.log('Server port 3000 at start ....'));