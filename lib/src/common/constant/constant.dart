import 'dart:io' as io;

class Constant {
  const Constant._();

  static final appLink = (io.Platform.isIOS || io.Platform.isMacOS) ? '' : '';

  static const privacyPolicyUrl = '';
  static const packageUi = 'ui';

  static const botUrl = 'https://t.me/prjkttest_bot';
  static const appShortName = 'app';

  static String get miniAppUrl {
    final username = botUrl.split('/').last;
    return 'https://t.me/$username/$appShortName';
  }
}
