// Firebase Configuration for Node.js Backend
// This file contains the Firebase configuration for the SaGovLaws backend application

const admin = require('firebase-admin');

// Firebase configuration object
const firebaseConfig = {
    apiKey: "AIzaSyCi2JL9S7D-bQ00ZwiercOpfTSDczJ9ZJI",
    authDomain: "sagovlaws.firebaseapp.com",
    projectId: "sagovlaws",
    storageBucket: "sagovlaws.firebasestorage.app",
    messagingSenderId: "1063086634234",
    appId: "1:1063086634234:web:d9e5539350769e9f5f8543"
};

// Initialize Firebase Admin SDK
// Ensure you have the service account JSON file in your project
// Set the path to your service account JSON file as an environment variable
try {
    if (!admin.apps.length) {
        const serviceAccountPath = process.env.GOOGLE_APPLICATION_CREDENTIALS;

        admin.initializeApp({
            credential: admin.credential.cert(require(serviceAccountPath || './serviceAccountKey.json')),
            ...firebaseConfig
        });
    }
} catch (error) {
    console.error('Error initializing Firebase Admin SDK:', error);
}

// Export Firebase Admin services
module.exports = {
    admin,
    auth: admin.auth(),
    db: admin.firestore(),
    storage: admin.storage(),
    firebaseConfig
};
