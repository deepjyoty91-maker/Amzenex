import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:medmylife/core/error/failures.dart';
import 'package:medmylife/features/appointments/domain/models/appointment_model.dart';

abstract class AppointmentLocalDataSource {
  Future<List<AppointmentModel>> getAppointments();
  Future<void> saveAppointment(AppointmentModel appointment);
  Future<void> updateAppointment(AppointmentModel appointment);
  Future<void> clearAppointments();
}

class AppointmentLocalDataSourceImpl implements AppointmentLocalDataSource {
  static const String boxName = 'appointments_cache_box';
  static const String appointmentsKey = 'appointments_list';

  @override
  Future<List<AppointmentModel>> getAppointments() async {
    try {
      final box = await Hive.openBox(boxName);
      final rawData = box.get(appointmentsKey);
      if (rawData != null && rawData is String) {
        final List<dynamic> jsonList = jsonDecode(rawData);
        return jsonList
            .map((e) => AppointmentModel.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      }
      return [];
    } catch (e) {
      throw CacheException('Failed to read saved appointments: $e');
    }
  }

  @override
  Future<void> saveAppointment(AppointmentModel appointment) async {
    final list = await getAppointments();
    list.add(appointment);
    await _persistList(list);
  }

  @override
  Future<void> updateAppointment(AppointmentModel appointment) async {
    final list = await getAppointments();
    final index = list.indexWhere((a) => a.id == appointment.id);
    if (index != -1) {
      list[index] = appointment;
      await _persistList(list);
    }
  }

  @override
  Future<void> clearAppointments() async {
    final box = await Hive.openBox(boxName);
    await box.delete(appointmentsKey);
  }

  Future<void> _persistList(List<AppointmentModel> list) async {
    final box = await Hive.openBox(boxName);
    final jsonString = jsonEncode(list.map((a) => a.toJson()).toList());
    await box.put(appointmentsKey, jsonString);
  }
}
