// ignore_for_file: use_key_in_widget_constructors, prefer_typing_uninitialized_variables, unused_local_variable

import 'package:flutter/material.dart';
import 'package:frontend/configs/images.dart';

import 'package:frontend/core/extensions/context.dart';
import 'package:frontend/models/room.dart';

class RoomCard extends StatelessWidget {
  const RoomCard(
    this.room, {
    this.onPress,
  });

  final Room room;
  final Function onPress;

  Widget _buildCircleDecoration({@required double height}) {
    return Positioned(
      top: -height * 0.616,
      left: -height * 0.53,
      child: CircleAvatar(
        radius: (height * 1.03) / 2,
        backgroundColor: Colors.white.withOpacity(0.14),
      ),
    );
  }

  Widget _buildRoomDecoration(
      {@required double height, @required String image}) {
    var img;
    switch (image) {
      case "kitchen":
        img = AppImages.kitchen;
        break;
      case "garage":
        img = AppImages.garage;
        break;
      case "living-room":
        img = AppImages.living_room;
        break;
      case "bedroom":
        img = AppImages.bedroom;
        break;
    }
    return Positioned(
      top: -height * 0.16,
      right: -height * 0.25,
      child: Image(
        image: img,
        width: height * 1.388,
        height: height * 1.388,
        color: Colors.white.withOpacity(0.14),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constrains) {
        final itemHeight = constrains.maxHeight;
        final itemWidth = constrains.maxWidth;

        return Stack(
          children: <Widget>[
            Align(
              alignment: Alignment.bottomCenter,
              child: _Shadows(color: room.color, width: itemWidth * 0.82),
            ),
            Material(
              color: room.color,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                splashColor: Colors.white10,
                highlightColor: Colors.white10,
                onTap: onPress,
                child: Stack(
                  children: [
                    _buildRoomDecoration(height: itemHeight, image: room.image),
                    _buildCircleDecoration(height: itemHeight),
                    _CardContent(room.name),
                  ],
                ),
              ),
            )
          ],
        );
      },
    );
  }
}

class _CardContent extends StatelessWidget {
  const _CardContent(this.name);

  final String name;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Text(
          name,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

class _Shadows extends StatelessWidget {
  const _Shadows({this.color, this.width});

  final Color color;
  final double width;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width * 0.82,
      height: context.responsive(11),
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: color,
            offset: Offset(0, context.responsive(3)),
            blurRadius: 23,
          ),
        ],
      ),
    );
  }
}
