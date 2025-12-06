import 'package:equatable/equatable.dart';

class VerifyEmailState extends Equatable {
  final String otp;
  final bool loading;
  final String? error;

  const VerifyEmailState({this.otp = '', this.loading = false, this.error});

  VerifyEmailState copyWith({String? otp, bool? loading, String? error}) {
    return VerifyEmailState(
      otp: otp ?? this.otp,
      loading: loading ?? this.loading,
      error: error,
    );
  }

  @override
  List<Object?> get props => [otp, loading, error];
}
