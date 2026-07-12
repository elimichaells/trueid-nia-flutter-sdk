import 'package:flutter_test/flutter_test.dart';
import 'package:trueid_nia_sdk/trueid_nia_sdk.dart';

void main() {
  group('VerificationConfig', () {
    test('toMap uses defaults and flattens captureConfig', () {
      const config = VerificationConfig();
      final map = config.toMap();

      expect(map['forceNia'], false);
      expect(map['enforceFaceComparison'], true);
      expect(map['requireLiveness'], true);
      expect(map['showGuidelines'], true);
      expect(map['useOrganizationCaptureSettings'], true);
      expect(map['captureMode'], 'auto');
      expect(map['initialCamera'], 'front');
      expect(map['transactionTypes'], isEmpty);
    });
  });

  group('VerificationResult', () {
    test('isSuccess is true only when verified and no error', () {
      final verified = VerificationResult.fromMap({'verified': true});
      final failed = VerificationResult.fromMap({
        'verified': true,
        'errorMessage': 'mismatch',
      });
      final unverified = VerificationResult.fromMap({'verified': false});

      expect(verified.isSuccess, true);
      expect(failed.isSuccess, false);
      expect(unverified.isSuccess, false);
    });

    test('fromMap parses extracted identity fields', () {
      final result = VerificationResult.fromMap({
        'verified': true,
        'fullName': 'Jane Doe',
        'documentNumber': 'GHA-000000000',
        'nationality': 'Ghanaian',
      });

      expect(result.fullName, 'Jane Doe');
      expect(result.documentNumber, 'GHA-000000000');
      expect(result.nationality, 'Ghanaian');
    });
  });

  group('FastTrackVerificationConfig', () {
    test('toMap requires individualId and flattens captureConfig', () {
      const config = FastTrackVerificationConfig(individualId: 'ind_123');
      final map = config.toMap();

      expect(map['individualId'], 'ind_123');
      expect(map['useOrganizationCaptureSettings'], true);
      expect(map['requireLiveness'], true);
      expect(map['captureMode'], 'auto');
    });
  });

  group('FastTrackVerificationResult', () {
    test('isSuccess mirrors verified', () {
      final result = FastTrackVerificationResult.fromMap({'verified': true});
      expect(result.isSuccess, true);
    });
  });
}
