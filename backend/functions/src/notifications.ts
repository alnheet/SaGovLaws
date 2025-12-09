/**
 * Cloud Function: Firestore Trigger for Notifications
 * Sends FCM notifications when new articles are added
 * 
 * Deploy with:
 * firebase deploy --only functions:notifyNewArticles
 */

import * as admin from "firebase-admin";
import * as functions from "firebase-functions";

// Initialize Firebase Admin (automatically done in Cloud Functions environment)
if (!admin.apps.length) {
    admin.initializeApp();
}

const firestore = admin.firestore();
const messaging = admin.messaging();

interface Article {
    title: string;
    source_key: string;
    category: string;
    published_at?: any;
    image_url?: string;
}

/**
 * Trigger: When a new article is added to Firestore
 * Action: Send FCM notification to all subscribed users
 */
export const notifyNewArticles = functions
    .region("me-south1") // Middle East region for faster delivery
    .firestore.document("articles/{articleId}")
    .onCreate(async (snap, context) => {
        try {
            const article = snap.data() as Article;
            const articleId = context.params.articleId;

            console.log(`📨 New article created: ${article.title}`);

            // Don't send notifications for old articles (more than 1 day old)
            if (article.published_at) {
                const publishedDate = article.published_at.toDate?.() || new Date(article.published_at);
                const oneDayAgo = new Date(Date.now() - 24 * 60 * 60 * 1000);

                if (publishedDate < oneDayAgo) {
                    console.log("⏭️ Skipping notification for old article");
                    return { skipped: true, reason: "article_too_old" };
                }
            }

            // Get all users subscribed to this category
            const usersSnapshot = await firestore
                .collection("users")
                .where("notification_subscriptions", "array-contains", article.source_key)
                .get();

            if (usersSnapshot.empty) {
                console.log("ℹ️ No subscribed users found");
                return { sent: 0, reason: "no_subscribers" };
            }

            console.log(`📋 Found ${usersSnapshot.size} subscribed users`);

            // Get FCM tokens for all subscribed users
            const fcmTokens: string[] = [];
            const userIds: string[] = [];

            for (const userDoc of usersSnapshot.docs) {
                const userData = userDoc.data();
                const tokens = userData.fcm_tokens || [];

                fcmTokens.push(...tokens);
                userIds.push(userDoc.id);
            }

            if (fcmTokens.length === 0) {
                console.log("⚠️ No FCM tokens found for subscribed users");
                return { sent: 0, reason: "no_fcm_tokens" };
            }

            // Prepare notification payload
            const notificationTitle = `${article.category} جديدة`;
            const notificationBody = article.title.substring(0, 100);

            const multicastMessage = {
                notification: {
                    title: notificationTitle,
                    body: notificationBody,
                    imageUrl: article.image_url
                },
                data: {
                    article_id: articleId,
                    source_key: article.source_key,
                    category: article.category,
                    click_action: "FLUTTER_NOTIFICATION_CLICK"
                },
                tokens: fcmTokens
            };

            // Send notifications in batches (max 500 at a time)
            const batchSize = 500;
            let totalSent = 0;
            let totalFailed = 0;

            for (let i = 0; i < fcmTokens.length; i += batchSize) {
                const batch = fcmTokens.slice(i, i + batchSize);

                try {
                    const response = await messaging.sendMulticast({
                        ...multicastMessage,
                        tokens: batch
                    });

                    totalSent += response.successCount;
                    totalFailed += response.failureCount;

                    // Log failed tokens for cleanup
                    if (response.failureCount > 0) {
                        const failedTokens: string[] = [];
                        response.responses.forEach((resp, index) => {
                            if (!resp.success) {
                                failedTokens.push(batch[index]);
                            }
                        });

                        // Queue cleanup of invalid tokens
                        await cleanupInvalidTokens(failedTokens);
                    }

                    console.log(
                        `✅ Batch sent: ${response.successCount} success, ${response.failureCount} failed`
                    );
                } catch (error) {
                    console.error(`❌ Error sending batch:`, error);
                    totalFailed += batch.length;
                }
            }

            // Log notification to Firestore for analytics
            await logNotificationEvent({
                article_id: articleId,
                article_title: article.title,
                source_key: article.source_key,
                category: article.category,
                sent_count: totalSent,
                failed_count: totalFailed,
                user_count: usersSnapshot.size,
                timestamp: admin.firestore.FieldValue.serverTimestamp()
            });

            console.log(
                `✅ Notifications sent: ${totalSent} successful, ${totalFailed} failed`
            );

            return {
                sent: totalSent,
                failed: totalFailed,
                total_users: usersSnapshot.size
            };
        } catch (error) {
            console.error("❌ Error in notifyNewArticles:", error);
            throw error;
        }
    });

