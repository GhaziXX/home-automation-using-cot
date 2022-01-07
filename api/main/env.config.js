module.exports = {
    'key-file': 'path/to/keyfile/privkey.pem',
    'cert-file': 'path/to/cert/fullchain.pem',
    'dh-strongfile': 'path/to/dhparam/dhparam.pem',
    'jwt-key': 'path/to/jwt-key/jwtRS256.key',
    'jwt-public-key': 'path/to/jwt-public-key/jwtRS256.key.pub',
    'main_db_url': "",
    'jwtValidityTimeInSeconds': 36000,
    'actualRefreshSecret': "refreshme",
    'permissionLevels': {
        'Master': 2048,
        'Member': 1,
        'Surfer': 2
    },
    "initRefreshSecret": function () {
        this.actualRefreshSecret = this.actualRefreshSecret.concat("$" + new Date(Date.now()).toISOString())
    },
    "mqtt-broker":"mqtts://mqtt.homeautomationcot.me/",
    "mqtt-port": 8883,
    "mqtt-username": "",
    "mqtt-password": ""
}