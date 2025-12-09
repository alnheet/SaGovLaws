/**
 * Enhanced Browser Automation for Web Scraping
 * Handles JavaScript-heavy pages and infinite scroll / Load More buttons
 */
import { Browser, Page } from "puppeteer";
export interface BrowserSession {
    browser: Browser;
    page: Page;
    initialized_at: Date;
}
export interface ScrapingOptions {
    headless?: boolean;
    timeout?: number;
    loadMoreClicks?: number;
    scrollDelay?: number;
    pageWaitSelector?: string;
}
export declare class BrowserManager {
    private static instance;
    /**
     * Initialize Puppeteer browser with optimal settings for Cloud Run
     */
    static initializeBrowser(options?: ScrapingOptions): Promise<BrowserSession>;
    /**
     * Navigate to URL with wait conditions
     */
    static navigateToUrl(session: BrowserSession, url: string, waitSelector?: string): Promise<void>;
    /**
     * Click "Load More" button repeatedly to load all articles
     */
    static loadMoreArticles(session: BrowserSession, loadMoreSelector: string, maxClicks?: number, scrollDelay?: number): Promise<number>;
    /**
     * Scroll page to load dynamic content
     */
    static scrollToBottom(session: BrowserSession, scrollDelay?: number): Promise<number>;
    /**
     * Get page HTML content
     */
    static getPageContent(session: BrowserSession): Promise<string>;
    /**
     * Take screenshot for debugging
     */
    static takeScreenshot(session: BrowserSession, filename: string): Promise<void>;
    /**
     * Close browser session
     */
    static closeBrowser(session: BrowserSession): Promise<void>;
    /**
     * Execute custom script in page context
     */
    static executeScript(session: BrowserSession, script: string): Promise<any>;
    /**
     * Wait for selector with logging
     */
    static waitForSelector(session: BrowserSession, selector: string, timeout?: number): Promise<boolean>;
    /**
     * Helper: Delay execution
     */
    private static delay;
}
export default BrowserManager;
//# sourceMappingURL=browser_enhanced.d.ts.map