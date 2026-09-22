import 'package:medmylife/core/error/failures.dart';
import 'package:medmylife/core/network/network_info.dart';
import 'package:medmylife/features/doctors/data/datasources/doctor_local_data_source.dart';
import 'package:medmylife/features/doctors/data/datasources/doctor_remote_data_source.dart';
import 'package:medmylife/features/doctors/domain/models/doctor_model.dart';

class DoctorFetchResult {
  final List<DoctorModel> doctors;
  final bool isFromCache;
  final String? warningMessage;

  const DoctorFetchResult({
    required this.doctors,
    required this.isFromCache,
    this.warningMessage,
  });
}

abstract class DoctorRepository {
  Future<DoctorFetchResult> getDoctors({bool forceRefresh = false});
}

class DoctorRepositoryImpl implements DoctorRepository {
  final DoctorRemoteDataSource remoteDataSource;
  final DoctorLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  DoctorRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<DoctorFetchResult> getDoctors({bool forceRefresh = false}) async {
    final isConnected = await networkInfo.isConnected;

    if (isConnected) {
      try {
        final remoteDoctors = await remoteDataSource.getDoctors();
        await localDataSource.cacheDoctors(remoteDoctors);
        return DoctorFetchResult(
          doctors: remoteDoctors,
          isFromCache: false,
        );
      } catch (_) {
        return _fallbackToCache('Server unreachable. Displaying cached doctors.');
      }
    } else {
      return _fallbackToCache('You are offline. Displaying cached doctors.');
    }
  }

  Future<DoctorFetchResult> _fallbackToCache(String warningMsg) async {
    try {
      final cachedDoctors = await localDataSource.getCachedDoctors();
      if (cachedDoctors.isNotEmpty) {
        return DoctorFetchResult(
          doctors: cachedDoctors,
          isFromCache: true,
          warningMessage: warningMsg,
        );
      }
      throw const NetworkFailure('No internet connection and no cached data available.');
    } catch (e) {
      if (e is Failure) rethrow;
      throw const CacheFailure('Failed to load doctors from local storage.');
    }
  }
}
