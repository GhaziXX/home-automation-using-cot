const IdentityProvider = require('./controllers/identity.provider');
const AuthorizationPermission = require('../security/authorization/authorization.permission');

const  passport = require('passport'),
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
    app.post('/users',
        [
            passport.authenticate('signUp', { session: false }),
            async (req, res, next) => {
                res.location('/users/' + req.user._id);
                res.status(201).send(req.user);
            }
        ]
        
    );
    app.post('/auth/signup',
        [
            IdentityProvider.signUp
        ]
    );

    app.get('/users', [
        passport.authenticate('jwt', { session: false }, ()=>{}),
        AuthorizationPermission.minimumPermissionLevelRequired(Member),
        IdentityProvider.list
    ]);
    app.get('/users/:userId', [
        passport.authenticate('jwt', { session: false }, ()=>{}),
        AuthorizationPermission.minimumPermissionLevelRequired(Surfer),
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
        passport.authenticate('jwt', { session: false }, ()=>{}),
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
    app.post('/oauth/token',
        async (req, res, next) => {
            passport.authenticate(
                'signIn',
                async (err, user, info) => {
                    try {
                        if (err || !user) {
                            return next(err);
                        }
                        req.login(
                            user,
                            { session: false },
                            async (error) => {
                                if (error) return next(error);
                                const now = Math.floor(Date.now() / 1000),
                                    body = {
                                        iss: iss,
                                        aud: aud,
                                        sub: user.username,
                                        name: user.fullName,
                                        userId: user._id,
                                        roles: user.permissionLevel,
                                        jti: uuidv4(),
                                        iat: now,
                                        exp: now+validityTime
                                    };
                                const token = jwt.sign({ user: body }, privateKey,{ algorithm: 'RS512'});

                                return res.json({ token });
                            }
                        );
                    } catch (error) {
                        return next(error);
                    }
                }
            )(req, res, next);
        }
    );
};