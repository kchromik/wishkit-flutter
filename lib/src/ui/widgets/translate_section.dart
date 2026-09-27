import 'package:flutter/material.dart';

import '../../config/configuration.dart';
import '../../state/detail_wish_view_model.dart';
import '../../wishkit.dart';
import '../../config/localization.dart';

/// The "See translation" / "See original" text button.
///
/// Port of `WishTranslateSection+iOS.swift`. Two things differ, both forced by
/// the platform:
///
/// * iOS gets translation from Apple's on-device Translation framework. Flutter
///   has no equivalent, so WishKit ships none and the host injects
///   [WishKitConfiguration.translator]. Without one the whole section is
///   hidden — the same user-visible outcome as iOS before 18, where the
///   framework does not exist and the view is not compiled in at all.
/// * iOS measures "does this need translating" against
///   `FeedbackLanguage.appLanguage`, i.e. the device language. Here it is
///   measured against the locale the board is *rendered* in, because that is
///   the language the user is reading.
class TranslateSection extends StatelessWidget {
  final DetailWishViewModel viewModel;

  const TranslateSection({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    if (!viewModel.shouldOfferTranslation(WishKit.config.translateButton)) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final strings = context.l10n;
    final label =
        viewModel.isShowingTranslation ? strings.seeOriginal : strings.seeTranslation;

    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: TextButton(
        onPressed: viewModel.isTranslating ? null : viewModel.toggleTranslation,
        // Compact: sits under the description like the iOS text button rather
        // than reading as a second primary action.
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        child: viewModel.isTranslating
            ? const SizedBox(
                width: 12,
                height: 12,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Text(
                label,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.secondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
      ),
    );
  }
}
