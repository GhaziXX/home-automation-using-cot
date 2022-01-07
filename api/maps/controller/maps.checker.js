const MapsModel = require('../models/maps.model');
const Maps = require('mongoose').model('Maps');

exports.IsAvailable = (req, res, next) => {
    MapsModel.getLocation().then((response) => {
        if (response[0]) {
            next();
        } else {
            const coord = req.query.coordinates.split(",");
            const data = {
                lat: coord[0],
                lon: coord[1],
            };
            const map = new Maps(data);
            map.save();
            next();
        }

    });
};