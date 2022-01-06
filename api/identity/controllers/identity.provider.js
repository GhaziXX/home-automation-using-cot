const IdentityModel = require('../models/identity.model');
const argon2 = require('argon2');
const crypto = require('crypto');

//// List all users in the database
exports.list = (req, res) => {

    let limit = req.query.limit && req.query.limit <= 100 ? parseInt(req.query.limit) : 10;
    let page = 0;
    if (req.query) {
        if (req.query.page) {
            req.query.page = parseInt(req.query.page);
            page = Number.isInteger(req.query.page) ? req.query.page : 0;
        }
    }
    IdentityModel.list(limit, page)
        .then((result) => {
            res.status(200).send({ok:true, message: result});
        })
};

//// Get user by ID
exports.getById = (req, res) => {

    IdentityModel.findById(req.params.userId)
        .then((result) => {
            res.status(200).send({ok:true, message: result});
        });
};

//// Get current profile
exports.getProfileById = (req, res) => {
    IdentityModel.findById(req.user.id)
        .then((result) => {
            let profile = {
                "forename": result.forename,
                "surname": result.surname,
                "email": result.email,
                "username": result.username,
                "permissions": result.permissions,
                "fullName": result.forename + ' ' + result.surname,
                "id": result.id
            }
            res.status(200).send({ok:true, message: profile});
        });
};

//// Put User by id
exports.putById = (req, res) => {
    if (req.body.password) {
        let salt = crypto.randomBytes(16).toString('base64');
        let hash = crypto.scryptSync(req.body.password, salt, 64, {
            N: 16384
        }).toString("base64");
        req.body.password = salt + "$" + hash;
    }
    IdentityModel.putIdentity(req.params.userId, req.body)
        .then((result) => {
            req.status(204).send({ok: true});
        });
};

//// Patch user by id
exports.patchById = (req, res) => {
    if (req.body.password) {
        let salt = crypto.randomBytes(16).toString('base64');
        let hash = crypto.scryptSync(req.body.password, salt, 64, {
            N: 16384
        }).toString("base64");
        req.body.password = salt + "$" + hash;
    }
    try {
        IdentityModel.patchIdentity(req.params.userId, req.body)
        .then((result) => {
            res.status(204).send({ok:true});
        });
    } catch (error) {
        res.status(200).send({ok:false});
    }
    
};

//// Remove user by id
exports.removeById = (req, res) => {
    IdentityModel.removeById(req.params.userId)
        .then((result) => {
            res.status(204).send({ok:true});
        });
};