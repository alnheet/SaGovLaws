import * as dotenv from 'dotenv';
import * as admin from 'firebase-admin';
import { Firestore, getFirestore } from 'firebase-admin/firestore';

dotenv.config();

let db: Firestore | null = null;

/**
 * Initialize Firebase Admin SDK
 * Uses service account key from environment or default credentials
 */
export function initializeFirebase(): Firestore {
    if (db) {
        return db;
    }

    // Initialize Firebase Admin
    if (admin.apps.length === 0) {
        const projectId = process.env.FIREBASE_PROJECT_ID;
        const keyPath = process.env.FIREBASE_PRIVATE_KEY_PATH;

        if (keyPath) {
            // Use service account key file
            const serviceAccount = require(keyPath);
            admin.initializeApp({
                credential: admin.credential.cert(serviceAccount),
                projectId: projectId,
            });
        } else {
            // Use default credentials (for Cloud Run)
            admin.initializeApp({
                projectId: projectId,
            });
        }
    }

    db = getFirestore();
    return db;
}

/**
 * Get Firestore instance
 */
export function getDb(): Firestore {
    if (!db) {
        return initializeFirebase();
    }
    return db;
}

/**
 * Collection names
 */
export const COLLECTIONS = {
    ARTICLES: 'articles',
    SOURCES: 'sources',
    USERS: 'users',
    FAVORITES: 'favorites',
};
