const Identity = require('mongoose').model('Identity');

//// Find user by username
exports.findByUsername = (username) => {
    return Identity.findByUsername(username);
}

//// Find user by email
exports.findByEmail = (email) => {
    try {
        identity = Identity.find({
            email: email
        });
    } catch (err) {
        console.log(err)
    }
    return identity
};

//// Find user by id
exports.findById = (id) => {
    return Identity.findById(id)
        .then((result) => {
            result = result.toJSON();
            delete result._id;
            delete result.__v;
            return result;
        });
};

//// Create new user
exports.createIdentity = (identityData) => {
    const identity = new Identity(identityData);
    return identity.save();
};


//// List all users
exports.list = (perPage, page) => {
    return new Promise((resolve, reject) => {
        Identity.find()
            .limit(perPage)
            .skip(perPage * page)
            .exec(function (err, users) {
                if (err) {
                    reject(err);
                } else {
                    resolve(users);
                }
            })
    });
};

//// Put identity by id
exports.putIdentity = (id, identityData) => {
    return new Promise((resolve, reject) => {
        Identity.findByIdAndUpdate(id, identityData, function (err, user) {
            if (err) reject(err);
            resolve(user);
        });
    });
};


//// Patch Identity
exports.patchIdentity = (id, userData) => {
    return new Promise((resolve, reject) => {
        Identity.findById(id, function (err, user) {
            if (err) reject(err);
            for (let i in userData) {
                if (i === 'permissions' || i === 'password') {
                    continue;
                }
                user[i] = userData[i];
            }
            user.save(function (err, updatedUser) {
                if (err) return reject(err);
                resolve(updatedUser);
            });
        });
    });

};

//// Remove by id
exports.removeById = (userId) => {
    return new Promise((resolve, reject) => {
        Identity.remove({
            _id: userId
        }, (err) => {
            if (err) {
                reject(err);
            } else {
                resolve(err);
            }
        });
    });
};