# ProGuard rules for Laffah app release build

-dontwarn com.google.android.play.**
-dontwarn io.flutter.embedding.engine.deferredcomponents.**
-dontwarn org.slf4j.**
-dontwarn com.google.protobuf.**
-dontwarn javax.annotation.**
-dontwarn org.codehaus.mojo.animal_sniffer.**

# Keep Flutter & Maps classes
-keep class io.flutter.** { *; }
-keep class com.google.android.gms.** { *; }
-keep class com.google.maps.android.** { *; }
