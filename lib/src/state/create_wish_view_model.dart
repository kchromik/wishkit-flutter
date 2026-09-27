import 'package:flutter/foundation.dart';

import '../config/configuration.dart';
import '../models/wish.dart';
import '../utilities/validation.dart';
import '../wishkit.dart' show WishKit;

/// Why a create-wish submit did not go through.
///
/// Carries the same three cases as iOS's `CreateWishSubmitOutcome`, so the view
/// can pick the right localized alert without inspecting a message string.
enum CreateWishSubmitOutcome {
  success,

  /// `emailField` is `.required` and the field is empty.
  emailRequired,

  /// A filled-in email that does not look like an address.
  emailFormatWrong,

  /// The backend rejected the request. [DetailCreateWishViewModel.error] carries
  /// the message.
  createReturnedError,
}

/// Form state for the create-wish screen.
///
/// Port of iOS's `CreateWishViewModel`. The submit action is injected so the
/// validation rules can be tested without a network.
class CreateWishViewModel extends ChangeNotifier {
  final Future<bool> Function(CreateWishRequest) _createWishAction;

  String _title = '';
  String _description = '';
  String _email = '';
  bool _isButtonLoading = false;
  bool _isSubmitting = false;
  String? _error;

  CreateWishViewModel({required Future<bool> Function(CreateWishRequest) onSubmit})
      : _createWishAction = onSubmit;

  String get title => _title;
  String get description => _description;
  String get email => _email;
  bool get isButtonLoading => _isButtonLoading;
  String? get error => _error;

  /// Whether the form differs from its initial state, which is what the
  /// "Discard changes?" guard keys off.
  bool get isDirty => _title.isNotEmpty || _description.isNotEmpty || _email.isNotEmpty;

  /// The submit button stays disabled until both required fields have content.
  ///
  /// Derived rather than stored, so it cannot drift from the text the user can
  /// actually see — the old implementation kept a separate flag that went stale
  /// whenever a field was cleared programmatically.
  bool get isButtonDisabled =>
      WishValidation.isCreateButtonDisabled(title: _title, description: _description);

  /// Whether the email field should be rendered, and how.
  ///
  /// Read live rather than captured, because a host is allowed to change
  /// `emailField` between two submits.
  EmailField get emailField => WishKit.config.emailField;

  // -----------------------------------------------------------------------
  // Field edits
  // -----------------------------------------------------------------------

  void setTitle(String value) {
    if (_title == value) return;
    _title = value;
    _truncateToLimits();
    notifyListeners();
  }

  void setDescription(String value) {
    if (_description == value) return;
    _description = value;
    _truncateToLimits();
    notifyListeners();
  }

  void setEmail(String value) {
    if (_email == value) return;
    _email = value;
    notifyListeners();
  }

  void _truncateToLimits() {
    final normalized = WishValidation.normalize(
      title: _title,
      description: _description,
      email: _email,
    );
    _title = normalized.title;
    _description = normalized.description;
  }

  // -----------------------------------------------------------------------
  // Submit
  // -----------------------------------------------------------------------

  /// Validates and submits.
  ///
  /// Validation runs *before* the button's disabled state is consulted, because
  /// a host can call this directly (an auto-submit, a keyboard action) and an
  /// invalid email must be caught either way.
  Future<CreateWishSubmitOutcome> submit() async {
    if (_isSubmitting) return CreateWishSubmitOutcome.createReturnedError;

    final emailResult = WishValidation.validateEmail(
      email: _email,
      fieldRequirement: emailField,
    );
    switch (emailResult) {
      case EmailValidationResult.requiredButMissing:
        return CreateWishSubmitOutcome.emailRequired;
      case EmailValidationResult.invalidFormat:
        return CreateWishSubmitOutcome.emailFormatWrong;
      case EmailValidationResult.valid:
        break;
    }

    _isButtonLoading = true;
    _error = null;
    notifyListeners();

    // A second tap while the first request is in flight would create the same
    // wish twice.
    _isSubmitting = true;
    bool ok;
    try {
      ok = await _createWishAction(CreateWishRequest(
        title: _title,
        description: _description,
        email: _email,
      ));
    } on Object catch (error) {
      _error = error.toString();
      ok = false;
    } finally {
      _isSubmitting = false;
      _isButtonLoading = false;
    }

    _error = ok ? null : (_error ?? 'createFailed');
    notifyListeners();
    return ok
        ? CreateWishSubmitOutcome.success
        : CreateWishSubmitOutcome.createReturnedError;
  }

  /// Clears the form, e.g. after a successful submit.
  void reset() {
    _title = '';
    _description = '';
    _email = '';
    _error = null;
    notifyListeners();
  }
}
