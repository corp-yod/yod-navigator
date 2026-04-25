import 'package:go_router/go_router.dart';
import 'package:yod_navigator/yod_navigator.dart';

abstract class YodRouterModule {
  void init();

  // แทนที่จะส่งเป็น Set ของ String เราจะส่ง Set ของ GoRoute ไปประกอบร่าง
  List<YodRouteBase> routes();

  // (Optional) ถ้ามีเงื่อนไข Redirect เฉพาะ Module เช่น เช็กสิทธิ์การเข้าถึงหน้าใน Domain นี้
  String? redirect(GoRouterState state) => null;
}
