import 'package:flutter/material.dart';

import '../../../theme/theme.dart';
import '../../../widgets/irma_themed_button.dart';
import '../../../widgets/translated_text.dart';

class DeleteButton extends StatelessWidget {
  final void Function(bool) onDelete;
  final bool deleteVisible;

  const DeleteButton({super.key, required this.onDelete, required this.deleteVisible});

  @override
  Widget build(BuildContext context) {
    void confirmDelete() async {
      final confirmed = await confirmationDialogue(context) ?? false;
      onDelete(confirmed);
    }

    final theme = IrmaTheme.of(context);
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      top: 0,
      bottom: 0,
      right: deleteVisible ? 0 : -72,
      width: 72,
      child: IgnorePointer(
        ignoring: !deleteVisible,
        child: GestureDetector(
          onTap: confirmDelete,
          behavior: HitTestBehavior.opaque,
          child: Container(
            height: double.infinity,
            color: theme.error,
            alignment: Alignment.center,
            child: const Icon(Icons.delete, color: Colors.white),
          ),
        ),
      ),
    );
  }
}

Future<bool?> confirmationDialogue(BuildContext context) {
  return showDialog<bool?>(
      context: context,
      builder: (context) {
        return AlertDialog(content: TranslatedText('mfa.delete.title'), actions: <Widget>[
          Column(spacing: IrmaTheme.of(context).smallSpacing, children: [
            IrmaThemedButton(
              label: 'mfa.delete.decline',
              onPressed: () => Navigator.pop(context),
              color: IrmaTheme.of(context).themeData.colorScheme.secondary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              isSecondary: true,
            ),
            IrmaThemedButton(
              label: 'mfa.delete.confirm',
              onPressed: () => Navigator.pop(context, true),
              color: IrmaTheme.of(context).themeData.colorScheme.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ]),
        ]);
      });
}
