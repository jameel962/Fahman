import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:dio/dio.dart';

import '../../../core/networking/api/api_interceptors.dart';
import '../../../core/networking/api/dio_consumer.dart';
import '../../../core/shared/widgets/settings_app_bar.dart';
import '../../../core/theming/colors_manager.dart';
import '../data/consultation_repository.dart';
import '../data/models/consultation_models.dart';
import '../logic/consultation_cubit.dart';
import '../logic/consultation_state.dart';

class MyConsultationsScreen extends StatefulWidget {
  const MyConsultationsScreen({super.key});

  @override
  State<MyConsultationsScreen> createState() => _MyConsultationsScreenState();
}

class _MyConsultationsScreenState extends State<MyConsultationsScreen> {
  late ConsultationCubit _cubit;

  int _currentPage = 1;
  final int _pageSize = 10;
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();

    // Initialize cubit
    final dio = Dio();
    dio.interceptors.add(ApiInterceptor());
    final apiConsumer = DioConsumer(dio: dio);
    final repository = ConsultationRepository(api: apiConsumer);
    _cubit = ConsultationCubit(repository: repository);

    _loadConsultations();
  }

  void _loadConsultations({bool refresh = false}) {
    if (refresh) {
      _currentPage = 1;
    }

    _cubit.fetchConsultations(pageNumber: _currentPage, pageSize: _pageSize);
  }

  void _loadMore() {
    if (!_isLoadingMore) {
      setState(() {
        _isLoadingMore = true;
        _currentPage++;
      });
      _loadConsultations();
    }
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: Scaffold(
        backgroundColor: const Color(0xFF121212),
        appBar: SettingsAppBar(
          title: 'استشاراتي',
          onBackPressed: () => Navigator.of(context).pop(),
        ),
        body: BlocBuilder<ConsultationCubit, ConsultationState>(
          builder: (context, state) {
            if (state.isLoadingList && _currentPage == 1) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state.errorMessage != null) {
              return _buildErrorView(state.errorMessage!);
            }

            if (state.consultations.isEmpty && !state.isLoadingList) {
              _isLoadingMore = false;
              return _buildEmptyView();
            }

            if (state.consultations.isNotEmpty) {
              _isLoadingMore = false;

              return RefreshIndicator(
                onRefresh: () async {
                  _loadConsultations(refresh: true);
                  await Future.delayed(const Duration(seconds: 1));
                },
                color: AppColors.brand800,
                backgroundColor: const Color(0xFF1E1E1E),
                child: NotificationListener<ScrollNotification>(
                  onNotification: (scrollInfo) {
                    if (scrollInfo.metrics.pixels ==
                        scrollInfo.metrics.maxScrollExtent) {
                      _loadMore();
                    }
                    return false;
                  },
                  child: ListView.builder(
                    padding: EdgeInsets.all(16.w),
                    itemCount: state.consultations.length + 1,
                    itemBuilder: (context, index) {
                      if (index == state.consultations.length) {
                        return _isLoadingMore
                            ? Center(
                                child: Padding(
                                  padding: EdgeInsets.all(16.h),
                                  child: const CircularProgressIndicator(),
                                ),
                              )
                            : const SizedBox.shrink();
                      }

                      final consultation = state.consultations[index];
                      return _buildConsultationCard(consultation);
                    },
                  ),
                ),
              );
            }

            return _buildEmptyView();
          },
        ),
      ),
    );
  }

  Widget _buildConsultationCard(ConsultationModel consultation) {
    return Card(
      margin: EdgeInsets.only(bottom: 16.h),
      color: const Color(0xFF1E1E1E),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      child: InkWell(
        onTap: () => _showConsultationDetails(consultation),
        borderRadius: BorderRadius.circular(12.r),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with status badge
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      consultation.sectionName,
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  _buildStatusBadge(consultation.status),
                ],
              ),
              SizedBox(height: 12.h),

              // Content preview
              Text(
                consultation.contentPreview.isNotEmpty
                    ? consultation.contentPreview
                    : consultation.content,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                  color: Colors.grey[400],
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w400,
                ),
              ),
              SizedBox(height: 12.h),

              // Footer with date and files count
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.access_time, size: 16.sp, color: Colors.grey),
                      SizedBox(width: 4.w),
                      Text(
                        consultation.createdAt != null
                            ? _formatDate(consultation.createdAt!)
                            : 'غير محدد',
                        style: GoogleFonts.inter(
                          color: Colors.grey,
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                  if (consultation.fileCount > 0)
                    Row(
                      children: [
                        Icon(
                          Icons.attach_file,
                          size: 16.sp,
                          color: Colors.grey,
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          '${consultation.fileCount} ملف',
                          style: GoogleFonts.inter(
                            color: Colors.grey,
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color bgColor;
    Color textColor;
    String statusLabel;

    switch (status.toLowerCase()) {
      case 'pending':
        bgColor = Colors.orange.withOpacity(0.2);
        textColor = Colors.orange;
        statusLabel = 'قيد الانتظار';
        break;
      case 'inprogress':
        bgColor = Colors.blue.withOpacity(0.2);
        textColor = Colors.blue;
        statusLabel = 'قيد المعالجة';
        break;
      case 'completed':
        bgColor = Colors.green.withOpacity(0.2);
        textColor = Colors.green;
        statusLabel = 'مكتملة';
        break;
      case 'rejected':
        bgColor = Colors.red.withOpacity(0.2);
        textColor = Colors.red;
        statusLabel = 'مرفوضة';
        break;
      default:
        bgColor = Colors.grey.withOpacity(0.2);
        textColor = Colors.grey;
        statusLabel = status;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Text(
        statusLabel,
        style: GoogleFonts.inter(
          color: textColor,
          fontSize: 12.sp,
          fontWeight: FontWeight.w600,
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
            'لا توجد استشارات',
            style: GoogleFonts.inter(
              color: Colors.grey[400],
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'ستظهر استشاراتك هنا',
            style: GoogleFonts.inter(
              color: Colors.grey[600],
              fontSize: 14.sp,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 80.sp, color: Colors.red[400]),
          SizedBox(height: 16.h),
          Text(
            'حدث خطأ',
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
              message,
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
            onPressed: () => _loadConsultations(refresh: true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.brand800,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
            ),
            child: Text(
              'إعادة المحاولة',
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

  void _showConsultationDetails(ConsultationModel consultation) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1E1E),
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) {
          return Padding(
            padding: EdgeInsets.all(20.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle bar
                Center(
                  child: Container(
                    width: 40.w,
                    height: 4.h,
                    decoration: BoxDecoration(
                      color: Colors.grey[600],
                      borderRadius: BorderRadius.circular(2.r),
                    ),
                  ),
                ),
                SizedBox(height: 20.h),

                // Title and status
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        consultation.sectionName,
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    _buildStatusBadge(consultation.status),
                  ],
                ),
                SizedBox(height: 16.h),

                // Content
                Expanded(
                  child: SingleChildScrollView(
                    controller: scrollController,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'المحتوى:',
                          style: GoogleFonts.inter(
                            color: Colors.grey[400],
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          consultation.content,
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w400,
                            height: 1.5,
                          ),
                        ),
                        SizedBox(height: 20.h),

                        // Date
                        if (consultation.createdAt != null) ...[
                          Text(
                            'تاريخ الإنشاء:',
                            style: GoogleFonts.inter(
                              color: Colors.grey[400],
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            _formatFullDate(consultation.createdAt!),
                            style: GoogleFonts.inter(
                              color: Colors.white,
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          SizedBox(height: 20.h),
                        ],

                        // Files
                        if (consultation.files.isNotEmpty) ...[
                          Text(
                            'المرفقات:',
                            style: GoogleFonts.inter(
                              color: Colors.grey[400],
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 8.h),
                          ...consultation.files.map(
                            (file) => Container(
                              margin: EdgeInsets.only(bottom: 8.h),
                              padding: EdgeInsets.all(12.w),
                              decoration: BoxDecoration(
                                color: const Color(0xFF2A2A2A),
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.attach_file,
                                    color: AppColors.brand800,
                                    size: 20.sp,
                                  ),
                                  SizedBox(width: 12.w),
                                  Expanded(
                                    child: Text(
                                      file.fileName,
                                      style: GoogleFonts.inter(
                                        color: Colors.white,
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),

                // Action buttons
                SizedBox(height: 16.h),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _showDeleteConfirmation(consultation);
                        },
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.red),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          padding: EdgeInsets.symmetric(vertical: 14.h),
                        ),
                        child: Text(
                          'حذف',
                          style: GoogleFonts.inter(
                            color: Colors.red,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _showEditDialog(consultation);
                        },
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: AppColors.brand800),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          padding: EdgeInsets.symmetric(vertical: 14.h),
                        ),
                        child: Text(
                          'تعديل',
                          style: GoogleFonts.inter(
                            color: AppColors.brand800,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.brand800,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          padding: EdgeInsets.symmetric(vertical: 14.h),
                        ),
                        child: Text(
                          'إغلاق',
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showDeleteConfirmation(ConsultationModel consultation) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: Text(
          'تأكيد الحذف',
          style: GoogleFonts.inter(
            color: Colors.white,
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Text(
          'هل أنت متأكد من حذف هذه الاستشارة؟',
          style: GoogleFonts.inter(
            color: Colors.grey[400],
            fontSize: 14.sp,
            fontWeight: FontWeight.w400,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'إلغاء',
              style: GoogleFonts.inter(
                color: Colors.grey,
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _cubit.deleteConsultation(consultation.id);
              _loadConsultations(refresh: true);

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'تم حذف الاستشارة بنجاح',
                    style: GoogleFonts.inter(color: Colors.white),
                  ),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
            child: Text(
              'حذف',
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

  void _showEditDialog(ConsultationModel consultation) {
    final contentController = TextEditingController(text: consultation.content);

    showDialog(
      context: context,
      builder: (dialogContext) {
        // Find sectionId by matching sectionName (since API doesn't return sectionId in list)
        String? selectedSectionId;

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF1E1E1E),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.r),
              ),
              title: Text(
                'تعديل الاستشارة',
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Section dropdown
                    Text(
                      'القسم',
                      style: GoogleFonts.inter(
                        color: Colors.grey[400],
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    BlocBuilder<ConsultationCubit, ConsultationState>(
                      bloc: _cubit,
                      builder: (context, state) {
                        // Load sections if not loaded
                        if (state.sections.isEmpty) {
                          _cubit.loadSections();
                        }

                        // Initialize selectedSectionId by matching sectionName
                        if (selectedSectionId == null &&
                            state.sections.isNotEmpty) {
                          final matchingSection = state.sections.firstWhere(
                            (section) =>
                                section.name == consultation.sectionName,
                            orElse: () => state.sections.first,
                          );
                          selectedSectionId = matchingSection.id;
                        }

                        return Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12.w,
                            vertical: 4.h,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2A2A2A),
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: state.sections.isEmpty
                              ? Center(
                                  child: Padding(
                                    padding: EdgeInsets.all(12.w),
                                    child: CircularProgressIndicator(
                                      color: AppColors.brand800,
                                      strokeWidth: 2,
                                    ),
                                  ),
                                )
                              : DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    value: selectedSectionId,
                                    isExpanded: true,
                                    dropdownColor: const Color(0xFF2A2A2A),
                                    style: GoogleFonts.inter(
                                      color: Colors.white,
                                      fontSize: 14.sp,
                                    ),
                                    items: state.sections.map((section) {
                                      return DropdownMenuItem<String>(
                                        value: section.id,
                                        child: Text(section.name),
                                      );
                                    }).toList(),
                                    onChanged: (value) {
                                      if (value != null) {
                                        setState(() {
                                          selectedSectionId = value;
                                        });
                                      }
                                    },
                                  ),
                                ),
                        );
                      },
                    ),
                    SizedBox(height: 16.h),

                    // Content field
                    Text(
                      'المحتوى',
                      style: GoogleFonts.inter(
                        color: Colors.grey[400],
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    TextField(
                      controller: contentController,
                      maxLines: 5,
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 14.sp,
                      ),
                      decoration: InputDecoration(
                        hintText: 'اكتب محتوى الاستشارة...',
                        hintStyle: GoogleFonts.inter(
                          color: Colors.grey[600],
                          fontSize: 14.sp,
                        ),
                        filled: true,
                        fillColor: const Color(0xFF2A2A2A),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.r),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: EdgeInsets.all(12.w),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(dialogContext);
                    // Dispose after dialog animation completes
                    Future.delayed(const Duration(milliseconds: 300), () {
                      contentController.dispose();
                    });
                  },
                  child: Text(
                    'إلغاء',
                    style: GoogleFonts.inter(
                      color: Colors.grey,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    final newContent = contentController.text.trim();

                    if (newContent.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'الرجاء إدخال محتوى الاستشارة',
                            style: GoogleFonts.inter(color: Colors.white),
                          ),
                          backgroundColor: Colors.orange,
                        ),
                      );
                      return;
                    }

                    if (selectedSectionId == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'الرجاء اختيار القسم',
                            style: GoogleFonts.inter(color: Colors.white),
                          ),
                          backgroundColor: Colors.orange,
                        ),
                      );
                      return;
                    }

                    // Show loading snackbar before closing dialog
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'جاري تحديث الاستشارة...',
                          style: GoogleFonts.inter(color: Colors.white),
                        ),
                        backgroundColor: AppColors.brand800,
                        duration: const Duration(seconds: 2),
                      ),
                    );

                    // Call update API
                    _cubit.updateConsultation(
                      id: consultation.id,
                      sectionId: selectedSectionId!,
                      content: newContent,
                    );

                    // Close dialog
                    Navigator.pop(dialogContext);

                    // Dispose controller after dialog closes (300ms for animation)
                    Future.delayed(const Duration(milliseconds: 300), () {
                      contentController.dispose();
                    });

                    // Refresh list after a delay to allow API to complete
                    Future.delayed(const Duration(seconds: 1), () {
                      if (mounted) {
                        _loadConsultations(refresh: true);
                      }
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.brand800,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                  child: Text(
                    'حفظ',
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
      },
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'اليوم';
    } else if (difference.inDays == 1) {
      return 'أمس';
    } else if (difference.inDays < 7) {
      return 'منذ ${difference.inDays} أيام';
    } else {
      return DateFormat('dd/MM/yyyy').format(date);
    }
  }

  String _formatFullDate(DateTime date) {
    return DateFormat('dd MMMM yyyy - hh:mm a', 'ar').format(date);
  }
}
