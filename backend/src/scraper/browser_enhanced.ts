/**
 * Enhanced Browser Automation for Web Scraping
 * Handles JavaScript-heavy pages and infinite scroll / Load More buttons
 */

import puppeteer, { Browser, Page } from "puppeteer";

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

export class BrowserManager {
    private static instance: Browser | null = null;

    /**
     * Initialize Puppeteer browser with optimal settings for Cloud Run
     */
    static async initializeBrowser(
        options: ScrapingOptions = {}
    ): Promise<BrowserSession> {
        const {
            headless = true,
            timeout = 30000,
            loadMoreClicks = 5,
            scrollDelay = 1000
        } = options;

        try {
            // Cloud Run optimized settings
            const browser = await puppeteer.launch({
                headless,
                args: [
                    "--no-sandbox",
                    "--disable-setuid-sandbox",
                    "--disable-dev-shm-usage",
                    "--disable-gpu",
                    "--no-first-run",
                    "--no-zygote",
                    "--single-process" // Recommended for Cloud Run
                ]
            });

            const page = await browser.newPage();

            // Set viewport
            await page.setViewport({
                width: 1280,
                height: 720
            });

            // Set timeouts
            page.setDefaultTimeout(timeout);
            page.setDefaultNavigationTimeout(timeout);

            // Block unnecessary resources
            await page.setRequestInterception(true);
            page.on("request", (request) => {
                const resourceType = request.resourceType();
                if (["image", "stylesheet", "font"].includes(resourceType)) {
                    request.abort();
                } else {
                    request.continue();
                }
            });

            // Set User-Agent to avoid blocking
            await page.setUserAgent(
                "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36"
            );

            console.log("✅ Browser initialized successfully");

            return {
                browser,
                page,
                initialized_at: new Date()
            };
        } catch (error) {
            console.error("❌ Failed to initialize browser:", error);
            throw error;
        }
    }

    /**
     * Navigate to URL with wait conditions
     */
    static async navigateToUrl(
        session: BrowserSession,
        url: string,
        waitSelector?: string
    ): Promise<void> {
        try {
            console.log(`📍 Navigating to: ${url}`);

            await session.page.goto(url, {
                waitUntil: "networkidle2",
                timeout: 30000
            });

            // Wait for main content to load
            if (waitSelector) {
                await session.page.waitForSelector(waitSelector, {
                    timeout: 10000
                });
                console.log(`✓ Page element loaded: ${waitSelector}`);
            } else {
                // Wait for body to ensure page is ready
                await session.page.waitForSelector("body", {
                    timeout: 10000
                });
            }

            console.log("✅ Page loaded successfully");
        } catch (error) {
            console.error(`❌ Failed to navigate to ${url}:`, error);
            throw error;
        }
    }

    /**
     * Click "Load More" button repeatedly to load all articles
     */
    static async loadMoreArticles(
        session: BrowserSession,
        loadMoreSelector: string,
        maxClicks: number = 5,
        scrollDelay: number = 1000
    ): Promise<number> {
        let clickCount = 0;

        try {
            console.log(`🔄 Looking for "Load More" button: ${loadMoreSelector}`);

            for (let i = 0; i < maxClicks; i++) {
                const button = await session.page.$(loadMoreSelector);

                if (!button) {
                    console.log(`✓ No more "Load More" buttons found after ${clickCount} clicks`);
                    break;
                }

                // Scroll button into view
                await session.page.evaluate((el) => {
                    el.scrollIntoView();
                }, button);

                // Wait a bit before clicking
                await this.delay(scrollDelay / 2);

                // Click the button
                try {
                    await button.click();
                    clickCount++;
                    console.log(`✓ Clicked "Load More" (${clickCount}/${maxClicks})`);

                    // Wait for new content to load
                    await this.delay(scrollDelay);

                    // Wait for network to settle
                    try {
                        await session.page.waitForNavigation({
                            waitUntil: "networkidle2",
                            timeout: 5000
                        });
                    } catch {
                        // Navigation might not happen, that's okay
                    }
                } catch (clickError) {
                    console.warn(`⚠️ Failed to click button, might be disabled`);
                    break;
                }
            }

            console.log(`✅ Successfully clicked "Load More" ${clickCount} times`);
            return clickCount;
        } catch (error) {
            console.error(`❌ Error during load more:`, error);
            return clickCount;
        }
    }

    /**
     * Scroll page to load dynamic content
     */
    static async scrollToBottom(
        session: BrowserSession,
        scrollDelay: number = 1000
    ): Promise<number> {
        let scrollCount = 0;

        try {
            console.log("📜 Scrolling page to load dynamic content...");

            const scrollHeight = await session.page.evaluate(
                () => document.documentElement.scrollHeight
            );

            let currentPosition = 0;

            while (currentPosition < scrollHeight) {
                // Scroll down
                currentPosition += 500;
                await session.page.evaluate((position) => {
                    window.scrollBy(0, position);
                }, 500);

                scrollCount++;

                // Wait for content to load
                await this.delay(scrollDelay);

                // Update scroll height in case more content loaded
                const newHeight = await session.page.evaluate(
                    () => document.documentElement.scrollHeight
                );

                if (newHeight > scrollHeight) {
                    console.log(`✓ New content loaded (scroll ${scrollCount})`);
                    currentPosition = 0; // Reset to check again
                }
            }

            console.log(`✅ Scrolled ${scrollCount} times to bottom`);
            return scrollCount;
        } catch (error) {
            console.error(`❌ Error during scroll:`, error);
            return scrollCount;
        }
    }

    /**
     * Get page HTML content
     */
    static async getPageContent(session: BrowserSession): Promise<string> {
        try {
            const html = await session.page.content();
            console.log(`✓ Retrieved HTML (${html.length} bytes)`);
            return html;
        } catch (error) {
            console.error(`❌ Failed to get page content:`, error);
            throw error;
        }
    }

    /**
     * Take screenshot for debugging
     */
    static async takeScreenshot(
        session: BrowserSession,
        filename: string
    ): Promise<void> {
        try {
            await session.page.screenshot({
                path: filename,
                fullPage: true
            });
            console.log(`📸 Screenshot saved: ${filename}`);
        } catch (error) {
            console.warn(`⚠️ Failed to take screenshot:`, error);
        }
    }

    /**
     * Close browser session
     */
    static async closeBrowser(session: BrowserSession): Promise<void> {
        try {
            await session.browser.close();
            console.log("✅ Browser closed");
        } catch (error) {
            console.error(`❌ Failed to close browser:`, error);
        }
    }

    /**
     * Execute custom script in page context
     */
    static async executeScript(
        session: BrowserSession,
        script: string
    ): Promise<any> {
        try {
            const result = await session.page.evaluate(script);
            return result;
        } catch (error) {
            console.error(`❌ Failed to execute script:`, error);
            throw error;
        }
    }

    /**
     * Wait for selector with logging
     */
    static async waitForSelector(
        session: BrowserSession,
        selector: string,
        timeout: number = 10000
    ): Promise<boolean> {
        try {
            await session.page.waitForSelector(selector, { timeout });
            console.log(`✓ Selector found: ${selector}`);
            return true;
        } catch (error) {
            console.warn(`⚠️ Selector timeout: ${selector}`);
            return false;
        }
    }

    /**
     * Helper: Delay execution
     */
    private static delay(ms: number): Promise<void> {
        return new Promise((resolve) => setTimeout(resolve, ms));
    }
}

export default BrowserManager;
