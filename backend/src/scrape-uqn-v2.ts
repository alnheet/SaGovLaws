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

/**
 * Article structure matching Flutter app expectations
 */
interface Article {
    id: string;
    original_id: string;
    source_key: string;
    source_name_ar: string;
    cat_id: number;
    title: string;
    content_html?: string;
    content_plain?: string;
    excerpt?: string;
    publish_date_raw: string;
    publish_date_gregorian?: string;
    publish_date_iso: admin.firestore.Timestamp;
    url: string;
    pdf_url?: string;
    has_pdf: boolean;
    scraped_at: admin.firestore.Timestamp;
    updated_at: admin.firestore.Timestamp;
    tags?: string[];
}

/**
 * Get cat_id for source
 */
function getCatId(sourceKey: string): number {
    const source = DEFAULT_SOURCES.find(s => s.id === sourceKey);
    return source?.cat_id || 0;
}

/**
 * Parse date from text like "1447-6-18 الموافق 2025-12-09"
 */
function parseDate(text: string): { gregorian?: string; hijri?: string; iso?: Date } {
    // Try to find Gregorian date (2025-12-09)
    const gregMatch = text.match(/(\d{4})-(\d{1,2})-(\d{1,2})/);
    let gregorian: string | undefined;
    let iso: Date | undefined;

    if (gregMatch) {
        const year = parseInt(gregMatch[1]);
        const month = parseInt(gregMatch[2]);
        const day = parseInt(gregMatch[3]);

        // Check if it's Gregorian (year > 1900) or Hijri (year < 1500)
        if (year > 1900) {
            gregorian = `${year}-${String(month).padStart(2, '0')}-${String(day).padStart(2, '0')}`;
            iso = new Date(year, month - 1, day);
        }
    }

    // Try to find Hijri date
    const hijriMatch = text.match(/(\d{4})-(\d{1,2})-(\d{1,2})هـ?/);
    let hijri: string | undefined;

    if (hijriMatch) {
        const year = parseInt(hijriMatch[1]);
        if (year < 1500) {
            hijri = `${year}-${hijriMatch[2]}-${hijriMatch[3]}`;
        }
    }

    return { gregorian, hijri, iso };
}

/**
 * Determine source from context
 */
function determineSource(text: string, parentText: string): { key: string; name: string } {
    const combined = `${text} ${parentText}`.toLowerCase();

    if (combined.includes('أمر ملكي') || combined.includes('أوامر ملكية')) {
        return { key: 'royal_orders', name: 'أوامر ملكية' };
    } else if (combined.includes('مرسوم ملكي') || combined.includes('مراسيم ملكية')) {
        return { key: 'royal_decrees', name: 'مراسيم ملكية' };
    } else if (combined.includes('قرار وزاري') || combined.includes('قرارات وزارية')) {
        return { key: 'ministerial_decisions', name: 'قرارات وزارية' };
    } else if (combined.includes('لائحة') || combined.includes('لوائح وأنظمة')) {
        return { key: 'laws_regulations', name: 'لوائح وأنظمة' };
    } else if (combined.includes('قرارات وأنظمة') || combined.includes('قرار وأنظمة')) {
        return { key: 'decisions_regulations', name: 'قرارات وأنظمة' };
    } else if (combined.includes('هيئة') || combined.includes('هيئات')) {
        return { key: 'authorities', name: 'هيئات' };
    } else if (combined.includes('مجلس الوزراء') || combined.includes('قرار مجلس')) {
        return { key: 'cabinet_decisions', name: 'قرارات مجلس الوزراء' };
    }

    return { key: 'cabinet_decisions', name: 'قرارات مجلس الوزراء' };
}

