// dart
import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

import '../../data/irma_repository.dart';
import '../../data/mfa_repository.dart';
import '../../models/mfa_events.dart';
import '../../providers/irma_repository_provider.dart';
import '../../theme/theme.dart';
import '../../util/navigation.dart';
import '../../util/simple_icon_utils.dart';
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

  // add ability to pause the timer when there are no codes to decrease unnecessary updates
  bool timerPaused = false;

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
        secret: 'WL5RMI2PVYKEIQQNQ', issuer: 'Discord', userAccount: 'test.nl', period: 30, algorithm: 'SHA1');
    // Placeholder for adding a new MFA code
    // In a real app, this would involve scanning a QR code or entering details manually
    _mfaRepo.storeTOTP(code);
    timerPaused = false;
    _getCodes();
    _startCodeTimers();
  }

  void _removeCode(TOTPcode code) {
    // clone code to get around immutability and pass the same instance but with timerProgress as an int
    code = TOTPcode(
        issuer: code.issuer,
        userAccount: code.userAccount,
        code: code.code,
        nextCode: code.nextCode,
        period: code.period,
        timerProgress: code.timerProgress);
    // Remove the code from the list and update the state

    _mfaRepo.removeTOTP(code);
    setState(() {
      codes.remove(code);
    });
  }

  Future<void> _getCodes() async {
    // Dispatch request to get all TOTP secrets
    _mfaRepo.getAllTOTP();

    try {
      // Wait for the event with the codes
      final event = await _irmaRepo.getEvents().whereType<GetAllTOTPSecretsEvent>().first.timeout(Duration(seconds: 1));
      if (event.codes == null) {
        timerPaused = true;
        _startCodeTimers();
      }
      setState(() {
        codes = event.codes ?? [];
      });
    } catch (e) {
      debugPrint('Failed to fetch codes: $e');
    }
  }

  void _startCodeTimers() {
    _ticker?.cancel();
    if (timerPaused) return;

    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      _getCodes();
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
                        onDelete: () => _removeCode(code)),
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
