import 'package:flutter/material.dart';

class GoogleSignInButton extends StatelessWidget {
  final VoidCallback onPressed;

  const GoogleSignInButton({
    super.key,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        /// خط فاصل مع كلمة "أو"
        Row(
          children: const [
            Expanded(
              child: Divider(
                thickness: 1,
                color: Color(0xFFBDBDBD),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                "أو",
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFFBDBDBD),
                ),
              ),
            ),
            Expanded(
              child: Divider(
                thickness: 1,
                color: Color(0xFFBDBDBD),
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        /// زر Google
        SizedBox(
          width: double.infinity,
          height: 52,
          child: OutlinedButton(
            onPressed: onPressed,
            style: OutlinedButton.styleFrom(
              backgroundColor: Colors.transparent,
              side: const BorderSide(
                color: Color(0xFFBDBDBD),
                width: 1.2,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/Icons/Google.png',
                  height: 20,
                ),
                const SizedBox(width: 10),
                const Text(
                  "Google تسجيل الدخول باستخدام",
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Color.fromARGB(255, 83, 85, 97),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
