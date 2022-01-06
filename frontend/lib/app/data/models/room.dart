

import 'package:frontend/app/data/models/sensor.dart';

class Room {
  final List<Sensor>? sensors;
  final String? id;

  Room({required this.sensors, required this.id});

  factory Room.fromJson(Map<String, dynamic> json) {
    return Room(id: json["_id"]["roomId"] ?? "", sensors: json["sensors"]);
  }
}
