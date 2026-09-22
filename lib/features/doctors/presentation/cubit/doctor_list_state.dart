import 'package:equatable/equatable.dart';
import '../../domain/models/doctor_model.dart';

abstract class DoctorListState extends Equatable {
  const DoctorListState();

  @override
  List<Object?> get props => [];
}

class DoctorListInitial extends DoctorListState {}

class DoctorListLoading extends DoctorListState {}

class DoctorListLoaded extends DoctorListState {
  final List<DoctorModel> allDoctors;
  final List<DoctorModel> filteredDoctors;
  final String searchQuery;
  final bool isFromCache;
  final String? warningMessage;

  const DoctorListLoaded({
    required this.allDoctors,
    required this.filteredDoctors,
    this.searchQuery = '',
    this.isFromCache = false,
    this.warningMessage,
  });

  bool get isEmpty => filteredDoctors.isEmpty;

  DoctorListLoaded copyWith({
    List<DoctorModel>? allDoctors,
    List<DoctorModel>? filteredDoctors,
    String? searchQuery,
    bool? isFromCache,
    String? warningMessage,
  }) {
    return DoctorListLoaded(
      allDoctors: allDoctors ?? this.allDoctors,
      filteredDoctors: filteredDoctors ?? this.filteredDoctors,
      searchQuery: searchQuery ?? this.searchQuery,
      isFromCache: isFromCache ?? this.isFromCache,
      warningMessage: warningMessage ?? this.warningMessage,
    );
  }

  @override
  List<Object?> get props => [
        allDoctors,
        filteredDoctors,
        searchQuery,
        isFromCache,
        warningMessage,
      ];
}

class DoctorListError extends DoctorListState {
  final String message;

  const DoctorListError(this.message);

  @override
  List<Object?> get props => [message];
}
