
# ProMarket Flutter App

## Prerequisites
- Flutter stable (>=3.0)
- Firebase project configured

## Setup
1. `flutter pub get`
2. Add `google-services.json` (android) and `GoogleService-Info.plist` (iOS) to respective folders.
3. For web, ensure Firebase config is set and add authorized redirect URIs in Google Cloud (see docs).
4. Run locally: `flutter run -d chrome --web-port=5000`

## Features & Roles

### Client
- Browse services
- Book appointments (Select Date/Time)
- Chat with providers
- Manage profile

### Employee
- View assigned jobs
- Manage bookings (Accept/Reject/Complete)
- Chat with clients

### Admin
- Manage services (Products)
- Manage employees
- View Booking Analytics

## Troubleshooting
- **Google Sign-In**: If you see `redirect_uri_mismatch`, ensure you are running on port 5000 and that `http://localhost:5000` is authorized in your Google Cloud Console Credentials.