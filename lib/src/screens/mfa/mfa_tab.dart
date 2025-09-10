// dart
import 'dart:async';
import 'dart:ffi';

import 'package:base32/base32.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../models/mfa_credentials.dart';

import '../../theme/theme.dart';
import '../../util/navigation.dart';
import '../../widgets/irma_app_bar.dart';
import '../../widgets/irma_icon_button.dart';
import 'widgets/totp_card.dart';

class MfaTab extends StatefulWidget {
  @override
  State<MfaTab> createState() => _MfaTabState();
}

class _MfaTabState extends State<MfaTab> {
  Timer? _ticker;
  List<MFASecret> codes = [];

  @override
  void initState() {
    super.initState();
    _getCodes();
    // run this once to initialize codes so we don't have a second where the codes are 000000
    _generateCodes();
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
    codes = [
      MFASecret(
        issuer: 'Cloudflare',
        secret: '64NAVGZ5PMPBNQCU',
        // replace with actual base32 secret
        period: 30,
        userAccount: 'fay@fayk.nl',
        timerProgress: 0,
        code: null,
        // empty to be replaced later
        nextCode: null, // empty to be replaced later
      ),
      MFASecret(
        issuer: 'Discord',
        secret: 'NUOLQ2UTZCA3PO6Q',
        period: 30,
        userAccount: 'fay@fayk.nl',
        timerProgress: 0,
        code: null,
        nextCode: null,
      ),
      MFASecret(
        issuer: 'Slack',
        secret: 'PZELTFR5RJNVV5T6',
        period: 30,
        userAccount: 'fay@fayk.nl',
        timerProgress: 0,
        code: null,
        nextCode: null,
      ),
      MFASecret(
        issuer: 'Github',
        secret: 'UKXQHODNS57YKZCO',
        period: 30,
        userAccount: 'fay@fayk.nl',
        timerProgress: 0,
        code: null,
        nextCode: null,
      ),
      MFASecret(
        issuer: 'OpenAI',
        secret: 'M4QNZ5ZZAMMUCLUD',
        period: 30,
        userAccount: 'fay@fayk.nl',
        timerProgress: 0,
        code: null,
        nextCode: null,
      ),
      MFASecret(
        issuer: 'Cloudflare',
        secret: 'PH37OLAT26PUHUY7',
        period: 15,
        userAccount: 'fay@fayk.nl',
        timerProgress: 0,
        code: null,
        nextCode: null,
      ),
      MFASecret(
        issuer: 'Cloudflare',
        secret: 'HLPGZ4VBFWXY5SI5',
        period: 60,
        userAccount: 'fay@fayk.nl',
        timerProgress: 0,
        code: null,
        nextCode: null,
      ),
    ];
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

  void _generateCodes() {
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    for (var value in codes) {
      value.code = generateTOTPCode(
        value,
        now
      );
      value.timerProgress = now % value.period;
      value.nextCode = generateTOTPCode(
          value,
          now + (value.period - value.timerProgress)
      );
    }
  }

  void _startCodeTimers() {
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {
        _generateCodes();
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
        actions: [
          IrmaIconButton(
            icon: CupertinoIcons.add_circled_solid,
            size: 28,
            onTap: context.pushAddDataScreen,
          ),
        ],
      ),
      body: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.all(theme.defaultSpacing),
          child: Column(
              spacing: theme.defaultSpacing,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: codes.map(
                    (code) => TotpCard(
                      serviceName: code.issuer,
                      userName: code.userAccount,
                      currentCode: code.code ?? 0,
                      period: code.period,
                      timerProgress: code.timerProgress,
                      nextCode: code.nextCode ?? 0,
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
