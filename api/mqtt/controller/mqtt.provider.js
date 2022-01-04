const mqtt = require('mqtt')
const config = require("../../main/env.config");
const MqttDispatcher = require('mqtt-dispatcher')
const ConnectObjectModel = require('../models/connectedObject.model');


const client = mqtt.connect(config['mqtt-broker'] + ":" + config['mqtt-port']);
const dispatcher = new MqttDispatcher(client)

client.on('connect', () => console.log('MQTT Server connected'));

this.objects = {}

ConnectObjectModel.list(50, 0).then((resp) => {
  resp.forEach(element => {
    dispatcher.addRule(element.sensorId, (topic, message) => {
      this.objects[topic] = JSON.parse(message.toString());
    });
  });
  console.log("init state done");
});

exports.addObject = async (req, res) => {
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

exports.removeObject = async (req, res) => {
  topic = req.body.roomId + "/" + req.body.sensorId
  try {
    dispatcher.removeRule(topic);
    client.publish("command", JSON.stringify({
      "sensorId": topic,
      "action": "remove"
    }), {
      qos: 2
    });
    delete this.objects[topic];
    ConnectObjectModel.removeBySensorId(topic).then(() => {
      return res.status(401).send({
        ok: true,
        message: 'Object Removed'
      });
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
  topic = req.body.roomId + "/" + req.body.sensorId
  return res.status(200).send({
    ok: true,
    message: this.objects[topic] ? this.objects[topic] : null
  });
}