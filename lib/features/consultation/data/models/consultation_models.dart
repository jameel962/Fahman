import 'dart:io';
import 'package:dio/dio.dart';

class ConsultationSectionModel {
  final String id;
  final String name;

  ConsultationSectionModel({required this.id, required this.name});

  factory ConsultationSectionModel.fromJson(Map<String, dynamic> json) {
    return ConsultationSectionModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
    );
  }
}

class ConsultationFileModel {
  final String id;
  final String fileName;
  final String url;

  ConsultationFileModel({
    required this.id,
    required this.fileName,
    required this.url,
  });

  factory ConsultationFileModel.fromJson(Map<String, dynamic> json) {
    return ConsultationFileModel(
      id: json['id']?.toString() ?? '',
      fileName: json['fileName']?.toString() ?? '',
      url: json['url']?.toString() ?? '',
    );
  }
}

class ConsultationModel {
  final String id;
  final String sectionId;
  final String sectionName;
  final String content;
  final String contentPreview;
  final String status;
  final DateTime? createdAt;
  final List<ConsultationFileModel> files;
  final int fileCount;
  final String? userName;

  ConsultationModel({
    required this.id,
    required this.sectionId,
    required this.sectionName,
    required this.content,
    required this.contentPreview,
    required this.status,
    required this.createdAt,
    required this.files,
    required this.fileCount,
    this.userName,
  });

  factory ConsultationModel.fromJson(Map<String, dynamic> json) {
    return ConsultationModel(
      id: json['id']?.toString() ?? '',
      sectionId: json['sectionId']?.toString() ?? '',
      sectionName: json['sectionName']?.toString() ?? '',
      content:
          json['content']?.toString() ??
          json['contentPreview']?.toString() ??
          '',
      contentPreview:
          json['contentPreview']?.toString() ??
          json['content']?.toString() ??
          '',
      status: json['status']?.toString() ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'])
          : null,
      files:
          (json['files'] as List?)
              ?.map((e) => ConsultationFileModel.fromJson(e))
              .toList() ??
          const [],
      fileCount:
          json['fileCount'] as int? ?? (json['files'] as List?)?.length ?? 0,
      userName: json['userName']?.toString(),
    );
  }
}

class ConsultationCreateRequest {
  final String sectionId;
  final String content;
  final List<File> files;

  ConsultationCreateRequest({
    required this.sectionId,
    required this.content,
    required this.files,
  });

  Map<String, dynamic> toFormData() {
    return {
      'SectionId': sectionId,
      'Content': content,
      'Files': files
          .map(
            (f) => MultipartFile.fromFileSync(
              f.path,
              filename: f.path.split('/').last,
            ),
          )
          .toList(),
    };
  }
}
