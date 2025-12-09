import { ParsedArticle, SourceDoc } from '../interfaces';
/**
 * UQN Scraper class - handles browser automation for scraping
 */
export declare class UqnScraper {
    private browser;
    /**
     * Initialize the browser instance
     */
    init(): Promise<void>;
    /**
     * Close browser instance
     */
    close(): Promise<void>;
    /**
     * Create a new page with proper settings
     */
    private createPage;
    /**
     * Scrape a category page
     * @param source - Source configuration
     * @param mode - 'full' for all pages, 'incremental' for new only
     * @param existingIds - Set of existing article IDs (for incremental mode)
     */
    scrapeCategory(source: SourceDoc, mode: 'full' | 'incremental', existingIds?: Set<string>): Promise<{
        articles: ParsedArticle[];
        errors: string[];
    }>;
    /**
     * Click the "Load More" button if it exists
     * @returns true if more content was loaded, false otherwise
     */
    private clickLoadMore;
    /**
     * Scrape article detail page
     */
    scrapeArticleDetail(url: string): Promise<{
        content_html?: string;
        content_plain?: string;
        pdf_url?: string;
    }>;
}
/**
 * Get scraper instance
 */
export declare function getScraper(): Promise<UqnScraper>;
/**
 * Close scraper instance
 */
export declare function closeScraper(): Promise<void>;
//# sourceMappingURL=browser.d.ts.map