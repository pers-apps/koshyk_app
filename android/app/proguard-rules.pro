# Flutter wrapper
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-dontwarn io.flutter.embedding.**

# Keep native methods
-keepclassmembers class * {
    native <methods>;
}

# Kotlin
-keep class kotlin.** { *; }
-dontwarn kotlin.**

# SQLite / sqflite
-keep class com.tekartik.sqflite.** { *; }

# in_app_purchase / billing
-keep class com.android.billingclient.** { *; }
-dontwarn com.android.billingclient.**

# Google Play services
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.android.gms.**

# Keep enums
-keepclassmembers enum * {
    public static **[] values();
    public static ** valueOf(java.lang.String);
}

# Serializable
-keepnames class * implements java.io.Serializable
-keepclassmembers class * implements java.io.Serializable {
    static final long serialVersionUID;
    private static final java.io.ObjectStreamField[] serialPersistentFields;
    !static !transient <fields>;
    private void writeObject(java.io.ObjectOutputStream);
    private void readObject(java.io.ObjectInputStream);
    java.lang.Object writeReplace();
    java.lang.Object readResolve();
}
