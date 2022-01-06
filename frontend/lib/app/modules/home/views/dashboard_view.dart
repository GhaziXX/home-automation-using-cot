import 'package:flutter/material.dart';
import 'package:frontend/app/data/models/sensor.dart';

import 'package:get/get.dart';
import 'package:frontend/app/global_widgets/room_selector.dart';
import 'package:frontend/app/modules/home/controllers/home_controller.dart';
import 'package:adaptive_dialog/adaptive_dialog.dart';

import 'package:frontend/app/theme/text_theme.dart';

int room_index = 0;

class DashboardView extends GetView<HomeController> {
  final _sensorNameController = TextEditingController();
  final _sensorPinController = TextEditingController();

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
            GetBuilder<HomeController>(
              id: 7,
              builder: (_) {
                int length = controller.rooms.then((value) => value.length);
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Welcome\nHome, ${controller.rooms}',
                      style: HomeFiTextTheme.kSubHeadTextStyle
                          .copyWith(color: Theme.of(context).primaryColorDark),
                    ),
                  ],
                );
              },
            ),
            SizedBox(height: size.height * 0.03),
            GetBuilder<HomeController>(
              init: HomeController(),
              id: 1,
              builder: (_) {
                List<Stream<Sensor>> streams = [
                  controller.tempStream.stream,
                  controller.humidStream.stream,
                  controller.luminosityStream.stream,
                  controller.motionStream.stream,
                  controller.smokeStream.stream,
                  controller.gasStream.stream
                ];
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                          itemCount: controller.rooms.length,
                          itemBuilder: (context, index) {
                            return GestureDetector(
                              child: RoomSelector(
                                roomName: controller.rooms[index].roomName,
                                roomImageURL:
                                    controller.rooms[index].roomImgUrl,
                                isSelected: controller.selectedRoom[index],
                              ),
                              onTap: () async {
                                if (index == controller.rooms.length - 1) {
                                  final roomName = await showTextInputDialog(
                                      context: context,
                                      textFields: const [
                                        DialogTextField(hintText: "Room Name"),
                                      ],
                                      title: 'Add room',
                                      okLabel: 'add');
                                  // add room
                                } else
                                  controller.roomChange(index);
                                room_index = index;
                              },
                            );
                          },
                        ),
                      ),
                    ),
                    SizedBox(height: size.height * 0.02),
                    Text(
                      'Sensors',
                      style: HomeFiTextTheme.kSub2HeadTextStyle
                          .copyWith(color: Theme.of(context).primaryColorDark),
                    ),
                    Container(
                      width: size.width,
                      height: size.height * 0.6,
                      child: GridView.builder(
                          physics: NeverScrollableScrollPhysics(),
                          gridDelegate:
                              const SliverGridDelegateWithMaxCrossAxisExtent(
                                  maxCrossAxisExtent: 200,
                                  childAspectRatio: 3 / 2,
                                  crossAxisSpacing: 20,
                                  mainAxisSpacing: 20),
                          itemCount: 6,
                          itemBuilder: (BuildContext context, index) {
                            return StreamBuilder<Sensor>(
                              stream: streams[index],
                              builder: (context, snapshot) {
                                if (!snapshot.hasData ||
                                    snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                  return SensorBanner(
                                    img: 'assets/icons/temperature.png',
                                    title: 'Temperature',
                                    horizontalPadding: 1,
                                    child: SizedBox(
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                      height: 15,
                                      width: 15,
                                    ),
                                  );
                                } else {
                                  var value;
                                  snapshot.data!.value == 'nan'
                                      ? value = 0
                                      : value =
                                          double.parse(snapshot.data!.value!)
                                              .toInt();
                                  return SensorBanner(
                                    img:
                                        'assets/icons/${snapshot.data!.sensorId}.png',
                                    title: '${snapshot.data!.sensorId}',
                                    horizontalPadding: Get.width * 0.046,
                                    child: Text(
                                      '${snapshot.data!}',
                                      style: HomeFiTextTheme.kSub2HeadTextStyle
                                          .copyWith(
                                        color:
                                            Theme.of(context).primaryColorDark,
                                        fontSize: 18,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  );
                                }
                              },
                            );
                          }),
                    ),
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
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15)),
                        labelText: 'Sensor name',
                      ),
                    ),
                    SizedBox(height: size.height * 0.02),
                    TextFormField(
                      controller: _sensorPinController,
                      decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          labelText: "Sensor pin"),
                    ),
                    SizedBox(height: size.height * 0.02),
                    OutlinedButton(
                        child: Text("Add"),
                        onPressed: () {
                          String sensorName = _sensorNameController.text;
                          String sensorPin = _sensorPinController.text;
                          // bch nzidou sensor
                        },
                        style: ButtonStyle(
                            shape: MaterialStateProperty.all<
                                    RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18.0),
                                    side: BorderSide(color: Colors.red))))),
                    SizedBox(
                      height: 500,
                    )
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class SensorBanner extends GetView<HomeController> {
  final HomeController controller = Get.put(HomeController());
  final double? horizontalPadding;
  final String? img;
  final String? title;
  final Widget? child;

  SensorBanner({
    required this.img,
    required this.title,
    required this.horizontalPadding,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: Get.height * 0.08,
      width: Get.width * 0.38,
      padding:
          EdgeInsets.symmetric(horizontal: horizontalPadding!, vertical: 8),
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
              img!,
            ),
            height: 40,
          ),
          SizedBox(
            width: 10,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Spacer(flex: 4),
              child!,
              Spacer(flex: 2),
              Text(
                title!,
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
