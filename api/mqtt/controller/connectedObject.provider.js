const ConnectedObjectModel = require('../models/connectedObject.model');

//// List all sensers in the database
exports.list = (req, res) => {
    let limit = req.query.limit && req.query.limit <= 100 ? parseInt(req.query.limit) : 20;
    let page = 0;
    if (req.query) {
        if (req.query.page) {
            req.query.page = parseInt(req.query.page);
            page = Number.isInteger(req.query.page) ? req.query.page : 0;
        }
    }
    ConnectedObjectModel.list(limit, page)
        .then((result) => {
            const copyItems = []
            result.forEach(element => {
                copyItems.push({
                    "roomId": element.roomId,
                    "sensorId": element.sensorId,
                    "pin": element.pin
                })
            });
            res.status(200).send({
                ok: true,
                message: copyItems
            });
        })
};

//// Get user by SensorId
exports.getBySensorId = (req, res) => {
    const sensorId = req.body.roomId + "/" + req.body.sensorId;
    ConnectedObjectModel.findBySensorId(sensorId)
        .then((result) => {
            res.status(200).send({
                ok: true,
                message: result
            });
        });
};

//// Get user by RoomId
exports.getByRoomId = (req, res) => {
    ConnectedObjectModel.findByRoomId(req.body.roomId)
        .then((result) => {
            res.status(200).send({
                ok: true,
                message: result
            });
        });
};

//// Remove sensor by id
exports.removeBySensorId = (req, res) => {
    const sensorId = req.body.roomId + "/" + req.body.sensorId;
    ConnectedObjectModel.removeBySensorId(sensorId)
        .then((result) => {
            res.status(204).send({
                ok: true
            });
        });
};

//// Returns all rooms and each corresponding sensors
exports.listRooms = (req, res) => {
    try {
        ConnectedObjectModel.listRooms()
            .then((result) => {
                var final = {};
                result.forEach((elem) => {
                    final[elem._id.roomId] = elem.sensors.map((e) => e.split("/")[1]);
                });
                res.status(200).send({
                    ok: true,
                    message: final
                });
            });
    } catch (error) {
        res.status(204).send({
            ok: false,
            message: null
        });
    }

};
