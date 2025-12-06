import 'package:easy_localization/easy_localization.dart';
import 'package:fahman_app/core/services/routes.dart';
import 'package:fahman_app/features/auth/login/ui/widget/custom_text_form_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fahman_app/core/theming/colors_manager.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../logic/login_cubit.dart';
import '../../logic/login_state.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _identifierController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    // push values to cubit and then call login
    final cubit = context.read<LoginCubit>();
    cubit.updateIdentifier(
      _identifierController.text.trim(),
      validateNow: true,
    );
    cubit.updatePassword(_passwordController.text, validateNow: true);
    // cubit.login will validate again and early-return if invalid
    cubit.login();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LoginCubit, LoginState>(
      builder: (context, state) {
        final isLoading = state.loading;
        return Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              BlocBuilder<LoginCubit, LoginState>(
                builder: (context, state) {
                  return CustomTextFormField(
                    controller: _identifierController,
                    labelText: 'auth_email_label'.tr(),
                    errorText: state.identifierError,
                    onChanged: (v) => context
                        .read<LoginCubit>()
                        .updateIdentifier(v, validateNow: false),
                    prefixIcon: Icon(Icons.email),
                  );
                },
              ),
              const SizedBox(height: 20),
              BlocBuilder<LoginCubit, LoginState>(
                builder: (context, state) {
                  return CustomTextFormField(
                    controller: _passwordController,
                    labelText: 'auth_password_label'.tr(),
                    errorText: state.passwordError,
                    obscureText: true,
                    onChanged: (v) => context.read<LoginCubit>().updatePassword(
                      v,
                      validateNow: false,
                    ),
                    prefixIcon: Icon(Icons.lock),
                  );
                },
              ),
              const SizedBox(height: 12),
              // show API message when present
              BlocBuilder<LoginCubit, LoginState>(
                builder: (context, state) {
                  final apiMsg =
                      state.data != null && state.data!['message'] != null
                      ? state.data!['message'].toString()
                      : state.error;
                  if (apiMsg == null) return const SizedBox.shrink();
                  // Display the error message as-is without translation
                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: Colors.red[50],
                      border: Border.all(color: Colors.red[200]!),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      apiMsg,
                      style: TextStyle(color: Colors.red[700]),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  BlocBuilder<LoginCubit, LoginState>(
                    builder: (context, state) {
                      return Checkbox(
                        value: state.rememberMe,
                        onChanged: (v) => context
                            .read<LoginCubit>()
                            .toggleRememberMe(v ?? false),
                        side: BorderSide(color: Colors.grey[600]!),
                        checkColor: Colors.white,
                        activeColor: AppColors.accentMauve,
                      );
                    },
                  ),
                  Text('auth_remember_me_text'.tr()),
                  Spacer(),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pushNamed(Routes.forgotPassword);
                    },
                    child: Text(
                      'auth_forgot_password_text'.tr(),
                      style: GoogleFonts.inter(
                        color: AppColors.accentMauve,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        height: 22 / 13,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                  ),
                  child: isLoading
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : Text('auth_login_button_text'.tr()),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
