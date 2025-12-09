import { Firestore } from 'firebase-admin/firestore';
/**
 * Initialize Firebase Admin SDK
 * Uses service account key from environment or default credentials
 */
export declare function initializeFirebase(): Firestore;
/**
 * Get Firestore instance
 */
export declare function getDb(): Firestore;
/**
 * Collection names
 */
export declare const COLLECTIONS: {
    ARTICLES: string;
    SOURCES: string;
    USERS: string;
    FAVORITES: string;
};
//# sourceMappingURL=firebase.d.ts.map