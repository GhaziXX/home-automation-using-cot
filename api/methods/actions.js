var User = require("../models/user")
var jwt = require("jwt-simple")
var config = require("../config/dbconfig")

var functions = {
    signUp: function (req, res)
    {
        
        if ((!req.body.email) || (!req.body.password) || (!req.body.username))
        {
            res.json({success: false, msg: 'Make sure that you entered all fields'})
        }
        else
        {
            var newUser = User({
                username: req.body.username,
                email: req.body.email,
                password: req.body.password,
                forname: req.body.forname,
                surname: req.body.surname
            });
            newUser.save(function(err, newUser) {
                if (err) {
                    res.json({success: false, msg: 'Failed to save'})
                }
                else
                {
                    res.json({success: true, msg: "Successfully saved"})
                }
            })
        }
    },
    signIn: function (req, res) {
        User.attemptAuthenticate(req.body.email, req.body.password, (err,user,reason) => {
            console.log(user)
            if (err) res.json({success: false, msg: err});
            // login was successful if we have an identity
            if (user) {
                var token = jwt.encode(user, config.secret)
                res.json({success: true, token: token});
                return user;
                
            }
            // otherwise we can determine why we failed
            const reasons = User.failedLogin;
            switch (reason) {
                case reasons.NOT_FOUND:
                case reasons.PASSWORD_INCORRECT:
                    res.json({success: false, msg: 'Sign In failed'});
                case reasons.MAX_ATTEMPTS:
                    res.json({success: false, msg: 'Account temporarily locked'})
            }
        });
    },
    getInfo: function(req, res)
    {
        if(req.headers.authorization && req.headers.authorization.split(" ")[0] === 'Bearer'){
            var token = req.headers.authorization.split(' ')[1]
            var decodedtoken = jwt.decode(token, config.secret)
            return res.json({success: true, msg: "Hello "+decodedtoken.username})
        }else
        {
            return res.json({success: false, msg: "No Headers"})
        }
    }

}

module.exports = functions