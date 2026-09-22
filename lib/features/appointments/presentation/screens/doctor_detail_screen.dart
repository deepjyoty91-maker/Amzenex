import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:medmylife/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:medmylife/features/auth/presentation/cubit/auth_state.dart';
import 'package:medmylife/features/doctors/domain/models/doctor_model.dart';
import 'package:medmylife/features/appointments/presentation/cubit/appointment_cubit.dart';
import 'package:medmylife/features/appointments/presentation/cubit/appointment_state.dart';

class DoctorDetailScreen extends StatefulWidget {
  final DoctorModel doctor;

  const DoctorDetailScreen({super.key, required this.doctor});

  @override
  State<DoctorDetailScreen> createState() => _DoctorDetailScreenState();
}

class _DoctorDetailScreenState extends State<DoctorDetailScreen> {
  late DateTime _selectedDate;
  late List<DateTime> _next7Days;
  String? _selectedSlot;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedDate = now;
    _next7Days = List.generate(7, (index) => now.add(Duration(days: index)));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final doctor = widget.doctor;

    return Scaffold(
      appBar: AppBar(
        title: Text(doctor.name),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: BlocConsumer<AppointmentCubit, AppointmentState>(
        listener: (context, state) {
          if (state is BookingError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: theme.colorScheme.error,
                behavior: SnackBarBehavior.floating,
              ),
            );
          } else if (state is BookingSuccess) {
            final isOffline = state.appointment.syncStatus.name == 'pending';
            final dateFormat = DateFormat('EEE, MMM dd, yyyy');

            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (dialogContext) => AlertDialog(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                title: Row(
                  children: [
                    Icon(
                      isOffline ? Icons.offline_pin : Icons.check_circle,
                      color: isOffline ? Colors.amber.shade800 : Colors.green,
                      size: 28,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        isOffline ? 'Queued Offline!' : 'Booking Confirmed!',
                        style: const TextStyle(fontSize: 18),
                      ),
                    ),
                  ],
                ),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isOffline
                          ? 'Your appointment has been saved locally and queued for automatic sync when internet becomes available.'
                          : 'Your appointment has been successfully booked with ${doctor.name}.',
                      style: const TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Doctor: ${doctor.name}', style: const TextStyle(fontWeight: FontWeight.bold)),
                          Text('Date: ${dateFormat.format(state.appointment.appointmentDate)}'),
                          Text('Time Slot: ${state.appointment.slot}'),
                          Text('Invoice Ref: ${state.appointment.invoiceNumber}'),
                          Text(
                            'Status: ${isOffline ? "PENDING SYNC" : "CONFIRMED & PAID"}',
                            style: TextStyle(
                              color: isOffline ? Colors.amber.shade900 : Colors.green.shade800,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                actions: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(dialogContext);
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('OK'),
                  ),
                ],
              ),
            );
          }
        },
        builder: (context, state) {
          final isBooking = state is BookingInProgress;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 36,
                              backgroundColor: Colors.teal.shade100,
                              child: Text(
                                doctor.name.replaceFirst('Dr. ', '').substring(0, 1),
                                style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.teal),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    doctor.name,
                                    style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    doctor.speciality,
                                    style: TextStyle(color: Colors.teal.shade700, fontWeight: FontWeight.w600),
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      const Icon(Icons.star, color: Colors.amber, size: 18),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${doctor.rating} (${doctor.reviewCount} reviews)',
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildMetaBadge(Icons.workspace_premium, 'Experience', '${doctor.experience} Yrs'),
                            _buildMetaBadge(Icons.payments, 'Fee', '₹${doctor.consultationFee}'),
                            _buildMetaBadge(
                              Icons.location_on,
                              'Location',
                              'Guwahati',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                Text(
                  'About Doctor',
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                Text(
                  doctor.about,
                  style: TextStyle(color: Colors.grey.shade800, height: 1.4, fontSize: 13),
                ),
                const SizedBox(height: 24),

                Text(
                  'Select Appointment Date (1 Week Ahead)',
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 70,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _next7Days.length,
                    itemBuilder: (context, index) {
                      final day = _next7Days[index];
                      final isSelected = DateFormat('yyyy-MM-dd').format(day) ==
                          DateFormat('yyyy-MM-dd').format(_selectedDate);

                      return Padding(
                        padding: const EdgeInsets.only(right: 10.0),
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              _selectedDate = day;
                            });
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            width: 65,
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              color: isSelected ? Colors.teal : Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected ? Colors.teal : Colors.grey.shade300,
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  DateFormat('EEE').format(day),
                                  style: TextStyle(
                                    color: isSelected ? Colors.white70 : Colors.grey.shade600,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  DateFormat('dd MMM').format(day),
                                  style: TextStyle(
                                    color: isSelected ? Colors.white : Colors.black87,
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 20),

                Text(
                  'Available Time Slots for ${DateFormat('EEE, MMM dd').format(_selectedDate)}',
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),

                if (!doctor.available)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Text(
                      '${doctor.name} is currently unavailable for bookings.',
                      style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                    ),
                  )
                else
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: doctor.availableSlots.map((slot) {
                      final isSelected = _selectedSlot == slot;
                      return ChoiceChip(
                        label: Text(slot),
                        selected: isSelected,
                        selectedColor: Colors.teal,
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : Colors.black87,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                        onSelected: (selected) {
                          setState(() {
                            _selectedSlot = selected ? slot : null;
                          });
                        },
                      );
                    }).toList(),
                  ),

                const SizedBox(height: 24),

                Text(
                  'Patient Reviews (${doctor.reviews.length})',
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                ...doctor.reviews.map((r) => Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      elevation: 1,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(r.patientName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                Row(
                                  children: [
                                    const Icon(Icons.star, color: Colors.amber, size: 14),
                                    Text(' ${r.rating}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(r.comment, style: TextStyle(color: Colors.grey.shade700, fontSize: 12)),
                          ],
                        ),
                      ),
                    )),

                const SizedBox(height: 30),

                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: (isBooking || !doctor.available || _selectedSlot == null)
                        ? null
                        : () {
                            final authState = context.read<AuthCubit>().state;
                            final patientName = (authState is Authenticated)
                                ? authState.user.name
                                : 'Patient';

                            context.read<AppointmentCubit>().bookAppointment(
                                  doctorId: doctor.id,
                                  doctorName: doctor.name,
                                  doctorSpeciality: doctor.speciality,
                                  slot: _selectedSlot!,
                                  appointmentDate: _selectedDate,
                                  patientName: patientName,
                                  consultationFee: doctor.consultationFee,
                                );
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 2,
                    ),
                    child: isBooking
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : Text(
                            _selectedSlot == null
                                ? 'Select a slot'
                                : 'Confirm & Book for ${DateFormat('dd MMM').format(_selectedDate)}',
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildMetaBadge(IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(icon, color: Colors.teal, size: 20),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 11)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
      ],
    );
  }
}
