const passport = require('passport'),
        LocalStrategy = require('passport-local').Strategy,
        JWTStrategy = require('passport-jwt').Strategy,
        ExtractJWT = require('passport-jwt').ExtractJwt,
        IdentityModel = require('../models/identity.model'),
        fs = require('fs'),
        pubKey = fs.readFileSync('./tls/privkey.pem'),
        iss = 'urn:homeautomationcot.me',
        aud = 'urn:*.homeautomationcot.me';

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
                    req.body.permissions = 0;
                    console.log(identity);
                    console.log(req.body);
                    const saved = await IdentityModel.createIdentity(req.body);
                    console.log("Hello!");
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
        async (token, done) => {
            IdentityModel.findByUsername(token.sub, function(err, identity) {
                if (err) {
                    return done(err, false);
                }
                if (identity) {
                    return done(null, identity);
                } else {
                    return done(null, false);
                }
            });
        }
    )
);