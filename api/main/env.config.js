module.exports = {
    'key-file': 'tls/privkey.pem',
    'cert-file': 'tls/fullchain.pem',
    'dh-strongfile': 'tls/dhparam.pem',
    'jwt-key': 'tls/jwtRS256.key',
    'jwt-public-key': 'tls/jwtRS256.key.pub',
    'main_db_url': "mongodb+srv://homeautomationcot:Homeautomationcot@cluster0.gipho.mongodb.net/users?retryWrites=true&w=majority",
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
    "mqtt-username": "homeautomationcotclient",
    "mqtt-password": "homeautomationcotmqtt"
}