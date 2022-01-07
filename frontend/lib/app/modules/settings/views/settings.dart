import 'dart:async';
import 'package:flutter/material.dart';
import 'package:frontend/app/data/provider/api_services.dart';
import 'package:frontend/app/global_widgets/snackbar.dart';
import 'package:frontend/app/modules/auth/auth.dart';
import 'package:frontend/app/theme/text_theme.dart';
import 'package:get/get.dart';
import 'package:get_it/get_it.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  Completer<GoogleMapController> _controller = Completer();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmpasswordController = TextEditingController();

  CameraPosition pos = CameraPosition(
      target: LatLng(36.93995593184964, 10.223821364343166), zoom: 15);

  void getLocation() async {
    List<double> l = await GetIt.I<APIServices>().getLocation();
    LatLng _pos = LatLng(l[0], l[1]);
    setState(() {
      pos = CameraPosition(target: _pos, zoom: 18);
    });
  }

  @override
  void initState() {
    super.initState();
    getLocation();
  }

  @override
  Widget build(BuildContext context) {
    Size _size = MediaQuery.of(context).size;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: _size.width * 0.067),
      height: _size.height,
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: _size.height * 0.08),
            Row(
              children: [
                Text(
                  'Set your location',
                  style: HomeFiTextTheme.kSub2HeadTextStyle
                      .copyWith(color: Theme.of(context).primaryColorDark),
                ),
                Spacer(),
                TextButton(
                    child: Icon(Icons.logout),
                    onPressed: () {
                      GetIt.I<APIServices>().logout().then((value) => Get.off(
                          () => ResponsiveSizer(
                                  builder: (context, orientation, screenType) {
                                return AuthScreen();
                              })));
                    }),
              ],
            ),
            SizedBox(height: _size.height * 0.02),
            Container(
              height: _size.height * 0.6,
              child: GoogleMap(
                mapType: MapType.hybrid,
                myLocationButtonEnabled: true,
                myLocationEnabled: true,
                trafficEnabled: true,
                initialCameraPosition: pos,
                onMapCreated: (GoogleMapController controller) {
                  getLocation();
                  _controller.complete(controller);
                },
                onLongPress: (coord) {
                  GetIt.I<APIServices>()
                      .setLocation(location: coord)
                      .then((value) {
                    if (value == true) {
                      SnackbarMessage(
                        message: "Location set",
                        icon: Icon(Icons.error, color: Colors.red),
                      ).showMessage(
                        context,
                      );
                    } else {
                      SnackbarMessage(
                        message: "Not authorized",
                        icon: Icon(Icons.error, color: Colors.red),
                      ).showMessage(
                        context,
                      );
                    }
                  });
                },
              ),
            ),
            SizedBox(height: _size.height * 0.05),
            Text(
              "Edit your Informations",
              style: HomeFiTextTheme.kSub2HeadTextStyle
                  .copyWith(color: Theme.of(context).primaryColorDark),
            ),
            SizedBox(height: _size.height * 0.05),
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(
                labelText: 'New Username',
              ),
            ),
            SizedBox(height: _size.height * 0.02),
            OutlinedButton(
                child: Text('Update'),
                onPressed: () {
                  String newUsername = _usernameController.text;
                  GetIt.I<APIServices>()
                      .updateProfile(data: {'username': newUsername});
                }),
            SizedBox(height: _size.height * 0.02),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: 'New Password',
              ),
            ),
            SizedBox(height: _size.height * 0.05),
            TextField(
              controller: _confirmpasswordController,
              decoration: InputDecoration(
                labelText: 'Confirm New Password',
              ),
            ),
            SizedBox(height: _size.height * 0.02),
            OutlinedButton(
                child: Text('Update'),
                style: ButtonStyle(
                    overlayColor: MaterialStateProperty.all(Colors.white),
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0),
                            side: BorderSide(width: 5, color: Colors.white)))),
                onPressed: () {
                  String newPassword = _passwordController.text;
                  String confirmPassword = _confirmpasswordController.text;
                  if (newPassword == confirmPassword) {
                    GetIt.I<APIServices>()
                        .updateProfile(data: {'password': newPassword});
                  }
                }),
            SizedBox(height: 100),
          ],
        ),
      ),
    );
  }
}
