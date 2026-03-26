import 'package:flutter/material.dart';
import 'package:tawakad_app/core/widgets/entry_header.dart';

class SuccessSheet extends StatelessWidget {
  const SuccessSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 41),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [

          EntryHeader(
            onBack: () => Navigator.pop(
              context,
              '/forgot-password',
            ),
          ),
          const SizedBox(height: 10),

          // أيقونة النجاح
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.mark_email_read_outlined,
              color: Colors.lightBlue,
              size: 60,
            ),
          ),
          const SizedBox(height: 10),

          Text(
            'تحقق من بريدك الإلكتروني',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 5),

          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[600], height: 1.5,),
              children: [
                TextSpan(
                  text: 'إذا كان البريد الإلكتروني مسجلًا لدينا\n',
                  style: TextStyle(
                    color: Colors.blue, 
                    fontSize: 15,
                  ),
                ),
                const TextSpan(text: ' فقد أرسلنا لك رابط إعادة التعيين، اضغط عليه لتعيين كلمة المرور الجديدة '),
              ],
            ),
          ),
          const SizedBox(height: 10),
          
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.amber.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: Colors.amber, size: 20),
                const SizedBox(width: 8),
              Expanded(
                child: Text(
                'ملاحظة: يرجى التحقق من الرسائل غير المرغوب فيها (Spam) في حال لم تجد الرسالة في الوارد',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Colors.amber[700]),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 15),

        // زر العودة لصفحة تسجيل الدخول
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/signin',
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 9),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              ),
              child: const Text('العودة لتسجيل الدخول'),
            ),
          ),
        ],
      ),
    );
  }
}