import puppeteer, { Browser, Page } from 'puppeteer';
import { SCRAPER_CONFIG } from '../config';
import { ParsedArticle, SourceDoc } from '../interfaces';
import { parseArticleDetail, parseArticlesFromHtml } from './parser';

/**
 * Delay helper function
 */
function delay(ms: number): Promise<void> {
    return new Promise(resolve => setTimeout(resolve, ms));
}

/**
 * UQN Scraper class - handles browser automation for scraping
 */
export class UqnScraper {
    private browser: Browser | null = null;

    /**
     * Initialize the browser instance
     */
    async init(): Promise<void> {
        if (this.browser) return;

        this.browser = await puppeteer.launch({
            headless: true,
            args: [
                '--no-sandbox',
                '--disable-setuid-sandbox',
                '--disable-dev-shm-usage',
                '--disable-accelerated-2d-canvas',
                '--disable-gpu',
                '--window-size=1920x1080',
            ],
        });
    }

    /**
     * Close browser instance
     */
    async close(): Promise<void> {
        if (this.browser) {
            await this.browser.close();
            this.browser = null;
        }
    }

    /**
     * Create a new page with proper settings
     */
    private async createPage(): Promise<Page> {
        if (!this.browser) {
            throw new Error('Browser not initialized. Call init() first.');
        }

        const page = await this.browser.newPage();

        await page.setViewport(SCRAPER_CONFIG.VIEWPORT);
        await page.setUserAgent(SCRAPER_CONFIG.USER_AGENT);

        // Set Arabic language preference
        await page.setExtraHTTPHeaders({
            'Accept-Language': 'ar-SA,ar;q=0.9,en;q=0.8',
        });

        return page;
    }

    /**
     * Scrape a category page
     * @param source - Source configuration
     * @param mode - 'full' for all pages, 'incremental' for new only
     * @param existingIds - Set of existing article IDs (for incremental mode)
     */
    async scrapeCategory(
        source: SourceDoc,
        mode: 'full' | 'incremental',
        existingIds: Set<string> = new Set()
    ): Promise<{ articles: ParsedArticle[]; errors: string[] }> {
        const page = await this.createPage();
        const articles: ParsedArticle[] = [];
        const errors: string[] = [];

        try {
            console.log(`[Scraper] Starting ${mode} scrape for ${source.id}`);

            // Navigate to category page
            await page.goto(source.url, {
                waitUntil: 'networkidle2',
                timeout: SCRAPER_CONFIG.TIMEOUT_MS,
            });

            let pageCount = 0;
            let hasMore = true;
            let foundExisting = false;

            while (hasMore && pageCount < SCRAPER_CONFIG.MAX_PAGES) {
                pageCount++;
                console.log(`[Scraper] Processing page ${pageCount} for ${source.id}`);

                // Get current page content
                const html = await page.content();
                const pageArticles = parseArticlesFromHtml(html, source.id);

                for (const article of pageArticles) {
                    const articleId = `${source.id}_${article.original_id}`;

                    if (mode === 'incremental' && existingIds.has(articleId)) {
                        foundExisting = true;
                        console.log(`[Scraper] Found existing article ${articleId}, stopping`);
                        break;
                    }

                    articles.push(article);
                }

                if (foundExisting) {
                    hasMore = false;
                    break;
                }

                // Try to click "Load More" button
                hasMore = await this.clickLoadMore(page);

                if (hasMore) {
                    await delay(SCRAPER_CONFIG.DELAY_MS);
                }
            }

            console.log(`[Scraper] Completed ${source.id}: found ${articles.length} articles`);
        } catch (error) {
            const errorMsg = error instanceof Error ? error.message : String(error);
            errors.push(`Error scraping ${source.id}: ${errorMsg}`);
            console.error(`[Scraper] Error:`, error);
        } finally {
            await page.close();
        }

        return { articles, errors };
    }

    /**
     * Click the "Load More" button if it exists
     * @returns true if more content was loaded, false otherwise
     */
    private async clickLoadMore(page: Page): Promise<boolean> {
        try {
            // Common patterns for load more buttons
            const selectors = [
                'button:has-text("المزيد")',
                'a:has-text("المزيد")',
                '.load-more',
                '.more-button',
                'button.more',
                '[data-action="load-more"]',
            ];

            for (const selector of selectors) {
                try {
                    const button = await page.$(selector);
                    if (button) {
                        const isVisible = await button.isVisible();
                        if (isVisible) {
                            await button.click();
                            // Wait for content to load
                            await page.waitForNetworkIdle({ timeout: 10000 });
                            return true;
                        }
                    }
                } catch {
                    // Selector not found, try next
                }
            }

            // Alternative: scroll to bottom and check for lazy loading
            const previousHeight = await page.evaluate(() => document.body.scrollHeight);
            await page.evaluate(() => window.scrollTo(0, document.body.scrollHeight));
            await delay(1000);
            const newHeight = await page.evaluate(() => document.body.scrollHeight);

            return newHeight > previousHeight;
        } catch {
            return false;
        }
    }

    /**
     * Scrape article detail page
     */
    async scrapeArticleDetail(url: string): Promise<{
        content_html?: string;
        content_plain?: string;
        pdf_url?: string;
    }> {
        const page = await this.createPage();

        try {
            await page.goto(url, {
                waitUntil: 'networkidle2',
                timeout: SCRAPER_CONFIG.TIMEOUT_MS,
            });

            const html = await page.content();
            return parseArticleDetail(html);
        } finally {
            await page.close();
        }
    }
}

// Singleton instance
let scraperInstance: UqnScraper | null = null;

/**
 * Get scraper instance
 */
export async function getScraper(): Promise<UqnScraper> {
    if (!scraperInstance) {
        scraperInstance = new UqnScraper();
        await scraperInstance.init();
    }
    return scraperInstance;
}

/**
 * Close scraper instance
 */
export async function closeScraper(): Promise<void> {
    if (scraperInstance) {
        await scraperInstance.close();
        scraperInstance = null;
    }
}
