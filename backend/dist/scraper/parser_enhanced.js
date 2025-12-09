"use strict";
/**
 * Enhanced HTML Parser for Saudi Government Documents
 * Extracts articles from uqn.gov.sa with improved selectors and validation
 */
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.ArticleParser = void 0;
const cheerio_1 = __importDefault(require("cheerio"));
class ArticleParser {
    /**
     * Parse articles from HTML content
     * Handles multiple document layouts from uqn.gov.sa
     */
    static parseArticlesFromHTML(html, sourceKey, sourceUrl, categoryName) {
        const $ = cheerio_1.default.load(html);
        const articles = [];
        // Try multiple selector patterns for article containers
        const selectors = [
            ".article-item",
            ".document-item",
            ".item",
            "[data-type='document']",
            "article",
            ".row.item-container",
            ".item-body"
        ];
        let $items = null;
        for (const selector of selectors) {
            const items = $(selector);
            if (items.length > 0) {
                $items = items;
                console.log(`✓ Found ${items.length} items using selector: ${selector}`);
                break;
            }
        }
        if (!$items || $items.length === 0) {
            console.warn(`⚠️ No article items found in HTML for ${sourceKey}`);
            return [];
        }
        $items.each((index, element) => {
            try {
                const $item = $(element);
                // Extract title - try multiple selectors
                const titleSelectors = [".item-title", "h2", "h3", ".title", "[data-field='title']"];
                let title = "";
                for (const sel of titleSelectors) {
                    title = $item.find(sel).text().trim();
                    if (title)
                        break;
                }
                if (!title) {
                    console.warn(`⚠️ Skipping item ${index + 1}: No title found`);
                    return;
                }
                // Extract description
                const descriptionSelectors = [".item-description", ".description", "p", ".text"];
                let description = "";
                for (const sel of descriptionSelectors) {
                    const text = $item.find(sel).text().trim();
                    if (text && text.length > 20) {
                        description = text.substring(0, 500);
                        break;
                    }
                }
                // Extract publish date
                const dateSelectors = [
                    ".item-date",
                    ".date",
                    "[data-field='date']",
                    ".publish-date",
                    ".item-meta"
                ];
                let publishedAt = null;
                for (const sel of dateSelectors) {
                    const dateStr = $item.find(sel).text().trim();
                    if (dateStr) {
                        publishedAt = this.parseDate(dateStr);
                        if (publishedAt)
                            break;
                    }
                }
                // Extract PDF URL
                const pdfSelectors = [
                    "a[href*='.pdf']",
                    ".item-pdf a",
                    "[data-type='pdf'] a",
                    "a.pdf-link"
                ];
                let pdfUrl = null;
                for (const sel of pdfSelectors) {
                    const href = $item.find(sel).attr("href");
                    if (href) {
                        pdfUrl = this.normalizeUrl(href, "https://uqn.gov.sa");
                        if (pdfUrl)
                            break;
                    }
                }
                // Extract HTML URL
                const linkSelectors = ["a.item-link", "a.title-link", "h2 a", "h3 a"];
                let htmlUrl = null;
                for (const sel of linkSelectors) {
                    const href = $item.find(sel).attr("href");
                    if (href) {
                        htmlUrl = this.normalizeUrl(href, "https://uqn.gov.sa");
                        if (htmlUrl)
                            break;
                    }
                }
                // Extract image URL
                const imageSelectors = [
                    "img",
                    ".item-image img",
                    "[data-type='image'] img"
                ];
                let imageUrl = null;
                for (const sel of imageSelectors) {
                    const src = $item.find(sel).attr("src");
                    if (src) {
                        imageUrl = this.normalizeUrl(src, "https://uqn.gov.sa");
                        if (imageUrl)
                            break;
                    }
                }
                // Extract official number (for government documents)
                const numberSelectors = [
                    ".official-number",
                    "[data-field='number']",
                    ".document-number"
                ];
                let officialNumber = undefined;
                for (const sel of numberSelectors) {
                    const num = $item.find(sel).text().trim();
                    if (num) {
                        officialNumber = num;
                        break;
                    }
                }
                // Extract tags from content
                const tags = this.extractTags(title, description, categoryName);
                // Determine if primary content is PDF
                const isPdf = !!pdfUrl;
                // Count words in description
                const wordCount = description.split(/\s+/).length;
                const article = {
                    title,
                    title_ar: title, // Arabic content
                    description,
                    content: description, // Use description as main content
                    source_key: sourceKey,
                    source_url: sourceUrl,
                    published_at: publishedAt,
                    pdf_url: pdfUrl,
                    html_url: htmlUrl,
                    image_url: imageUrl,
                    category: categoryName,
                    is_pdf: isPdf,
                    word_count: wordCount,
                    language: "ar",
                    tags,
                    official_number: officialNumber,
                    document_type: this.inferDocumentType(categoryName)
                };
                articles.push(article);
            }
            catch (error) {
                console.error(`❌ Error parsing item ${index + 1}:`, error);
            }
        });
        console.log(`✅ Successfully parsed ${articles.length} articles from ${sourceKey}`);
        return articles;
    }
    /**
     * Parse date from various formats common in Saudi documents
     */
    static parseDate(dateStr) {
        if (!dateStr)
            return null;
        // Islamic date pattern
        const hijriMatch = dateStr.match(/(\d{1,2})\s*\/\s*(\d{1,2})\s*\/\s*(\d{4})\s*ه/);
        if (hijriMatch) {
            // Simplified Hijri conversion (use a proper library for production)
            console.log(`📅 Found Hijri date: ${dateStr}`);
            // For now, use current date as fallback
            return new Date();
        }
        // Gregorian date pattern (DD/MM/YYYY or YYYY-MM-DD)
        const gregorianMatch = dateStr.match(/(\d{1,4})-(\d{1,2})-(\d{1,2})|(\d{1,2})\/(\d{1,2})\/(\d{4})/);
        if (gregorianMatch) {
            try {
                const [, y1, m1, d1, d2, m2, y2] = gregorianMatch;
                const year = y1 ? parseInt(y1) : parseInt(y2);
                const month = m1 ? parseInt(m1) : parseInt(m2);
                const day = d1 ? parseInt(d1) : parseInt(d2);
                return new Date(year, month - 1, day);
            }
            catch (error) {
                console.error(`❌ Failed to parse date: ${dateStr}`);
            }
        }
        return null;
    }
    /**
     * Normalize URL to absolute path
     */
    static normalizeUrl(url, baseUrl) {
        if (!url)
            return null;
        try {
            // Already absolute
            if (url.startsWith("http")) {
                return url;
            }
            // Relative URL
            if (url.startsWith("/")) {
                return `${baseUrl}${url}`;
            }
            // Relative without leading slash
            return `${baseUrl}/${url}`;
        }
        catch (error) {
            console.error(`❌ Failed to normalize URL: ${url}`);
            return null;
        }
    }
    /**
     * Extract keywords/tags from content
     */
    static extractTags(title, description, category) {
        const tags = new Set();
        // Add category as tag
        tags.add(category);
        // Extract important words (3+ characters)
        const content = `${title} ${description}`;
        const words = content
            .split(/[\s\-\.]/)
            .filter((w) => w.length >= 3)
            .slice(0, 10);
        words.forEach((word) => tags.add(word));
        return Array.from(tags);
    }
    /**
     * Infer document type from category name
     */
    static inferDocumentType(category) {
        const mapping = {
            "قرارات مجلس الوزراء": "قرار",
            "أوامر ملكية": "أمر",
            "مراسيم ملكية": "مرسوم",
            "قرارات وأنظمة": "قرار/نظام",
            "لوائح وأنظمة": "لائحة",
            "قرارات وزارية": "قرار وزاري",
            "هيئات": "وثيقة"
        };
        return mapping[category] || "وثيقة رسمية";
    }
    /**
     * Validate parsed articles
     */
    static validateArticles(articles) {
        return articles.filter((article) => {
            // Must have title
            if (!article.title || article.title.length < 3) {
                console.warn(`⚠️ Skipping article: Invalid title`);
                return false;
            }
            // Must have either PDF or HTML URL
            if (!article.pdf_url && !article.html_url) {
                console.warn(`⚠️ Skipping article: No PDF or HTML URL - ${article.title}`);
                return false;
            }
            // Should have at least some description
            if (!article.description || article.description.length < 10) {
                console.warn(`⚠️ Skipping article: Insufficient description - ${article.title}`);
                return false;
            }
            return true;
        });
    }
}
exports.ArticleParser = ArticleParser;
exports.default = ArticleParser;
//# sourceMappingURL=parser_enhanced.js.map