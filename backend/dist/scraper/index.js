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
var __exportStar = (this && this.__exportStar) || function(m, exports) {
    for (var p in m) if (p !== "default" && !Object.prototype.hasOwnProperty.call(exports, p)) __createBinding(exports, m, p);
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.runScraper = runScraper;
exports.scrapeSingleSource = scrapeSingleSource;
const config_1 = require("../config");
const browser_1 = require("./browser");
const storage_1 = require("./storage");
/**
 * Main scraper orchestrator
 * Coordinates scraping of all enabled sources
 */
async function runScraper(mode = 'incremental') {
    const results = [];
    const storage = new storage_1.ArticleStorage();
    try {
        // Initialize sources if needed
        await storage.initializeSources(config_1.DEFAULT_SOURCES);
        // Get enabled sources
        const sources = await storage.getEnabledSources();
        console.log(`[Main] Starting ${mode} sync for ${sources.length} sources`);
        // Get scraper instance
        const scraper = await (0, browser_1.getScraper)();
        for (const source of sources) {
            const startTime = Date.now();
            const result = {
                source_key: source.id,
                total_found: 0,
                new_articles: 0,
                updated_articles: 0,
                errors: [],
                duration_ms: 0,
            };
            try {
                // Get existing IDs for incremental mode
                const existingIds = mode === 'incremental'
                    ? await storage.getExistingArticleIds(source.id)
                    : new Set();
                // Scrape category
                const { articles, errors } = await scraper.scrapeCategory(source, mode, existingIds);
                result.errors = errors;
                result.total_found = articles.length;
                if (articles.length > 0) {
                    // Upsert to Firestore
                    const { newCount, updatedCount } = await storage.upsertArticles(articles, source);
                    result.new_articles = newCount;
                    result.updated_articles = updatedCount;
                }
                // Update source metadata
                const articleCount = await storage.getArticleCount(source.id);
                await storage.updateSourceMeta(source.id, {
                    article_count: articleCount,
                    last_error: errors.length > 0 ? errors.join('; ') : null,
                });
            }
            catch (error) {
                const errorMsg = error instanceof Error ? error.message : String(error);
                result.errors.push(errorMsg);
                await storage.updateSourceMeta(source.id, {
                    last_error: errorMsg,
                });
            }
            result.duration_ms = Date.now() - startTime;
            results.push(result);
            console.log(`[Main] ${source.id}: ${result.new_articles} new, ${result.updated_articles} updated in ${result.duration_ms}ms`);
        }
    }
    finally {
        await (0, browser_1.closeScraper)();
    }
    return results;
}
/**
 * Scrape a single source
 */
async function scrapeSingleSource(sourceKey, mode = 'incremental') {
    const storage = new storage_1.ArticleStorage();
    const sources = await storage.getEnabledSources();
    const source = sources.find(s => s.id === sourceKey);
    if (!source) {
        throw new Error(`Source not found: ${sourceKey}`);
    }
    const startTime = Date.now();
    const result = {
        source_key: source.id,
        total_found: 0,
        new_articles: 0,
        updated_articles: 0,
        errors: [],
        duration_ms: 0,
    };
    try {
        const scraper = await (0, browser_1.getScraper)();
        const existingIds = mode === 'incremental'
            ? await storage.getExistingArticleIds(source.id)
            : new Set();
        const { articles, errors } = await scraper.scrapeCategory(source, mode, existingIds);
        result.errors = errors;
        result.total_found = articles.length;
        if (articles.length > 0) {
            const { newCount, updatedCount } = await storage.upsertArticles(articles, source);
            result.new_articles = newCount;
            result.updated_articles = updatedCount;
        }
        const articleCount = await storage.getArticleCount(source.id);
        await storage.updateSourceMeta(source.id, {
            article_count: articleCount,
            last_error: errors.length > 0 ? errors.join('; ') : null,
        });
    }
    catch (error) {
        const errorMsg = error instanceof Error ? error.message : String(error);
        result.errors.push(errorMsg);
        await storage.updateSourceMeta(source.id, {
            last_error: errorMsg,
        });
    }
    finally {
        await (0, browser_1.closeScraper)();
    }
    result.duration_ms = Date.now() - startTime;
    return result;
}
// Export all scraper modules
__exportStar(require("./browser"), exports);
__exportStar(require("./parser"), exports);
__exportStar(require("./storage"), exports);
//# sourceMappingURL=index.js.map