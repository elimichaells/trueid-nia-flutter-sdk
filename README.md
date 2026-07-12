# TrueID NIA SDK for Flutter

Native Ghana Card verification: your customer enters their PIN, takes a
selfie with guided liveness, and the result is matched against the National
Identification Authority (NIA) register — all as a fully native Android
flow, no browser involved.

Requires [`trueid_core`](https://pub.dev/packages/trueid_core) for API-key
setup and the shared camera/liveness engine.

## Features

- **PIN entry + NIA lookup** — Ghana Card PIN verified directly against the
  NIA register
- **Selfie with guided liveness** — head-turn challenge + countdown, shared
  engine from `trueid_core`
- **Face comparison** — optional enforcement that the live selfie matches
  the NIA photo on file
- **Organization-driven capture settings** — capture mode (guided/manual/auto)
  and liveness requirements come from your dashboard on app.trueid.info
- **Fast Track** — returning users re-verify by a fresh live selfie against
  a known individual id, without re-entering their PIN

## Platform Support

| Platform | Supported |
|----------|-----------|
| Android  | Yes       |
| iOS      | No (planned) |

## Installation

```yaml
dependencies:
  trueid_core: ^1.0.0
  trueid_nia_sdk: ^1.0.0
```

### Android Setup

Add the TrueID Maven repository to your `android/settings.gradle.kts`:

```kotlin
dependencyResolutionManagement {
    repositories {
        google()
        mavenCentral()
        maven { url = uri("https://app.trueid.info/sdk/android") }
    }
}
```

On-prem institutions: replace `app.trueid.info` with your TrueID server origin.

Set `minSdkVersion` to at least **24**, and make your `MainActivity` extend
`FlutterFragmentActivity`:

```kotlin
import io.flutter.embedding.android.FlutterFragmentActivity

class MainActivity : FlutterFragmentActivity()
```

## Quick Start

```dart
import 'package:trueid_core/trueid_core.dart';
import 'package:trueid_nia_sdk/trueid_nia_sdk.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await TrueIdSdk.initialize(secretKey: 'sk_your_secret_key');
  runApp(MyApp());
}

Future<void> verify() async {
  try {
    final result = await TrueIdNiaVerification.verify(
      config: const VerificationConfig(enforceFaceComparison: true),
    );

    if (result == null) {
      print('User cancelled');
      return;
    }

    if (result.isSuccess) {
      print('Verified: ${result.fullName} (${result.documentNumber})');
    } else {
      print('Failed: ${result.errorMessage}');
    }
  } on TrueIdException catch (e) {
    print('Error: ${e.code} - ${e.message}');
  }
}
```

This flow requires your **secret key** — pass it to `TrueIdSdk.initialize()`.

## API Reference

### TrueIdNiaVerification

| Method | Description |
|--------|-------------|
| `verify({config})` | Launch the full PIN → selfie → NIA verification flow. Returns `VerificationResult?` (`null` if cancelled) |
| `fastTrackVerify({config})` | Re-verify a known individual with a fresh live selfie, no PIN re-entry |

### VerificationConfig

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `forceNia` | `bool` | `false` | Force an NIA lookup even if a local match exists |
| `enforceFaceComparison` | `bool` | `true` | Require the live selfie to match the NIA photo |
| `livenessPassed` | `bool?` | `null` | Supply an active-challenge liveness outcome yourself |
| `transactionType` | `String?` | `null` | Your correlation label, echoed on the result |
| `transactionTypes` | `List<String>` | `[]` | Choices shown on the review screen; empty hides the row |
| `requireLiveness` | `bool` | `true` | Run the guided head-turn liveness challenge |
| `showGuidelines` | `bool` | `true` | Show the photo-instructions screen |
| `useOrganizationCaptureSettings` | `bool` | `true` | Pull capture mode/liveness settings from your dashboard |
| `captureConfig` | `SelfieCaptureConfig` | defaults | Selfie camera settings (from `trueid_core`) |

### VerificationResult

| Field | Type | Description |
|-------|------|-------------|
| `verified` | `bool` | Matched against the NIA register |
| `isSuccess` | `bool` | `verified && errorMessage == null` |
| `lookupSource` | `String?` | Where the match came from |
| `scanRecordId` | `String?` | Record id — fetch the full record server-side |
| `fullName`, `documentNumber`, `nationality`, `dateOfBirth`, `gender`, `expiryDate` | `String?` | Extracted identity fields |
| `phoneNumber`, `email` | `String?` | On file with NIA, when available |
| `selfieUrl`, `niaPhotoUrl` | `String?` | Stored photo URLs |
| `errorMessage`, `errorCode` | `String?` | Failure details, when applicable |

### FastTrackVerificationConfig / FastTrackVerificationResult

| Parameter | Type | Description |
|-----------|------|-------------|
| `individualId` | `String` | Required — obtain from your authenticated backend |
| `useOrganizationCaptureSettings`, `requireLiveness`, `captureConfig` | — | Same as `VerificationConfig` |

The SDK deliberately provides no mobile-side person search, which would risk
exposing an organization's customer data — `individualId` must come from
your own backend.

## License

Proprietary. Use of this SDK requires an active TrueID organization account —
see https://app.trueid.info.
