const express = require('express');
const app = express();
const bodyParser = require('body-parser');
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({extended: true}))

const path = require('path');

//connect to all databases
require('./connection.pools')();
require('../identity/models/identity.schema');
require('../identity/controllers/iam.provider');

const SecurityRouter = require('../security/routes.config');
const IdentityRouter = require('../identity/routes.config');

//bind routes to the express application
SecurityRouter.routesConfig(app);
IdentityRouter.routesConfig(app);

// Export the express application
module.exports = app;