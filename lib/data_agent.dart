import 'package:xgboostranker_app/driver_vo.dart';
import 'package:xgboostranker_app/constructor_vo.dart';
import 'package:xgboostranker_app/search_item.dart';

abstract class DataAgent {
  Future<DriverVO>? getDriver(String id);

  Future<ConstructorVO>? getConstructor(String id);

  Future<List<SearchItem>> searchAll(String query);
}