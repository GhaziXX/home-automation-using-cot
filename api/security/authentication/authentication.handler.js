const refreshSecret = require('../../main/env.config.js').actualRefreshSecret;
const jwt = require('jsonwebtoken');
const config = require('../../main/env.config');
const validityTime = process.env.JWT_VALIDITY_TIME_IN_SECONDS || config.jwtValidityTimeInSeconds;
const crypto = require('crypto');
const fs = require('fs');

const privateKey = fs.readFileSync(process.env.JWT_KEY || config['jwt-key']);

exports.login = (req, res) => {
    try {
        let refreshId = req.body.userId + refreshSecret + req.body.jti;
        let salt = crypto.randomBytes(16).toString('base64');
        let hash = crypto.createHmac('sha512', salt).update(refreshId).digest("base64");
        
        req.body["exp"] = Number(req.body["exp"]);
        let token = jwt.sign(req.body, privateKey, { algorithm: 'RS512'});
        let b = Buffer.from(hash);
        let refresh_token = salt+'$'+b.toString('base64');

        res.status(201).send({accessToken: token, refreshToken: refresh_token});
    } catch (err) {
        res.status(500).send({errors: err});
    }
};

exports.refresh_token = (req, res) => {
    try {
        var now = Math.floor(Date.now() / 1000);
        req.body.iat = now;
        req.body.exp = now + validityTime;
        let token = jwt.sign(req.body,privateKey, { algorithm: 'RS512'});
    
        res.status(201).send({access_token: token});
    } catch (err) {
        res.status(500).send({errors: err});
    }
};

exports.resetRefreshSecret = (req, res) => {
    try {
        config.initRefreshSecret();
        res.status(204).send({});
    }catch (err) {
        res.status(500).send({errors: err});
    }
};