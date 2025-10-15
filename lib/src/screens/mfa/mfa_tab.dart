// dart
import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../routing.dart';

import '../../data/irma_repository.dart';
import '../../data/mfa_repository.dart';
import '../../models/mfa_events.dart';
import '../../providers/irma_repository_provider.dart';
import '../../providers/mfa_list_provider.dart';
import '../../theme/theme.dart';
import '../../util/navigation.dart';
import '../../widgets/irma_app_bar.dart';
import '../../widgets/irma_icon_button.dart';
import 'widgets/totp_card.dart';

class MfaTab extends ConsumerStatefulWidget {
  @override
  ConsumerState<MfaTab> createState() => MfaTabState();
}

class MfaTabState extends ConsumerState<MfaTab> with RouteAware {
  Timer? _ticker;
  late IrmaRepository _irmaRepo;
  late MfaRepository _mfaRepo;
  bool _reposInitialized = false;

  // add ability to pause the timer when there are no codes to decrease unnecessary updates
  bool timerPaused = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Subscribe to route changes so we can pause the timer when navigating away from this screen for the manual add screen
    routeObserver.subscribe(this, ModalRoute.of(context)!);
    if (!_reposInitialized) {
      _irmaRepo = IrmaRepositoryProvider.of(context);
      _mfaRepo = MfaRepository(irmaRepository: _irmaRepo);
      _reposInitialized = true;
    }
    _mfaRepo.getAllTOTP();
    _startCodeTimers();
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    _ticker?.cancel();
    super.dispose();
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
    _mfaRepo.getAllTOTP();
  }

  void _startCodeTimers() {
    _ticker?.cancel();
    if (timerPaused) return;

    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      _mfaRepo.getAllTOTP();
    });
  }

  @override
  void didPushNext() {
    timerPaused = true;
    _ticker?.cancel();
  }

  @override
  void didPopNext() {
    timerPaused = false;
    _startCodeTimers();
  }

  @override
  Widget build(BuildContext context) {
    void addManualCode() {
      debugPrint('Add manual code');
      context.pushMFAManualAddScreen();
    }

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
            onTap: addManualCode,
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
