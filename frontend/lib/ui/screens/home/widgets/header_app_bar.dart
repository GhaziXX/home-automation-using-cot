// ignore_for_file: unused_element, use_key_in_widget_constructors

import 'package:flutter/material.dart';
import 'package:frontend/configs/colors.dart';
import 'package:frontend/core/extensions/context.dart';
import 'package:frontend/data/rooms.dart';
import 'package:frontend/ui/widgets/widgets/room_card.dart';
import 'package:frontend/ui/widgets/widgets/pokeball_background.dart';
import 'package:frontend/ui/widgets/widgets/spacer.dart';

import '../../../../routes.dart';

class HeaderAppBar extends StatelessWidget {
  static const double heightFraction = 0.66;

  const HeaderAppBar({
    @required this.height,
    @required this.showTitle,
  });

  final double height;
  final bool showTitle;

  Widget _buildTitle(visible) {
    if (!visible) {
      return null;
    }

    return const Text(
      'Home Automation',
      style: TextStyle(
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildRooms(BuildContext context) {
    final spacing = context.responsive(10);

    return Expanded(
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: 28,
          vertical: context.responsive(40),
        ),
        child: LayoutBuilder(
          builder: (_, constrains) {
            final width = constrains.maxWidth;
            final height = constrains.maxHeight;
            final itemHeight = (height - 2 * spacing) / 2;

            return Wrap(
              alignment: WrapAlignment.spaceBetween,
              runAlignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: rooms
                  .map(
                    (e) => SizedBox(
                      width: (width - spacing) / 2,
                      height: itemHeight,
                      child: RoomCard(
                        e,
                        onPress: () => AppNavigator.push(e.route),
                      ),
                    ),
                  )
                  .toList(),
            );
          },
        ),
      ),
    );
  }

  Widget _buildCard(BuildContext context) {
    return Container(
      clipBehavior: Clip.hardEdge,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(30),
        ),
      ),
      child: PokeballBackground(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            VSpacer(context.responsive(60) + context.padding.top),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Text(
                'Welcome Back,\nChoose the room you want to controle?',
                style: TextStyle(
                  fontSize: 30,
                  height: 1.4 * context.responsive(30) / 30,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            VSpacer(context.responsive(28)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Text(
                'Current wheather is',
                style: TextStyle(
                  fontSize: 12,
                  height: 1.4 * context.responsive(30) / 30,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            _buildRooms(context),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: height,
      floating: true,
      pinned: true,
      elevation: 0,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(30),
        ),
      ),
      backgroundColor: AppColors.red,
      flexibleSpace: FlexibleSpaceBar(
        collapseMode: CollapseMode.pin,
        centerTitle: true,
        title: _buildTitle(showTitle),
        background: _buildCard(context),
      ),
    );
  }
}
