const refreshSecret = require('../../main/env.config.js').actualRefreshSecret;
const jwt = require('jsonwebtoken');
const config = require('../../main/env.config');
const validityTime = process.env.JWT_VALIDITY_TIME_IN_SECONDS || config.jwtValidityTimeInSeconds;
const crypto = require('crypto');
const fs = require('fs');

const privateKey = fs.readFileSync(process.env.JWT_KEY || config['jwt-key']);

this.challenges = {}
this.codes = {}
this.identities = {}

const base64Encode = (str) => {
    return str.toString('base64')
        .replace(/\+/g, '-')
        .replace(/\//g, '_')
        .replace(/=/g, '');
}

//// PKCE flow: PreLogin Step
exports.preLogin = (req, res) => {

    if (req.headers['pre-authorization']) {
        let authorization = req.headers['pre-authorization'].split(' ');
        if (authorization[0] !== 'Bearer') {
            return res.status(401).send({
                ok: false,
                message: 'Unauthorized'
            });
        } else {
            authorizationData = Buffer.from(authorization[1], 'base64').toString().split("#");
            let clientId = authorizationData[0];
            let codeChallenge = authorizationData[1];
            let loginId = clientId + "#" + crypto.randomBytes(32).toString("base64");
            let loginData = {
                loginId: loginId,
                clienId: clientId,
                codeChallenge: codeChallenge
            }
            this.challenges[codeChallenge] = loginId
            //this.codeChallenge = codeChallenge;
            return res.status(200).send({
                ok: true,
                message: loginData
            });
        }
    } else {
        return res.status(403).send({
            ok: false,
            message: 'No pre-authorization data'
        });
    }

};

//// PKCE flow: Login Step
exports.login = (req, res) => {
    let authorizationCode = crypto.randomBytes(32).toString("base64");
    this.codes[req.body.loginId] = authorizationCode;
    let identity = req.body;
    delete identity["loginId"];
    this.identities[authorizationCode] = identity;
    return res.status(200).send({
        ok: true,
        authorizationCode: authorizationCode
    });
};

//// PKCE flow: PostLogin Step
exports.postLogin = (req, res) => {
    if (req.headers['post-authorization']) {
        let authorization = req.headers['post-authorization'].split(' ');
        if (authorization[0] !== 'Bearer') {
            return res.status(401).send({
                ok: false,
                message: 'Unauthorized'
            });
        } else {
            authorizationData = Buffer.from(authorization[1], 'base64').toString().split("#");
            let hash = base64Encode(crypto.createHash('sha256').update(authorizationData[1]).digest());
            if (this.challenges.hasOwnProperty(hash)) {
                if (this.codes[this.challenges[hash]] === authorizationData[0]) {
                    this.codes[this.challenges[hash]] = null;
                    delete this.codes[this.challenges[hash]];
                    try {
                        let body = this.identities[authorizationData[0]];
                        let refreshId = body.userId + refreshSecret + body.jti;
                        let salt = crypto.randomBytes(16).toString('base64');
                        let hash = crypto.createHmac('sha512', salt).update(refreshId).digest("base64");

                        req.body["exp"] = Number(body["exp"]);
                        let token = jwt.sign(body, privateKey, {
                            algorithm: 'RS512'
                        });
                        let b = Buffer.from(hash);
                        let refresh_token = salt + '$' + b.toString('base64');
                        delete this.challenges[hash];
                        delete this.identities[authorizationData[0]];
                        return res.status(201).send({
                            ok: true,
                            accessToken: token,
                            refreshToken: refresh_token
                        });
                    } catch (err) {
                        delete this.challenges[hash];
                        delete this.identities[authorizationData[0]];
                        return res.status(500).send({
                            ok: false,
                            message: err
                        });
                    }
                } else {
                    delete this.challenges[hash];
                    delete this.identities[authorizationData[0]];
                    return res.status(401).send({
                        ok: false,
                        message: 'Unauthorized'
                    });
                }

            } else {
                delete this.challenges[hash];
                delete this.identities[authorizationData[0]];
                return res.status(401).send({
                    ok: false,
                    message: 'Unauthorized'
                });
            }
        }
    } else {
        return res.status(403).send({
            ok: false,
            message: 'No pre-authorization data'
        });
    }

};

exports.refresh_token = (req, res) => {
    try {
        var now = Math.floor(Date.now() / 1000);
        req.body.iat = now;
        req.body.exp = now + validityTime;
        let token = jwt.sign(req.body, privateKey, {
            algorithm: 'RS512'
        });

        res.status(201).send({
            ok: true,
            access_token: token
        });
    } catch (err) {
        res.status(500).send({
            ok: false,
            message: err
        });
    }
};

exports.resetRefreshSecret = (req, res) => {
    try {
        config.initRefreshSecret();
        res.status(204).send({
            ok: true,
            message: "RefreshSecret initialized"
        });
    } catch (err) {
        res.status(500).send({
            ok: false,
            errors: err
        });
    }
};