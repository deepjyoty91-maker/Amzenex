import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:medmylife/core/network/network_info.dart';
import 'package:medmylife/features/appointments/data/datasources/appointment_local_data_source.dart';
import 'package:medmylife/features/appointments/data/repositories/appointment_repository_impl.dart';
import 'package:medmylife/features/appointments/domain/models/appointment_model.dart';

class MockAppointmentLocalDataSource extends Mock implements AppointmentLocalDataSource {}
class MockNetworkInfo extends Mock implements NetworkInfo {}
class FakeAppointmentModel extends Fake implements AppointmentModel {}

void main() {
  late AppointmentRepositoryImpl repository;
  late MockAppointmentLocalDataSource mockLocal;
  late MockNetworkInfo mockNetwork;

  setUpAll(() {
    registerFallbackValue(FakeAppointmentModel());
  });

  setUp(() {
    mockLocal = MockAppointmentLocalDataSource();
    mockNetwork = MockNetworkInfo();
    repository = AppointmentRepositoryImpl(
      localDataSource: mockLocal,
      networkInfo: mockNetwork,
    );
  });

  group('Appointment Offline Sync Queue', () {
    test('should save appointment with status PENDING when booking offline', () async {
      when(() => mockLocal.getAppointments()).thenAnswer((_) async => []);
      when(() => mockNetwork.isConnected).thenAnswer((_) async => false);
      when(() => mockLocal.saveAppointment(any())).thenAnswer((_) async {});

      final appointment = await repository.bookAppointment(
        doctorId: 101,
        doctorName: 'Dr. Rahul Sharma',
        doctorSpeciality: 'Cardiologist',
        slot: '10:00 AM',
        appointmentDate: DateTime.now(),
        patientName: 'Test Patient',
        consultationFee: 800,
      );

      expect(appointment.syncStatus, equals(AppointmentSyncStatus.pending));
      verify(() => mockLocal.saveAppointment(any())).called(1);
    });

    test('should transition PENDING appointments to SYNCED during sync Pending', () async {
      final pendingAppointment = AppointmentModel(
        id: 'APT_123',
        doctorId: 101,
        doctorName: 'Dr. Rahul Sharma',
        doctorSpeciality: 'Cardiologist',
        slot: '10:00 AM',
        appointmentDate: DateTime.now(),
        patientName: 'Test Patient',
        syncStatus: AppointmentSyncStatus.pending,
        createdAt: DateTime.now(),
        consultationFee: 800,
        taxAmount: 144.0,
        totalAmount: 944.0,
        invoiceNumber: 'INV-AMZ-1001',
        paymentStatus: 'PENDING SYNC',
      );

      when(() => mockNetwork.isConnected).thenAnswer((_) async => true);
      when(() => mockLocal.getAppointments()).thenAnswer((_) async => [pendingAppointment]);
      when(() => mockLocal.updateAppointment(any())).thenAnswer((_) async {});

      final result = await repository.syncPendingAppointments();

      verify(() => mockLocal.updateAppointment(any())).called(2);
    });
  });
}
