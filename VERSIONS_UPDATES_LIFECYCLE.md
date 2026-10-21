# Chey Ngar — Version Update Lifecycle Guide

> မြန်မာဘာသာဖြင့် ရေးသားထားသော GitHub Release ထုတ်ပြန်ရေး နှင့် Auto-Update Feature အသုံးပြုနည်း လမ်းညွှန်

---

## ၁. အကျဉ်းချုပ် (Overview)

Chey Ngar App တွင် Auto-Update System ကို အောက်ပါ Package များဖြင့် တည်ဆောက်ထားသည်—

| Package | ရည်ရွယ်ချက် |
|---|---|
| `package_info_plus` | Device ပေါ်ရှိ လက်ရှိ APK version ကို dynamic ဖတ်ရန် |
| `http` | GitHub Releases API မှ version info ဆွဲယူရန် |
| `ota_update` | APK ကို Background ဒေါင်းလုဒ်ပြီး Installer မှတဆင့် Update လုပ်ရန် |

**GitHub Repo:** `https://github.com/thanwannahtun/CheyNgar-App`

---

## ၂. Configuration Values

[`lib/main.dart`](lib/main.dart) တွင် အောက်ပါ Config သတ်မှတ်ထားသည်—

```dart
UpdateConfig(
  githubOwner: 'thanwannahtun',   // GitHub username
  githubRepo: 'CheyNgar-App',      // Repository name (exact case!)
  destinationFilename: 'CheyNgar-latest.apk',  // ဒေါင်းလုဒ်ဆင်းသော ဖိုင်အမည်
)
```

**GitHub API Endpoint (Auto-generated):**
```
https://api.github.com/repos/thanwannahtun/CheyNgar-App/releases/latest
```

---

## ၃. Version Update Lifecycle Flow

```
App Start
    │
    ▼
AppUpdateCubit.init()
    │
    ├─► package_info_plus မှ လက်ရှိ version ဖတ်
    │       → state.currentVersion = "1.0.1+1"
    │
    └─► Last check ≥ 7 ရက် ဖြစ်လျှင်...
            └─► GitHub API → Latest Release check (silent, background)
                    │
                    ├─► hasUpdate == true  → Badge ပေါ်လာ (footer တွင်)
                    └─► hasUpdate == false → သာမန် version ပြ
```

```
User ► Footer Version တို့ (Manual Check)
    │
    ▼
AppUpdateCubit.checkForUpdates(force: true)
    │
    ├─► Checking... → Footer တွင် spinner ပေါ်
    │
    ├─► Update Available → UpdateDialog ပွင့်
    │       │
    │       └─► "Update Now" နှိပ် → startDownloadAndInstall()
    │               │
    │               ├─► Downloading 0%...100% (progress bar)
    │               ├─► Installing... (OS Installer ပေါ်)
    │               └─► Done! (Dialog ပိတ်)
    │
    ├─► Up to Date → Snackbar: "Version X.X.X သည် နောက်ဆုံး version"
    └─► Error      → Snackbar: Error message (red background)
```

---

## ၄. GitHub Release ထုတ်ပြန်နည်း (Step-by-Step)

### Step 1 — `pubspec.yaml` Version တင်ရန်

```yaml
version: 1.0.2+2    # format: major.minor.patch+buildNumber
```

> `1.0.2` = versionName (GitHub tag တွင် ယှဉ်တွဲ)  
> `+2` = buildNumber (Google Play / Internal tracking)

### Step 2 — Release APK Build လုပ်ရန်

```bash
flutter build apk --release
```

APK ဖိုင်တည်နေရာ:
```
build\app\outputs\flutter-apk\app-release.apk
```

### Step 3 — APK ဖိုင် Rename လုပ်ရန်

```
app-release.apk  →  CheyNgar-latest.apk
```

> ⚠️ Filename သည် `destinationFilename` နှင့် ကိုက်ညီရမည်! (Case Sensitive)

### Step 4 — GitHub Release ဖန်တီးရန်

1. GitHub ► `CheyNgar-App` Repo ► **Releases** ► **Draft a new release**
2. **Tag version:** `v1.0.2` *(pubspec version နှင့် ကိုက်ညီရမည်)*
3. **Release title:** `Chey Ngar v1.0.2`
4. **Description:** Release notes (Markdown format ရေးနိုင်သည် — App တွင် ပြလိမ့်မည်)
5. **Upload APK:** `CheyNgar-latest.apk` ဖိုင် ထည့်ပါ
6. ✅ **Publish release**

### Step 5 — App တွင် Test လုပ်ရန်

