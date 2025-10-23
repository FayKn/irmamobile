import 'package:flutter/material.dart';

import '../../notifications/widgets/notification_indicator.dart';

class ActivityIcon extends StatelessWidget {
  final Function() onTap;
  final bool showIndicator;
  final bool outlined;
  final Color? color;

  const ActivityIcon({
    super.key,
    required this.onTap,
    this.showIndicator = false,
    this.outlined = true,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Icon(
          outlined ? Icons.history_outlined : Icons.history,
          size: 28,
          color: color,
        ),
        if (showIndicator)
          Positioned(
            top: 0,
            right: 0,
            child: NotificationIndicator(),
          )
      ],
    );
  }
}
