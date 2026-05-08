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
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

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
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('uk'),
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
  /// **'борг'**
  String get pays;

  /// No description provided for @currentlyOwes.
  ///
  /// In uk, this message translates to:
  /// **'Актуальний борг'**
  String get currentlyOwes;

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

  /// No description provided for @noSettlementsHint.
  ///
  /// In uk, this message translates to:
  /// **'Немає розрахунків.\nНатисніть + щоб зафіксувати погашення боргу.'**
  String get noSettlementsHint;

  /// No description provided for @settlementsEmptyExplainer.
  ///
  /// In uk, this message translates to:
  /// **'Розрахунки фіксують погашення боргів між учасниками. Коли хтось повертає борг — зафіксуйте це тут.'**
  String get settlementsEmptyExplainer;

  /// No description provided for @createFirstGroupTitle.
  ///
  /// In uk, this message translates to:
  /// **'Ласкаво просимо до Кошика!'**
  String get createFirstGroupTitle;

  /// No description provided for @createFirstGroupSubtitle.
  ///
  /// In uk, this message translates to:
  /// **'Створіть першу групу, щоб відстежувати спільні витрати'**
  String get createFirstGroupSubtitle;

  /// No description provided for @noCategoriesHint.
  ///
  /// In uk, this message translates to:
  /// **'Тут можна змінити існуючі категорії,\nдодати нові.'**
  String get noCategoriesHint;

  /// No description provided for @onboardingCategoriesHint.
  ///
  /// In uk, this message translates to:
  /// **'Тут можна змінити існуючі категорії,\nдодати нові.\nАле це можна зробити і згодом.'**
  String get onboardingCategoriesHint;

  /// No description provided for @minOneCategoryRequired.
  ///
  /// In uk, this message translates to:
  /// **'Має бути хоча б одна категорія'**
  String get minOneCategoryRequired;

  /// No description provided for @equalSharingInfo.
  ///
  /// In uk, this message translates to:
  /// **'Витрати діляться порівну між учасниками'**
  String get equalSharingInfo;

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

  /// No description provided for @whoOwesWhom.
  ///
  /// In uk, this message translates to:
  /// **'Хто-Кому-Скільки'**
  String get whoOwesWhom;

  /// No description provided for @shareTitle.
  ///
  /// In uk, this message translates to:
  /// **'Підсумок Кошик'**
  String get shareTitle;

  /// No description provided for @spendingByCategory.
  ///
  /// In uk, this message translates to:
  /// **'Витрати за категоріями'**
  String get spendingByCategory;

  /// No description provided for @exitAppTitle.
  ///
  /// In uk, this message translates to:
  /// **'Вийти з додатку'**
  String get exitAppTitle;

  /// No description provided for @exitAppConfirm.
  ///
  /// In uk, this message translates to:
  /// **'Ви впевнені, що хочете вийти?'**
  String get exitAppConfirm;

  /// No description provided for @exitApp.
  ///
  /// In uk, this message translates to:
  /// **'Вийти'**
  String get exitApp;

  /// No description provided for @groupArchived.
  ///
  /// In uk, this message translates to:
  /// **'Групу архівовано'**
  String get groupArchived;

  /// No description provided for @groupUnarchived.
  ///
  /// In uk, this message translates to:
  /// **'Групу розархівовано'**
  String get groupUnarchived;

  /// No description provided for @archivedGroups.
  ///
  /// In uk, this message translates to:
  /// **'АРХІВ'**
  String get archivedGroups;

  /// No description provided for @roundingEnabled.
  ///
  /// In uk, this message translates to:
  /// **'Заокруглювати суми до цілих'**
  String get roundingEnabled;

  /// No description provided for @nextStep.
  ///
  /// In uk, this message translates to:
  /// **'Далі'**
  String get nextStep;

  /// No description provided for @expenseTitle.
  ///
  /// In uk, this message translates to:
  /// **'Назва (необов\'язково)'**
  String get expenseTitle;

  /// No description provided for @noExpensesHint.
  ///
  /// In uk, this message translates to:
  /// **'Ще немає витрат.\nНатисніть + щоб додати першу.'**
  String get noExpensesHint;

  /// No description provided for @done.
  ///
  /// In uk, this message translates to:
  /// **'Готово'**
  String get done;

  /// No description provided for @categoryIcon.
  ///
  /// In uk, this message translates to:
  /// **'Іконка (емодзі)'**
  String get categoryIcon;

  /// No description provided for @categoryColor.
  ///
  /// In uk, this message translates to:
  /// **'Колір'**
  String get categoryColor;

  /// No description provided for @cannotDeleteCategoryInUse.
  ///
  /// In uk, this message translates to:
  /// **'Неможливо видалити категорію, що використовується у витратах'**
  String get cannotDeleteCategoryInUse;

  /// No description provided for @duplicateCategoryName.
  ///
  /// In uk, this message translates to:
  /// **'А вже є така категорія!'**
  String get duplicateCategoryName;

  /// No description provided for @more.
  ///
  /// In uk, this message translates to:
  /// **'Більше'**
  String get more;

  /// No description provided for @theme.
  ///
  /// In uk, this message translates to:
  /// **'Тема'**
  String get theme;

  /// No description provided for @aboutApp.
  ///
  /// In uk, this message translates to:
  /// **'Про додаток'**
  String get aboutApp;

  /// No description provided for @onboardingStepGroup.
  ///
  /// In uk, this message translates to:
  /// **'Група'**
  String get onboardingStepGroup;

  /// No description provided for @onboardingStepParticipants.
  ///
  /// In uk, this message translates to:
  /// **'Учасники'**
  String get onboardingStepParticipants;

  /// No description provided for @onboardingStepCategories.
  ///
  /// In uk, this message translates to:
  /// **'Категорії'**
  String get onboardingStepCategories;

  /// No description provided for @defaultCategoryAccommodation.
  ///
  /// In uk, this message translates to:
  /// **'Проживання'**
  String get defaultCategoryAccommodation;

  /// No description provided for @defaultCategoryFood.
  ///
  /// In uk, this message translates to:
  /// **'Харчування'**
  String get defaultCategoryFood;

  /// No description provided for @defaultCategoryWork.
  ///
  /// In uk, this message translates to:
  /// **'Транспорт'**
  String get defaultCategoryWork;

  /// No description provided for @appTitleTagline.
  ///
  /// In uk, this message translates to:
  /// **'Кошик — рахує за тебе'**
  String get appTitleTagline;

  /// No description provided for @appDescription.
  ///
  /// In uk, this message translates to:
  /// **'Кошик — мобільний додаток для спільного обліку витрат у групі. Зручний для подорожей, спільного проживання та командних заходів.\n\n• Створюйте групи учасників\n• Додавайте витрати з категоріями та платником\n• Підсумок: загальна сума, рівна частка, хто кому скільки винен\n• Розрахунки фіксують погашення боргів між учасниками\n• Pie-діаграма витрат за категоріями\n• Підтримка світлої та темної теми'**
  String get appDescription;

  /// No description provided for @version.
  ///
  /// In uk, this message translates to:
  /// **'Версія'**
  String get version;

  /// No description provided for @language.
  ///
  /// In uk, this message translates to:
  /// **'Мова'**
  String get language;

  /// No description provided for @tutorialSkip.
  ///
  /// In uk, this message translates to:
  /// **'Розберусь'**
  String get tutorialSkip;

  /// No description provided for @tutorialNext.
  ///
  /// In uk, this message translates to:
  /// **'Далі'**
  String get tutorialNext;

  /// No description provided for @tutorialGroupsFab.
  ///
  /// In uk, this message translates to:
  /// **'Натисніть + щоб створити нову групу'**
  String get tutorialGroupsFab;

  /// No description provided for @tutorialGroupsTile.
  ///
  /// In uk, this message translates to:
  /// **'створення груп/заходів для обліку витрат'**
  String get tutorialGroupsTile;

  /// No description provided for @tutorialExpensesFab.
  ///
  /// In uk, this message translates to:
  /// **'зазначайте витрати групи саме тут'**
  String get tutorialExpensesFab;

  /// No description provided for @tutorialSettlementsFab.
  ///
  /// In uk, this message translates to:
  /// **'Натисніть + щоб зафіксувати розрахунок між учасниками'**
  String get tutorialSettlementsFab;

  /// No description provided for @tutorialSummaryTab.
  ///
  /// In uk, this message translates to:
  /// **'аналітика витрат та боргів групи'**
  String get tutorialSummaryTab;

  /// No description provided for @tutorialMoreTab.
  ///
  /// In uk, this message translates to:
  /// **'Більше — налаштування теми, мови та інформація про додаток'**
  String get tutorialMoreTab;

  /// No description provided for @tutorialNavExpenses.
  ///
  /// In uk, this message translates to:
  /// **'Тут відстежуйте всі спільні витрати. Натисніть + щоб додати нову.'**
  String get tutorialNavExpenses;

  /// No description provided for @tutorialNavSummary.
  ///
  /// In uk, this message translates to:
  /// **'Загальна сума витрат, хто кому винен та розбивка по категоріях.'**
  String get tutorialNavSummary;

  /// No description provided for @tutorialNavSettlements.
  ///
  /// In uk, this message translates to:
  /// **'Фіксуйте погашення боргів між учасниками групи.'**
  String get tutorialNavSettlements;

  /// No description provided for @tutorialNavMore.
  ///
  /// In uk, this message translates to:
  /// **'Налаштування: тема, мова, валюта та інформація про додаток.'**
  String get tutorialNavMore;

  /// No description provided for @checkForUpdates.
  ///
  /// In uk, this message translates to:
  /// **'Перевірити оновлення'**
  String get checkForUpdates;

  /// No description provided for @upToDate.
  ///
  /// In uk, this message translates to:
  /// **'Встановлена остання версія ✓'**
  String get upToDate;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'uk'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'uk':
      return AppLocalizationsUk();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
