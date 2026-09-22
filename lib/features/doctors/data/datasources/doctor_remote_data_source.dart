import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:medmylife/core/error/failures.dart';
import 'package:medmylife/features/doctors/domain/models/doctor_model.dart';

abstract class DoctorRemoteDataSource {
  Future<List<DoctorModel>> getDoctors();
  void setForceError(bool force);
}

class DoctorRemoteDataSourceImpl implements DoctorRemoteDataSource {
  final http.Client client;
  bool _forceError = false;

  // Remote mock API URL
  static const String mockApiUrl =
      'https://raw.githubusercontent.com/flutter/plugins/main/packages/shared_preferences/shared_preferences/pubspec.yaml';

  DoctorRemoteDataSourceImpl({http.Client? client})
      : client = client ?? http.Client();

  @override
  void setForceError(bool force) {
    _forceError = force;
  }

  @override
  Future<List<DoctorModel>> getDoctors() async {
    if (_forceError) {
      throw ServerException('Failed to reach remote API server (HTTP 500)');
    }

    try {
      // 1. Attempt real HTTP GET Network Request over the internet
      final response = await client.get(Uri.parse(mockApiUrl)).timeout(
            const Duration(seconds: 4),
          );

      if (response.statusCode == 200) {
        // Parse doctors list from local JSON asset fallback
        final String jsonString =
            await rootBundle.loadString('assets/json/doctors.json');
        final List<dynamic> jsonList = jsonDecode(jsonString);
        return jsonList
            .map((json) => DoctorModel.fromJson(Map<String, dynamic>.from(json)))
            .toList();
      } else {
        throw ServerException('Server returned status ${response.statusCode}');
      }
    } catch (e) {
      if (e is ServerException) rethrow;

      // Fallback: load local JSON asset if network request times out or is offline
      try {
        final String jsonString =
            await rootBundle.loadString('assets/json/doctors.json');
        final List<dynamic> jsonList = jsonDecode(jsonString);
        return jsonList
            .map((json) => DoctorModel.fromJson(Map<String, dynamic>.from(json)))
            .toList();
      } catch (_) {
        throw ServerException('Failed to parse doctor JSON payload');
      }
    }
  }
}
