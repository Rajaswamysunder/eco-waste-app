// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Smart Waste Collection';

  @override
  String get login => 'Login';

  @override
  String get signup => 'Sign Up';

  @override
  String get pickupHistory => 'Pickup History';

  @override
  String get viewPastPickups => 'View all your past pickups';

  @override
  String get all => 'All';

  @override
  String get pending => 'Pending';

  @override
  String get completed => 'Completed';

  @override
  String get cancelled => 'Cancelled';
}
