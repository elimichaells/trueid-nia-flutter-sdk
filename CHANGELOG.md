## 1.0.0

* Initial release: native Ghana Card (NIA) PIN + selfie verification, split
  out from the former monolithic `trueid_sdk` package into its own
  independently-versioned product package.
* PIN entry, NIA register lookup, and optional face-comparison enforcement.
* Selfie with guided liveness (shared engine from `trueid_core`).
* Organization-driven capture settings (capture mode, liveness requirement).
* Fast Track: re-verify a known individual with a fresh live selfie, no PIN
  re-entry.
