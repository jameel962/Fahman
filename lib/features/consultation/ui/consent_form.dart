import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/shared/widgets/settings_app_bar.dart';
import '../../../core/theming/colors_manager.dart';

class ConsentFormScreen extends StatelessWidget {
  const ConsentFormScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isArabic = context.locale.languageCode == 'ar';
    final sections = isArabic ? _getArabicSections() : _getEnglishSections();

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: SettingsAppBar(
        title: 'consent_form_title'.tr(),
        onBackPressed: () => Navigator.of(context).pop(),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          // No API call needed for static data
          await Future.delayed(const Duration(milliseconds: 300));
        },
        color: AppColors.brand800,
        backgroundColor: const Color(0xFF1E1E1E),
        child: ListView.builder(
          padding: EdgeInsets.all(16.w),
          itemCount: sections.length + 1, // +1 for intro text
          itemBuilder: (context, index) {
            if (index == 0) {
              return _buildIntroCard(context, isArabic);
            }
            return _buildSectionCard(sections[index - 1]);
          },
        ),
      ),
    );
  }

  Widget _buildIntroCard(BuildContext context, bool isArabic) {
    return Card(
      margin: EdgeInsets.only(bottom: 16.h),
      color: const Color(0xFF1E1E1E),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.description_outlined,
                  color: AppColors.brand800,
                  size: 24.sp,
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Text(
                    'consent_form_subtitle'.tr(),
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
            Text(
              'consent_form_intro'.tr(),
              style: GoogleFonts.inter(
                color: Colors.grey[400],
                fontSize: 14.sp,
                fontWeight: FontWeight.w400,
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard(ConsentSection section) {
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
                    section.sectionNumber,
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
            SizedBox(height: 16.h),

            // Section items
            ...section.items.map(
              (item) => Padding(
                padding: EdgeInsets.only(bottom: 12.h),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${item.number}. ',
                      style: GoogleFonts.inter(
                        color: AppColors.brand800,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        item.content,
                        style: GoogleFonts.inter(
                          color: Colors.grey[400],
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w400,
                          height: 1.6,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Bullet points if any
            if (section.bulletPoints.isNotEmpty) ...[
              SizedBox(height: 8.h),
              ...section.bulletPoints.map(
                (bullet) => Padding(
                  padding: EdgeInsets.only(
                    left: 24.w,
                    right: 24.w,
                    bottom: 8.h,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '• ',
                        style: GoogleFonts.inter(
                          color: AppColors.brand800,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          bullet,
                          style: GoogleFonts.inter(
                            color: Colors.grey[400],
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w400,
                            height: 1.5,
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
    );
  }

  List<ConsentSection> _getArabicSections() {
    return [
      ConsentSection(
        sectionNumber: 'أولاً',
        sectionTitle: 'الإقرار بالإطلاع على الشروط والأحكام',
        items: [
          ConsentItem(
            number: '١',
            content:
                'أقرّ بأنني قرأت الشروط والأحكام الخاصة باستخدام تطبيق فهمان قراءة كاملة ودقيقة، وأنني فهمت مضمونها ومعانيها القانونية دون أي لبس أو غموض.',
          ),
          ConsentItem(
            number: '٢',
            content:
                'أقرّ بأن الشروط والأحكام المنشورة داخل التطبيق تشكل اتفاقًا ملزمًا من الناحية القانونية بيني وبين تطبيق فهمان.',
          ),
          ConsentItem(
            number: '٣',
            content:
                'أوافق بموجب هذا المستند موافقة صريحة وقطعية على الالتزام بجميع البنود والواجبات المنصوص عليها في الشروط والأحكام، بما في ذلك:',
          ),
        ],
        bulletPoints: [
          'طبيعة الخدمات المقدمة',
          'حدود مسؤولية التطبيق',
          'التزامات المستخدم',
          'سياسة الدفع',
          'حقوق الملكية الفكرية',
          'أي تعديلات مستقبلية تصدر عنها',
        ],
      ),
      ConsentSection(
        sectionNumber: 'ثانياً',
        sectionTitle: 'الاعتراف بالقوة القانونية لهذا النموذج',
        items: [
          ConsentItem(
            number: '٤',
            content:
                'أقرّ بأن تفعيل حسابي أو استمراري في استخدام خدمات التطبيق يُعد قبولًا نهائيًا لتلك الشروط وفق أحكام القانون.',
          ),
          ConsentItem(
            number: '٥',
            content:
                'أوافق على أن الضغط على زر "أوافق" داخل التطبيق يعادل توقيعًا خطيًا كامل الأثر القانوني وفقًا للمعايير المتعارف عليها في التشريعات الأردنية والتجارة الإلكترونية.',
          ),
        ],
        bulletPoints: [],
      ),
      ConsentSection(
        sectionNumber: 'ثالثاً',
        sectionTitle: 'الالتزام باستخدام التطبيق وفق القوانين',
        items: [
          ConsentItem(
            number: '٦',
            content:
                'أتعهد باستخدام تطبيق فهمان وخدماته كافة بما يتوافق مع القوانين الأردنية، وأتحمل كامل المسؤولية عن أي استخدام مخالف.',
          ),
          ConsentItem(
            number: '٧',
            content:
                'أقرّ بأن أي محاولة لخرق الشروط أو إساءة استخدام التطبيق تمنح فهمان الحق في:',
          ),
        ],
        bulletPoints: [
          'تعليق الحساب',
          'إغلاق الحساب',
          'اتخاذ الإجراءات القانونية اللازمة',
        ],
      ),
      ConsentSection(
        sectionNumber: 'رابعاً',
        sectionTitle: 'الإقرار بالتعديلات المستقبلية',
        items: [
          ConsentItem(
            number: '٨',
            content:
                'أوافق على أن تطبيق فهمان قد يقوم بتعديل أو تحديث الشروط والأحكام من وقت لآخر، وأنني أتحمل مسؤولية الاطلاع على النسخ المحدثة، ويُعد استمرار استخدامي للتطبيق قبولًا بالتعديلات.',
          ),
        ],
        bulletPoints: [],
      ),
      ConsentSection(
        sectionNumber: 'خامساً',
        sectionTitle: 'توقيع وإقرار',
        items: [
          ConsentItem(
            number: '٩',
            content:
                'أصرّح طوعًا وبشكل نهائي أن ضغطي على زر الموافقة يمثل موافقة كاملة وملزمة قانونيًا على جميع ما ورد أعلاه.',
          ),
        ],
        bulletPoints: [],
      ),
    ];
  }

  List<ConsentSection> _getEnglishSections() {
    return [
      ConsentSection(
        sectionNumber: 'First',
        sectionTitle: 'Acknowledgment of Reviewing the Terms & Conditions',
        items: [
          ConsentItem(
            number: '1',
            content:
                'I acknowledge that I have read the Terms and Conditions of the Fahman Application thoroughly and carefully, and that I fully understand their legal meaning and implications without ambiguity.',
          ),
          ConsentItem(
            number: '2',
            content:
                'I acknowledge that the Terms and Conditions displayed within the App constitute a legally binding agreement between me and the Fahman Application.',
          ),
          ConsentItem(
            number: '3',
            content:
                'I hereby give my explicit and unconditional consent to fully comply with all obligations and provisions listed in the Terms and Conditions, including but not limited to:',
          ),
        ],
        bulletPoints: [
          'Nature of the services provided',
          'Limitations of liability',
          'User responsibilities',
          'Payment policies',
          'Intellectual property rights',
          'Any future modifications or updates',
        ],
      ),
      ConsentSection(
        sectionNumber: 'Second',
        sectionTitle: 'Recognition of the Legal Force of This Form',
        items: [
          ConsentItem(
            number: '4',
            content:
                'I acknowledge that activating my account or continuing to use the App\'s services constitutes full acceptance of the Terms according to applicable laws.',
          ),
          ConsentItem(
            number: '5',
            content:
                'I agree that clicking the "I Agree" button within the App is equivalent to a handwritten signature and carries full legal effect under Jordanian law and electronic commerce standards.',
          ),
        ],
        bulletPoints: [],
      ),
      ConsentSection(
        sectionNumber: 'Third',
        sectionTitle: 'Commitment to Lawful Use of the Application',
        items: [
          ConsentItem(
            number: '6',
            content:
                'I undertake to use the Fahman Application and all its services in compliance with Jordanian laws, and I bear full responsibility for any unlawful use.',
          ),
          ConsentItem(
            number: '7',
            content:
                'I acknowledge that any attempt to violate the Terms or misuse the App grants Fahman the right to:',
          ),
        ],
        bulletPoints: [
          'Suspend my account',
          'Terminate my account',
          'Take any necessary legal action',
        ],
      ),
      ConsentSection(
        sectionNumber: 'Fourth',
        sectionTitle: 'Acknowledgment of Future Amendments',
        items: [
          ConsentItem(
            number: '8',
            content:
                'I agree that Fahman may update or modify the Terms and Conditions at any time, and that I am responsible for reviewing updated versions. Continued use of the App constitutes acceptance of such modifications.',
          ),
        ],
        bulletPoints: [],
      ),
      ConsentSection(
        sectionNumber: 'Fifth',
        sectionTitle: 'Signature and Confirmation',
        items: [
          ConsentItem(
            number: '9',
            content:
                'I hereby declare voluntarily and conclusively that clicking the digital consent button constitutes full and legally binding acceptance of all the above provisions.',
          ),
        ],
        bulletPoints: [],
      ),
    ];
  }
}

// Models for static consent data
class ConsentSection {
  final String sectionNumber;
  final String sectionTitle;
  final List<ConsentItem> items;
  final List<String> bulletPoints;

  ConsentSection({
    required this.sectionNumber,
    required this.sectionTitle,
    required this.items,
    required this.bulletPoints,
  });
}

class ConsentItem {
  final String number;
  final String content;

  ConsentItem({required this.number, required this.content});
}
