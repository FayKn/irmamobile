import '../models/mfa_events.dart';
import 'irma_repository.dart';

class MfaRepository {
  final IrmaRepository irmaRepository;

  MfaRepository({required this.irmaRepository});

  void storeTOTP(TOTPStored code) {
    irmaRepository.bridgedDispatch(AddTOTPSecretEvent(totpStored: code));
  }

  void exportTOTP() {
    irmaRepository.bridgedDispatch(ExportSecretsEvent());
  }

  void exportTOTPToURL(List<TOTPStored> secrets, {bool isGoogle = true}) {
    irmaRepository.bridgedDispatch(ExportSecretsInputToUrlEvent(secrets: secrets, isGoogle: isGoogle));
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

  void encryptExportFile(String password, String encryptedFile) {
    irmaRepository.bridgedDispatch(EncryptExportFileSendEvent(password: password, encryptedFile: encryptedFile));
  }

  void decryptExportFile(String password, String encryptedFile) {
    irmaRepository.bridgedDispatch(DecryptExportFileSendEvent(password: password, encryptedFile: encryptedFile));
  }
}
