class MFASecret {
  String issuer;
  String secret;
  int period;
  String userAccount;
  String algorithm;
  int timerProgress;
  int? code;
  int? nextCode;

  MFASecret({
    required this.issuer,
    required this.secret,
    required this.period,
    required this.userAccount,
    this.algorithm = 'SHA1',
    this.timerProgress = 0,
    this.code,
    this.nextCode,
  });
}
