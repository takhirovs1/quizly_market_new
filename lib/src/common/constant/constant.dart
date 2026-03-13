import 'dart:io' as io;

class Constant {
  const Constant._();

  static final appLink = (io.Platform.isIOS || io.Platform.isMacOS) ? '' : '';

  static const privacyPolicyUrl = '';
}
