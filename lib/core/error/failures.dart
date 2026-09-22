import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;

  const Failure(this.message);

  @override
  List<Object?> get props => [message];
}

class ServerFailure extends Failure {
  const ServerFailure([super.message = 'A server error occurred. Please try again.']);
}

class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Failed to load cached data.']);
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'No internet connection. Displaying offline data.']);
}

class AuthFailure extends Failure {
  const AuthFailure([super.message = 'Invalid credentials or authentication error.']);
}

class BookingFailure extends Failure {
  const BookingFailure([super.message = 'Failed to book appointment.']);
}

class ServerException implements Exception {
  final String message;
  ServerException([this.message = 'Server Exception']);
}

class CacheException implements Exception {
  final String message;
  CacheException([this.message = 'Cache Exception']);
}
