import 'package:flutter/cupertino.dart';

import '../models/mfa_events.dart';
import 'irma_repository.dart';

class MfaRepository {
  final IrmaRepository irmaRepository;

  MfaRepository({required this.irmaRepository});

  void storeTOTP(TOTPStored code) {
    irmaRepository.bridgedDispatch(AddTOTPSecretEvent(totpStored: code));
  }

  void getAllTOTP() {
    irmaRepository.bridgedDispatch(GetAllTOTPSecretsEvent());
  }
}
