import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fahman_app/core/theming/colors_manager.dart';
import 'package:dio/dio.dart';
import 'package:fahman_app/core/networking/api/dio_consumer.dart';
import 'package:fahman_app/core/networking/api/api_interceptors.dart';
import 'package:fahman_app/features/data/auth/auth_repository.dart'
    as auth_repo;
import 'package:fahman_app/features/data/auth/logic/auth_cubit.dart';

class HomeGreetingHeader extends StatefulWidget {
  const HomeGreetingHeader({super.key});

  @override
  State<HomeGreetingHeader> createState() => _HomeGreetingHeaderState();
}

class _HomeGreetingHeaderState extends State<HomeGreetingHeader> {
  late AuthCubit _authCubit;

  @override
  void initState() {
    super.initState();
    // Initialize AuthCubit and load user data
    final dio = Dio();
    dio.interceptors.add(ApiInterceptor());
    final apiConsumer = DioConsumer(dio: dio);
    final repo = auth_repo.AuthRepository(apiConsumer: apiConsumer);
    _authCubit = AuthCubit(repository: repo);
    _authCubit.loadUser();
  }

  @override
  void dispose() {
    _authCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AuthCubit>.value(
      value: _authCubit,
      child: BlocBuilder<AuthCubit, AuthState>(
        builder: (context, state) {
          String name = 'auth_user_default'.tr();

          if (state is AuthLoaded) {
            final user = state.user;
            if (user.username?.isNotEmpty == true) {
              name = user.username!;
            }
          }

          return RichText(
            textAlign: TextAlign.right,
            text: TextSpan(
              style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w700),
              children: [
                TextSpan(
                  text: '${'greeting_user'.tr(namedArgs: {'name': name})}\n',
                  style: const TextStyle(color: Colors.white),
                ),
                TextSpan(
                  text: 'assistant_name'.tr(),
                  style: const TextStyle(color: Colors.white),
                ),
                TextSpan(
                  text: 'assistant_tagline'.tr(),
                  style: const TextStyle(color: AppColors.accentMauve),
                ),
                const TextSpan(
                  text: '✨',
                  style: TextStyle(color: AppColors.accentMauve),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
