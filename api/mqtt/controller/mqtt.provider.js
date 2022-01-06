const mqtt = require('mqtt')
const config = require("../../main/env.config");
const MqttDispatcher = require('mqtt-dispatcher')
const ConnectObjectModel = require('../models/connectedObject.model');


const client = mqtt.connect(config['mqtt-broker'] + ":" + config['mqtt-port'], {
  // Clean session
  clean: true,
  // Auth
  username: process.env.MQTT_USERNAME || config['mqtt-username'],
  password: process.env.MQTT_PASSWORD || config['mqtt-password'],
});
const dispatcher = new MqttDispatcher(client)

client.on('connect', () => console.log('MQTT Server connected'));

ConnectObjectModel.list(30, 0).then((resp) => {
  resp.forEach(element => {
    dispatcher.addRule(element.sensorId, async (topic, message) => {
      var json = JSON.parse(message.toString());
      if (!json.hasOwnProperty("on"))
        await ConnectObjectModel.updateSensorValue(element.roomId, element.sensorId.split("/")[1], json.hasOwnProperty("value") ? json.value : "");
    });
  });
  console.log("init state done");
});

exports.addObject = async (req, res) => {
  topic = req.body.roomId + "/" + req.body.sensorId
  try {
    dispatcher.addRule(topic, async (topic, message) => {
      var json = JSON.parse(message.toString());
      await ConnectObjectModel.updateSensorValue(req.body.roomId, req.body.sensorId, json.value);
    });
    client.publish("command", JSON.stringify({
      "sensorId": topic,
      "action": "add",
      "pin": req.body.pin,
    }), {
      qos: 2
    });
    return res.status(201).send({
      ok: true,
      message: 'Object Created'
    });
  } catch (error) {
    return res.status(404).send({
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
    ConnectObjectModel.removeBySensorId(topic).then(() => {
      return res.status(201).send({
        ok: true,
        message: 'Object Removed'
      });
    });
  } catch (error) {
    return res.status(404).send({
      ok: false,
      message: error
    });
  }
}

exports.performSetAction = async (req, res) => {
  topic = req.body.roomId + "/" + req.body.sensorId
  try {
    client.publish(topic, JSON.stringify(req.body.action), {
      qos: 2
    });
    await ConnectObjectModel.updateSensorValue(req.body.roomId, req.body.sensorId, req.body.action.on ? "true" : "false");
    return res.status(201).send({
      ok: true,
      message: 'Message sent'
    });
  } catch (error) {
    return res.status(404).send({
      ok: true,
      message: error
    });
  }
}

exports.performGetAction = (req, res) => {
  topic = req.body.roomId + "/" + req.body.sensorId
  client.publish(topic, JSON.stringify({
    "on": null
  }), {
    qos: 2
  });
  ConnectObjectModel.findBySensorId(topic).then((result) => {
    return res.status(200).send({
      ok: true,
      message: result[0].value
    });
  });
};