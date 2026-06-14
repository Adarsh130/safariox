# SafariOX

SafariOX is a mobile application for browsing and booking tours. It's built with Flutter and uses Supabase for the backend.

## Project Status

**This project is in an early stage of development and is not yet feature-complete. The project structure is unconventional, with most of the code residing in the `screens` directory. There is a lack of separation of concerns, with business logic, UI, and data models all contained within the screen files. This is not a recommended practice for Flutter development and will be refactored in the future.**

## Features

*   **User Authentication:**
    *   Users can sign up and log in using an OTP (One-Time Password) sent to their mobile number.
    *   Users can log out of the application.
*   **Tour Management:**
    *   Users can browse a list of available tours on the `tours_page.dart`.
    *   Users can view the details of a specific tour.
*   **Booking Management:**
    *   Users can book a tour from the `booking_page.dart`.
    *   Users can view their existing bookings on the `bookings_page.dart`.
*   **Profile Management:**
    *   Users can view and manage their profile on the `profile_page.dart`.
*   **Location-based Services:**
    *   The app uses the `geolocator` package to get the device's location.
    *   The `permission_handler` package is used to request location permissions.
*   **Local Notifications:**
    *   The `flutter_local_notifications` package is used to send local notifications to the user.

## Tech Stack

*   **Frontend:** Flutter - A UI toolkit for building natively compiled applications for mobile, web, and desktop from a single codebase.
*   **Backend:** Supabase - An open-source Firebase alternative for building secure and scalable backends.
*   **State Management:** Riverpod - A reactive state management and dependency injection framework for Flutter.
*   **Routing:** go_router - A declarative routing package for Flutter that simplifies navigation and deep linking.
*   **Environment Variables:** flutter_dotenv - A package for loading environment variables from a `.env` file.
*   **Location:** geolocator - A Flutter plugin for getting the device's location.
*   **Permissions:** permission_handler - A Flutter plugin for requesting and checking permissions.
*   **Notifications:** flutter_local_notifications - A Flutter plugin for showing local notifications.
*   **Local Storage:** shared_preferences - A Flutter plugin for reading and writing simple key-value pairs.

## Getting Started

1.  **Clone the repository:**
    ```bash
    git clone https://github.com/your-username/safariox.git
    ```
2.  **Install dependencies:**
    ```bash
    flutter pub get
    ```
3.  **Set up environment variables:**
    Create a `.env` file in the root of the project and add the following:
    ```
    SUPABASE_URL=your_supabase_url
    SUPABASE_ANON_KEY=your_supabase_anon_key
    ```
4.  **Run the app:**
    ```bash
    flutter run
    ```

## Project Structure

The project is structured as follows:

```
lib/
├── main.dart
├── models/ (currently empty)
├── screens/
│   ├── auth/
│   │   ├── login_page.dart
│   │   └── otp_page.dart
│   ├── booking/
│   │   ├── booking_page.dart
│   │   └── bookings_page.dart
│   ├── home/
│   │   └── home_page.dart
│   ├── profile/
│   │   └── profile_page.dart
│   ├── splash/
│   │   └── splash_screen.dart
│   ├── tours/
│   │   └── tours_page.dart
│   └── welcome/
├── services/ (currently empty)
├── utils/ (currently empty)
└── widgets/
```

*   `main.dart`: The entry point of the application.
*   `models`: Contains the data models for the application (currently empty).
*   `screens`: Contains the UI screens of the application.
    *   `auth`: Contains the authentication screens (login and OTP).
    *   `booking`: Contains the booking screens (create and view bookings).
    *   `home`: Contains the main screen of the app.
    *   `profile`: Contains the user profile screen.
    *   `splash`: Contains the splash screen.
    *   `tours`: Contains the tour browsing screen.
    *   `welcome`: Contains the welcome screens.
*   `services`: Contains the business logic and API calls (currently empty).
*   `utils`: Contains utility functions (currently empty).
*   `widgets`: Contains reusable UI components.
