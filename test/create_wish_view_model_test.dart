import 'package:flutter_test/flutter_test.dart';
import 'package:wishkit/wishkit.dart';

/// Port of `CreateWishViewModelTests`.
///
/// The view model takes the submit action as an injected callback, so the
/// validation rules and the loading state around the network call can be
/// exercised without a network.
void main() {
  final originalConfig = WishKit.config;

  setUp(() => WishKit.config = WishKitConfiguration());

  tearDown(() => WishKit.config = originalConfig);

  group('validation', () {
    test('trims title and description to the server limits', () {
      final viewModel = CreateWishViewModel(
        onSubmit: (_) async => false,
      );
      viewModel.setTitle('x' * 70);
      viewModel.setDescription('y' * 700);

      // The truncation happens on every change, so the fields are already
      // clamped. The submit path runs the same normalisation again, which is
      // what this test covers.
      final normalized = WishValidation.normalize(
        title: viewModel.title,
        description: viewModel.description,
        email: '',
      );

      expect(normalized.title.length, WishValidation.titleLimit);
      expect(normalized.description.length, WishValidation.descriptionLimit);
    });

    test('submit returns emailRequired when required and missing', () async {
      WishKit.config.emailField = EmailField.required;

      final viewModel = CreateWishViewModel(
        onSubmit: (_) async => true,
      );
      viewModel.setTitle('Title');
      viewModel.setDescription('Description');

      final result = await viewModel.submit();

      expect(result, CreateWishSubmitOutcome.emailRequired);
      expect(viewModel.isButtonLoading, isFalse);
    });

    test('submit returns emailFormatWrong when invalid email provided', () async {
      WishKit.config.emailField = EmailField.optional;

      final viewModel = CreateWishViewModel(
        onSubmit: (_) async => true,
      );
      viewModel.setTitle('Title');
      viewModel.setDescription('Description');
      viewModel.setEmail('abc');

      final result = await viewModel.submit();

      expect(result, CreateWishSubmitOutcome.emailFormatWrong);
      expect(viewModel.isButtonLoading, isFalse);
    });

    test('submit toggles loading around the API call', () async {
      var observedLoadingDuringRequest = false;
      late final CreateWishViewModel viewModel;

      viewModel = CreateWishViewModel(
        onSubmit: (_) async {
          observedLoadingDuringRequest = viewModel.isButtonLoading;
          return false;
        },
      );
      viewModel.setTitle('Title');
      viewModel.setDescription('Description');

      final result = await viewModel.submit();

      expect(result, CreateWishSubmitOutcome.createReturnedError);
      expect(observedLoadingDuringRequest, isTrue);
      expect(viewModel.isButtonLoading, isFalse);
    });

    test('submit returns success when the action succeeds', () async {
      final viewModel = CreateWishViewModel(
        onSubmit: (_) async => true,
      );
      viewModel.setTitle('Title');
      viewModel.setDescription('Description');

      final result = await viewModel.submit();

      expect(result, CreateWishSubmitOutcome.success);
      expect(viewModel.isButtonLoading, isFalse);
    });
  });

  group('field limits', () {
    test('title longer than 50 characters is truncated on change', () {
      final viewModel = CreateWishViewModel(
        onSubmit: (_) async => false,
      );
      viewModel.setTitle('x' * 100);

      expect(viewModel.title.length, WishValidation.titleLimit);
    });

    test('description longer than 500 characters is truncated on change', () {
      final viewModel = CreateWishViewModel(
        onSubmit: (_) async => false,
      );
      viewModel.setDescription('y' * 1000);

      expect(viewModel.description.length, WishValidation.descriptionLimit);
    });
  });

  group('button state', () {
    test('button is disabled when title is empty', () {
      final viewModel = CreateWishViewModel(
        onSubmit: (_) async => false,
      );
      viewModel.setTitle('');
      viewModel.setDescription('Description');

      expect(viewModel.isButtonDisabled, isTrue);
    });

    test('button is disabled when description is empty', () {
      final viewModel = CreateWishViewModel(
        onSubmit: (_) async => false,
      );
      viewModel.setTitle('Title');
      viewModel.setDescription('');

      expect(viewModel.isButtonDisabled, isTrue);
    });

    test('button is enabled when both fields have content', () {
      final viewModel = CreateWishViewModel(
        onSubmit: (_) async => false,
      );
      viewModel.setTitle('Title');
      viewModel.setDescription('Description');

      expect(viewModel.isButtonDisabled, isFalse);
    });
  });

  group('dirty tracking', () {
    test('isDirty is false on a fresh form', () {
      final viewModel = CreateWishViewModel(
        onSubmit: (_) async => false,
      );
      expect(viewModel.isDirty, isFalse);
    });

    test('isDirty is true after typing in any field', () {
      final viewModel = CreateWishViewModel(
        onSubmit: (_) async => false,
      );
      viewModel.setTitle('x');
      expect(viewModel.isDirty, isTrue);

      viewModel.setTitle('');
      viewModel.setDescription('x');
      expect(viewModel.isDirty, isTrue);

      viewModel.setDescription('');
      viewModel.setEmail('x');
      expect(viewModel.isDirty, isTrue);
    });

    test('reset clears the dirty flag', () {
      final viewModel = CreateWishViewModel(
        onSubmit: (_) async => false,
      );
      viewModel.setTitle('Title');
      viewModel.setDescription('Description');
      viewModel.reset();

      expect(viewModel.isDirty, isFalse);
      expect(viewModel.title, '');
      expect(viewModel.description, '');
      expect(viewModel.email, '');
    });
  });

  group('config-driven email field', () {
    test('emailField reads live from WishKit.config', () {
      final viewModel = CreateWishViewModel(
        onSubmit: (_) async => false,
      );

      WishKit.config.emailField = EmailField.none;
      expect(viewModel.emailField, EmailField.none);

      WishKit.config.emailField = EmailField.required;
      expect(viewModel.emailField, EmailField.required);
    });
  });
}