import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:frontend/app/utils/responsive.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class SnackbarMessage extends StatelessWidget {
  SnackbarMessage(
      {Key? key,
      required this.message,
      required this.icon,
      this.isDissmisible = true})
      : super(key: key);

  final String message;
  final Icon icon;
  final bool isDissmisible;

  @override
  Widget build(BuildContext context) {
    return showMessage(context);
  }

  Widget showMessage(BuildContext context) {
    Size _size = MediaQuery.of(context).size;
    return Flushbar(
        margin: EdgeInsets.all(10),
        maxWidth: Responsive.isMobile(context) && _size.width < 500
            ? _size.width
            : 60.w,
        message: message,
        isDismissible: isDissmisible,
        borderRadius: BorderRadius.all(Radius.circular(8)),
        icon: icon,
        duration: Duration(seconds: 2, milliseconds: 500),
        //leftBarIndicatorColor: Colors.red.shade300,
        backgroundGradient: LinearGradient(
          colors: [
            Colors.blue.shade800,
            Colors.blueAccent.shade700,
            Colors.blueAccent.shade400
          ],
          stops: [0.4, 0.7, 1],
        ),
        boxShadows: [
          BoxShadow(
            color: Colors.black45,
            offset: Offset(3, 3),
            blurRadius: 3,
          ),
        ],
        forwardAnimationCurve: Curves.fastLinearToSlowEaseIn,
        dismissDirection: FlushbarDismissDirection.HORIZONTAL)
      ..show(context);
  }
}
