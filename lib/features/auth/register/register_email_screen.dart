import 'package:dio/dio.dart';
import 'package:fahman_app/core/networking/api/dio_consumer.dart';
import 'package:fahman_app/core/theming/colors_manager.dart';
import 'package:fahman_app/features/auth/register/data/register_repository.dart';
import 'package:fahman_app/features/auth/register/logic/register_cubit.dart';
import 'package:fahman_app/features/auth/register/logic/register_state.dart';
import 'package:fahman_app/features/auth/register/ui/widget/register_form.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:fahman_app/core/services/routes.dart';
import 'package:fahman_app/core/shared/widgets/auth_split_scaffold.dart';
import 'package:fahman_app/core/shared/widgets/auth_header.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class RegisterEmailScreen extends StatelessWidget {
  const RegisterEmailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // provide cubit with real ApiConsumer
    final dio = Dio();
    final apiConsumer = DioConsumer(dio: dio);
    final repo = RegisterRepository(apiConsumer: apiConsumer);

    return BlocProvider(
      create: (_) => RegisterCubit(repository: repo),
      child: BlocListener<RegisterCubit, RegisterState>(
        listener: (context, state) {
          // Handle general API errors
          if (state.error != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.error ?? 'An error occurred'),
                backgroundColor: Colors.red,
              ),
            );
          }
          // Navigate to verification screen on success
          if (state.status == RegisterStatus.success) {
            Navigator.of(context).pushNamed(
              Routes.verifyEmail,
              arguments: {
                'email': state.email,
                'userID': state.userID,
                'isRegistration': true,
              },
            );
          }
        },
        child: AuthSplitScaffold(
          topFraction: 0.25,
          header: AuthHeader(subtitle: 'auth_register_title'.tr()),
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: 12),
                // Padding(
                //   padding: const EdgeInsets.symmetric(horizontal: 24),
                //   child: Text(
                //     'auth_register_title'.tr(),
                //     style: GoogleFonts.inter(
                //       color: Colors.white,
                //       fontSize: 16,
                //       fontWeight: FontWeight.w700,
                //       letterSpacing: 0.2,
                //     ),
                //     textAlign: TextAlign.center,
                //   ),
                // ),
                SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: RegisterForm(),
                ),
                SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Center(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.of(
                          context,
                        ).pushReplacementNamed(Routes.loginEmail);
                      },
                      child: Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: 'auth_have_account_question_space'.tr(),
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                            TextSpan(
                              text: 'auth_login_link_text'.tr(),
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
                ),
                SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
