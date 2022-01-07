const Maps = require('mongoose').model('Maps');

//// Get current location
exports.getLocation = (location) => {
    return Maps.getLocation(location);
}

//// Update location
exports.updateLocation = (lat,lon) => {
    return Maps.updateLocation(lat,lon);
};
