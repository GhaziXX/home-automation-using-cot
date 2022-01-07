import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:flutter/material.dart';
import 'package:frontend/app/data/models/profile.dart';
import 'package:frontend/app/data/provider/api_services.dart';
import 'package:frontend/app/theme/color_theme.dart';
import 'package:frontend/app/theme/text_theme.dart';

import 'package:get/get.dart';
import 'package:get_it/get_it.dart';

import '../controllers/list_users_controller.dart';

class ListUsers extends StatefulWidget {
  const ListUsers({Key? key}) : super(key: key);

  @override
  _ListUsersState createState() => _ListUsersState();
}

class _ListUsersState extends State<ListUsers> {
  List<Profile> users = [];
  void getUsers() async {
    var x = await GetIt.I<APIServices>().listUsers(page: 0, limit: 15);
    setState(() {
      users = x;
    });
  }

  @override
  void initState() {
    super.initState();
    getUsers();
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: size.height * 0.08),
            Text(
              'Users',
              style: HomeFiTextTheme.kSub2HeadTextStyle
                  .copyWith(color: Theme.of(context).primaryColorDark),
            ),
            Container(
              height: size.height * 0.8,
              width: size.width,
              child: ListView.separated(
                  separatorBuilder: (BuildContext context, int index) {
                    return SizedBox(
                      height: 10,
                    );
                  },
                  scrollDirection: Axis.vertical,
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    return UserBanner(
                      username: users[index].username,
                      permission: users[index].permission,
                      id: users[index].id,
                    );
                  }),
            )
          ],
        ),
      ),
    );
  }
}

class ListUsersView extends GetView<ListUsersController> {
  @override
  Widget build(BuildContext context) {
    return ListUsers();
  }
}

class UserBanner extends StatefulWidget {
  final String username;
  final int permission;
  final String id;

  const UserBanner(
      {Key? key,
      required this.username,
      required this.permission,
      required this.id})
      : super(key: key);

  @override
  _UserBannerState createState() => _UserBannerState();
}

class _UserBannerState extends State<UserBanner> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10),
      height: Get.height * 0.08,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border.all(
          color: Theme.of(context).primaryColor,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Spacer(flex: 4),
              Text(
                widget.username,
                style: HomeFiTextTheme.kSub2HeadTextStyle.copyWith(
                  color: Theme.of(context).primaryColorDark,
                  fontSize: 18,
                ),
              ),
              Spacer(flex: 2),
              Text(
                "permission : " + widget.permission.toString(),
                style: HomeFiTextTheme.kSub2HeadTextStyle.copyWith(
                  color: Theme.of(context).primaryColorDark,
                  fontSize: 12,
                ),
              ),
              Spacer(flex: 4),
            ],
          ),
          Spacer(flex: 4),
          Spacer(flex: 4),
          IconButton(
              onPressed: () async {
                String permission = await showTextInputDialog(
                  context: context,
                  textFields: const [
                    DialogTextField(hintText: "permission"),
                  ],
                  title: 'Set permission',
                  okLabel: 'set',
                ).then((value) => value![0]);
                print(permission);
                await GetIt.I<APIServices>().updatePermessionById(
                    id: widget.id, permission: int.parse(permission));
              },
              icon: Icon(
                Icons.upgrade,
                color: GFTheme.primaryColor,
              )),
          IconButton(
              onPressed: () async {
                await GetIt.I<APIServices>().deleteUserById(id: widget.id);
              },
              icon: Icon(
                Icons.delete,
                color: GFTheme.primaryColor,
              ))
        ],
      ),
    );
  }
}
