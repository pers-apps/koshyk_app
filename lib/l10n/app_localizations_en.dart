// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Koshyk';

  @override
  String get groups => 'Groups';

  @override
  String get newGroup => 'New Group';

  @override
  String get editGroup => 'Edit Group';

  @override
  String get deleteGroup => 'Delete Group';

  @override
  String deleteGroupConfirm(String name) {
    return 'Delete group \"$name\"? All expenses and participants will be deleted.';
  }

  @override
  String get groupName => 'Group name';

  @override
  String get currency => 'Currency symbol';

  @override
  String get noGroups => 'No groups. Tap + to create one.';

  @override
  String get totalExpenses => 'Total expenses';

  @override
  String get participants => 'Participants';

  @override
  String get addParticipant => 'Add participant';

  @override
  String get editParticipant => 'Edit participant';

  @override
  String get participantName => 'Participant name';

  @override
  String get deactivate => 'Deactivate';

  @override
  String get activate => 'Activate';

  @override
  String get deleteParticipant => 'Delete participant';

  @override
  String get cannotDeleteParticipantHasData => 'Cannot delete participant with expenses. Try deactivating instead.';

  @override
  String get duplicateParticipantName => 'A participant with this name already exists';

  @override
  String get categories => 'Categories';

  @override
  String get addCategory => 'Add category';

  @override
  String get editCategory => 'Edit category';

  @override
  String get categoryName => 'Category name';

  @override
  String get maxCategoriesReached => 'Maximum 10 categories';

  @override
  String get noCategory => 'No category';

  @override
  String get expenses => 'Expenses';

  @override
  String get addExpense => 'Add expense';

  @override
  String get editExpense => 'Edit expense';

  @override
  String get amount => 'Amount';

  @override
  String get payer => 'Payer';

  @override
  String get date => 'Date';

  @override
  String get comment => 'Comment';

  @override
  String get category => 'Category';

  @override
  String get invalidAmount => 'Enter a valid amount (> 0)';

  @override
  String get amountHint => 'e.g. 300+450 or 250';

  @override
  String get settlements => 'Settlements';

  @override
  String get addSettlement => 'Add settlement';

  @override
  String get editSettlement => 'Edit settlement';

  @override
  String get from => 'From';

  @override
  String get to => 'To';

  @override
  String get samePersonError => 'From and To must be different people';

  @override
  String get summary => 'Summary';

  @override
  String get totalShared => 'Total shared expenses';

  @override
  String get equalShare => 'Equal share';

  @override
  String get amountPaid => 'Amount paid';

  @override
  String get rawBalance => 'Raw balance (excl. transfers)';

  @override
  String get transferNet => 'Transfers (net)';

  @override
  String get finalBalance => 'Final balance';

  @override
  String get settlementInstructions => 'Settlement instructions';

  @override
  String get nothingToSettle => 'Nothing to settle';

  @override
  String get pays => 'pays';

  @override
  String get balanceWarning => 'Warning: sum of balances deviates from zero';

  @override
  String get analytics => 'Analytics';

  @override
  String get byCategory => 'By category';

  @override
  String get byParticipant => 'By participant';

  @override
  String get dateRange => 'Date range';

  @override
  String get from_date => 'From';

  @override
  String get to_date => 'To';

  @override
  String get allTime => 'All time';

  @override
  String get export => 'Export CSV';

  @override
  String get exportDone => 'CSV file ready';

  @override
  String get delete => 'Delete';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get confirm => 'Confirm';

  @override
  String get deleted => 'Deleted';

  @override
  String get undo => 'Undo';

  @override
  String get required => 'Required field';

  @override
  String get duplicateGroupName => 'A group with this name already exists';

  @override
  String get noExpenses => 'No expenses';

  @override
  String get noSettlements => 'No settlements';

  @override
  String get groupSettings => 'Group settings';

  @override
  String get participant => 'Participant';

  @override
  String get inactive => '(inactive)';
}
