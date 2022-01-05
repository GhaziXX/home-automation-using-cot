const IdentityChecker = require('./authentication/identity.checker');
const Authenticator = require('./authentication/authentication.handler');
const Validator = require('./authorization/authorization.validation');
const Authorization = require('../security/authorization/authorization.permission');
const config = require('../main/env.config');

const Master = config.permissionLevels.Master;

exports.routesConfig = function (app) {

    //// @params:
    //clientId#codeChallenge encoded to base64 and passed as pre-authorization header 
    //// @returns:
    //loginId, clienId, codeChallenge
    app.post('/oauth/presignin', [
        Authenticator.preLogin
    ]);

    //// @params:
    //email, password, loginId
    //// @returns:
    //authorizationCode
    app.post('/oauth/signin', [
        IdentityChecker.hasAuthValidFields,
        IdentityChecker.isPasswordAndUserMatch,
        Authenticator.login
    ]);

    //// @params:
    //authorizationCode#codeVerifier encoded to base64 and passed as post-authorization header 
    //// @returns:
    //accessToken, refreshToken
    app.post('/oauth/token', [
        Authenticator.postLogin
    ]);

    //// @params:
    //accessToken by Header
    // refreshtoken
    //// @returns:
    //accessToken
    app.post('/oauth/refresh', [
        Validator.validJWTNeeded,
        Validator.verifyRefreshBodyField,
        Validator.validRefreshNeeded,
        IdentityChecker.isUserStillExistsWithSamePrivileges,
        Authenticator.refresh_token
    ]);

    //// @params:
    //accessToken by Header
    // refreshtoken
    //// @returns:
    app.put('/auth/revokeIssuedRefreshTokens', [
        Validator.validJWTNeeded,
        Authorization.minimumPermissionLevelRequired(Master),
        Authenticator.resetRefreshSecret
    ]);
};