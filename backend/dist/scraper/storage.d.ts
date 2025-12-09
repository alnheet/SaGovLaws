import { ParsedArticle, SourceDoc } from '../interfaces';
/**
 * Firestore operations for scraper
 */
export declare class ArticleStorage {
    private db;
    constructor();
    /**
     * Get all enabled sources
     */
    getEnabledSources(): Promise<SourceDoc[]>;
    /**
     * Get existing article IDs for a source
     */
    getExistingArticleIds(sourceKey: string): Promise<Set<string>>;
    /**
     * Upsert articles to Firestore
     * @returns Number of new and updated articles
     */
    upsertArticles(articles: ParsedArticle[], source: SourceDoc): Promise<{
        newCount: number;
        updatedCount: number;
    }>;
    /**
     * Update source sync metadata
     */
    updateSourceMeta(sourceKey: string, data: {
        article_count?: number;
        last_error?: string | null;
    }): Promise<void>;
    /**
     * Get article count for a source
     */
    getArticleCount(sourceKey: string): Promise<number>;
    /**
     * Initialize sources collection with default data
     */
    initializeSources(sources: Omit<SourceDoc, 'last_sync_at' | 'article_count' | 'last_error'>[]): Promise<void>;
}
//# sourceMappingURL=storage.d.ts.map