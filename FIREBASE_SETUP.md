# Firebase Setup and Usage Guide

## Project Overview

**Project Name**: SaGovLaws (راصد أم القرى)
**Firebase Project ID**: `sagovlaws`
**Console URL**: https://console.firebase.google.com/project/sagovlaws

---

## Quick Start

### 1. Web Configuration (Already Done ✓)

The Firebase configuration for the web is already set up in:
- `flutter_app/web/firebase-config.js` - Web JavaScript configuration
- `flutter_app/web/index.html` - Updated with Firebase SDK

### 2. Flutter Configuration (Already Done ✓)

The Flutter app is already configured with:
- `flutter_app/lib/firebase_options.dart` - Platform-specific settings
- `flutter_app/lib/main.dart` - Firebase initialization in main function

### 3. Backend Configuration (Already Done ✓)

The backend is configured with:
- `backend/firebase-config.js` - Node.js Firebase configuration
- `firebase.json` - Firebase deployment configuration

---

## Firebase Services Configuration

### Authentication 🔐

**Location**: `flutter_app/lib/core/services/firebase_service.dart`

**Methods Available**:
```dart
// Sign up
FirebaseService().signUp(
  email: 'user@example.com',
  password: 'password123',
  displayName: 'User Name',
);

// Sign in
FirebaseService().signIn(
  email: 'user@example.com',
  password: 'password123',
);

// Sign out
FirebaseService().signOut();

// Get current user
User? currentUser = FirebaseService().currentUser;

// Listen to auth changes
FirebaseService().authStateChanges.listen((user) {
  if (user != null) {
    print('User logged in: ${user.email}');
  } else {
    print('User logged out');
  }
});
```

### Firestore Database 📊

**Collections Structure**:
```
users/
  {userId}/
    - uid: string
    - email: string
    - displayName: string
    - createdAt: timestamp
    - lastLogin: timestamp
    favorites/
      {articleId}/
        - articleId: string
        - addedAt: timestamp

articles/
  {articleId}/
    - title: string
    - content: string
    - source: string
    - createdAt: timestamp
    - updatedAt: timestamp

sources/
  {sourceId}/
    - name: string
    - url: string
    - category: string

notifications/
  {notificationId}/
    - userId: string
    - message: string
    - read: boolean
    - createdAt: timestamp
```

**Firestore Methods**:
```dart
// Get all articles
var articles = await FirebaseService().getArticles();

// Get single article
var article = await FirebaseService().getArticle(articleId);

// Search articles
var results = await FirebaseService().searchArticles('قانون');

// Add favorite
await FirebaseService().addFavorite(userId, articleId);

// Get user favorites
var favorites = await FirebaseService().getUserFavorites(userId);
```

### Cloud Storage 📁

**Bucket**: `sagovlaws.firebasestorage.app`

**Upload Methods**:
```dart
// Upload file
String downloadUrl = await FirebaseService().uploadFile(
  '/path/to/file.pdf',
  'document-name.pdf',
);

// Download file
await FirebaseService().downloadFile(
  downloadUrl,
  '/local/save/path.pdf',
);
```

### Google Analytics 📈

**Measurement ID**: `G-CB2JBRL65C`

**Features**:
- User engagement tracking
- Page view analytics
- Event tracking
- User demographics

---

## Security Rules

### Firestore Security Rules
Location: `firestore.rules`

```firestore
rules_version = '2';

service cloud.firestore {
  match /databases/{database}/documents {
    // Users can only read/write their own data
    match /users/{userId} {
      allow read, write: if request.auth.uid == userId;
      
      match /favorites/{document=**} {
        allow read, write: if request.auth.uid == userId;
      }
    }
    
    // Everyone can read articles
    match /articles/{document=**} {
      allow read: if true;
      allow write: if request.auth != null && request.auth.token.admin == true;
    }
    
    // Everyone can read sources
    match /sources/{document=**} {
      allow read: if true;
      allow write: if request.auth != null && request.auth.token.admin == true;
    }
  }
}
```

### Storage Security Rules
Location: `storage.rules`

