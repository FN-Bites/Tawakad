import 'package:flutter/material.dart';

class GoogleSignInButton extends StatelessWidget {
  final VoidCallback? onPressed;

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

        const SizedBox(height: 20),

        /// زر Google
        SizedBox(
          width: double.infinity,
          height: 45,
          child: Material(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
            elevation: 2, 
            shadowColor: Colors.black.withOpacity(0.08),
            child: InkWell(
              borderRadius: BorderRadius.circular(30),
              onTap: onPressed,
              splashColor: Colors.black.withOpacity(0.04),
              highlightColor: Colors.transparent,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: const Color(0xFFD1D5DB), 
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "تسجيل الدخول بإستخدام Google",
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF374151),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Image.asset(
                      'assets/Icons/Google.png',
                      height: 20,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
