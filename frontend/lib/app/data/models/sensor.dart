class Sensor {
  final dynamic value;
  final String? id;
  final String? roomId;

  Sensor({required this.value, required this.id, required this.roomId});

  factory Sensor.fromJson(Map<String, dynamic> json) {
    return Sensor(
        value: json["value"] ?? 0,
        id: json["sensorId"] ?? "",
        roomId: json["roomId"] ?? "");
  }

  @override
  String toString() {
    return "the sensor $id is in $roomId and have the value $value";
  }
}
