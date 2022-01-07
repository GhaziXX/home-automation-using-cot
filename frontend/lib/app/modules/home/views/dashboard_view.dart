import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:flutter/material.dart';
import 'package:frontend/app/data/models/profile.dart';
import 'package:frontend/app/data/models/room.dart';
import 'package:frontend/app/data/models/sensor.dart';
import 'package:frontend/app/data/provider/api_services.dart';
import 'package:frontend/app/global_widgets/snackbar.dart';
import 'package:frontend/app/theme/color_theme.dart';

import 'package:geolocator/geolocator.dart';

import 'package:get/get.dart';
import 'package:frontend/app/global_widgets/room_selector.dart';
import 'package:frontend/app/modules/home/controllers/home_controller.dart';

import 'package:frontend/app/theme/text_theme.dart';
import 'package:get_it/get_it.dart';
import 'package:maps_toolkit/maps_toolkit.dart';

String cleanValue(Sensor sensor) {
  String text;
  if (sensor.id == 'temphum') {
    var temphum = sensor.value.toString().split(',');
    var temp = temphum[1].split(':')[1];
    var hum = temphum[0].split(':')[1];
    text = temp + ',' + hum;
  } else if (sensor.id!.contains('led') || sensor.id!.contains('pir')) {
    if (sensor.value == 'true') {
      text = 'on';
    } else
      text = 'off';
  } else if (sensor.id!.contains('servo')) {
    if (sensor.value == 'true') {
      text = 'opened';
    } else
      text = 'closed';
  } else {
    text = double.parse(sensor.value).toStringAsFixed(2);
  }
  return text;
}

class Dashborad extends StatefulWidget {
  const Dashborad({Key? key}) : super(key: key);

  @override
  _DashboradState createState() => _DashboradState();
}

class _DashboradState extends State<Dashborad> {
  final _sensorNameController = TextEditingController();
  final _sensorPinController = TextEditingController();
  List<bool> selectedRoom = [];
  var roomId;
  List<Sensor> sensors = [];
  List<Room> rooms = [];
  Room newRoom = Room(sensors: [], id: 'add');
  String newRoomName = "";
  Profile user = Profile(
      authorized: false,
      forename: '',
      surname: '',
      email: '',
      username: '',
      permission: 0,
      fullname: '',
      id: '');

  void getRooms() async {
    var x = await GetIt.I<APIServices>().listRooms(page: 0, limit: 15);
    setState(() {
      x.add(newRoom);
      rooms = x;
    });
  }

  void getProfile() async {
    var x = await GetIt.I<APIServices>().profile();
    setState(() {
      user = x;
    });
  }

  void setSelectedRoomLen() async {
    var x = await GetIt.I<APIServices>().listRooms(page: 0, limit: 15);
    setState(() {
      selectedRoom = List.filled(x.length + 1, false);
    });
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    return await Geolocator.getCurrentPosition();
  }

  @override
  void initState() {
    super.initState();
    setSelectedRoomLen();
    getRooms();
    getProfile();
  }

