import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medmylife/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:medmylife/features/auth/presentation/cubit/auth_state.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Patient Profile'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: BlocBuilder<AuthCubit, AuthState>(
        builder: (context, state) {
          final userName = (state is Authenticated) ? state.user.name : 'Patient User';
          final userIdentifier = (state is Authenticated) ? state.user.identifier : 'patient@medmylife.com';

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                Container(
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
                        color: Colors.teal.shade200,
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          Row(
                            children: [
                              Icon(Icons.medical_services, color: Colors.white, size: 24),
                              SizedBox(width: 8),
                              Text(
                                'AMZENEX HEALTH ID',
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1),
                              ),
                            ],
                          ),
                          Icon(Icons.qr_code_2, color: Colors.white, size: 36),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Text(
                        userName,
                        style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        userIdentifier,
                        style: const TextStyle(color: Colors.white70, fontSize: 13),
                      ),
                      const Divider(color: Colors.white38, height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('BLOOD GROUP', style: TextStyle(color: Colors.white60, fontSize: 10)),
                              Text('O +ve', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('AGE / GENDER', style: TextStyle(color: Colors.white60, fontSize: 10)),
                              Text('28 Yrs / Male', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('LOCATION', style: TextStyle(color: Colors.white60, fontSize: 10)),
                              Text('Guwahati', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 2,
                  child: Column(
                    children: const [
                      ListTile(
                        leading: Icon(Icons.emergency_outlined, color: Colors.red),
                        title: Text('Emergency Contact'),
                        subtitle: Text('+91 98640 12345 (Family)'),
                      ),
                      Divider(height: 1),
                      ListTile(
                        leading: Icon(Icons.history_edu, color: Colors.teal),
                        title: Text('Medical History'),
                        subtitle: Text('No chronic conditions reported'),
                      ),
                      Divider(height: 1),
                      ListTile(
                        leading: Icon(Icons.vaccines, color: Colors.teal),
                        title: Text('Vaccination Record'),
                        subtitle: Text('COVID-19 Booster Completed'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 2,
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.notifications_active_outlined, color: Colors.teal),
                        title: const Text('Appointment Reminders'),
                        trailing: Switch(value: true, onChanged: (v) {}, activeColor: Colors.teal),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.security, color: Colors.teal),
                        title: const Text('Privacy & Security'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {},
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.help_outline, color: Colors.teal),
                        title: const Text('Help & Support'),
                        subtitle: const Text('Amzenex Guwahati Helpline'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {},
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),

                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      context.read<AuthCubit>().logout();
                    },
                    icon: const Icon(Icons.logout, color: Colors.red),
                    label: const Text(
                      'Logout Account',
                      style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.red),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
}
