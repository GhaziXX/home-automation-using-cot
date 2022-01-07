import 'dart:async';

import 'package:flutter/material.dart';
import 'package:frontend/app/data/provider/api_services.dart';
import 'package:frontend/app/modules/auth/auth.dart';
import 'package:frontend/app/modules/auth/signin/views/signin_view.dart';
import 'package:get/get.dart';
import 'package:get_it/get_it.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  Completer<GoogleMapController> _controller = Completer();

  CameraPosition pos = CameraPosition(
      target: LatLng(36.93995593184964, 10.223821364343166), zoom: 15);

  void getLocation() async {
    LatLng _pos = await GetIt.I<APIServices>().getLocation();
    print("zna hna $_pos");
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
    double _size = MediaQuery.of(context).size.height;

    return new Scaffold(
        body: Center(
      child: Column(
        children: [
          Container(
            height: _size * 0.8,
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
                    .then((value) => print(value));
              },
            ),
          ),
          OutlinedButton(
              child: Text('logout'),
              onPressed: () {
                GetIt.I<APIServices>()
                    .logout()
                    .then((value) => Get.off(() => AuthScreen()));
              },
              style: OutlinedButton.styleFrom(
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18.0),
                      side:
                          BorderSide(color: Theme.of(context).primaryColor)))),
        ],
      ),
    ));
  }
}
