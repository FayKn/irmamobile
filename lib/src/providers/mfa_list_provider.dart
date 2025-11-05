import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/irma_preferences.dart';
import '../models/mfa_events.dart';
import 'irma_repository_provider.dart';
import 'preferences_provider.dart';

// Indicates whether the user is currently dragging an MFA item in the UI
final mfaDraggingProvider = StateProvider<bool>((ref) => false);

abstract class OrderRepo {
  // Should return a list of MFA ids (issuer|userAccount)
  Future<List<String>> loadOrder();

  // Should save a list of MFA ids (issuer|userAccount)
  Future<void> saveOrder(List<String> ids);
}

class IrmaPreferencesOrderRepo implements OrderRepo {
  final IrmaPreferences _prefs;

  IrmaPreferencesOrderRepo(this._prefs);

  @override
  Future<List<String>> loadOrder() async {
    return _prefs.getMFAOrder();
  }

  @override
  Future<void> saveOrder(List<String> ids) {
    return _prefs.setMFAOrder(ids);
  }
}

final mfaOrderRepoProvider = Provider(
  (ref) => IrmaPreferencesOrderRepo(ref.watch(preferencesProvider)),
);

enum NewItemPolicy { append, prepend }

// Stream of MFA TOTP codes, updates when corresponding IRMA events are emitted.
final mfaCodesProvider = StreamProvider<List<TOTPcode>>((ref) async* {
  final repo = ref.watch(irmaRepositoryProvider);

  await for (final event in repo.getEvents()) {
    if (event is GetAllTOTPSecretsEvent) {
      // Treat a null Codes payload as an explicit empty list coming from the bridge.
      // This ensures the UI and timers update when the native side responds with no codes.
      yield event.codes ?? <TOTPcode>[];
    }
  }
});

String _codeKey(TOTPcode c) => '${c.issuer}|${c.userAccount}';

final mfaOrderControllerProvider = AsyncNotifierProvider<MFAOrderController, List<TOTPcode>>(
  MFAOrderController.new,
);

class MFAOrderController extends AsyncNotifier<List<TOTPcode>> {
  Timer? _debounce;
  List<String> _order = const []; // persisted order of IDs
  final NewItemPolicy _policy = NewItemPolicy.prepend;
  OrderRepo? _orderRepo;

  @override
  Future<List<TOTPcode>> build() async {
    _orderRepo = ref.read(mfaOrderRepoProvider);

    // Load persisted order once
    _order = await _orderRepo!.loadOrder();

    // Listen to external source and reconcile on each update
    ref.listen<AsyncValue<List<TOTPcode>>>(
      mfaCodesProvider,
      (prev, next) async {
        final items = next.valueOrNull;
        if (items == null) {
          return;
        }
        // If external reports zero items, clear persisted order and update immediately
        if (items.isEmpty) {
          state = AsyncData(<TOTPcode>[]);
          _debouncedSave(<TOTPcode>[]);
          _order = <String>[];
          return;
        }
        // Suppress updates while the user is dragging to prevent snap-back
        if (ref.read(mfaDraggingProvider)) {
          return;
        }
        final merged = _reconcile(items, _order, _policy);
        state = AsyncData(merged);
        // Optionally clean up persisted order (remove non-existent IDs)
        _debouncedSave(merged);
        _order = merged.map(_codeKey).toList();
      },
    );

    // Ensure timer is cancelled if this provider is disposed
    ref.onDispose(() {
      _debounce?.cancel();
      _orderRepo = null;
    });

    // Seed with current external value (if available)
    final ext = await ref.read(mfaCodesProvider.future);
    final merged = _reconcile(ext, _order, _policy);
    _order = merged.map(_codeKey).toList();
    return merged;
  }

  /// User reorders visible items
  void reorder(int oldIndex, int newIndex) {
    final current = state.requireValue.toList();
    if (newIndex > oldIndex) newIndex -= 1;
    final moved = current.removeAt(oldIndex);
    current.insert(newIndex, moved);
    state = AsyncData(current);
    _order = current.map(_codeKey).toList();
    _debouncedSave(current);
  }

  void removeCode(TOTPcode code) {
    final current = (state.valueOrNull ?? <TOTPcode>[]).toList();
    current.removeWhere((c) => _codeKey(c) == _codeKey(code));
    state = AsyncData(current);
    _order = current.map(_codeKey).toList();
    _debouncedSave(current);
  }

  void clearAll() {
    state = AsyncData(<TOTPcode>[]);
    _order = <String>[];
    _debouncedSave(<TOTPcode>[]);
  }

  List<TOTPcode> _reconcile(
    List<TOTPcode> external,
    List<String> storedOrder,
    NewItemPolicy p,
  ) {
    final byId = {for (final it in external) _codeKey(it): it};
    final visible = <TOTPcode>[];

    // 1) Keep items that still exist in the stored order
    for (final id in storedOrder) {
      final it = byId.remove(id);
      if (it != null) visible.add(it);
    }

    // 2) Any remaining are new from external
    final newOnes = byId.values.toList();
    if (newOnes.isEmpty) return visible;

    if (p == NewItemPolicy.append) {
      visible.addAll(newOnes);
    } else {
      visible.insertAll(0, newOnes);
    }
    return visible;
  }

  void _debouncedSave(List<TOTPcode> items) {
    _debounce?.cancel();
    _debounce = Timer(
      const Duration(milliseconds: 400),
      () async {
        // Use captured repo instance instead of ref.read to avoid reading providers after dispose
        try {
          await _orderRepo?.saveOrder(
            items.map(_codeKey).toList(),
          );
        } catch (_) {
          // ignore errors if repo is no longer available
        }
      },
    );
  }
}
