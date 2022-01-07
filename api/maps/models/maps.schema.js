const mongoose = require('mongoose');
const Schema = mongoose.Schema;

//@start Schema
const MapsSchema = new Schema({
    lat: {
        type: Number
    },
    lon: {
        type: Number,
    }
}, {
    toJSON: {
        virtuals: true
    },
    collection: 'maps'
});

//// Get Location
MapsSchema.statics.getLocation = () => {
    return mongoose.model("Maps", MapsSchema).find({});
};

//// Update Location
MapsSchema.statics.updateLocation = (lat,lon) => {
    const updateDoc = {
        $set: {
            lat: lat,
            lon: lon,
        },
    };
    return mongoose.model("Maps", MapsSchema).findOneAndUpdate({}, updateDoc);
};

/**
 * Here we compile a model from the schema definition
 * An instance of a model is called a document.
 * Models are responsible for creating and reading documents from the underlying MongoDB database.
 */
 MapsSchema.index({
    "loc": "2dsphere"
});
mongoose.model('Maps', MapsSchema);