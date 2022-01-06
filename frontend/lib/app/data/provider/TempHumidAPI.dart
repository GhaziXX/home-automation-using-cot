import 'dart:convert';

import 'package:frontend/app/data/models/sensor_model.dart';
import 'package:http/http.dart' as http;

class TempHumidAPI {
  static String username = 'blairripper';
  static String tempFeed = 'temperature';
  static String humidFeed = 'humidity';
  static String led1Feed = 'led-1';
  static String rgbFeed = 'color';
  static String mainURL = 'https://io.adafruit.com/api/v2/';

  static Future<Sensor> getTempData() async {
    http.Response response = await http.get(
      Uri.parse(mainURL + '$username/feeds/$tempFeed'),
      // headers: <String, String>{'X-AIO-Key': !},
    );
    if (response.statusCode == 200) {
      return Sensor.fromRawJson(response.body);
    } else {
      throw Error();
    }
  }

  static Future<Sensor> getHumidData() async {
    http.Response response = await http.get(
      Uri.parse(mainURL + '$username/feeds/$humidFeed'),
      // headers: <String, String>{'X-AIO-Key': aioKey!},
    );
    if (response.statusCode == 200) {
      return Sensor.fromRawJson(response.body);
    } else {
      throw Error();
    }
  }

  static Future<Sensor> getLed1Data() async {
    http.Response response = await http.get(
      Uri.parse(mainURL + '$username/feeds/$led1Feed'),
      // headers: <String, String>{'X-AIO-Key': aioKey!},
    );
    if (response.statusCode == 200) {
      return Sensor.fromRawJson(response.body);
    } else {
      throw Error();
    }
  }

  static Future<bool> updateLed1Data(String value) async {
    http.Response response = await http.post(
      Uri.parse(mainURL + '$username/feeds/$led1Feed/data'),
      headers: <String, String>{
        // 'X-AIO-Key': aioKey!,
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        "datum": {"value": value}
      }),
    );
    if (response.statusCode == 200) {
      return true;
    } else {
      throw Error();
    }
  }

  static Future<Sensor> getRGBstatus() async {
    http.Response response = await http.get(
      Uri.parse(mainURL + '$username/feeds/$rgbFeed'),
      // headers: <String, String>{'X-AIO-Key': aioKey!},
    );
    if (response.statusCode == 200) {
      return Sensor.fromRawJson(response.body);
    } else {
      throw Error();
    }
  }

  static Future<bool> updateRGBdata(String value) async {
    http.Response response = await http.post(
      Uri.parse(mainURL + '$username/feeds/$rgbFeed/data'),
      headers: <String, String>{
        // 'X-AIO-Key': aioKey!,
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        "datum": {"value": value}
      }),
    );
    if (response.statusCode == 200) {
      return true;
    } else {
      throw Error();
    }
  }
}
