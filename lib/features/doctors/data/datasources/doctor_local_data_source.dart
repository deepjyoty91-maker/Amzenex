import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:medmylife/core/error/failures.dart';
import 'package:medmylife/features/doctors/domain/models/doctor_model.dart';

abstract class DoctorLocalDataSource {
  Future<List<DoctorModel>> getCachedDoctors();
  Future<void> cacheDoctors(List<DoctorModel> doctors);
  Future<void> clearCache();
}

class DoctorLocalDataSourceImpl implements DoctorLocalDataSource {
  static const String boxName = 'doctors_cache_box';
  static const String doctorsKey = 'cached_doctors_list';

  @override
  Future<List<DoctorModel>> getCachedDoctors() async {
    try {
      final box = await Hive.openBox(boxName);
      final rawData = box.get(doctorsKey);
      if (rawData != null && rawData is String) {
        final List<dynamic> jsonList = jsonDecode(rawData);
        return jsonList.map((e) => DoctorModel.fromJson(Map<String, dynamic>.from(e))).toList();
      }
      return [];
    } catch (e) {
      throw CacheException('Failed to read cached doctors: $e');
    }
  }

  @override
  Future<void> cacheDoctors(List<DoctorModel> doctors) async {
    try {
      final box = await Hive.openBox(boxName);
      final jsonString = jsonEncode(doctors.map((d) => d.toJson()).toList());
      await box.put(doctorsKey, jsonString);
    } catch (e) {
      throw CacheException('Failed to write cached doctors: $e');
    }
  }

  @override
  Future<void> clearCache() async {
    final box = await Hive.openBox(boxName);
    await box.delete(doctorsKey);
  }
}