/**
 * Scrape the main page
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

        $('a[href*="details?p="]').each((index, element) => {
            const $el = $(element);
            const href = $el.attr('href') || '';
            const title = $el.text().trim();

            if (!title || title.length < 5) return;

            const match = href.match(/details\?p=(\d+)/);
            if (!match) return;

            const originalId = match[1];
            const articleId = `article_${originalId}`;
            const fullUrl = href.startsWith('http') ? href : `https://uqn.gov.sa${href}`;

            // Skip duplicates
            if (articles.some(a => a.id === articleId)) return;

            // Parse date
            const dates = parseDate(title);

            // Determine source
            const parent = $el.parents('[class*="news"], [class*="decision"], section, .card').first();
            const source = determineSource(title, parent.text());

            articles.push({
                id: articleId,
                original_id: originalId,
                source_key: source.key,
                source_name_ar: source.name,
                cat_id: getCatId(source.key),
                title: title.replace(/\d{4}-\d{1,2}-\d{1,2}.*$/, '').trim().substring(0, 500),
                content_plain: title,
                excerpt: title.substring(0, 200),
                publish_date_raw: dates.hijri || dates.gregorian || new Date().toISOString().split('T')[0],
                publish_date_gregorian: dates.gregorian,
                publish_date_iso: dates.iso
                    ? admin.firestore.Timestamp.fromDate(dates.iso)
                    : admin.firestore.Timestamp.now(),
                url: fullUrl,
                pdf_url: undefined,
                has_pdf: false,
                scraped_at: admin.firestore.Timestamp.now(),
                updated_at: admin.firestore.Timestamp.now(),
                tags: [],
            });
        });

        console.log(`✅ Found ${articles.length} articles on main page`);

    } catch (error) {
        console.error('❌ Error fetching main page:', error instanceof Error ? error.message : error);
    }

    return articles;
}

/**
 * Scrape the decisions page
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

        $('a[href*="details?p="]').each((index, element) => {
            const $el = $(element);
            const href = $el.attr('href') || '';
            const title = $el.text().trim();

            if (!title || title.length < 5) return;

            const match = href.match(/details\?p=(\d+)/);
            if (!match) return;

            const originalId = match[1];
            const articleId = `decision_${originalId}`;
            const fullUrl = href.startsWith('http') ? href : `https://uqn.gov.sa${href}`;

            if (articles.some(a => a.id === articleId)) return;

            // Parse date
            const dates = parseDate(title);

            // Determine source from title
            const source = determineSource(title, '');

            articles.push({
                id: articleId,
                original_id: originalId,
                source_key: source.key,
                source_name_ar: source.name,
                cat_id: getCatId(source.key),
                title: title.replace(/\d{4}-\d{1,2}-\d{1,2}.*$/, '').trim().substring(0, 500),
                content_plain: title,
                excerpt: title.substring(0, 200),
                publish_date_raw: dates.hijri || dates.gregorian || new Date().toISOString().split('T')[0],
                publish_date_gregorian: dates.gregorian,
                publish_date_iso: dates.iso
                    ? admin.firestore.Timestamp.fromDate(dates.iso)
                    : admin.firestore.Timestamp.now(),
                url: fullUrl,
                pdf_url: undefined,
                has_pdf: false,
                scraped_at: admin.firestore.Timestamp.now(),
                updated_at: admin.firestore.Timestamp.now(),
                tags: [],
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
            // Convert undefined to null for Firestore
            const cleanArticle: Record<string, unknown> = {};
            for (const [key, value] of Object.entries(article)) {
                cleanArticle[key] = value === undefined ? null : value;
            }

            await db.collection('articles').doc(article.id).set(cleanArticle, { merge: true });
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
    console.log('🚀 Starting UQN.gov.sa scraping (v2 - Flutter compatible)...\n');

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

    // Clear old articles to avoid conflicts
    console.log('🗑️  Clearing old sample articles...');
    const oldArticles = await db.collection('articles').listDocuments();
    for (const doc of oldArticles) {
        await doc.delete();
    }
    console.log(`✅ Cleared ${oldArticles.length} old articles\n`);

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
