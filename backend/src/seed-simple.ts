import * as dotenv from 'dotenv';
import * as admin from 'firebase-admin';
import * as path from 'path';
import { DEFAULT_SOURCES } from './config/sources';

dotenv.config();

// Initialize Firebase Admin
const serviceAccountPath = path.resolve(__dirname, '../firebase-service-account.json');
console.log('Loading service account from:', serviceAccountPath);

// eslint-disable-next-line @typescript-eslint/no-var-requires
const serviceAccount = require(serviceAccountPath);

admin.initializeApp({
    credential: admin.credential.cert(serviceAccount),
    projectId: 'sagovlaws'
});

console.log('Firebase initialized successfully');

const db = admin.firestore();

/**
 * Sample articles for testing
 * هذه بيانات تجريبية للاختبار
 */
const SAMPLE_ARTICLES = [
    {
        title: 'قرار مجلس الوزراء رقم 1',
        description: 'قرار بشأن تطوير الخدمات الحكومية الرقمية',
        pdf_url: 'https://uqn.gov.sa/pdf/1.pdf',
        source_key: 'cabinet_decisions'
    },
    {
        title: 'قرار مجلس الوزراء رقم 2',
        description: 'قرار بشأن تحسين كفاءة الأداء الحكومي',
        pdf_url: 'https://uqn.gov.sa/pdf/2.pdf',
        source_key: 'cabinet_decisions'
    },
    {
        title: 'أمر ملكي رقم 1',
        description: 'أمر ملكي بشأن تعديلات إدارية',
        pdf_url: 'https://uqn.gov.sa/pdf/3.pdf',
        source_key: 'royal_orders'
    },
    {
        title: 'مرسوم ملكي رقم 1',
        description: 'مرسوم ملكي بشأن تنظيمات جديدة',
        pdf_url: 'https://uqn.gov.sa/pdf/4.pdf',
        source_key: 'royal_decrees'
    },
    {
        title: 'قرار وأنظمة رقم 1',
        description: 'قرار بشأن تطبيق الأنظمة الجديدة',
        pdf_url: 'https://uqn.gov.sa/pdf/5.pdf',
        source_key: 'decisions_regulations'
    },
];

/**
 * Seed the database with sample data
 */
async function seedDatabase() {
    try {
        console.log('🚀 Starting database seeding...');

        // Step 1: Create sources
        console.log('\n📝 Step 1: Creating sources collection...');
        for (const source of DEFAULT_SOURCES) {
            await db.collection('sources').doc(source.id).set({
                ...source,
                last_sync_at: admin.firestore.Timestamp.now(),
                article_count: 0,
                last_error: null,
                created_at: admin.firestore.Timestamp.now(),
            }, { merge: true });
            console.log(`✅ Created source: ${source.name_ar}`);
        }

        // Step 2: Create sample articles
        console.log('\n📰 Step 2: Creating sample articles...');
        let articleCount = 0;

        for (let i = 0; i < SAMPLE_ARTICLES.length; i++) {
            const sample = SAMPLE_ARTICLES[i];
            const source = DEFAULT_SOURCES.find(s => s.id === sample.source_key);

            if (!source) continue;

            const articleId = `${sample.source_key}_${i + 1}`;
            const now = new Date();
            const publishDate = new Date(now.getTime() - i * 24 * 60 * 60 * 1000); // Different dates

            await db.collection('articles').doc(articleId).set({
                id: articleId,
                article_number: String(i + 1),
                title: sample.title,
                description: sample.description,
                title_ar: sample.title,
                url: `https://uqn.gov.sa/article/${articleId}`,
                pdf_url: sample.pdf_url,
                published_date: admin.firestore.Timestamp.fromDate(publishDate),
                published_date_hijri: `${i + 1} محرم 1446`,
                source_key: sample.source_key,
                source_name: source.name_ar,
                category: source.name_ar,
                is_archive: false,
                crawled_at: admin.firestore.Timestamp.now(),
                is_valid: true,
                created_at: admin.firestore.Timestamp.now(),
            });

            console.log(`✅ Created article: ${sample.title}`);
            articleCount++;
        }

        // Step 3: Update source stats
        console.log('\n📊 Step 3: Updating source statistics...');
        const sourceArticleCounts: { [key: string]: number } = {};

        SAMPLE_ARTICLES.forEach(article => {
            sourceArticleCounts[article.source_key] = (sourceArticleCounts[article.source_key] || 0) + 1;
        });

        for (const [sourceKey, count] of Object.entries(sourceArticleCounts)) {
            await db.collection('sources').doc(sourceKey).update({
                article_count: count,
                last_sync_at: admin.firestore.Timestamp.now(),
                last_error: null,
            });
            console.log(`✅ Updated ${sourceKey}: ${count} articles`);
        }

        console.log('\n' + '='.repeat(60));
        console.log('✅ Database seeding completed successfully!');
        console.log(`📊 Created ${DEFAULT_SOURCES.length} sources`);
        console.log(`📰 Created ${articleCount} sample articles`);
        console.log('='.repeat(60));
        console.log('\n✨ You can now refresh the website to see the articles!');

        process.exit(0);

    } catch (error) {
        console.error('❌ Error during seeding:', error);
        process.exit(1);
    }
}

// Run the seeding
seedDatabase().catch(error => {
    console.error('Fatal error:', error);
    process.exit(1);
});
