# Migration Guide: From Supabase to Firebase

This guide outlines the steps to migrate the SafarioX project from Supabase to Firebase.

## 1. Firebase Project Setup
1. Go to the [Firebase Console](https://console.firebase.google.com/).
2. Click **Add project** and follow the instructions.
3. Enable **Authentication** in the Build section.
   - Go to **Sign-in method**.
   - Enable **Phone** (since the project uses OTP).
4. Enable **Cloud Firestore** in the Build section.
   - Create a database in **Production mode** or **Test mode**.
   - Choose a location.

## 2. Flutter Configuration
1. Install the Firebase CLI if you haven't: `npm install -g firebase-tools`.
2. Log in to Firebase: `firebase login`.
3. Install the FlutterFire CLI: `dart pub global activate flutterfire_cli`.
4. Run the configuration command in your project root:
   ```bash
   flutterfire configure
   ```
   - Select your project.
   - Select the platforms (Android, iOS, Web).
   - This will create `firebase_options.dart` in `lib/`.

## 3. Dependency Updates
Remove Supabase and add Firebase dependencies in `pubspec.yaml`:
```yaml
dependencies:
  firebase_core: ^3.10.1
  firebase_auth: ^5.4.1
  cloud_firestore: ^5.6.1
  # Remove: supabase_flutter
```

## 4. Code Migration

### A. Initialization (`lib/main.dart`)
Replace Supabase initialization with Firebase:
```dart
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}
```

### B. Authentication (`lib/screens/auth/`)
- **Login Page:** Use `FirebaseAuth.instance.verifyPhoneNumber`.
- **OTP Page:** Use `PhoneAuthProvider.credential` and `signInWithCredential`.

### C. Database (`lib/screens/booking/`)
- Replace `Supabase.instance.client.from('bookings')` with `FirebaseFirestore.instance.collection('bookings')`.

## 5. Cleanup
1. Remove the `supabase/` directory.
2. Remove Supabase environment variables from `.env`.
3. Delete any remaining Supabase-specific logic or imports.
