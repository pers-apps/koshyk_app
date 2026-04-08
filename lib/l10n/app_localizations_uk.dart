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
  String get cannotDeleteParticipantHasData => 'Неможливо видалити учасника з витратами. Спробуйте деактивувати.';

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
  String get equalShare => 'Рівна частка';

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
  String get pays => 'платить';

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
  String get export => 'Експорт CSV';

  @override
  String get exportDone => 'Файл CSV готовий';

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
  String get groupSettings => 'Налаштування групи';

  @override
  String get participant => 'Учасник';

  @override
  String get inactive => '(неактивний)';
}
