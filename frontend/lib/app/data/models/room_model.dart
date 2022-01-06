import 'dart:convert';

class Room {
  Room({required this.roomName, required this.roomImgUrl});

  String roomName;
  String roomImgUrl;

  factory Room.fromRawJson(String str) => Room.fromJson(json.decode(str));

  String? toRawJson() => json.encode(toJson());

  factory Room.fromJson(Map<String?, dynamic> json) =>
      Room(roomName: json["roomId"], roomImgUrl: json["roomId"]);

  Map<String?, dynamic> toJson() =>
      {"roomName": roomName, "roomImgUrl": roomImgUrl};
}
