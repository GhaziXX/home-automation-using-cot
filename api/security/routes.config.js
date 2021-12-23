const IdentityChecker = require('./authentication/identity.checker');
const Authenticator = require('./authentication/authentication.handler');
const Validator = require('./authorization/authorization.validation');
const Authorization = require('../security/authorization/authorization.permission');
const config = require('../main/env.config');
const passport = require('passport');

const Master = config.permissionLevels.Master;

exports.routesConfig = function (app) {
    app.post('/auth/signin', [
        //passport.authenticate('signIn', { session: false }),
        IdentityChecker.hasAuthValidFields,
        IdentityChecker.isPasswordAndUserMatch,
        Authenticator.login
    ]);
    
    app.post('/auth/refresh', [
        Validator.validJWTNeeded,
        Validator.verifyRefreshBodyField,
        Validator.validRefreshNeeded,
        IdentityChecker.isUserStillExistsWithSamePrivileges,
        Authenticator.refresh_token
    ]);

    app.put('/auth/revokeIssuedRefreshTokens',[
        Validator.validJWTNeeded,
        Authorization.minimumPermissionLevelRequired(Master),
        Authenticator.resetRefreshSecret
    ]);
};