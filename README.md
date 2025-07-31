# Math Alarm Clock

A Flutter alarm clock app that requires solving math problems to turn off the alarm. This app uses `android_alarm_manager_plus` to manage background alarm processes and ensures users are fully awake before turning off the alarm.

## Features

- ⏰ Set multiple alarms with custom labels
- 🧮 Math challenges to turn off alarms (addition, subtraction, multiplication, division)
- 🔄 One-time or recurring alarms (weekday selection)
- 📱 Background alarm management using `android_alarm_manager_plus`
- 🔔 Local notifications when alarms trigger
- 🎵 Audio feedback and vibration
- 💾 Persistent alarm storage using SharedPreferences

## Project Structure

```
lib/
├── main.dart                 # App entry point
├── models/                   # Data models
│   ├── alarm.dart           # Alarm model
│   └── math_problem.dart    # Math problem generator
├── services/                 # Business logic services
│   ├── alarm_service.dart   # Alarm management
│   ├── audio_service.dart   # Sound and vibration
│   └── notification_service.dart # Local notifications
├── screens/                  # UI screens
│   ├── home_screen.dart     # Main alarm list screen
│   └── add_alarm_screen.dart # Add/edit alarm screen
├── widgets/                  # Reusable UI components
│   ├── alarm_list_item.dart # Individual alarm display
│   └── math_challenge_dialog.dart # Math problem dialog
└── utils/                    # Utility functions
    └── time_utils.dart      # Time formatting and calculations
```

## Key Dependencies

- `android_alarm_manager_plus: ^4.0.5` - Background alarm scheduling
- `flutter_local_notifications: ^17.2.2` - Push notifications
- `shared_preferences: ^2.2.2` - Local data persistence
- `audioplayers: ^6.1.0` - Audio playback

## How It Works

1. **Alarm Scheduling**: Uses `AndroidAlarmManager` to schedule exact alarms that wake the device
2. **Background Callback**: When an alarm triggers, a top-level callback function is executed
3. **Math Challenge**: Users must solve 3 random math problems to turn off the alarm
4. **Persistence**: Alarm settings are saved locally and restored on app restart

## Math Problems

The app generates random math problems with these operations:
- **Addition**: Numbers 1-50
- **Subtraction**: Ensures positive results
- **Multiplication**: Numbers 1-12 (times tables)
- **Division**: Uses multiplication facts for clean division

## Android Configuration

The app includes necessary Android permissions and services:

### Permissions (AndroidManifest.xml)
- `WAKE_LOCK` - Keep device awake for alarms
- `RECEIVE_BOOT_COMPLETED` - Restore alarms after reboot
- `VIBRATE` - Vibration feedback
- `USE_FULL_SCREEN_INTENT` - Full-screen alarm notifications
- `POST_NOTIFICATIONS` - Show notifications

### Services
- `AlarmService` - Background alarm processing
- `AlarmBroadcastReceiver` - Alarm event handling
- `RebootBroadcastReceiver` - Restore alarms after reboot

## Usage

1. **Add Alarm**: Tap the + button to create a new alarm
2. **Set Time**: Choose the alarm time using the time picker
3. **Configure**: Set label, one-time vs recurring, and weekdays
4. **Activate**: Toggle alarms on/off from the main screen
5. **Solve Math**: When alarm rings, solve 3 math problems to turn it off

## Development Notes

- Uses Material 3 design system
- Follows clean architecture principles with separation of concerns
- Implements proper error handling and user feedback
- Includes animations and visual feedback for better UX
- Handles app lifecycle events for alarm management

## Building and Running

1. Ensure Flutter SDK is installed
2. Run `flutter pub get` to install dependencies
3. Connect an Android device or start an emulator
4. Run `flutter run` to build and install the app

## Troubleshooting Alarm Permissions

### Common Issues and Solutions

#### 1. Alarms Not Working / Permission Errors

**Symptoms:**
- Error message: "Error saving alarm" 
- Alarms don't trigger at the set time
- App crashes when setting alarms

**Solutions:**

1. **Grant Exact Alarm Permission (Android 12+)**
   - Go to **Settings** > **Apps** > **Math Alarm Clock** > **Special app access** > **Alarms & reminders**
   - Enable "Allow setting alarms and reminders"
   - Or use the app's built-in permission checker (Menu > Check Permissions)

2. **Disable Battery Optimization**
   - Go to **Settings** > **Apps** > **Math Alarm Clock** > **Battery** > **Battery optimization**
   - Select "Don't optimize" or "Unrestricted"
   - This prevents Android from killing the app in the background

3. **Enable Notifications**
   - Go to **Settings** > **Apps** > **Math Alarm Clock** > **Notifications**
   - Enable all notification categories
   - Set importance to "High" for alarm notifications

4. **Auto-start Permission (Some Manufacturers)**
   - On Xiaomi/MIUI: **Settings** > **Apps** > **Manage apps** > **Math Alarm Clock** > **Other permissions** > **Auto-start**
   - On Huawei/EMUI: **Settings** > **Apps** > **Apps** > **Math Alarm Clock** > **App launch** > **Manage manually**

#### 2. App-Specific Permission Check

The app includes a built-in permission checker:
1. Open the app
2. Tap the **menu button** (three dots) in the top-right
3. Select **"Check Permissions"**
4. Follow the prompts to grant required permissions

#### 3. Manual Permission Grant

If the automatic permission request doesn't work:

1. **Exact Alarms (Android 12+):**
   ```
   Settings > Apps & notifications > Special app access > 
   Alarms & reminders > Math Alarm Clock > Allow
   ```

2. **Battery Optimization:**
   ```
   Settings > Apps > Math Alarm Clock > Battery > 
   Battery optimization > Don't optimize
   ```

3. **Notifications:**
   ```
   Settings > Apps > Math Alarm Clock > Notifications > 
   Enable all categories
   ```

#### 4. Testing Alarms

- Use the **"Test Math Challenge"** button to verify the math dialog works
- Set a test alarm for 1-2 minutes in the future
- Keep the app open initially to verify it works
- Check if notifications appear when the alarm triggers

#### 5. Device-Specific Issues

**Samsung:**
- Disable "Put unused apps to sleep" in Device Care > Battery > Background app limits

**Xiaomi/MIUI:**
- Enable "Autostart" permission
- Disable "Battery Saver" for the app
- Add the app to "Protected apps" list

**Huawei/EMUI:**
- Enable "App launch" management
- Add to "Protected apps"
- Disable "Battery optimization"

### Still Having Issues?

1. Restart your device after granting permissions
2. Try setting the alarm while keeping the app open
3. Check Android version compatibility (requires Android 7.0+)
4. Ensure the app is updated to the latest version

Note: This app is designed for Android and uses platform-specific alarm management features.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
