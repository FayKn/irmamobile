// lib/src/utils/dialogs.dart
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';

import '../../../theme/theme.dart';
import '../../../widgets/irma_themed_button.dart';
import '../../../widgets/translated_text.dart';

Future<String?> showPasswordDialog(BuildContext context, String primaryLabel) async {
  final filePassword = TextEditingController();
  return showDialog<String?>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const TranslatedText('mfa.export.password_popup_title'),
        content: TextField(
          controller: filePassword,
          decoration: InputDecoration(hintText: FlutterI18n.translate(context, 'mfa.export.password_popup_hint')),
        ),
        actions: <Widget>[
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            IrmaThemedButton(
              minWidth: 120,
              label: 'mfa.export.password_popup_cancel',
              onPressed: () => Navigator.pop(context),
              color: IrmaTheme.of(context).themeData.colorScheme.secondary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              isSecondary: true,
            ),
            IrmaThemedButton(
              minWidth: 120,
              label: primaryLabel,
              onPressed: () => Navigator.pop(context, filePassword.text),
              color: IrmaTheme.of(context).themeData.colorScheme.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ]),
        ],
      );
    },
  );
}
