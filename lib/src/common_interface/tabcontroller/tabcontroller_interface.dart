import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:yod_navigator/presentation/yod_navigator/yod_navigator.dart';

abstract class TabcontrollerInterface implements TickerProvider {
  TabController? _tabController;
  @override
  Ticker createTicker(TickerCallback onTick) {
    return Ticker(onTick);
  }

  void initTabController({required int length}) {
    _tabController = TabController(
      length: length,
      vsync: this,
      animationDuration: const Duration(milliseconds: 0),
    );
  }

  TabController get getTabcontroller {
    if (_tabController == null) {
      throw Exception("TabcontrollerInterface : TabController is null");
    }
    return _tabController!;
  }

  void dispose() {
    _tabController?.dispose();
    _tabController = null;
  }

  void animateTo(
    NavBarName navBarName,
    BuildContext? context, {
    bool reload = false,
  }) {
    _tabController?.animateTo(getIndex(navBarName));
  }

  int getIndex(NavBarName navBarName);

  int getCurrent() {
    return _tabController?.index ?? -1;
  }
}
