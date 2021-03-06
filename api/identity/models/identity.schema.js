const mongoose = require('mongoose'),
    Schema = mongoose.Schema,
    argon2 = require('argon2'),
    uniqueValidator = require('mongoose-unique-validator'),
    // these values can be whatever you want - we're defaulting to a
    // max of 5 attempts, resulting in a 2 hour lock
    MAX_LOGIN_ATTEMPTS = 5,
    LOCK_TIME = 2 * 60 * 60 * 1000;

//@start Schema
const identitySchema = new Schema({
    forename: String,
    surname: String,
    email: {
        type: String,
        lowercase: true,
        index: {
            unique: true
        },
        required: [true, 'Cannot be Empty'],
        match: [/\S+@\S+\.\S+/, 'is invalid']
    },
    username: {
        type: String,
        lowercase: true,
        index: {
            unique: true
        },
        immutable: true,
        required: [true, 'Cannot be Empty'],
        match: [/^[a-zA-Z][a-zA-Z0-9_]+$/, 'is invalid']
    },
    password: {
        type: String,
        required: true
    },
    permissions: {
        type: Number,
        default: 0,
        min: 0,
        max: 2147483647
    },
    loginAttempts: {
        type: Number,
        required: true,
        default: 0
    },
    lockUntil: {
        type: Number
    },
    
}, {
    toObject: {
        virtuals: true
    },
    toJSON: {
        virtuals: true
    },
    collection: 'identities'
});

identitySchema.virtual('fullName')
    .get(function () {
        return this.forename + ' ' + this.surname;
    })
    .set((v) => {
        this.forename = v.substr(0, v.lastIndexOf(' '));
        this.surname = v.substr(v.lastIndexOf(' ') + 1)
    });

identitySchema.virtual('isLocked').get(function () {
    // check for a future lockUntil timestamp
    return !!(this.lockUntil && this.lockUntil > Date.now());
});

/**
 *
 * @param cb
 * @returns {*}
 */
identitySchema.methods.incLoginAttempts = function (cb) {
    // if we have a previous lock that has expired, restart at 1
    if (this.lockUntil && this.lockUntil < Date.now()) {
        return this.update({
            $set: {
                loginAttempts: 1
            },
            $unset: {
                lockUntil: 1
            }
        }, cb);
    }
    // otherwise we're incrementing
    let updates = {
        $inc: {
            loginAttempts: 1
        }
    };
    // lock the account if we've reached max attempts and it's not locked already
    if (this.loginAttempts + 1 >= MAX_LOGIN_ATTEMPTS && !this.isLocked) {
        updates.$set = {
            lockUntil: Date.now() + LOCK_TIME
        };
    }
    return this.updateOne(updates, cb);
};

/**
 * Grant the permission identified by {@param permission} to the current identity
 * @param permission A number between 0 and 30 inclusive identifying the permission
 */
identitySchema.methods.grantPermission = (permission) => {
    this.permissions |= (1 << permission);
};
/**
 * Revoke the permission identified by {@param permission} to the current identity
 * @param permission A number between 0 and 30 inclusive identifying the permission
 */
identitySchema.methods.revokePermission = (permission) => {
    this.permissions &= ~(1 << permission);
};
/**
 * Check if the permission identified by {@param permission} is granted to the current identity
 * @param permission A number between 0 and 30 inclusive identifying the permission
 */
identitySchema.methods.hasPermission = (permission) => {
    return (this.permissions & (1 << permission)) !== 0;
};

identitySchema.statics.persissionSet = {
    SURFER: 0, //Read Only Access To all the Cloud of Things Resources
    DEVICE_CONTROLLER: 7, //Update device configuration and send commands to devices
    MEMBER: 15, //Create and Delete Devices from Registries
    MODERATOR: 22, //Read-Write access to all the Cloud of Things Resources excluding managing users
    MASTER: 30 //Full Access To  all the Cloud of Things Resources including managing all users
};

const reasons = identitySchema.statics.failedLogin = {
    NOT_FOUND: 0,
    PASSWORD_INCORRECT: 1,
    MAX_ATTEMPTS: 2
};

//// Verify password
identitySchema.methods.checkPassword = async function (candidatePassword) {
    const identity = this;
    return await argon2.verify(identity.password, candidatePassword);
};

//// Find user by username
identitySchema.statics.findByUsername = (username) => {
    return mongoose.model("Identity", identitySchema).find({
        username: username
    });
};

//// Find user by email
identitySchema.statics.findByEmail = (email) => {
    return mongoose.model("Identity", identitySchema).find({
        email: email
    });
};

identitySchema.plugin(uniqueValidator, {
    message: 'is already taken.'
});
/**
 * Here we compile a model from the schema definition
 * An instance of a model is called a document.
 * Models are responsible for creating and reading documents from the underlying MongoDB database.
 */
mongoose.model('Identity', identitySchema);