import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:fahman_app/features/consultation/ui/consultation_form.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import 'package:fahman_app/core/networking/api/dio_consumer.dart';
import 'package:fahman_app/core/networking/api/api_interceptors.dart';
import 'package:fahman_app/features/consultation/logic/consultation_cubit.dart';
import 'package:fahman_app/features/consultation/logic/consultation_state.dart';
import 'package:fahman_app/features/consultation/data/consultation_repository.dart';
import 'dart:io';
import 'package:file_selector/file_selector.dart';

class ConsultationScreen extends StatelessWidget {
  final String initialTypeKey;
  final String? initialSectionId;
  const ConsultationScreen({
    super.key,
    this.initialTypeKey = 'consultation_type_legal',
    this.initialSectionId,
  });

  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<ConsultationFormState>();

    return BlocProvider<ConsultationCubit>(
      create: (_) {
        final dio = Dio();
        dio.interceptors.add(ApiInterceptor());
        final api = DioConsumer(dio: dio);
        final repo = ConsultationRepository(api: api);
        final cubit = ConsultationCubit(repository: repo);
        cubit.loadSections(); // Only load sections, no consultations list
        return cubit;
      },
      child: BlocListener<ConsultationCubit, ConsultationState>(
        listenWhen: (p, c) =>
            p.errorMessage != c.errorMessage ||
            p.lastServerMessage != c.lastServerMessage ||
            p.isSubmitting != c.isSubmitting,
        listener: (context, state) {
          if (state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage ?? 'An error occurred'),
                backgroundColor: Colors.red,
              ),
            );
          } else if (state.lastServerMessage != null && !state.isSubmitting) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.lastServerMessage ?? 'Operation completed'),
                backgroundColor: Colors.green,
              ),
            );
            // Reset form after successful submission
            formKey.currentState?.resetForm();
          }
        },
        child: Scaffold(
          appBar: AppBar(
            title: Text('feature_consultations_title'.tr()),
            centerTitle: true,
          ),
          body: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: BlocBuilder<ConsultationCubit, ConsultationState>(
              builder: (context, state) {
                final sectionNames = state.sections.map((s) => s.name).toList();
                final sectionIds = state.sections.map((s) => s.id).toList();

                print('📋 Sections loaded: ${sectionIds.length}');
                print('   Section Names: $sectionNames');
                print('   Section IDs: $sectionIds');

                return SingleChildScrollView(
                  child: ConsultationForm(
                    key: formKey,
                    consultationTypeKey: initialTypeKey,
                    sectionNames: sectionNames,
                    sectionIds: sectionIds,
                    initialSectionId: initialSectionId,
                    onSubmit:
                        ({
                          required String sectionId,
                          required String content,
                          List<XFile> files = const [],
                        }) async {
                          print('🚀 Submitting consultation...');
                          final cubit = context.read<ConsultationCubit>();
                          final ioFiles = files
                              .map((xf) => File(xf.path))
                              .toList();

                          await cubit.createConsultation(
                            sectionId: sectionId,
                            content: content,
                            files: ioFiles,
                            forwardHistoryUrl: null,
                          );
                        },
                  ),
                );
              },
            ),
          ),
          backgroundColor: Colors.transparent,
        ),
      ),
    );
  }
}
