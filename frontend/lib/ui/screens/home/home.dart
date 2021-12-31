import 'package:flutter/material.dart';
import 'package:frontend/core/extensions/context.dart';
import 'package:frontend/ui/screens/home/widgets/header_app_bar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollController = ScrollController();

  double appBarHeight = 0;
  bool showTitle = false;

  @override
  void initState() {
    _scrollController.addListener(_onScroll);

    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();

    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;

    final offset = _scrollController.offset;

    setState(() {
      showTitle = offset > appBarHeight - kToolbarHeight;
    });
  }

  @override
  Widget build(BuildContext context) {
    appBarHeight = context.screenSize.height * HeaderAppBar.heightFraction;

    return Scaffold(
      body: NestedScrollView(
        controller: _scrollController,
        headerSliverBuilder: (_, __) => [
          HeaderAppBar(
            height: appBarHeight,
            showTitle: showTitle,
          ),
        ],
        body: const Center(),
      ),
    );
  }
}
