import { SourceDoc } from '../interfaces';
/**
 * Default sources configuration for Umm Al-Qura Gazette
 * These are the 7 official categories as defined in the plan
 */
export declare const DEFAULT_SOURCES: Omit<SourceDoc, 'last_sync_at' | 'article_count' | 'last_error'>[];
/**
 * Base URL for Umm Al-Qura website
 */
export declare const UQN_BASE_URL = "https://uqn.gov.sa";
/**
 * Scraper configuration
 */
export declare const SCRAPER_CONFIG: {
    DELAY_MS: number;
    MAX_PAGES: number;
    TIMEOUT_MS: number;
    USER_AGENT: string;
    VIEWPORT: {
        width: number;
        height: number;
    };
};
//# sourceMappingURL=sources.d.ts.map