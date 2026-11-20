// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Ukrainian (`uk`).
class AppLocalizationsUk extends AppLocalizations {
  AppLocalizationsUk([String locale = 'uk']) : super(locale);

  @override
  String get appTitle => 'Кошик';

  @override
  String get groups => 'Групи';

  @override
  String get newGroup => 'Нова група';

  @override
  String get editGroup => 'Редагувати групу';

  @override
  String get deleteGroup => 'Видалити групу';

  @override
  String deleteGroupConfirm(String name) {
    return 'Видалити групу \"$name\"? Всі витрати та учасники будуть видалені.';
  }

  @override
  String get groupName => 'Назва групи';

  @override
  String get currency => 'Символ валюти';

  @override
  String get noGroups => 'Немає груп. Натисніть + щоб створити.';

  @override
  String get totalExpenses => 'Загальні витрати';

  @override
  String get participants => 'Учасники';

  @override
  String get addParticipant => 'Додати учасника';

  @override
  String get editParticipant => 'Редагувати учасника';

  @override
  String get participantName => 'Ім\'я учасника';

  @override
  String get deactivate => 'Деактивувати';

  @override
  String get activate => 'Активувати';

  @override
  String get deleteParticipant => 'Видалити учасника';

  @override
  String get cannotDeleteParticipantHasData =>
      'Неможливо видалити учасника з витратами. Спробуйте деактивувати.';

  @override
  String get duplicateParticipantName => 'Учасник з таким ім\'ям вже існує';

  @override
  String get categories => 'Категорії';

  @override
  String get addCategory => 'Додати категорію';

  @override
  String get editCategory => 'Редагувати категорію';

  @override
  String get categoryName => 'Назва категорії';

  @override
  String get maxCategoriesReached => 'Максимум 10 категорій';

  @override
  String get noCategory => 'Без категорії';

  @override
  String get expenses => 'Витрати';

  @override
  String get addExpense => 'Додати витрату';

  @override
  String get editExpense => 'Редагувати витрату';

  @override
  String get amount => 'Сума';

  @override
  String get payer => 'Платник';

  @override
  String get date => 'Дата';

  @override
  String get comment => 'Коментар';

  @override
  String get category => 'Категорія';

  @override
  String get splitBetween => 'Розподіл витрати';

  @override
  String get splitAll => 'Всі';

  @override
  String get splitBetweenSheetTitle => 'Розподілити між:';

  @override
  String get invalidAmount => 'Введіть коректну суму (> 0)';

  @override
  String get amountHint => 'напр. 300+450 або 250';

  @override
  String get settlements => 'Розрахунки';

  @override
  String get addSettlement => 'Додати розрахунок';

  @override
  String get editSettlement => 'Редагувати розрахунок';

  @override
  String get from => 'Від';

  @override
  String get to => 'Кому';

  @override
  String get samePersonError => 'Відправник і отримувач мають бути різними';

  @override
  String get summary => 'Підсумок';

  @override
  String get totalShared => 'Загальні спільні витрати';

  @override
  String get shareOfEachPerson => 'Частка кожного';

  @override
  String get amountPaid => 'Сплачено';

  @override
  String get rawBalance => 'Баланс (без переказів)';

  @override
  String get transferNet => 'Перекази (нетто)';

  @override
  String get finalBalance => 'Підсумковий баланс';

  @override
  String get settlementInstructions => 'Інструкції розрахунку';

  @override
  String get nothingToSettle => 'Нічого розраховувати';

  @override
  String get pays => 'борг';

  @override
  String get currentlyOwes => 'Актуальний борг';

  @override
  String get balanceWarning => 'Увага: сума балансів відхиляється від нуля';

  @override
  String get analytics => 'Аналітика';

  @override
  String get byCategory => 'За категоріями';

  @override
  String get byParticipant => 'За учасниками';

  @override
  String get dateRange => 'Діапазон дат';

  @override
  String get from_date => 'Від';

  @override
  String get to_date => 'До';

  @override
  String get allTime => 'Весь час';

  @override
  String get export => 'Експортувати (backup)';

  @override
  String get exportDone => 'Файл бекапу готовий';

  @override
  String get importBackup => 'Імпортувати (backup)';

  @override
  String get importDone => 'Групу імпортовано';

  @override
  String get importInvalidFile =>
      'Не вдалося прочитати файл — невірний формат або версія';

  @override
  String get delete => 'Видалити';

  @override
  String get cancel => 'Скасувати';

  @override
  String get save => 'Зберегти';

  @override
  String get confirm => 'Підтвердити';

  @override
  String get deleted => 'Видалено';

  @override
  String get undo => 'Скасувати';

  @override
  String get required => 'Обов\'язкове поле';

  @override
  String get duplicateGroupName => 'Група з такою назвою вже існує';

  @override
  String get noExpenses => 'Немає витрат';

  @override
  String get noSettlements => 'Немає розрахунків';

  @override
  String get noSettlementsHint =>
      'Немає розрахунків.\nНатисніть + щоб зафіксувати погашення боргу.';

  @override
  String get settlementsEmptyExplainer =>
      'Розрахунки фіксують погашення боргів між учасниками. Коли хтось повертає борг — зафіксуйте це тут.';

  @override
  String get createFirstGroupTitle => 'Ласкаво просимо до Кошика!';

  @override
  String get createFirstGroupSubtitle =>
      'Створіть першу групу, щоб відстежувати спільні витрати';

  @override
  String get noCategoriesHint =>
      'Тут можна змінити існуючі категорії,\nдодати нові.';

