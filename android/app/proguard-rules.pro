# ==============================================================================
# Flutter Core Rules
# ==============================================================================
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# ==============================================================================
# Google Play Games Services (GPGS v2)
# ==============================================================================
-keep class com.google.android.gms.games.** { *; }
-keep interface com.google.android.gms.games.** { *; }
-keep class com.google.android.gms.common.** { *; }
-keep class com.google.android.gms.tasks.** { *; }
-keep class com.google.android.gms.auth.** { *; }

# ==============================================================================
# Google Mobile Ads (AdMob)
# ==============================================================================
-keep class com.google.android.gms.ads.** { *; }
-keep interface com.google.android.gms.ads.** { *; }

# ==============================================================================
# In-App Purchase (Google Play Billing)
# ==============================================================================
-keep class com.android.vending.billing.** { *; }

# ==============================================================================
# Native Crash Channel (MainActivity)
# ==============================================================================
-keepclassmembers class txa.zerogrid.quantumshift.MainActivity { *; }
