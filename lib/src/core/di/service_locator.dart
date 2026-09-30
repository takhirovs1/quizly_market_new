import 'package:get_it/get_it.dart';

import '../services/web_update_notifier.dart';
import '../services/web_update_service.dart';

final getIt = GetIt.instance;

void setupServiceLocator() {
  if (!getIt.isRegistered<WebUpdateService>()) {
    getIt.registerLazySingleton<WebUpdateService>(WebUpdateService.new);
  }
  if (!getIt.isRegistered<WebUpdateNotifier>()) {
    getIt.registerSingleton<WebUpdateNotifier>(WebUpdateNotifier());
  }
}
