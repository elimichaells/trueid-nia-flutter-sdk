## 1.0.3

* Updates the native Android dependency to `trueid-nia-sdk:1.1.1`
  (verification screen fixes).

## 1.0.2

* Updates the native Android dependency to `trueid-nia-sdk:1.1.0`:
  organization-driven light/dark/auto theme mode and a full visual
  redesign matching the document SDK's step-header/gradient/footer
  treatment. Also requires `trueid_core: ^1.0.2` for its automatic
  contrast-enforcement and theme-aware color-token fixes.
* No Dart-facing API changes.

## 1.0.1

* Requires `trueid_core: ^1.0.1` for the shared selfie engine's lighting/
  blink/multi-face/head-roll gating, face-region AE metering, and shutter
  sound + flash feedback, plus a packaging fix that silently required host
  apps to raise `compileSdk` to 36.

## 1.0.0

* Initial release: native Ghana Card (NIA) PIN + selfie verification, split
  out from the former monolithic `trueid_sdk` package into its own
  independently-versioned product package.
* PIN entry, NIA register lookup, and optional face-comparison enforcement.
* Selfie with guided liveness (shared engine from `trueid_core`).
* Organization-driven capture settings (capture mode, liveness requirement).
* Fast Track: re-verify a known individual with a fresh live selfie, no PIN
  re-entry.
