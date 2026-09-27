import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../config/configuration.dart';
import '../config/localization.dart';
import '../state/create_wish_view_model.dart';
import '../state/wish_model.dart';
import '../utilities/validation.dart';

/// View for creating a new wish.
///
/// Port of `CreateWishView`. The form state lives in a
/// [CreateWishViewModel] rather than in three `TextEditingController`s plus a
/// mirrored `isDirty` flag, which is what let the "discard changes?" prompt
/// fire on an empty form and the submit button drift out of sync with the text
/// on screen.
class CreateWishView extends StatefulWidget {
  const CreateWishView({super.key});

  @override
  State<CreateWishView> createState() => _CreateWishViewState();
}

class _CreateWishViewState extends State<CreateWishView> {
  late final CreateWishViewModel _viewModel;
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final model = context.read<WishModel>();
    _viewModel = CreateWishViewModel(
      onSubmit: (request) => model.createWish(request),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _emailController.dispose();
    _viewModel.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final outcome = await _viewModel.submit();
    if (!mounted) return;

    if (outcome == CreateWishSubmitOutcome.success) {
      Navigator.of(context).pop();
      return;
    }

    final strings = context.l10n;
    final message = switch (outcome) {
      CreateWishSubmitOutcome.emailRequired => strings.emailRequiredText,
      CreateWishSubmitOutcome.emailFormatWrong => strings.emailFormatWrongText,
      CreateWishSubmitOutcome.createReturnedError => strings.somethingWentWrong,
      CreateWishSubmitOutcome.success => null,
    };
    if (message == null) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  /// Confirms before throwing away a partially filled form.
  ///
  /// Keyed on the view model's `isDirty`, which is the text the user can
  /// actually see. The old `setState(() => _hasChanges = true)` in a
  /// controller listener also fired when the form was programmatically
  /// cleared, so leaving an untouched screen could prompt.
  Future<bool> _confirmDiscard() async {
    if (!_viewModel.isDirty) return true;

    final strings = context.l10n;
    // The dialog's own context is what `showDialog` needs; the strings are read
    // before the await so no context crosses the gap.
    final discard = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(strings.discardEnteredInformation),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(strings.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(strings.confirm),
          ),
        ],
      ),
    );
    return discard ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final strings = context.l10n;
    final theme = Theme.of(context);
    final emailField = _viewModel.emailField;

    return PopScope<bool>(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final navigator = Navigator.of(context);
        if (await _confirmDiscard()) navigator.pop();
      },
      child: Scaffold(
        appBar: AppBar(title: Text(strings.createWish)),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _LabelledField(
              label: strings.title,
              child: TextField(
                controller: _titleController,
                onChanged: _viewModel.setTitle,
                enabled: !_viewModel.isButtonLoading,
                maxLength: WishValidation.titleLimit,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  hintText: strings.titleOfWish,
                  border: const OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(height: 16),
            _LabelledField(
              label: strings.description,
              child: TextField(
                controller: _descriptionController,
                onChanged: _viewModel.setDescription,
                enabled: !_viewModel.isButtonLoading,
                minLines: 3,
                maxLines: 6,
                maxLength: WishValidation.descriptionLimit,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  hintText: strings.descriptionPlaceholder,
                  border: const OutlineInputBorder(),
                ),
              ),
            ),
            if (emailField != EmailField.none) ...[
              const SizedBox(height: 16),
              _LabelledField(
                // iOS labels the field "Email (optional)" / "Email (required)"
                // through two separate keys rather than composing them, so a
                // host overriding one gets exactly that string.
                label: emailField == EmailField.required
                    ? strings.emailRequired
                    : strings.emailOptional,
                child: TextField(
                  controller: _emailController,
                  onChanged: _viewModel.setEmail,
                  enabled: !_viewModel.isButtonLoading,
                  keyboardType: TextInputType.emailAddress,
                  autocorrect: false,
                  decoration: InputDecoration(
                    hintText: strings.emailPlaceholder,
                    border: const OutlineInputBorder(),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 24),
            FilledButton(
              onPressed:
                  _viewModel.isButtonDisabled || _viewModel.isButtonLoading
                      ? null
                      : _submit,
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
              ),
              child: _viewModel.isButtonLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(strings.save),
            ),
            if (_viewModel.error != null) ...[
              const SizedBox(height: 12),
              Text(
                _viewModel.error!,
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: theme.colorScheme.error),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// A caption above a text field.
///
/// Material's own `InputDecoration.labelText` floats inside the outline, which
/// does not match the iOS layout where the caption sits above the field and
/// stays put. Rolling it keeps the two SDKs visually aligned for a host that
/// ships both.
class _LabelledField extends StatelessWidget {
  final String label;
  final Widget child;

  const _LabelledField({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.labelMedium
              ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
        ),
        const SizedBox(height: 6),
        child,
      ],
    );
  }
}
