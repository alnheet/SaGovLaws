import { ScrapeResult } from '../interfaces';
/**
 * Main scraper orchestrator
 * Coordinates scraping of all enabled sources
 */
export declare function runScraper(mode?: 'full' | 'incremental'): Promise<ScrapeResult[]>;
/**
 * Scrape a single source
 */
export declare function scrapeSingleSource(sourceKey: string, mode?: 'full' | 'incremental'): Promise<ScrapeResult>;
export * from './browser';
export * from './parser';
export * from './storage';
//# sourceMappingURL=index.d.ts.map