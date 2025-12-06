import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:fahman_app/features/consultation/logic/consultation_cubit.dart';
import 'package:fahman_app/features/consultation/logic/consultation_state.dart';
import 'package:fahman_app/features/consultation/data/models/consultation_models.dart';
import 'package:file_selector/file_selector.dart';

class ConsultationList extends StatelessWidget {
  const ConsultationList({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ConsultationCubit, ConsultationState>(
      builder: (context, state) {
        final items = state.consultations;
        if (state.isLoadingList && items.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        if (items.isEmpty) {
          return Center(child: Text('consultation_no_consultations'.tr()));
        }
        return NotificationListener<ScrollNotification>(
          onNotification: (n) {
            if (n.metrics.pixels >= n.metrics.maxScrollExtent - 100 &&
                state.hasMore &&
                !state.isLoadingList) {
              context.read<ConsultationCubit>().loadConsultations();
            }
            return false;
          },
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length + (state.isLoadingList ? 1 : 0),
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              if (index >= items.length) {
                return const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              final c = items[index];

              return _ConsultationListItem(consultation: c);
            },
          ),
        );
      },
    );
  }
}

class _ConsultationListItem extends StatelessWidget {
  const _ConsultationListItem({required this.consultation});

  final ConsultationModel consultation;

  @override
  Widget build(BuildContext context) {
    final titleText = consultation.sectionName.isNotEmpty
        ? consultation.sectionName
        : consultation.sectionId;
    return ListTile(
      title: Text(titleText),
      subtitle: Text(
        consultation.content,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: PopupMenuButton<String>(
        onSelected: (v) async {
          final cubit = context.read<ConsultationCubit>();
          if (v == 'delete') {
            await cubit.deleteConsultation(consultation.id);
          } else if (v == 'add_file') {
            final typeGroup = const XTypeGroup(label: 'files');
            final xf = await openFile(acceptedTypeGroups: [typeGroup]);
            if (xf != null) {
              await cubit.addFiles(consultation.id, [File(xf.path)]);
            }
          }
        },
        itemBuilder: (context) => [
          PopupMenuItem(
            value: 'add_file',
            child: Text('consultation_add_file'.tr()),
          ),
          PopupMenuItem(
            value: 'delete',
            child: Text('consultation_delete'.tr()),
          ),
        ],
      ),
    );
  }
}

/// After creating a consultation (POST /api/customer/Consultations),
/// use this widget to upload additional files via POST /api/customer/Consultations/{id}/files.
class ConsultationAttachmentsUploader extends StatelessWidget {
  const ConsultationAttachmentsUploader({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ConsultationCubit, ConsultationState>(
      builder: (context, state) {
        final id = state.lastCreatedConsultationId;
        if (id == null || id.isEmpty) {
          return const SizedBox.shrink();
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 8),
            const Text(
              'Upload more files to your new consultation',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: state.isMutating
                      ? null
                      : () async {
                          final typeGroup = const XTypeGroup(label: 'files');
                          final xf = await openFile(
                            acceptedTypeGroups: [typeGroup],
                          );
                          if (xf != null) {
                            await context.read<ConsultationCubit>().addFiles(
                              id,
                              [File(xf.path)],
                            );
                          }
                        },
                  icon: const Icon(Icons.attach_file),
                  label: Text('consultation_add_file'.tr()),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
