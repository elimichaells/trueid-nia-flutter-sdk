import 'package:trueid_core/trueid_core.dart';

/// Configuration for the NIA verification flow.
class VerificationConfig {
  /// Force NIA lookup even if a local match exists.
  final bool forceNia;

  /// Require face match on local lookups.
  final bool enforceFaceComparison;

  /// Optional active-challenge liveness outcome supplied by the host app.
  final bool? livenessPassed;

  /// Optional transaction type label for your records.
  final String? transactionType;

  /// Optional choices shown as a dropdown on the review screen; when empty
  /// the row is hidden and [transactionType] is used as-is.
  final List<String> transactionTypes;

  /// Run the guided liveness challenge (turn head left/right + countdown)
  /// during selfie capture.
  final bool requireLiveness;

  /// Show the Photo Instructions screen before opening the camera.
  final bool showGuidelines;

  /// Use the institution's server-managed `selfieCapture` setting. This maps
  /// `guided`, `manual`, and `auto` to the native flow. Disable only when the
  /// integration must use the local capture options below.
  final bool useOrganizationCaptureSettings;

  /// Selfie capture settings.
  final SelfieCaptureConfig captureConfig;

  const VerificationConfig({
    this.forceNia = false,
    this.enforceFaceComparison = true,
    this.livenessPassed,
    this.transactionType,
    this.transactionTypes = const [],
    this.requireLiveness = true,
    this.showGuidelines = true,
    this.useOrganizationCaptureSettings = true,
    this.captureConfig = const SelfieCaptureConfig(),
  });

  Map<String, dynamic> toMap() => {
        'forceNia': forceNia,
        'enforceFaceComparison': enforceFaceComparison,
        'livenessPassed': livenessPassed,
        'transactionType': transactionType,
        'transactionTypes': transactionTypes,
        'requireLiveness': requireLiveness,
        'showGuidelines': showGuidelines,
        'useOrganizationCaptureSettings': useOrganizationCaptureSettings,
        'captureMode': captureConfig.captureMode.name,
        'initialCamera': captureConfig.initialCamera.name,
        'allowCameraSwitch': captureConfig.allowCameraSwitch,
        'showFaceMesh': captureConfig.showFaceMesh,
        'outputWidth': captureConfig.outputWidth,
        'outputHeight': captureConfig.outputHeight,
        'jpegQuality': captureConfig.jpegQuality,
        'burstFrameCount': captureConfig.burstFrameCount,
        'burstFrameDelayMs': captureConfig.burstFrameDelayMs,
      };
}

/// Result of an identity verification.
class VerificationResult {
  final bool verified;
  final String? lookupSource;
  final String? scanRecordId;
  final String? fullName;
  final String? documentNumber;
  final String? nationality;
  final String? dateOfBirth;
  final String? gender;
  final String? expiryDate;
  final String? phoneNumber;
  final String? email;
  final String? selfieUrl;
  final String? niaPhotoUrl;
  final String? transactionType;
  final String? errorMessage;
  final String? errorCode;

  /// True when the identity was verified and no error occurred.
  bool get isSuccess => verified && errorMessage == null;

  const VerificationResult({
    required this.verified,
    this.lookupSource,
    this.scanRecordId,
    this.fullName,
    this.documentNumber,
    this.nationality,
    this.dateOfBirth,
    this.gender,
    this.expiryDate,
    this.phoneNumber,
    this.email,
    this.selfieUrl,
    this.niaPhotoUrl,
    this.transactionType,
    this.errorMessage,
    this.errorCode,
  });

  factory VerificationResult.fromMap(Map<dynamic, dynamic> map) {
    return VerificationResult(
      verified: map['verified'] as bool? ?? false,
      lookupSource: map['lookupSource'] as String?,
      scanRecordId: map['scanRecordId'] as String?,
      fullName: map['fullName'] as String?,
      documentNumber: map['documentNumber'] as String?,
      nationality: map['nationality'] as String?,
      dateOfBirth: map['dateOfBirth'] as String?,
      gender: map['gender'] as String?,
      expiryDate: map['expiryDate'] as String?,
      phoneNumber: map['phoneNumber'] as String?,
      email: map['email'] as String?,
      selfieUrl: map['selfieUrl'] as String?,
      niaPhotoUrl: map['niaPhotoUrl'] as String?,
      transactionType: map['transactionType'] as String?,
      errorMessage: map['errorMessage'] as String?,
      errorCode: map['errorCode'] as String?,
    );
  }

  @override
  String toString() =>
      'VerificationResult(verified: $verified, fullName: $fullName, documentNumber: $documentNumber)';
}

/// Configuration for Fast Track re-verification of a known individual.
///
/// Obtain [individualId] from your authenticated backend. The SDK deliberately
/// does not provide a mobile-side person search, which would risk exposing an
/// organization's customer data.
class FastTrackVerificationConfig {
  final String individualId;
  final bool useOrganizationCaptureSettings;
  final bool requireLiveness;
  final SelfieCaptureConfig captureConfig;

  const FastTrackVerificationConfig({
    required this.individualId,
    this.useOrganizationCaptureSettings = true,
    this.requireLiveness = true,
    this.captureConfig = const SelfieCaptureConfig(),
  });

  Map<String, dynamic> toMap() => {
        'individualId': individualId,
        'useOrganizationCaptureSettings': useOrganizationCaptureSettings,
        'requireLiveness': requireLiveness,
        'captureMode': captureConfig.captureMode.name,
        'initialCamera': captureConfig.initialCamera.name,
        'allowCameraSwitch': captureConfig.allowCameraSwitch,
        'showFaceMesh': captureConfig.showFaceMesh,
        'outputWidth': captureConfig.outputWidth,
        'outputHeight': captureConfig.outputHeight,
        'jpegQuality': captureConfig.jpegQuality,
        'burstFrameCount': captureConfig.burstFrameCount,
        'burstFrameDelayMs': captureConfig.burstFrameDelayMs,
      };
}

/// Result of a Fast Track facial re-verification.
class FastTrackVerificationResult {
  final bool verified;
  final String? scanRecordId;
  final String? message;

  const FastTrackVerificationResult({
    required this.verified,
    this.scanRecordId,
    this.message,
  });

  bool get isSuccess => verified;

  factory FastTrackVerificationResult.fromMap(Map<dynamic, dynamic> map) {
    return FastTrackVerificationResult(
      verified: map['verified'] as bool? ?? false,
      scanRecordId: map['scanRecordId'] as String?,
      message: map['message'] as String?,
    );
  }
}
