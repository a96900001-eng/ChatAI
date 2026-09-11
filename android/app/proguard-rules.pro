-keep class com.capacitorjs.** { *; }
-keep class * extends com.capacitorjs.core.Plugin { *; }
-keep @interface com.capacitorjs.** { *; }
-dontwarn com.capacitorjs.**

-keep class org.chromium.** { *; }
-dontwarn org.chromium.**
