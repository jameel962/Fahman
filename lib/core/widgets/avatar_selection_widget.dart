import 'package:fahman_app/core/shared/widgets/shared_ui_widgets.dart';
import 'package:fahman_app/features/complete_profile/data/complete_profile_repo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fahman_app/core/theming/colors_manager.dart';
import 'package:fahman_app/core/services/avatar_service.dart';
import 'package:fahman_app/core/models/avatar_model.dart';
import 'package:dio/dio.dart';
import 'package:fahman_app/core/networking/api/api_interceptors.dart';
import 'package:fahman_app/core/networking/api/dio_consumer.dart';

/// Widget for selecting avatar from available images
class AvatarSelectionWidget extends StatefulWidget {
  final String? selectedAvatar;
  final Function(String) onAvatarSelected;
  final double? avatarSize;
  final int? crossAxisCount;
  final bool useRemote;

  const AvatarSelectionWidget({
    super.key,
    this.selectedAvatar,
    required this.onAvatarSelected,
    this.avatarSize,
    this.crossAxisCount,
    this.useRemote = false,
  });

  @override
  State<AvatarSelectionWidget> createState() => _AvatarSelectionWidgetState();
}

class _AvatarSelectionWidgetState extends State<AvatarSelectionWidget> {
  String? _selectedAvatar;
  List<AvatarModel> _avatars = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _selectedAvatar = widget.selectedAvatar;
    _loadAvatars();
  }

  /// تحميل الأفاتارات من الخدمة
  Future<void> _loadAvatars() async {
    try {
      if (widget.useRemote) {
        try {
          // Lazily create Dio + ApiInterceptor to call repository endpoint
          final dio = Dio();
          dio.interceptors.add(ApiInterceptor());
          final repo = CompleteProfileRepository(
            apiConsumer: DioConsumer(dio: dio),
          );
          final remote = await repo.getAllAvatarsRemote();
          List<AvatarModel> parsed = [];
          if (remote is Map && remote['avatars'] is List) {
            parsed = (remote['avatars'] as List)
                .map((e) => AvatarModel.fromJson(Map<String, dynamic>.from(e)))
                .toList();
          } else if (remote is List) {
            parsed = remote
                .map((e) => AvatarModel.fromJson(Map<String, dynamic>.from(e)))
                .toList();
          }

          if (parsed.isNotEmpty) {
            setState(() {
              _avatars = parsed;
              _isLoading = false;
            });
            return;
          }
        } catch (_) {
          // fall through to local avatars
        }
      }

      final avatars = await AvatarService.getAvatars();
      setState(() {
        _avatars = avatars;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          SharedUIWidgets.sectionHeader(
            title: 'اختر صورة شخصية',
            subtitle: 'اختر الصورة التي تعبر عنك',
          ),

          // عرض حالة التحميل أو شبكة الأفاتارات
          if (_isLoading)
            const Center(child: CircularProgressIndicator())
          else
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: widget.crossAxisCount ?? 4,
                crossAxisSpacing: 12.w,
                mainAxisSpacing: 12.h,
                childAspectRatio: 1,
              ),
              itemCount: _avatars.length,
              itemBuilder: (context, index) {
                final avatar = _avatars[index];
                final isSelected = _selectedAvatar == avatar.path;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedAvatar = avatar.path;
                    });
                    widget.onAvatarSelected(avatar.path);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.brand600
                            : Colors.white.withOpacity(0.2),
                        width: isSelected ? 3 : 1,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: AppColors.brand600.withOpacity(0.3),
                                blurRadius: 8,
                                offset: Offset(0, 2.h),
                              ),
                            ]
                          : null,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12.r),
                      child: Image.asset(
                        avatar.path,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey.withOpacity(0.3),
                            child: Icon(
                              Icons.person,
                              color: Colors.white70,
                              size: 24.sp,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                );
              },
            ),

          SizedBox(height: 20.h),

          // Selected Avatar Preview
          if (_selectedAvatar != null) ...[
            SharedUIWidgets.customDivider(),
            Row(
              children: [
                Text(
                  'الصورة المختارة:',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(width: 12.w),
                SharedUIWidgets.customAvatar(
                  imagePath: _selectedAvatar!,
                  size: 40.w,
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

/// Dialog for avatar selection
class AvatarSelectionDialog extends StatelessWidget {
  final String? currentAvatar;
  final Function(String) onAvatarSelected;

  const AvatarSelectionDialog({
    super.key,
    this.currentAvatar,
    required this.onAvatarSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: Colors.white.withOpacity(0.1),
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'اختر صورة شخصية',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  SharedUIWidgets.customIconButton(
                    icon: Icons.close,
                    onTap: () => Navigator.pop(context),
                    backgroundColor: Colors.white.withOpacity(0.1),
                  ),
                ],
              ),
            ),

            // Avatar Selection
            Flexible(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(20.w),
                child: AvatarSelectionWidget(
                  selectedAvatar: currentAvatar,
                  onAvatarSelected: (avatarPath) {
                    onAvatarSelected(avatarPath);
                    Navigator.pop(context);
                  },
                  crossAxisCount: 5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static void show({
    required BuildContext context,
    String? currentAvatar,
    required Function(String) onAvatarSelected,
  }) {
    showDialog(
      context: context,
      builder: (context) => AvatarSelectionDialog(
        currentAvatar: currentAvatar,
        onAvatarSelected: onAvatarSelected,
      ),
    );
  }
}
