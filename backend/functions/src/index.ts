import * as admin from 'firebase-admin';
import * as functions from 'firebase-functions';

// Initialize Firebase Admin
admin.initializeApp();

const db = admin.firestore();
const messaging = admin.messaging();

/**
 * Firestore trigger: When a new article is created
 * Sends FCM data message to subscribed users
 */
export const onArticleCreated = functions
    .region('me-west1')
    .firestore.document('articles/{articleId}')
    .onCreate(async (snapshot, context) => {
        const article = snapshot.data();
        const articleId = context.params.articleId;

        functions.logger.info(`New article created: ${articleId}`, {
            source: article.source_key,
            title: article.title,
        });

        try {
            // Send to topic for this source
            const sourceTopic = `news_${article.source_key}`;

            // Send data-only message (silent push)
            const message: admin.messaging.Message = {
                topic: sourceTopic,
                data: {
                    type: 'new_article',
                    article_id: articleId,
                    source_key: article.source_key,
                    source_name_ar: article.source_name_ar,
                    title: article.title.substring(0, 100),
                    timestamp: String(Date.now()),
                },
                // Android: data-only message
                android: {
                    priority: 'high',
                },
                // iOS: enable background updates
                apns: {
                    headers: {
                        'apns-priority': '5',
                    },
                    payload: {
                        aps: {
                            contentAvailable: true,
                        },
                    },
                },
            };

            await messaging.send(message);
            functions.logger.info(`FCM sent to topic: ${sourceTopic}`);

            // Also send to general news topic
            const generalMessage: admin.messaging.Message = {
                ...message,
                topic: 'news_updates',
            };
            await messaging.send(generalMessage);
            functions.logger.info('FCM sent to topic: news_updates');

        } catch (error) {
            functions.logger.error('Error sending FCM:', error);
        }

        return null;
    });

/**
 * Scheduled function: Daily summary notification
 * Runs at 8 AM Saudi time
 */
export const dailySummaryNotification = functions
    .region('me-west1')
    .pubsub.schedule('0 8 * * *')
    .timeZone('Asia/Riyadh')
    .onRun(async (_context) => {
        functions.logger.info('Running daily summary notification');

        try {
            // Get article count from last 24 hours
            const yesterday = admin.firestore.Timestamp.fromDate(
                new Date(Date.now() - 24 * 60 * 60 * 1000)
            );

            const snapshot = await db
                .collection('articles')
                .where('scraped_at', '>=', yesterday)
                .get();

            if (snapshot.empty) {
                functions.logger.info('No new articles in last 24 hours');
                return null;
            }

            // Count by source
            const sourceCounts: Record<string, number> = {};
            snapshot.docs.forEach(doc => {
                const source = doc.data().source_key;
                sourceCounts[source] = (sourceCounts[source] || 0) + 1;
            });

            const totalCount = snapshot.docs.length;

            // Send summary notification
            const message: admin.messaging.Message = {
                topic: 'news_updates',
                data: {
                    type: 'daily_summary',
                    total_count: String(totalCount),
                    source_counts: JSON.stringify(sourceCounts),
                    timestamp: String(Date.now()),
                },
                notification: {
                    title: 'ملخص أم القرى اليومي',
                    body: `تم نشر ${totalCount} قرارات جديدة في آخر 24 ساعة`,
                },
                android: {
                    priority: 'high',
                    notification: {
                        channelId: 'daily_summary',
                        icon: 'ic_notification',
                    },
                },
                apns: {
                    payload: {
                        aps: {
                            badge: totalCount,
                            sound: 'default',
                        },
                    },
                },
            };

            await messaging.send(message);
            functions.logger.info(`Daily summary sent: ${totalCount} articles`);

        } catch (error) {
            functions.logger.error('Error sending daily summary:', error);
        }

        return null;
    });

/**
 * HTTP function: Register FCM token for user
 */
export const registerFcmToken = functions
    .region('me-west1')
    .https.onCall(async (data, context) => {
        // Verify authentication
        if (!context.auth) {
            throw new functions.https.HttpsError(
                'unauthenticated',
                'User must be authenticated'
            );
        }

        const { token, subscribedSources } = data;
        const uid = context.auth.uid;

        if (!token) {
            throw new functions.https.HttpsError(
                'invalid-argument',
                'FCM token is required'
            );
        }

        try {
            // Update user document
            const userRef = db.collection('users').doc(uid);

            await userRef.set({
                fcm_tokens: admin.firestore.FieldValue.arrayUnion(token),
                subscribed_sources: subscribedSources || ['all'],
                updated_at: admin.firestore.FieldValue.serverTimestamp(),
            }, { merge: true });

            // Subscribe to topics
            const sources = subscribedSources || ['all'];

            for (const source of sources) {
                const topic = source === 'all' ? 'news_updates' : `news_${source}`;
                await messaging.subscribeToTopic(token, topic);
                functions.logger.info(`Subscribed ${uid} to topic: ${topic}`);
            }

            return { success: true };

        } catch (error) {
            functions.logger.error('Error registering FCM token:', error);
            throw new functions.https.HttpsError(
                'internal',
                'Failed to register FCM token'
            );
        }
    });

/**
 * HTTP function: Update notification preferences
 */
export const updateNotificationPreferences = functions
    .region('me-west1')
    .https.onCall(async (data, context) => {
        if (!context.auth) {
            throw new functions.https.HttpsError(
                'unauthenticated',
                'User must be authenticated'
            );
        }

        const { enabled, subscribedSources, notificationHours } = data;
        const uid = context.auth.uid;

        try {
            const userRef = db.collection('users').doc(uid);
            const userDoc = await userRef.get();
            const userData = userDoc.data();
            const tokens = userData?.fcm_tokens || [];

            // Update preferences
            await userRef.set({
                notification_enabled: enabled,
                subscribed_sources: subscribedSources,
                notification_hours: notificationHours,
                updated_at: admin.firestore.FieldValue.serverTimestamp(),
            }, { merge: true });

            // Update topic subscriptions
            if (tokens.length > 0) {
                // Unsubscribe from all news topics first
                const allSources = [
                    'cabinet_decisions', 'royal_orders', 'royal_decrees',
                    'decisions_regulations', 'laws_regulations',
                    'ministerial_decisions', 'authorities'
                ];

                for (const token of tokens) {
                    // Unsubscribe from all
                    await messaging.unsubscribeFromTopic(token, 'news_updates');
                    for (const source of allSources) {
                        await messaging.unsubscribeFromTopic(token, `news_${source}`);
                    }

                    // Re-subscribe based on preferences
                    if (enabled) {
                        if (subscribedSources.includes('all')) {
                            await messaging.subscribeToTopic(token, 'news_updates');
                        } else {
                            for (const source of subscribedSources) {
                                await messaging.subscribeToTopic(token, `news_${source}`);
                            }
                        }
                    }
                }
            }

            return { success: true };

        } catch (error) {
            functions.logger.error('Error updating preferences:', error);
            throw new functions.https.HttpsError(
                'internal',
                'Failed to update preferences'
            );
        }
    });
