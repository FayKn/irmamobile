// lib/src/utils/dialogs.dart
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';

import '../../../models/mfa_events.dart';
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

List<TOTPStored> fileToStoredList(String fileContent) {
  final lines = fileContent.split('\n');
  List<TOTPStored> list = [];

  var interimList = <String, String>{};
  for (var line in lines) {
    line = line.trim();
    if (line.isEmpty || line.startsWith('#')) {
      // check if we have a complete entry to add
      if (interimList.containsKey('issuer') && interimList.containsKey('user') && interimList.containsKey('secret')) {
        list.add(TOTPStored(
          issuer: interimList['issuer']!,
          userAccount: interimList['user']!,
          secret: interimList['secret']!,
          period: int.tryParse(interimList['period'] ?? '') ?? 30,
          algorithm: interimList['algorithm'] ?? 'SHA1',
        ));
        interimList.clear();
      }

      continue; // Skip empty lines and comments
    }

    if (line.startsWith('Issuer: ')){
      interimList['issuer'] = line.substring(8).trim();
    } else if (line.startsWith('Account: ')){
      interimList['user'] = line.substring(9).trim();
    } else if (line.startsWith('Secret: ')){
      interimList['secret'] = line.substring(8).trim();
    } else if (line.startsWith('Period: ')){
      interimList['period'] = line.substring(8).trim();
    } else if (line.startsWith('Algorithm: ')){
      interimList['algorithm'] = line.substring(11).trim();
    }
  }

  return list;
}
