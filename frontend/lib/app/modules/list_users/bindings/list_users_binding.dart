import 'package:get/get.dart';

import '../controllers/list_users_controller.dart';

class ListUsersBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ListUsersController>(
      () => ListUsersController(),
    );
  }
}