  @override
  Widget build(BuildContext context) {
    Size size = Get.size;
    return Container(
        padding: EdgeInsets.symmetric(horizontal: size.width * 0.067),
        height: size.height,
        width: size.width,
        color: Theme.of(context).scaffoldBackgroundColor,
        child: SingleChildScrollView(
            child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
              SizedBox(height: size.height * 0.08),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Welcome\nHome, ${user.forename}',
                    style: HomeFiTextTheme.kSubHeadTextStyle
                        .copyWith(color: Theme.of(context).primaryColorDark),
                  ),
                ],
              ),
              SizedBox(height: size.height * 0.03),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(
                  'Rooms',
                  style: HomeFiTextTheme.kSub2HeadTextStyle
                      .copyWith(color: Theme.of(context).primaryColorDark),
                ),
                SizedBox(height: size.height * 0.02),
                Container(
                  width: size.width,
                  height: size.height * 0.12,
                  child: Theme(
                    data: Theme.of(context),
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: rooms.length,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          child: RoomSelector(
                            roomName: rooms[index].id,
                            roomImageURL:
                                'assets/icons/${rooms[index].id!}.svg',
                            isSelected: selectedRoom[index],
                          ),
                          onTap: () async {
                            if (index == rooms.length - 1) {
                              newRoomName = await showTextInputDialog(
                                context: context,
                                textFields: const [
                                  DialogTextField(hintText: "Room Name"),
                                ],
                                title: 'Add room',
                                okLabel: 'add',
                              ).then((value) => value
                                  .toString()
                                  .substring(1, value.toString().length - 1));
                              rooms.add(Room(sensors: [], id: newRoomName));
                              selectedRoom = List<bool>.filled(
                                  rooms.length, false,
                                  growable: true);
                              selectedRoom.add(true);
                            } else
                              roomId = rooms[index].id;
                            sensors = await GetIt.I<APIServices>()
                                .listSensorsByRoom(roomId: roomId);
                            setState(() {
                              selectedRoom = List<bool>.filled(
                                  rooms.length, false,
                                  growable: true);
                              selectedRoom[index] = true;
                            });
                          },
                        );
                      },
                    ),
                  ),
                ),
                SizedBox(height: size.height * 0.02),
              ]),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(
                  'Sensors',
                  style: HomeFiTextTheme.kSub2HeadTextStyle
                      .copyWith(color: Theme.of(context).primaryColorDark),
                ),
                Container(
                    width: size.width,
                    height: sensors.length == 0 ? 0 : size.height * 0.5,
                    child: GridView.builder(
                      physics: NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithMaxCrossAxisExtent(
                              maxCrossAxisExtent: 200,
                              childAspectRatio: 3 / 2,
                              crossAxisSpacing: 20,
                              mainAxisSpacing: 20),
                      itemCount: sensors.length,
                      itemBuilder: (BuildContext context, index) {
                        return GestureDetector(
                          child: SensorBanner(
                            img: 'assets/icons/${sensors[index].id}.png',
                            title: '${sensors[index].id}',
                            horizontalPadding: Get.width * 0.046,
                            child: Text(
                              '${cleanValue(sensors[index])}',
                              style:
                                  HomeFiTextTheme.kSub2HeadTextStyle.copyWith(
                                color: Theme.of(context).primaryColorDark,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          onTap: () async {
                            if (sensors[index].id!.contains("servo")) {
                              Position position = await _determinePosition();
                              LatLng p =
                                  LatLng(position.latitude, position.longitude);
                              List<double> homePosition =
                                  await GetIt.I<APIServices>().getLocation();
                              LatLng hp =
                                  LatLng(homePosition[0], homePosition[1]);
                              var distanceBetweenPoints =
                                  SphericalUtil.computeDistanceBetween(p, hp);
                              if (distanceBetweenPoints < 10) {
                                await GetIt.I<APIServices>()
                                    .setStateOfConnectedObject(
                                        roomId: sensors[index].roomId,
                                        objectId: sensors[index].id,
                                        state:
                                            !(sensors[index].value == 'true'));
                              } else {
                                SnackbarMessage(
                                  message: "You are far away",
                                  icon: Icon(Icons.error, color: Colors.red),
                                ).showMessage(
                                  context,
                                );
                              }
                            } else {
                              await GetIt.I<APIServices>()
                                  .setStateOfConnectedObject(
                                      roomId: sensors[index].roomId,
                                      objectId: sensors[index].id,
                                      state: !(sensors[index].value == 'true'));
                            }
                          },
                        );
                      },
                    )),
                SizedBox(height: size.height * 0.02),
                Text(
                  'Add sensors',
                  style: HomeFiTextTheme.kSub2HeadTextStyle
                      .copyWith(color: Theme.of(context).primaryColorDark),
                ),
                SizedBox(height: size.height * 0.02),
                TextField(
                  controller: _sensorNameController,
                  decoration: InputDecoration(
                    labelText: 'Sensor name',
                  ),
                ),
                SizedBox(height: size.height * 0.02),
                TextFormField(
                  controller: _sensorPinController,
                  decoration: InputDecoration(labelText: "Sensor pin"),
                ),
                SizedBox(height: size.height * 0.02),
                OutlinedButton(
                    child: Text("Add"),
                    onPressed: () {
                      setState(() {});
                      String sensorName = _sensorNameController.text;
                      int sensorPin = int.parse(_sensorPinController.text);
                      GetIt.I<APIServices>().addConnectedObject(
                          roomId: roomId, objectId: sensorName, pin: sensorPin);
                    }),
                SizedBox(
                  height: 100,
                )
              ])
            ])));
  }
}

class DashboardView extends GetView<HomeController> {
  @override
  Widget build(BuildContext context) {
    Size size = Get.size;
    return Dashborad();
  }
}

class SensorBanner extends StatefulWidget {
  final double? horizontalPadding;
  final String? img;
  final String? title;
  final Widget? child;
  SensorBanner({
    Key? key,
    required this.img,
    required this.title,
    required this.horizontalPadding,
    required this.child,
  }) : super(key: key);

  @override
  _SensorBannerState createState() => _SensorBannerState();
}

class _SensorBannerState extends State<SensorBanner> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: Get.height * 0.08,
      width: Get.width * 0.38,
      padding: EdgeInsets.symmetric(
          horizontal: widget.horizontalPadding!, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border.all(
          color: Theme.of(context).primaryColor,
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image(
            image: AssetImage(
              widget.img!,
            ),
            height: 40,
            errorBuilder: (context, error, stackTrace) => Image.asset(
              'assets/icons/sensor.png',
              height: 40,
            ),
          ),
          SizedBox(
            width: 10,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Spacer(flex: 4),
              widget.child!,
              Spacer(flex: 2),
              Text(
                widget.title!,
                style: HomeFiTextTheme.kSub2HeadTextStyle.copyWith(
                  color: Theme.of(context).primaryColorDark,
                  fontSize: 12,
                ),
              ),
              Spacer(flex: 4),
            ],
          ),
        ],
      ),
    );
  }
}
