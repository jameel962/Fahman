import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fahman_app/features/auth/login/ui/widget/custom_text_form_field.dart';
import 'package:fahman_app/core/theming/colors_manager.dart';

import 'package:fahman_app/core/services/routes.dart';
// colors_manager not used here
import '../../logic/register_cubit.dart';
import '../../logic/register_state.dart';

class RegisterForm extends StatefulWidget {
  const RegisterForm({super.key});

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _submit() {
    // Just call registerCustomer - it will validate everything
    context.read<RegisterCubit>().registerCustomer();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<RegisterCubit, RegisterState>(
      listener: (context, state) {
        if (state.status == RegisterStatus.success) {
          Navigator.of(context).pushNamed(
            Routes.verifyEmail,
            arguments: {
              'email': state.email,
              'userID': state.userID,
              'password': state.password,
              'confirmPassword': state.confirmPassword,
              'isRegistration': true,
            },
          );
        }
      },
      builder: (context, state) {
        final isLoading = state.status == RegisterStatus.loading;
        return Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Email field
              BlocBuilder<RegisterCubit, RegisterState>(
                builder: (context, state) {
                  return CustomTextFormField(
                    prefixIcon: Icon(Icons.email),
                    controller: _emailController,
                    labelText: 'auth_email_label'.tr(),
                    errorText: state.emailError,
                    keyboardType: TextInputType.emailAddress,
                    onChanged: (v) => context.read<RegisterCubit>().updateEmail(
                      v,
                      validateNow: false,
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),

              // Password field
              BlocBuilder<RegisterCubit, RegisterState>(
                builder: (context, state) {
                  return CustomTextFormField(
                    prefixIcon: Icon(Icons.lock),
                    controller: _passwordController,
                    labelText: 'auth_password_label'.tr(),
                    errorText: state.passwordError,
                    obscureText: true,
                    onChanged: (v) => context
                        .read<RegisterCubit>()
                        .updatePassword(v, validateNow: false),
                  );
                },
              ),
              const SizedBox(height: 12),

              // Confirm password field
              BlocBuilder<RegisterCubit, RegisterState>(
                builder: (context, state) {
                  return CustomTextFormField(
                    prefixIcon: Icon(Icons.lock),
                    controller: _confirmPasswordController,
                    labelText: 'auth_confirm_password_label'.tr(),
                    errorText: state.confirmPasswordError,
                    obscureText: true,
                    onChanged: (v) => context
                        .read<RegisterCubit>()
                        .updateConfirmPassword(v, validateNow: false),
                  );
                },
              ),
              const SizedBox(height: 24),

              // Terms and Privacy Policy acceptance
              BlocBuilder<RegisterCubit, RegisterState>(
                builder: (context, state) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Checkbox(
                            value: state.acceptedTerms,
                            onChanged: (value) {
                              context
                                  .read<RegisterCubit>()
                                  .updateTermsAcceptance(value ?? false);
                            },
                            activeColor: AppColors.brand800,
                            side: BorderSide(
                              color: state.termsError != null
                                  ? Colors.red
                                  : Colors.grey,
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(top: 12),
                              child: RichText(
                                text: TextSpan(
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                  ),
                                  children: [
                                    TextSpan(text: 'accept_terms_prefix'.tr()),
                                    TextSpan(
                                      text: 'terms_link'.tr(),
                                      style: TextStyle(
                                        color: AppColors.brand800,
                                        decoration: TextDecoration.underline,
                                      ),
                                      recognizer: TapGestureRecognizer()
                                        ..onTap = () {
                                          Navigator.pushNamed(
                                            context,
                                            Routes.termsConditions,
                                          );
                                        },
                                    ),
                                    TextSpan(text: 'accept_terms_middle'.tr()),
                                    TextSpan(
                                      text: 'privacy_link'.tr(),
                                      style: TextStyle(
                                        color: AppColors.brand800,
                                        decoration: TextDecoration.underline,
                                      ),
                                      recognizer: TapGestureRecognizer()
                                        ..onTap = () {
                                          Navigator.pushNamed(
                                            context,
                                            Routes.privacyPolicy,
                                          );
                                        },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (state.termsError != null)
                        Padding(
                          padding: const EdgeInsets.only(left: 16, top: 4),
                          child: Text(
                            state.termsError!.tr(),
                            style: TextStyle(color: Colors.red, fontSize: 12),
                          ),
                        ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 16),

              // Error message
              if (state.error != null)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    border: Border.all(color: Colors.red[200]!),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    // Display error message as-is without translation
                    state.error!,
                    style: TextStyle(color: Colors.red[700]),
                  ),
                ),

              // Submit button
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
                      : Text('auth_register_button'.tr()),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
