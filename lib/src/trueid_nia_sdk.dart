import 'package:flutter/services.dart';
import 'package:trueid_core/trueid_core.dart';
import 'models.dart';

/// Native Ghana Card (NIA) PIN + selfie verification.
///
/// Call `TrueIdSdk.initialize(secretKey: ...)` (from `package:trueid_core`)
/// once before use — this flow requires your secret key.
///
/// ```dart
/// final result = await TrueIdNiaVerification.verify();
/// if (result != null && result.isSuccess) {
///   print('Verified: ${result.fullName}');
/// }
/// ```
class TrueIdNiaVerification {
  static const MethodChannel _channel =
      MethodChannel('com.trueid.sdk.nia/flutter');

  TrueIdNiaVerification._();

  /// Launch the full verification flow (PIN → selfie with guided liveness →
  /// NIA verification).
  ///
  /// Returns a [VerificationResult] on completion, or `null` if the user
  /// cancelled. Throws [TrueIdException] on error.
  static Future<VerificationResult?> verify({
    VerificationConfig config = const VerificationConfig(),
  }) async {
    try {
      final result = await _channel.invokeMethod('verify', config.toMap());
      if (result == null) return null;
      return VerificationResult.fromMap(Map<dynamic, dynamic>.from(result));
    } on PlatformException catch (e) {
      throw TrueIdException(
        code: e.code,
        message: e.message ?? 'Verification failed',
      );
    }
  }

  /// Re-verify a known individual with a fresh live selfie.
  ///
  /// Your authenticated backend must supply
  /// [FastTrackVerificationConfig.individualId]. The SDK captures the selfie,
  /// applies the institution's capture/liveness setting by default, and sends
  /// it to the server for face matching.
  static Future<FastTrackVerificationResult?> fastTrackVerify({
    required FastTrackVerificationConfig config,
  }) async {
    try {
      final result =
          await _channel.invokeMethod('fastTrackVerify', config.toMap());
      if (result == null) return null;
      return FastTrackVerificationResult.fromMap(
        Map<dynamic, dynamic>.from(result),
      );
    } on PlatformException catch (e) {
      throw TrueIdException(
        code: e.code,
        message: e.message ?? 'Fast Track verification failed',
      );
    }
  }
}
