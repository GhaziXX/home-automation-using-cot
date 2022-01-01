const IdentityModel = require('../../identity/models/identity.model');
const argon2 = require('argon2');

const {
    v4: uuidv4
} = require('uuid');

const config = require('../../main/env.config');
const validityTime = process.env.JWT_VALIDITY_TIME_IN_SECONDS || config.jwtValidityTimeInSeconds;

//// Check if the request has valid fields for signin
exports.hasAuthValidFields = (req, res, next) => {
    let errors = [];
    if (req.body) {
        if (!req.body.email) {
            errors.push('Missing email field');
        }
        if (!req.body.password) {
            errors.push('Missing password field');
        }
        if (!req.body.loginId) {
            errors.push('Missing loginId field');
        }

        if (errors.length) {
            return res.status(400).send({
                ok: false,
                message: errors
            });
        } else {
            return next();
        }
    } else {
        return res.status(400).send({
            ok: false,
            message: 'Missing email and password fields'
        });
    }
};

//// Check if a user exists
exports.isUserExists = (req, res, next) => {
    IdentityModel.findByUsername(req.body.username).then(
        async (identity) => {
            if (identity[0]) {
                console.log(identity[0]);
                return res.status(400).send({
                    ok: false,
                    errors: 'Username already exists'
                });
            } else {
                return next();
            }
        }
    );
};

//// Check if Password and User match
exports.isPasswordAndUserMatch = async (req, res, next) => {
    IdentityModel.findByEmail(req.body.email)
        .then(async (user) => {
            if (!user[0]) {
                res.status(404).send({
                    ok: false,
                    message: 'User does not exists'
                });
            } else {
                if (await argon2.verify(user[0].password, req.body.password)) {
                    var now = Math.floor(Date.now() / 1000);
                    req.body = {
                        iss: 'urn:homeautomationcot.me',
                        aud: 'urn:' + (req.get('origin') ? req.get('origin') : "homeautomationcot.me"),
                        sub: user[0].email,
                        name: user[0].forename + ' ' + user[0].surname,
                        userId: user[0]._id,
                        roles: user[0].permissions,
                        jti: uuidv4(),
                        iat: now,
                        exp: now + validityTime,
                        loginId: req.body.loginId
                    };
                    return next();
                } else {
                    return res.status(400).send({
                        ok: false,
                        message: 'Invalid e-mail or password'
                    });
                }
            }
        });
};


//// Check if user still have the same previleges
exports.isUserStillExistsWithSamePrivileges = (req, res, next) => {
    IdentityModel.findByEmail(req.body.sub)
        .then((user) => {
            if (!user[0]) {
                res.status(404).send({
                    ok: false,
                    message: 'User does not exists'
                });
            }

            req.body.roles = user[0].permissions;
            return next();
        });
};