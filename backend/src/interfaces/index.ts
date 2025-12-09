import { Timestamp } from 'firebase-admin/firestore';

/**
 * Source document interface
 * Represents a news category/source from Umm Al-Qura Gazette
 */
export interface SourceDoc {
    id: string;                    // e.g., "cabinet_decisions"
    name_ar: string;               // Arabic name
    name_en: string;               // English name
    cat_id: number;                // Category ID from website
    url: string;                   // Full URL to category page
    enabled: boolean;              // Whether source is active
    icon: string;                  // Material icon name
    color: string;                 // Hex color code
    order: number;                 // Display order in tabs
    last_sync_at?: Timestamp;      // Last successful sync
    article_count?: number;        // Total articles count
    last_error?: string | null;    // Last error message if any
}

/**
 * Article document interface
 * Represents a single article/decision from the gazette
 */
export interface ArticleDoc {
    id: string;                    // "{source_key}_{original_id}"
    original_id: string;           // Original ID from website
    source_key: string;            // Source identifier
    source_name_ar: string;        // Arabic source name (denormalized)
    cat_id: number;                // Category ID

    // Core content
    title: string;                 // Article title
    content_html?: string | null;  // Full HTML content
    content_plain?: string | null; // Plain text (for search)
    excerpt?: string | null;       // Short excerpt

    // Dates
    publish_date_raw: string;      // Raw date string (Hijri/combined)
    publish_date_gregorian?: string | null;  // Gregorian date "YYYY-MM-DD"
    publish_date_iso?: Timestamp;  // Normalized timestamp for sorting

    // URLs & attachments
    url: string;                   // Detail page URL
    pdf_url?: string | null;       // Direct PDF URL
    pdf_storage_path?: string | null;  // Firebase Storage path
    has_pdf: boolean;              // Quick check for PDF availability

    // Meta
    scraped_at: Timestamp;         // When article was scraped
    updated_at: Timestamp;         // Last update timestamp

    tags?: string[];               // Optional tags
    related_archive_id?: string | null;  // Related archive reference
}

/**
 * User document interface
 */
export interface UserDoc {
    uid: string;                   // Firebase Auth UID
    email?: string | null;
    display_name?: string | null;

    // Notification preferences
    notification_enabled: boolean;
    notification_hours?: number[]; // Hours for notifications [8, 14, 20]

    // Subscriptions
    subscribed_sources: string[];  // Source keys or ["all"]

    // UI settings
    theme: 'light' | 'dark' | 'system';
    font_size: 'small' | 'medium' | 'large';

    // Device & meta
    fcm_tokens: string[];          // FCM tokens for push
    created_at: Timestamp;
    updated_at: Timestamp;
    last_seen_at?: Timestamp;
}

/**
 * Favorite document interface (subcollection under users)
 */
export interface FavoriteDoc {
    article_id: string;            // Article document ID
    source_key: string;            // Source key for filtering
    added_at: Timestamp;           // When favorited
}

/**
 * Parsed article from scraper (before Firestore conversion)
 */
export interface ParsedArticle {
    original_id: string;
    title: string;
    url: string;
    publish_date_raw: string;
    publish_date_gregorian?: string;
    content_html?: string;
    pdf_url?: string;
}

/**
 * Scrape result summary
 */
export interface ScrapeResult {
    source_key: string;
    total_found: number;
    new_articles: number;
    updated_articles: number;
    errors: string[];
    duration_ms: number;
}
