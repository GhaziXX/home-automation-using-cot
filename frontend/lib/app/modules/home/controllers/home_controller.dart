import 'dart:async';

import 'package:flutter/material.dart';
import 'package:frontend/app/data/models/room.dart';
import 'package:frontend/app/data/models/sensor.dart';
import 'package:frontend/app/data/provider/api_services.dart';
import 'package:get/get.dart';

import 'package:frontend/app/modules/connected_device/views/connected_device_view.dart';
import 'package:frontend/app/modules/home/views/dashboard_view.dart';
import 'package:frontend/app/modules/home/views/settings_view.dart';
import 'package:get_it/get_it.dart';

class HomeController extends GetxController {
  // bottom nav current index.
  RxInt _currentIndex = 0.obs;
  get currentIndex => this._currentIndex.value;

  // userData
  String userName = 'Jobin';

  // List of bools for selected room
  List<bool> selectedRoom = [true, false, false, false, false];

  // the list of screens switched by bottom navBar
  final List<Widget> homeViews = [
    DashboardView(),
    ConnectedDeviceView(),
    SettingsView(),
  ];

  // Future<List<Room>> get rooms async {
  //   List<Room> rooms =
  //       await GetIt.I<APIServices>().listRooms(page: 0, limit: 15);
  //   return rooms;
  // }

  Future<List<Room>> rooms =
      GetIt.I<APIServices>().listRooms(page: 0, limit: 15);

  Room newRoom = Room(sensors: [], id: "add");

  List<bool> _isToggled = [];
  void set isToggled(length) {
    _isToggled = List.generate(length, (index) => false);
  }

  // Sensor & Sensor from sensor;
  late StreamController<Sensor> tempStream;
  late StreamController<Sensor> humidStream;
  late StreamController<Sensor> luminosityStream;
  late StreamController<Sensor> motionStream;
  late StreamController<Sensor> smokeStream;
  late StreamController<Sensor> gasStream;

  // funtion to set current index
  setCurrentIndex(int index) {
    _currentIndex.value = index;
    if (index == 1 || index == 2) {
      tempStream.close();
      humidStream.close();
      luminosityStream.close();
      motionStream.close();
      smokeStream.close();
      gasStream.close();
    } else if (index == 0) {
      streamInit();
    }
  }

  // function to return correct view on bottom navBar switch
  Widget navBarSwitcher() {
    return homeViews.elementAt(currentIndex);
  }

  // function to move between each room
  void roomChange(int index) {
    selectedRoom = [false, false, false, false, false];
    selectedRoom[index] = true;
    update([1, true]);
  }

  streamInit() {
    tempStream = StreamController();
    humidStream = StreamController();
    luminosityStream = StreamController();
    motionStream = StreamController();
    smokeStream = StreamController();
    gasStream = StreamController();
    Timer.periodic(
      Duration(seconds: 1),
      (_) {},
    );
  }

  @override
  void onInit() {
    rooms.then((value) => value.add(newRoom));
    streamInit();
    super.onInit();
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
    tempStream.close();
    humidStream.close();
    luminosityStream.close();
    motionStream.close();
    smokeStream.close();
    gasStream.close();
  }
}
