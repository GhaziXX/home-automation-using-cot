import 'package:flutter/material.dart';
import 'package:home_fi/app/theme/color_theme.dart';

class CustomCircleButton extends StatelessWidget {
  // ignore: use_key_in_widget_constructors
  const CustomCircleButton({@required this.onPressed});
  final GestureTapCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return RawMaterialButton(
      fillColor: GFTheme.primaryMaroon,
      splashColor: GFTheme.primaryGrey,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: const <Widget>[
            Icon(
              Icons.arrow_forward,
              color: Colors.white,
              size: 32,
            ),
          ],
        ),
      ),
      onPressed: onPressed,
      padding: const EdgeInsets.all(16.0),
      shape: const CircleBorder(),
    );
  }
}
