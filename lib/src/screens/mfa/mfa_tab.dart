// dart
import 'dart:async';

import 'package:base32/base32.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';

import '../../theme/theme.dart';
import '../../widgets/irma_app_bar.dart';
import 'widgets/totp_card.dart';

class MfaTab extends StatefulWidget {
  @override
  State<MfaTab> createState() => _MfaTabState();
}

class _MfaTabState extends State<MfaTab> {
  Timer? _ticker;
  Map<String, Map<String, dynamic>> codes = {};

  @override
  void initState() {
    super.initState();
    _getCodes();
    _initCodes();
    _startCodeTimers();
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  void _getCodes() {
    // temporary function to simulate fetching codes
    // In a real app, this would fetch from a backend or local storage
    // Demo data
    codes = {
      '64NAVGZ5PMPBNQCU': {
        'name': 'fay@fayk.nl',
        'issuer': 'Cloudflare',
        'period': 30,
        'timerProgress': 0,
        'code': 123456,
        'nextCode': 654321,
      },      '2L7MBIKPJ2V3NKKW': {
        'name': 'fay@fayk.nl',
        'issuer': 'Cloudflare',
        'period': 30,
        'timerProgress': 0,
        'code': 123456,
        'nextCode': 654321,
      },      'FQHR4UH4PT3SMAIN': {
        'name': 'fay@fayk.nl',
        'issuer': 'Cloudflare',
        'period': 30,
        'timerProgress': 0,
        'code': 123456,
        'nextCode': 654321,
      },      '2MF4SAKOQQK7DZ2Z': {
        'name': 'fay@fayk.nl',
        'issuer': 'Cloudflare',
        'period': 30,
        'timerProgress': 0,
        'code': 123456,
        'nextCode': 654321,
      },      '5CBXXQXE4Q6WZ3C6': {
        'name': 'fay@fayk.nl',
        'issuer': 'Cloudflare',
        'period': 30,
        'timerProgress': 0,
        'code': 123456,
        'nextCode': 654321,
      },      'YCCR4IJAG2STUHEP': {
        'name': 'fay@fayk.nl',
        'issuer': 'Cloudflare',
        'period': 15,
        'timerProgress': 0,
        'code': 123456,
        'nextCode': 654321,
      },      'JAR4UXFVWAODQID3': {
        'name': 'fay@fayk.nl',
        'issuer': 'Cloudflare',
        'period': 60,
        'timerProgress': 0,
        'code': 123456,
        'nextCode': 654321,
      },
    };
  }

  int generateTOTPCode(String secret, int period, int currentTime) {
    var currenTimeBytes = _intToBytes(currentTime ~/ period);
    var decodedSecret = base32.decode(secret);

    var hmac = Hmac(sha1, decodedSecret); // HMAC-SHA1
    var hash = hmac.convert(currenTimeBytes).bytes;

    int offset = hash[hash.length - 1] & 0xf;

    int binary = ((hash[offset] & 0x7f) << 24) |
    ((hash[offset + 1] & 0xff) << 16) |
    ((hash[offset + 2] & 0xff) << 8) |
    (hash[offset + 3] & 0xff);

    return binary % 1000000;
  }

  static List<int> _intToBytes(int value) {
    final byteArray = List<int>.filled(8, 0);
    for (var index = byteArray.length - 1; index >= 0; index--) {
      final byte = value & 0xff;
      byteArray[index] = byte;
      value = value >> 8;
    }
    return byteArray;
  }

  void _initCodes() {
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    codes.forEach((key, value) {
      value['code'] = generateTOTPCode(
        key,
        value['period'] as int,
        now,
      );
      value['timerProgress'] = now % (value['period'] as int);
      value['nextCode'] = generateTOTPCode(
        key,
        value['period'] as int,
        now + (value['period'] as int),
      );
    });
  }

  void _startCodeTimers() {
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      setState(() {
        codes.forEach((key, value) {
          final period = value['period'] as int;
          final elapsed = now % period;
          // always update visible progress
          value['timerProgress'] = elapsed;
          // recompute current and next codes (cheap enough for small lists)
          value['code'] = generateTOTPCode(
            key,
            period,
            now,
          );
          value['nextCode'] = generateTOTPCode(
            key,
            period,
            now + period,
          );
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = IrmaTheme.of(context);

    return Scaffold(
        backgroundColor: IrmaTheme.of(context).backgroundTertiary,
        appBar: IrmaAppBar(
          titleTranslationKey: 'home.nav_bar.mfa',
          leading: null,
        ),
        body: SingleChildScrollView(
            physics: AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.all(theme.defaultSpacing),
            child: Column(
              spacing: theme.defaultSpacing,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: codes.entries
                    .map(
                      (entry) => TotpCard(
                    serviceName: entry.value['issuer'],
                    userName: entry.value['name'],
                    currentCode: entry.value['code'],
                    period: entry.value['period'],
                    timerProgress: entry.value['timerProgress'],
                  ),
                )
                    .toList())));
  }
}
