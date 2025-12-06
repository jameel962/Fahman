class EndPoints {
  // Base (use only if you need full url helpers)
  static const String baseUrl = 'http://fahman.net/';
  // static const String baseUrl = 'http://fahmaan.runasp.net/';

  // Auth
  static const String login = '/Auth/login';
  static const String logout = '/Auth/logout/{refreshToken}';
  static const String registerCustomer = '/Auth/register/customer';
  static const String changePassword = '/Auth/change-password';
  static const String refreshToken = '/Auth/refresh-token/{refreshToken}';
  static const String validateUsername = '/Auth/validate-username/{username}';
  static const String validateEmail = '/Auth/validate-email/{email}';
  static const String validatePhone = '/Auth/validate-phone/{phone}';
  static const String verifyOtp = '/Auth/verfiyOtp';
  static const String resendAuthOtp = '/Auth/reSendAuth-otp';
  static const String getUserInfo = '/Auth/GetUserInfo';
  static const String passwordSendOtp = '/Auth/password/send-otp';
  static const String passwordVerifyOtp = '/Auth/password/verify-otp';
  static const String passwordReset = '/Auth/password/reset';
  static const String updateUserInfo = '/Auth/UpdateUserInfo';
  static const String completeProfile = '/Auth/CompleteProfile';

  // Chat
  static const String chatMessage = '/api/Chat/message';
  static const String chatConversations = '/api/Chat/conversations';
  static const String chatConversation =
      '/api/Chat/conversation/{conversationId}';
  static const String chatConversationMessages =
      '/api/Chat/conversation/{conversationId}';

  // Articles
  static const String articles = '/api/Article';

  // Comments
  static const String comments = '/api/Comment';
  static const String commentById = '/api/Comment/{id}';
  static const String commentsByArticle = '/api/Comment/article/{articleId}';

  // Likes
  static const String toggleLike = '/api/Like/toggle/{articleId}';
  static const String likeCount = '/api/Like/count/{articleId}';
  static const String checkLike = '/api/Like/check/{articleId}';

  // Static
  static const String allAvatars = '/api/Static/AllAvatars';

  static const String consultationSections =
      '/api/customer/Consultations/sections';

  static const String consultations = '/api/customer/Consultations';
  static const String consultationById = '/api/customer/Consultations/{id}';
  static const String consultationFiles =
      '/api/customer/Consultations/{id}/files';
  static const String deleteConsultationFile =
      '/api/customer/Consultations/{consultationId}/files/{fileId}';

  /// Helper: replace path params like {id} with values from [params].
  /// Example:
  ///   EndPoints.withParams(EndPoints.logout, {'refreshToken': token})
  static String withParams(String pathTemplate, Map<String, Object?> params) {
    var result = pathTemplate;
    params.forEach((key, value) {
      result = result.replaceAll('{$key}', value?.toString() ?? '');
    });
    return result;
  }

  /// Helper: full url with base
  static String full(String path) => '$baseUrl$path';
}

class ApiKey {
  static String status = "status";
  static String errorMessage = "ErrorMessage";
  static String email = "email";
  static String password = "password";
  static String token = "token";
  static String refreshToken = "refreshToken";
  static String userID = "userID";
  static String message = "message";
  static String id = "id";
  static String name = "name";
  static String phone = "phone";
  static String confirmPassword = "confirmPassword";
  static String location = "location";
  static String profilePic = "profilePic";
}
