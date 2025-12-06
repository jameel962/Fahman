import 'package:fahman_app/core/networking/api/api_consumer.dart';
import 'package:fahman_app/core/networking/api/end_points.dart';

class RegisterRepository {
  final ApiConsumer apiConsumer;

  RegisterRepository({required this.apiConsumer});

  /// Calls /Auth/register/customer with multipart/form-data
  Future<Map<String, dynamic>> registerCustomer({
    required String email,
    required String password,
    required String confirmPassword,
    required bool agreeTermsAndPolicy,
  }) async {
    final formData = {
      'Email': email,
      'Password': password,
      'ConfirmPassword': confirmPassword,
      'AgreeTermsAndPolicy': agreeTermsAndPolicy,
    };

    final response = await apiConsumer.post(
      EndPoints.registerCustomer,
      data: formData,
      isFormData: true, // This should trigger multipart form data
    );
    return response as Map<String, dynamic>;
  }
}
