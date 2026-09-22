import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medmylife/features/appointments/data/repositories/appointment_repository_impl.dart';
import 'package:medmylife/features/appointments/domain/models/appointment_model.dart';
import 'appointment_state.dart';

class AppointmentCubit extends Cubit<AppointmentState> {
  final AppointmentRepository appointmentRepository;

  AppointmentCubit({required this.appointmentRepository}) : super(AppointmentInitial());

  Future<void> loadAppointments() async {
    emit(AppointmentLoading());
    try {
      final list = await appointmentRepository.getAppointments();
      emit(AppointmentLoaded(appointments: list));
    } catch (e) {
      emit(BookingError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> bookAppointment({
    required int doctorId,
    required String doctorName,
    required String doctorSpeciality,
    required String slot,
    required DateTime appointmentDate,
    required String patientName,
    required int consultationFee,
  }) async {
    emit(BookingInProgress());
    try {
      final booked = await appointmentRepository.bookAppointment(
        doctorId: doctorId,
        doctorName: doctorName,
        doctorSpeciality: doctorSpeciality,
        slot: slot,
        appointmentDate: appointmentDate,
        patientName: patientName,
        consultationFee: consultationFee,
      );
      emit(BookingSuccess(booked));
    } catch (e) {
      emit(BookingError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> syncOfflineQueue() async {
    if (state is AppointmentLoaded) {
      final currentList = (state as AppointmentLoaded).appointments;
      emit(AppointmentLoaded(appointments: currentList, isSyncing: true));
    }

    try {
      final updatedList = await appointmentRepository.syncPendingAppointments();
      emit(AppointmentLoaded(appointments: updatedList, isSyncing: false));
    } catch (e) {
      final list = await appointmentRepository.getAppointments();
      emit(AppointmentLoaded(appointments: list, isSyncing: false));
    }
  }
}
