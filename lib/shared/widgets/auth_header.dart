import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:easy_localization/easy_localization.dart';
import 'dart:ui' as ui;
import 'package:fahman_app/core/theming/colors_manager.dart';

class AuthHeader extends StatelessWidget {
  final String? subtitle;

  const AuthHeader({super.key, this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'auth_fahman_title'.tr(),
              textDirection: ui.TextDirection.rtl,
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                '|',
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
            ),
            Directionality(
              textDirection: ui.TextDirection.ltr,
              child: Text.rich(
                TextSpan(
                  children: [
                    const TextSpan(
                      text: 'FAH',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    TextSpan(
                      text: 'MAN',
                      style: TextStyle(
                        color: AppColors.brand800,
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 8),
          Text(
            subtitle!,
            style: GoogleFonts.inter(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w600,
              height: 22 / 13,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ],
    );
  }
}