/**
 * Cloud Function: Batch notification for new articles
 * Sends a summary notification every 6 hours
 * 
 * Deploy with:
 * firebase deploy --only functions:notifyArticlesSummary
 */
export const notifyArticlesSummary = functions
    .region("me-south1")
    .pubsub.schedule("every 6 hours")
    .onRun(async (context) => {
        try {
            console.log("📊 Starting summary notification job");

            // Get articles from last 6 hours
            const sixHoursAgo = new Date(Date.now() - 6 * 60 * 60 * 1000);

            const articlesSnapshot = await firestore
                .collection("articles")
                .where("created_at", ">=", sixHoursAgo)
                .orderBy("created_at", "desc")
                .limit(10)
                .get();

            if (articlesSnapshot.empty) {
                console.log("ℹ️ No new articles in the last 6 hours");
                return { articles_found: 0 };
            }

            console.log(`📰 Found ${articlesSnapshot.size} new articles`);

            // Group articles by category
            const articlesByCategory: { [key: string]: Article[] } = {};

            articlesSnapshot.docs.forEach((doc) => {
                const article = doc.data() as Article;
                if (!articlesByCategory[article.category]) {
                    articlesByCategory[article.category] = [];
                }
                articlesByCategory[article.category].push(article);
            });

            // Get all users
            const usersSnapshot = await firestore.collection("users").get();

            let totalNotificationsSent = 0;

            // Send summary to each user based on their preferences
            for (const userDoc of usersSnapshot.docs) {
                const userData = userDoc.data();
                const fcmTokens = userData.fcm_tokens || [];
                const subscriptions = userData.notification_subscriptions || [];

                if (fcmTokens.length === 0) continue;

                // Filter articles by user's subscriptions
                const userArticles = Object.entries(articlesByCategory)
                    .filter(([category]) => subscriptions.includes(category))
                    .flatMap(([, articles]) => articles);

                if (userArticles.length === 0) continue;

                // Create summary message
                const summary = Object.entries(articlesByCategory)
                    .filter(([category]) => subscriptions.includes(category))
                    .map(([cat, articles]) => `${cat}: ${articles.length}`)
                    .join("، ");

                const message = {
                    notification: {
                        title: "📰 ملخص الأخبار",
                        body: `وصلت لك ${articlesSnapshot.size} أخبار جديدة: ${summary}`
                    },
                    data: {
                        type: "summary",
                        articles_count: articlesSnapshot.size.toString(),
                        click_action: "FLUTTER_NOTIFICATION_CLICK"
                    },
                    tokens: fcmTokens
                };

                try {
                    const response = await messaging.sendMulticast(message);
                    totalNotificationsSent += response.successCount;

                    console.log(`✓ Summary sent to user ${userDoc.id}`);
                } catch (error) {
                    console.warn(`⚠️ Failed to send summary to user ${userDoc.id}:`, error);
                }
            }

            console.log(`✅ Summary notifications sent: ${totalNotificationsSent}`);

            return {
                articles_found: articlesSnapshot.size,
                notifications_sent: totalNotificationsSent
            };
        } catch (error) {
            console.error("❌ Error in notifyArticlesSummary:", error);
            throw error;
        }
    });

/**
 * Helper: Clean up invalid FCM tokens
 */
async function cleanupInvalidTokens(tokens: string[]): Promise<void> {
    try {
        console.log(`🧹 Cleaning up ${tokens.length} invalid tokens`);

        // Queue for batch cleanup (in production, use Firestore batch operation)
        for (const token of tokens) {
            // Mark token for cleanup in a dedicated collection
            await firestore
                .collection("fcm_tokens_cleanup")
                .doc(token)
                .set({
                    token,
                    marked_at: admin.firestore.FieldValue.serverTimestamp()
                });
        }
    } catch (error) {
        console.warn("⚠️ Failed to queue token cleanup:", error);
    }
}

/**
 * Helper: Log notification event for analytics
 */
async function logNotificationEvent(event: any): Promise<void> {
    try {
        await firestore
            .collection("notification_events")
            .add(event);
    } catch (error) {
        console.warn("⚠️ Failed to log notification event:", error);
    }
}
