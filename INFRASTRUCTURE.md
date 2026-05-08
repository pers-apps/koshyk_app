# Koshyk App — Infrastructure Documentation

**Date:** 2026-04-11  
**Server:** 173.212.212.150 (Ubuntu 24.04)  
**User:** deployer  

---

## Overview

Koshyk is a Flutter-based multi-platform Expense Splitter application. The server acts as a **CI/CD build host** — it runs a self-hosted GitHub Actions Runner that builds Android APKs and publishes GitHub Releases when a version tag is pushed.

---

## Application

| Property        | Value                                                    |
|-----------------|----------------------------------------------------------|
| Name            | Koshyk Expense Splitter                                  |
| Framework       | Flutter / Dart                                           |
| Repository      | https://github.com/gviacheslav-sketch/koshyk_app         |
| Branch          | `main`                                                   |
| App ID          | `com.grygoriev.koshyk`                                   |
| Source path     | `/home/deployer/koshyk_app/`                             |
| Database        | SQLite via Drift ORM (db name: `koshyk`)                 |
| Localizations   | Ukrainian (primary), English                             |

### Supported Platforms

- Android (API 26+)
- iOS
- Web (WASM SQLite workers)
- Linux, macOS, Windows

### Key Dependencies

| Package                 | Version   | Purpose                  |
|-------------------------|-----------|--------------------------|
| flutter_riverpod        | ^2.5.1    | State management         |
| go_router               | ^14.6.2   | Navigation/routing       |
| drift                   | ^2.22.0   | SQLite ORM               |
| sqlite3_flutter_libs    | ^0.5.0    | SQLite native bindings   |
| fl_chart                | ^0.69.0   | Analytics charts         |
| intl                    | ^0.19.0   | i18n / localization      |
| share_plus              | ^10.1.4   | File/data sharing        |
| math_expressions        | ^2.6.0    | Expression evaluation    |

---

## CI/CD Pipeline

### Trigger

Builds are triggered by pushing a version tag to GitHub:

```bash
git tag v1.0.0
git push origin v1.0.0
```

### Workflow

**File:** `/home/deployer/koshyk_app/.github/workflows/build.yml`

1. Tag pushed → GitHub dispatches job to self-hosted runner `koshyk-server`
2. Runner checks out the repository into `_work/koshyk_app/koshyk_app/`
3. Flutter builds a debug Android APK
4. A GitHub Release is created and the APK is attached
5. A Telegram notification is sent on completion

### Self-Hosted Runner

| Property         | Value                                                                     |
|------------------|---------------------------------------------------------------------------|
| Runner name      | `koshyk-server`                                                           |
| Agent ID         | 2                                                                         |
| Runner version   | 2.333.1                                                                   |
| Pool             | Default                                                                   |
| Install path     | `/home/deployer/actions-runner/`                                          |
| Work directory   | `/home/deployer/actions-runner/_work/`                                    |
| GitHub URL       | https://github.com/gviacheslav-sketch/koshyk_app                         |

**Systemd service:**

```
actions.runner.gviacheslav-sketch-koshyk_app.koshyk-server.service
```

- Started: 2026-04-09 06:54:03 CEST
- Status: **active (running)**
- Memory: ~115 MB
- Runs as: `deployer`
- Entry point: `/home/deployer/actions-runner/runsvc.sh`

**Manage the runner:**

```bash
# Status
sudo systemctl status actions.runner.gviacheslav-sketch-koshyk_app.koshyk-server

# Restart
sudo systemctl restart actions.runner.gviacheslav-sketch-koshyk_app.koshyk-server

# Logs
journalctl -u actions.runner.gviacheslav-sketch-koshyk_app.koshyk-server -f
```

---

## Server Environment

### Operating System

| Property   | Value          |
|------------|----------------|
| OS         | Ubuntu 24.04   |
| User       | deployer       |
| Sudo       | passwordless   |

### SSH

| Property       | Value         |
|----------------|---------------|
| Port           | 2222          |
| Authentication | Key-only      |
| Port 22        | UFW DENY      |

### Firewall (UFW)

| Port  | Protocol | Status  | Purpose              |
|-------|----------|---------|----------------------|
| 2222  | TCP      | ALLOW   | SSH                  |
| 80    | TCP      | ALLOW   | HTTP                 |
| 443   | TCP      | ALLOW   | HTTPS                |
| 8080  | TCP      | ALLOW   | App / development    |
| 22    | TCP      | DENY    | Old SSH (blocked)    |

### Intrusion Prevention (Fail2Ban)

- Active on SSH (port 2222)
- Bans IPs after repeated failed login attempts

### Installed Toolchains

| Tool           | Path                          | Notes                     |
|----------------|-------------------------------|---------------------------|
| Flutter SDK    | `/home/deployer/flutter/`     | Used by CI builds         |
| Android SDK    | `/home/deployer/android-sdk/` | Required for APK builds   |
| Gradle         | 8.7.0                         | Via Gradle wrapper        |
| Kotlin         | 1.8.22                        | Android plugin dependency |
| Gradle cache   | `/home/deployer/.gradle/`     |                           |
| Pub cache      | `/home/deployer/.pub-cache/`  |                           |

---

## Additional Server Services

| Service       | Location                       | Purpose                             |
|---------------|--------------------------------|-------------------------------------|
| OpenClaw      | `~/.openclaw/`                 | Automation gateway (Telegram)       |
| Voice Claude  | `/home/deployer/voice-claude/` | Voice-enabled Claude Telegram bot   |

---

## Feature Modules

```
lib/
├── core/
│   ├── db/          # Drift SQLite database layer
│   ├── router/      # go_router navigation
│   ├── theme/       # Material design theme
│   └── utils/       # Money helpers, expression parser
└── features/
    ├── analytics/   # Spend analytics & charts
    ├── categories/  # Expense categories
    ├── expenses/    # Expense CRUD
    ├── export/      # CSV export
    ├── groups/      # Group management
    ├── participants/# Participant management
    ├── settlements/ # Debt settlement calculations
    └── summary/     # Summary statistics
```

---

## Repository Access

| Property   | Value                                         |
|------------|-----------------------------------------------|
| Remote     | https://github.com/gviacheslav-sketch/koshyk_app |
| Git user   | gviacheslav-sketch (G.Vyacheslav@gmail.com)   |
| Local path | `/home/deployer/koshyk_app/`                  |

---

## Quick Reference — Common Tasks

```bash
# Check runner status
sudo systemctl status actions.runner.gviacheslav-sketch-koshyk_app.koshyk-server

# Trigger a release build (from local machine)
git tag v1.x.x && git push origin v1.x.x

# Build APK manually on server
cd /home/deployer/koshyk_app
/home/deployer/flutter/bin/flutter build apk --debug

# View recent CI logs
journalctl -u actions.runner.gviacheslav-sketch-koshyk_app.koshyk-server --since "1 hour ago"

# Check UFW rules
sudo ufw status verbose
```
