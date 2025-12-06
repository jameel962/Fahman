import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fahman_app/features/profile/edit_profile/logic/edit_profile_state.dart';
import 'package:fahman_app/features/data/auth/auth_repository.dart'
    as auth_repo;
import 'package:fahman_app/features/profile/edit_profile/data/edit_profile.dart';
import 'package:fahman_app/app_logger.dart';
import 'package:fahman_app/core/models/avatar_model.dart';

class EditProfileCubit extends Cubit<EditProfileState> {
  final auth_repo.AuthRepository authRepo;
  final UpdateProfileRepository profileRepo;

  EditProfileCubit({required this.authRepo, required this.profileRepo})
    : super(const EditProfileState());

  /// Load current user info and populate state.
  Future<void> loadUserInfo() async {
    emit(state.copyWith(loading: true, error: null));
    try {
      final user = await authRepo.getUserInfo();
      if (user != null) {
        emit(
          state.copyWith(
            loading: false,
            userName: user.username ?? '',
            avatarPath: user.profileImage,
          ),
        );
      } else {
        emit(state.copyWith(loading: false));
      }
    } catch (e, st) {
      AppLogger.e('EditProfile loadUserInfo error', e, st);
      emit(state.copyWith(loading: false, error: e.toString()));
    }
  }

  void updateName(String v) => emit(state.copyWith(userName: v, error: null));

  void updateAvatar(String? path) =>
      emit(state.copyWith(avatarPath: path, error: null));

  /// Submit edit: resolve avatarId when possible and call UpdateUserInfo.
  Future<bool> submit() async {
    final name = state.userName.trim();
    if (name.isEmpty || name.length < 6) {
      emit(
        state.copyWith(error: 'الرجاء إدخال اسم صحيح مكون من حرفين على الأقل'),
      );
      return false;
    }

    emit(state.copyWith(loading: true, error: null));
    try {
      int avatarId = 0;
      if (state.avatarPath != null && state.avatarPath!.startsWith('http')) {
        final remote = await profileRepo.getAllAvatarsRemote();
        if (remote is List) {
          final avatars = remote
              .map((e) => AvatarModel.fromJson(Map<String, dynamic>.from(e)))
              .toList();
          final selected = avatars.firstWhere(
            (a) => a.path == state.avatarPath,
            orElse: () => AvatarModel(id: 0, path: ''),
          );
          if (selected.id != 0) avatarId = selected.id;
        } else if (remote is Map && remote['avatars'] is List) {
          final avatars = (remote['avatars'] as List)
              .map((e) => AvatarModel.fromJson(Map<String, dynamic>.from(e)))
              .toList();
          final selected = avatars.firstWhere(
            (a) => a.path == state.avatarPath,
            orElse: () => AvatarModel(id: 0, path: ''),
          );
          if (selected.id != 0) avatarId = selected.id;
        }
      }

      final res = await profileRepo.updateUserInfoJson(
        userName: name,
        avatarId: avatarId,
      );

      if (res['success'] == true) {
        emit(state.copyWith(loading: false));
        return true;
      }

      final errorMessage =
          res['message']?.toString() ?? 'فشل في تحديث الملف الشخصي';
      emit(state.copyWith(loading: false, error: errorMessage));
      return false;
    } catch (e, st) {
      AppLogger.e('EditProfile submit error', e, st);
      emit(state.copyWith(loading: false, error: e.toString()));
      return false;
    }
  }
}
