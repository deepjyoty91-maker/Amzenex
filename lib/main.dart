import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/network/network_info.dart';
import 'features/appointments/data/datasources/appointment_local_data_source.dart';
import 'features/appointments/data/repositories/appointment_repository_impl.dart';
import 'features/appointments/presentation/cubit/appointment_cubit.dart';
import 'features/auth/data/auth_repository.dart';
import 'features/auth/presentation/cubit/auth_cubit.dart';
import 'features/auth/presentation/cubit/auth_state.dart';
import 'features/auth/presentation/screens/login_screen.dart';
import 'features/doctors/data/datasources/doctor_local_data_source.dart';
import 'features/doctors/data/datasources/doctor_remote_data_source.dart';
import 'features/doctors/data/repositories/doctor_repository_impl.dart';
import 'features/doctors/presentation/cubit/doctor_list_cubit.dart';
import 'features/home/presentation/screens/home_container_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();

  final sharedPreferences = await SharedPreferences.getInstance();

  final NetworkInfo networkInfo = NetworkInfoImpl();

  final DoctorRemoteDataSource doctorRemoteDataSource = DoctorRemoteDataSourceImpl();
  final DoctorLocalDataSource doctorLocalDataSource = DoctorLocalDataSourceImpl();
  final AppointmentLocalDataSource appointmentLocalDataSource = AppointmentLocalDataSourceImpl();

  final AuthRepository authRepository = AuthRepositoryImpl(sharedPreferences: sharedPreferences);
  final DoctorRepository doctorRepository = DoctorRepositoryImpl(
    remoteDataSource: doctorRemoteDataSource,
    localDataSource: doctorLocalDataSource,
    networkInfo: networkInfo,
  );
  final AppointmentRepository appointmentRepository = AppointmentRepositoryImpl(
    localDataSource: appointmentLocalDataSource,
    networkInfo: networkInfo,
  );

  runApp(MedmylifeApp(
    networkInfo: networkInfo,
    authRepository: authRepository,
    doctorRepository: doctorRepository,
    appointmentRepository: appointmentRepository,
  ));
}

class MedmylifeApp extends StatelessWidget {
  final NetworkInfo networkInfo;
  final AuthRepository authRepository;
  final DoctorRepository doctorRepository;
  final AppointmentRepository appointmentRepository;

  const MedmylifeApp({
    super.key,
    required this.networkInfo,
    required this.authRepository,
    required this.doctorRepository,
    required this.appointmentRepository,
  });

  @override
  Widget build(BuildContext context) {
    return Provider<NetworkInfo>.value(
      value: networkInfo,
      child: MultiRepositoryProvider(
        providers: [
          RepositoryProvider<AuthRepository>.value(value: authRepository),
          RepositoryProvider<DoctorRepository>.value(value: doctorRepository),
          RepositoryProvider<AppointmentRepository>.value(value: appointmentRepository),
        ],
        child: MultiBlocProvider(
          providers: [
            BlocProvider<AuthCubit>(
              create: (context) => AuthCubit(authRepository: authRepository)..checkAuthStatus(),
            ),
            BlocProvider<DoctorListCubit>(
              create: (context) => DoctorListCubit(doctorRepository: doctorRepository),
            ),
            BlocProvider<AppointmentCubit>(
              create: (context) => AppointmentCubit(appointmentRepository: appointmentRepository),
            ),
          ],
          child: MaterialApp(
            title: 'Medmylife Patient App',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              useMaterial3: true,
              colorSchemeSeed: Colors.teal,
              scaffoldBackgroundColor: const Color(0xFFF8FAF9),
            ),
            home: const AppRootNavigator(),
          ),
        ),
      ),
    );
  }
}

class AppRootNavigator extends StatelessWidget {
  const AppRootNavigator({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        if (state is AuthLoading || state is AuthInitial) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (state is Authenticated) {
          return const HomeContainerScreen();
        }

        return const LoginScreen();
      },
    );
  }
}
