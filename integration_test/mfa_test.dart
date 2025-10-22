import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:irmamobile/src/data/mfa_repository.dart';
import 'package:irmamobile/src/models/mfa_events.dart';
import 'package:irmamobile/src/models/session.dart';
import 'package:irmamobile/src/screens/mfa/mfa_tab.dart';
import 'package:irmamobile/src/screens/mfa/widgets/code_export_card.dart';
import 'package:irmamobile/src/screens/scanner/scanner_screen.dart';
import 'package:irmamobile/src/widgets/yivi_themed_button.dart';
import 'package:qr_flutter/qr_flutter.dart';

import 'helpers/helpers.dart';
import 'irma_binding.dart';
import 'qr_on_pin_screen_test.dart';
import 'util.dart';

main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  final irmaBinding = IntegrationTestIrmaBinding.ensureInitialized();
  WidgetController.hitTestWarningShouldBeFatal = true;
  Future<void> initAndNavToMfaScreen(WidgetTester tester) async {
    await pumpAndUnlockApp(tester, irmaBinding.repository);

    // Navigate to more tab
    await tester.tapAndSettle(find.byKey(const Key('nav_button_mfa')));
  }

  Future<void> initAndNavToMoreScreen(WidgetTester tester) async {
    await pumpAndUnlockApp(tester, irmaBinding.repository);

    // Navigate to more tab
    await tester.tapAndSettle(find.byKey(const Key('nav_button_more')));
  }

  Future<void> pauseMfaTimer(WidgetTester tester) async {
    final MfaTabState mfaState = tester.state(find.byType(MfaTab));
    mfaState.timerPaused = true;
    await tester.pumpAndSettle();
  }

  group('mfa', () {
    setUp(() => irmaBinding.setUp(experimentalFeatures: true));
    tearDown(() => irmaBinding.tearDown());

    testWidgets('Add MFA item via QR on homescreen', (WidgetTester tester) async {
      await pumpAndUnlockApp(tester, irmaBinding.repository);
      await tester.tapAndSettle(find.byKey(const Key('nav_button_scanner')));
      // pretend to scan MFA QR code by creating a pointer directly and running the handler
      Pointer pointer = MFAPointer(
        inputUrl:
            'otpauth://totp/TestIssuer:TestUser?issuer=TestIssuer&secret=LMSCQYMSVVQYSIUM&algorithm=SHA1&digits=6&period=30',
      );

      final ScannerScreenState scannerState = tester.state(find.byType(ScannerScreen));
      scannerState.onQrScanned(pointer);

      await tester.pumpAndSettle();
      await pauseMfaTimer(tester);

      // verify item is added, the correctness of data is tested in unit tests within Go
      expect(find.text('TestIssuer'), findsOneWidget);
      expect(find.text('TestUser'), findsOneWidget);
    });

    testWidgets('add mfa item manually', (WidgetTester tester) async {
      await initAndNavToMfaScreen(tester);
      expect(find.byKey(const Key('add_mfa_manual_button')), findsOneWidget);

      // click add button top right
      await tester.tapAndSettle(find.byKey(const Key('add_mfa_manual_button')));

      // fill in form
      await tester.enterText(find.byKey(const Key('mfa_manual_issuer_input')), 'TestIssuer');
      await tester.enterText(find.byKey(const Key('mfa_manual_secret_input')), 'JBSWY3DPEHPK3PXP');
      await tester.enterText(find.byKey(const Key('mfa_manual_account_input')), 'TestUser');
      await tester.pumpAndSettle();

      final saveButtonFinder = find.ancestor(
        of: find.text('Save'),
        matching: find.byType(YiviThemedButton),
      );
      expect(
        tester.widget<YiviThemedButton>(saveButtonFinder).onPressed,
        isNotNull,
      );
      // don't settle or the test will hang because of the timer
      await tester.tap(find.byKey(const Key('bottom_bar_primary')));

      await tester.pump(const Duration(seconds: 1));
      await pauseMfaTimer(tester);

      // verify item is added, the correctness of data is tested in unit tests within Go
      expect(find.text('TestIssuer'), findsOneWidget);
      expect(find.text('TestUser'), findsOneWidget);
    });

    testWidgets('Export code via Google QR', (WidgetTester tester) async {
      await initAndNavToMoreScreen(tester);

      var mfaRepo = MfaRepository(irmaRepository: irmaBinding.repository);
      final code = TOTPStored(secret: 'JBSWY3DPEHPK3PXP',
          issuer: 'TestIssuer',
          userAccount: 'TestUser',
          period: 30,
          algorithm: 'SHA1');
      mfaRepo.storeTOTP(code);

      // wait a second so the code is actually stored
      await tester.pump(const Duration(seconds: 1));

      await tester.tapAndSettle(find.byKey(const Key('mfa_export_list_tile')));

      // verify item is added, the correctness of data is tested in unit tests within Go
      expect(find.text('TestIssuer'), findsOneWidget);
      expect(find.text('TestUser'), findsOneWidget);

      // tap and hold the first CodeExportcard to select it
      final codeCardFinder = find.byType(CodeExportcard).first;
      await tester.longPress(codeCardFinder);
      await tester.pumpAndSettle();

      // tap the export button
      await tester.tapAndSettle(find.byKey(const Key('bottom_bar_secondary')));

      // expect to be on the Google export tab with a QR code
      expect(find.byType(QrImageView), findsOneWidget);
    });
  });
}
