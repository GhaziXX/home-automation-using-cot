const Identity = require('mongoose').model('Identity');

exports.findByUsername = (username) => {
    Identity.findOne().byUsername(username).exec((err, identity) => {
        if(err){
            throw err;
        }
        return identity;
    });
}

exports.triggerLogin = (username, password) => {
    Identity.attemptAuthenticate(username, password, (err,identity,reason) => {
        if (err) throw err;
        // login was successful if we have an identity
        if (identity) {
            return identity;
        }
        // otherwise we can determine why we failed
        const reasons = Identity.failedLogin;
        switch (reason) {
            case reasons.NOT_FOUND:
            case reasons.PASSWORD_INCORRECT:
                throw new Error('Sign In failed');
            case reasons.MAX_ATTEMPTS:
                throw new Error('Account temporarily locked');
        }
    });
}

exports.findByEmail = (email) => {
    return Identity.find({email: email});
};

exports.findById = (id) => {
    return Identity.findById(id)
        .then((result) => {
            result = result.toJSON();
            delete result._id;
            delete result.__v;
            return result;
        });
};

exports.createIdentity = (identityData) => {
    const identity = new Identity(identityData);
    return identity.save();
};

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

exports.putIdentity = (id,identityData) => {
    return new Promise((resolve, reject) => {
        Identity.findByIdAndUpdate(id,identityData,function (err,user) {
            if (err) reject(err);
            resolve(user);
        });
    });
};

exports.patchIdentity = (id, userData) => {
    return new Promise((resolve, reject) => {
        Identity.findById(id, function (err, user) {
            if (err) reject(err);
            for (let i in userData) {
                if(i === 'permissions' || i === 'password'){
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

exports.removeById = (userId) => {
    return new Promise((resolve, reject) => {
        Identity.remove({_id: userId}, (err) => {
            if (err) {
                reject(err);
            } else {
                resolve(err);
            }
        });
    });
};