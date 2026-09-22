import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:medmylife/core/error/failures.dart';
import 'package:medmylife/core/network/network_info.dart';
import 'package:medmylife/features/doctors/data/datasources/doctor_local_data_source.dart';
import 'package:medmylife/features/doctors/data/datasources/doctor_remote_data_source.dart';
import 'package:medmylife/features/doctors/data/repositories/doctor_repository_impl.dart';
import 'package:medmylife/features/doctors/domain/models/doctor_model.dart';

class MockDoctorRemoteDataSource extends Mock implements DoctorRemoteDataSource {}
class MockDoctorLocalDataSource extends Mock implements DoctorLocalDataSource {}
class MockNetworkInfo extends Mock implements NetworkInfo {}

void main() {
  late DoctorRepositoryImpl repository;
  late MockDoctorRemoteDataSource mockRemote;
  late MockDoctorLocalDataSource mockLocal;
  late MockNetworkInfo mockNetwork;

  const tDoctor = DoctorModel(
    id: 101,
    name: 'Dr. Rahul Sharma',
    speciality: 'Cardiologist',
    experience: 12,
    consultationFee: 800,
    available: true,
  );

  final tDoctorsList = [tDoctor];

  setUpAll(() {
    registerFallbackValue(tDoctorsList);
  });

  setUp(() {
    mockRemote = MockDoctorRemoteDataSource();
    mockLocal = MockDoctorLocalDataSource();
    mockNetwork = MockNetworkInfo();

    repository = DoctorRepositoryImpl(
      remoteDataSource: mockRemote,
      localDataSource: mockLocal,
      networkInfo: mockNetwork,
    );
  });

  group('getDoctors', () {
    test('should fetch from remote and cache locally when network is online', () async {
      when(() => mockNetwork.isConnected).thenAnswer((_) async => true);
      when(() => mockRemote.getDoctors()).thenAnswer((_) async => tDoctorsList);
      when(() => mockLocal.cacheDoctors(any())).thenAnswer((_) async {});

      final result = await repository.getDoctors();

      expect(result.doctors, equals(tDoctorsList));
      expect(result.isFromCache, isFalse);
      verify(() => mockRemote.getDoctors()).called(1);
      verify(() => mockLocal.cacheDoctors(tDoctorsList)).called(1);
    });

    test('should fallback to local cache when offline', () async {
      when(() => mockNetwork.isConnected).thenAnswer((_) async => false);
      when(() => mockLocal.getCachedDoctors()).thenAnswer((_) async => tDoctorsList);

      final result = await repository.getDoctors();

      expect(result.doctors, equals(tDoctorsList));
      expect(result.isFromCache, isTrue);
      verifyNever(() => mockRemote.getDoctors());
      verify(() => mockLocal.getCachedDoctors()).called(1);
    });

    test('should throw NetworkFailure when offline and local cache is empty', () async {
      when(() => mockNetwork.isConnected).thenAnswer((_) async => false);
      when(() => mockLocal.getCachedDoctors()).thenAnswer((_) async => []);

      expect(() => repository.getDoctors(), throwsA(isA<NetworkFailure>()));
    });
  });
}
