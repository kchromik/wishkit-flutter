import 'package:flutter_test/flutter_test.dart';
import 'package:wishkit/wishkit.dart';

/// Port of `WishValidationTests`.
///
/// The validation logic is pure and context-free, so these tests hit the
/// production functions directly rather than through a view model.
void main() {
  group('normalize', () {
    test('trims title and description to the server limits', () {
      final result = WishValidation.normalize(
        title: 't' * 80,
        description: 'd' * 700,
        email: 'test@example.com',
      );

      expect(result.title.length, WishValidation.titleLimit);
      expect(result.description.length, WishValidation.descriptionLimit);
      // Email passes through unchanged — iOS does not trim or cap it.
      expect(result.email, 'test@example.com');
    });

    test('title shorter than limit is unchanged', () {
      final result = WishValidation.normalize(
        title: 'short',
        description: 'short',
        email: 'test@example.com',
      );

      expect(result.title, 'short');
      expect(result.description, 'short');
    });
  });

  group('isCreateButtonDisabled', () {
    test('disabled when title is empty', () {
      expect(
        WishValidation.isCreateButtonDisabled(title: '', description: 'x'),
        isTrue,
      );
    });

    test('disabled when description is empty', () {
      expect(
        WishValidation.isCreateButtonDisabled(title: 'x', description: ''),
        isTrue,
      );
    });

    test('enabled when both have content', () {
      expect(
        WishValidation.isCreateButtonDisabled(title: 'x', description: 'y'),
        isFalse,
      );
    });
  });

  group('validateEmail', () {
    test('required but missing returns requiredButMissing', () {
      final result = WishValidation.validateEmail(
        email: '',
        fieldRequirement: EmailField.required,
      );

      expect(result, EmailValidationResult.requiredButMissing);
    });

    test('optional and empty returns valid', () {
      final result = WishValidation.validateEmail(
        email: '',
        fieldRequirement: EmailField.optional,
      );

      expect(result, EmailValidationResult.valid);
    });

    test('invalid format returns invalidFormat', () {
      final result = WishValidation.validateEmail(
        email: 'abc',
        fieldRequirement: EmailField.optional,
      );

      expect(result, EmailValidationResult.invalidFormat);
    });

    test('valid format returns valid', () {
      final result = WishValidation.validateEmail(
        email: 'person@example.com',
        fieldRequirement: EmailField.optional,
      );

      expect(result, EmailValidationResult.valid);
    });

    test('required with valid format returns valid', () {
      final result = WishValidation.validateEmail(
        email: 'person@example.com',
        fieldRequirement: EmailField.required,
      );

      expect(result, EmailValidationResult.valid);
    });

    test('none validates format when email is provided', () {
      // The field is hidden, but a host could still set it programmatically.
      // Validation runs on whatever value is provided.
      final result = WishValidation.validateEmail(
        email: 'abc',
        fieldRequirement: EmailField.none,
      );

      expect(result, EmailValidationResult.invalidFormat);
    });

    test('none returns valid for a valid email', () {
      final result = WishValidation.validateEmail(
        email: 'person@example.com',
        fieldRequirement: EmailField.none,
      );

      expect(result, EmailValidationResult.valid);
    });
  });
}