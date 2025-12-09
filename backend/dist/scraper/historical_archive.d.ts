/**
 * Historical Data Archival Scraper
 * جلب وتخزين الأخبار القديمة من جميع المصادر
 *
 * يقوم بـ:
 * 1. استخراج الأخبار من أول ظهورها (صفحات قديمة)
 * 2. معالجة التاريخ الهجري والميلادي
 * 3. تجنب التكرار
 * 4. تخزين الكل في Firestore
 */
import { Firestore } from 'firebase-admin/firestore';
export interface HistoricalArticle {
    id: string;
    article_number: string;
    title: string;
    description: string;
    url: string;
    pdf_url?: string;
    published_date: Date;
    published_date_hijri?: string;
    source_key: string;
    source_name: string;
    category: string;
    is_archive: boolean;
    crawled_at: Date;
    is_valid: boolean;
}
export declare class HistoricalArchiveScraper {
    private firestore;
    constructor(firestore: Firestore);
    /**
     * جلب الأخبار القديمة من مصدر واحد
     * يبدأ من أقدم صفحة وينتقل للأحدث
     */
    archiveSource(sourceKey: string, sourceName: string, baseUrl: string, category: string, maxPages?: number): Promise<{
        total: number;
        newArticles: number;
        errors: string[];
    }>;
    /**
     * استخراج المقالات من صفحة واحدة
     */
    private scrapePageArchive;
    /**
     * استخراج بيانات المقالة من عنصر DOM
     */
    private parseArticleElement; /**
     * استخراج رقم المقالة الفريد
     */
    private extractArticleNumber;
    /**
     * معالجة التواريخ (هجري وميلادي)
     */
    private parseDate;
    /**
     * تحويل تاريخ هجري إلى ميلادي (تقريبي)
     */
    private hijriToGregorian;
    /**
     * معالجة الروابط النسبية
     */
    private resolveUrl;
    /**
     * التحقق من صحة المقالة
     */
    private isValidArticle;
    /**
     * الحصول على معرفات المقالات الموجودة
     */
    private getExistingArticleIds;
    /**
     * حفظ المقالة في Firestore
     */
    private saveArticle;
    /**
     * تأخير التنفيذ
     */
    private delay;
    /**
     * جلب الأرشيف الكامل لجميع المصادر
     */
    archiveAllSources(sourceConfigs: Array<{
        id: string;
        name_ar: string;
        url: string;
    }>): Promise<{
        [key: string]: {
            total: number;
            newArticles: number;
            errors: string[];
        };
    }>;
}
export default HistoricalArchiveScraper;
//# sourceMappingURL=historical_archive.d.ts.map