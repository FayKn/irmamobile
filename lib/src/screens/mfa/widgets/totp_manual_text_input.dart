import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../theme/theme.dart';
import '../../../widgets/translated_text.dart';

enum Formatters { nospecial, numerical, special }

class TotpManualTextInput extends StatelessWidget {
  final TextEditingController controller;
  final String translationKey;
  final String inputKey;
  final Formatters formatter;

  const TotpManualTextInput({
    super.key,
    required this.controller,
    required this.translationKey,
    required this.inputKey,
    this.formatter = Formatters.nospecial,
  });

  @override
  Widget build(BuildContext context) {
    final theme = IrmaTheme.of(context);
    final baseTextStyle = theme.textTheme.bodyMedium;

    return TextFormField(
        key: Key(inputKey),
        controller: controller,
        keyboardType: formatter == Formatters.numerical ? TextInputType.number : TextInputType.text,
        textCapitalization: TextCapitalization.characters,
        cursorColor: theme.themeData.colorScheme.secondary,
        style: baseTextStyle,
        inputFormatters: [
          if (formatter == Formatters.numerical)
            FilteringTextInputFormatter.digitsOnly
          else if (formatter == Formatters.special)
            FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9!@#\$%\^&\*\(\)_\+\-=\[\]\{\};:"\\|,.<>\/\?`~ ]'))
          else
          FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9]')),
        ],
        decoration: InputDecoration(
          hint: TranslatedText(
            translationKey,
            style: baseTextStyle?.copyWith(color: baseTextStyle.color?.withValues(alpha: 0.5)),
          ),
          contentPadding: const EdgeInsets.only(top: -10.0),
          label: TranslatedText(
            translationKey,
            style: baseTextStyle,
          ),
          floatingLabelAlignment: FloatingLabelAlignment.start,
          floatingLabelBehavior: FloatingLabelBehavior.always,
        ),
        autovalidateMode: AutovalidateMode.onUserInteraction
    );
  }
}
