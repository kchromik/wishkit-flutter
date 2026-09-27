// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'wishkit_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class WishKitLocalizationsJa extends WishKitLocalizations {
  WishKitLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get requested => 'リクエスト済み';

  @override
  String get pending => '承認待ち';

  @override
  String get approved => '承認済み';

  @override
  String get implemented => '完了';

  @override
  String get inReview => 'レビュー中';

  @override
  String get planned => '計画中';

  @override
  String get inProgress => '対応中';

  @override
  String get completed => '完了';

  @override
  String get open => 'オープン';

  @override
  String get closed => 'クローズ';

  @override
  String get wishlist => '機能リクエスト';

  @override
  String get save => '送信';

  @override
  String get title => 'タイトル';

  @override
  String get description => '説明';

  @override
  String get upvote => '投票';

  @override
  String get info => '情報';

  @override
  String get youCanOnlyVoteOnce => '投票は1回のみ可能です。';

  @override
  String get youCanNotVoteForACompletedWish => 'すでに完了した機能には投票できません。';

  @override
  String get youCanNotVoteForYourOwnWish => '自分の機能リクエストには投票できません。';

  @override
  String get poweredBy => 'Powered by';

  @override
  String get successfullyCreated => '送信が完了しました';

  @override
  String get done => '完了';

  @override
  String get detail => '詳細';

  @override
  String get featureWishlist => '機能リクエスト';

  @override
  String get confirm => '確認';

  @override
  String get cancel => 'キャンセル';

  @override
  String get ok => 'OK';

  @override
  String get titleOfWish => '機能のタイトル..';

  @override
  String get titleDescriptionCannotBeEmpty => 'タイトルと説明は必須です。';

  @override
  String get votes => '票';

  @override
  String get close => '閉じる';

  @override
  String get createWish => '新しい機能リクエスト';

  @override
  String get optional => '任意';

  @override
  String get required => '必須';

  @override
  String get emailRequiredText => 'メールアドレスを入力してください。';

  @override
  String get emailFormatWrongText => 'メールアドレスの形式が正しくありません。';

  @override
  String get comments => 'コメント';

  @override
  String get writeAComment => 'コメントを書く..';

  @override
  String get submitComment => '送信';

  @override
  String get admin => '管理者';

  @override
  String get user => 'ユーザー';

  @override
  String get noFeatureRequests => 'まだ機能リクエストはありません ✨';

  @override
  String get emailOptional => 'メール（任意）';

  @override
  String get emailRequired => 'メール（必須）';

  @override
  String get discardEnteredInformation => '変更を破棄しますか？';

  @override
  String get addButtonInNavigationBar => '作成';

  @override
  String get refresh => '更新';

  @override
  String get refreshing => '更新中..';

  @override
  String get somethingWentWrong => '問題が発生しました。しばらくしてからもう一度お試しください。';

  @override
  String get all => 'すべて';

  @override
  String get notSupported => '非対応';

  @override
  String get filter => 'フィルタ';

  @override
  String get activateToSwitchFilter => '選択するとフィルタを切り替えます。';

  @override
  String get seeTranslation => '翻訳を表示';

  @override
  String get seeOriginal => '原文を表示';

  @override
  String get chat => 'チャットで相談';

  @override
  String get writeAMessage => 'メッセージを入力…';

  @override
  String get send => '送信';

  @override
  String get chatEmptyState => '質問やフィードバックはありますか？メッセージをお送りください。';

  @override
  String get failedToSendTapToRetry => '送信に失敗しました。タップして再試行。';
}
