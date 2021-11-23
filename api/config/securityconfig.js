module.exports = {
    'key-file' : 'config/certificates/privkey.pem',
    'cert-file': 'config/certificates/fullchain.pem',
    'dh-strongfile': 'config/certificates/dhparam.pem',
    'jwtValidityTimeInSeconds': 86400,
    'permissionLevels': {
        'Master':1073741824,
        'Member':1,
        'Surfer':2
    },
}