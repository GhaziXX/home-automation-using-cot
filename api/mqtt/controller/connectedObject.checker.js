const ConnectedObjectModel = require('../models/connectedObject.model');

//// Check if the request has valid fields for performing operation on sensors
exports.hasConnectedObjectValidFields = (req, res, next) => {
    let errors = [];
    if (req.body) {
        if (!req.body.roomId) {
            errors.push('Missing roomId field');
        }
        if (!req.body.sensorId) {
            errors.push('Missing sensorId field');
        }
        if (!req.body.pin) {
            errors.push('Missing pin field');
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
            message: 'Missing roomId and sensorId fields'
        });
    }
};


exports.hasGetValidFields = (req, res, next) => {
    let errors = [];
    if (req.body) {
        if (!req.body.roomId) {
            errors.push('Missing roomId field');
        }
        if (!req.body.sensorId) {
            errors.push('Missing sensorId field');
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
            message: 'Missing roomId and sensorId fields'
        });
    }
};

//// Check if a sensor exists
exports.isSensorExists = (req, res, next) => {
    const sensorId = req.body.roomId + "/" + req.body.sensorId;
    ConnectedObjectModel.findBySensorId(sensorId).then(
        async (sensor) => {
            if (sensor[0]) {
                console.log(sensor[0]);
                return res.status(400).send({
                    ok: false,
                    errors: 'Sensor already exists'
                });
            } else {
                ConnectedObjectModel.createConnectedObject({
                    "roomId": req.body.roomId,
                    "sensorId": sensorId,
                    "pin": req.body.pin,
                    "value": ""
                }).then(() => {
                    return next();
                });


            }
        }
    );
};