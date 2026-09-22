import 'package:equatable/equatable.dart';

enum AppointmentSyncStatus { pending, syncing, synced, failed }

class AppointmentModel extends Equatable {
  final String id;
  final int doctorId;
  final String doctorName;
  final String doctorSpeciality;
  final String slot;
  final DateTime appointmentDate;
  final String patientName;
  final AppointmentSyncStatus syncStatus;
  final DateTime createdAt;
  final int consultationFee;
  final double taxAmount;
  final double totalAmount;
  final String invoiceNumber;
  final String paymentStatus;

  const AppointmentModel({
    required this.id,
    required this.doctorId,
    required this.doctorName,
    required this.doctorSpeciality,
    required this.slot,
    required this.appointmentDate,
    required this.patientName,
    required this.syncStatus,
    required this.createdAt,
    required this.consultationFee,
    required this.taxAmount,
    required this.totalAmount,
    required this.invoiceNumber,
    required this.paymentStatus,
  });

  AppointmentModel copyWith({
    String? id,
    int? doctorId,
    String? doctorName,
    String? doctorSpeciality,
    String? slot,
    DateTime? appointmentDate,
    String? patientName,
    AppointmentSyncStatus? syncStatus,
    DateTime? createdAt,
    int? consultationFee,
    double? taxAmount,
    double? totalAmount,
    String? invoiceNumber,
    String? paymentStatus,
  }) {
    return AppointmentModel(
      id: id ?? this.id,
      doctorId: doctorId ?? this.doctorId,
      doctorName: doctorName ?? this.doctorName,
      doctorSpeciality: doctorSpeciality ?? this.doctorSpeciality,
      slot: slot ?? this.slot,
      appointmentDate: appointmentDate ?? this.appointmentDate,
      patientName: patientName ?? this.patientName,
      syncStatus: syncStatus ?? this.syncStatus,
      createdAt: createdAt ?? this.createdAt,
      consultationFee: consultationFee ?? this.consultationFee,
      taxAmount: taxAmount ?? this.taxAmount,
      totalAmount: totalAmount ?? this.totalAmount,
      invoiceNumber: invoiceNumber ?? this.invoiceNumber,
      paymentStatus: paymentStatus ?? this.paymentStatus,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'doctorId': doctorId,
      'doctorName': doctorName,
      'doctorSpeciality': doctorSpeciality,
      'slot': slot,
      'appointmentDate': appointmentDate.toIso8601String(),
      'patientName': patientName,
      'syncStatus': syncStatus.name,
      'createdAt': createdAt.toIso8601String(),
      'consultationFee': consultationFee,
      'taxAmount': taxAmount,
      'totalAmount': totalAmount,
      'invoiceNumber': invoiceNumber,
      'paymentStatus': paymentStatus,
    };
  }

  factory AppointmentModel.fromJson(Map<String, dynamic> json) {
    return AppointmentModel(
      id: json['id'] as String,
      doctorId: json['doctorId'] as int,
      doctorName: json['doctorName'] as String,
      doctorSpeciality: json['doctorSpeciality'] as String,
      slot: json['slot'] as String,
      appointmentDate: DateTime.parse(json['appointmentDate'] as String? ?? json['createdAt'] as String),
      patientName: json['patientName'] as String,
      syncStatus: AppointmentSyncStatus.values.firstWhere(
        (e) => e.name == json['syncStatus'],
        orElse: () => AppointmentSyncStatus.synced,
      ),
      createdAt: DateTime.parse(json['createdAt'] as String),
      consultationFee: json['consultationFee'] as int? ?? 800,
      taxAmount: (json['taxAmount'] as num?)?.toDouble() ?? 144.0,
      totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 944.0,
      invoiceNumber: json['invoiceNumber'] as String? ?? 'INV-AMZ-8821',
      paymentStatus: json['paymentStatus'] as String? ?? 'PAID',
    );
  }

  @override
  List<Object?> get props => [
        id,
        doctorId,
        doctorName,
        doctorSpeciality,
        slot,
        appointmentDate,
        patientName,
        syncStatus,
        createdAt,
        consultationFee,
        taxAmount,
        totalAmount,
        invoiceNumber,
        paymentStatus,
      ];
}
