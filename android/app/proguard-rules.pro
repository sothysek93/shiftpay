# Flutter Wrapper & Engine bindings
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Keep generated plugin registrants
-keep class io.flutter.plugins.GeneratedPluginRegistrant { *; }

# Google Mobile Ads / Play Services
-keep class com.google.android.gms.ads.** { *; }
-keep class com.google.ads.** { *; }

# Firebase Core & Analytics
-keep class com.google.firebase.** { *; }

# Keep Dart JNI & native calls
-dontwarn io.flutter.embedding.**

# Retain line numbers and annotations for crash stack traces
-keepattributes SourceFile,LineNumberTable,*Annotation*,Signature,InnerClasses,EnclosingMethod
-renamesourcefileattribute SourceFile

-keepclassmembers enum * { *; }
-dontwarn javax.annotation.**
-dontwarn org.codehaus.mojo.animal_sniffer.**
