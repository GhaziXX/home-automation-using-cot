#!/usr/bin/env node
const app  = require('./app');
const config = require('./env.config');
const debug = require("debug")('phoenix:server');
//config.initRefreshSecret();
const tls = require('spdy'); // HTTP2 + HTTPS (HTTP2 over TLS)
const fs = require('fs');
let helmet = require('helmet');

const key_file = process.env.KEY_FILE || config["key-file"]
const cert_file = process.env.CERT_FILE || config["cert-file"]
const dh_strongfile = process.env.DH_STRONGFILE || config["dh-strongfile"]

const options = {
    key: fs.readFileSync(key_file),
    cert: fs.readFileSync(cert_file),
    dhparam: fs.readFileSync(dh_strongfile)
}
app.use(helmet());
app.use(function(req,resp,next){
    if (req.method =="OPTIONS")
    {
        req.header["Access-Control-Allow-Origin"] = "*";
        req.header["Access-Control-Allow-Headers"] = "Special-Request-Header";
        req.header["Access-Control-Allow-Methods"] = ["GET","PUT","POST","PATCH","DELETE"];
        req.header["Access-Control-Allow-Credentials"] = true;

        resp.sendStatus(200);
    }else
    {
        next();
    }
});

const server = tls.createServer(options, app);
const PORT = process.env.PORT || 3000

server.listen(PORT, (error) => {
    if (error)
    {
        console.log("An error occured",error);
    }else
    {
        console.log("Succesfully connected");
    }
  });
