import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

import '../../data/irma_repository.dart';
import '../../data/mfa_repository.dart';
import '../../models/mfa_events.dart';
import '../../providers/irma_repository_provider.dart';
import '../../theme/theme.dart';
import '../../widgets/irma_app_bar.dart';
import '../../widgets/irma_bottom_bar.dart';
import 'widgets/mfa_password_popup.dart';
import 'widgets/totp_manual_text_input.dart';

class MfaManualEntryTab extends StatefulWidget {
  @override
  State<MfaManualEntryTab> createState() => _MfaManualEntryTabState();
}

enum Algorithm {
  sha1('SHA1'),
  sha256('SHA256'),
  sha512('SHA512');

  final String label;

  const Algorithm(this.label);
}

class _MfaManualEntryTabState extends State<MfaManualEntryTab> {
  late IrmaRepository _irmaRepo;
  late MfaRepository _mfaRepo;
  bool _reposInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_reposInitialized) {
      _irmaRepo = IrmaRepositoryProvider.of(context);
      _mfaRepo = MfaRepository(irmaRepository: _irmaRepo);
      _reposInitialized = true;
    }
  }

  final _manualEntryFormKey = GlobalKey<FormState>();

  final _issuerCtrl = TextEditingController();
  final _secretCtrl = TextEditingController();
  final _userNameCtrl = TextEditingController();
  final _periodCtrl = TextEditingController(text: '30');

  Algorithm? _selectedAlgorithm = Algorithm.sha1;

  bool _canContinue = false; // soft validity during typing

  void _recomputeCanContinue() {
    // Keep this light: avoid calling validate() here.
    final issuerOk = _issuerCtrl.text.isNotEmpty;
    final secretOk = _secretCtrl.text.isNotEmpty;
    final userOk = _userNameCtrl.text.isNotEmpty;
    final periodOk = int.tryParse(_periodCtrl.text) != null;

    final can = issuerOk && secretOk && userOk && periodOk;
    if (can != _canContinue) {
      setState(() => _canContinue = can);
    }
  }

  void _onContinuePressed() {
    if (_manualEntryFormKey.currentState!.validate()) {
      final issuer = _issuerCtrl.text;
      final secret = _secretCtrl.text;
      final user = _userNameCtrl.text;
      final period = int.tryParse(_periodCtrl.text) ?? 30;
      final algorithm = _selectedAlgorithm?.label ?? 'SHA1';
      final code = TOTPStored(secret: secret, issuer: issuer, userAccount: user, period: period, algorithm: algorithm);
      _mfaRepo.storeTOTP(code);
      Navigator.of(context).pop();
    }
  }

  void _handleFileImport() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      File file = File(result.files.single.path!);

      var password = await showPasswordDialog(context, 'mfa.export.password_popup_confirm');
      if (password == null || password.isEmpty) {
        return;
      }

      var fileStr = await file.readAsString();
      _mfaRepo.decryptExportFile(password, fileStr);

      try {
        // Wait for the event with the codes
        final event =
            await _irmaRepo.getEvents().whereType<EncryptExportFileReceiveEvent>().first.timeout(Duration(seconds: 2));
        if (event.content.isNotEmpty) {
          var codes = fileToStoredList(event.content);
          for (var code in codes) {
            _mfaRepo.storeTOTP(code);
          }
          Navigator.of(context).pop();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('mfa.import.error')));
        }
      } catch (e) {
        debugPrint('Failed to import codes: $e');
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('mfa.import.error')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = IrmaTheme.of(context);

    return Scaffold(
      backgroundColor: theme.backgroundTertiary,
      appBar: IrmaAppBar(titleTranslationKey: 'mfa.manual.title'),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          child: Form(
            key: _manualEntryFormKey,
            onChanged: () {
              _recomputeCanContinue();
            },
            child: Padding(
              padding: EdgeInsets.all(theme.defaultSpacing * 2),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TotpManualTextInput(
                      key: Key('mfa_manual_issuer_input'),
                      controller: _issuerCtrl,
                      translationKey: 'mfa.manual.issuer',
                      inputKey: 'issuer',
                      formatter: Formatters.special,
                    ),
                    SizedBox(height: theme.defaultSpacing * 2),
                    TotpManualTextInput(
                      key: Key('mfa_manual_secret_input'),
                      controller: _secretCtrl,
                      translationKey: 'mfa.manual.secret',
                      inputKey: 'secret',
                    ),
                    SizedBox(height: theme.defaultSpacing * 2),
                    TotpManualTextInput(
                      key: Key('mfa_manual_account_input'),
                      controller: _userNameCtrl,
                      translationKey: 'mfa.manual.account',
                      inputKey: 'account',
                      formatter: Formatters.special,
                    ),
                    SizedBox(height: theme.defaultSpacing * 2),
                    Row(
                      children: [
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(top: 10),
                            child: TotpManualTextInput(
                              controller: _periodCtrl,
                              translationKey: 'mfa.manual.period',
                              inputKey: 'period',
                              formatter: Formatters.numerical,
                            ),
                          ),
                        ),
                        Spacer(
                          flex: 1,
                        ),
                        DropdownMenu<Algorithm>(
                          initialSelection: _selectedAlgorithm,
                          label: Text('Algorithm', style: theme.textTheme.bodySmall!.copyWith(fontSize: 14)),
                          textStyle: theme.textTheme.bodySmall!.copyWith(fontWeight: FontWeight.normal),
                          onSelected: (Algorithm? algo) {
                            setState(() {
                              _selectedAlgorithm = algo;
                            });
                          },
                          dropdownMenuEntries: Algorithm.values.map<DropdownMenuEntry<Algorithm>>((Algorithm algo) {
                            return DropdownMenuEntry<Algorithm>(
                              value: algo,
                              label: algo.label,
                              style: MenuItemButton.styleFrom(textStyle: theme.textTheme.bodySmall),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: IrmaBottomBar(
        primaryButtonLabel: 'mfa.export.password_popup_confirm',
        onPrimaryPressed: _canContinue ? _onContinuePressed : null,
        secondaryButtonLabel: 'mfa.export.import_file',
        onSecondaryPressed: _handleFileImport,
        alignment: IrmaBottomBarAlignment.horizontal,
      ),
    );
  }
}
