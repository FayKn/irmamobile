import 'dart:ffi';

import 'package:flutter/material.dart';
import '../../../theme/theme.dart';
import 'package:flutter_svg/flutter_svg.dart';

class TotpCard extends StatelessWidget {
  final String serviceName;
  final String userName;
  final int currentCode;
  final int period;
  final int timerProgress;

  const TotpCard({
    super.key,
    required this.serviceName,
    required this.userName,
    required this.currentCode,
    required this.period,
    required this.timerProgress,
  });

  @override
  Widget build(BuildContext context) {
    final theme = IrmaTheme.of(context);
    final double containerWidth = MediaQuery.of(context).size.width - theme.defaultSpacing * 2;

    return Container(
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
          ]),
      child: ClipRRect(
          borderRadius: theme.borderRadius,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // Timer bar
            AnimatedContainer(
              duration: const Duration(milliseconds: 1000),
              curve: Curves.linear,
              color: theme.primary,
              alignment: Alignment.topLeft,
              width: containerWidth - (timerProgress / period) * containerWidth,
              height: 5,
            ),

            Row(spacing: theme.defaultSpacing, children: [
              SvgPicture.network(
                height: 40,
                width: 40,
                'https://cdn.simpleicons.org/$serviceName',
                semanticsLabel: '$serviceName Logo',
              ),
              Column(children: [
                RichText(
                  text: TextSpan(
                    text: serviceName,
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
                Text(userName),
                Text(currentCode.toString()),
              ]),
            ]),
          ])),
    );
  }
}
