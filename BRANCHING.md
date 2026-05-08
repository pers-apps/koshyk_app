# Branching Strategy

## Branch model

| Branch | Purpose | Base |
|---|---|---|
| `main` | Production — matches Play Store release | — |
| `develop` | v2 development line | `main` |
| `feature/*` | New v2 features | `develop` |
| `fix/*` | Production hotfixes | `main` |

## Rules

- `main` is always releasable. Never commit directly; merge via PR only.
- `develop` is the integration branch for v2. Feature branches merge here first.
- Every `fix/*` merged into `main` **must** also be merged forward into `develop` immediately to avoid divergence.
- Tags (`v1.x.x`, `v2.x.x`) are placed on `main` commits only.

## Workflow

### New v2 feature
```
git checkout develop
git checkout -b feature/my-feature
# ... work ...
git push -u origin feature/my-feature
# open PR → develop
```

### Production hotfix
```
git checkout main
git checkout -b fix/issue-description
# ... fix ...
# open PR → main
# after merge: open second PR fix/issue-description → develop
```

### Release
```
# on main after PR merge:
git tag vX.Y.Z
git push origin vX.Y.Z
```

## iOS flavors — manual Xcode steps

Flutter flavors map to Xcode schemes and build configurations. These edits must be done manually in Xcode (scripting `.xcodeproj` is fragile):

1. **Duplicate the scheme**
   - Xcode → Product → Scheme → Manage Schemes
   - Duplicate `Runner` → rename to `Runner-dev`
   - Mark `Runner-dev` as shared (so it commits to git)

2. **Add build configurations**
   - Project settings → Info tab → Configurations
   - Duplicate `Debug` → rename to `Debug-dev`
   - Duplicate `Release` → rename to `Release-dev`
   - Duplicate `Profile` → rename to `Profile-dev`

3. **Assign configurations to scheme**
   - Edit `Runner-dev` scheme
   - For each action (Run, Test, Archive…) select the `-dev` configuration

4. **Set bundle ID suffix for dev**
   - Target → Runner → Build Settings → filter "Product Bundle Identifier"
   - Set `Debug-dev` and `Release-dev` rows to `com.koshyk.dev` (append `.dev`)

5. **Flutter build command for dev iOS**
   ```
   flutter run --flavor dev -t lib/main_dev.dart
   flutter build ipa --flavor dev -t lib/main_dev.dart
   ```

6. **Flutter build command for prod iOS**
   ```
   flutter build ipa --flavor prod -t lib/main_prod.dart --release
   ```
