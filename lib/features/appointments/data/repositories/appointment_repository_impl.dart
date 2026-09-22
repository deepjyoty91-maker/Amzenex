import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:medmylife/core/error/failures.dart';
import 'package:medmylife/core/network/network_info.dart';
import 'package:medmylife/features/appointments/data/datasources/appointment_local_data_source.dart';
import 'package:medmylife/features/appointments/domain/models/appointment_model.dart';

abstract class AppointmentRepository {
  Future<List<AppointmentModel>> getAppointments();
  Future<AppointmentModel> bookAppointment({
    required int doctorId,
    required String doctorName,
    required String doctorSpeciality,
    required String slot,
    required DateTime appointmentDate,
    required String patientName,
    required int consultationFee,
  });
  Future<List<AppointmentModel>> syncPendingAppointments();
}

class AppointmentRepositoryImpl implements AppointmentRepository {
  final AppointmentLocalDataSource localDataSource;
  final NetworkInfo networkInfo;
  final Uuid _uuid = const Uuid();

  AppointmentRepositoryImpl({
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<List<AppointmentModel>> getAppointments() async {
    return localDataSource.getAppointments();
  }

  @override
  Future<AppointmentModel> bookAppointment({
    required int doctorId,
    required String doctorName,
    required String doctorSpeciality,
    required String slot,
    required DateTime appointmentDate,
    required String patientName,
    required int consultationFee,
  }) async {
    final existingAppointments = await localDataSource.getAppointments();

    final dateStr = DateFormat('yyyy-MM-dd').format(appointmentDate);

    // Prevent duplicate booking for same doctor, same date, and same slot
    final isDuplicate = existingAppointments.any(
      (a) =>
          a.doctorId == doctorId &&
          a.slot == slot &&
          DateFormat('yyyy-MM-dd').format(a.appointmentDate) == dateStr,
    );

    if (isDuplicate) {
      throw const BookingFailure('You have already booked a slot with this doctor on this date and time.');
    }

    final isOnline = await networkInfo.isConnected;
    final tax = (consultationFee * 0.18).roundToDouble();
    final total = consultationFee + tax;
    final uniqueSeq = (1000 + (DateTime.now().millisecondsSinceEpoch % 8999)).toString();

    final appointment = AppointmentModel(
      id: 'APT_${_uuid.v4().substring(0, 8)}',
      doctorId: doctorId,
      doctorName: doctorName,
      doctorSpeciality: doctorSpeciality,
      slot: slot,
      appointmentDate: appointmentDate,
      patientName: patientName,
      syncStatus: isOnline ? AppointmentSyncStatus.synced : AppointmentSyncStatus.pending,
      createdAt: DateTime.now(),
      consultationFee: consultationFee,
      taxAmount: tax,
      totalAmount: total,
      invoiceNumber: 'INV-AMZ-$uniqueSeq',
      paymentStatus: isOnline ? 'CONFIRMED / PAID' : 'PENDING SYNC',
    );

    if (isOnline) {
      await Future.delayed(const Duration(milliseconds: 1200));
    }

    await localDataSource.saveAppointment(appointment);

    return appointment;
  }

  @override
  Future<List<AppointmentModel>> syncPendingAppointments() async {
    final isOnline = await networkInfo.isConnected;
    if (!isOnline) {
      throw const NetworkFailure('Cannot sync while offline. Please connect to internet.');
    }

    final appointments = await localDataSource.getAppointments();
    final pending = appointments.where((a) => a.syncStatus == AppointmentSyncStatus.pending).toList();

    for (final item in pending) {
      final syncingItem = item.copyWith(syncStatus: AppointmentSyncStatus.syncing);
      await localDataSource.updateAppointment(syncingItem);

      await Future.delayed(const Duration(milliseconds: 800));

      final syncedItem = item.copyWith(
        syncStatus: AppointmentSyncStatus.synced,
        paymentStatus: 'CONFIRMED / PAID',
      );
      await localDataSource.updateAppointment(syncedItem);
    }

    return localDataSource.getAppointments();
  }
}
