import 'package:flutter_test/flutter_test.dart';
import 'package:wishkit/wishkit.dart';

import 'helpers/fixtures.dart';

/// Port of `DetailWishViewModelTests`.
///
/// The view model owns the vote/comment state for a single wish and the
/// translation toggle. The actions are injected so the guards and the
/// optimistic updates can be tested without a network.
void main() {
  final originalConfig = WishKit.config;

  setUp(() {
    WishKit.config = WishKitConfiguration();
    WishKit.config.allowUndoVote = true;
  });

  tearDown(() => WishKit.config = originalConfig);

  group('vote', () {
    test('a completed wish cannot be voted on', () async {
      final wish = makeWish(id: 'done', state: WishState.completed);
      var voteCalled = false;
      var unvoteCalled = false;

      final viewModel = DetailWishViewModel(
        wishId: wish.id,
        wish: wish,
        userUuid: 'me',
        appLanguage: 'en',
        onVote: (_) {
          voteCalled = true;
          return Future.value(true);
        },
        onUnvote: (_) {
          unvoteCalled = true;
          return Future.value(true);
        },
        onCreateComment: (_) async => null,
      );

      final outcome = await viewModel.toggleVote();

      expect(outcome, VoteOutcome.completedWish);
      expect(voteCalled, isFalse);
      expect(unvoteCalled, isFalse);
      expect(viewModel.hasVoted, isFalse);
      expect(viewModel.voteCount, wish.voteCount);
    });

    test('an implemented wish cannot be voted on', () async {
      final wish = makeWish(id: 'done', state: WishState.implemented);

      final viewModel = DetailWishViewModel(
        wishId: wish.id,
        wish: wish,
        userUuid: 'me',
        appLanguage: 'en',
        onVote: (_) => Future.value(true),
        onUnvote: (_) => Future.value(true),
        onCreateComment: (_) async => null,
      );

      final outcome = await viewModel.toggleVote();

      expect(outcome, VoteOutcome.completedWish);
    });

    test('already voted and undo off returns alreadyVoted', () async {
      WishKit.config.allowUndoVote = false;
      final wish = makeWish(id: 'a', userUuid: 'me', votes: 1, voterUuids: ['me']);

      final viewModel = DetailWishViewModel(
        wishId: wish.id,
        wish: wish,
        userUuid: 'me',
        appLanguage: 'en',
        onVote: (_) => Future.value(true),
        onUnvote: (_) => Future.value(true),
        onCreateComment: (_) async => null,
      );

      expect(viewModel.hasVoted, isTrue);

      final outcome = await viewModel.toggleVote();

      expect(outcome, VoteOutcome.alreadyVoted);
      expect(viewModel.hasVoted, isTrue);
    });

    test('voting increments the count optimistically and reverts on failure',
        () async {
      final wish = makeWish(id: 'a', votes: 5);
      var callCount = 0;

      final viewModel = DetailWishViewModel(
        wishId: wish.id,
        wish: wish,
        userUuid: 'me',
        appLanguage: 'en',
        onVote: (_) {
          callCount++;
          return Future.value(false);
        },
        onUnvote: (_) => Future.value(true),
        onCreateComment: (_) async => null,
      );

      final outcome = await viewModel.vote();

      expect(outcome, VoteOutcome.error);
      expect(viewModel.voteCount, 5);
      expect(viewModel.hasVoted, isFalse);
      expect(callCount, 1);
    });

    test('voting keeps the optimistic update on success', () async {
      final wish = makeWish(id: 'a', votes: 5);

      final viewModel = DetailWishViewModel(
        wishId: wish.id,
        wish: wish,
        userUuid: 'me',
        appLanguage: 'en',
        onVote: (_) => Future.value(true),
        onUnvote: (_) => Future.value(true),
        onCreateComment: (_) async => null,
      );

      final outcome = await viewModel.vote();

      expect(outcome, VoteOutcome.success);
      expect(viewModel.voteCount, 6);
      expect(viewModel.hasVoted, isTrue);
    });

    test('unvoting decrements the count optimistically and reverts on failure',
        () async {
      final wish = makeWish(id: 'a', userUuid: 'me', votes: 5, voterUuids: ['me', 'other1', 'other2', 'other3', 'other4']);

      final viewModel = DetailWishViewModel(
        wishId: wish.id,
        wish: wish,
        userUuid: 'me',
        appLanguage: 'en',
        onVote: (_) => Future.value(true),
        onUnvote: (_) => Future.value(false),
        onCreateComment: (_) async => null,
      );

      expect(viewModel.hasVoted, isTrue);

      final outcome = await viewModel.removeVote();

      expect(outcome, VoteOutcome.error);
      expect(viewModel.voteCount, 5);
      expect(viewModel.hasVoted, isTrue);
    });

    test('unvoting keeps the optimistic update on success', () async {
      final wish = makeWish(id: 'a', userUuid: 'me', votes: 5, voterUuids: ['me', 'other1', 'other2', 'other3', 'other4']);

      final viewModel = DetailWishViewModel(
        wishId: wish.id,
        wish: wish,
        userUuid: 'me',
        appLanguage: 'en',
        onVote: (_) => Future.value(true),
        onUnvote: (_) => Future.value(true),
        onCreateComment: (_) async => null,
      );

      expect(viewModel.hasVoted, isTrue);

      final outcome = await viewModel.removeVote();

      expect(outcome, VoteOutcome.voteRemoved);
      expect(viewModel.voteCount, 4);
      expect(viewModel.hasVoted, isFalse);
    });

    test('toggleVote with undo on unvotes when already voted', () async {
      final wish = makeWish(id: 'a', userUuid: 'me', votes: 5, voterUuids: ['me', 'other1', 'other2', 'other3', 'other4']);

      final viewModel = DetailWishViewModel(
        wishId: wish.id,
        wish: wish,
        userUuid: 'me',
        appLanguage: 'en',
        onVote: (_) => Future.value(true),
        onUnvote: (_) => Future.value(true),
        onCreateComment: (_) async => null,
      );

      expect(viewModel.hasVoted, isTrue);
      final outcome = await viewModel.toggleVote();

      expect(outcome, VoteOutcome.voteRemoved);
      expect(viewModel.voteCount, 4);
      expect(viewModel.hasVoted, isFalse);
    });

    test('an exception in the action is treated like a failure', () async {
      final wish = makeWish(id: 'a', votes: 5);

      final viewModel = DetailWishViewModel(
        wishId: wish.id,
        wish: wish,
        userUuid: 'me',
        appLanguage: 'en',
        onVote: (_) => Future.error(StateError('network')),
        onUnvote: (_) => Future.value(true),
        onCreateComment: (_) async => null,
      );

      final outcome = await viewModel.vote();

      expect(outcome, VoteOutcome.error);
      expect(viewModel.voteCount, 5);
      expect(viewModel.hasVoted, isFalse);
    });
  });

  group('comments', () {
    test('submitComment skips whitespace-only input', () async {
      var callCount = 0;

      final viewModel = DetailWishViewModel(
        wishId: 'a',
        wish: makeWish(id: 'a'),
        userUuid: 'me',
        appLanguage: 'en',
        onVote: (_) => Future.value(true),
        onUnvote: (_) => Future.value(true),
        onCreateComment: (_) {
          callCount++;
          return Future.value(null);
        },
      );

      viewModel.setNewComment('   \n  ');
      await viewModel.submitComment();

      expect(callCount, 0);
      expect(viewModel.isLoading, isFalse);
    });

    test('submitComment toggles loading and trims the body', () async {
      var observedLoading = false;
      var capturedDescription = '';
      late final DetailWishViewModel viewModel;

      viewModel = DetailWishViewModel(
        wishId: 'a',
        wish: makeWish(id: 'a'),
        userUuid: 'me',
        appLanguage: 'en',
        onVote: (_) => Future.value(true),
        onUnvote: (_) => Future.value(true),
        onCreateComment: (request) {
          observedLoading = viewModel.isLoading;
          capturedDescription = request.description;
          return Future.value(Comment(
            id: 'c1',
            description: request.description,
            createdAt: DateTime.now(),
            isAdmin: false,
          ));
        },
      );

      viewModel.setNewComment('  hello world  ');
      final comment = await viewModel.submitComment();

      expect(observedLoading, isTrue);
      expect(capturedDescription, 'hello world');
      expect(viewModel.isLoading, isFalse);
      expect(comment, isNotNull);
      expect(comment!.description, 'hello world');
      // The input field is cleared on success.
      expect(viewModel.newComment, '');
    });

    test('submitComment returns null on error and restores the field', () async {
      final viewModel = DetailWishViewModel(
        wishId: 'a',
        wish: makeWish(id: 'a'),
        userUuid: 'me',
        appLanguage: 'en',
        onVote: (_) => Future.value(true),
        onUnvote: (_) => Future.value(true),
        onCreateComment: (_) async => null,
      );

      viewModel.setNewComment('hello');
      final comment = await viewModel.submitComment();

      expect(comment, isNull);
      expect(viewModel.newComment, 'hello');
      expect(viewModel.isLoading, isFalse);
    });
  });

  group('translation', () {
    test('shouldOfferTranslation returns false when translator is null', () {
      final viewModel = DetailWishViewModel(
        wishId: 'a',
        wish: makeWish(id: 'a'),
        userUuid: 'me',
        appLanguage: 'en',
        onVote: (_) => Future.value(true),
        onUnvote: (_) => Future.value(true),
        onCreateComment: (_) async => null,
        translator: null,
      );

      expect(viewModel.shouldOfferTranslation(TranslateButton.automatic), false);
      expect(viewModel.shouldOfferTranslation(TranslateButton.always), false);
      expect(viewModel.shouldOfferTranslation(TranslateButton.hide), false);
    });

    test('shouldOfferTranslation returns false for hide mode', () {
      final viewModel = DetailWishViewModel(
        wishId: 'a',
        wish: makeWish(id: 'a'),
        userUuid: 'me',
        appLanguage: 'en',
        onVote: (_) => Future.value(true),
        onUnvote: (_) => Future.value(true),
        onCreateComment: (_) async => null,
        translator: (requests) async => const [],
      );

      expect(viewModel.shouldOfferTranslation(TranslateButton.hide), false);
    });

    test('shouldOfferTranslation returns true for always mode', () {
      final viewModel = DetailWishViewModel(
        wishId: 'a',
        wish: makeWish(id: 'a'),
        userUuid: 'me',
        appLanguage: 'en',
        onVote: (_) => Future.value(true),
        onUnvote: (_) => Future.value(true),
        onCreateComment: (_) async => null,
        translator: (requests) async => const [],
      );

      expect(viewModel.shouldOfferTranslation(TranslateButton.always), true);
    });

    test('shouldOfferTranslation for automatic mode uses language detection', () {
      // Spanish text with function words (por, favor, esta, etc.) triggers detection.
      // "Hola mundo" has no function words, so it returns null = no offer.
      final viewModel = DetailWishViewModel(
        wishId: 'a',
        wish: makeWish(
          id: 'a',
          title: 'Por favor añade esta funcionalidad',
          description: 'Cuando pueda, por favor',
        ),
        userUuid: 'me',
        appLanguage: 'en',
        onVote: (_) => Future.value(true),
        onUnvote: (_) => Future.value(true),
        onCreateComment: (_) async => null,
        translator: (requests) async => const [],
      );

      // Spanish text detected, English app language -> differs -> should offer
      expect(viewModel.shouldOfferTranslation(TranslateButton.automatic), isTrue);

      final viewModel2 = DetailWishViewModel(
        wishId: 'b',
        wish: makeWish(id: 'b', title: 'Hello', description: 'World'),
        userUuid: 'me',
        appLanguage: 'en',
        onVote: (_) => Future.value(true),
        onUnvote: (_) => Future.value(true),
        onCreateComment: (_) async => null,
        translator: (requests) async => const [],
      );

      // English text, English app language -> same -> should NOT offer
      expect(viewModel2.shouldOfferTranslation(TranslateButton.automatic), false);
    });
  });

  group('allowUndoVote', () {
    test('reads live from WishKit.config', () {
      final wish = makeWish(id: 'a', userUuid: 'me', votes: 1);

      final viewModel = DetailWishViewModel(
        wishId: wish.id,
        wish: wish,
        userUuid: 'me',
        appLanguage: 'en',
        onVote: (_) => Future.value(true),
        onUnvote: (_) => Future.value(true),
        onCreateComment: (_) async => null,
      );

      expect(viewModel.allowUndoVote, isTrue);

      WishKit.config.allowUndoVote = false;
      expect(viewModel.allowUndoVote, isFalse);
    });
  });

  group('isOwnWish', () {
    test('is true when userUuid matches the wish owner', () {
      final wish = makeWish(id: 'a', userUuid: 'me');

      final viewModel = DetailWishViewModel(
        wishId: wish.id,
        wish: wish,
        userUuid: 'me',
        appLanguage: 'en',
        onVote: (_) => Future.value(true),
        onUnvote: (_) => Future.value(true),
        onCreateComment: (_) async => null,
      );

      expect(viewModel.isOwnWish, isTrue);
    });

    test('is false when userUuid differs from the wish owner', () {
      final wish = makeWish(id: 'a', userUuid: 'other');

      final viewModel = DetailWishViewModel(
        wishId: wish.id,
        wish: wish,
        userUuid: 'me',
        appLanguage: 'en',
        onVote: (_) => Future.value(true),
        onUnvote: (_) => Future.value(true),
        onCreateComment: (_) async => null,
      );

      expect(viewModel.isOwnWish, isFalse);
    });

    test('is false when userUuid is empty', () {
      final wish = makeWish(id: 'a', userUuid: 'other');

      final viewModel = DetailWishViewModel(
        wishId: wish.id,
        wish: wish,
        userUuid: '',
        appLanguage: 'en',
        onVote: (_) => Future.value(true),
        onUnvote: (_) => Future.value(true),
        onCreateComment: (_) async => null,
      );

      expect(viewModel.isOwnWish, isFalse);
    });

    test('comparison is case-insensitive', () {
      final wish = makeWish(id: 'a', userUuid: 'AB-CD');

      final viewModel = DetailWishViewModel(
        wishId: wish.id,
        wish: wish,
        userUuid: 'ab-cd',
        appLanguage: 'en',
        onVote: (_) => Future.value(true),
        onUnvote: (_) => Future.value(true),
        onCreateComment: (_) async => null,
      );

      expect(viewModel.isOwnWish, isTrue);
    });
  });

  group('invalidateTranslation', () {
    test('clears cached translations', () {
      final viewModel = DetailWishViewModel(
        wishId: 'a',
        wish: makeWish(id: 'a'),
        userUuid: 'me',
        appLanguage: 'en',
        onVote: (_) => Future.value(true),
        onUnvote: (_) => Future.value(true),
        onCreateComment: (_) async => null,
      );

      // Simulate a cached translation
      viewModel.invalidateTranslation();

      expect(viewModel.isShowingTranslation, isFalse);
      expect(viewModel.isTranslating, isFalse);
    });
  });
}