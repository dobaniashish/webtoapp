# WebToApp

Convert Website to App.

This project was created for personal use. It is not intended for direct use but rather as a foundation for a new Flutter project. Copy the necessary files from this project to create a new starting point or use it as a reference in case things in flutter have changed.

I developed this project to create a service that converts websites into Android and iOS applications. It was also an opportunity to learn Flutter and Dart. I utilized Firebase for messaging and configuration storage. I had also created an admin panel to manage firebase configs easily and send push notification but that is not included in this code.

There could be lots of optimizations possible in the code since this was a project created while I was learning Flutter and Dart.

## Features

- Automatic updates with new content.
- Splash screen.
- Home screen.
- App bar & Drawer.
- Bottom navigation bar.
- AdMob integration for monetization.
- Onboarding screen.
- App rating integration.
- Pull-down to refresh feature.
- Push notifications.
- More...

## Developer information

To setup your own app, download this repo for reference and follow these steps.

1. Create a new flutter app with `flutter create --platform ios,android --org com.example webtoapp`
1. Copy `lib` directory
1. Copy `assets` directory
1. Copy `pubspec.yaml` directory
1. Create launcher icons with `flutter pub run flutter_launcher_icons` <https://pub.dev/packages/flutter_launcher_icons>
1. Create splash with `dart run flutter_native_splash:create` <https://pub.dev/packages/flutter_native_splash>
1. Configure firebase with `flutterfire configure` <https://firebase.google.com/docs/flutter/setup?platform=ios>
1. Setup Android
   1. Compare values in `\android\app\src\main\AndroidManifest.xml`
   1. Compare values in `\android\app\build.gradle`
   1. Create `\android\key.properties` with sample values below
   1. Create `\android\local.properties` with sample values below
1. Setup iOS
   1. Copy/Compare `\ios\Podfile`
   1. Copy/Compare values into `\ios\Runner\Info.plist` with sample values below
   1. Add deep link support
      1. Open xcode
      1. Go to the Project navigator (Cmd+1) and select the Runner root item at the very top.
      1. Select the Runner target and then the Signing & Capabilities tab.
      1. Click the + Capability (plus) button to add a new capability.
      1. Type 'associated domains` and select the item.
      1. Double-click the first item in the Domains list and change it from webcredentials:example.com to: applinks: + your host (ex: my-fancy-domain.com).
      1. A file called Runner.entitlements will be created and added to the project.

### Setup firebase

Create a new Remote Config in firebase with the name `settings` and add default values from `firebase-default-settings.json`.

To understand what each setting mean, refer the file `firebase-settings-structure.json`.

### Sample `key.properties`

```
storePassword=
keyPassword=
keyAlias=
storeFile=
```

### Sample `local.properties`

```
flutter.minSdkVersion=21
flutter.targetSdkVersion=34
flutter.compileSdkVersion=34
```

### Values for `Info.plist`

```
<key>UIStatusBarHidden</key>
<false/>

<!-- flutter_inappwebview uploader -->
<key>NSMicrophoneUsageDescription</key>
<string>App requires access to microphone.</string>
<key>NSCameraUsageDescription</key>
<string>App requires access to camera.</string>

<!-- flutter_inappwebview location -->
<key>NSLocationWhenInUseUsageDescription</key>
<string>App requires access to location when in use.</string>
<key>NSLocationUsageDescription</key>
<string>App requires access to location.</string>

<!-- google_mobile_ads -->
<!-- Sample AdMob app ID: ca-app-pub-3940256099942544~3347511713 -->
<key>GADApplicationIdentifier</key>
<string>ca-app-pub-3940256099942544~3347511713</string>

<!-- Disable impeller engine -->
<key>FLTEnableImpeller</key>
<false/>

<!-- Enable background modes -->
<key>UIBackgroundModes</key>
<array>
	<string>fetch</string>
	<string>remote-notification</string>
</array>
```
