const jwt = require('jsonwebtoken'),
    config = require('../../main/env.config');

const Master = config.permissionLevels.Master;
const Member = config.permissionLevels.Member;
const Surfer = config.permissionLevels.Surfer;

exports.minimumPermissionLevelRequired = (required_permission_level) => {
    return (req, res, next) => {
        let user_permission_level = parseInt(req.user.permissions);
        console.log(user_permission_level)
        if (user_permission_level & required_permission_level) {
            return next();
        } else {
            return res.status(403).send({
                ok: false,
                message: 'User does not have the required permissions'
            });
        }
    };
};

exports.onlySameUserOrAdminCanDoThisAction = (req, res, next) => {

    let user_permission_level = parseInt(req.user.permissions);
    let userId = req.user.id;

    if (req.params && req.params.userId && userId === req.params.userId) {
        return next();
    } else {
        if (user_permission_level & Master) {
            return next();
        } else {
            return res.status(403).send({
                ok: false,
                message: 'User does not have the required permissions'
            });
        }
    }

};

exports.sameUserCantDoThisAction = (req, res, next) => {
    let userId = req.user.id;

    if (req.params.userId !== userId) {
        return next();
    } else {
        return res.status(403).send({
            ok: false,
            message: 'User does not have the required permissions'
        });
    }

};