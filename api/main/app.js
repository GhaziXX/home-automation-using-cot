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
require('dotenv').config()

//connect to all databases
require('./connection.pools')();
require('../identity/models/identity.schema');
require('../mqtt/models/connectedObject.schema');
require('../identity/controllers/iam.provider');

const SecurityRouter = require('../security/routes.config');
const IdentityRouter = require('../identity/routes.config');
const MqttRouter = require("../mqtt/routes.config");

//bind routes to the express application
SecurityRouter.routesConfig(app);
IdentityRouter.routesConfig(app);
MqttRouter.routesConfig(app);

// Export the express application
module.exports = app;