import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'legal_document_screen.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return LegalDocumentScreen(
      title: 'privacy_policy'.tr(),
      apiEndpoint: '/api/Profile/privacy-policy',
    );
  }
}
