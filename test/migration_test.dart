import 'package:drift_dev/api/migrations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:koshyk_app/core/db/database.dart';

// TODO(v2): Fill in generated schema snapshots once the v2 schema is finalized.
//
// How to generate snapshots:
//   dart run drift_dev schema dump lib/core/db/database.dart test/drift_schemas/
//   dart run drift_dev schema steps test/drift_schemas/ lib/core/db/schema_versions.dart
//
// Then replace the TODOs below with:
//   final schemaV1 = await SchemaVerifier(GeneratedHelper()).schemaAt(1);
//   final schemaV2 = await SchemaVerifier(GeneratedHelper()).schemaAt(2);
//   await verifier.migrateAndValidate(db, 2);

void main() {
  late SchemaVerifier verifier;

  setUpAll(() {
    // TODO(v2): replace GeneratedHelper() with the actual generated helper
    // from lib/core/db/schema_versions.dart after running drift_dev schema steps.
    // verifier = SchemaVerifier(GeneratedHelper());
  });

  test('TODO: v1 → v2 migration is valid', () async {
    // TODO(v2): implement once schema v2 is defined.
    //
    // Example:
    //   final connection = await verifier.startAt(1);
    //   final db = AppDatabase(connection);
    //   await verifier.migrateAndValidate(db, 2);
    //   await db.close();
  });

  test('TODO: database passes verifySelf on current schema', () async {
    // TODO(v2): uncomment after schema_versions.dart is generated.
    //
    //   await verifier.verifySelf(AppDatabase());
  });
}
