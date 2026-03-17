# Flutter
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# just_audio / ExoPlayer / Media3
-keep class com.google.android.exoplayer2.** { *; }
-keep class androidx.media3.** { *; }

# in_app_purchase
-keep class com.android.vending.billing.** { *; }

# Play Core (deferred components)
-dontwarn com.google.android.play.core.**
-keep class com.google.android.play.core.** { *; }
