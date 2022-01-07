const MapsModel = require('../models/maps.model');

//// Get current location
exports.getLocation = (req, res) => {
    MapsModel.getLocation().then((result) => {
        console.log(result);
        res.status(200).send({
            ok: true,
            message: {
                lat: result[0]["lat"],
                lon: result[0]["lon"]
            }
        });
    })
};

//// Update Location
exports.updateLocation = (req, res) => {
    const coord = req.query.coordinates.split(",");

    MapsModel.updateLocation(coord[0], coord[1]).then((result) => {
        res.status(201).send({
            ok: true,
            message: "Updated"
        });
    });
};