1. ပြောင်းမထားသော **ဟောင်းသော version** APK ကို Device တွင် Install ပြုလုပ်ပါ
2. App ဖွင့်ပြီး Footer ရှိ version number ကို **တို့** (manual check)
3. Update Dialog ပေါ်လာလျှင် **"Update Now"** နှိပ်
4. Download progress (0%→100%) မြင်ရမည်
5. OS Installer ပေါ်ပြီး Install လုပ်ပါ
6. Update ပြီးစီးမည်!

---

## ၅. Code Architecture (Clean & Decoupled)

```
lib/
├── core/update/                    # ← Business Logic Module (Project-agnostic)
│   ├── models/
│   │   ├── app_version_info.dart   # Installed app version data
│   │   ├── update_config.dart      # GitHub config (owner, repo, interval)
│   │   ├── update_info.dart        # GitHub Release metadata
│   │   ├── update_check_result.dart
│   │   └── update_progress.dart    # Download/install progress
│   ├── services/
│   │   ├── app_update_service_interface.dart  # ← Public API Contract
│   │   ├── github_app_update_service.dart     # GitHub implementation
│   │   ├── version_comparator.dart            # Semver comparison
│   │   ├── update_storage.dart                # Storage interface
│   │   └── repository_update_storage.dart     # Pluggable storage adapter
│   ├── ui/
│   │   ├── update_badge.dart        # Mini badge widget
│   │   └── update_dialog.dart       # Full update dialog with progress
│   └── app_update.dart             # Barrel export (single import)
│
├── bloc/update/
│   ├── app_update_cubit.dart       # State management
│   └── app_update_state.dart       # States: initial/checking/available/downloading/error
│
└── app.dart                        # UI: Footer with dynamic version + badge + BlocConsumer
```

### Open API Methods (`AppUpdateServiceInterface`)

```dart
// ① လက်ရှိ installed version ဖတ်ရန်
Future<AppVersionInfo> checkCurrentApkVersion();

// ② GitHub မှ latest version စစ်ရန်
Future<UpdateCheckResult> checkForVersionUpdate({bool force = false});

// ③ APK ဒေါင်းလုဒ် + Install (stream-based progress)
Stream<AppUpdateProgress> downloadLatestAPK(String apkUrl, {String? destinationFilename});

// ④ 7-day periodic check ကြောင်းသောကြောင် စစ်ရန်
Future<bool> shouldPerformPeriodicCheck();

// ⑤ Browser တွင် Release page ဖွင့်ရန် (fallback for non-Android)
Future<bool> openReleaseInBrowser(String url);
```

---

## ၆. Other Project တွင် Reuse လုပ်နည်း

`lib/core/update/` folder ကို မည်သည့် Flutter project တွင်မဆို Copy/Paste လုပ်ပြီး—

```dart
// pubspec.yaml တွင် ထည့်ပါ
ota_update: ^7.1.0
package_info_plus: ^9.0.1
http: ^1.6.0

// main.dart တွင် config ပြောင်းပါ
UpdateConfig(
  githubOwner: 'your-github-username',
  githubRepo: 'your-repo-name',
  destinationFilename: 'YourApp-latest.apk',
)

// Storage adapter ချိတ်ပါ (SharedPrefs / SecureStorage / Hive စသည်)
RepositoryUpdateStorage(
  reader: (key) => yourStorage.read(key),
  writer: (key, val) => yourStorage.write(key, val),
)
```

**AndroidManifest.xml တွင် ထည့်ရမည့် Permission:**
```xml
<uses-permission android:name="android.permission.REQUEST_INSTALL_PACKAGES" />

<provider
    android:name="androidx.core.content.FileProvider"
    android:authorities="${applicationId}.ota_update_provider"
    android:exported="false"
    android:grantUriPermissions="true">
    <meta-data
        android:name="android.support.FILE_PROVIDER_PATHS"
        android:resource="@xml/filepaths" />
</provider>
```

**`android/app/src/main/res/xml/filepaths.xml`:**
```xml
<paths>
    <files-path name="internal_apk_storage" path="ota_update/" />
</paths>
```

---

## ၇. Version Tag Format Rules

| ✅ Supported | ❌ Unsupported |
|---|---|
| `v1.0.2` | `release-1.0` |
| `1.0.2` | `version_1_0_2` |
| `v1.0.2+5` | `1.0.2-SNAPSHOT` |
| `v2.0.0-beta` | (pre-release, `allowPrereleases: false` ဆိုလျှင် skip) |

`VersionComparator` သည် `v` prefix, `+buildNumber`, `-prerelease` suffix များကို အလိုအလျောက် handle လုပ်သည်။

---

*Generated for Chey Ngar v1.0.1 — thanwannahtun/CheyNgar-App*
