import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:medmylife/features/appointments/presentation/cubit/appointment_cubit.dart';
import 'package:medmylife/features/appointments/presentation/cubit/appointment_state.dart';
import 'package:medmylife/features/appointments/presentation/widgets/digital_invoice_dialog.dart';
import 'package:medmylife/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:medmylife/features/auth/presentation/cubit/auth_state.dart';
import 'package:medmylife/features/doctors/presentation/cubit/doctor_list_cubit.dart';
import 'package:medmylife/features/doctors/presentation/cubit/doctor_list_state.dart';

class HomeDashboardScreen extends StatelessWidget {
  final VoidCallback onNavigateToDoctors;
  final VoidCallback onNavigateToMedicines;
  final VoidCallback onNavigateToBookings;

  const HomeDashboardScreen({
    super.key,
    required this.onNavigateToDoctors,
    required this.onNavigateToMedicines,
    required this.onNavigateToBookings,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('EEE, MMM dd');

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.medical_services_rounded, color: Colors.white, size: 24),
            SizedBox(width: 8),
            Text('MEDMYLIFE', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)),
          ],
        ),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none),
            onPressed: () {},
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          context.read<DoctorListCubit>().fetchDoctors();
          context.read<AppointmentCubit>().loadAppointments();
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              BlocBuilder<AuthCubit, AuthState>(
                builder: (context, state) {
                  final name = (state is Authenticated) ? state.user.name : 'Patient';
                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.teal.shade800, Colors.teal.shade500],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.teal.shade100,
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome back, $name 👋',
                          style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'How are you feeling today? Book a consultation with top specialists in Guwahati.',
                          style: TextStyle(color: Colors.white70, fontSize: 13),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: onNavigateToDoctors,
                          icon: const Icon(Icons.calendar_today, size: 18),
                          label: const Text('Book Appointment Now'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.amber.shade800,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Current Bookings (Quick Glance)',
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  TextButton(
                    onPressed: onNavigateToBookings,
                    child: const Text('See All'),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              BlocBuilder<AppointmentCubit, AppointmentState>(
                builder: (context, state) {
                  if (state is AppointmentLoaded && state.appointments.isNotEmpty) {
                    final bookings = state.appointments.reversed.toList();

                    return SizedBox(
                      height: 180,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: bookings.length,
                        itemBuilder: (context, index) {
                          final item = bookings[index];
                          return Container(
                            width: 300,
                            margin: const EdgeInsets.only(right: 12),
                            child: Card(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                              elevation: 2,
                              color: Colors.teal.shade50,
                              child: Padding(
                                padding: const EdgeInsets.all(14),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Row(
                                            children: [
                                              const Icon(Icons.event_available, color: Colors.teal, size: 20),
                                              const SizedBox(width: 6),
                                              Expanded(
                                                child: Text(
                                                  item.doctorName,
                                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: item.syncStatus.name == 'pending'
                                                ? Colors.amber.shade100
                                                : Colors.green.shade100,
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            item.paymentStatus,
                                            style: TextStyle(
                                              fontSize: 9,
                                              fontWeight: FontWeight.bold,
                                              color: item.syncStatus.name == 'pending'
                                                  ? Colors.amber.shade900
                                                  : Colors.green.shade900,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      'Speciality: ${item.doctorSpeciality}',
                                      style: TextStyle(color: Colors.grey.shade800, fontSize: 12),
                                    ),
                                    Text(
                                      'Scheduled: ${dateFormat.format(item.appointmentDate)} @ ${item.slot}',
                                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.teal, fontSize: 12),
                                    ),
                                    const Spacer(),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Invoice: ${item.invoiceNumber}',
                                          style: const TextStyle(fontSize: 11, color: Colors.grey),
                                        ),
                                        InkWell(
                                          onTap: () {
                                            showDialog(
                                              context: context,
                                              builder: (_) => DigitalInvoiceDialog(appointment: item),
                                            );
                                          },
                                          child: const Text(
                                            'View Invoice →',
                                            style: TextStyle(color: Colors.teal, fontWeight: FontWeight.bold, fontSize: 12),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  }

                  return Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          const Icon(Icons.event_note, color: Colors.grey, size: 28),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Text(
                              'No active appointments. Tap to schedule a consultation with a doctor.',
                              style: TextStyle(fontSize: 13, color: Colors.grey),
                            ),
                          ),
                          TextButton(
                            onPressed: onNavigateToDoctors,
                            child: const Text('Book Now'),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.amber.shade300),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.medication_liquid, color: Colors.amber, size: 36),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Amzenex Guwahati Medicines',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.black87),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Explore authentic formulations for Cardiology, Dermatology, Orthopedics & Pediatrics.',
                            style: TextStyle(fontSize: 12, color: Colors.black54),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.arrow_forward, color: Colors.teal),
                      onPressed: onNavigateToMedicines,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Featured Specialists',
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  TextButton(
                    onPressed: onNavigateToDoctors,
                    child: const Text('View All'),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              BlocBuilder<DoctorListCubit, DoctorListState>(
                builder: (context, state) {
                  if (state is DoctorListLoaded && state.allDoctors.isNotEmpty) {
                    return SizedBox(
                      height: 140,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: state.allDoctors.take(4).length,
                        itemBuilder: (context, index) {
                          final doc = state.allDoctors[index];
                          return Container(
                            width: 200,
                            margin: const EdgeInsets.only(right: 12),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey.shade200),
                              boxShadow: [
                                BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 4, offset: const Offset(0, 2)),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 18,
                                      backgroundColor: Colors.teal.shade100,
                                      child: Text(
                                        doc.name.replaceFirst('Dr. ', '').substring(0, 1),
                                        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.teal),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        doc.name,
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(doc.speciality, style: TextStyle(color: Colors.teal.shade800, fontSize: 12, fontWeight: FontWeight.w600)),
                                const Spacer(),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('₹${doc.consultationFee}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                    Row(
                                      children: [
                                        const Icon(Icons.star, color: Colors.amber, size: 14),
                                        Text(' ${doc.rating}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    );
                  }
                  return const SizedBox(height: 80, child: Center(child: CircularProgressIndicator()));
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
