import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:irmamobile/src/screens/data/credentials_details_screen.dart';
import 'package:irmamobile/src/screens/logging/widgets/activity_icon.dart';
import 'package:irmamobile/src/screens/notifications/notifications_tab.dart';
import 'package:irmamobile/src/screens/notifications/widgets/notification_card.dart';
import 'package:irmamobile/src/widgets/credential_card/yivi_credential_card.dart';
import 'package:irmamobile/src/widgets/yivi_themed_button.dart';

import 'helpers/helpers.dart';
import 'helpers/issuance_helpers.dart';
import 'irma_binding.dart';
import 'util.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  final irmaBinding = IntegrationTestIrmaBinding.ensureInitialized();
  WidgetController.hitTestWarningShouldBeFatal = true;

  group('notifications', () {
    // Initialize the app's repository for integration tests (enable developer mode, etc.)
    setUp(() => irmaBinding.setUp(experimentalFeatures: true));
    tearDown(() => irmaBinding.tearDown());

    // Reusable finders
    final notificationsScreenFinder = find.byType(NotificationsTab);

    final activityIconFinder = find.byType(ActivityIcon);
    final notificationCardFinder = find.byType(NotificationCard);

    Future<void> navtoNotificationsTab(WidgetTester tester) async {
      // Switch to notifications tab
      final tabBarFinder = find.byType(TabBar);
      // second tab is notifications, don't check by text as it is translated
      final notificationsTabFinder = find
          .descendant(
            of: tabBarFinder,
            matching: find.byType(Tab),
          )
          .at(1);
      await tester.tapAndSettle(notificationsTabFinder);
    }

    Future<void> initAndNavToNotificationTab(WidgetTester tester) async {
      await pumpAndUnlockApp(tester, irmaBinding.repository);

      await tester.tapAndSettle(activityIconFinder);

      await navtoNotificationsTab(tester);
    }

    // Mocked notification cache
    const mockedCredentialCache =
        '[{"id":"#55175","softDeleted":false,"read":false,"content":{"titleTranslationKey":"notifications.credential_status.revoked.title","messageTranslationKey":"notifications.credential_status.revoked.message","translationType":"internalTranslatedContent"},"timestamp":"2023-07-14T11:11:31.794803","credentialHash":"session-43-0","type":"revoked","credentialTypeId":"irma-demo.IRMATube.member","action":{"credentialTypeId":"irma-demo.IRMATube.member","actionType":"credentialDetailNavigationAction"},"notificationType":"credentialStatusNotification"}]';

    const twoMockedCredentialsCache = '''
      [
        {
          "id": "#55175",
          "softDeleted": false,
          "read": false,
          "content": {
            "titleTranslationKey": "notifications.credential_status.revoked.title",
            "messageTranslationKey": "notifications.credential_status.revoked.message",
            "translationType": "internalTranslatedContent"
          },
          "timestamp": "2023-07-14T11:11:31.794803",
          "credentialHash": "session-43-0",
          "type": "revoked",
          "credentialTypeId": "irma-demo.IRMATube.member",
          "action": {
            "credentialTypeId": "irma-demo.IRMATube.member",
            "actionType": "credentialDetailNavigationAction"
          },
          "notificationType": "credentialStatusNotification"
        },
        {
          "id": "#55176",
          "softDeleted": false,
          "read": false,
          "content": {
            "titleTranslationKey": "notifications.credential_status.revoked.title",
            "messageTranslationKey": "notifications.credential_status.revoked.message",
            "translationType": "internalTranslatedContent"
          },
          "timestamp": "2023-07-15T11:11:31.794803",
          "credentialHash": "session-44-0",
          "type": "revoked",
          "credentialTypeId": "irma-demo.sidn-pbdf.mobilenumber",
          "action": {
            "credentialTypeId": "irma-demo.IRMATube.member",
            "actionType": "credentialDetailNavigationAction"
          },
          "notificationType": "credentialStatusNotification"
        }
      ]
    ''';
    testWidgets('reach', (tester) async {
      await pumpAndUnlockApp(tester, irmaBinding.repository);
      await tester.tapAndSettle(activityIconFinder);
      await navtoNotificationsTab(tester);
      expect(notificationsScreenFinder, findsOneWidget);

      await tester.tapAndSettle(find.byKey(const Key('nav_button_more')));
      await tester.tapAndSettle(activityIconFinder);
      await navtoNotificationsTab(tester);
      expect(notificationsScreenFinder, findsOneWidget);

      await tester.tapAndSettle(find.byKey(const Key('nav_button_data')));
      await tester.tapAndSettle(activityIconFinder);
      await navtoNotificationsTab(tester);
      expect(notificationsScreenFinder, findsOneWidget);
    });

    testWidgets('empty-state', (tester) async {
      await initAndNavToNotificationTab(tester);

      // Expect empty state message
      final emptyStateMessageFinder = find.descendant(
        of: notificationsScreenFinder,
        matching: find.text('No notifications'),
      );
      expect(emptyStateMessageFinder, findsOneWidget);
    });

    testWidgets('filled-state', (tester) async {
      await irmaBinding.repository.preferences.setSerializedNotifications(twoMockedCredentialsCache);
      await initAndNavToNotificationTab(tester);

      expect(notificationCardFinder, findsExactly(2));

      // Evaluate the NotificationCard
      await evaluateNotificationCard(
        tester,
        notificationCardFinder.at(0),
        title: 'Data revoked',
        content: 'Demo IRMATube has revoked this data: Demo IRMATube Member',
      );
    });

    testWidgets('read-all-notifications', (tester) async {
      await irmaBinding.repository.preferences.setSerializedNotifications(mockedCredentialCache);
      await pumpAndUnlockApp(tester, irmaBinding.repository);

      // Notification bell should show the indicator
      final icon = tester.widget<ActivityIcon>(activityIconFinder);
      expect(icon.showIndicator, true);

      // Press the NotificationBell and expect the NotificationsScreen to appear
      await tester.tapAndSettle(activityIconFinder);
      await navtoNotificationsTab(tester);
      expect(notificationsScreenFinder, findsOneWidget);

      expect(notificationCardFinder, findsOneWidget);

      // Evaluate the NotificationCard
      await evaluateNotificationCard(
        tester,
        notificationCardFinder,
        title: 'Data revoked',
        content: 'Demo IRMATube has revoked this data: Demo IRMATube Member',
        read: false,
      );

      // Leave the screen by pressing the data tab button
      await tester.tapAndSettle(find.byKey(const Key('nav_button_data')));

      // pumpAndSettle to make sure the event is processed
      await tester.pumpAndSettle();

      // NotificationBell now should not show the indicator
      final notificationBell2 = tester.widget<ActivityIcon>(activityIconFinder);
      expect(notificationBell2.showIndicator, false);

      // Press the NotificationBell and expect the NotificationsScreen to appear
      await tester.tapAndSettle(activityIconFinder);
      await navtoNotificationsTab(tester);
      expect(notificationsScreenFinder, findsOneWidget);

      // Expect one NotificationCard
      final notificationCardFinder2 = find.byType(NotificationCard);
      expect(notificationCardFinder2, findsOneWidget);

      // Evaluate the NotificationCard
      await evaluateNotificationCard(
        tester,
        notificationCardFinder2,
        title: 'Data revoked',
        content: 'Demo IRMATube has revoked this data: Demo IRMATube Member',
        read: true,
      );
    });

    testWidgets('dismiss-notification', (tester) async {
      await irmaBinding.repository.preferences.setSerializedNotifications(mockedCredentialCache);
      await initAndNavToNotificationTab(tester);

      expect(notificationCardFinder, findsOneWidget);

      await tester.drag(notificationCardFinder, const Offset(-500, 0));

      // pumpAndSettle to make sure the event is processed
      await tester.pumpAndSettle();

      // Expect no NotificationCard
      expect(notificationCardFinder, findsNothing);

      // Go back
      await tester.tapAndSettle(find.byKey(const Key('nav_button_data')));

      await tester.tapAndSettle(activityIconFinder);
      await navtoNotificationsTab(tester);

      // Expect no NotificationCard
      expect(notificationCardFinder, findsNothing);
    });

    testWidgets('notification-action', (tester) async {
      await irmaBinding.repository.preferences.setSerializedNotifications(mockedCredentialCache);
      await pumpAndUnlockApp(tester, irmaBinding.repository);

      // To make the action action work, we need to actually have the credential in the app
      await issueIrmaTubeMember(tester, irmaBinding);

      await tester.tapAndSettle(find.descendant(
        of: find.byType(YiviThemedButton),
        matching: find.text('OK'),
      ));

      await tester.tapAndSettle(activityIconFinder);
      await navtoNotificationsTab(tester);
      expect(notificationsScreenFinder, findsOneWidget);

      expect(notificationCardFinder, findsOneWidget);
      await evaluateNotificationCard(
        tester,
        notificationCardFinder,
        title: 'Data revoked',
        content: 'Demo IRMATube has revoked this data: Demo IRMATube Member',
        read: false,
      );

      // Now trigger the action by tapping the notification card
      await tester.tapAndSettle(notificationCardFinder);

      // Expect the credential detail screen
      final credentialDetailScreenFinder = find.byType(CredentialsDetailsScreen);
      expect(credentialDetailScreenFinder, findsOneWidget);

      // Expect the actual credential card
      // Note: the credential card is not actually revoked, so the card does not reflect this.
      final credentialCardFinder = find.byType(YiviCredentialCard);
      await evaluateCredentialCard(
        tester,
        credentialCardFinder.first,
        credentialName: 'Demo IRMATube Member',
        issuerName: 'Demo IRMATube',
      );

      // Go back
      final backButtonFinder = find.byKey(const Key('irma_app_bar_leading'));
      await tester.tapAndSettle(backButtonFinder);

      // Expect the notification screen
      expect(notificationsScreenFinder, findsOneWidget);

      // The notification should be marked as read
      final notificationCardFinder2 = find.byType(NotificationCard);
      expect(notificationCardFinder2, findsOneWidget);

      await evaluateNotificationCard(
        tester,
        notificationCardFinder2,
        title: 'Data revoked',
        content: 'Demo IRMATube has revoked this data: Demo IRMATube Member',
        read: true,
      );
    });

    // Note that the reloading of the notifications is tested in the disclosure permission revocation test
  });
}
