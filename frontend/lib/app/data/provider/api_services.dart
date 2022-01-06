import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:frontend/app/data/models/login.dart';
import 'package:frontend/app/data/models/profile.dart';
import 'package:frontend/app/data/models/room.dart';
import 'package:frontend/app/data/models/sensor.dart';
import 'package:frontend/app/data/models/signup.dart';
import 'package:frontend/app/oauth/oauth_lib.dart';
import 'package:get_it/get_it.dart';

class APIServices {
  Future<Login> login({required email, required password}) async {
    try {
      var x = await GetIt.I<OAuthSettings>()
          .oauth
          .requestTokenAndSave(PasswordGrant(email: email, password: password));
      print('dd ${x.accessToken}');
      return Login(loggedIn: true, message: "loggedIn");
    } on DioError catch (e) {
      return Login.fromJson(e.response!.data);
    }
  }

  Future<SignUp> register(
      {required forename,
      required surname,
      required email,
      required password,
      required username,
      permission = 1}) async {
    FlutterSecureStorage storage = const FlutterSecureStorage();
    Dio dio = Dio();
    final request = RequestOptions(
        method: 'POST',
        path: '/',
        contentType: 'application/json',
        data: {
          "forename": forename,
          "surname": surname,
          "email": email,
          "password": password,
          "username": username,
          "permission": permission
        });
    try {
      var resp = await dio.request(
          "https://api.homeautomationcot.me/auth/signup",
          data: request.data,
          options: Options(
              contentType: request.contentType, method: request.method));
      await storage.write(key: "id", value: resp.data["id"]);
      return SignUp.fromJson(resp.data);
    } on DioError catch (e) {
      return SignUp.fromJson(e.response!.data);
    }
  }

  Future<Profile> profile() async {
    final request = RequestOptions(
      path: '/',
      contentType: 'application/json',
    );
    try {
      var resp = await GetIt.I<OAuthSettings>().authenticatedDio.get(
          "https://api.homeautomationcot.me/profile",
          options: Options(contentType: request.contentType));
      return Profile.fromJson(resp.data);
    } on DioError catch (e) {
      var data = {
        "ok": false,
      };
      return Profile.fromJson(data);
    }
  }

  Future<List<Profile>> listUsers({required page, required limit}) async {
    final request = RequestOptions(
      path: '/',
      contentType: 'application/json',
    );
    try {
      var resp = await GetIt.I<OAuthSettings>().authenticatedDio.get(
          "https://api.homeautomationcot.me/users?page=$page&limit=$limit",
          options: Options(contentType: request.contentType));

      return resp.data["message"].map<Profile>((e) {
        return Profile.fromJson({"ok": true, "message": e});
      }).toList();
    } on DioError catch (e) {
      print(e.response);
      var data = {
        "ok": false,
      };
      return [Profile.fromJson(data)];
    }
  }

  Future<Profile> getUserById({required id}) async {
    final request = RequestOptions(
      path: '/',
      contentType: 'application/json',
    );
    try {
      var resp = await GetIt.I<OAuthSettings>().authenticatedDio.get(
          "https://api.homeautomationcot.me/users/$id",
          options: Options(contentType: request.contentType));

      return Profile.fromJson(resp.data);
    } on DioError catch (_) {
      var data = {
        "ok": false,
      };
      return Profile.fromJson(data);
    }
  }

  Future<void> updateProfile({required Map<String, dynamic> data}) async {
    final request = RequestOptions(
      path: '/',
      contentType: 'application/json',
    );
    try {
      FlutterSecureStorage storage = const FlutterSecureStorage();
      String? id = await storage.read(key: "id");
      await GetIt.I<OAuthSettings>().authenticatedDio.patch(
          "https://api.homeautomationcot.me/users/$id",
          data: data,
          options: Options(contentType: request.contentType));
    } on DioError catch (e) {
      print(e.response);
    }
  }

  Future<void> updatePermessionById({required id, required permission}) async {
    final request = RequestOptions(
      path: '/',
      contentType: 'application/json',
    );
    try {
      await GetIt.I<OAuthSettings>().authenticatedDio.patch(
          "https://api.homeautomationcot.me/users/$id",
          data: {"permissions": permission},
          options: Options(contentType: request.contentType));
    } on DioError catch (e) {
      print(e.response);
    }
  }

