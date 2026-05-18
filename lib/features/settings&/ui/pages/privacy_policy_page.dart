// 📄 privacy_policy_page.dart — سياسة الخصوصية

import 'package:flutter/material.dart';
import 'package:tawakad_app/core/theme/app_colors.dart';
import 'package:tawakad_app/features/settings&/ui/widgets/settings_ui.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: settingsPageBackground(context),
        body: SafeArea(
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: SettingsPageHeader(title: 'سياسة الخصوصية'),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'آخر تحديث: مايو 2026',
                        style: SettingsTextStyles.tileSubtitleEmphasisStyle(
                          context,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const _PolicyParagraph(
                        'تم تصميم هذه السياسة استنادًا إلى مبادئ حماية البيانات '
                        'الشخصية وأفضل ممارسات أمن تطبيقات الأجهزة الذكية.',
                      ),
                      const _PolicyParagraph(
                        'يحترم تطبيق توكد (Tawakad) خصوصية المستخدمين ويلتزم بحماية '
                        'البيانات والمعلومات الشخصية التي يتم جمعها أثناء استخدام '
                        'التطبيق. توضح هذه السياسة كيفية جمع البيانات واستخدامها '
                        'وتخزينها وحمايتها.',
                      ),
                      const _PolicySection(
                        title: 'جمع المعلومات',
                        intro:
                            'قد يقوم التطبيق بجمع الأنواع التالية من المعلومات:',
                        bullets: [
                          'معلومات الحساب مثل البريد الإلكتروني وبيانات تسجيل الدخول.',
                          'معلومات أساسية من حساب Google عند استخدام تسجيل الدخول بواسطة Google، مثل الاسم والبريد الإلكتروني وصورة الملف الشخصي.',
                          'إجابات أسئلة الحالة الصحية والعادات اليومية المستخدمة لتحسين التخصيص والاقتراحات الذكية.',
                          'بيانات القوائم والتذكيرات والمواعيد التي ينشئها المستخدم.',
                          'بيانات إشارات البلوتوث منخفض الطاقة (BLE) لدعم خاصية التحقق التلقائي من الأغراض.',
                          'بيانات التقويم والمواعيد عند تفعيل مزامنة التقويم.',
                          'بيانات تقنية محدودة مثل نوع الجهاز وإصدار نظام التشغيل لتحسين استقرار التطبيق والأداء.',
                        ],
                      ),
                      const _PolicySection(
                        title: 'استخدام المعلومات',
                        intro:
                            'يتم استخدام البيانات التي يتم جمعها للأغراض التالية:',
                        bullets: [
                          'تقديم اقتراحات ذكية مخصصة للمستخدم.',
                          'تحسين تجربة الاستخدام ورفع دقة التوصيات.',
                          'إرسال التذكيرات والتنبيهات الذكية.',
                          'مزامنة البيانات بين الأجهزة المختلفة.',
                          'دعم خاصية الفحص التلقائي للأغراض باستخدام تقنية BLE.',
                          'تحسين أداء التطبيق واستقراره واكتشاف المشكلات التقنية.',
                        ],
                      ),
                      const _PolicySection(
                        title: 'تسجيل الدخول باستخدام Google',
                        paragraphs: [
                          'قد يتيح التطبيق للمستخدم خيار تسجيل الدخول باستخدام حساب Google.',
                          'عند استخدام هذه الخاصية، قد يتم الوصول إلى بعض المعلومات الأساسية المرتبطة بحساب Google مثل:',
                        ],
                        bullets: [
                          'الاسم',
                          'البريد الإلكتروني',
                          'صورة الملف الشخصي',
                        ],
                        outro: [
                          'تُستخدم هذه المعلومات فقط لأغراض المصادقة وتخصيص تجربة المستخدم داخل التطبيق، ولا يتم بيعها أو مشاركتها مع أطراف خارجية.',
                          'تخضع عملية تسجيل الدخول أيضًا لسياسات الخصوصية الخاصة بشركة Google.',
                        ],
                      ),
                      const _PolicySection(
                        title: 'مشاركة بيانات القوائم',
                        paragraphs: [
                          'يمكن للمستخدم التحكم في مشاركة بيانات القوائم المستخدمة لتحسين الاقتراحات الذكية داخل التطبيق.',
                          'في حال اختيار المستخدم تفعيل خيار «عدم مشاركة البيانات»، فلن يتم استخدام بيانات القوائم الخاصة به في تدريب أو تحسين نظام الاقتراحات الذكية.',
                        ],
                      ),
                      const _PolicySection(
                        title: 'عدم مشاركة البيانات مع أطراف خارجية',
                        paragraphs: [
                          'لا يقوم تطبيق توكد ببيع بيانات المستخدمين أو مشاركتها مع أي جهات خارجية لأغراض تسويقية أو تجارية.',
                          'قد تُستخدم بعض خدمات الطرف الثالث التقنية فقط لتشغيل وظائف التطبيق الأساسية مثل التخزين السحابي والإشعارات والمصادقة.',
                        ],
                      ),
                      const _PolicySection(
                        title: 'حماية البيانات',
                        paragraphs: [
                          'يتم تخزين البيانات باستخدام خدمات Firebase السحابية مع تطبيق وسائل حماية مناسبة لمنع الوصول غير المصرح به أو التعديل أو الكشف عن البيانات.',
                          'كما يتم تأمين الاتصال بين التطبيق والخدمات السحابية باستخدام بروتوكولات اتصال مشفرة (HTTPS/TLS).',
                          'ويتم تقييد الوصول إلى البيانات الحساسة للمستخدمين المصرح لهم فقط.',
                        ],
                      ),
                      const _PolicySection(
                        title: 'صلاحيات البلوتوث',
                        paragraphs: [
                          'يتطلب التطبيق استخدام تقنية البلوتوث منخفض الطاقة (BLE) لدعم خصائص التحقق التلقائي من الأغراض والتنبيهات الذكية المرتبطة بالأجهزة القريبة.',
                          'تُستخدم هذه الصلاحيات فقط أثناء تشغيل الخصائص المرتبطة بها، ولا يتم استخدام بيانات البلوتوث لأي أغراض خارجية.',
                        ],
                      ),
                      const _PolicySection(
                        title: 'صلاحيات التقويم',
                        paragraphs: [
                          'عند تفعيل مزامنة التقويم، يمكن للتطبيق الوصول إلى بيانات الأحداث والمواعيد المرتبطة بالتذكيرات فقط بهدف تنظيم الجداول والتنبيهات الذكية.',
                          'يمكن للمستخدم تعطيل هذه الصلاحية في أي وقت من إعدادات الجهاز أو التطبيق.',
                        ],
                      ),
                      const _PolicySection(
                        title: 'خدمات الطرف الثالث',
                        intro:
                            'قد يستخدم التطبيق بعض خدمات الطرف الثالث مثل:',
                        bullets: [
                          'Firebase Authentication',
                          'Cloud Firestore',
                          'Firebase Cloud Messaging (FCM)',
                          'Google Sign-In Services',
                        ],
                        outro: [
                          'وذلك لدعم تسجيل الدخول والتخزين السحابي والإشعارات الفورية.',
                          'تخضع هذه الخدمات لسياسات الخصوصية الخاصة بها.',
                        ],
                      ),
                      const _PolicySection(
                        title: 'الاحتفاظ بالبيانات',
                        paragraphs: [
                          'يتم الاحتفاظ ببيانات المستخدم طالما أن الحساب نشط داخل التطبيق.',
                          'يمكن للمستخدم طلب حذف الحساب والبيانات المرتبطة به في أي وقت، وسيتم حذف البيانات المرتبطة بالحساب خلال فترة زمنية مناسبة وفقًا لإجراءات النظام.',
                        ],
                      ),
                      const _PolicySection(
                        title: 'حقوق المستخدم',
                        intro: 'يحق للمستخدم:',
                        bullets: [
                          'تعديل أو حذف بياناته وقوائمه.',
                          'تعطيل صلاحيات البلوتوث أو التقويم.',
                          'إيقاف مشاركة بيانات القوائم المستخدمة لتحسين الاقتراحات الذكية.',
                          'طلب حذف الحساب والبيانات المرتبطة به.',
                          'معرفة البيانات التي يتم جمعها واستخدامها داخل التطبيق.',
                        ],
                      ),
                      const _PolicySection(
                        title: 'خصوصية الأطفال',
                        paragraphs: [
                          'لا يستهدف تطبيق توكد الأطفال دون سن 13 عامًا، ولا يتم جمع بيانات شخصية منهم عن قصد.',
                        ],
                      ),
                      const _PolicySection(
                        title: 'التوافق مع الأنظمة',
                        paragraphs: [
                          'تم تصميم سياسة الخصوصية وممارسات حماية البيانات وفقًا للمبادئ العامة لحماية البيانات الشخصية وأفضل ممارسات أمن تطبيقات الأجهزة الذكية.',
                        ],
                      ),
                      const _PolicySection(
                        title: 'التواصل',
                        paragraphs: [
                          'في حال وجود أي استفسارات متعلقة بالخصوصية أو حماية البيانات، يمكن التواصل عبر البريد الإلكتروني الخاص بالتطبيق:',
                        ],
                      ),
                      Center(
                        child: SelectableText(
                          'tawakad.support@gmail.com',
                          style: SettingsTextStyles.tileSubtitleEmphasisStyle(
                            context,
                          ).copyWith(color: AppColors.primary),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const _PolicySection(
                        title: 'تحديثات السياسة',
                        paragraphs: [
                          'قد يتم تحديث سياسة الخصوصية مستقبلًا بما يتوافق مع تطوير التطبيق أو المتطلبات التنظيمية، وسيتم إشعار المستخدمين عند وجود تغييرات جوهرية.',
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PolicyParagraph extends StatelessWidget {
  const _PolicyParagraph(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Text(
        text,
        style: SettingsTextStyles.tileSubtitleStyle(context).copyWith(
          height: 1.55,
        ),
      ),
    );
  }
}

class _PolicySection extends StatelessWidget {
  const _PolicySection({
    required this.title,
    this.intro,
    this.bullets = const [],
    this.paragraphs = const [],
    this.outro = const [],
  });

  final String title;
  final String? intro;
  final List<String> bullets;
  final List<String> paragraphs;
  final List<String> outro;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: SettingsTextStyles.tileTitleStyle(context).copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          if (intro != null) ...[
            _PolicyParagraph(intro!),
          ],
          ...paragraphs.map(_PolicyParagraph.new),
          ...bullets.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 8, right: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '• ',
                    style: SettingsTextStyles.tileSubtitleStyle(context),
                  ),
                  Expanded(
                    child: Text(
                      item,
                      style: SettingsTextStyles.tileSubtitleStyle(context)
                          .copyWith(height: 1.5),
                    ),
                  ),
                ],
              ),
            ),
          ),
          ...outro.map(_PolicyParagraph.new),
        ],
      ),
    );
  }
}
