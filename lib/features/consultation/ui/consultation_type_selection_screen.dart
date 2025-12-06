import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fahman_app/core/theming/colors_manager.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import 'package:fahman_app/core/networking/api/dio_consumer.dart';
import 'package:fahman_app/core/networking/api/api_interceptors.dart';
import 'package:fahman_app/features/consultation/logic/consultation_cubit.dart';
import 'package:fahman_app/features/consultation/logic/consultation_state.dart';
import 'package:fahman_app/features/consultation/data/consultation_repository.dart';
import 'package:fahman_app/features/consultation/consultation_screen.dart';

class ConsultationTypeSelectionScreen extends StatelessWidget {
  const ConsultationTypeSelectionScreen({super.key});

  void _showConnectionErrorDialog(BuildContext context, String errorType) {
    String title;
    String message;

    switch (errorType) {
      case 'NO_INTERNET':
        title = 'connection_error'.tr();
        message = 'no_internet_connection'.tr();
        break;
      case 'CONNECTION_TIMEOUT':
        title = 'connection_error'.tr();
        message = 'connection_timeout'.tr();
        break;
      case 'NETWORK_ERROR':
        title = 'connection_error'.tr();
        message = 'failed_to_load_document'.tr();
        break;
      case 'SERVER_ERROR':
        title = 'error_occurred'.tr();
        message = 'server_error'.tr();
        break;
      case 'SECTIONS_NOT_FOUND':
        title = 'error_occurred'.tr();
        message = 'consultation_no_sections'.tr();
        break;
      default:
        title = 'error_occurred'.tr();
        message = errorType;
    }

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E1E1E),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          title: Row(
            children: [
              Icon(Icons.wifi_off, color: Colors.red[400], size: 28.sp),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          content: Text(
            message,
            style: GoogleFonts.inter(
              color: Colors.grey[400],
              fontSize: 14.sp,
              fontWeight: FontWeight.w400,
              height: 1.5,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(
                'cancel'.tr(),
                style: GoogleFonts.inter(
                  color: Colors.grey[400],
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                context.read<ConsultationCubit>().loadSections();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.brand800,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
              child: Text(
                'retry'.tr(),
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ConsultationCubit>(
      create: (_) {
        final dio = Dio();
        dio.interceptors.add(ApiInterceptor());
        final api = DioConsumer(dio: dio);
        final repo = ConsultationRepository(api: api);
        final cubit = ConsultationCubit(repository: repo);
        cubit.loadSections();
        return cubit;
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF1A1A1A),
        appBar: AppBar(
          backgroundColor: const Color(0xFF1A1A1A),
          elevation: 0,
          leading: IconButton(
            icon: Icon(
              context.locale.languageCode == 'ar'
                  ? Icons.arrow_back_ios
                  : Icons.arrow_forward_ios,
              color: Colors.white,
            ),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            'feature_consultations_title'.tr(),
            style: TextStyle(
              color: Colors.white,
              fontSize: 20.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
          centerTitle: true,
        ),
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20.h),

              Text(
                'consultation_type_selection_title'.tr(),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w700,
                ),
                textAlign: context.locale.languageCode == 'ar'
                    ? TextAlign.right
                    : TextAlign.left,
              ),
              SizedBox(height: 8.h),

              Text(
                'consultation_type_selection_subtitle'.tr(),
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w400,
                ),
                textAlign: context.locale.languageCode == 'ar'
                    ? TextAlign.right
                    : TextAlign.left,
              ),
              SizedBox(height: 30.h),

              Expanded(
                child: BlocConsumer<ConsultationCubit, ConsultationState>(
                  listener: (context, state) {
                    // Show alert dialog for connection errors
                    if (state.errorMessage != null &&
                        (state.errorMessage == 'NO_INTERNET' ||
                            state.errorMessage == 'CONNECTION_TIMEOUT' ||
                            state.errorMessage == 'NETWORK_ERROR')) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        _showConnectionErrorDialog(
                          context,
                          state.errorMessage!,
                        );
                      });
                    }
                  },
                  builder: (context, state) {
                    if (state.isLoadingSections) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (state.errorMessage != null) {
                      return _buildErrorView(context, state.errorMessage!);
                    }
                    final sections = state.sections;
                    if (sections.isEmpty) {
                      return Center(
                        child: Text('consultation_no_sections'.tr()),
                      );
                    }
                    return ListView.separated(
                      itemCount: sections.length,
                      separatorBuilder: (_, __) => SizedBox(height: 16.h),
                      itemBuilder: (context, index) {
                        final s = sections[index];
                        return _buildConsultationTypeCard(
                          context: context,
                          icon: Icons.topic,
                          title: s.name,
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => ConsultationScreen(
                                  initialTypeKey: 'consultation_type_dynamic',
                                  initialSectionId: s.id,
                                ),
                              ),
                            );
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorView(BuildContext context, String errorMessage) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64.sp, color: Colors.red[400]),
          SizedBox(height: 16.h),
          Text(
            'error_occurred'.tr(),
            style: GoogleFonts.inter(
              color: Colors.white,
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 8.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 32.w),
            child: Text(
              errorMessage.contains('NO_INTERNET') ||
                      errorMessage.contains('CONNECTION') ||
                      errorMessage.contains('NETWORK')
                  ? 'failed_to_load_document'.tr()
                  : errorMessage,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                color: Colors.grey[400],
                fontSize: 14.sp,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          SizedBox(height: 24.h),
          ElevatedButton(
            onPressed: () {
              context.read<ConsultationCubit>().loadSections();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.brand800,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
            ),
            child: Text(
              'retry'.tr(),
              style: GoogleFonts.inter(
                color: Colors.white,
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConsultationTypeCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(20.w),
        constraints: BoxConstraints(minHeight: 100.h),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.08),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: Colors.white.withOpacity(0.06), width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48.w,
                  height: 48.w,
                  decoration: BoxDecoration(
                    color: AppColors.brand600.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(icon, color: AppColors.brand600, size: 24.sp),
                ),
                SizedBox(width: 16.w),

                // Title
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

                Icon(
                  context.locale.languageCode == 'ar'
                      ? Icons.arrow_forward_ios
                      : Icons.arrow_back_ios,
                  color: Colors.white54,
                  size: 16.sp,
                ),
              ],
            ),

            SizedBox(height: 8.h),

            // Text(
            //   description,
            //   style: GoogleFonts.cairo(
            //     fontWeight: FontWeight.w400,
            //     fontSize: 12.sp,
            //     height: 20 / 12,
            //     letterSpacing: -0.4,
            //     color: const Color(0xFFD4D4FF),
            //   ),
            //   textAlign: context.locale.languageCode == 'ar'
            //       ? TextAlign.right
            //       : TextAlign.left,
            // ),
          ],
        ),
      ),
    );
  }
}
