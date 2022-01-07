const Maps = require("./controller/maps.provider");
const passport = require('passport');
const AuthorizationPermission = require('../security/authorization/authorization.permission');
const MapsPermission = require("./controller/maps.checker");
const config = require('../main/env.config');
const Master = config.permissionLevels.Master;

exports.routesConfig = function (app) {
    
    app.get('/getLocation', [
        Maps.getLocation
    ]);

    app.post('/setLocation', [
        passport.authenticate('jwt', {
            session: false
        }),
        AuthorizationPermission.minimumPermissionLevelRequired(Master),
        MapsPermission.IsAvailable,
        Maps.updateLocation
    ]);
}