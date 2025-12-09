"use strict";
var __createBinding = (this && this.__createBinding) || (Object.create ? (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    var desc = Object.getOwnPropertyDescriptor(m, k);
    if (!desc || ("get" in desc ? !m.__esModule : desc.writable || desc.configurable)) {
      desc = { enumerable: true, get: function() { return m[k]; } };
    }
    Object.defineProperty(o, k2, desc);
}) : (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    o[k2] = m[k];
}));
var __setModuleDefault = (this && this.__setModuleDefault) || (Object.create ? (function(o, v) {
    Object.defineProperty(o, "default", { enumerable: true, value: v });
}) : function(o, v) {
    o["default"] = v;
});
var __importStar = (this && this.__importStar) || (function () {
    var ownKeys = function(o) {
        ownKeys = Object.getOwnPropertyNames || function (o) {
            var ar = [];
            for (var k in o) if (Object.prototype.hasOwnProperty.call(o, k)) ar[ar.length] = k;
            return ar;
        };
        return ownKeys(o);
    };
    return function (mod) {
        if (mod && mod.__esModule) return mod;
        var result = {};
        if (mod != null) for (var k = ownKeys(mod), i = 0; i < k.length; i++) if (k[i] !== "default") __createBinding(result, mod, k[i]);
        __setModuleDefault(result, mod);
        return result;
    };
})();
Object.defineProperty(exports, "__esModule", { value: true });
exports.COLLECTIONS = void 0;
exports.initializeFirebase = initializeFirebase;
exports.getDb = getDb;
const dotenv = __importStar(require("dotenv"));
const admin = __importStar(require("firebase-admin"));
const firestore_1 = require("firebase-admin/firestore");
dotenv.config();
let db = null;
/**
 * Initialize Firebase Admin SDK
 * Uses service account key from environment or default credentials
 */
function initializeFirebase() {
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
        }
        else {
            // Use default credentials (for Cloud Run)
            admin.initializeApp({
                projectId: projectId,
            });
        }
    }
    db = (0, firestore_1.getFirestore)();
    return db;
}
/**
 * Get Firestore instance
 */
function getDb() {
    if (!db) {
        return initializeFirebase();
    }
    return db;
}
/**
 * Collection names
 */
exports.COLLECTIONS = {
    ARTICLES: 'articles',
    SOURCES: 'sources',
    USERS: 'users',
    FAVORITES: 'favorites',
};
//# sourceMappingURL=firebase.js.map