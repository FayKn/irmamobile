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
    if (event is GetAllTOTPSecretsEvent && event.codes != null) {
      yield event.codes!;
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

  @override
  Future<List<TOTPcode>> build() async {
    // Load persisted order once
    _order = await ref.read(mfaOrderRepoProvider).loadOrder();

    // Listen to external source and reconcile on each update
    ref.listen<AsyncValue<List<TOTPcode>>>(
      mfaCodesProvider,
      (prev, next) async {
        final items = next.valueOrNull;
        if (items == null) {
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

  /// Merge logic:
  /// - keep IDs in stored order if they still exist
  /// - add any new external IDs at end/start (policy)
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
        await ref.read(mfaOrderRepoProvider).saveOrder(
              items.map(_codeKey).toList(),
            );
      },
    );
  }

  void dispose() {
    _debounce?.cancel();
  }
}
