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
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const dotenv = __importStar(require("dotenv"));
const express_1 = __importDefault(require("express"));
const config_1 = require("./config");
const scraper_1 = require("./scraper");
dotenv.config();
// Initialize Firebase
(0, config_1.initializeFirebase)();
const app = (0, express_1.default)();
app.use(express_1.default.json());
const PORT = process.env.PORT || 8080;
/**
 * Health check endpoint
 */
app.get('/health', (_req, res) => {
    res.json({ status: 'ok', timestamp: new Date().toISOString() });
});
/**
 * Run full scrape for all sources
 */
app.post('/scrape/full', async (_req, res) => {
    try {
        console.log('[API] Starting full scrape...');
        const results = await (0, scraper_1.runScraper)('full');
        res.json({
            success: true,
            mode: 'full',
            results,
        });
    }
    catch (error) {
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
app.post('/scrape/incremental', async (_req, res) => {
    try {
        console.log('[API] Starting incremental scrape...');
        const results = await (0, scraper_1.runScraper)('incremental');
        res.json({
            success: true,
            mode: 'incremental',
            results,
        });
    }
    catch (error) {
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
app.post('/scrape/source/:sourceKey', async (req, res) => {
    try {
        const { sourceKey } = req.params;
        const mode = req.query.mode === 'full' ? 'full' : 'incremental';
        console.log(`[API] Scraping source ${sourceKey} in ${mode} mode...`);
        const result = await (0, scraper_1.scrapeSingleSource)(sourceKey, mode);
        res.json({
            success: true,
            result,
        });
    }
    catch (error) {
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
exports.default = app;
//# sourceMappingURL=index.js.map