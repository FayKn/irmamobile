// lib/src/screens/logging/logging_tab.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../theme/theme.dart';
import '../../widgets/translated_text.dart';
import '../activity/activity_tab.dart';
import '../notifications/bloc/notifications_bloc.dart';
import '../notifications/notifications_tab.dart';
import '../notifications/widgets/notification_indicator.dart';

class LoggingTab extends StatefulWidget {
  @override
  State<LoggingTab> createState() => _LoggingTabState();
}

class _LoggingTabState extends State<LoggingTab> {
  @override
  Widget build(BuildContext context) {
    final theme = IrmaTheme.of(context);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: theme.backgroundPrimary,
        appBar: AppBar(
          centerTitle: true,
          title: const TranslatedText(
            'home.nav_bar.logging',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          elevation: 0,
          bottom: TabBar(
            tabs: [
              Tab(child: TranslatedText('activity.tab_bar.transactions')),
              Tab(child: _notificationText('activity.tab_bar.notifications')),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            ActivityTab(isInLogging: true),
            BlocProvider.value(
              value: BlocProvider.of<NotificationsBloc>(context),
              child: NotificationsTab(isInLogging: true),
            ),
          ],
        ),
      ),
    );
  }

  // widget so the notification text gets an indicator when there are new notifications
  Widget _notificationText(String translationKey) {
    return BlocBuilder<NotificationsBloc, NotificationsState>(
      builder: (context, state) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          spacing: 4,
          children: [
            TranslatedText(translationKey),
            if (state is NotificationsLoaded ? state.hasUnreadNotifications : false) NotificationIndicator(),
          ],
        );
      },
    );
  }
}
