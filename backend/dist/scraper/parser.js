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
var __setModuleDefault = (this && this.__setModuleDefault) || (Object.create ? (function(o, v) {
    Object.defineProperty(o, "default", { enumerable: true, value: v });
}) : function(o, v) {
    o["default"] = v;
});
var __importStar = (this && this.__importStar) || (function () {
    var ownKeys = function(o) {
        ownKeys = Object.getOwnPropertyNames || function (o) {
            var ar = [];
            for (var k in o) if (Object.prototype.hasOwnProperty.call(o, k)) ar[ar.length] = k;
            return ar;
        };
        return ownKeys(o);
    };
    return function (mod) {
        if (mod && mod.__esModule) return mod;
        var result = {};
        if (mod != null) for (var k = ownKeys(mod), i = 0; i < k.length; i++) if (k[i] !== "default") __createBinding(result, mod, k[i]);
        __setModuleDefault(result, mod);
        return result;
    };
})();
Object.defineProperty(exports, "__esModule", { value: true });
exports.parseArticlesFromHtml = parseArticlesFromHtml;
exports.extractOriginalId = extractOriginalId;
exports.parseArticleDetail = parseArticleDetail;
exports.parseDateString = parseDateString;
exports.generateExcerpt = generateExcerpt;
exports.sanitizeHtml = sanitizeHtml;
const cheerio = __importStar(require("cheerio"));
const config_1 = require("../config");
/**
 * Parse articles from category page HTML
 * @param html - Raw HTML content
 * @param sourceKey - Source identifier for this category
 * @returns Array of parsed articles
 */
function parseArticlesFromHtml(html, sourceKey) {
    const $ = cheerio.load(html);
    const articles = [];
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
            if (!original_id)
                continue;
            // Extract title
            const title = $el.find('h2, h3, .title, .news-title').first().text().trim();
            if (!title)
                continue;
            // Extract date
            const dateText = $el.find('.date, .post-date, time, .news-date').first().text().trim();
            // Extract PDF link if present
            const pdfLink = $el.find('a[href*=".pdf"]').attr('href');
            // Build full URL if needed
            const fullUrl = url.startsWith('http') ? url : `${config_1.UQN_BASE_URL}${url}`;
            articles.push({
                original_id,
                title,
                url: fullUrl,
                publish_date_raw: dateText,
                pdf_url: pdfLink,
            });
        }
        catch (error) {
            console.error('Error parsing article element:', error);
        }
    }
    return articles;
}
/**
 * Extract original article ID from URL
 * Handles formats like: ?p=28661, /details?p=28661, /article/28661
 */
function extractOriginalId(url) {
    // Pattern 1: ?p=28661
    const pMatch = url.match(/[?&]p=(\d+)/);
    if (pMatch)
        return pMatch[1];
    // Pattern 2: /article/28661 or /details/28661
    const pathMatch = url.match(/\/(?:article|details|post)\/(\d+)/);
    if (pathMatch)
        return pathMatch[1];
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
function parseArticleDetail(html) {
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
function parseDateString(dateStr) {
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
function generateExcerpt(content, maxLength = 200) {
    const cleaned = content.replace(/\s+/g, ' ').trim();
    if (cleaned.length <= maxLength)
        return cleaned;
    return cleaned.substring(0, maxLength - 3) + '...';
}
/**
 * Sanitize HTML content (remove scripts, iframes, etc.)
 */
function sanitizeHtml(html) {
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
//# sourceMappingURL=parser.js.map