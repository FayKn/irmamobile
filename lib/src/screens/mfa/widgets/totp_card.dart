import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../theme/theme.dart';
import '../../../widgets/irma_themed_button.dart';
import '../../../widgets/translated_text.dart';
import 'service_icon.dart';

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
  bool _showCopyCheckmark = false;

  void _handleTapCopyOrDismiss(String stringCurrentCode) {
    if (_deleteVisible) {
      setState(() => _deleteVisible = false);
      return;
    }
    Clipboard.setData(ClipboardData(text: stringCurrentCode));

    _showCopyCheckmark = true;
    setState(() {});
    Future.delayed(const Duration(seconds: 3), () {
      _showCopyCheckmark = false;
      setState(() {});
    });
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

  Future<void> _delete() async {
    var confirmed = await confirmationDialogue(context) ?? false;

    if (confirmed) {
      widget.onDelete();
    }
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
            child: Dismissible(
              confirmDismiss: (_) async {
                await _delete();
                return false;
              },
              key: ValueKey(widget.serviceName + widget.userName),
              background: Container(
                  color: theme.error,
                      alignment: Alignment.centerRight,
                      padding: EdgeInsets.only(right: theme.defaultSpacing),
                      child: Icon(Icons.delete, color: Color(0xFFFFC1C1), size: 30),
              ),
              direction: DismissDirection.endToStart,
              child: Stack(
                children: [
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    // timer bar
                    AnimatedSlide(
                      offset: Offset(-(widget.timerProgress / widget.period), 0),
                      duration: const Duration(milliseconds: 1000),
                      curve: Curves.linear,
                      child: Container(
                        width: containerWidth,
                        height: 5,
                        color: theme.primary,
                      ),
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
                              ServiceIcon(
                                  iconName: widget.serviceName.isNotEmpty ? widget.serviceName : widget.userName),
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
                            _showCopyCheckmark
                                ? Icon(Icons.check, color: theme.success)
                                : Icon(Icons.copy, color: theme.neutralExtraDark),
                          ]),
                        ],
                      ),
                    ),
                  ]),
                ],
              ),
            )),
      ),
    );
  }
}
