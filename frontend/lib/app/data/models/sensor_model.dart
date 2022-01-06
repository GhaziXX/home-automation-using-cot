import 'dart:convert';

class Sensor {
  Sensor({this.sensorId, this.pin, this.value});

  String? sensorId;
  String? pin;
  String? value;

  factory Sensor.fromRawJson(String str) => Sensor.fromJson(json.decode(str));

  String? toRawJson() => json.encode(toJson());

  factory Sensor.fromJson(Map<String?, dynamic> json) => Sensor(
      sensorId: json["sensorId"], pin: json["pin"], value: json["value"]);

  Map<String?, dynamic> toJson() =>
      {"sensorId": sensorId, "pin": pin, "value": value};
}