```
rules_version = '2';

service firebase.storage {
  match /b/{bucket}/o {
    // Public read, authenticated write
    match /documents/{allPaths=**} {
      allow read: if true;
      allow write: if request.auth != null;
    }
    
    // User-specific uploads
    match /users/{userId}/{allPaths=**} {
      allow read, write: if request.auth.uid == userId;
    }
  }
}
```

---

## Environment Setup

### Backend Environment Variables

Create `.env` file in the backend directory:

```bash
# Firebase Configuration
FIREBASE_PROJECT_ID=sagovlaws
FIREBASE_API_KEY=AIzaSyCi2JL9S7D-bQ00ZwiercOpfTSDczJ9ZJI
FIREBASE_AUTH_DOMAIN=sagovlaws.firebaseapp.com
FIREBASE_STORAGE_BUCKET=sagovlaws.firebasestorage.app
FIREBASE_MESSAGING_SENDER_ID=1063086634234

# Service Account Key
GOOGLE_APPLICATION_CREDENTIALS=./serviceAccountKey.json

# Node Environment
NODE_ENV=development
PORT=5000
```

### Required Files

1. **Service Account Key** (for backend authentication)
   - Download from: https://console.firebase.google.com/project/sagovlaws/settings/serviceaccounts/adminsdk
   - Save as: `backend/serviceAccountKey.json`
   - **IMPORTANT**: Add to `.gitignore` to prevent exposing credentials

2. **Google Services Configuration** (for mobile)
   - Android: `android/app/google-services.json`
   - iOS: `ios/Runner/GoogleService-Info.plist`

---

## Deployment

### Deploy to Firebase Hosting

```bash
# Install Firebase CLI
npm install -g firebase-tools

# Login to Firebase
firebase login

# Build Flutter web
cd flutter_app
flutter build web

# Deploy
cd ..
firebase deploy --only hosting
```

### Deploy Firestore Rules

```bash
firebase deploy --only firestore:rules
```

### Deploy Storage Rules

```bash
firebase deploy --only storage
```

### Deploy Cloud Functions (Backend)

```bash
firebase deploy --only functions
```

---

## Testing

### Test Firebase Authentication

```dart
void testFirebaseAuth() async {
  try {
    // Sign up
    await FirebaseService().signUp(
      email: 'test@example.com',
      password: 'testPassword123',
      displayName: 'Test User',
    );
    print('✓ Sign up successful');

    // Sign out
    await FirebaseService().signOut();
    print('✓ Sign out successful');

    // Sign in
    await FirebaseService().signIn(
      email: 'test@example.com',
      password: 'testPassword123',
    );
    print('✓ Sign in successful');
  } catch (e) {
    print('✗ Error: $e');
  }
}
```

### Test Firestore Access

```dart
void testFirestore() async {
  try {
    var articles = await FirebaseService().getArticles();
    print('✓ Retrieved ${articles.docs.length} articles');
  } catch (e) {
    print('✗ Error: $e');
  }
}
```

---

## Common Issues & Solutions

### Issue 1: "Permission denied" errors
**Solution**:
- Check Firestore security rules
- Ensure user is authenticated
- Verify user ID matches the document

### Issue 2: Firebase app not initializing
**Solution**:
- Verify Firebase configuration in `firebase_options.dart`
- Check internet connection
- Clear Flutter build cache: `flutter clean`

### Issue 3: Storage upload fails
**Solution**:
- Check Storage security rules
- Verify file size limits
- Ensure user is authenticated

### Issue 4: Analytics data not showing
**Solution**:
- Wait 24-48 hours for data to appear
- Verify measurement ID is correct
- Check that analytics is enabled in project

---

## Useful Resources

| Resource | URL |
|----------|-----|
| Firebase Documentation | https://firebase.google.com/docs |
| Flutter Firebase Plugin | https://pub.dev/packages/firebase_core |
| Cloud Firestore Guide | https://firebase.google.com/docs/firestore |
| Firebase Authentication | https://firebase.google.com/docs/auth |
| Cloud Storage Guide | https://firebase.google.com/docs/storage |

---

## Support

For issues or questions:
1. Check Firebase Console: https://console.firebase.google.com/project/sagovlaws
2. Review security rules
3. Check browser/app console for error messages
4. Verify credentials and permissions

---

**Last Updated**: December 9, 2025
**Status**: ✅ Ready for Development
