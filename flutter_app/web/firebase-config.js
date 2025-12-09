// Firebase Configuration for Web
// This file contains the Firebase configuration for the SaGovLaws web application

import { getAnalytics } from "firebase/analytics";
import { initializeApp } from "firebase/app";
import { getAuth } from "firebase/auth";
import { getFirestore } from "firebase/firestore";
import { getStorage } from "firebase/storage";

// Your web app's Firebase configuration
// For Firebase JS SDK v7.20.0 and later, measurementId is optional
const firebaseConfig = {
    apiKey: "AIzaSyCi2JL9S7D-bQ00ZwiercOpfTSDczJ9ZJI",
    authDomain: "sagovlaws.firebaseapp.com",
    projectId: "sagovlaws",
    storageBucket: "sagovlaws.firebasestorage.app",
    messagingSenderId: "1063086634234",
    appId: "1:1063086634234:web:d9e5539350769e9f5f8543",
    measurementId: "G-CB2JBRL65C"
};

// Initialize Firebase
const app = initializeApp(firebaseConfig);

// Initialize Firebase services
const analytics = getAnalytics(app);
const auth = getAuth(app);
const db = getFirestore(app);
const storage = getStorage(app);

// Export Firebase services for use in the application
export { analytics, app, auth, db, storage };

