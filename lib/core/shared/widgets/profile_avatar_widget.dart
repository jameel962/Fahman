import 'package:fahman_app/core/shared/widgets/avatar_selection_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../theming/colors_manager.dart';

/// Reusable profile avatar widget with optional edit button.
class ProfileAvatarWidget extends StatelessWidget {
  final String? imagePath;
  final double radius;
  final bool isEditable;
  final VoidCallback? onTap;

  const ProfileAvatarWidget({
    super.key,
    this.imagePath,
    this.radius = 60,
    this.isEditable = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final double size = radius * 2;

    Widget avatar;
    if (imagePath == null) {
      avatar = Icon(Icons.person_outline, color: Colors.white, size: radius.sp);
    } else if (imagePath!.startsWith('assets/')) {
      avatar = ClipOval(
        child: Image.asset(
          imagePath!,
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) =>
              Icon(Icons.person_outline, color: Colors.white, size: radius.sp),
        ),
      );
    } else {
      avatar = ClipOval(
        child: Image.network(
          imagePath!,
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) =>
              Icon(Icons.person_outline, color: Colors.white, size: radius.sp),
        ),
      );
    }

    return Stack(
      clipBehavior: Clip.none,
      children: [
        CircleAvatar(
          radius: radius.r,
          backgroundColor: const Color(0xFF1E1E1E),
          child: avatar,
        ),
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

  void _showAvatarSelection() {
    // implemented in parent
  }
}

class EditableProfileAvatarWidget extends StatefulWidget {
  final String? initialImagePath;
  final double radius;
  final Function(String)? onImageSelected;
  final bool useRemoteAvatars;

  const EditableProfileAvatarWidget({
    super.key,
    this.initialImagePath,
    this.radius = 60,
    this.onImageSelected,
    this.useRemoteAvatars = false,
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
  void didUpdateWidget(covariant EditableProfileAvatarWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // If parent updated the initial image path, reflect it locally so UI updates.
    if (widget.initialImagePath != oldWidget.initialImagePath) {
      setState(() {
        _selectedImagePath = widget.initialImagePath;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ProfileAvatarWidget(
      imagePath: _selectedImagePath,
      radius: widget.radius,
      isEditable: true,
      onTap: _showAvatarSelection,
    );
  }

  void _showAvatarSelection() {
    AvatarSelectionDialog.show(
      context: context,
      currentAvatar: _selectedImagePath,
      useRemote: widget.useRemoteAvatars,
      onAvatarSelected: (avatarPath) {
        setState(() {
          _selectedImagePath = avatarPath;
        });
        widget.onImageSelected?.call(avatarPath);
      },
    );
  }
}
