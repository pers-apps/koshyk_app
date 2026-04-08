import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_uk.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('uk')
  ];

  /// No description provided for @appTitle.
  ///
  /// In uk, this message translates to:
  /// **'Кошик'**
  String get appTitle;

  /// No description provided for @groups.
  ///
  /// In uk, this message translates to:
  /// **'Групи'**
  String get groups;

  /// No description provided for @newGroup.
  ///
  /// In uk, this message translates to:
  /// **'Нова група'**
  String get newGroup;

  /// No description provided for @editGroup.
  ///
  /// In uk, this message translates to:
  /// **'Редагувати групу'**
  String get editGroup;

  /// No description provided for @deleteGroup.
  ///
  /// In uk, this message translates to:
  /// **'Видалити групу'**
  String get deleteGroup;

  /// No description provided for @deleteGroupConfirm.
  ///
  /// In uk, this message translates to:
  /// **'Видалити групу \"{name}\"? Всі витрати та учасники будуть видалені.'**
  String deleteGroupConfirm(String name);

  /// No description provided for @groupName.
  ///
  /// In uk, this message translates to:
  /// **'Назва групи'**
  String get groupName;

  /// No description provided for @currency.
  ///
  /// In uk, this message translates to:
  /// **'Символ валюти'**
  String get currency;

  /// No description provided for @noGroups.
  ///
  /// In uk, this message translates to:
  /// **'Немає груп. Натисніть + щоб створити.'**
  String get noGroups;

  /// No description provided for @totalExpenses.
  ///
  /// In uk, this message translates to:
  /// **'Загальні витрати'**
  String get totalExpenses;

  /// No description provided for @participants.
  ///
  /// In uk, this message translates to:
  /// **'Учасники'**
  String get participants;

  /// No description provided for @addParticipant.
  ///
  /// In uk, this message translates to:
  /// **'Додати учасника'**
  String get addParticipant;

  /// No description provided for @editParticipant.
  ///
  /// In uk, this message translates to:
  /// **'Редагувати учасника'**
  String get editParticipant;

  /// No description provided for @participantName.
  ///
  /// In uk, this message translates to:
  /// **'Ім\'я учасника'**
  String get participantName;

  /// No description provided for @deactivate.
  ///
  /// In uk, this message translates to:
  /// **'Деактивувати'**
  String get deactivate;

  /// No description provided for @activate.
  ///
  /// In uk, this message translates to:
  /// **'Активувати'**
  String get activate;

  /// No description provided for @deleteParticipant.
  ///
  /// In uk, this message translates to:
  /// **'Видалити учасника'**
  String get deleteParticipant;

  /// No description provided for @cannotDeleteParticipantHasData.
  ///
  /// In uk, this message translates to:
  /// **'Неможливо видалити учасника з витратами. Спробуйте деактивувати.'**
  String get cannotDeleteParticipantHasData;

  /// No description provided for @duplicateParticipantName.
  ///
  /// In uk, this message translates to:
  /// **'Учасник з таким ім\'ям вже існує'**
  String get duplicateParticipantName;

  /// No description provided for @categories.
  ///
  /// In uk, this message translates to:
  /// **'Категорії'**
  String get categories;

  /// No description provided for @addCategory.
  ///
  /// In uk, this message translates to:
  /// **'Додати категорію'**
  String get addCategory;

  /// No description provided for @editCategory.
  ///
  /// In uk, this message translates to:
  /// **'Редагувати категорію'**
  String get editCategory;

  /// No description provided for @categoryName.
  ///
  /// In uk, this message translates to:
  /// **'Назва категорії'**
  String get categoryName;

  /// No description provided for @maxCategoriesReached.
  ///
  /// In uk, this message translates to:
  /// **'Максимум 10 категорій'**
  String get maxCategoriesReached;

  /// No description provided for @noCategory.
  ///
  /// In uk, this message translates to:
  /// **'Без категорії'**
  String get noCategory;

  /// No description provided for @expenses.
  ///
  /// In uk, this message translates to:
  /// **'Витрати'**
  String get expenses;

  /// No description provided for @addExpense.
  ///
  /// In uk, this message translates to:
  /// **'Додати витрату'**
  String get addExpense;

  /// No description provided for @editExpense.
  ///
  /// In uk, this message translates to:
  /// **'Редагувати витрату'**
  String get editExpense;

  /// No description provided for @amount.
  ///
  /// In uk, this message translates to:
  /// **'Сума'**
  String get amount;

  /// No description provided for @payer.
  ///
  /// In uk, this message translates to:
  /// **'Платник'**
  String get payer;

  /// No description provided for @date.
  ///
  /// In uk, this message translates to:
  /// **'Дата'**
  String get date;

  /// No description provided for @comment.
  ///
  /// In uk, this message translates to:
  /// **'Коментар'**
  String get comment;

  /// No description provided for @category.
  ///
  /// In uk, this message translates to:
  /// **'Категорія'**
  String get category;

  /// No description provided for @invalidAmount.
  ///
  /// In uk, this message translates to:
  /// **'Введіть коректну суму (> 0)'**
  String get invalidAmount;

  /// No description provided for @amountHint.
  ///
  /// In uk, this message translates to:
  /// **'напр. 300+450 або 250'**
  String get amountHint;

  /// No description provided for @settlements.
  ///
  /// In uk, this message translates to:
  /// **'Розрахунки'**
  String get settlements;

  /// No description provided for @addSettlement.
  ///
  /// In uk, this message translates to:
  /// **'Додати розрахунок'**
  String get addSettlement;

  /// No description provided for @editSettlement.
  ///
  /// In uk, this message translates to:
  /// **'Редагувати розрахунок'**
  String get editSettlement;

  /// No description provided for @from.
  ///
  /// In uk, this message translates to:
  /// **'Від'**
  String get from;

  /// No description provided for @to.
  ///
  /// In uk, this message translates to:
  /// **'Кому'**
  String get to;

  /// No description provided for @samePersonError.
  ///
  /// In uk, this message translates to:
  /// **'Відправник і отримувач мають бути різними'**
  String get samePersonError;

  /// No description provided for @summary.
  ///
  /// In uk, this message translates to:
  /// **'Підсумок'**
  String get summary;

  /// No description provided for @totalShared.
  ///
  /// In uk, this message translates to:
  /// **'Загальні спільні витрати'**
  String get totalShared;

  /// No description provided for @equalShare.
  ///
  /// In uk, this message translates to:
  /// **'Рівна частка'**
  String get equalShare;

  /// No description provided for @amountPaid.
  ///
  /// In uk, this message translates to:
  /// **'Сплачено'**
  String get amountPaid;

  /// No description provided for @rawBalance.
  ///
  /// In uk, this message translates to:
  /// **'Баланс (без переказів)'**
  String get rawBalance;

  /// No description provided for @transferNet.
  ///
  /// In uk, this message translates to:
  /// **'Перекази (нетто)'**
  String get transferNet;

  /// No description provided for @finalBalance.
  ///
  /// In uk, this message translates to:
  /// **'Підсумковий баланс'**
  String get finalBalance;

  /// No description provided for @settlementInstructions.
  ///
  /// In uk, this message translates to:
  /// **'Інструкції розрахунку'**
  String get settlementInstructions;

  /// No description provided for @nothingToSettle.
  ///
  /// In uk, this message translates to:
  /// **'Нічого розраховувати'**
  String get nothingToSettle;

  /// No description provided for @pays.
  ///
  /// In uk, this message translates to:
  /// **'платить'**
  String get pays;

  /// No description provided for @balanceWarning.
  ///
  /// In uk, this message translates to:
  /// **'Увага: сума балансів відхиляється від нуля'**
  String get balanceWarning;

  /// No description provided for @analytics.
  ///
  /// In uk, this message translates to:
  /// **'Аналітика'**
  String get analytics;

  /// No description provided for @byCategory.
  ///
  /// In uk, this message translates to:
  /// **'За категоріями'**
  String get byCategory;

  /// No description provided for @byParticipant.
  ///
  /// In uk, this message translates to:
  /// **'За учасниками'**
  String get byParticipant;

  /// No description provided for @dateRange.
  ///
  /// In uk, this message translates to:
  /// **'Діапазон дат'**
  String get dateRange;

  /// No description provided for @from_date.
  ///
  /// In uk, this message translates to:
  /// **'Від'**
  String get from_date;

  /// No description provided for @to_date.
  ///
  /// In uk, this message translates to:
  /// **'До'**
  String get to_date;

  /// No description provided for @allTime.
  ///
  /// In uk, this message translates to:
  /// **'Весь час'**
  String get allTime;

  /// No description provided for @export.
  ///
  /// In uk, this message translates to:
  /// **'Експорт CSV'**
  String get export;

  /// No description provided for @exportDone.
  ///
  /// In uk, this message translates to:
  /// **'Файл CSV готовий'**
  String get exportDone;

  /// No description provided for @delete.
  ///
  /// In uk, this message translates to:
  /// **'Видалити'**
  String get delete;

  /// No description provided for @cancel.
  ///
  /// In uk, this message translates to:
  /// **'Скасувати'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In uk, this message translates to:
  /// **'Зберегти'**
  String get save;

  /// No description provided for @confirm.
  ///
  /// In uk, this message translates to:
  /// **'Підтвердити'**
  String get confirm;

  /// No description provided for @deleted.
  ///
  /// In uk, this message translates to:
  /// **'Видалено'**
  String get deleted;

  /// No description provided for @undo.
  ///
  /// In uk, this message translates to:
  /// **'Скасувати'**
  String get undo;

  /// No description provided for @required.
  ///
  /// In uk, this message translates to:
  /// **'Обов\'язкове поле'**
  String get required;

  /// No description provided for @duplicateGroupName.
  ///
  /// In uk, this message translates to:
  /// **'Група з такою назвою вже існує'**
  String get duplicateGroupName;

  /// No description provided for @noExpenses.
  ///
  /// In uk, this message translates to:
  /// **'Немає витрат'**
  String get noExpenses;

  /// No description provided for @noSettlements.
  ///
  /// In uk, this message translates to:
  /// **'Немає розрахунків'**
  String get noSettlements;

  /// No description provided for @groupSettings.
  ///
  /// In uk, this message translates to:
  /// **'Налаштування групи'**
  String get groupSettings;

  /// No description provided for @participant.
  ///
  /// In uk, this message translates to:
  /// **'Учасник'**
  String get participant;

  /// No description provided for @inactive.
  ///
  /// In uk, this message translates to:
  /// **'(неактивний)'**
  String get inactive;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'uk'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'uk': return AppLocalizationsUk();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
