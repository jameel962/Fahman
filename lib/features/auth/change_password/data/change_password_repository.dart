import 'package:fahman_app/features/auth/change_password/data/change_password_remote_data_source.dart';

class ChangePasswordRepository {
  final ChangePasswordRemoteDataSource remoteDataSource;

  ChangePasswordRepository({required this.remoteDataSource});

  Future<Map<String, dynamic>> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmNewPassword,
  }) async {
    final response = await remoteDataSource.changePassword(
      currentPassword: currentPassword,
      newPassword: newPassword,
      confirmNewPassword: confirmNewPassword,
    );

    return response;
  }
}
