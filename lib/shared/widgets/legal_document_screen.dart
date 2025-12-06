import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/networking/api/api_interceptors.dart';
import '../../core/networking/api/dio_consumer.dart';
import '../../core/shared/widgets/settings_app_bar.dart';
import '../../core/theming/colors_manager.dart';

/// Generic reusable screen for displaying legal documents (Privacy Policy, Terms & Conditions, etc.)
class LegalDocumentScreen extends StatefulWidget {
  final String title;
  final String apiEndpoint;

  const LegalDocumentScreen({
    super.key,
    required this.title,
    required this.apiEndpoint,
  });

  @override
  State<LegalDocumentScreen> createState() => _LegalDocumentScreenState();
}

class _LegalDocumentScreenState extends State<LegalDocumentScreen> {
  List<LegalSection> _sections = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadDocument();
    });
  }

  Future<void> _loadDocument() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final dio = Dio();
      dio.interceptors.add(ApiInterceptor());
      final apiConsumer = DioConsumer(dio: dio);

      // ApiInterceptor automatically adds Accept-Language header
      final response = await apiConsumer.get(widget.apiEndpoint);

      if (response is List) {
        setState(() {
          // Only use sections from API - no default sections
          final allSections =
              response.map((json) => LegalSection.fromJson(json)).toList()
                ..sort((a, b) => a.id.compareTo(b.id));

          _sections = allSections
              .where((section) => section.level == 1)
              .toList();
          _isLoading = false;
        });
      } else {
        // Handle unexpected response format
        setState(() {
          _sections = [];
          _isLoading = false;
        });
      }
    } on DioException catch (e) {
      // Handle network errors
      String errorMessage;
      bool isConnectionError = false;

      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.sendTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        errorMessage = 'connection_timeout'.tr();
        isConnectionError = true;
      } else if (e.type == DioExceptionType.connectionError) {
        errorMessage = 'no_internet_connection'.tr();
        isConnectionError = true;
      } else if (e.response?.statusCode == 404) {
        errorMessage = 'document_not_found'.tr();
      } else if (e.response?.statusCode == 500) {
        errorMessage = 'server_error'.tr();
      } else {
        errorMessage = 'failed_to_load_document'.tr();
        isConnectionError = true;
      }

      setState(() {
        _errorMessage = errorMessage;
        _isLoading = false;
      });

      // Show alert dialog for connection errors
      if (mounted && isConnectionError) {
        _showConnectionErrorDialog(errorMessage);
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'unexpected_error_occurred'.tr();
        _isLoading = false;
      });
    }
  }

  void _showConnectionErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E1E1E),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          title: Row(
            children: [
              Icon(Icons.wifi_off, color: Colors.red[400], size: 28.sp),
              SizedBox(width: 12.w),
              Text(
                'connection_error'.tr(),
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w700,
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
              onPressed: () => Navigator.of(context).pop(),
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
                Navigator.of(context).pop();
                _loadDocument();
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
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: SettingsAppBar(
        title: widget.title,
        onBackPressed: () => Navigator.of(context).pop(),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(color: AppColors.brand800),
      );
    }

    if (_errorMessage != null) {
      return _buildErrorView();
    }

    if (_sections.isEmpty) {
      return _buildEmptyView();
    }

    return RefreshIndicator(
      onRefresh: _loadDocument,
      color: AppColors.brand800,
      backgroundColor: const Color(0xFF1E1E1E),
      child: ListView.builder(
        padding: EdgeInsets.all(16.w),
        itemCount: _sections.length,
        itemBuilder: (context, index) {
          // ✅ نمرر الـ index الصحيح (بدءاً من 1)
          return _buildSectionCard(_sections[index], index + 1);
        },
      ),
    );
  }

  // ✅ أضفنا parameter جديد: displayNumber
  Widget _buildSectionCard(LegalSection section, int displayNumber) {
    return Card(
      margin: EdgeInsets.only(bottom: 16.h),
      color: const Color(0xFF1E1E1E),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section number and title
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 6.h,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.brand800.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Text(
                    // ✅ استخدم displayNumber بدلاً من section.sectionNumber
                    displayNumber.toString(),
                    style: GoogleFonts.inter(
                      color: AppColors.brand800,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Text(
                    section.sectionTitle,
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),

            // Section content
            Text(
              section.sectionContent,
              style: GoogleFonts.inter(
                color: Colors.grey[400],
                fontSize: 14.sp,
                fontWeight: FontWeight.w400,
                height: 1.6,
              ),
            ),

            // Last updated info
            if (section.lastUpdated != null) ...[
              SizedBox(height: 12.h),
              Divider(color: Colors.grey[800], height: 1),
              SizedBox(height: 8.h),
              Row(
                children: [
                  Icon(Icons.update, size: 14.sp, color: Colors.grey[600]),
                  SizedBox(width: 4.w),
                  Text(
                    'last_updated'.tr(),
                    style: GoogleFonts.inter(
                      color: Colors.grey[600],
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  SizedBox(width: 4.w),
                  Text(
                    _formatDate(section.lastUpdated!),
                    style: GoogleFonts.inter(
                      color: Colors.grey[500],
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],

            // Subsections - ✅ أيضاً نمرر أرقام صحيحة
            if (section.subsections.isNotEmpty) ...[
              SizedBox(height: 16.h),
              ...section.subsections.asMap().entries.map((entry) {
                final subIndex = entry.key;
                final subsection = entry.value;

                return Padding(
                  padding: EdgeInsets.only(left: 16.w, bottom: 12.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        // ✅ استخدم displayNumber.subIndex (مثل: 1.1, 1.2)
                        '$displayNumber.${subIndex + 1}. ${subsection.sectionTitle}',
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 6.h),
                      Text(
                        subsection.sectionContent,
                        style: GoogleFonts.inter(
                          color: Colors.grey[400],
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w400,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.description_outlined,
            size: 80.sp,
            color: Colors.grey[600],
          ),
          SizedBox(height: 16.h),
          Text(
            'no_document_available'.tr(),
            style: GoogleFonts.inter(
              color: Colors.grey[400],
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 80.sp, color: Colors.red[400]),
          SizedBox(height: 16.h),
          Text(
            'error_occurred'.tr(),
            style: GoogleFonts.inter(
              color: Colors.red[400],
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 8.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 32.w),
            child: Text(
              _errorMessage ?? 'unknown_error'.tr(),
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                color: Colors.grey[600],
                fontSize: 14.sp,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          SizedBox(height: 24.h),
          ElevatedButton(
            onPressed: _loadDocument,
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

  String _formatDate(DateTime date) {
    return DateFormat('dd MMM yyyy', context.locale.languageCode).format(date);
  }
}

// Legal Section Model
class LegalSection {
  final int id;
  final String sectionNumber;
  final String sectionTitle;
  final String sectionContent;
  final int level;
  final DateTime? lastUpdated;
  final String? updatedBy;
  final List<LegalSection> subsections;

  LegalSection({
    required this.id,
    required this.sectionNumber,
    required this.sectionTitle,
    required this.sectionContent,
    required this.level,
    this.lastUpdated,
    this.updatedBy,
    required this.subsections,
  });

  factory LegalSection.fromJson(Map<String, dynamic> json) {
    return LegalSection(
      id: json['id'] as int,
      sectionNumber: json['sectionNumber']?.toString() ?? '',
      sectionTitle: json['sectionTitle']?.toString() ?? '',
      sectionContent: json['sectionContent']?.toString() ?? '',
      level: json['level'] as int? ?? 1,
      lastUpdated: json['lastUpdated'] != null
          ? DateTime.tryParse(json['lastUpdated'])
          : null,
      updatedBy: json['updatedBy']?.toString(),
      subsections:
          (json['subsections'] as List<dynamic>?)
              ?.map((e) => LegalSection.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}
