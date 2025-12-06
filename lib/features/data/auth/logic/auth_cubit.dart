import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:fahman_app/features/data/auth/auth_repository.dart';
import 'package:fahman_app/features/data/auth/models/user_info.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository repository;
  AuthCubit({required this.repository}) : super(AuthInitial());

  Future<void> loadUser() async {
    emit(AuthLoading());
    try {
      final user = await repository.getUserInfo();
      if (user != null) {
        emit(AuthLoaded(user));
      } else {
        emit(const AuthError('Failed to load user'));
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }
}
