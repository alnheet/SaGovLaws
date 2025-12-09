import * as cheerio from 'cheerio';
import { UQN_BASE_URL } from '../config';
import { ParsedArticle } from '../interfaces';

/**
 * Parse articles from category page HTML
 * @param html - Raw HTML content
 * @param sourceKey - Source identifier for this category
 * @returns Array of parsed articles
 */
export function parseArticlesFromHtml(html: string, sourceKey: string): ParsedArticle[] {
    const $ = cheerio.load(html);
    const articles: ParsedArticle[] = [];

    // Select article cards/items - adjust selector based on actual DOM structure
    // Common patterns: .post-item, .article-card, article, .news-item
    const articleElements = $('.news-item, .post-item, article, .card').toArray();

    for (const element of articleElements) {
        try {
            const $el = $(element);

            // Extract article URL and original ID
            const linkEl = $el.find('a[href*="?p="], a[href*="details"]').first();
            const url = linkEl.attr('href') || '';
            const original_id = extractOriginalId(url);

            if (!original_id) continue;

            // Extract title
            const title = $el.find('h2, h3, .title, .news-title').first().text().trim();
            if (!title) continue;

            // Extract date
            const dateText = $el.find('.date, .post-date, time, .news-date').first().text().trim();

            // Extract PDF link if present
            const pdfLink = $el.find('a[href*=".pdf"]').attr('href');

            // Build full URL if needed
            const fullUrl = url.startsWith('http') ? url : `${UQN_BASE_URL}${url}`;

            articles.push({
                original_id,
                title,
                url: fullUrl,
                publish_date_raw: dateText,
                pdf_url: pdfLink,
            });
        } catch (error) {
            console.error('Error parsing article element:', error);
        }
    }

    return articles;
}

/**
 * Extract original article ID from URL
 * Handles formats like: ?p=28661, /details?p=28661, /article/28661
 */
export function extractOriginalId(url: string): string | null {
    // Pattern 1: ?p=28661
    const pMatch = url.match(/[?&]p=(\d+)/);
    if (pMatch) return pMatch[1];

    // Pattern 2: /article/28661 or /details/28661
    const pathMatch = url.match(/\/(?:article|details|post)\/(\d+)/);
    if (pathMatch) return pathMatch[1];

    // Pattern 3: Last segment is numeric
    const lastSegment = url.split('/').pop();
    if (lastSegment && /^\d+$/.test(lastSegment)) {
        return lastSegment;
    }

    return null;
}

/**
 * Parse article detail page for full content
 */
export function parseArticleDetail(html: string): {
    content_html?: string;
    content_plain?: string;
    pdf_url?: string;
} {
    const $ = cheerio.load(html);

    // Find main content container
    const contentEl = $('.article-content, .post-content, .content, .entry-content, main article').first();
    const content_html = contentEl.html() || undefined;
    const content_plain = contentEl.text().trim() || undefined;

    // Look for PDF links
    const pdfUrl = $('a[href*=".pdf"]').first().attr('href');

    return {
        content_html,
        content_plain,
        pdf_url: pdfUrl,
    };
}

/**
 * Parse Hijri date string and attempt to extract Gregorian equivalent
 * Format examples: "1446/05/28", "28 جمادى الأولى 1446"
 */
export function parseDateString(dateStr: string): {
    raw: string;
    gregorian?: string;
} {
    // For now, just return the raw date
    // In production, use a Hijri-Gregorian conversion library
    return {
        raw: dateStr.trim(),
        // gregorian conversion would go here
    };
}

/**
 * Generate excerpt from content
 */
export function generateExcerpt(content: string, maxLength: number = 200): string {
    const cleaned = content.replace(/\s+/g, ' ').trim();
    if (cleaned.length <= maxLength) return cleaned;
    return cleaned.substring(0, maxLength - 3) + '...';
}

/**
 * Sanitize HTML content (remove scripts, iframes, etc.)
 */
export function sanitizeHtml(html: string): string {
    const $ = cheerio.load(html);

    // Remove potentially dangerous elements
    $('script, iframe, object, embed, form').remove();

    // Remove event handlers
    $('*').each((_, el) => {
        const element = $(el);
        const attributes = Object.keys(element.attr() || {});
        attributes.forEach(attr => {
            if (attr.startsWith('on')) {
                element.removeAttr(attr);
            }
        });
    });

    return $.html();
}
