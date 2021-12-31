import 'package:flutter/material.dart';

import '../../routes.dart';

class Room {
  const Room({
    @required this.name,
    @required this.color,
    @required this.route,
    @required this.image,
  });

  final Color color;
  final String name;
  final Routes route;
  final String image;
}
