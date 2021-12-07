const IdentityChecker = require('./authentication/identity.checker');
const Authenticator = require('./authentication/authentication.handler');
const Validator = require('./authorization/authorization.validation');
const Authorization = require('../security/authorization/authorization.permission');
const config = require('../main/env.config');

const Master = config.permissionLevels.Master;
const Member = config.permissionLevels.Member;
const Surfer = config.permissionLevels.Surfer;

exports.routesConfig = function (app) {
    app.post('/auth/signin', [
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