# Firebase Integration Guide - دليل ربط Firebase

## مشروع Firebase المستخدم

- **Project ID**: `sagovlaws`
- **Project Name**: SaGovLaws
- **Region**: 🌍 Global
- **Console**: https://console.firebase.google.com/project/sagovlaws

---

## Firebase Configuration

### Web Configuration (Flutter Web)
```javascript
const firebaseConfig = {
  apiKey: "AIzaSyCi2JL9S7D-bQ00ZwiercOpfTSDczJ9ZJI",
  authDomain: "sagovlaws.firebaseapp.com",
  projectId: "sagovlaws",
  storageBucket: "sagovlaws.firebasestorage.app",
  messagingSenderId: "1063086634234",
  appId: "1:1063086634234:web:d9e5539350769e9f5f8543",
  measurementId: "G-CB2JBRL65C"
};
```

### Flutter Configuration
```dart
static const FirebaseOptions web = FirebaseOptions(
  apiKey: 'AIzaSyCi2JL9S7D-bQ00ZwiercOpfTSDczJ9ZJI',
  appId: '1:1063086634234:web:d9e5539350769e9f5f8543',
  messagingSenderId: '1063086634234',
  projectId: 'sagovlaws',
  authDomain: 'sagovlaws.firebaseapp.com',
  storageBucket: 'sagovlaws.firebasestorage.app',
);
```

### Backend (Node.js) Configuration
```javascript
const firebaseConfig = {
  apiKey: "AIzaSyCi2JL9S7D-bQ00ZwiercOpfTSDczJ9ZJI",
  authDomain: "sagovlaws.firebaseapp.com",
  projectId: "sagovlaws",
  storageBucket: "sagovlaws.firebasestorage.app",
  messagingSenderId: "1063086634234",
  appId: "1:1063086634234:web:d9e5539350769e9f5f8543"
};
```

---

## Firebase Services Used

### 1. **Authentication** 🔐
- **Service**: Firebase Authentication
- **URL**: https://console.firebase.google.com/project/sagovlaws/authentication/providers
- **Supported Methods**:
  - Email/Password
  - Google Sign-In
  - Phone Authentication (Optional)

### 2. **Database** 📊
- **Service**: Cloud Firestore
- **URL**: https://console.firebase.google.com/project/sagovlaws/firestore
- **Collections**:
  - `users` - User profiles and data
  - `articles` - Legal articles and documents
  - `sources` - Sources/publishers
  - `favorites` - User favorite articles
  - `notifications` - User notifications

### 3. **Storage** 📁
- **Service**: Cloud Storage
- **URL**: https://console.firebase.google.com/project/sagovlaws/storage
- **Buckets**:
  - `sagovlaws.firebasestorage.app` - Main storage bucket for documents and PDFs

### 4. **Analytics** 📈
- **Service**: Google Analytics
- **URL**: https://console.firebase.google.com/project/sagovlaws/analytics
- **Measurement ID**: `G-CB2JBRL65C`

### 5. **Hosting** 🌐
- **Service**: Firebase Hosting
- **URL**: https://sagovlaws.web.app (if deployed)
- **Domain**: sagovlaws.firebaseapp.com

---

## Files Setup

### 1. Flutter Configuration Files
```
flutter_app/
├── lib/
│   ├── firebase_options.dart    ✓ Already configured
│   └── main.dart               ✓ Firebase initialized
└── web/
    ├── index.html              ✓ Firebase SDK added
    └── firebase-config.js      ✓ Web configuration
```

### 2. Backend Configuration Files
```
backend/
├── firebase-config.js          ✓ Node.js configuration
├── firebase.json              ✓ Firebase deployment config
├── firestore.rules            ✓ Firestore security rules
└── storage.rules              ✓ Storage security rules
```

---

## Security Rules

### Firestore Rules (`firestore.rules`)
Located at: `./firestore.rules`
- Ensures only authenticated users can read/write their data
- Admin access for specific operations

### Storage Rules (`storage.rules`)
Located at: `./storage.rules`
- Ensures only authenticated users can upload/download files
- File size and format restrictions

---

## Environment Variables

Create a `.env` file in the backend directory:

```bash
# Firebase Configuration
FIREBASE_PROJECT_ID=sagovlaws
FIREBASE_API_KEY=AIzaSyCi2JL9S7D-bQ00ZwiercOpfTSDczJ9ZJI
FIREBASE_AUTH_DOMAIN=sagovlaws.firebaseapp.com
FIREBASE_STORAGE_BUCKET=sagovlaws.firebasestorage.app

# Service Account (for backend)
GOOGLE_APPLICATION_CREDENTIALS=./serviceAccountKey.json
```

---

## Deployment

### Firebase Hosting Deployment
```bash
# Install Firebase CLI (if not already installed)
npm install -g firebase-tools

# Login to Firebase
firebase login

# Deploy Flutter Web
firebase deploy --only hosting

# Deploy Cloud Functions (backend)
firebase deploy --only functions

# Deploy Firestore rules
firebase deploy --only firestore:rules

# Deploy Storage rules
firebase deploy --only storage
```

### Backend Deployment
```bash
# Deploy to Firebase Cloud Functions
cd backend
npm install
firebase deploy --only functions
```

---

## Testing Firebase Connection

### Test Web Configuration
Open browser console and run:
```javascript
// Check if Firebase is initialized
console.log(app);
console.log(analytics);
console.log(auth);
console.log(db);
console.log(storage);
```

### Test Flutter Configuration
```dart
import 'package:firebase_core/firebase_core.dart';

// Check Firebase initialization
print('Firebase initialized: ${Firebase.apps.isNotEmpty}');
print('Current app: ${Firebase.app().options.projectId}');
```

---

## Important Links

| Service | URL |
|---------|-----|
| Firebase Console | https://console.firebase.google.com/project/sagovlaws |
| Authentication | https://console.firebase.google.com/project/sagovlaws/authentication |
| Firestore | https://console.firebase.google.com/project/sagovlaws/firestore |
| Storage | https://console.firebase.google.com/project/sagovlaws/storage |
| Analytics | https://console.firebase.google.com/project/sagovlaws/analytics |
| Hosting | https://console.firebase.google.com/project/sagovlaws/hosting |

---

## Troubleshooting

### Issue: Firebase not initializing
- ✓ Check that `google-services.json` (Android) and `GoogleService-Info.plist` (iOS) are properly added
- ✓ Verify Firebase configuration matches the project ID

### Issue: Authentication not working
- ✓ Enable authentication method in Firebase Console
- ✓ Check security rules in Firestore and Storage

### Issue: Firestore/Storage access denied
- ✓ Review and update security rules
- ✓ Verify user authentication status
- ✓ Check user permissions in Firebase Console

---

## Last Updated
- Date: 2025-12-09
- By: GitHub Copilot
- Status: ✅ Configuration Complete
