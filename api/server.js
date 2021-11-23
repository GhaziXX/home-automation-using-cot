const express = require("express")
const morgan = require("morgan")
const cors = require("cors")
const connectDB = require("./config/db")
const tlsconfig = require("./config/securityconfig")
const passport = require("passport")
const bodyParser = require("body-parser")
const routes = require("./routes/index")

const tls = require('spdy'); // HTTP2 + HTTPS (HTTP2 over TLS)
const fs = require('fs');
let helmet = require('helmet');


const options = {
    key: fs.readFileSync(tlsconfig["key-file"]),
    cert: fs.readFileSync(tlsconfig["cert-file"]),
    dhparam: fs.readFileSync(tlsconfig["dh-strongfile"])
}

connectDB()

const app = express()

app.use(cors())
app.use(bodyParser.urlencoded({extended: false}))
app.use(bodyParser.json())
app.use(routes)
app.use(passport.initialize())
require("./config/passport")(passport)
app.use(helmet())


if(process.env.NODE_ENV === 'development')
{
    app.use(morgan('dev'))
}

const PORT = process.env.PORT || 3000


const server = tls.createServer(options, app)
server.listen(PORT, console.log(`Server running in ${process.env.NODE_ENV} mode on port ${PORT}`))