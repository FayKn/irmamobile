import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';

import '../../../theme/theme.dart';
import '../../../widgets/translated_text.dart';

class TotpCard extends StatelessWidget {
  final String serviceName;
  final String userName;
  final int currentCode;
  final int period;
  final int timerProgress;
  final int nextCode;

  const TotpCard({
    super.key,
    required this.serviceName,
    required this.userName,
    required this.currentCode,
    required this.period,
    required this.timerProgress,
    required this.nextCode,
  });

  @override
  Widget build(BuildContext context) {
    final theme = IrmaTheme.of(context);
    final double containerWidth = MediaQuery.of(context).size.width - theme.defaultSpacing * 2;
    var stringCurrentCode = currentCode.toString().padLeft(6, '0');
    var stringNextCode = nextCode.toString().padLeft(6, '0');

    return GestureDetector(
      onTap: () {
        Clipboard.setData(
          ClipboardData(text: stringCurrentCode),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: theme.borderRadius,
          border: Border.all(width: 0, color: Colors.transparent),
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Timer bar
              AnimatedContainer(
                duration: const Duration(milliseconds: 1000),
                curve: Curves.linear,
                color: theme.primary,
                alignment: Alignment.topLeft,
                width: containerWidth - (timerProgress / period) * containerWidth,
                height: 5,
              ),

              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: theme.defaultSpacing,
                  vertical: theme.smallSpacing,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  spacing: theme.defaultSpacing,
                  children: [
                    Row(
                      spacing: theme.defaultSpacing,
                      children: [
                        // TODO: replace with local assets though a sub repo of simple-icons to allow offline use
                        SvgPicture.network(
                          height: 40,
                          width: 40,
                          'https://cdn.simpleicons.org/$serviceName',
                          semanticsLabel: '$serviceName Logo',
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            RichText(
                              text: TextSpan(
                                text: serviceName,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Text(
                              userName,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontSize: 8,
                                decoration: TextDecoration.underline,
                                color: theme.neutralExtraDark,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Row(spacing: theme.smallSpacing, children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            stringCurrentCode,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TranslatedText(
                            'mfa.nextCode',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontSize: 8,
                              color: theme.neutralExtraDark,
                            ),
                            translationParams: {'code': stringNextCode},
                          ),
                        ],
                      ),
                      Icon(Icons.copy, color: theme.neutralExtraDark),
                    ])
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
