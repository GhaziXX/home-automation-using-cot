import 'package:flutter/material.dart';

const String _imagePath = 'assets/images';

class _Image extends AssetImage {
  const _Image(String fileName) : super('$_imagePath/$fileName');
}

class AppImages {
  static const loader = _Image('loader.gif');
  static const kitchen = _Image('kitchen.png');
  static const garage = _Image('garage.png');
  static const living_room = _Image('living-room.png');
  static const bedroom = _Image('bedroom.png');

  static Future precacheAssets(BuildContext context) async {
    await precacheImage(loader, context);
    await precacheImage(kitchen, context);
    await precacheImage(garage, context);
    await precacheImage(living_room, context);
    await precacheImage(bedroom, context);
  }
}
