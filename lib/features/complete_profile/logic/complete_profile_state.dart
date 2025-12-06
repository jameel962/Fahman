import 'package:equatable/equatable.dart';

class CompleteProfileState extends Equatable {
  final String userName;
  final String phoneNumber;
  final String? imageFilePath;
  final bool loading;
  final String? error;

  const CompleteProfileState({
    this.userName = '',
    this.phoneNumber = '',
    this.imageFilePath,
    this.loading = false,
    this.error,
  });

  CompleteProfileState copyWith({
    String? userName,
    String? phoneNumber,
    String? imageFilePath,
    bool? loading,
    String? error,
  }) {
    return CompleteProfileState(
      userName: userName ?? this.userName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      imageFilePath: imageFilePath ?? this.imageFilePath,
      loading: loading ?? this.loading,
      error: error,
    );
  }

  @override
  List<Object?> get props => [
    userName,
    phoneNumber,
    imageFilePath,
    loading,
    error,
  ];
}
