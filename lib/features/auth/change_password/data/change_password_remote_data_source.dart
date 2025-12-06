import 'package:fahman_app/core/networking/api/api_consumer.dart';
import 'package:fahman_app/core/networking/api/end_points.dart';

class ChangePasswordRemoteDataSource {
  final ApiConsumer api;

  ChangePasswordRemoteDataSource({required this.api});

  Future<Map<String, dynamic>> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmNewPassword,
  }) async {
    final body = {
      'currentPassword': currentPassword,
      'newPassword': newPassword,
      'confirmNewPassword': confirmNewPassword,
    };

    final response = await api.post(
      EndPoints.changePassword,
      data: body,
      isFormData: false,
    );

    return (response as Map).cast<String, dynamic>();
  }
}
