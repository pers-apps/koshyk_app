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
  String get cannotDeleteParticipantHasData =>
      'Cannot delete participant with expenses. Try deactivating instead.';

  @override
  String get duplicateParticipantName =>
      'A participant with this name already exists';

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
  String get splitBetween => 'Split between';

  @override
  String get splitAll => 'All';

  @override
  String get splitBetweenSheetTitle => 'Split between:';

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
  String get shareOfEachPerson => 'Each person\'s share';

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
  String get pays => 'debt';

  @override
  String get currentlyOwes => 'Current debt';

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
  String get export => 'Export (backup)';

  @override
  String get exportDone => 'Backup file ready';

  @override
  String get importBackup => 'Import (backup)';

  @override
  String get importDone => 'Group imported';

  @override
  String get importInvalidFile =>
      'Couldn\'t read file — invalid format or version';

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
  String get noSettlementsHint =>
      'No settlements yet.\nTap + to record a debt repayment.';

  @override
  String get settlementsEmptyExplainer =>
      'Settlements record debt repayments between group members. When someone pays back what they owe — record it here.';

  @override
  String get createFirstGroupTitle => 'Welcome to Koshyk!';

  @override
  String get createFirstGroupSubtitle =>
      'Create your first group to start tracking shared expenses';

  @override
  String get noCategoriesHint =>
      'Here you can change current categories\nor add new ones.';

  @override
  String get onboardingCategoriesHint =>
      'Here you can change default categories,\nadd your own.\nThat can be done later too.';

  @override
  String get minOneCategoryRequired => 'At least one category must remain';

  @override
  String get groupSettings => 'Group settings';

  @override
  String get participant => 'Participant';

  @override
  String get inactive => '(inactive)';

  @override
  String get whoOwesWhom => 'Who Owes Whom';

  @override
  String get shareTitle => 'Koshyk Summary';

  @override
  String get latestExpensesShareTitle => 'Koshyk — Recent expenses';

  @override
  String get latestExpensesHeading => 'Last 10 expenses';

  @override
  String get spendingByCategory => 'Spending by category';

  @override
  String get exitAppTitle => 'Exit app';

  @override
  String get exitAppConfirm => 'Are you sure you want to exit?';

  @override
  String get exitApp => 'Exit';

  @override
  String get groupArchived => 'Group archived';

  @override
  String get groupUnarchived => 'Group unarchived';

  @override
  String get archivedGroups => 'ARCHIVED';

  @override
  String get roundingEnabled => 'Round amounts to whole numbers';

  @override
  String get nextStep => 'Next';

  @override
  String get expenseTitle => 'Title (optional)';

  @override
  String get noExpensesHint => 'No expenses yet.\nTap + to add the first one.';

  @override
  String get done => 'Done';

  @override
  String get categoryIcon => 'Icon (emoji)';

  @override
  String get categoryColor => 'Color';

  @override
  String get cannotDeleteCategoryInUse =>
      'Cannot delete a category that is used in expenses';

  @override
  String get duplicateCategoryName => 'That\'s what we already have!';

  @override
  String get more => 'More';

  @override
  String get theme => 'Theme';

  @override
  String get aboutApp => 'About App';

  @override
  String get onboardingStepGroup => 'Group';

  @override
  String get onboardingStepParticipants => 'Members';

  @override
  String get onboardingStepCategories => 'Categories';

  @override
  String get defaultCategoryAccommodation => 'Accommodation';

  @override
  String get defaultCategoryFood => 'Food';

  @override
  String get defaultCategoryWork => 'Work';

  @override
  String get defaultCategoryTransport => 'Transport';

  @override
  String get appTitleTagline => 'Koshyk — does the math for you';

  @override
  String get appDescription =>
      'Koshyk is a mobile app for shared expense tracking in a group. Perfect for trips, shared living, and team events.\n\n• Create groups with participants and categories\n• Personalise groups with an emoji or photo\n• Add expenses with category, payer and comment\n• Split an expense among everyone or only selected participants\n• Calculate right in the amount field (e.g. 300+450 or 120×3)\n• Summary: total amount, each person\'s share, who owes whom\n• Settlements record debt repayments between members\n• Pie chart of expenses by category\n• Share the summary or latest expenses as an image\n• Back up a group to a file and move it to another phone\n• Archive finished groups\n• Works offline — your data stays on your device\n• Light and dark theme support';

  @override
  String get version => 'Version';

  @override
  String get language => 'Language';

  @override
  String get tutorialSkip => 'Got it';

  @override
  String get tutorialNext => 'Next';

  @override
  String get tutorialGroupsFab => 'Tap + to create a new group';

  @override
  String get tutorialGroupsTile =>
      'Create groups or events to track shared expenses';

  @override
  String get tutorialExpensesFab => 'Add your group expenses right here';

  @override
  String get tutorialSettlementsFab =>
      'Tap + to record a settlement between members';

  @override
  String get tutorialSummaryTab => 'Expense analytics and group debts';

  @override
  String get tutorialMoreTab => 'More — theme, language settings and app info';

  @override
  String get tutorialNavExpenses =>
      'Track all shared expenses here. Tap + to add a new one.';

  @override
  String get tutorialNavSummary =>
      'See total spending, who owes whom, and a breakdown by category.';

  @override
  String get tutorialNavSettlements =>
      'Record debt repayments between group members.';

  @override
  String get tutorialNavMore =>
      'Settings: theme, language, currency and app info.';

  @override
  String get checkForUpdates => 'Check for updates';

  @override
  String get upToDate => 'You have the latest version ✓';

  @override
  String get groupIcon => 'Group icon';

  @override
  String get groupIconEmoji => 'Emoji';

  @override
  String get groupIconGallery => 'Photo from gallery';

  @override
  String get groupIconCamera => 'Take a photo';

  @override
  String get groupIconRemove => 'Remove icon';

  @override
  String get groupIconEmojiHint => 'Or type any emoji';

  @override
  String get groupIconCropTitle => 'Crop photo';

  @override
  String get groupIconError => 'Could not load the photo';

  @override
  String splitHintCount(int count, int total) {
    return '$count of $total participants';
  }

  @override
  String splitHintSemantics(String names) {
    return 'Split between: $names';
  }
}
