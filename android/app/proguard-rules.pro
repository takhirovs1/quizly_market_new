# Flutter Proguard Rules
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.internal.** { *; }
-keep class io.flutter.embedding.** { *; }
-keep class io.flutter.plugins.** { *; }
-dontwarn io.flutter.embedding.**

# Suppress missing class warnings from dependencies
-dontwarn androidx.window.extensions.**
-dontwarn androidx.window.sidecar.**
-dontwarn com.github.dart_lang.jni_flutter.**
-dontwarn dev.fluttercommunity.plus.share.**
-dontwarn io.flutter.embedding.engine.plugins.lifecycle.**
-dontwarn io.flutter.plugins.firebase.auth.**
-dontwarn io.flutter.plugins.firebase.crashlytics.**
-dontwarn io.flutter.plugins.flutter_plugin_android_lifecycle.**
