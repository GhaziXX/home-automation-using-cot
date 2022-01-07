import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';


class ActionButton extends StatelessWidget {
  const ActionButton({
    Key? key,
    required this.press,
    required this.title,
  }) : super(key: key);

  final VoidCallback press;
  final String title;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: press,
      style: ElevatedButton.styleFrom(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
        elevation: 4,
      ),
      child: Center(
        widthFactor: 4.w,
        heightFactor: 0.15.h,
        child: Text(
          title,
          style: TextStyle(
              color: Colors.white, fontSize: 8.sp, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}