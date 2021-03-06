const jwt = require('jsonwebtoken'),
    refreshSecret = require('../../main/env.config.js').actualRefreshSecret,
    crypto = require('crypto');
fs = require('fs');

const config = require('../../main/env.config');
const cert = fs.readFileSync(process.env.JWT_KEY || config['jwt-key']);

exports.validJWTNeeded = (req, res, next) => {
    if (req.headers['authorization']) {
        let authorization = req.headers['authorization'].split(' ');
        if (authorization[0] !== 'Bearer') {
            return res.status(401).send({
                ok: false,
                message: 'Unauthorized'
            });
        } else {
            // var aud = 'urn:' + (req.get('origin') ? req.get('origin') : "homeautomationcot.me");
            var aud = 'urn:' + "homeautomationcot.me";
            req.jwt = jwt.verify(authorization[1], cert, {
                issuer: "urn:homeautomationcot.me",
                audience: aud,
                algorithms: ['RS512']
            });
            // console.log(req.jwt)
            return next();

        }
    } else {
        return res.status(403).send({
            ok: false,
            message: 'No authorization token'
        });
    }
};

exports.verifyRefreshBodyField = (req, res, next) => {
    if (req.body && req.body.refresh_token) {
        return next();
    } else {
        return res.status(400).send({
            ok: false,
            message: 'need to pass refresh_token field'
        });
    }
};

exports.validRefreshNeeded = (req, res, next) => {
    let salt = req.body.refresh_token.split("$")[0]
    let refresh_token = req.body.refresh_token.split("$")[1]
    refresh_token = Buffer.from(refresh_token, 'base64').toString();
    let hash = crypto.createHmac('sha512', salt).update(req.jwt.userId + refreshSecret + req.jwt.jti).digest("base64");
    if (hash === refresh_token) {
        req.body = req.jwt;
        return next();
    } else {
        return res.status(404).send({
            ok: false,
            message: 'Invalid refresh token'
        });
    }
};