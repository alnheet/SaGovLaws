import * as dotenv from 'dotenv';
import express, { Request, Response } from 'express';
import { initializeFirebase } from './config';
import archiveRouter from './routes/archive';
import { runScraper, scrapeSingleSource } from './scraper';

dotenv.config();

// Initialize Firebase
initializeFirebase();

const app = express();
app.use(express.json());

// استخدام موجهات الأرشيفة
app.use('/api/archive', archiveRouter);

const PORT = process.env.PORT || 8080;

/**
 * Health check endpoint
 */
app.get('/health', (_req: Request, res: Response) => {
    res.json({ status: 'ok', timestamp: new Date().toISOString() });
});

/**
 * Run full scrape for all sources
 */
app.post('/scrape/full', async (_req: Request, res: Response) => {
    try {
        console.log('[API] Starting full scrape...');
        const results = await runScraper('full');
        res.json({
            success: true,
            mode: 'full',
            results,
        });
    } catch (error) {
        console.error('[API] Full scrape error:', error);
        res.status(500).json({
            success: false,
            error: error instanceof Error ? error.message : String(error),
        });
    }
});

/**
 * Run incremental scrape for all sources
 */
app.post('/scrape/incremental', async (_req: Request, res: Response) => {
    try {
        console.log('[API] Starting incremental scrape...');
        const results = await runScraper('incremental');
        res.json({
            success: true,
            mode: 'incremental',
            results,
        });
    } catch (error) {
        console.error('[API] Incremental scrape error:', error);
        res.status(500).json({
            success: false,
            error: error instanceof Error ? error.message : String(error),
        });
    }
});

/**
 * Scrape a single source
 */
app.post('/scrape/source/:sourceKey', async (req: Request, res: Response) => {
    try {
        const { sourceKey } = req.params;
        const mode = req.query.mode === 'full' ? 'full' : 'incremental';

        console.log(`[API] Scraping source ${sourceKey} in ${mode} mode...`);
        const result = await scrapeSingleSource(sourceKey, mode);

        res.json({
            success: true,
            result,
        });
    } catch (error) {
        console.error('[API] Source scrape error:', error);
        res.status(500).json({
            success: false,
            error: error instanceof Error ? error.message : String(error),
        });
    }
});

/**
 * Start server
 */
app.listen(PORT, () => {
    console.log(`[Server] Rasid UQN Scraper running on port ${PORT}`);
});

export default app;
