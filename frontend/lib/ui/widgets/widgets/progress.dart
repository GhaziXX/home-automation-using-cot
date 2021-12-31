import 'package:flutter/material.dart';
import 'package:frontend/configs/colors.dart';
import 'package:frontend/core/extensions/context.dart';

class ProgressBar extends StatelessWidget {
  // ignore: use_key_in_widget_constructors
  const ProgressBar({
    this.color = AppColors.red,
    this.backgroundColor = AppColors.lighterGrey,
    this.enableAnimation = true,
    @required this.progress,
  });

  final Color backgroundColor;
  final Color color;
  final double progress;
  final bool enableAnimation;

  @override
  Widget build(BuildContext context) {
    final child = Container(
      decoration: ShapeDecoration(
        shape: const StadiumBorder(),
        color: color,
      ),
    );

    return Container(
      clipBehavior: Clip.hardEdge,
      height: context.responsive(3),
      alignment: Alignment.centerLeft,
      decoration: const ShapeDecoration(
        shape: StadiumBorder(),
        color: AppColors.lighterGrey,
      ),
      child: enableAnimation
          ? AnimatedAlign(
              duration: const Duration(milliseconds: 260),
              alignment: const Alignment(1, 0),
              widthFactor: progress,
              child: child,
            )
          : FractionallySizedBox(
              widthFactor: progress,
              child: child,
            ),
    );
  }
}
