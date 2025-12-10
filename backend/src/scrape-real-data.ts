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
    scraped_at: admin.firestore.Timestamp;
    is_archive: boolean;
}

/**
 * Fetch articles from a source page
 */
async function fetchArticlesFromSource(source: typeof DEFAULT_SOURCES[0], maxPages: number = 5): Promise<Article[]> {
    const articles: Article[] = [];

    console.log(`\n📡 Fetching from: ${source.name_ar} (${source.url})`);

    for (let page = 1; page <= maxPages; page++) {
        try {
            const pageUrl = page === 1 ? source.url : `${source.url}&page=${page}`;
            console.log(`  📄 Page ${page}: ${pageUrl}`);

            const response = await axios.get(pageUrl, {
                headers: {
                    'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
                    'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8',
                    'Accept-Language': 'ar,en;q=0.9',
                },
                timeout: 30000,
            });

            const $ = cheerio.load(response.data);

            // Try multiple selectors for articles
            const articleSelectors = [
                '.news-item',
                '.article-item',
                '.news-card',
                '.list-item',
                'article',
                '.card',
                '[class*="news"]',
                '[class*="article"]',
                '.content-item',
                'tr[onclick]',
                'table tbody tr',
            ];

            let foundArticles = false;

            for (const selector of articleSelectors) {
                const elements = $(selector);

                if (elements.length > 0) {
                    console.log(`  ✅ Found ${elements.length} elements with selector: ${selector}`);

                    elements.each((index, element) => {
                        const $el = $(element);

                        // Try to extract title
                        const title = $el.find('h1, h2, h3, h4, .title, a').first().text().trim() ||
                            $el.find('td:nth-child(1)').text().trim() ||
                            $el.text().trim().substring(0, 100);

                        if (!title || title.length < 5) return;

                        // Try to extract link
                        let articleUrl = $el.find('a').attr('href') || $el.attr('onclick')?.match(/location.href='([^']+)'/)?.[1] || '';
                        if (articleUrl && !articleUrl.startsWith('http')) {
                            articleUrl = `https://uqn.gov.sa${articleUrl.startsWith('/') ? '' : '/'}${articleUrl}`;
                        }

                        // Try to extract PDF
                        let pdfUrl = $el.find('a[href*=".pdf"]').attr('href') || '';
                        if (pdfUrl && !pdfUrl.startsWith('http')) {
                            pdfUrl = `https://uqn.gov.sa${pdfUrl.startsWith('/') ? '' : '/'}${pdfUrl}`;
                        }

                        // Try to extract date
                        const dateText = $el.find('.date, time, [class*="date"]').text().trim() ||
                            $el.find('td:nth-child(2)').text().trim();

                        // Try to extract description
                        const description = $el.find('p, .description, .excerpt, .summary').text().trim() ||
                            $el.find('td:nth-child(3)').text().trim() ||
                            title;

                        // Generate unique ID
                        const articleId = `${source.id}_${Date.now()}_${index}`;

                        articles.push({
                            id: articleId,
                            title: title.substring(0, 500),
                            description: description.substring(0, 2000),
                            url: articleUrl || source.url,
                            pdf_url: pdfUrl,
                            source_key: source.id,
                            source_name: source.name_ar,
                            category: source.name_ar,
                            published_date: admin.firestore.Timestamp.now(),
                            scraped_at: admin.firestore.Timestamp.now(),
                            is_archive: false,
                        });
                    });

                    foundArticles = true;
                    break;
                }
            }

            if (!foundArticles) {
                console.log(`  ⚠️ No articles found on page ${page}`);

                // Debug: Print the HTML structure
                console.log(`  📝 HTML preview: ${$.html().substring(0, 500)}...`);
            }

            // Delay between requests
            await new Promise(resolve => setTimeout(resolve, 1000));

        } catch (error) {
            console.error(`  ❌ Error fetching page ${page}:`, error instanceof Error ? error.message : error);
        }
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
 * Main function
 */
async function main() {
    console.log('🚀 Starting real data scraping...\n');

    let totalArticles = 0;

    for (const source of DEFAULT_SOURCES) {
        try {
            const articles = await fetchArticlesFromSource(source, 3); // 3 pages per source

            if (articles.length > 0) {
                console.log(`  💾 Saving ${articles.length} articles...`);
                const saved = await saveArticles(articles);
                console.log(`  ✅ Saved ${saved} articles from ${source.name_ar}`);
                totalArticles += saved;

                // Update source statistics
                await db.collection('sources').doc(source.id).update({
                    article_count: admin.firestore.FieldValue.increment(saved),
                    last_sync_at: admin.firestore.Timestamp.now(),
                });
            } else {
                console.log(`  ⚠️ No articles found for ${source.name_ar}`);
            }

        } catch (error) {
            console.error(`Error processing source ${source.name_ar}:`, error);
        }
    }

    console.log('\n============================================================');
    console.log(`✅ Scraping completed!`);
    console.log(`📰 Total articles saved: ${totalArticles}`);
    console.log('============================================================');

    process.exit(0);
}

main().catch(console.error);
