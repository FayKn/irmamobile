import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:irmamobile/src/data/irma_client_bridge.dart';
import 'package:irmamobile/src/widgets/yivi_themed_button.dart';

import 'helpers/helpers.dart';
import 'irma_binding.dart';
import 'util.dart';

main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  final irmaBinding = IntegrationTestIrmaBinding.ensureInitialized();
  WidgetController.hitTestWarningShouldBeFatal = true;
  Future<void> initAndNavToMfaScreen(WidgetTester tester) async {
    await pumpAndUnlockApp(tester, irmaBinding.repository);

    //Navigate to more tab
    await tester.tapAndSettle(find.byKey(const Key('nav_button_mfa')));
  }

  Future<void> initAndNavToMoreScreen(WidgetTester tester) async {
    await pumpAndUnlockApp(tester, irmaBinding.repository);

    //Navigate to more tab
    await tester.tapAndSettle(find.byKey(const Key('nav_button_more')));
  }

  group('mfa', () {
    setUp(() => irmaBinding.setUp());
    tearDown(() => irmaBinding.tearDown());

    testWidgets('add mfa item', (WidgetTester tester) async {
      await initAndNavToMfaScreen(tester);
      expect(find.byKey(const Key('add_mfa_manual_button')), findsOneWidget);

      // click add button
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
      await tester.tapAndSettle(find.byKey(const Key('bottom_bar_primary')));
      expect(find.text('TestIssuer'), findsOneWidget);
      expect(find.text('TestUser'), findsOneWidget);
    });
  });
}
