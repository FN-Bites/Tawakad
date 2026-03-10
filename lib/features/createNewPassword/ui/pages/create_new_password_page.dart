import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tawakad_app/core/widgets/singin_singup/sign_auth_text_field.dart';
import 'package:tawakad_app/features/createNewPassword/ui/widgets/create_new_password_args.dart';
import '../../../../../../core/widgets/entry_header.dart';
import '../../../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/singin_singup/password_strength_hints.dart';
import '../../state/createNewPassword_flow_provider.dart';

class CreateNewPasswordPage extends StatelessWidget {
  const CreateNewPasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    
    final args = ModalRoute.of(context)!.settings.arguments as CreateNewPasswordArgs;
    final flow = context.watch<CreateNewPasswordFlowProvider>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!flow.codeValid && flow.codeError == null) {
        flow.verifyResetCode(args.oobCode);
      }
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [

              const EntryHeader(),

              const SizedBox(height: 16),

              Text(
                'إنشاء كلمة مرور جديدة',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineLarge,
              ),

              const SizedBox(height: 8),

              Text(
                'يرجى إدخال كلمة مرور جديدة لحسابك',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.labelMedium,
              ),

              const SizedBox(height: 16),

              if (flow.codeError != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text(
                    flow.codeError!,
                    style: const TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    children: [
                      /// Password field
                      SignAuthTextField(
                        hint: 'كلمة المرور الجديدة',
                        controller: flow.passwordController,
                        isPassword: true,
                        enableToggle: true,
                        errorText: flow.passwordError,
                        externalError: flow.serverError,
                        onChanged: (value) {
                          if (flow.codeValid) {
                            flow.setPassword(value);
                          }
                        },
                      ),

                      const SizedBox(height: 16),

                      /// Confirm password
                      SignAuthTextField(
                        hint: 'تأكيد كلمة المرور الجديدة',
                        controller: flow.confirmPasswordController,
                        isPassword: true,
                        enableToggle: true,
                        errorText: flow.confirmPasswordError,
                        onChanged: (value) {
                          if (flow.codeValid) {
                            flow.setConfirmPassword(value);
                          }
                        }, 
                      ),

                      const SizedBox(height: 16),

                      PasswordStrengthHints(
                        hasMinLength: flow.hasMinLength,
                        hasNumber: flow.hasNumber,
                        hasUppercase: flow.hasUppercase,
                        hasLowercase: flow.hasLowercase,
                        hasSpecialChar: flow.hasSpecialChar,
                        isPasswordEmpty: flow.password.isEmpty,
                      ),

                      const SizedBox(height: 24),

                      /// Submit button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(

                          onPressed: flow.isButtonEnabled 
                              ? () async {
                                  final success = await flow.submit(
                                    oobCode: args.oobCode,
                                  );
                                  if (success && context.mounted) {
                                    Navigator.pushReplacementNamed(context, '/signin',);
                                  }
                                }
                              : null,

                          style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.resolveWith<Color>((states) {
                              if (states.contains(MaterialState.disabled)) {
                                return AppColors.linkSoft;
                              }
                              return AppColors.primary;
                            }),
                            foregroundColor:
                                MaterialStateProperty.all(Colors.white),
                          ),

                          child: flow.isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : Text(
                                  'تعيين كلمة المرور',
                                  style: Theme.of(context).textTheme.labelLarge,
                                ),
                        ),
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