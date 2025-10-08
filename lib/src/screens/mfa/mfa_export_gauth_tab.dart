// dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../data/irma_repository.dart';
import '../../data/mfa_repository.dart';
import '../../providers/irma_repository_provider.dart';
import '../../theme/theme.dart';
import '../../widgets/irma_app_bar.dart';

class MfaExportGauthTab extends StatefulWidget {
  @override
  State<MfaExportGauthTab> createState() => MfaExportGauthTabState();
}

class MfaExportGauthTabState extends State<MfaExportGauthTab> {
  late IrmaRepository _irmaRepo;
  late MfaRepository _mfaRepo;
  bool _reposInitialized = false;

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
              data: 'tets.com',
              version: QrVersions.auto,
              size: 150,
            ),
          ],
        ),
      ),
    );
  }
}
