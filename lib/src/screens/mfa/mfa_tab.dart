// dart
import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

import '../../data/irma_repository.dart';
import '../../data/mfa_repository.dart';
import '../../models/mfa_credentials.dart';
import '../../models/mfa_events.dart';
import '../../providers/irma_repository_provider.dart';
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
  List<TOTPcode> codes = [];
  late IrmaRepository _irmaRepo;
  late MfaRepository _mfaRepo;
  bool _reposInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_reposInitialized) {
      _irmaRepo = IrmaRepositoryProvider.of(context);
      _mfaRepo = MfaRepository(irmaRepository: _irmaRepo);
      _reposInitialized = true;
    }

    _getCodes();
    _startCodeTimers();
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  void _addCode() {
    var code = TOTPStored(
        secret: '64NAVGZ5PMPBNQCU', issuer: 'NewService', userAccount: 'test.nl', period: 30, algorithm: 'SHA1');
    // Placeholder for adding a new MFA code
    // In a real app, this would involve scanning a QR code or entering details manually
    _mfaRepo.storeTOTP(code);
  }

  Future<void> _getCodes() async {
    // Dispatch request to get all TOTP secrets
    _mfaRepo.getAllTOTP();

    try {
      // Wait for the event with the codes
      final event = await _irmaRepo.getEvents().whereType<GetAllTOTPSecretsEvent>().first.timeout(Duration(seconds: 5));
      codes = event.codes!;
    } catch (e) {
      debugPrint('Failed to fetch codes: $e');
    }
  }

  void _startCodeTimers() {
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {
        _getCodes();
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
              children: codes
                  .map(
                    (code) => TotpCard(
                      serviceName: code.issuer,
                      userName: code.userAccount,
                      currentCode: code.code,
                      nextCode: code.nextCode,
                      period: code.period,
                      timerProgress: code.timerProgress,
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
          _addCode();
          // Add your onPressed code here!
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
