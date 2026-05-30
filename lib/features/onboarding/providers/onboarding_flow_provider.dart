import 'package:flutter/material.dart';

/// This provider is responsible for:
/// - tracking the current onboarding step
/// - storing the user's answers
/// - validating required fields
/// - showing or hiding validation errors
///  - moving forward and backward between steps

class OnboardingFlowProvider extends ChangeNotifier {
  OnboardingFlowProvider({required int totalSteps}) : _totalSteps = totalSteps;

  final int _totalSteps;

  /// The 1-based index of the currently active step.
  int _currentStep = 1;

  /// Controllers used to read and control the text entered in the name fields.
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();

  /// Stores the user's answers during the onboarding process.
  String _firstName = '';
  String _lastName = '';
  String? _gender;
  String? _status;
  String? _takesMedication;

  /// Tracks whether the user tried to submit each step.
  bool _nameSubmitAttempted = false;
  bool _genderSubmitAttempted = false;
  bool _statusSubmitAttempted = false;
  bool _medicationSubmitAttempted = false;

  /// Controls whether the mascot error message should be shown.
  bool _showMascotError = false;

  /// Public getters used by the UI to safely read provider values.
  int get totalSteps => _totalSteps;
  int get currentStep => _currentStep;
  bool get showMascotError => _showMascotError;
  String get firstName => _firstName;
  String get lastName => _lastName;
  String? get gender => _gender;
  String? get status => _status;
  String? get takesMedication => _takesMedication;

  /// Validation getters.
  bool get firstNameInvalid =>
      _nameSubmitAttempted && _firstName.trim().isEmpty;
  bool get lastNameInvalid => _nameSubmitAttempted && _lastName.trim().isEmpty;
  bool get genderInvalid => _genderSubmitAttempted && (_gender == null);
  bool get statusInvalid => _statusSubmitAttempted && (_status == null);
  bool get medicationInvalid =>
      _medicationSubmitAttempted && (_takesMedication == null);

  /// Returns all onboarding answers in one list.
  List<String> get answers => [
        _firstName,
        _lastName,
        _gender ?? '',
        _status ?? '',
        _takesMedication ?? '',
      ];

  /// Hides the mascot error message once the user starts fixing the mistake
  void clearMascotError() {
    if (!_showMascotError) return;
    _showMascotError = false;
    notifyListeners();
  }

  /// Updates the stored first name value.
  void setFirstName(String value) {
    _firstName = value;
    notifyListeners();
  }

  /// Updates the stored last name value.
  void setLastName(String value) {
    _lastName = value;
    notifyListeners();
  }

  /// Updates the selected gender answer.
  void setGender(String? value) {
    _gender = value;
    notifyListeners();
  }

  /// Updates the selected status answer.
  void setStatus(String? value) {
    _status = value;
    notifyListeners();
  }

  /// Updates the selected medication answer.
  void setTakesMedication(String? value) {
    _takesMedication = value;
    notifyListeners();
  }

  /// Validates the name step before moving to the next step.
  void nextFromNameStep() {
    _nameSubmitAttempted = true;

    _firstName = firstNameController.text;
    _lastName = lastNameController.text;

    final invalid = firstNameInvalid || lastNameInvalid;
    _showMascotError = invalid;

    notifyListeners();

    if (invalid) return;

    _goToStep(_currentStep + 1);
  }

  /// Validates the gender step before moving to the next step.
  void nextFromGenderStep() {
    _genderSubmitAttempted = true;

    final invalid = genderInvalid;
    _showMascotError = invalid;

    notifyListeners();

    if (invalid) return;

    _goToStep(_currentStep + 1);
  }

  /// Validates the status step before moving to the next step.
  void nextFromStatusStep() {
    _statusSubmitAttempted = true;

    final invalid = statusInvalid;
    _showMascotError = invalid;

    notifyListeners();

    if (invalid) return;

    _goToStep(_currentStep + 1);
  }

  /// Validates the medication step before moving to the next step.
  void nextFromMedicationStep() {
    _medicationSubmitAttempted = true;

    final invalid = medicationInvalid;
    _showMascotError = invalid;

    notifyListeners();

    if (invalid) return;

    _goToStep(currentStep + 1);
  }

  /// Moves the user back one step
  void back() {
    if (_currentStep <= 1) return;
    _goToStep(_currentStep - 1);
  }

  /// Moves to a specific step while keeping the step number within the valid range.
  void _goToStep(int step) {
    final clamped = step.clamp(1, _totalSteps);
    if (clamped == _currentStep) return;

    _currentStep = clamped;
    _showMascotError = false;
    notifyListeners();
  }

  /// Clears all onboarding answers and returns the flow to the first step.
  void reset() {
    _currentStep = 1;
    _firstName = '';
    _lastName = '';
    _gender = null;
    _status = null;
    _takesMedication = null;

    firstNameController.text = '';
    lastNameController.text = '';

    _nameSubmitAttempted = false;
    _genderSubmitAttempted = false;
    _statusSubmitAttempted = false;
    _medicationSubmitAttempted = false;

    _showMascotError = false;

    notifyListeners();
  }

  /// Disposes text controllers to prevent memory leaks.
  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    super.dispose();
  }
}
