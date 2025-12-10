import * as dotenv from 'dotenv';
import * as admin from 'firebase-admin';
import { DEFAULT_SOURCES } from './config/sources';
import { HistoricalArchiveScraper } from './scraper/historical_archive';

dotenv.config();

// Initialize Firebase Admin
const serviceAccountPath = process.env.FIREBASE_SERVICE_ACCOUNT_KEY_PATH ||
    './firebase-service-account.json';

admin.initializeApp({
    credential: admin.credential.cert(require(serviceAccountPath)),
    databaseURL: 'https://sagovlaws.firebaseio.com'
});

const db = admin.firestore();
const archiver = new HistoricalArchiveScraper(db);

/**
 * Seed the database with initial data from sources
 */
async function seedDatabase() {
    try {
        console.log('🚀 Starting database seeding...');
        console.log(`📊 Sources to process: ${DEFAULT_SOURCES.length}`);

        // Initialize sources collection
        console.log('\n📝 Initializing sources...');
        for (const source of DEFAULT_SOURCES) {
            await db.collection('sources').doc(source.id).set({
                ...source,
                last_sync_at: admin.firestore.Timestamp.now(),
                article_count: 0,
                last_error: null,
                created_at: admin.firestore.Timestamp.now(),
            });
            console.log(`✅ Created source: ${source.name_ar}`);
        }

        // Archive articles for each source
        console.log('\n📥 Archiving articles from sources...');
        let totalArticles = 0;

        for (const source of DEFAULT_SOURCES) {
            try {
                console.log(`\n🔄 Processing: ${source.name_ar} (${source.id})`);
                console.log(`   URL: ${source.url}`);

                // Start archiving with limited pages for faster seeding
                const result = await archiver.archiveSource(
                    source.id,
                    source.name_ar,
                    source.url,
                    source.name_ar,
                    5  // Start with 5 pages for testing
                );

                console.log(`✅ ${source.name_ar}:`);
                console.log(`   Total articles: ${result.total}`);
                console.log(`   New articles saved: ${result.newArticles}`);
                console.log(`   Errors: ${result.errors.length}`);

                totalArticles += result.newArticles;

                // Update source stats
                await db.collection('sources').doc(source.id).update({
                    article_count: result.total,
                    last_sync_at: admin.firestore.Timestamp.now(),
                    last_error: result.errors.length > 0 ? result.errors[0] : null,
                });

            } catch (error) {
                console.error(`❌ Error processing ${source.name_ar}:`, error);
                // Update with error
                await db.collection('sources').doc(source.id).update({
                    last_sync_at: admin.firestore.Timestamp.now(),
                    last_error: error instanceof Error ? error.message : String(error),
                });
            }

            // Add delay between requests to avoid rate limiting
            await new Promise(resolve => setTimeout(resolve, 2000));
        }

        console.log('\n' + '='.repeat(50));
        console.log('✅ Database seeding completed!');
        console.log(`📊 Total articles saved: ${totalArticles}`);
        console.log('='.repeat(50));

        process.exit(0);

    } catch (error) {
        console.error('❌ Fatal error during seeding:', error);
        process.exit(1);
    }
}

// Run the seeding
seedDatabase();
