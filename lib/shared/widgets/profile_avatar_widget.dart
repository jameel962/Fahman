import 'package:fahman_app/shared/widgets/avatar_selection_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../core/theming/colors_manager.dart';

/// ويدجت الصورة الشخصية القابلة لإعادة الاستخدام
class ProfileAvatarWidget extends StatelessWidget {
  final String? imagePath;
  final double radius;
  final bool isEditable;
  final VoidCallback? onTap;
  final String? fallbackText;

  const ProfileAvatarWidget({
    super.key,
    this.imagePath,
    this.radius = 60,
    this.isEditable = false,
    this.onTap,
    this.fallbackText,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // الصورة الرئيسية
        CircleAvatar(
          radius: radius.r,
          backgroundColor: const Color(0xFF1E1E1E),
          backgroundImage: imagePath != null
              ? (imagePath!.startsWith('assets/')
                    ? AssetImage(imagePath!)
                    : NetworkImage(imagePath!) as ImageProvider)
              : null,
          child: imagePath == null
              ? Icon(Icons.person_outline, color: Colors.white, size: radius.sp)
              : null,
        ),

        // زر التعديل (إذا كان قابلاً للتعديل)
        if (isEditable)
          Positioned(
            bottom: 0,
            right: 0,
            child: GestureDetector(
              onTap: onTap ?? _showAvatarSelection,
              child: Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: AppColors.brand600,
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF1A1A1A), width: 2),
                ),
                child: Icon(Icons.camera_alt, color: Colors.white, size: 16.sp),
              ),
            ),
          ),
      ],
    );
  }

  /// عرض نافذة اختيار الأفاتارات
  void _showAvatarSelection() {
    // سيتم تنفيذ هذا في الكلاس الأب
  }
}

/// ويدجت الصورة الشخصية مع إمكانية التعديل
class EditableProfileAvatarWidget extends StatefulWidget {
  final String? initialImagePath;
  final double radius;
  final Function(String)? onImageSelected;
  final String? fallbackText;

  const EditableProfileAvatarWidget({
    super.key,
    this.initialImagePath,
    this.radius = 60,
    this.onImageSelected,
    this.fallbackText,
  });

  @override
  State<EditableProfileAvatarWidget> createState() =>
      _EditableProfileAvatarWidgetState();
}

class _EditableProfileAvatarWidgetState
    extends State<EditableProfileAvatarWidget> {
  String? _selectedImagePath;

  @override
  void initState() {
    super.initState();
    _selectedImagePath = widget.initialImagePath;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // الصورة الرئيسية
        CircleAvatar(
          radius: widget.radius.r,
          backgroundColor: const Color(0xFF1E1E1E),
          backgroundImage: _selectedImagePath != null
              ? (_selectedImagePath!.startsWith('assets/')
                    ? AssetImage(_selectedImagePath!)
                    : NetworkImage(_selectedImagePath!) as ImageProvider)
              : null,
          child: _selectedImagePath == null
              ? Icon(
                  Icons.person_outline,
                  color: Colors.white,
                  size: widget.radius.sp,
                )
              : null,
        ),

        // زر التعديل
        Positioned(
          bottom: 0,
          right: 0,
          child: GestureDetector(
            onTap: _showAvatarSelection,
            child: Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: AppColors.brand600,
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF1A1A1A), width: 2),
              ),
              child: Icon(Icons.camera_alt, color: Colors.white, size: 16.sp),
            ),
          ),
        ),
      ],
    );
  }

  /// عرض نافذة اختيار الأفاتارات
  void _showAvatarSelection() {
    AvatarSelectionDialog.show(
      context: context,
      currentAvatar: _selectedImagePath,
      onAvatarSelected: (avatarPath) {
        setState(() {
          _selectedImagePath = avatarPath;
        });
        widget.onImageSelected?.call(avatarPath);
      },
    );
  }
}
