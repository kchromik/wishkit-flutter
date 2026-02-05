import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/configuration.dart';
import '../models/wish.dart';
import '../state/wish_provider.dart';
import '../wishkit.dart';

/// View for creating a new wish.
class CreateWishView extends StatefulWidget {
  const CreateWishView({super.key});

  @override
  State<CreateWishView> createState() => _CreateWishViewState();
}

class _CreateWishViewState extends State<CreateWishView> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _emailController = TextEditingController();
  bool _isSubmitting = false;
  bool _hasChanges = false;

  static const int _maxTitleLength = 50;
  static const int _maxDescriptionLength = 500;

  @override
  void initState() {
    super.initState();
    _titleController.addListener(_onChanged);
    _descriptionController.addListener(_onChanged);
    _emailController.addListener(_onChanged);
  }

  void _onChanged() {
    if (!_hasChanges) {
      setState(() => _hasChanges = true);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<bool> _onWillPop() async {
    if (!_hasChanges) return true;

    final localization = WishKit.config.localization;
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(localization.unsavedChangesTitle),
        content: Text(localization.unsavedChangesMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(localization.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(localization.discard),
          ),
        ],
      ),
    );

    return result ?? false;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    final provider = context.read<WishProvider>();
    final localization = WishKit.config.localization;

    final request = CreateWishRequest(
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      email: _emailController.text.trim().isEmpty
          ? null
          : _emailController.text.trim(),
    );

    final success = await provider.createWish(request);

    if (!mounted) return;

    setState(() => _isSubmitting = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(localization.wishCreatedMessage),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.error ?? localization.errorTitle),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final config = WishKit.config;
    final localization = config.localization;
    final theme = Theme.of(context);
    final primaryColor = WishKit.theme.primaryColor;

    return PopScope(
      canPop: !_hasChanges,
      onPopInvokedWithResult: (didPop, result) async {
        if (!didPop) {
          final shouldPop = await _onWillPop();
          if (shouldPop && mounted) {
            Navigator.pop(context);
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(localization.featureRequest),
          actions: [
            if (config.buttons.doneButton.display == Display.show)
              TextButton(
                onPressed: _isSubmitting ? null : _submit,
                child: _isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(
                        localization.save,
                        style: TextStyle(color: primaryColor),
                      ),
              ),
          ],
        ),
        body: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                localization.title,
                style: theme.textTheme.labelLarge,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _titleController,
                maxLength: _maxTitleLength,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  hintText: localization.titlePlaceholder,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Title is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Text(
                localization.description,
                style: theme.textTheme.labelLarge,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _descriptionController,
                maxLength: _maxDescriptionLength,
                maxLines: 5,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  hintText: localization.descriptionPlaceholder,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  alignLabelWithHint: true,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Description is required';
                  }
                  return null;
                },
              ),
              if (config.emailField != EmailField.none) ...[
                const SizedBox(height: 16),
                Text(
                  localization.email,
                  style: theme.textTheme.labelLarge,
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    hintText: localization.emailPlaceholder,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  validator: (value) {
                    if (config.emailField == EmailField.required) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Email is required';
                      }
                    }
                    if (value != null && value.isNotEmpty) {
                      if (!_isValidEmail(value)) {
                        return 'Please enter a valid email';
                      }
                    }
                    return null;
                  },
                ),
              ],
              const SizedBox(height: 24),
              if (config.buttons.doneButton.display == Display.hide)
                ElevatedButton(
                  onPressed: _isSubmitting ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(localization.submit),
                ),
            ],
          ),
        ),
      ),
    );
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }
}
