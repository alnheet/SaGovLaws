/**
 * Enhanced HTML Parser for Saudi Government Documents
 * Extracts articles from uqn.gov.sa with improved selectors and validation
 */
export interface ParsedArticle {
    title: string;
    title_ar?: string;
    description: string;
    content: string;
    source_key: string;
    source_url: string;
    published_at: Date | null;
    pdf_url: string | null;
    html_url: string | null;
    image_url: string | null;
    category: string;
    is_pdf: boolean;
    word_count: number;
    language: "ar" | "en";
    tags: string[];
    official_number?: string;
    document_type?: string;
}
export declare class ArticleParser {
    /**
     * Parse articles from HTML content
     * Handles multiple document layouts from uqn.gov.sa
     */
    static parseArticlesFromHTML(html: string, sourceKey: string, sourceUrl: string, categoryName: string): ParsedArticle[];
    /**
     * Parse date from various formats common in Saudi documents
     */
    private static parseDate;
    /**
     * Normalize URL to absolute path
     */
    private static normalizeUrl;
    /**
     * Extract keywords/tags from content
     */
    private static extractTags;
    /**
     * Infer document type from category name
     */
    private static inferDocumentType;
    /**
     * Validate parsed articles
     */
    static validateArticles(articles: ParsedArticle[]): ParsedArticle[];
}
export default ArticleParser;
//# sourceMappingURL=parser_enhanced.d.ts.map