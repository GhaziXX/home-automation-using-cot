const jwt = require('jsonwebtoken'),
    refreshSecret = require('../../main/env.config.js').actualRefreshSecret,
    crypto = require('crypto');
    fs = require('fs');

const config = require('../../main/env.config');
const cert = fs.readFileSync(process.env.CERT_FILE || config['cert-file']);

exports.validJWTNeeded = (req, res, next) => {
    if (req.headers['authorization']) {
        try {
            let authorization = req.headers['authorization'].split(' ');
            if (authorization[0] !== 'Bearer') {
                return res.status(401).send();
            } else {
                var aud = 'urn:'+(req.get('origin')?req.get('origin'):"homeautomationcot.me");
                req.jwt = jwt.verify(authorization[1], cert, {issuer:"urn:homeautomationcot.me",audience:aud,algorithms: ['RS512']});
                return next();
            }
        } catch (err) {
            return res.status(403).send();
        }
    } else {
        return res.status(401).send();
    }
};

exports.verifyRefreshBodyField = (req, res, next) => {
    if (req.body && req.body.refresh_token) {
        return next();
    } else {
        return res.status(400).send({error: 'need to pass refresh_token field'});
    }
};

exports.validRefreshNeeded = (req, res, next) => {
    let b = Buffer.from(req.body.refresh_token, 'base64');
    let decoded = b.toString().split('$');
    let salt = decoded[0];
    let refresh_token = decoded[1];
    let hash = crypto.createHmac('sha512', salt).update(req.jwt.user_id + refreshSecret + req.jwt.jti).digest("base64");
    if (hash === refresh_token) {
        req.body = req.jwt;
        return next();
    } else {
        return res.status(400).send({error: 'Invalid refresh token'});
    }
};