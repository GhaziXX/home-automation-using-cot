var mongoose = require("mongoose")
var argon2 = require("argon2")

uniqueValidator = require('mongoose-unique-validator'),
    MAX_LOGIN_ATTEMPTS = 5,
    LOCK_TIME = 2 * 60 * 60 * 1000;
var Schema = mongoose.Schema;


//@start Schema
const userSchema = new Schema({
    forename: String,
    surname: String,
    email: {type: String, lowercase:true, index: {unique: true},
            required: [true,'cannot be undefined'], match: [/\S+@\S+\.\S+/, 'is invalid']},
    username: { type: String, lowercase:true, index : {unique: true}, immutable: true,
                required: [true,'cannot be undefined'], match: [/^[a-zA-Z][a-zA-Z0-9_]+$/, 'is invalid']},
    password: {type: String, required: true},
    permissions: { type: Number, default: 0, min: 0, max: 2147483647 },
    loginAttempts: { type: Number, required: true, default: 0 },
    lockUntil: { type: Number }
},{
    toObject: { virtuals: true },
    toJSON: { virtuals: true },
    collection: 'users'
});

userSchema.virtual('fullName')
    .get( () => { return this.forename + ' ' + this.surname; })
    .set( (v) => {
        this.forename = v.substr(0, v.lastIndexOf(' '));
        this.surname = v.substr(v.lastIndexOf(' ') + 1)
    });

    userSchema.virtual('isLocked').get(function() {
    return !!(this.lockUntil && this.lockUntil > Date.now());
});

/**
 *
 * @param cb
 * @returns {*}
 */
 userSchema.methods.incLoginAttempts = function(cb) {
    if (this.lockUntil && this.lockUntil < Date.now()) {
        return this.update({
            $set: { loginAttempts: 1 },
            $unset: { lockUntil: 1 }
        }, cb);
    }
    let updates = {$inc: {loginAttempts: 1}};
    if (this.loginAttempts + 1 >= MAX_LOGIN_ATTEMPTS && !this.isLocked) {
        updates.$set = { lockUntil: Date.now() + LOCK_TIME };
    }
    return this.updateOne(updates, cb);
};

/**
 * Grant the permission identified by {@param permission} to the current identity
 * @param permission A number between 0 and 30 inclusive identifying the permission
 */
 userSchema.methods.grantPermission = (permission) => {
    this.permissions |= (1<<permission);
};
/**
 * Revoke the permission identified by {@param permission} to the current identity
 * @param permission A number between 0 and 30 inclusive identifying the permission
 */
 userSchema.methods.revokePermission = (permission) => {
    this.permissions &= ~(1<<permission);
};
/**
 * Check if the permission identified by {@param permission} is granted to the current identity
 * @param permission A number between 0 and 30 inclusive identifying the permission
 */
 userSchema.methods.hasPermission = (permission) => {
    return (this.permissions & (1<<permission) ) !== 0;
};

userSchema.statics.persissionSet = {
    SURFER: 0, //Read Only Access To all the Cloud of Things Resources
    DEVICE_CONTROLLER: 7, //Update device configuration and send commands to devices
    MEMBER:15, //Create and Delete Devices from Registries
    MODERATOR: 22, //Read-Write access to all the Cloud of Things Resources excluding managing users
    MASTER:30 //Full Access To  all the Cloud of Things Resources including managing all users
};

const reasons = userSchema.statics.failedLogin = {
    NOT_FOUND: 0,
    PASSWORD_INCORRECT: 1,
    MAX_ATTEMPTS: 2
};


userSchema.methods.checkPassword = async function(candidatePassword) {
    return await argon2.verify(this.password, candidatePassword);
};

userSchema.statics.attemptAuthenticate = function(email, password, cb) {
    this.findOne().byEmail(email).exec((err, user) => {
        if (err) return cb(err);

        // make sure the identity exists
        if (!user) {
            return cb(null, null, reasons.NOT_FOUND);
        }

        // check if the account is currently locked
        if (user.isLocked) {
            // just increment login attempts if account is already locked
            return user.incLoginAttempts(function(err) {
                if (err) return cb(err);
                return cb(null, null, reasons.MAX_ATTEMPTS);
            });
        }
        // check if the password is a match
        user.checkPassword(password).then((isMatch) => {
            if(isMatch){

                console.log(isMatch)
                // if there's no lock or failed attempts, just return the identity
                if (!user.loginAttempts && !user.lockUntil) return cb(null, user);
                // reset attempts and lock info
                let updates = {
                    $set: {loginAttempts: 0},
                    $unset: {lockUntil: 1}
                };
                return user.updateOne(updates, (err) => {
                    if (err) return cb(err);
                    return cb(null, user);
                });
            }
            // password is incorrect, so increment login attempts before responding
            user.incLoginAttempts((err) => {
                if (err) return cb(err);
                return cb(null, null, reasons.PASSWORD_INCORRECT);
            });
        }).catch(() => {
            // password is incorrect, so increment login attempts before responding
            user.incLoginAttempts((err) => {
                if (err) return cb(err);
                return cb(null, null, reasons.PASSWORD_INCORRECT);
            });
        });
    });
};

userSchema.query.byEmail = function (email) {
    return this.where({ email: new RegExp(email) } ); // 'i' flag to ignore case
};

userSchema.plugin(uniqueValidator, {message: 'is already taken.'});

userSchema.pre('save', async function(next){
    var user = this;
    if(this.isModified("password") || this.isNew)
    {
        user.password = await argon2.hash(user.password,{
            type: argon2.argon2id,
            memoryCost: 2 ** 16,
            hashLength: 64,
            saltLength: 32,
            timeCost: 11,
            parallelism: 2
        });
        next()
    }
    else
    {
        return next()
    }
})

module.exports = mongoose.model('User', userSchema)