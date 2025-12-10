import axios from 'axios';
import * as cheerio from 'cheerio';
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

interface Article {
    id: string;
    title: string;
    description: string;
    url: string;
    pdf_url: string;
    source_key: string;
    source_name: string;
    category: string;
    published_date: admin.firestore.Timestamp;
    published_date_hijri?: string;
    scraped_at: admin.firestore.Timestamp;
    is_archive: boolean;
}

// Real URLs from the website
const REAL_URLS = {
    decisions_and_systems: 'https://uqn.gov.sa/DecisionsAndSystems',
    section: 'https://uqn.gov.sa/section',
    archives: 'https://uqn.gov.sa/Archives',
};

/**
 * Parse the main page to find article links
 */
async function scrapeMainPage(): Promise<Article[]> {
    const articles: Article[] = [];

    console.log('📡 Fetching main page: https://uqn.gov.sa');

    try {
        const response = await axios.get('https://uqn.gov.sa', {
            headers: {
                'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
                'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
                'Accept-Language': 'ar,en;q=0.9',
            },
            timeout: 30000,
        });

        const $ = cheerio.load(response.data);

        // Find all links to articles (details?p=...)
        $('a[href*="details?p="]').each((index, element) => {
            const $el = $(element);
            const href = $el.attr('href') || '';
            const title = $el.text().trim();

            if (!title || title.length < 5) return;

            // Extract article ID from URL
            const match = href.match(/details\?p=(\d+)/);
            if (!match) return;

            const articleId = `article_${match[1]}`;
            const fullUrl = href.startsWith('http') ? href : `https://uqn.gov.sa${href}`;

            // Parse date from title (format: 1447-6-18 الموافق 2025-12-09)
            const dateMatch = title.match(/(\d{4})-(\d{1,2})-(\d{1,2})/);
            let publishedDate = admin.firestore.Timestamp.now();
            let hijriDate = '';

            if (dateMatch) {
                try {
                    publishedDate = admin.firestore.Timestamp.fromDate(
                        new Date(parseInt(dateMatch[1]), parseInt(dateMatch[2]) - 1, parseInt(dateMatch[3]))
                    );
                } catch (e) {
                    // Use current date if parsing fails
                }
            }

            // Try to find hijri date
            const hijriMatch = title.match(/(\d{4}-\d{1,2}-\d{1,2})هـ?/);
            if (hijriMatch) {
                hijriDate = hijriMatch[1];
            }

            // Determine source based on context
            const parent = $el.parents('[class*="news"], [class*="decision"], section, .card').first();
            let sourceKey = 'cabinet_decisions';
            let sourceName = 'قرارات مجلس الوزراء';

            const parentText = parent.text().toLowerCase();
            if (parentText.includes('أوامر ملكية') || parentText.includes('أمر ملكي')) {
                sourceKey = 'royal_orders';
                sourceName = 'أوامر ملكية';
            } else if (parentText.includes('مراسيم ملكية') || parentText.includes('مرسوم ملكي')) {
                sourceKey = 'royal_decrees';
                sourceName = 'مراسيم ملكية';
            } else if (parentText.includes('قرارات وزارية') || parentText.includes('قرار وزاري')) {
                sourceKey = 'ministerial_decisions';
                sourceName = 'قرارات وزارية';
            } else if (parentText.includes('لوائح') || parentText.includes('أنظمة')) {
                sourceKey = 'laws_regulations';
                sourceName = 'لوائح وأنظمة';
            }

            // Skip duplicates
            if (articles.some(a => a.id === articleId)) return;

            articles.push({
                id: articleId,
                title: title.substring(0, 500),
                description: title,
                url: fullUrl,
                pdf_url: '',
                source_key: sourceKey,
                source_name: sourceName,
                category: sourceName,
                published_date: publishedDate,
                published_date_hijri: hijriDate,
                scraped_at: admin.firestore.Timestamp.now(),
                is_archive: false,
            });
        });

        console.log(`✅ Found ${articles.length} articles on main page`);

    } catch (error) {
        console.error('❌ Error fetching main page:', error instanceof Error ? error.message : error);
    }

    return articles;
}

/**
 * Scrape Decisions and Systems page
 */
