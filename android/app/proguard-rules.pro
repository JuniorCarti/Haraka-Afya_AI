# Stripe ProGuard Rules
-keep class com.stripe.android.** { *; }
-keep class com.reactnativestripesdk.** { *; }
-keep class com.stripe.android.pushProvisioning.** { *; }

# Keep all classes in the pushprovisioning package
-keep class com.stripe.android.pushProvisioning.** { *; }

# Keep the specific missing classes mentioned in the error
-keep class com.stripe.android.pushProvisioning.PushProvisioningActivity$g { *; }
-keep class com.stripe.android.pushProvisioning.PushProvisioningActivityStarter$Args { *; }
-keep class com.stripe.android.pushProvisioning.PushProvisioningActivityStarter$Error { *; }
-keep class com.stripe.android.pushProvisioning.PushProvisioningActivityStarter { *; }
-keep class com.stripe.android.pushProvisioning.PushProvisioningEphemeralKeyProvider { *; }

# Keep React Native Stripe SDK classes
-keep class com.reactnativestripesdk.pushprovisioning.** { *; }
-keep class com.reactnativestripesdk.pushprovisioning.DefaultPushProvisioningProxy { *; }
-keep class com.reactnativestripesdk.pushprovisioning.PushProvisioningProxy { *; }

# Don't warn about missing Stripe classes
-dontwarn com.stripe.android.**
-dontwarn com.reactnativestripesdk.**