import 'package:flutter/material.dart';
import 'package:fahman_app/core/theming/colors_manager.dart';
import 'package:easy_localization/easy_localization.dart';

class CustomTextFormField extends StatefulWidget {
  final TextEditingController controller;
  final String labelText;
  final String? errorText;
  final bool obscureText;
  final ValueChanged<String> onChanged;
  final TextInputType? keyboardType;
  final Icon? prefixIcon;

  const CustomTextFormField({
    super.key,
    required this.controller,
    required this.labelText,
    this.errorText,
    this.obscureText = false,
    required this.onChanged,
    this.keyboardType,
    required this.prefixIcon,
  });

  @override
  State<CustomTextFormField> createState() => _CustomTextFormFieldState();
}

class _CustomTextFormFieldState extends State<CustomTextFormField> {
  late bool _obscured;

  @override
  void initState() {
    super.initState();
    _obscured = widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      decoration: InputDecoration(
        // translate the label text (accepts key or raw text)
        labelText: widget.labelText.tr(),
        errorText: widget.errorText != null ? widget.errorText!.tr() : null,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        filled: true,
        fillColor: AppColors.neutral900,
        prefixIcon: widget.prefixIcon,
        suffixIcon: widget.obscureText
            ? IconButton(
                icon: Icon(_obscured ? Icons.visibility : Icons.visibility_off),
                onPressed: () => setState(() => _obscured = !_obscured),
              )
            : null,
      ),
      obscureText: _obscured,
      onChanged: widget.onChanged,
      keyboardType: widget.keyboardType,
    );
  }
}
