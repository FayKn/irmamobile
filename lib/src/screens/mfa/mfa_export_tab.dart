// dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

import '../../data/irma_repository.dart';
import '../../data/mfa_repository.dart';
import '../../models/mfa_events.dart';
import '../../providers/irma_repository_provider.dart';
import '../../widgets/yivi_themed_button.dart';
import '../../theme/theme.dart';
import '../../widgets/irma_app_bar.dart';
import 'widgets/CodeExportCard.dart';

class MfaExportTab extends StatefulWidget {
  @override
  State<MfaExportTab> createState() => MfaExportTabState();
}

class MfaExportTabState extends State<MfaExportTab> {
  late IrmaRepository _irmaRepo;
  late MfaRepository _mfaRepo;
  bool _reposInitialized = false;

  // Store TOTP entries together with the generated otpauth:// URL
  List<TOTPStoredWithUrl> codes = [];
  List<TOTPStoredWithUrl> codesSelected = [];

  @override
  void initState() {
    super.initState();
  }

  @override
  didChangeDependencies() {
    super.didChangeDependencies();
    if (!_reposInitialized) {
      _irmaRepo = IrmaRepositoryProvider.of(context);
      _mfaRepo = MfaRepository(irmaRepository: _irmaRepo);
      _reposInitialized = true;

      _getSecrets();
    }
  }

  Future<void> _getSecrets() async {
    _mfaRepo.exportTOTP();

    try {
      // Wait for the event with the codes
      final event = await _irmaRepo.getEvents().whereType<ExportSecretsEvent>().first.timeout(Duration(seconds: 1));
      setState(() {
        final list = event.totpStored ?? [];
        codes = list.map((c) => TOTPStoredWithUrl.fromTOTPStored(c)).toList();
      });
    } catch (e) {
      debugPrint('Failed to fetch codes: $e');
    }
  }

  void changeSelection(TOTPStoredWithUrl code, bool shortPress) {
    if (shortPress && codesSelected.isEmpty) {
      // No selection yet, short press does nothing
      return;
    }

    setState(() {
      if (codesSelected.contains(code)) {
        codesSelected.remove(code);
      } else {
        codesSelected.add(code);
      }
    });
  }

  void handleExportList() {
    debugPrint('Exporting ${codesSelected.length} codes');
  }

  // No separate URL list is needed: each stored entry contains its URL.
  @override
  Widget build(BuildContext context) {
    final theme = IrmaTheme.of(context);

    return Scaffold(
      backgroundColor: IrmaTheme.of(context).backgroundTertiary,
      appBar: IrmaAppBar(
        titleTranslationKey: 'more_tab.mfa_export',
      ),
      floatingActionButton: SizedBox(
        width: MediaQuery.of(context).size.width - theme.defaultSpacing * 2,
        child: YiviThemedButton(
          label: 'Export another way',
          onPressed: codesSelected.isNotEmpty ? () => handleExportList : null,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      body: SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.all(theme.defaultSpacing),
        child: Column(
          spacing: theme.defaultSpacing,
          children: codes
              .map(
                (entry) => InkWell (
                  onLongPress: () {
                    setState(() {
                      changeSelection(entry, false);
                    });
                  },
                  onTap: () {
                    setState(() {
                      changeSelection(entry, true);
                    });
                  },
                  child: CodeExportcard(code: entry, codeselected: codesSelected),
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}

// Simple container type that mirrors `TOTPStored` but also includes the
// generated otpauth:// URL so callers can easily show a QR code.
class TOTPStoredWithUrl {
  final String issuer;
  final String userAccount;
  final String secret;
  final int period;
  final String algorithm;
  final String url;

  TOTPStoredWithUrl({
    required this.issuer,
    required this.userAccount,
    required this.secret,
    required this.period,
    required this.algorithm,
    required this.url,
  });

  factory TOTPStoredWithUrl.fromTOTPStored(TOTPStored s) {
    final url = 'otpauth://totp/${Uri.encodeComponent(s.issuer)}:${Uri.encodeComponent(s.userAccount)}'
        '?secret=${s.secret}&issuer=${Uri.encodeComponent(s.issuer)}&algorithm=${s.algorithm}&period=${s.period}';
    return TOTPStoredWithUrl(
      issuer: s.issuer,
      userAccount: s.userAccount,
      secret: s.secret,
      period: s.period,
      algorithm: s.algorithm,
      url: url,
    );
  }
}
