import 'package:equatable/equatable.dart';
import '../../domain/models/appointment_model.dart';

abstract class AppointmentState extends Equatable {
  const AppointmentState();

  @override
  List<Object?> get props => [];
}

class AppointmentInitial extends AppointmentState {}

class AppointmentLoading extends AppointmentState {}

class AppointmentLoaded extends AppointmentState {
  final List<AppointmentModel> appointments;
  final bool isSyncing;

  const AppointmentLoaded({
    required this.appointments,
    this.isSyncing = false,
  });

  bool get hasPending => appointments.any((a) => a.syncStatus == AppointmentSyncStatus.pending);

  @override
  List<Object?> get props => [appointments, isSyncing];
}

class BookingInProgress extends AppointmentState {}

class BookingSuccess extends AppointmentState {
  final AppointmentModel appointment;

  const BookingSuccess(this.appointment);

  @override
  List<Object?> get props => [appointment];
}

class BookingError extends AppointmentState {
  final String message;

  const BookingError(this.message);

  @override
  List<Object?> get props => [message];
}
