import 'package:flutter/foundation.dart';

enum AppLanguage { en, bn }

final ValueNotifier<AppLanguage> appLanguage =
    ValueNotifier<AppLanguage>(AppLanguage.en);

void toggleAppLanguage() {
  appLanguage.value =
      appLanguage.value == AppLanguage.en ? AppLanguage.bn : AppLanguage.en;
}
