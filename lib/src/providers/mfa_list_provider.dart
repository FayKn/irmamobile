import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/irma_preferences.dart';
import 'credentials_list_provider.dart';
import 'preferences_provider.dart';

abstract class OrderRepo {
  // Should return a list of full credential ids
  Future<List<String>> loadOrder();

  // Should save a list of full credential ids
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

final credentialOrderControllerProvider = AsyncNotifierProvider<MFAOrderController, List<MultiFormatCredential>>(
  MFAOrderController.new,
);

class MFAOrderController extends AsyncNotifier<List<MultiFormatCredential>> {
  Timer? _debounce;
  List<String> _order = const []; // persisted order of IDs
  final NewItemPolicy _policy = NewItemPolicy.prepend;

  @override
  Future<List<MultiFormatCredential>> build() async {
    // Load persisted order once
    _order = await ref.read(credentialOrderRepoProvider).loadOrder();

    // Listen to external source and reconcile on each update
    ref.listen(
      credentialInfoListProvider,
          (prev, next) async {
        final items = next.valueOrNull;
        if (items == null) {
          return;
        }
        final merged = _reconcile(items, _order, _policy);
        state = AsyncData(merged);
        // Optionally clean up persisted order (remove non-existent IDs)
        _debouncedSave(merged);
        _order = merged.map((c) => c.credentialType.fullId).toList();
      },
    );

    // Seed with current external value (if available)
    final ext = await ref.read(credentialInfoListProvider.future);
    final merged = _reconcile(ext, _order, _policy);
    _order = merged.map((e) => e.credentialType.fullId).toList();
    return merged;
  }

  /// User reorders visible items
  void reorder(int oldIndex, int newIndex) {
    final current = state.requireValue.toList();
    if (newIndex > oldIndex) newIndex -= 1;
    final moved = current.removeAt(oldIndex);
    current.insert(newIndex, moved);
    state = AsyncData(current);
    _order = current.map((e) => e.credentialType.fullId).toList();
    _debouncedSave(current);
  }

  void _debouncedSave(List<MultiFormatCredential> items) {
    _debounce?.cancel();
    _debounce = Timer(
      const Duration(milliseconds: 400),
          () async {
        await ref.read(credentialOrderRepoProvider).saveOrder(
          items.map((e) => e.credentialType.fullId).toList(),
        );
      },
    );
  }

  void dispose() {
    _debounce?.cancel();
  }
}
