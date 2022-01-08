const express = require('express');
const app = express();
const bodyParser = require('body-parser');
const cors = require('cors');
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({
    extended: true
}))
app.use(cors());
const path = require('path');
require('dotenv').config();
app.use(express.static(__dirname +'/web'));
//set default message
app.get('/', (req, res) => {
    console.log(req.subdomains);
    if (req.subdomains.includes('api')) {
        res.status(401).send({
            message: 'You do not have access rights'
        });
        return;
    }
    res.sendFile(__dirname + '/web/index.html');
});
//connect to all databases
require('./connection.pools')();
require('../identity/models/identity.schema');
require('../mqtt/models/connectedObject.schema');
require('../maps/models/maps.schema')
require('../identity/controllers/iam.provider');

const SecurityRouter = require('../security/routes.config');
const IdentityRouter = require('../identity/routes.config');
const MqttRouter = require("../mqtt/routes.config");
const MapsRouter = require("../maps/routes.config");

//bind routes to the express application
SecurityRouter.routesConfig(app);
IdentityRouter.routesConfig(app);
MqttRouter.routesConfig(app);
MapsRouter.routesConfig(app);

// Export the express application
module.exports = app;