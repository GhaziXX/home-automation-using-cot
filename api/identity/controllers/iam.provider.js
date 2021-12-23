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

passport.use('signUp',
    new LocalStrategy(
        {
            usernameField : 'username',
            passwordField : 'password',
            passReqToCallback : true
        },
        async (req, username, password, done) => {
            // check if there
            try {
                let identity = IdentityModel.findByUsername({username: username});

                // check to see if there is already an identity with that email
                if (identity) {
                    return done(null, false, req.flash('signupMessage', 'That username is already taken.'));
                } else {
                    req.body.password = await argon2.hash(req.body.password,{
                        type: argon2.argon2id,
                        memoryCost: 2 ** 16,
                        hashLength: 64,
                        saltLength: 32,
                        timeCost: 11,
                        parallelism: 2
                    });
                    const saved = await IdentityModel.createIdentity(req.body);
                    return done(null, saved);
                }
            }catch (e) {
                return done(e);
            }
        }
    )
);

passport.use('signIn',
    new LocalStrategy(
        {
            usernameField: 'username',
            passwordField: 'password'
        },
        async (username, password, done) => {
            console.log("wsolt")
            try {
                return done(null,IdentityModel.triggerLogin(username,password));
            } catch (error) {
                return done(error);
            }
        }
    )
);

passport.use(
    new JWTStrategy(
        {
            issuer: iss,
            audience: aud,
            algorithms: ['RS512'],
            secretOrKey: pubKey,
            jwtFromRequest: ExtractJWT.fromAuthHeaderAsBearerToken()
        },
        async (token, next) => {
            IdentityModel.findById(token.userId).then(function(identity, err) {
                if (err) {
                    return next(err, false);
                }
                if (identity) {
                    
                    return next(null ,identity);
                } else {
                    return next(null, false);
                }
            });
        }
    )
);