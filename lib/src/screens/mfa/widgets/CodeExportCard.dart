import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../theme/theme.dart';
import '../mfa_export_tab.dart';
import 'simple_icons.dart';

class CodeExportcard extends StatefulWidget {
  final TOTPStoredWithUrl code;

  const CodeExportcard({super.key, required this.code});

  @override
  State<CodeExportcard> createState() => _CodeExportcardState();
}

class _CodeExportcardState extends State<CodeExportcard> {
  bool codeBlurred = true;

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
        spacing: theme.defaultSpacing,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(children: [
                SimpleIcon(iconName: widget.code.issuer, width: 60, height: 60),
                Text(
                  widget.code.issuer,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 26,
                  ),
                ),
                Text(widget.code.userAccount),
              ]),
              Spacer(flex: 1),
              GestureDetector(
                onTap: () {
                  setState(() {
                    codeBlurred = !codeBlurred;
                  });
                },
                child: ImageFiltered(
                  imageFilter:
                      codeBlurred ? ImageFilter.blur(sigmaX: 6, sigmaY: 6) : ImageFilter.blur(sigmaX: 0, sigmaY: 0),
                  child: QrImageView(
                    errorCorrectionLevel: QrErrorCorrectLevel.L,
                    data: widget.code.url,
                    version: QrVersions.auto,
                    size: 180,
                  ),
                ),
              )
            ],
          ),
        ],
      ),
    );
  }
}
