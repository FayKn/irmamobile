import '../models/mfa_events.dart';
import 'irma_repository.dart';

class MfaRepository {
  final IrmaRepository irmaRepository;

  MfaRepository({required this.irmaRepository});

  void storeTOTP(TOTPStored code) {
    irmaRepository.bridgedDispatch(AddTOTPSecretEvent(totpStored: code));
  }

  void storeTOTPByURL(String url) {
    irmaRepository.bridgedDispatch(StoreTOTPSecretByURLEvent(inputUrl: url));
  }

  void getAllTOTP() {
    irmaRepository.bridgedDispatch(GetAllTOTPSecretsEvent());
  }

  void removeTOTP(TOTPcode code) {
    irmaRepository.bridgedDispatch(RemoveTOTPSecretEvent(code: code));
  }
}
