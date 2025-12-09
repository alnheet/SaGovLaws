import { Timestamp } from 'firebase-admin/firestore';
/**
 * Source document interface
 * Represents a news category/source from Umm Al-Qura Gazette
 */
export interface SourceDoc {
    id: string;
    name_ar: string;
    name_en: string;
    cat_id: number;
    url: string;
    enabled: boolean;
    icon: string;
    color: string;
    order: number;
    last_sync_at?: Timestamp;
    article_count?: number;
    last_error?: string | null;
}
/**
 * Article document interface
 * Represents a single article/decision from the gazette
 */
export interface ArticleDoc {
    id: string;
    original_id: string;
    source_key: string;
    source_name_ar: string;
    cat_id: number;
    title: string;
    content_html?: string | null;
    content_plain?: string | null;
    excerpt?: string | null;
    publish_date_raw: string;
    publish_date_gregorian?: string | null;
    publish_date_iso?: Timestamp;
    url: string;
    pdf_url?: string | null;
    pdf_storage_path?: string | null;
    has_pdf: boolean;
    scraped_at: Timestamp;
    updated_at: Timestamp;
    tags?: string[];
    related_archive_id?: string | null;
}
/**
 * User document interface
 */
export interface UserDoc {
    uid: string;
    email?: string | null;
    display_name?: string | null;
    notification_enabled: boolean;
    notification_hours?: number[];
    subscribed_sources: string[];
    theme: 'light' | 'dark' | 'system';
    font_size: 'small' | 'medium' | 'large';
    fcm_tokens: string[];
    created_at: Timestamp;
    updated_at: Timestamp;
    last_seen_at?: Timestamp;
}
/**
 * Favorite document interface (subcollection under users)
 */
export interface FavoriteDoc {
    article_id: string;
    source_key: string;
    added_at: Timestamp;
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
//# sourceMappingURL=index.d.ts.map