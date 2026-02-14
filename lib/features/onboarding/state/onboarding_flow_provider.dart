import 'package:flutter/material.dart';

class OnboardingFlowProvider extends ChangeNotifier {
  final int totalSteps;

  OnboardingFlowProvider({this.totalSteps = 4});

  int currentStep = 1;

  String firstName = '';
  String lastName = '';

  // Validation flags
  bool submitted = false;

  bool get firstNameInvalid => submitted && firstName.trim().isEmpty;
  bool get lastNameInvalid => submitted && lastName.trim().isEmpty;

  void setFirstName(String v) {
    firstName = v;
    notifyListeners();
  }

  void setLastName(String v) {
    lastName = v;
    notifyListeners();
  }

  bool validateNameStep() {
    submitted = true;
    notifyListeners();
    return firstName.trim().isNotEmpty && lastName.trim().isNotEmpty;
  }

  void nextFromNameStep() {
    if (!validateNameStep()) return;

    // move to next step
    if (currentStep < totalSteps) {
      currentStep++;
    }

    // reset validation for next page
    submitted = false;
    notifyListeners();
  }

  void back() {
    if (currentStep > 1) {
      currentStep--;
      submitted = false;
      notifyListeners();
    }
  }
}
