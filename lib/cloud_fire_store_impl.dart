import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:xgboostranker_app/data_agent.dart';
import 'package:xgboostranker_app/driver_vo.dart';
import 'package:xgboostranker_app/constructor_vo.dart';
import 'package:xgboostranker_app/search_item.dart';

class CloudFireStoreImpl extends DataAgent{
  CloudFireStoreImpl._();

  static final CloudFireStoreImpl _singleton = CloudFireStoreImpl._();

  factory CloudFireStoreImpl() => _singleton;
  
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<DriverVO>? getDriver(String id) => _firestore
      .collection("drivers")
      .doc(id)
      .get()
      .asStream()
      .map((documentSnapshot) => DriverVO.fromJson(documentSnapshot.data() ?? {}))
      .first;
  
  @override
  Future<ConstructorVO>? getConstructor(String id) => _firestore
      .collection("constructors")
      .doc(id)
      .get()
      .asStream()
      .map((documentSnapshot) => ConstructorVO.fromJson(documentSnapshot.data() ?? {}))
      .first;

  @override
  Future<List<SearchItem>> searchAll(String query) async {
    final q = query.trim().toLowerCase();

    if (q.isEmpty) return [];

    final List<SearchItem> results = [];

    // =========================
    // Search drivers
    // =========================
    final driverSnapshot =
    await FirebaseFirestore.instance.collection('drivers').get();

    for (final doc in driverSnapshot.docs) {
      final data = doc.data();

      final fullName =
      (data['fullName'] ?? data['full_name'] ?? '').toString().trim();
      final forename = (data['forename'] ?? '').toString().trim();
      final surname = (data['surname'] ?? '').toString().trim();
      final nationality = (data['nationality'] ?? '').toString().trim();
      final driverRef = (data['driverRef'] ?? '').toString().trim();

      final combinedName = fullName.isNotEmpty
          ? fullName
          : '$forename $surname'.trim();

      final searchableText = [
        combinedName,
        forename,
        surname,
        nationality,
        driverRef,
      ].join(' ').toLowerCase();

      if (searchableText.contains(q)) {
        results.add(
          SearchItem(
            id: doc.id,
            title: combinedName.isNotEmpty ? combinedName : 'Unknown Driver',
            subtitle: nationality.isNotEmpty ? nationality : 'Driver',
            type: 'driver',
          ),
        );
      }
    }

    // =========================
    // Search constructors
    // =========================
    final constructorSnapshot =
    await FirebaseFirestore.instance.collection('constructors').get();

    for (final doc in constructorSnapshot.docs) {
      final data = doc.data();

      final name = (data['name'] ?? '').toString().trim();
      final nationality = (data['nationality'] ?? '').toString().trim();
      final constructorRef = (data['constructorRef'] ?? '').toString().trim();

      final searchableText = [
        name,
        nationality,
        constructorRef,
      ].join(' ').toLowerCase();

      if (searchableText.contains(q)) {
        results.add(
          SearchItem(
            id: doc.id,
            title: name.isNotEmpty ? name : 'Unknown Constructor',
            subtitle: nationality.isNotEmpty ? nationality : 'Constructor',
            type: 'constructor',
          ),
        );
      }
    }

    results.sort((a, b) => a.title.compareTo(b.title));

    return results;
  }

  
}