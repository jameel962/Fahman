import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'legal_document_screen.dart';

class TermsConditionsScreen extends StatelessWidget {
  const TermsConditionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return LegalDocumentScreen(
      title: 'terms_conditions'.tr(),
      apiEndpoint: '/api/Profile/terms-conditions',
    );
  }
}
