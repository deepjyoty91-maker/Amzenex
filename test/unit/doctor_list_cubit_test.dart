import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:medmylife/features/doctors/data/repositories/doctor_repository_impl.dart';
import 'package:medmylife/features/doctors/domain/models/doctor_model.dart';
import 'package:medmylife/features/doctors/presentation/cubit/doctor_list_cubit.dart';
import 'package:medmylife/features/doctors/presentation/cubit/doctor_list_state.dart';

class MockDoctorRepository extends Mock implements DoctorRepository {}

void main() {
  late DoctorListCubit cubit;
  late MockDoctorRepository mockRepository;

  const doc1 = DoctorModel(
    id: 101,
    name: 'Dr. Rahul Sharma',
    speciality: 'Cardiologist',
    experience: 12,
    consultationFee: 800,
    available: true,
  );

  const doc2 = DoctorModel(
    id: 102,
    name: 'Dr. Priya Patel',
    speciality: 'Dermatologist',
    experience: 8,
    consultationFee: 650,
    available: true,
  );

  final testDoctors = [doc1, doc2];

  setUp(() {
    mockRepository = MockDoctorRepository();
    cubit = DoctorListCubit(doctorRepository: mockRepository);
  });

  tearDown(() {
    cubit.close();
  });

  group('DoctorListCubit State Transitions', () {
    test('initial state should be DoctorListInitial', () {
      expect(cubit.state, equals(DoctorListInitial()));
    });

    blocTest<DoctorListCubit, DoctorListState>(
      'emits [DoctorListLoading, DoctorListLoaded] on successful doctor fetch',
      build: () {
        when(() => mockRepository.getDoctors(forceRefresh: any(named: 'forceRefresh')))
            .thenAnswer((_) async => DoctorFetchResult(
                  doctors: testDoctors,
                  isFromCache: false,
                ));
        return cubit;
      },
      act: (c) => c.fetchDoctors(),
      expect: () => [
        DoctorListLoading(),
        DoctorListLoaded(
          allDoctors: testDoctors,
          filteredDoctors: testDoctors,
          searchQuery: '',
          isFromCache: false,
        ),
      ],
    );

    blocTest<DoctorListCubit, DoctorListState>(
      'filters doctor list by search query correctly',
      build: () {
        when(() => mockRepository.getDoctors(forceRefresh: any(named: 'forceRefresh')))
            .thenAnswer((_) async => DoctorFetchResult(
                  doctors: testDoctors,
                  isFromCache: false,
                ));
        return cubit;
      },
      act: (c) async {
        await c.fetchDoctors();
        c.searchDoctors('Dermatologist');
      },
      expect: () => [
        DoctorListLoading(),
        DoctorListLoaded(
          allDoctors: testDoctors,
          filteredDoctors: testDoctors,
        ),
        DoctorListLoaded(
          allDoctors: testDoctors,
          filteredDoctors: const [doc2],
          searchQuery: 'Dermatologist',
        ),
      ],
    );
  });
}