  @override
  String get onboardingCategoriesHint =>
      'Тут можна змінити існуючі категорії,\nдодати нові.\nАле це можна зробити і згодом.';

  @override
  String get minOneCategoryRequired => 'Має бути хоча б одна категорія';

  @override
  String get groupSettings => 'Налаштування групи';

  @override
  String get participant => 'Учасник';

  @override
  String get inactive => '(неактивний)';

  @override
  String get whoOwesWhom => 'Хто-Кому-Скільки';

  @override
  String get shareTitle => 'Підсумок Кошик';

  @override
  String get latestExpensesShareTitle => 'Останні витрати — Кошик';

  @override
  String get latestExpensesHeading => 'Останні 10 витрат';

  @override
  String get spendingByCategory => 'Витрати за категоріями';

  @override
  String get exitAppTitle => 'Вийти з додатку';

  @override
  String get exitAppConfirm => 'Ви впевнені, що хочете вийти?';

  @override
  String get exitApp => 'Вийти';

  @override
  String get groupArchived => 'Групу архівовано';

  @override
  String get groupUnarchived => 'Групу розархівовано';

  @override
  String get archivedGroups => 'АРХІВ';

  @override
  String get roundingEnabled => 'Заокруглювати суми до цілих';

  @override
  String get nextStep => 'Далі';

  @override
  String get expenseTitle => 'Назва (необов\'язково)';

  @override
  String get noExpensesHint =>
      'Ще немає витрат.\nНатисніть + щоб додати першу.';

  @override
  String get done => 'Готово';

  @override
  String get categoryIcon => 'Іконка (емодзі)';

  @override
  String get categoryColor => 'Колір';

  @override
  String get cannotDeleteCategoryInUse =>
      'Неможливо видалити категорію, що використовується у витратах';

  @override
  String get duplicateCategoryName => 'А вже є така категорія!';

  @override
  String get more => 'Більше';

  @override
  String get theme => 'Тема';

  @override
  String get aboutApp => 'Про додаток';

  @override
  String get onboardingStepGroup => 'Група';

  @override
  String get onboardingStepParticipants => 'Учасники';

  @override
  String get onboardingStepCategories => 'Категорії';

  @override
  String get defaultCategoryAccommodation => 'Проживання';

  @override
  String get defaultCategoryFood => 'Харчування';

  @override
  String get defaultCategoryWork => 'Робота';

  @override
  String get defaultCategoryTransport => 'Транспорт';

  @override
  String get appTitleTagline => 'Кошик — рахує за тебе';

  @override
  String get appDescription =>
      'Кошик — мобільний додаток для спільного обліку витрат у групі. Зручний для подорожей, спільного проживання та командних заходів.\n\n• Створюйте групи з учасниками та категоріями\n• Додавайте групам іконку — емодзі або фото\n• Додавайте витрати з категорією, платником і коментарем\n• Діліть витрату між усіма або лише обраними учасниками\n• Рахуйте прямо в полі суми (напр. 300+450 або 120×3)\n• Підсумок: загальна сума, частка кожного, хто кому скільки винен\n• Розрахунки фіксують погашення боргів між учасниками\n• Кругова діаграма витрат за категоріями\n• Діліться підсумком або останніми витратами як зображенням\n• Зберігайте групу у файл і переносьте на інший телефон\n• Архівуйте завершені групи\n• Працює без інтернету — дані залишаються на вашому пристрої\n• Підтримка світлої та темної теми';

  @override
  String get version => 'Версія';

  @override
  String get language => 'Мова';

  @override
  String get tutorialSkip => 'Розберусь';

  @override
  String get tutorialNext => 'Далі';

  @override
  String get tutorialGroupsFab => 'Натисніть + щоб створити нову групу';

  @override
  String get tutorialGroupsTile => 'створення груп/заходів для обліку витрат';

  @override
  String get tutorialExpensesFab => 'зазначайте витрати групи саме тут';

  @override
  String get tutorialSettlementsFab =>
      'Натисніть + щоб зафіксувати розрахунок між учасниками';

  @override
  String get tutorialSummaryTab => 'аналітика витрат та боргів групи';

  @override
  String get tutorialMoreTab =>
      'Більше — налаштування теми, мови та інформація про додаток';

  @override
  String get tutorialNavExpenses =>
      'Тут відстежуйте всі спільні витрати. Натисніть + щоб додати нову.';

  @override
  String get tutorialNavSummary =>
      'Загальна сума витрат, хто кому винен та розбивка по категоріях.';

  @override
  String get tutorialNavSettlements =>
      'Фіксуйте погашення боргів між учасниками групи.';

  @override
  String get tutorialNavMore =>
      'Налаштування: тема, мова, валюта та інформація про додаток.';

  @override
  String get checkForUpdates => 'Перевірити оновлення';

  @override
  String get upToDate => 'Встановлена остання версія ✓';

  @override
  String get groupIcon => 'Іконка групи';

  @override
  String get groupIconEmoji => 'Емодзі';

  @override
  String get groupIconGallery => 'Фото з галереї';

  @override
  String get groupIconCamera => 'Зробити фото';

  @override
  String get groupIconRemove => 'Прибрати іконку';

  @override
  String get groupIconEmojiHint => 'Або введіть будь-яке емодзі';

  @override
  String get groupIconCropTitle => 'Обрізати фото';

  @override
  String get groupIconError => 'Не вдалося завантажити фото';

  @override
  String splitHintCount(int count, int total) {
    return '$count з $total учасників';
  }

  @override
  String splitHintSemantics(String names) {
    return 'Розподілено між: $names';
  }
}
