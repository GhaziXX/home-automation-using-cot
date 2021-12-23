const IdentityProvider = require('./controllers/identity.provider');
const AuthorizationPermission = require('../security/authorization/authorization.permission');
const AuthorizationValidator =require("../security/authorization/authorization.validation.js")

const  passport = require('passport'),
        IdentityModel = require('./models/identity.model'),
        jwt = require('jsonwebtoken'),
        {v4: uuidv4 } = require('uuid'),
        config = require('../main/env.config');
        privateKey = fs.readFileSync(process.env.JWT_KEY || config['jwt-key']),
        iss = 'urn:homeautomationcot.me',
        aud = 'urn:*.homeautomationcot.me'

const       Master = config.permissionLevels.Master,
            Member = config.permissionLevels.Member,
            Surfer = config.permissionLevels.Surfer,
            validityTime = process.env.JWT_VALIDITY_TIME_IN_SECONDS || config.jwtValidityTimeInSeconds;

exports.routesConfig = function (app) {
    app.post('/auth/signup',
        [
            passport.authenticate('signUp', { session: false }),
            async (req, res, next) => {
                res.location('/users/' + req.user._id);
                res.status(201).send({"id":req.user["id"]});
            }
        ]
    );
    
    app.get('/users', [
        passport.authenticate('jwt', { session: false }), 
        AuthorizationPermission.minimumPermissionLevelRequired(Master),
        IdentityProvider.list
        
    ]);

    app.get('/profile', [
        passport.authenticate('jwt', { session: false }), 
        AuthorizationPermission.minimumPermissionLevelRequired(Master),
        IdentityProvider.getProfileById
        
    ]);

    app.get('/users/:userId', [
        passport.authenticate('jwt', { session: false }), 
        AuthorizationPermission.onlySameUserOrAdminCanDoThisAction,
        IdentityProvider.getById
    ]);

    /**
     * In a PUT request, the enclosed entity is considered to be
     * a modified version of the resource stored on the origin server,
     * and the client is requesting that the stored version be replaced.
     * So all the attributes are to be updated!
     * Thus this is a privileged action done only by administrator
     */
    app.put('/users/:userId', [
        passport.authenticate('jwt', { session: false }),
        AuthorizationPermission.minimumPermissionLevelRequired(Master),
        AuthorizationPermission.sameUserCantDoThisAction,
        IdentityProvider.putById
    ]);

    /**
     * PATCH specifies that the enclosed entity contains a set of instructions describing
     * how a resource currently residing on the origin server should be modified to produce a new version.
     * So, some attributes could or should remain unchanged.
     * In our case, a regular user cannot change permissionLevel!
     * Thus only same user or admin can patch without changing identity permission level.
     */
    app.patch('/users/:userId', [
        passport.authenticate('jwt', { session: false }, ()=>{}),
        AuthorizationPermission.minimumPermissionLevelRequired(Surfer),
        AuthorizationPermission.onlySameUserOrAdminCanDoThisAction,
        IdentityProvider.patchById
    ]);
    app.delete('/users/:userId', [
        passport.authenticate('jwt', { session: false }, ()=>{}),
        AuthorizationPermission.minimumPermissionLevelRequired(Master),
        AuthorizationPermission.sameUserCantDoThisAction,
        IdentityProvider.removeById
    ]);
/*
    app.post('/authorize', async (req,res,next) => {
        //TODO add PKCE FLOW

    });
*/
};