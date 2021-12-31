import 'package:frontend/configs/colors.dart';
import 'package:frontend/models/room.dart';

import '../routes.dart';

const List<Room> rooms = [
  Room(
      name: 'Kitchen',
      color: AppColors.teal,
      route: Routes.room,
      image: "kitchen"),
  Room(
      name: 'Garage',
      color: AppColors.red,
      route: Routes.room,
      image: "garage"),
  Room(
      name: 'Bedroom',
      color: AppColors.blue,
      route: Routes.room,
      image: "bedroom"),
  Room(
      name: 'Saloon',
      color: AppColors.yellow,
      route: Routes.room,
      image: "living-room"),
];
