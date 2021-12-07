module.exports = {
'key-file' : 'tls/privkey.pem',
'cert-file': 'tls/fullchain.pem',
'dh-strongfile': 'tls/dhparam.pem',
'jwt-key': 'tls/jwtRS256.key',
'main_db_url': "mongodb+srv://homeautomationcot:Homeautomationcot@cluster0.gipho.mongodb.net/users?retryWrites=true&w=majority",
'jwtValidityTimeInSeconds': 86400,
'permissionLevels': {
    'Master':1073741824,
    'Member':1,
    'Surfer':2
},
}
