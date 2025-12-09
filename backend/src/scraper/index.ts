import { DEFAULT_SOURCES } from '../config';
import { ScrapeResult } from '../interfaces';
import { closeScraper, getScraper } from './browser';
import { ArticleStorage } from './storage';

/**
 * Main scraper orchestrator
 * Coordinates scraping of all enabled sources
 */
export async function runScraper(mode: 'full' | 'incremental' = 'incremental'): Promise<ScrapeResult[]> {
    const results: ScrapeResult[] = [];
    const storage = new ArticleStorage();

    try {
        // Initialize sources if needed
        await storage.initializeSources(DEFAULT_SOURCES);

        // Get enabled sources
        const sources = await storage.getEnabledSources();
        console.log(`[Main] Starting ${mode} sync for ${sources.length} sources`);

        // Get scraper instance
        const scraper = await getScraper();

        for (const source of sources) {
            const startTime = Date.now();
            const result: ScrapeResult = {
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
                    : new Set<string>();

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

            } catch (error) {
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

    } finally {
        await closeScraper();
    }

    return results;
}

/**
 * Scrape a single source
 */
export async function scrapeSingleSource(sourceKey: string, mode: 'full' | 'incremental' = 'incremental'): Promise<ScrapeResult> {
    const storage = new ArticleStorage();
    const sources = await storage.getEnabledSources();
    const source = sources.find(s => s.id === sourceKey);

    if (!source) {
        throw new Error(`Source not found: ${sourceKey}`);
    }

    const startTime = Date.now();
    const result: ScrapeResult = {
        source_key: source.id,
        total_found: 0,
        new_articles: 0,
        updated_articles: 0,
        errors: [],
        duration_ms: 0,
    };

    try {
        const scraper = await getScraper();

        const existingIds = mode === 'incremental'
            ? await storage.getExistingArticleIds(source.id)
            : new Set<string>();

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

    } catch (error) {
        const errorMsg = error instanceof Error ? error.message : String(error);
        result.errors.push(errorMsg);

        await storage.updateSourceMeta(source.id, {
            last_error: errorMsg,
        });
    } finally {
        await closeScraper();
    }

    result.duration_ms = Date.now() - startTime;
    return result;
}

// Export all scraper modules
export * from './browser';
export * from './parser';
export * from './storage';

