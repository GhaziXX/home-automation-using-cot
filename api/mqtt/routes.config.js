const Mqtt = require("./controller/mqtt.provider");
const ConnectedObject = require("./controller/connectedObject.provider");
const passport = require('passport');
const AuthorizationPermission = require('../security/authorization/authorization.permission');
const ConnectedObjectPermission = require("./controller/connectedObject.checker");
const config = require('../main/env.config');
const Master = config.permissionLevels.Master;

exports.routesConfig = function (app) {
    
    app.post('/mqtt/addObject', [
        passport.authenticate('jwt', {
            session: false
        }),
        AuthorizationPermission.minimumPermissionLevelRequired(Master),
        ConnectedObjectPermission.hasAddConnectedObjectValidFields,
        ConnectedObjectPermission.isSensorExists,
        Mqtt.addObject
    ]);

    app.post('/mqtt/removeObject', [
        passport.authenticate('jwt', {
            session: false
        }),
        AuthorizationPermission.minimumPermissionLevelRequired(Master),
        ConnectedObjectPermission.hasDeleteConnectedObjectValidFields,
        Mqtt.removeObject
    ]);

    app.post('/mqtt/setState', [
        passport.authenticate('jwt', {
            session: false
        }),
        ConnectedObjectPermission.hasSetValidFields,
        Mqtt.performSetAction
    ]);

    app.get('/mqtt/getState', [
        ConnectedObjectPermission.hasGetValidFields,
        Mqtt.performGetAction
    ]);

    app.get('/mqtt/listConnectedObjects', [
        ConnectedObject.list,
    ]);

    app.get('/mqtt/listRooms', [

        ConnectedObject.listRooms,
    ]);
}