async function scrapeDecisionsPage(): Promise<Article[]> {
    const articles: Article[] = [];

    console.log('📡 Fetching Decisions page: https://uqn.gov.sa/DecisionsAndSystems');

    try {
        const response = await axios.get('https://uqn.gov.sa/DecisionsAndSystems', {
            headers: {
                'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
                'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
                'Accept-Language': 'ar,en;q=0.9',
            },
            timeout: 30000,
        });

        const $ = cheerio.load(response.data);

        // Find all links to articles
        $('a[href*="details?p="]').each((index, element) => {
            const $el = $(element);
            const href = $el.attr('href') || '';
            const title = $el.text().trim();

            if (!title || title.length < 5) return;

            const match = href.match(/details\?p=(\d+)/);
            if (!match) return;

            const articleId = `decision_${match[1]}`;
            const fullUrl = href.startsWith('http') ? href : `https://uqn.gov.sa${href}`;

            if (articles.some(a => a.id === articleId)) return;

            articles.push({
                id: articleId,
                title: title.substring(0, 500),
                description: title,
                url: fullUrl,
                pdf_url: '',
                source_key: 'decisions_regulations',
                source_name: 'قرارات وأنظمة',
                category: 'قرارات وأنظمة',
                published_date: admin.firestore.Timestamp.now(),
                scraped_at: admin.firestore.Timestamp.now(),
                is_archive: false,
            });
        });

        console.log(`✅ Found ${articles.length} decisions`);

    } catch (error) {
        console.error('❌ Error fetching decisions page:', error instanceof Error ? error.message : error);
    }

    return articles;
}

/**
 * Save articles to Firestore
 */
async function saveArticles(articles: Article[]): Promise<number> {
    let saved = 0;

    for (const article of articles) {
        try {
            await db.collection('articles').doc(article.id).set(article, { merge: true });
            saved++;
        } catch (error) {
            console.error(`Error saving article ${article.id}:`, error);
        }
    }

    return saved;
}

/**
 * Update source statistics
 */
async function updateSourceStats(articles: Article[]) {
    const stats: Record<string, number> = {};

    for (const article of articles) {
        stats[article.source_key] = (stats[article.source_key] || 0) + 1;
    }

    for (const [sourceKey, count] of Object.entries(stats)) {
        try {
            await db.collection('sources').doc(sourceKey).update({
                article_count: admin.firestore.FieldValue.increment(count),
                last_sync_at: admin.firestore.Timestamp.now(),
            });
            console.log(`📊 Updated ${sourceKey}: +${count} articles`);
        } catch (error) {
            console.error(`Error updating source ${sourceKey}:`, error);
        }
    }
}

/**
 * Main function
 */
async function main() {
    console.log('🚀 Starting UQN.gov.sa scraping...\n');

    // Ensure sources exist
    console.log('📝 Ensuring sources exist...');
    for (const source of DEFAULT_SOURCES) {
        await db.collection('sources').doc(source.id).set({
            ...source,
            last_sync_at: admin.firestore.Timestamp.now(),
            article_count: 0,
            last_error: null,
            created_at: admin.firestore.Timestamp.now(),
        }, { merge: true });
    }
    console.log('✅ Sources created\n');

    // Scrape main page
    const mainArticles = await scrapeMainPage();

    // Scrape decisions page
    const decisionArticles = await scrapeDecisionsPage();

    // Combine and remove duplicates
    const allArticles = [...mainArticles];
    for (const article of decisionArticles) {
        if (!allArticles.some(a => a.url === article.url)) {
            allArticles.push(article);
        }
    }

    console.log(`\n📰 Total unique articles found: ${allArticles.length}`);

    if (allArticles.length > 0) {
        console.log('💾 Saving articles to Firestore...');
        const saved = await saveArticles(allArticles);
        console.log(`✅ Saved ${saved} articles`);

        console.log('\n📊 Updating source statistics...');
        await updateSourceStats(allArticles);
    }

    console.log('\n============================================================');
    console.log('✅ Scraping completed!');
    console.log(`📰 Total articles saved: ${allArticles.length}`);
    console.log('============================================================');
    console.log('\n✨ Refresh the website to see the new articles!');
    console.log('🌐 https://sagovlaws.web.app\n');

    process.exit(0);
}

main().catch(console.error);
