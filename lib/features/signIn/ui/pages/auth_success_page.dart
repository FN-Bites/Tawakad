import 'package:flutter/material.dart';

class AuthSuccessPage extends StatelessWidget {
  const AuthSuccessPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login Success'),
      ),
      body: const Center(
        child: Text(
          'تم تسجيل الدخول بنجاح',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}