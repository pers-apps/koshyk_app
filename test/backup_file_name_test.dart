import 'package:flutter_test/flutter_test.dart';
import 'package:koshyk_app/features/export/export_service.dart';

// REMARKS #144 — Koshyk_BU_HHMM_DDMMYYYY_<first 6 chars of group name>.json
void main() {
  final t = DateTime(2026, 11, 19, 9, 5, 42);

  test('Cyrillic name, zero-padded time and date', () {
    expect(backupFileName('Подорож Карпати', t), 'Koshyk_BU_0905_19112026_Подоро.json');
  });
  test('name shorter than 6 chars is used in full', () {
    expect(backupFileName('Trip', t), 'Koshyk_BU_0905_19112026_Trip.json');
  });
  test('spaces and invalid chars become _', () {
    expect(backupFileName('A/B: c', t), 'Koshyk_BU_0905_19112026_A_B__c.json');
  });
  test('leading/trailing junk trimmed', () {
    expect(backupFileName('  Rome  ', t), 'Koshyk_BU_0905_19112026_Rome.json');
  });
  test('no usable chars → no suffix', () {
    expect(backupFileName('???', t), 'Koshyk_BU_0905_19112026.json');
  });
  test('afternoon time uses 24h', () {
    expect(backupFileName('Trip', DateTime(2026, 1, 3, 17, 30)), 'Koshyk_BU_1730_03012026_Trip.json');
  });
}
