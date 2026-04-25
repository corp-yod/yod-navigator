// import 'package:flutter/material.dart';
// import 'package:yod_navigator/presentation/yod_navigator/yod_navigator.dart';

// class AppTabController {
//   final TabController tabController;

//   AppTabController({required this.tabController});

//   void animateTo(
//     NavBarName navBarName,
//     BuildContext? context, {
//     bool reload = false,
//   }) {
//     tabController.animateTo(_getIndex(navBarName));
//   }

//   int _getIndex(NavBarName navBarName) {
//     switch (navBarName) {
//       case NavBarName.HOME:
//         return 0;
//       case NavBarName.SEARCH:
//         return 1;
//       case NavBarName.PROFILE:
//         return 2;
//       default:
//         return -1;
//     }
//   }

//   int getCurrent() {
//     return tabController.index;
//   }
// }
