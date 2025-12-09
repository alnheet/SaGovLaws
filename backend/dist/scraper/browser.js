"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.UqnScraper = void 0;
exports.getScraper = getScraper;
exports.closeScraper = closeScraper;
const puppeteer_1 = __importDefault(require("puppeteer"));
const config_1 = require("../config");
const parser_1 = require("./parser");
/**
 * Delay helper function
 */
function delay(ms) {
    return new Promise(resolve => setTimeout(resolve, ms));
}
/**
 * UQN Scraper class - handles browser automation for scraping
 */
class UqnScraper {
    constructor() {
        this.browser = null;
    }
    /**
     * Initialize the browser instance
     */
    async init() {
        if (this.browser)
            return;
        this.browser = await puppeteer_1.default.launch({
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
    async close() {
        if (this.browser) {
            await this.browser.close();
            this.browser = null;
        }
    }
    /**
     * Create a new page with proper settings
     */
    async createPage() {
        if (!this.browser) {
            throw new Error('Browser not initialized. Call init() first.');
        }
        const page = await this.browser.newPage();
        await page.setViewport(config_1.SCRAPER_CONFIG.VIEWPORT);
        await page.setUserAgent(config_1.SCRAPER_CONFIG.USER_AGENT);
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
    async scrapeCategory(source, mode, existingIds = new Set()) {
        const page = await this.createPage();
        const articles = [];
        const errors = [];
        try {
            console.log(`[Scraper] Starting ${mode} scrape for ${source.id}`);
            // Navigate to category page
            await page.goto(source.url, {
                waitUntil: 'networkidle2',
                timeout: config_1.SCRAPER_CONFIG.TIMEOUT_MS,
            });
            let pageCount = 0;
            let hasMore = true;
            let foundExisting = false;
            while (hasMore && pageCount < config_1.SCRAPER_CONFIG.MAX_PAGES) {
                pageCount++;
                console.log(`[Scraper] Processing page ${pageCount} for ${source.id}`);
                // Get current page content
                const html = await page.content();
                const pageArticles = (0, parser_1.parseArticlesFromHtml)(html, source.id);
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
                    await delay(config_1.SCRAPER_CONFIG.DELAY_MS);
                }
            }
            console.log(`[Scraper] Completed ${source.id}: found ${articles.length} articles`);
        }
        catch (error) {
            const errorMsg = error instanceof Error ? error.message : String(error);
            errors.push(`Error scraping ${source.id}: ${errorMsg}`);
            console.error(`[Scraper] Error:`, error);
        }
        finally {
            await page.close();
        }
        return { articles, errors };
    }
    /**
     * Click the "Load More" button if it exists
     * @returns true if more content was loaded, false otherwise
     */
    async clickLoadMore(page) {
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
                }
                catch {
                    // Selector not found, try next
                }
            }
            // Alternative: scroll to bottom and check for lazy loading
            const previousHeight = await page.evaluate(() => document.body.scrollHeight);
            await page.evaluate(() => window.scrollTo(0, document.body.scrollHeight));
            await delay(1000);
            const newHeight = await page.evaluate(() => document.body.scrollHeight);
            return newHeight > previousHeight;
        }
        catch {
            return false;
        }
    }
    /**
     * Scrape article detail page
     */
    async scrapeArticleDetail(url) {
        const page = await this.createPage();
        try {
            await page.goto(url, {
                waitUntil: 'networkidle2',
                timeout: config_1.SCRAPER_CONFIG.TIMEOUT_MS,
            });
            const html = await page.content();
            return (0, parser_1.parseArticleDetail)(html);
        }
        finally {
            await page.close();
        }
    }
}
exports.UqnScraper = UqnScraper;
// Singleton instance
let scraperInstance = null;
/**
 * Get scraper instance
 */
async function getScraper() {
    if (!scraperInstance) {
        scraperInstance = new UqnScraper();
        await scraperInstance.init();
    }
    return scraperInstance;
}
/**
 * Close scraper instance
 */
async function closeScraper() {
    if (scraperInstance) {
        await scraperInstance.close();
        scraperInstance = null;
    }
}
//# sourceMappingURL=browser.js.map