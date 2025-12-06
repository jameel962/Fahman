import 'package:fahman_app/core/networking/api/end_points.dart';

class ErrorModel {
  final dynamic status;
  final String message;

  ErrorModel({required this.status, required this.message});

  factory ErrorModel.fromJson(Map<String, dynamic> jsonData) {
    // The API returns different fields depending on the endpoint. Try common keys.
    String msg = '';
    if (jsonData.containsKey('message') && jsonData['message'] != null) {
      msg = jsonData['message'].toString();
    } else if (jsonData.containsKey('Message') && jsonData['Message'] != null) {
      msg = jsonData['Message'].toString();
    } else if (jsonData.containsKey('error') && jsonData['error'] != null) {
      msg = jsonData['error'].toString();
    } else if (jsonData.containsKey('errors') && jsonData['errors'] != null) {
      // errors might be a map or list
      final errors = jsonData['errors'];
      if (errors is Map) {
        msg = errors.values.map((e) => e.toString()).join('\n');
      } else if (errors is List) {
        msg = errors.map((e) => e.toString()).join('\n');
      } else {
        msg = errors.toString();
      }
    } else if (jsonData.containsKey('status') && jsonData['status'] != null) {
      msg = jsonData['status'].toString();
    }

    return ErrorModel(status: jsonData[ApiKey.status], message: msg);
  }
}
