const ConnectedObject = require('mongoose').model('ConnectedObject');

//// Find sensor by id
exports.findBySensorId = (sensorId) => {
    return ConnectedObject.findBySensorId(sensorId);
}

//// Find user by room
exports.findByRoomId = (roomId) => {
    return ConnectedObject.findByRoomId(roomId);
};

//// Find user by room
exports.findByPin = (pin) => {
    return ConnectedObject.findByPin(pin);
};

//// Find user by room
exports.listRooms = () => {
    return ConnectedObject.listRooms();
};

//// Update sensor value
exports.updateSensorValue = (roomId, sensorId, value) => {
    return ConnectedObject.updateSensorValue(roomId, sensorId, value);
};

//// Create new ConnectedObject
exports.createConnectedObject = (sensorData) => {
    const sensor = new ConnectedObject(sensorData);
    return sensor.save();
};


//// List all sensors
exports.list = (perPage, page) => {
    return new Promise((resolve, reject) => {
        ConnectedObject.find()
            .limit(perPage)
            .skip(perPage * page)
            .exec(function (err, sensors) {
                if (err) {
                    reject(err);
                } else {
                    resolve(sensors);
                }
            })
    });
};

//// Remove by sensorId
exports.removeBySensorId = (sensorId) => {
    return new Promise((resolve, reject) => {
        ConnectedObject.deleteOne({
            sensorId: sensorId
        }, (err) => {
            if (err) {
                reject(err);
            } else {
                resolve(err);
            }
        });
    });
};

//// Remove by sensorId
exports.removeByRoomId = (roomId) => {
    return new Promise((resolve, reject) => {
        ConnectedObject.remove({
            roomId: roomId
        }, (err) => {
            if (err) {
                reject(err);
            } else {
                resolve(err);
            }
        });
    });
};