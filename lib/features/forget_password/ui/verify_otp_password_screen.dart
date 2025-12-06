import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';

import 'package:fahman_app/core/services/routes.dart';
import 'package:fahman_app/core/helpers/text_helper.dart';
import 'package:fahman_app/shared/widgets/otp_verification_widget.dart';
import '../logic/forgot_password_cubit.dart';

class VerifyOtpPasswordScreen extends StatelessWidget {
  const VerifyOtpPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ForgotPasswordCubit, ForgotPasswordState>(
      listener: (context, state) {
        // Show error messages
        if (state.errorMessage != null) {
          final errorText = state.errorMessage!.startsWith('auth_')
              ? state.errorMessage!.tr()
              : state.errorMessage!;

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(errorText), backgroundColor: Colors.red),
          );
        }

        // Navigate to reset password screen on success
        if (state.otpVerified) {
          Navigator.of(context).pushReplacementNamed(
            Routes.resetPassword,
            arguments: context.read<ForgotPasswordCubit>(),
          );
        }
      },
      builder: (context, state) {
        final cubit = context.read<ForgotPasswordCubit>();

        return OtpVerificationWidget(
          title: 'auth_verify_code_title'.tr(),
          description: 'auth_verify_code_desc'.tr(),
          maskedIdentifier: TextHelper.maskEmail(state.identifier),
          otpLength: 4,
          isLoading: state.isLoading,
          buttonText: 'auth_verify_button'.tr(),
          onVerify: (otp) {
            cubit.updateOtp(otp);
            cubit.verifyOtp();
          },
          onResend: () async {
            return await cubit.sendOtp();
          },
        );
      },
    );
  }
}
