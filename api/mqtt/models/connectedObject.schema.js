const mongoose = require('mongoose');
const Schema = mongoose.Schema;

//@start Schema
const ConnectedObjectSchema = new Schema({
    roomId: {
        type: String,
        lowercase: true,
        index: {
            unique: false,
        },
        required: [true, "Room cannot be empty"],
    },
    sensorId: {
        type: String,
        lowercase: true,
        index: {
            unique: true,
        },
        required: [true, "Sensor cannot be empty"],
    },
    pin: {
        type: Number,
        index: {
            unique: false,
        },
        required: [true, "Sensor pin cannot be empty"],
    },
    value: {
        type: String,
        index: {
            unique: false,
        },
    }

}, {
    toObject: {
        virtuals: true
    },
    toJSON: {
        virtuals: true
    },
    collection: 'connectedObjects'
});

//// Find user by sensorid
ConnectedObjectSchema.statics.findBySensorId = (sensorid) => {
    return mongoose.model("ConnectedObject", ConnectedObjectSchema).find({
        sensorId: sensorid
    });
};

ConnectedObjectSchema.statics.findByPin = (pin) => {
    return mongoose.model("ConnectedObject", ConnectedObjectSchema).find({
        pin: pin
    });
};

//// Find user by sensorid
ConnectedObjectSchema.statics.findByRoomId = (roomId) => {
    return mongoose.model("ConnectedObject", ConnectedObjectSchema).find({
        roomId: roomId
    });
};

//// Find user by sensorid
ConnectedObjectSchema.statics.listRooms = () => {
    return mongoose.model("ConnectedObject", ConnectedObjectSchema).aggregate([{
            $group: {
                _id: {
                    roomId: "$roomId"
                },
                sensors: {
                    $push: "$sensorId"
                },
                values: {
                    $push: "$value"
                }
            },

        },
    ]);
};

//// Update the sensor value
ConnectedObjectSchema.statics.updateSensorValue = (roomId, sensorId, value) => {
    const filter = {
        "roomId": roomId,
        "sensorId": roomId + "/" + sensorId
    };
    const updateDoc = {
        $set: {
            value: value
        },
    };
    return mongoose.model("ConnectedObject", ConnectedObjectSchema).updateOne(filter, updateDoc);
};

/**
 * Here we compile a model from the schema definition
 * An instance of a model is called a document.
 * Models are responsible for creating and reading documents from the underlying MongoDB database.
 */
mongoose.model('ConnectedObject', ConnectedObjectSchema);