import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'dart:math' as math;

import '../../../theme/theme.dart';
import '../mfa_export_tab.dart';
import 'simple_icons.dart';

class CodeExportcard extends StatelessWidget {
  final TOTPStoredWithUrl code;

  const CodeExportcard({super.key, required this.code});

  @override
  Widget build(BuildContext context) {
    final theme = IrmaTheme.of(context);

    return Container(
      decoration: BoxDecoration(
        borderRadius: theme.borderRadius,
        color: theme.light,
      ),
      padding: EdgeInsets.all(theme.defaultSpacing),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          LayoutBuilder(builder: (context, constraints) {
            return ConstrainedBox(
              constraints: BoxConstraints(maxWidth: constraints.maxWidth),
              child: Text(
                code.issuer,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                softWrap: false,
                textAlign: TextAlign.center,
              ),
            );
          }),
          SizedBox(height: theme.defaultSpacing / 2),
          SimpleIcon(iconName: code.issuer),
          SizedBox(height: theme.defaultSpacing),
          // Make the QR responsive to the available space in the card so it
          // doesn't overflow when the carousel forces a smaller card size.
          LayoutBuilder(builder: (context, constraints) {
            // choose a maximum size but respect the card's constraints
            final maxAvailable = math.min(constraints.maxWidth, constraints.maxHeight);
            final qrSize = math.min(200.0, maxAvailable * 0.6);
            return QrImageView(
              data: code.url,
              version: QrVersions.auto,
              size: qrSize,
            );
          }),
        ],
      ),
    );
  }
}
