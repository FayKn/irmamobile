// dart
import 'dart:async';

import 'package:base32/base32.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import '../../models/mfa_credentials.dart';

import '../../theme/theme.dart';
import '../../widgets/irma_app_bar.dart';
import 'widgets/totp_card.dart';

class MfaTab extends StatefulWidget {
  @override
  State<MfaTab> createState() => _MfaTabState();
}

class _MfaTabState extends State<MfaTab> {
  Timer? _ticker;
  Map<String, MFASecret> codes = {};

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
      '64NAVGZ5PMPBNQCU': MFASecret(
        issuer: 'Cloudflare',
        secret: '',
        // replace with actual base32 secret
        period: 30,
        userAccount: 'fay@fayk.nl',
        timerProgress: 0,
        code: null,
        // empty to be replaced later
        nextCode: null, // empty to be replaced later
      ),
      '2L7MBIKPJ2V3NKKW': MFASecret(
        issuer: 'Discord',
        secret: '',
        period: 30,
        userAccount: 'fay@fayk.nl',
        timerProgress: 0,
        code: null,
        nextCode: null,
      ),
      'FQHR4UH4PT3SMAIN': MFASecret(
        issuer: 'Slack',
        secret: '',
        period: 30,
        userAccount: 'fay@fayk.nl',
        timerProgress: 0,
        code: null,
        nextCode: null,
      ),
      '2MF4SAKOQQK7DZ2Z': MFASecret(
        issuer: 'Github',
        secret: '',
        period: 30,
        userAccount: 'fay@fayk.nl',
        timerProgress: 0,
        code: null,
        nextCode: null,
      ),
      '5CBXXQXE4Q6WZ3C6': MFASecret(
        issuer: 'OpenAI',
        secret: '',
        period: 30,
        userAccount: 'fay@fayk.nl',
        timerProgress: 0,
        code: null,
        nextCode: null,
      ),
      'YCCR4IJAG2STUHEP': MFASecret(
        issuer: 'Cloudflare',
        secret: '',
        period: 15,
        userAccount: 'fay@fayk.nl',
        timerProgress: 0,
        code: null,
        nextCode: null,
      ),
      'JAR4UXFVWAODQID3': MFASecret(
        issuer: 'Cloudflare',
        secret: '',
        period: 60,
        userAccount: 'fay@fayk.nl',
        timerProgress: 0,
        code: null,
        nextCode: null,
      ),
    };
  }

  int generateTOTPCode(MFASecret secret, int currentTime) {
    var currenTimeBytes = _intToBytes(currentTime ~/ secret.period);
    var decodedSecret = base32.decode(secret.secret);

    Hmac hmac;
    switch (secret.algorithm) {
      case 'SHA256':
        hmac = Hmac(sha256, decodedSecret); // HMAC-SHA256
      case 'SHA512':
        hmac = Hmac(sha512, decodedSecret); // HMAC-SHA512
      default:
        hmac = Hmac(sha1, decodedSecret); // HMAC-SHA1
    }

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
      value.code = generateTOTPCode(
        value,
        now
      );
      value.timerProgress = now % value.period;
      value.nextCode = generateTOTPCode(
          value,
          now
      );
    });
  }

  void _startCodeTimers() {
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      setState(() {
        codes.forEach((key, value) {
          final period = value.period;
          final elapsed = now % period;
          value.timerProgress = elapsed;
          value.code = generateTOTPCode(
              value,
              now
          );
          value.nextCode = generateTOTPCode(
              value,
              now
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
                      serviceName: entry.value.issuer,
                      userName: entry.value.userAccount,
                      currentCode: entry.value.code ?? 0,
                      period: entry.value.period,
                      timerProgress: entry.value.timerProgress,
                      nextCode: entry.value.nextCode ?? 0,
                    ),
                  )
                  .toList())),
      floatingActionButton: FloatingActionButton(
        shape: CircleBorder(
          side: BorderSide(
            color: theme.primary,
            width: 4.0,
          ),
        ),
        onPressed: () {
          // Add your onPressed code here!
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
