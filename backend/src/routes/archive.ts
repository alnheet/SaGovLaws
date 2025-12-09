/**
 * Historical Archive API Endpoints
 * نقاط نهاية لجلب وتخزين الأخبار القديمة
 * 
 * يوفر:
 * - POST /api/archive/full - جلب الأرشيف الكامل
 * - POST /api/archive/source/:sourceKey - جلب أرشيف مصدر واحد
 * - GET /api/archive/status - حالة الأرشفة
 */

import { Request, Response, Router } from 'express';
import { getFirestore } from 'firebase-admin/firestore';
import HistoricalArchiveScraper from '../scraper/historical_archive';
import { SOURCES_CONFIG } from '../seeds/sources.seed';

const router = Router();
const firestore = getFirestore();
const archiveScraper = new HistoricalArchiveScraper(firestore);

// متتبع حالة الأرشفة
const archiveStatus: {
    [key: string]: {
        status: 'pending' | 'running' | 'completed' | 'error';
        startTime?: Date;
        endTime?: Date;
        progress?: { current: number; total: number };
        results?: any;
        error?: string;
    };
} = {};

/**
 * POST /api/archive/full
 * جلب الأرشيف الكامل لجميع المصادر
 */
router.post('/full', async (req: Request, res: Response) => {
    try {
        const archiveId = `full_${Date.now()}`;
        archiveStatus[archiveId] = {
            status: 'running',
            startTime: new Date(),
            progress: { current: 0, total: SOURCES_CONFIG.length },
        };

        console.log(`📚 بدء أرشفة شاملة (${archiveId})...`);
        console.log(`📊 عدد المصادر: ${SOURCES_CONFIG.length}`);

        // جلب جميع المصادر
        const results = await archiveScraper.archiveAllSources(SOURCES_CONFIG);

        // تحديث الحالة
        archiveStatus[archiveId] = {
            status: 'completed',
            startTime: archiveStatus[archiveId].startTime,
            endTime: new Date(),
            results,
        };

        // حساب الإحصائيات
        const stats = {
            totalSources: SOURCES_CONFIG.length,
            completedSources: Object.keys(results).length,
            totalArticles: Object.values(results).reduce((sum, r: any) => sum + r.total, 0),
            newArticles: Object.values(results).reduce((sum, r: any) => sum + r.newArticles, 0),
            errors: Object.values(results).reduce((sum, r: any) => sum + r.errors.length, 0),
        };

        console.log('✅ انتهت الأرشفة الشاملة!');
        console.log(`📊 الإحصائيات:`, stats);

        res.json({
            success: true,
            archiveId,
            stats,
            results,
        });
    } catch (error) {
        const message = error instanceof Error ? error.message : String(error);
        console.error('❌ خطأ في الأرشفة الشاملة:', error);

        archiveStatus[`full_${Date.now()}`] = {
            status: 'error',
            error: message,
        };

        res.status(500).json({
            success: false,
            error: message,
        });
    }
});

/**
 * POST /api/archive/source/:sourceKey
 * جلب أرشيف مصدر واحد
 */
router.post('/source/:sourceKey', async (req: Request, res: Response) => {
    try {
        const { sourceKey } = req.params;
        const maxPages = parseInt(req.body.maxPages || '100');

        // البحث عن المصدر
        const source = SOURCES_CONFIG.find((s) => s.id === sourceKey);
        if (!source) {
            return res.status(404).json({
                success: false,
                error: `المصدر ${sourceKey} غير موجود`,
            });
        }

        const archiveId = `source_${sourceKey}_${Date.now()}`;
        archiveStatus[archiveId] = {
            status: 'running',
            startTime: new Date(),
        };

        console.log(`📚 بدء أرشفة ${source.name_ar} (${maxPages} صفحة)...`);

        // جلب أرشيف المصدر
        const result = await archiveScraper.archiveSource(
            source.id,
            source.name_ar,
            source.url,
            source.name_ar,
            maxPages
        );

        // تحديث الحالة
        archiveStatus[archiveId] = {
            status: 'completed',
            startTime: archiveStatus[archiveId].startTime,
            endTime: new Date(),
            results: result,
        };

        console.log(`✅ انتهت أرشفة ${source.name_ar}`);

        res.json({
            success: true,
            archiveId,
            source: {
                id: source.id,
                name_ar: source.name_ar,
            },
            result,
        });
    } catch (error) {
        const message = error instanceof Error ? error.message : String(error);
        console.error('❌ خطأ في أرشفة المصدر:', error);

        res.status(500).json({
            success: false,
            error: message,
        });
    }
});

/**
 * GET /api/archive/status/:archiveId
 * الاستعلام عن حالة الأرشفة
 */
router.get('/status/:archiveId', async (req: Request, res: Response) => {
    try {
        const { archiveId } = req.params;
        const status = archiveStatus[archiveId];

        if (!status) {
            return res.status(404).json({
                success: false,
                error: `معرف الأرشفة ${archiveId} غير موجود`,
            });
        }

        res.json({
            success: true,
            archiveId,
            status,
        });
    } catch (error) {
        const message = error instanceof Error ? error.message : String(error);
        res.status(500).json({
            success: false,
            error: message,
        });
    }
});

/**
 * GET /api/archive/stats
 * إحصائيات عامة للأرشيفة
 */
router.get('/stats', async (req: Request, res: Response) => {
    try {
        // عد المقالات في Firestore
        const articlesSnapshot = await firestore.collection('articles').count().get();
        const archiveSnapshot = await firestore
            .collection('articles')
            .where('is_archive', '==', true)
            .count()
            .get();

        const totalCount = articlesSnapshot.data().count;
        const archiveCount = archiveSnapshot.data().count;

        const stats = {
            totalArticles: totalCount,
            archiveArticles: archiveCount,
            recentArticles: totalCount - archiveCount,
            archiveJobs: Object.keys(archiveStatus).length,
            runningJobs: Object.values(archiveStatus).filter((s) => s.status === 'running').length,
            completedJobs: Object.values(archiveStatus).filter((s) => s.status === 'completed').length,
        };

        res.json({
            success: true,
            stats,
        });
    } catch (error) {
        const message = error instanceof Error ? error.message : String(error);
        console.error('❌ خطأ في الحصول على الإحصائيات:', error);

        res.status(500).json({
            success: false,
            error: message,
        });
    }
});

export default router;
