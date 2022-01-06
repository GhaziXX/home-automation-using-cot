import 'dart:async';
import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:frontend/app/data/models/room.dart';
import 'package:frontend/app/data/provider/api_services.dart';
import 'package:get/get.dart';

import 'package:frontend/app/data/provider/TempHumidAPI.dart';
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

  Future<List<Room>> get rooms async {
    List<Room> rooms =
        await GetIt.I<APIServices>().listRooms(page: 0, limit: 15);
    return rooms;
  }

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

  // switches in the room
  onSwitched(int index) {
    isToggled[index] = !isToggled[index];
    if (index == 0) {
      var value = isToggled[index] ? "1" : "0";
      TempHumidAPI.updateLed1Data(value);
    }
    if (index == 1) {
      var value = isToggled[index] ? "#ffffff" : "#000000";
      TempHumidAPI.updateRGBdata(value);
    }
    update([2, true]);
  }

  // function to retreve sensor data
  retrieveSensorData() async {
    // Sensor temperature data fetch
    Sensor temper = await TempHumidAPI.getTempData();
    tempStream.add(temper);

    // Sensor humidity data fetch
    Sensor humid = await TempHumidAPI.getHumidData();
    humidStream.add(humid);
  }

  getSmartSystemStatus() async {
    var data = await TempHumidAPI.getLed1Data();
    var rgbData = await TempHumidAPI.getRGBstatus();
    var value = int.parse(data.value!);
    if (value == 1) {
      isToggled[0] = true;
    } else if (value == 0) {
      isToggled[0] = false;
    }
    if (rgbData.value?.compareTo("#000000") == 0) {
      isToggled[1] = false;
    } else {
      isToggled[1] = true;
    }
    update([2, true]);
  }

  sendRGBColor(String hex) {
    TempHumidAPI.updateRGBdata(hex);
  }

  streamInit() {
    tempStream = StreamController();
    humidStream = StreamController();
    luminosityStream = StreamController();
    motionStream = StreamController();
    smokeStream = StreamController();
    gasStream = StreamController();
    Timer.periodic(
      Duration(seconds: 3),
      (_) {
        getSmartSystemStatus();
        retrieveSensorData();
      },
    );
  }

  @override
  void onInit() {
    rooms.add(newRoom);
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