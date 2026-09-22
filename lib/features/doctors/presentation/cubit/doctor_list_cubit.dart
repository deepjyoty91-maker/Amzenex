import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/doctor_repository_impl.dart';
import '../../domain/models/doctor_model.dart';
import 'doctor_list_state.dart';

class DoctorListCubit extends Cubit<DoctorListState> {
  final DoctorRepository doctorRepository;

  DoctorListCubit({required this.doctorRepository}) : super(DoctorListInitial());

  Future<void> fetchDoctors({bool forceRefresh = false}) async {
    if (state is! DoctorListLoaded) {
      emit(DoctorListLoading());
    }

    try {
      final result = await doctorRepository.getDoctors(forceRefresh: forceRefresh);
      
      final currentQuery = (state is DoctorListLoaded)
          ? (state as DoctorListLoaded).searchQuery
          : '';

      final filtered = _applySearchFilter(result.doctors, currentQuery);

      emit(DoctorListLoaded(
        allDoctors: result.doctors,
        filteredDoctors: filtered,
        searchQuery: currentQuery,
        isFromCache: result.isFromCache,
        warningMessage: result.warningMessage,
      ));
    } catch (e) {
      emit(DoctorListError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  void searchDoctors(String query) {
    if (state is DoctorListLoaded) {
      final currentState = state as DoctorListLoaded;
      final trimmed = query.trim();
      final filtered = _applySearchFilter(currentState.allDoctors, trimmed);

      emit(currentState.copyWith(
        searchQuery: trimmed,
        filteredDoctors: filtered,
      ));
    }
  }

  List<DoctorModel> _applySearchFilter(List<DoctorModel> doctors, String query) {
    if (query.isEmpty) return doctors;
    final lowerQuery = query.toLowerCase();
    return doctors.where((doctor) {
      final nameMatches = doctor.name.toLowerCase().contains(lowerQuery);
      final specialityMatches = doctor.speciality.toLowerCase().contains(lowerQuery);
      return nameMatches || specialityMatches;
    }).toList();
  }
}
