import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medmylife/core/network/network_info.dart';
import 'package:medmylife/core/utils/debouncer.dart';
import 'package:medmylife/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:medmylife/features/appointments/presentation/screens/doctor_detail_screen.dart';
import 'package:medmylife/features/appointments/presentation/screens/my_appointments_screen.dart';
import 'package:medmylife/features/doctors/presentation/cubit/doctor_list_cubit.dart';
import 'package:medmylife/features/doctors/presentation/cubit/doctor_list_state.dart';
import 'package:medmylife/features/doctors/domain/models/doctor_model.dart';

class DoctorListScreen extends StatefulWidget {
  const DoctorListScreen({super.key});

  @override
  State<DoctorListScreen> createState() => _DoctorListScreenState();
}

class _DoctorListScreenState extends State<DoctorListScreen> {
  final TextEditingController _searchController = TextEditingController();
  final Debouncer _debouncer = Debouncer(delay: const Duration(milliseconds: 350));

  @override
  void initState() {
    super.initState();
    context.read<DoctorListCubit>().fetchDoctors();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debouncer.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debouncer.run(() {
      context.read<DoctorListCubit>().searchDoctors(value);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final networkInfo = context.watch<NetworkInfo>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Find Doctors'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(
              networkInfo.isSimulatedOffline ? Icons.wifi_off : Icons.wifi,
              color: networkInfo.isSimulatedOffline ? Colors.amber : Colors.white,
            ),
            tooltip: networkInfo.isSimulatedOffline ? 'Simulating Offline' : 'Online',
            onPressed: () {
              final newOfflineState = !networkInfo.isSimulatedOffline;
              networkInfo.toggleSimulatedOffline(newOfflineState);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    newOfflineState
                        ? 'Simulating Offline Mode (Using local database)'
                        : 'Simulating Online Mode',
                  ),
                  duration: const Duration(seconds: 2),
                ),
              );
              context.read<DoctorListCubit>().fetchDoctors();
            },
          ),
          IconButton(
            icon: const Icon(Icons.event_note),
            tooltip: 'My Appointments',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const MyAppointmentsScreen(),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () {
              context.read<AuthCubit>().logout();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          if (networkInfo.isSimulatedOffline)
            Container(
              color: Colors.amber.shade800,
              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
              child: const Row(
                children: [
                  Icon(Icons.offline_bolt, color: Colors.white, size: 18),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Offline Mode active. Displaying doctors from local storage.',
                      style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ),

          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Search doctor name or speciality...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          context.read<DoctorListCubit>().searchDoctors('');
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.grey.shade100,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          Expanded(
            child: BlocBuilder<DoctorListCubit, DoctorListState>(
              builder: (context, state) {
                if (state is DoctorListLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is DoctorListError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.error_outline, size: 64, color: theme.colorScheme.error),
                          const SizedBox(height: 16),
                          Text(
                            'Failed to load doctors',
                            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            state.message,
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey.shade700),
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton.icon(
                            onPressed: () {
                              context.read<DoctorListCubit>().fetchDoctors(forceRefresh: true);
                            },
                            icon: const Icon(Icons.refresh),
                            label: const Text('Retry'),
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.teal, foregroundColor: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                if (state is DoctorListLoaded) {
                  if (state.isEmpty) {
                    return RefreshIndicator(
                      onRefresh: () => context.read<DoctorListCubit>().fetchDoctors(forceRefresh: true),
                      child: ListView(
                        children: [
                          const SizedBox(height: 80),
                          Icon(Icons.search_off, size: 64, color: Colors.grey.shade400),
                          const SizedBox(height: 16),
                          Center(
                            child: Text(
                              'No doctors found for "${state.searchQuery}"',
                              style: theme.textTheme.titleMedium?.copyWith(color: Colors.grey.shade700),
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () => context.read<DoctorListCubit>().fetchDoctors(forceRefresh: true),
                    child: ListView.builder(
                      padding: const EdgeInsets.only(bottom: 24, left: 16, right: 16),
                      itemCount: state.filteredDoctors.length,
                      itemBuilder: (context, index) {
                        final doctor = state.filteredDoctors[index];
                        return _DoctorCard(doctor: doctor);
                      },
                    ),
                  );
                }

                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _DoctorCard extends StatelessWidget {
  final DoctorModel doctor;

  const _DoctorCard({required this.doctor});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DoctorDetailScreen(doctor: doctor),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: Colors.teal.shade100,
                child: Text(
                  doctor.name.replaceFirst('Dr. ', '').substring(0, 1),
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.teal),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            doctor.name,
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: doctor.available ? Colors.green.shade50 : Colors.red.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: doctor.available ? Colors.green : Colors.red,
                              width: 0.8,
                            ),
                          ),
                          child: Text(
                            doctor.available ? 'Available' : 'Unavailable',
                            style: TextStyle(
                              color: doctor.available ? Colors.green.shade800 : Colors.red.shade800,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      doctor.speciality,
                      style: TextStyle(color: Colors.teal.shade700, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(Icons.workspace_premium, size: 16, color: Colors.grey.shade600),
                        const SizedBox(width: 4),
                        Text(
                          '${doctor.experience} yrs exp',
                          style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
                        ),
                        const SizedBox(width: 16),
                        Icon(Icons.payments_outlined, size: 16, color: Colors.grey.shade600),
                        const SizedBox(width: 4),
                        Text(
                          '₹${doctor.consultationFee}',
                          style: const TextStyle(
                            color: Colors.black87,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
