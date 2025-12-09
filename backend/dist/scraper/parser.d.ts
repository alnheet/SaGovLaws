import { ParsedArticle } from '../interfaces';
/**
 * Parse articles from category page HTML
 * @param html - Raw HTML content
 * @param sourceKey - Source identifier for this category
 * @returns Array of parsed articles
 */
export declare function parseArticlesFromHtml(html: string, sourceKey: string): ParsedArticle[];
/**
 * Extract original article ID from URL
 * Handles formats like: ?p=28661, /details?p=28661, /article/28661
 */
export declare function extractOriginalId(url: string): string | null;
/**
 * Parse article detail page for full content
 */
export declare function parseArticleDetail(html: string): {
    content_html?: string;
    content_plain?: string;
    pdf_url?: string;
};
/**
 * Parse Hijri date string and attempt to extract Gregorian equivalent
 * Format examples: "1446/05/28", "28 جمادى الأولى 1446"
 */
export declare function parseDateString(dateStr: string): {
    raw: string;
    gregorian?: string;
};
/**
 * Generate excerpt from content
 */
export declare function generateExcerpt(content: string, maxLength?: number): string;
/**
 * Sanitize HTML content (remove scripts, iframes, etc.)
 */
export declare function sanitizeHtml(html: string): string;
//# sourceMappingURL=parser.d.ts.map