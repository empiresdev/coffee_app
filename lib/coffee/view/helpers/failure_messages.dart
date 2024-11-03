import 'package:coffee_app/l10n/l10n.dart';

String getFailureMessage(AppLocalizations localizations, String? failureId) {
  switch (failureId) {
    case 'favoritesEmptyErrorMessage':
      return localizations.favoritesEmptyErrorMessage;
    case 'fetchRandomImageFailureMessage':
      return localizations.fetchRandomImageFailureMessage;
    case 'loadFavoriteImageFailureMessage':
      return localizations.loadFavoriteImageFailureMessage;
    case 'saveImageFailureMessage':
      return localizations.saveImageFailureMessage;
  }
  return localizations.errorMessage;
}
