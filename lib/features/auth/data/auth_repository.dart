import 'package:shared_preferences/shared_preferences.dart';
import 'package:medmylife/core/error/failures.dart';
import 'package:medmylife/features/auth/domain/models/user_model.dart';

abstract class AuthRepository {
  Future<bool> isLoggedIn();
  Future<UserModel?> getSavedUser();
  Future<UserModel> login({required String identifier, required String password});
  Future<void> logout();
}

class AuthRepositoryImpl implements AuthRepository {
  final SharedPreferences sharedPreferences;

  static const String _keyUserId = 'user_id';
  static const String _keyUserIdentifier = 'user_identifier';
  static const String _keyUserName = 'user_name';

  AuthRepositoryImpl({required this.sharedPreferences});

  @override
  Future<bool> isLoggedIn() async {
    return sharedPreferences.containsKey(_keyUserId);
  }

  @override
  Future<UserModel?> getSavedUser() async {
    final id = sharedPreferences.getString(_keyUserId);
    final identifier = sharedPreferences.getString(_keyUserIdentifier);
    final name = sharedPreferences.getString(_keyUserName);

    if (id != null && identifier != null && name != null) {
      return UserModel(id: id, identifier: identifier, name: name);
    }
    return null;
  }

  @override
  Future<UserModel> login({required String identifier, required String password}) async {
    await Future.delayed(const Duration(milliseconds: 1000));

    final trimmedId = identifier.trim();
    if (trimmedId.isEmpty || password.isEmpty) {
      throw const AuthFailure('Email/Mobile and Password cannot be empty.');
    }

    if (password.length < 6) {
      throw const AuthFailure('Password must be at least 6 characters.');
    }

    if (trimmedId.toLowerCase() == 'error@medmylife.com' || password == 'wrong123') {
      throw const AuthFailure('Invalid credentials. Please check identifier and password.');
    }

    final String displayName = trimmedId.contains('@')
        ? trimmedId.split('@').first
        : 'Patient ($trimmedId)';

    final user = UserModel(
      id: 'USR_${DateTime.now().millisecondsSinceEpoch}',
      identifier: trimmedId,
      name: displayName,
    );

    await sharedPreferences.setString(_keyUserId, user.id);
    await sharedPreferences.setString(_keyUserIdentifier, user.identifier);
    await sharedPreferences.setString(_keyUserName, user.name);

    return user;
  }

  @override
  Future<void> logout() async {
    await sharedPreferences.remove(_keyUserId);
    await sharedPreferences.remove(_keyUserIdentifier);
    await sharedPreferences.remove(_keyUserName);
  }
}
