import 'package:dio/dio.dart';
import 'package:fahman_app/core/networking/api/dio_consumer.dart';
import 'package:fahman_app/core/theming/colors_manager.dart';
import 'package:fahman_app/features/auth/login/data/login_repository.dart';
import 'package:fahman_app/features/auth/login/logic/login_cubit.dart';
import 'package:fahman_app/features/auth/login/logic/login_state.dart';
import 'package:fahman_app/features/auth/login/ui/widget/login_form.dart';
import 'package:fahman_app/features/home/ui/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:fahman_app/core/services/routes.dart';
import 'package:fahman_app/core/shared/widgets/auth_split_scaffold.dart';
import 'package:fahman_app/core/shared/widgets/auth_header.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LoginEmailScreen extends StatefulWidget {
  const LoginEmailScreen({super.key});

  @override
  State<LoginEmailScreen> createState() => _LoginEmailScreenState();
}

class _LoginEmailScreenState extends State<LoginEmailScreen> {
  @override
  Widget build(BuildContext context) {
    // provide cubit with real ApiConsumer
    final dio = Dio();
    final apiConsumer = DioConsumer(dio: dio);
    final repo = LoginRepository(apiConsumer: apiConsumer);

    return BlocProvider(
      create: (_) => LoginCubit(repository: repo),
      child: BlocListener<LoginCubit, LoginState>(
        listener: (context, state) {
          if (state.error != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.error ?? 'An error occurred'),
                backgroundColor: Colors.red,
              ),
            );
          }

          if (state.data != null && state.data!['success'] == true) {
            _handleLoginSuccess(state.data!);
          }
        },
        child: AuthSplitScaffold(
          topFraction: 0.25,
          header: const AuthHeader(),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 12),
              // login form widget that uses the cubit
              const Center(child: SizedBox(width: 350, child: LoginForm())),

              SizedBox(height: 12.h),
              Center(
                child: GestureDetector(
                  onTap: () {
                    Navigator.of(
                      context,
                    ).pushReplacementNamed(Routes.registerEmail);
                  },
                  child: Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: 'auth_new_user_question_space'.tr(),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                        TextSpan(
                          text: 'auth_login_link_text_alt'.tr(),
                          style: TextStyle(
                            color: AppColors.accentMauve,
                            fontSize: 12,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleLoginSuccess(Map<String, dynamic> data) {
    // Navigate to home screen after successful login
    Navigator.of(context).push(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 600),
        pageBuilder: (context, animation, secondaryAnimation) =>
            const HomeScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final curved = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOut,
          );
          return FadeTransition(opacity: curved, child: child);
        },
      ),
    );
  }
}