  Future<void> deleteUserById({required id}) async {
    final request = RequestOptions(
      path: '/',
      contentType: 'application/json',
    );
    try {
      await GetIt.I<OAuthSettings>().authenticatedDio.delete(
          "https://api.homeautomationcot.me/users/$id",
          options: Options(contentType: request.contentType));
    } on DioError catch (e) {
      print(e.response);
    }
  }

  Future<bool> isConnected() async {
    try {
      OAuthToken? token =
          await GetIt.I<OAuthSettings>().oauth.fetchOrRefreshAccessToken();
      return token != null ? true : false;
    } on DioError catch (e) {
      print(e.response);
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<void> logout() async {
    FlutterSecureStorage storage = const FlutterSecureStorage();
    await storage.deleteAll();
  }

  Future<Sensor> addConnectedObject(
      {required String roomId,
      required String objectId,
      required int pin}) async {
    final request = RequestOptions(
      path: '/',
      data: {"roomId": roomId, "sensorId": objectId, "pin": pin},
      contentType: 'application/json',
    );
    try {
      var resp = await GetIt.I<OAuthSettings>().authenticatedDio.post(
          "https://api.homeautomationcot.me/mqtt/addObject",
          data: request.data,
          options: Options(contentType: request.contentType));
      return Sensor(value: null, id: objectId, roomId: roomId);
    } on DioError catch (e) {
      return Sensor(value: e.response!.data["message"], id: null, roomId: null);
    }
  }

  Future<String> removeConnectedObject(
      {required String roomId, required String objectId}) async {
    final request = RequestOptions(
      path: '/',
      data: {"roomId": roomId, "sensorId": objectId},
      contentType: 'application/json',
    );
    try {
      var resp = await GetIt.I<OAuthSettings>().authenticatedDio.post(
          "https://api.homeautomationcot.me/mqtt/removeObject",
          data: request.data,
          options: Options(contentType: request.contentType));
      return resp.data["message"];
    } on DioError catch (e) {
      return e.response!.data["message"];
    }
  }

  Future<String> setStateOfConnectedObject({
    required String roomId,
    required String objectId,
    required bool state,
  }) async {
    final request = RequestOptions(
      path: '/',
      data: {
        "roomId": roomId,
        "sensorId": objectId,
        "action": {'on': state}
      },
      contentType: 'application/json',
    );
    try {
      var resp = await GetIt.I<OAuthSettings>().authenticatedDio.post(
          "https://api.homeautomationcot.me/mqtt/setState",
          data: request.data,
          options: Options(contentType: request.contentType));
      return resp.data["message"];
    } on DioError catch (e) {
      return e.response!.data["message"];
    }
  }

  Future<Sensor> getsetStateOfConnectedObject(
      {required String roomId, required String objectId}) async {
    final request = RequestOptions(
      path: '/',
      method: 'GET',
      data: {"roomId": roomId, "sensorId": objectId},
      contentType: 'application/json',
    );
    final Dio dio = Dio();
    try {
      var resp = await dio.request(
          "https://api.homeautomationcot.me/mqtt/getState",
          data: request.data,
          options: Options(
              contentType: request.contentType, method: request.method));
      return Sensor(
          value: resp.data["message"]["value"], id: objectId, roomId: roomId);
    } on DioError catch (e) {
      print(e.response!.data["message"]);
      return Sensor(value: e.response!.data["message"], id: null, roomId: null);
    }
  }

  Future<List<Room>> listRooms({required page, required limit}) async {
    final request = RequestOptions(
      path: '/',
      method: 'GET',
      contentType: 'application/json',
    );
    final Dio dio = Dio();
    try {
      var resp = await dio.request(
          "https://api.homeautomationcot.me/mqtt/listRooms?page=$page&limit=$limit",
          options: Options(contentType: request.contentType));

      return resp.data["message"].map<Room>((e) {
        List<Sensor> roomSensors = e["sensors"].map<Sensor>((e) async {
          return await getsetStateOfConnectedObject(
              roomId: e.split("/")[0], objectId: e.split('/')[1]);
        }).toList();
        e["sensors"] = roomSensors;
        return Room.fromJson(e);
      }).toList();
    } on DioError catch (e) {
      print(e.response);
      return [Room(sensors: null, id: null)];
    }
  }
}
