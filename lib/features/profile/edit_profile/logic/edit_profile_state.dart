import 'package:equatable/equatable.dart';

class EditProfileState extends Equatable {
  final String userName;
  final String? avatarPath;
  final bool loading;
  final String? error;

  const EditProfileState({
    this.userName = '',
    this.avatarPath,
    this.loading = false,
    this.error,
  });

  EditProfileState copyWith({
    String? userName,
    String? avatarPath,
    bool? loading,
    String? error,
  }) {
    return EditProfileState(
      userName: userName ?? this.userName,
      avatarPath: avatarPath ?? this.avatarPath,
      loading: loading ?? this.loading,
      error: error,
    );
  }

  @override
  List<Object?> get props => [userName, avatarPath, loading, error];
}
