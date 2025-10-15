// dart
import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:rxdart/rxdart.dart';
import 'package:share_plus/share_plus.dart';

import '../../data/irma_repository.dart';
import '../../data/mfa_repository.dart';
import '../../models/mfa_events.dart';
import '../../providers/irma_repository_provider.dart';
import '../../theme/theme.dart';
import '../../widgets/irma_app_bar.dart';
import '../../widgets/irma_bottom_bar.dart';
import '../../widgets/translated_text.dart';
import 'mfa_export_gauth_tab.dart';
import 'widgets/code_export_card.dart';
import 'widgets/mfa_password_popup.dart';

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
    // No selection yet, short press does nothing so to not interfere with unblurring the QR
    if (shortPress && codesSelected.isEmpty) {
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

  Future<void> handleFileExportList() async {
    debugPrint('Exporting list of ${codesSelected.length} codes');

    var password = await showPasswordDialog(context, 'mfa.export.password_popup_confirm');

    if (password == null || password.isEmpty) {
      debugPrint('Export cancelled: no password provided');
      return;
    }

    var content = generatePlainExportContent().toString();

    debugPrint(content);

    _mfaRepo.encryptExportFile(password, content);
    try {
      // Wait for the event with the codes
      final event =
          await _irmaRepo.getEvents().whereType<EncryptExportFileReceiveEvent>().first.timeout(Duration(seconds: 2));
      content = event.content;
    } catch (e) {
      debugPrint('Export failed: $e');
      return;
    }

    debugPrint(content);

    var buffer = StringBuffer(content);

    switch (Platform.operatingSystem) {
      case 'android':
        filePickerShareFile(buffer);
      case 'ios':
        await shareExportFile(content);
      default:
        await filePickerShareFile(buffer);
    }

    debugPrint('Exporting ${codesSelected.length} codes');
  }

  void goToGoogleAuthCode() {
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (context) => MfaExportGauthTab(codesSelected: codesSelected),
      ),
    );
  }

  StringBuffer generatePlainExportContent() {
    final buffer = StringBuffer();
    for (var code in codesSelected) {
      buffer.writeln('Issuer: ${code.issuer}');
      buffer.writeln('Account: ${code.userAccount}');
      buffer.writeln('Secret: ${code.secret}');
      buffer.writeln('Period: ${code.period}');
      buffer.writeln('Algorithm: ${code.algorithm}');
      buffer.writeln(''); // Blank line between entries
    }
    return buffer;
  }

  Future<void> shareExportFile(String content) async {
    final directory = await getTemporaryDirectory();
    var currentDate = DateTime.now().toIso8601String().split('T').first;
    final filePath = '${directory.path}/mfa_export-$currentDate.txt';
    final file = await File(filePath).writeAsString(content);
    if (await file.exists()) {
      debugPrint('Prepared for sharing: $filePath');
      final shareParams = ShareParams(
        files: [XFile(filePath)],
      );
      await SharePlus.instance.share(shareParams);
    } else {
      debugPrint('Failed to write export file');
    }
  }

  Future<void> filePickerShareFile(StringBuffer content) async {
    var currentDate = DateTime.now().toIso8601String().split('T').first;
    final suggestedName = 'mfa_export-$currentDate.txt';
    content.write('\n');
    final Uint8List contentBytes = Uint8List.fromList(content.toString().codeUnits);

    final String? path = await FilePicker.platform.saveFile(
      fileName: suggestedName,
      type: FileType.custom,
      allowedExtensions: ['txt'],
      bytes: contentBytes,
    );

    if (path != null) {
      debugPrint('File saved to: $path');
    } else {
      debugPrint('User canceled save');
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
      bottomNavigationBar: IrmaBottomBar(
        primaryButtonLabel: 'mfa.export.as_file',
        secondaryButtonLabel: 'mfa.export.as_google',
        onPrimaryPressed: codesSelected.isNotEmpty ? handleFileExportList : null,
        onSecondaryPressed: codesSelected.isNotEmpty ? goToGoogleAuthCode : null,
        alignment: IrmaBottomBarAlignment.vertical,
      ),
      body: SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.all(theme.defaultSpacing),
        child: Column(spacing: theme.defaultSpacing, children: [
          TranslatedText('mfa.export.explanation'),
          Column(
            spacing: theme.defaultSpacing,
            children: codes
                .map(
                  (entry) => InkWell(
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
        ]),
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
