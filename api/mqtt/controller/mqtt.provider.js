const mqtt = require('mqtt')
const config = require("../../main/env.config");
const MqttDispatcher = require('mqtt-dispatcher')

const client = mqtt.connect(config['mqtt-broker'] + ":" + config['mqtt-port']);
const dispatcher = new MqttDispatcher(client)

client.on('connect', () => console.log('MQTT Server connected'));

this.objects = {}
exports.addRule = async (req, res) => {
  topic = req.body.roomId + "/" + req.body.sensorId
  try {
    dispatcher.addRule(topic, (topic, message) => {
      this.objects[topic] = JSON.parse(message.toString());
    });
    client.publish("command", JSON.stringify({
      "sensorId": topic,
      "action": "add"
    }), {
      qos: 2
    });
    return res.status(401).send({
      ok: true,
      message: 'Object Created'
    });
  } catch (error) {
    return res.status(400).send({
      ok: false,
      message: error
    });
  }
}

exports.performSetAction = (req, res) => {
  topic = req.body.roomId + "/" + req.body.sensorId
  try {
    client.publish(topic, JSON.stringify(req.body.action), {
      qos: 2
    });
    return res.status(401).send({
      ok: true,
      message: 'Message sent'
    });
  } catch (error) {
    return res.status(400).send({
      ok: true,
      message: error
    });
  }


}

exports.performGetAction = (req, res) => {
  topic = req.body.roomId + "/" + req.body.object
  return res.status(200).send({
    ok: true,
    message: this.objects[topic]
  });
}