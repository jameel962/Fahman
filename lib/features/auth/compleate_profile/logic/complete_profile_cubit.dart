import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fahman_app/app_logger.dart';
import '../data/complete_profile.dart';
import 'package:fahman_app/core/models/avatar_model.dart';
import 'complete_profile_state.dart';

class CompleteProfileCubit extends Cubit<CompleteProfileState> {
  final CompleteProfileRepository repo;

  CompleteProfileCubit(this.repo) : super(const CompleteProfileState());

  void updateName(String v) => emit(state.copyWith(userName: v, error: null));

  void updatePhone(String v) =>
      emit(state.copyWith(phoneNumber: v, error: null));

  void updateImagePath(String? v) =>
      emit(state.copyWith(imageFilePath: v, error: null));

  Future<bool> submit() async {
    // Validation
    final name = state.userName.trim();
    final phone = state.phoneNumber.trim();
    final avatar = state.imageFilePath;

    // Validate avatar selection
    if (avatar == null || avatar.isEmpty) {
      emit(state.copyWith(error: 'profile_avatar_required'));
      return false;
    }

    // Validate name
    if (name.isEmpty) {
      emit(state.copyWith(error: 'profile_name_required'));
      return false;
    }

    if (name.length < 2) {
      emit(state.copyWith(error: 'profile_name_too_short'));
      return false;
    }

    // Validate name contains only letters and spaces
    final nameRegex = RegExp(r'^[\u0621-\u064Aa-zA-Z\s]+$');
    if (!nameRegex.hasMatch(name)) {
      emit(state.copyWith(error: 'profile_name_letters_only'));
      return false;
    }

    // Validate phone number
    if (phone.isEmpty) {
      emit(state.copyWith(error: 'profile_phone_required'));
      return false;
    }

    // Normalize phone to local Jordan format (starting with 0) then validate
    String localPhone = phone;
    if (localPhone.startsWith('+962')) {
      final rest = localPhone.substring(4); // after +962
      if (rest.startsWith('0')) {
        localPhone = rest;
      } else {
        localPhone = '0' + rest;
      }
    } else if (localPhone.startsWith('962')) {
      // handle numbers like 9627xxxxxxx
      final rest = localPhone.substring(3);
      localPhone = rest.startsWith('0') ? rest : '0' + rest;
    } else if (localPhone.startsWith('7')) {
      // user entered '7XXXXXXXX' -> convert to '07XXXXXXXX'
      localPhone = '0' + localPhone;
    }

    // Jordan mobile numbers: 10 digits, start with 077/078/079
    final jordanReg = RegExp(r'^07[7-9][0-9]{7}$');
    if (!jordanReg.hasMatch(localPhone)) {
      emit(state.copyWith(error: 'profile_phone_invalid_jordan'));
      return false;
    }

    emit(state.copyWith(loading: true, error: null));

    try {
      AppLogger.d('CompleteProfile: Submitting profile update');
      AppLogger.d('  userName: ${state.userName}');
      AppLogger.d('  phoneNumber: ${state.phoneNumber}');
      AppLogger.d('  imageFilePath: ${state.imageFilePath}');

      // If an imageFilePath corresponds to a known avatar, prefer the JSON
      // CompleteProfile endpoint which accepts avatarId. Otherwise fallback
      // to multipart updateProfile.
      // Prefer using the JSON CompleteProfile endpoint always. If we can
      // resolve an avatarId from a remote avatar, use it; otherwise send
      // avatarId: 0 which the server should interpret as no remote avatar.
      int avatarId = 0;
      if (state.imageFilePath != null && state.imageFilePath!.isNotEmpty) {
        if (state.imageFilePath!.startsWith('http')) {
          final remoteAvatars = await repo.getAllAvatarsRemote();
          if (remoteAvatars is List) {
            final avatars = remoteAvatars
                .map((e) => AvatarModel.fromJson(Map<String, dynamic>.from(e)))
                .toList();
            final selected = avatars.firstWhere(
              (avatar) => avatar.path == state.imageFilePath,
              orElse: () => AvatarModel(id: 0, path: ''),
            );
            avatarId = selected.id;
          }
        }
      }

      final res = await repo.completeProfile(
        userName: state.userName.trim(),
        phoneNumber: state.phoneNumber.trim(),
        avatarId: avatarId,
      );

      AppLogger.d('CompleteProfile: server response $res');

      if (res['success'] == true) {
        emit(state.copyWith(loading: false));
        return true;
      }

      final errorMessage =
          res['message']?.toString() ?? 'فشل في تحديث الملف الشخصي';
      emit(state.copyWith(loading: false, error: errorMessage));
      return false;
    } catch (e) {
      AppLogger.e('CompleteProfile submit error', e);
      emit(
        state.copyWith(
          loading: false,
          error: 'خطأ في تحديث الملف الشخصي: ${e.toString()}',
        ),
      );
      return false;
    }
  }

  /// Fetch remote avatars from server (optional). Returns decoded data or null.
  Future<dynamic> fetchRemoteAvatars() async {
    final res = await repo.getAllAvatarsRemote();
    return res;
  }
}
