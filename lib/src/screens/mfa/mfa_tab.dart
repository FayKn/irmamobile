// dart
import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/irma_repository.dart';
import '../../data/mfa_repository.dart';
import '../../models/mfa_events.dart';
import '../../providers/irma_repository_provider.dart';
import '../../providers/mfa_list_provider.dart';
import '../../theme/theme.dart';
import '../../widgets/irma_app_bar.dart';
import '../../widgets/irma_icon_button.dart';
import 'widgets/totp_card.dart';

class MfaTab extends ConsumerStatefulWidget {
  @override
  ConsumerState<MfaTab> createState() => _MfaTabState();
}

class _MfaTabState extends ConsumerState<MfaTab> {
  Timer? _ticker;
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
        secret: 'WL5RMI2PVYKEIQQNR', issuer: 'Cloudflare', userAccount: 'test.nl', period: 30, algorithm: 'SHA1');
    // Placeholder for adding a new MFA code
    // In a real app, this would involve scanning a QR code or entering details manually
    _mfaRepo.storeTOTP(code);
    timerPaused = false;
    _getCodes();
    _startCodeTimers();
  }

  void _removeCode(TOTPcode code) {
    // clone code to get around immutability and pass the same instance but with timerProgress as an int
    final clone = TOTPcode(
        issuer: code.issuer,
        userAccount: code.userAccount,
        code: code.code,
        nextCode: code.nextCode,
        period: code.period,
        timerProgress: code.timerProgress);

    _mfaRepo.removeTOTP(clone);
    // Trigger a refresh
    _getCodes();
  }

  void _getCodes() {
    // Dispatch request to get all TOTP secrets; provider will pick up the event
    _mfaRepo.getAllTOTP();
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

    final itemsAsync = ref.watch(mfaOrderControllerProvider);
    final controller = ref.read(mfaOrderControllerProvider.notifier);

    return Scaffold(
      backgroundColor: IrmaTheme.of(context).backgroundTertiary,
      appBar: IrmaAppBar(
        titleTranslationKey: 'home.nav_bar.mfa',
        leading: null,
        actions: [
          IrmaIconButton(
            icon: CupertinoIcons.add_circled_solid,
            size: 28,
            onTap: _addCode,
          ),
        ],
      ),
      body: itemsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (codes) {
          timerPaused = codes.isEmpty;
          if (timerPaused) {
            _startCodeTimers();
          }
          return ReorderableListView.builder(
            onReorderStart: (index) {
              HapticFeedback.mediumImpact();
              // Suppress incoming updates during drag to avoid snap-back
              ref.read(mfaDraggingProvider.notifier).state = true;
              // Pause periodic fetch while dragging
              _ticker?.cancel();
            },
            onReorderEnd: (index) {
              HapticFeedback.mediumImpact();
              // Re-enable updates
              ref.read(mfaDraggingProvider.notifier).state = false;
              // Resume periodic fetch after drag ends
              _startCodeTimers();
            },
            onReorder: controller.reorder,
            proxyDecorator: (child, index, animation) {
              return Material(
                type: MaterialType.transparency,
                child: child,
              );
            },
            padding: EdgeInsets.all(theme.defaultSpacing),
            itemCount: codes.length,
            buildDefaultDragHandles: false,
            itemBuilder: (BuildContext context, int index) {
              final code = codes[index];
              return Padding(
                key: ValueKey(code.issuer + code.userAccount),
                padding: EdgeInsets.only(bottom: theme.smallSpacing),
                child: ReorderableDelayedDragStartListener(
                  index: index,
                  child: TotpCard(
                    serviceName: code.issuer,
                    userName: code.userAccount,
                    currentCode: code.code,
                    nextCode: code.nextCode,
                    period: code.period,
                    timerProgress: code.timerProgress,
                    onDelete: () => _removeCode(code),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
