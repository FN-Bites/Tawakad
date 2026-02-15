import 'package:flutter/material.dart';

class OnboardingFlowProvider extends ChangeNotifier {
  OnboardingFlowProvider({required int totalSteps}) : _totalSteps = totalSteps;

  final int _totalSteps;
  int _currentStep = 1;

  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();

  String _firstName = '';
  String _lastName = '';
  String? _gender;
  String? _status;

  bool _nameSubmitAttempted = false;
  bool _genderSubmitAttempted = false;
  bool _statusSubmitAttempted = false;

  int get totalSteps => _totalSteps;
  int get currentStep => _currentStep;

  String get firstName => _firstName;
  String get lastName => _lastName;
  String? get gender => _gender;
  String? get status => _status;

  bool get firstNameInvalid =>
      _nameSubmitAttempted && _firstName.trim().isEmpty;
  bool get lastNameInvalid => _nameSubmitAttempted && _lastName.trim().isEmpty;
  bool get genderInvalid => _genderSubmitAttempted && (_gender == null);
  bool get statusInvalid => _statusSubmitAttempted && (_status == null);

  void setFirstName(String value) {
    _firstName = value;
    notifyListeners();
  }

  void setLastName(String value) {
    _lastName = value;
    notifyListeners();
  }

  void setGender(String? value) {
    _gender = value;
    notifyListeners();
  }

  void setStatus(String? value) {
    _status = value;
    notifyListeners();
  }

  void nextFromNameStep() {
    _nameSubmitAttempted = true;

    _firstName = firstNameController.text;
    _lastName = lastNameController.text;

    notifyListeners();

    if (firstNameInvalid || lastNameInvalid) return;

    _goToStep(_currentStep + 1);
  }

  void nextFromGenderStep() {
    _genderSubmitAttempted = true;
    notifyListeners();

    if (genderInvalid) return;

    _goToStep(_currentStep + 1);
  }

  void nextFromStatusStep() {
    _statusSubmitAttempted = true;
    notifyListeners();

    if (statusInvalid) return;

    _goToStep(_currentStep + 1);
  }

  void back() {
    if (_currentStep <= 1) return;
    _goToStep(_currentStep - 1);
  }

  void _goToStep(int step) {
    final clamped = step.clamp(1, _totalSteps);
    if (clamped == _currentStep) return;

    _currentStep = clamped;
    notifyListeners();
  }

  void reset() {
    _currentStep = 1;
    _firstName = '';
    _lastName = '';
    _gender = null;
    _status = null;

    firstNameController.text = '';
    lastNameController.text = '';

    _nameSubmitAttempted = false;
    _genderSubmitAttempted = false;
    _statusSubmitAttempted = false;

    notifyListeners();
  }

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    super.dispose();
  }
}
