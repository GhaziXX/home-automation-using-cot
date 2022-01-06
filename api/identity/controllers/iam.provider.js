const passport = require('passport'),
    LocalStrategy = require('passport-local').Strategy,
    JWTStrategy = require('passport-jwt').Strategy,
    ExtractJWT = require('passport-jwt').ExtractJwt,
    IdentityModel = require('../models/identity.model'),
    argon2 = require('argon2');
fs = require('fs'),
    config = require('../../main/env.config'),
    pubKey = fs.readFileSync(process.env.JWT_KEY || config['jwt-key']),
    iss = 'urn:homeautomationcot.me',
    aud = 'urn:homeautomationcot.me';

//// Create the signup strategy
passport.use('signUp',
    new LocalStrategy({
            usernameField: 'username',
            passwordField: 'password',
            passReqToCallback: true
        },
        async (req, username, password, done) => {
            try {
                // Hash the password and create the user
                req.body.password = await argon2.hash(req.body.password, {
                    type: argon2.argon2id,
                    memoryCost: 2 ** 16,
                    hashLength: 64,
                    saltLength: 32,
                    timeCost: 11,
                    parallelism: 2
                });
                const saved = await IdentityModel.createIdentity(req.body);
                return done(null, saved);

            } catch (e) {
                
                return done(e);
            }
        }
    )
);

//// Create jwt strategy
passport.use(
    new JWTStrategy({
            issuer: iss,
            audience: aud,
            algorithms: ['RS512'],
            secretOrKey: pubKey,
            jwtFromRequest: ExtractJWT.fromAuthHeaderAsBearerToken()
        },
        async (token, next) => {
            IdentityModel.findById(token.userId).then(function (identity, err) {
                if (err) {
                    return next(err, false);
                }
                if (identity) {

                    return next(null, identity);
                } else {
                    return next(null, false);
                }
            });
        }
    )
);