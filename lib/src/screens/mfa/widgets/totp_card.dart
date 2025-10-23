import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../theme/theme.dart';
import '../../../widgets/translated_text.dart';
import 'delete_button.dart';
import 'simple_icons.dart';

class TotpCard extends StatefulWidget {
  final String serviceName;
  final String userName;
  final String currentCode;
  final String nextCode;
  final int period;
  final int timerProgress;
  final void Function() onDelete;

  const TotpCard({
    super.key,
    required this.serviceName,
    required this.userName,
    required this.currentCode,
    required this.period,
    required this.timerProgress,
    required this.nextCode,
    required this.onDelete,
  });

  @override
  State<TotpCard> createState() => _TotpCardState();
}

class _TotpCardState extends State<TotpCard> {
  bool _deleteVisible = false;

  void _handleTapCopyOrDismiss(String stringCurrentCode) {
    if (_deleteVisible) {
      setState(() => _deleteVisible = false);
      return;
    }
    Clipboard.setData(ClipboardData(text: stringCurrentCode));
  }
  void _onHorizontalDragUpdate(DragUpdateDetails details) {
    // Reveal on left swipe, hide on right swipe.
    const threshold = 10; // pixels per update
    if (details.delta.dx < -threshold && !_deleteVisible) {
      setState(() => _deleteVisible = true);
    } else if (details.delta.dx > threshold && _deleteVisible) {
      setState(() => _deleteVisible = false);
    }
  }

  void _delete(bool confirmed) {
    if (confirmed) {
      widget.onDelete();
    }
    setState(() {
      _deleteVisible = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = IrmaTheme.of(context);
    final double containerWidth = MediaQuery.of(context).size.width - theme.defaultSpacing * 2;

    var stringCurrentCode = widget.currentCode.toString().padLeft(6, '0');
    var stringNextCode = widget.nextCode.toString().padLeft(6, '0');
    var codeLength = widget.currentCode.toString().length;

    var halfLength = (codeLength / 2).ceil();

    stringCurrentCode = '${stringCurrentCode.substring(0, halfLength)} ${stringCurrentCode.substring(halfLength)}';
    stringNextCode = '${stringNextCode.substring(0, halfLength)} ${stringNextCode.substring(halfLength)}';

    return GestureDetector(
      onTap: () => _handleTapCopyOrDismiss(stringCurrentCode),
      onHorizontalDragUpdate: _onHorizontalDragUpdate,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: theme.borderRadius,
          color: theme.light,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade300,
              offset: const Offset(0.0, 1.0),
              blurRadius: 6.0,
            )
          ],
        ),
        child: ClipRRect(
          borderRadius: theme.borderRadius,
          child: Stack(
            children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                // Timer bar
                AnimatedContainer(
                  duration: const Duration(milliseconds: 1000),
                  curve: Curves.linear,
                  color: theme.primary,
                  alignment: Alignment.topLeft,
                  width: containerWidth - (widget.timerProgress / widget.period) * containerWidth,
                  height: 5,
                ),

                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: theme.defaultSpacing,
                    vertical: theme.smallSpacing,
                  ),
                  child: Row(
                    children: [
                      Flexible(
                        child: Row(spacing: theme.defaultSpacing, children: [
                          SimpleIcon(iconName: widget.serviceName),
                          Expanded(
                            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Text(
                                widget.serviceName,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                              Text(
                                widget.userName,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontSize: 12,
                                  decoration: TextDecoration.underline,
                                  color: theme.neutralExtraDark,
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ]),
                          ),
                        ]),
                      ),
                      Row(spacing: theme.smallSpacing, children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              stringCurrentCode,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            TranslatedText(
                              'mfa.nextCode',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontSize: 10,
                                color: theme.neutralExtraDark,
                              ),
                              translationParams: {'code': stringNextCode},
                            ),
                          ],
                        ),
                        Icon(Icons.copy, color: theme.neutralExtraDark),
                      ]),
                    ],
                  ),
                ),
              ]),

              // Delete overlay
              DeleteButton(onDelete: _delete, deleteVisible: _deleteVisible),
            ],
          ),
        ),
      ),
    );
  }
}
