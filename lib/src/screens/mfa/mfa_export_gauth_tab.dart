// dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:rxdart/rxdart.dart';

import '../../data/irma_repository.dart';
import '../../data/mfa_repository.dart';
import '../../models/mfa_events.dart';
import '../../providers/irma_repository_provider.dart';
import '../../theme/theme.dart';
import '../../widgets/irma_app_bar.dart';
import 'mfa_export_tab.dart';

class MfaExportGauthTab extends StatefulWidget {
  @override
  State<MfaExportGauthTab> createState() => MfaExportGauthTabState();
  final List<TOTPStoredWithUrl> codesSelected;

  const MfaExportGauthTab({
    super.key,
    required this.codesSelected,
  });
}

class MfaExportGauthTabState extends State<MfaExportGauthTab> {
  late IrmaRepository _irmaRepo;
  late MfaRepository _mfaRepo;
  bool _reposInitialized = false;
  String googleMigrationUrl = '';

  @override
  didChangeDependencies() {
    super.didChangeDependencies();
    if (!_reposInitialized) {
      _irmaRepo = IrmaRepositoryProvider.of(context);
      _mfaRepo = MfaRepository(irmaRepository: _irmaRepo);
      _reposInitialized = true;
      _getGoogleTOTPURL();
    }
  }

  Future<void> _getGoogleTOTPURL() async {
    // build list of TOTPStored from selected entries by removing the URL
    final List<TOTPStored> codesSelected = widget.codesSelected
        .map((e) => TOTPStored(
      issuer: e.issuer,
      userAccount: e.userAccount,
      secret: e.secret,
      period: e.period,
      algorithm: e.algorithm,
    ))
        .toList();


    _mfaRepo.exportTOTPToURL(codesSelected, isGoogle: true);

    try {
      // Wait for the event with the codes
      final event =
      await _irmaRepo.getEvents().whereType<ExportSecretsToUrlEvent>().first.timeout(Duration(seconds: 1));
      setState(() {
        debugPrint('Received URLs: ${event.urls}');
        googleMigrationUrl = (event.urls!.isNotEmpty ? event.urls?.first : '')!;
        // Handle the received URLs or data here
        // For example, you might want to store them in a list
      });
    } catch (e) {
      debugPrint('Failed to fetch codes: $e');
    }
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
      body: SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.all(theme.defaultSpacing),
        child: Column(
          spacing: theme.defaultSpacing,
          children: [
            QrImageView(
              errorCorrectionLevel: QrErrorCorrectLevel.L,
              data: googleMigrationUrl,
              version: QrVersions.auto,
              size: MediaQuery.of(context).size.width * 0.9,
              backgroundColor: Colors.white,
            ),
          ],
        ),
      ),
    );
  }
}
