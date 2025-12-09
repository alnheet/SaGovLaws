import { SourceDoc } from '../interfaces';

/**
 * Default sources configuration for Umm Al-Qura Gazette
 * These are the 7 official categories as defined in the plan
 */
export const DEFAULT_SOURCES: Omit<SourceDoc, 'last_sync_at' | 'article_count' | 'last_error'>[] = [
    {
        id: 'cabinet_decisions',
        name_ar: 'قرارات مجلس الوزراء',
        name_en: 'Cabinet Decisions',
        cat_id: 9,
        url: 'https://uqn.gov.sa/category?cat=9',
        enabled: true,
        icon: 'gavel',
        color: '#1976D2',
        order: 1,
    },
    {
        id: 'royal_orders',
        name_ar: 'أوامر ملكية',
        name_en: 'Royal Orders',
        cat_id: 7,
        url: 'https://uqn.gov.sa/category?cat=7',
        enabled: true,
        icon: 'verified',
        color: '#7B1FA2',
        order: 2,
    },
    {
        id: 'royal_decrees',
        name_ar: 'مراسيم ملكية',
        name_en: 'Royal Decrees',
        cat_id: 8,
        url: 'https://uqn.gov.sa/category?cat=8',
        enabled: true,
        icon: 'article',
        color: '#C2185B',
        order: 3,
    },
    {
        id: 'decisions_regulations',
        name_ar: 'قرارات وأنظمة',
        name_en: 'Decisions & Regulations',
        cat_id: 6,
        url: 'https://uqn.gov.sa/category?cat=6',
        enabled: true,
        icon: 'description',
        color: '#00796B',
        order: 4,
    },
    {
        id: 'laws_regulations',
        name_ar: 'لوائح وأنظمة',
        name_en: 'Laws & Regulations',
        cat_id: 11,
        url: 'https://uqn.gov.sa/category?cat=11',
        enabled: true,
        icon: 'balance',
        color: '#F57C00',
        order: 5,
    },
    {
        id: 'ministerial_decisions',
        name_ar: 'قرارات وزارية',
        name_en: 'Ministerial Decisions',
        cat_id: 10,
        url: 'https://uqn.gov.sa/category?cat=10',
        enabled: true,
        icon: 'account_balance',
        color: '#5D4037',
        order: 6,
    },
    {
        id: 'authorities',
        name_ar: 'هيئات',
        name_en: 'Authorities',
        cat_id: 12,
        url: 'https://uqn.gov.sa/category?cat=12',
        enabled: true,
        icon: 'business',
        color: '#455A64',
        order: 7,
    },
];

/**
 * Base URL for Umm Al-Qura website
 */
export const UQN_BASE_URL = 'https://uqn.gov.sa';

/**
 * Scraper configuration
 */
export const SCRAPER_CONFIG = {
    // Delay between page loads (ms)
    DELAY_MS: parseInt(process.env.SCRAPE_DELAY_MS || '2000'),

    // Maximum pages to scrape per run
    MAX_PAGES: parseInt(process.env.MAX_PAGES_PER_RUN || '50'),

    // Page load timeout (ms)
    TIMEOUT_MS: parseInt(process.env.SCRAPE_TIMEOUT_MS || '60000'),

    // User agent for requests
    USER_AGENT: 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',

    // Viewport size for Puppeteer
    VIEWPORT: {
        width: 1920,
        height: 1080,
    },
};
