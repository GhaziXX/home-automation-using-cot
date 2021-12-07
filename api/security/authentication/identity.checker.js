const IdentityModel = require('../../identity/models/identity.model');
const argon2 = require('argon2');

const { v4: uuidv4 } = require('uuid');

const config = require('../../main/env.config');
const validityTime = process.env.JWT_VALIDITY_TIME_IN_SECONDS || config.jwtValidityTimeInSeconds;

exports.hasAuthValidFields = (req, res, next) => {
    let errors = [];
    if (req.body) {
        if (!req.body.email) {
            errors.push('Missing email field');
        }
        if (!req.body.password) {
            errors.push('Missing password field');
        }

        if (errors.length) {
            return res.status(400).send({errors: errors.join(',')});
        } else {
            return next();
        }
    } else {
        return res.status(400).send({errors: 'Missing email and password fields'});
    }
};

exports.isPasswordAndUserMatch = async (req, res, next) => {
    IdentityModel.findByEmail(req.body.email)
        .then(async (user)=>{
            if(!user[0]){
                res.status(404).send({});
            }else{
                if (await argon2.verify(user[0].password, req.body.password)) {
                    var now = Math.floor(Date.now() / 1000);
                    req.body = {
                        iss: 'urn:homeautomationcot.me',
                        aud: 'urn:'+(req.get('origin')?req.get('origin'):"homeautomationcot.me"),
                        sub: user[0].email,
                        name: user[0].firstName + ' ' + user[0].lastName,
                        userId: user[0]._id,
                        roles: user[0].permissionLevel,
                        jti: uuidv4(),
                        iat: now,
                        exp: now+validityTime
                    };
                    return next();
                } else {
                    return res.status(400).send({errors: ['Invalid e-mail or password']});
                }
            }
        });
};

exports.isUserStillExistsWithSamePrivileges = (req, res, next) => {
    IdentityModel.findByEmail(req.body.sub)
        .then((user)=>{
            if(!user[0]){
                res.status(404).send({});
            }
            req.body.roles = user[0].permissionLevel;
            return next();
        });
};