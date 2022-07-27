const spdy = require("spdy") // https://github.com/spdy-http2/node-spdy
const express = require("express")
const fs = require("fs")

const app = express()

app.use(express.static("public"))

app.get("/push", async (req, res) => {
  try {
    if(res.push){
      // push 一个url，下次浏览器访问时，会直接拿到
      const stream = res.push("/push.css", {});
      stream.on('acknowledge', function() {
        console.log('stream ACK');
      });
      stream.on('error', function() {
        console.log('stream ERR');
       });
      stream.end('alert("stream SUCCESSFUL");');
    }

    res.end('<script src="/push.css"></script>')
  }catch(error){
    res.status(500).send(error.toString())
  }
});

// 此证书需要chrome点击空白处输入thisisunsafe
const credentials = {
  key: fs.readFileSync(__dirname + '/server.key'),
  cert: fs.readFileSync(__dirname + '/server.crt'),
};
// use https, because browser no secure server 
spdy.createServer(credentials, app).listen(3001, (err) => {
  if(err){
    throw new Error(err)
  }
  console.log("Listening on port 3001")
})