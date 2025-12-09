"use strict";
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
Object.defineProperty(exports, "__esModule", { value: true });
exports.HistoricalArchiveScraper = void 0;
const cheerio = __importStar(require("cheerio"));
class HistoricalArchiveScraper {
    constructor(firestore) {
        this.firestore = firestore;
    }
    /**
     * جلب الأخبار القديمة من مصدر واحد
     * يبدأ من أقدم صفحة وينتقل للأحدث
     */
    async archiveSource(sourceKey, sourceName, baseUrl, category, maxPages = 100) {
        console.log(`📚 بدء أرشفة ${sourceName} من ${maxPages} صفحة...`);
        const errors = [];
        let totalArticles = 0;
        let newArticles = 0;
        // الحصول على أعداد المقالات الموجودة
        const existingIds = await this.getExistingArticleIds(sourceKey);
        console.log(`📊 وجدنا ${existingIds.size} مقالة موجودة بالفعل`);
        // جلب من كل صفحة
        for (let pageNum = 1; pageNum <= maxPages; pageNum++) {
            try {
                const pageUrl = `${baseUrl}${baseUrl.includes('?') ? '&' : '?'}paged=${pageNum}`;
                console.log(`📄 جاري جلب الصفحة ${pageNum}...`);
                const articles = await this.scrapePageArchive(pageUrl, sourceKey, sourceName, category);
                if (articles.length === 0) {
                    console.log(`✓ انتهينا - الصفحة ${pageNum} فارغة`);
                    break;
                }
                totalArticles += articles.length;
                // حفظ المقالات الجديدة فقط
                for (const article of articles) {
                    if (!existingIds.has(article.id)) {
                        await this.saveArticle(article);
                        newArticles++;
                    }
                }
                console.log(`✓ الصفحة ${pageNum}: ${articles.length} مقالة (${newArticles} جديدة حتى الآن)`);
                // تأخير لعدم إجهاد الخادم
                await this.delay(500);
            }
            catch (error) {
                const errorMsg = `خطأ في الصفحة ${pageNum}: ${error}`;
                console.error(errorMsg);
                errors.push(errorMsg);
                // استمرر للصفحة التالية
            }
        }
        console.log(`✅ انتهت الأرشفة: ${totalArticles} مقالة (${newArticles} جديدة)`);
        return {
            total: totalArticles,
            newArticles,
            errors,
        };
    }
    /**
     * استخراج المقالات من صفحة واحدة
     */
    async scrapePageArchive(pageUrl, sourceKey, sourceName, category) {
        const articles = [];
        try {
            // جلب الصفحة
            const response = await fetch(pageUrl, {
                headers: {
                    'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
                },
            });
            if (!response.ok) {
                throw new Error(`HTTP ${response.status}`);
            }
            const html = await response.text();
            const $ = cheerio.load(html);
            // استخراج المقالات - استخدم selectors متعددة
            const selectors = [
                '.item-body', // UQN selector الشائع
                '.post-item',
                '.article-item',
                '.news-item',
                '[data-article]',
            ];
            let itemCount = 0;
            for (const selector of selectors) {
                const items = $(selector);
                if (items.length > 0) {
                    itemCount = items.length;
                    items.each((_, element) => {
                        const article = this.parseArticleElement($(element), sourceKey, sourceName, category);
                        if (article && this.isValidArticle(article)) {
                            articles.push(article);
                        }
                    });
                    break; // توقف عند أول selector ينجح
                }
            }
            console.log(`  - استخرجنا ${itemCount} عنصر`);
        }
        catch (error) {
            console.error(`خطأ في جلب ${pageUrl}:`, error);
        }
        return articles;
    }
    /**
     * استخراج بيانات المقالة من عنصر DOM
     */
    parseArticleElement($element, sourceKey, sourceName, category) {
        try {
            // استخراج الرقم المرجعي
            const titleLink = $element.find('a').first();
            const url = titleLink.attr('href') || '';
            // استخراج الرقم من URL أو العنصر
            const articleNumber = this.extractArticleNumber(url, $element);
            if (!articleNumber) {
                return null;
            }
            // استخراج العنوان
            const title = titleLink.text().trim() || $element.find('h2, h3').text().trim();
            if (!title || title.length < 5) {
                return null;
            }
            // استخراج الوصف
            const description = $element.find('.excerpt, .summary, p').text().trim().substring(0, 500);
            // استخراج التاريخ
            const dateText = $element.find('.date, .published-date, .item-date').text().trim();
            const { gregorian, hijri } = this.parseDate(dateText);
            // استخراج PDF
            const pdfUrl = $element.find('a[href*=".pdf"], .pdf-link').attr('href');
            const article = {
                id: `${sourceKey}_${articleNumber}`,
                article_number: articleNumber,
                title,
                description,
                url: this.resolveUrl(url),
                pdf_url: pdfUrl ? this.resolveUrl(pdfUrl) : undefined,
                published_date: gregorian || new Date(),
                published_date_hijri: hijri || undefined,
                source_key: sourceKey,
                source_name: sourceName,
                category,
                is_archive: true,
                crawled_at: new Date(),
                is_valid: true,
            };
            return article;
        }
        catch (error) {
            console.warn('خطأ في parsing:', error);
            return null;
        }
    } /**
     * استخراج رقم المقالة الفريد
     */
    extractArticleNumber(url, $element) {
        // محاولة استخراج من URL
        let match = url.match(/[?&]p=(\d+)/);
        if (match)
            return match[1];
        match = url.match(/\/(\d+)\/?$/);
        if (match)
            return match[1];
        match = url.match(/article-(\d+)/i);
        if (match)
            return match[1];
        // محاولة استخراج من العنصر
        const dataId = $element.attr('data-id') || $element.attr('data-article-id');
        if (dataId)
            return dataId;
        // إنشاء رقم من العنوان كملاذ أخير
        const title = $element.find('a').first().text();
        if (title) {
            return Buffer.from(title).toString('base64').substring(0, 20);
        }
        return null;
    }
    /**
     * معالجة التواريخ (هجري وميلادي)
     */
    parseDate(dateStr) {
        if (!dateStr) {
            return { gregorian: null, hijri: null };
        }
        let gregorian = null;
        let hijri = null;
        // محاولة التاريخ الهجري: "25 ذو الحجة 1445"
        const hijriMatch = dateStr.match(/(\d{1,2})\s+([\u0600-\u06FF]+)\s+(\d{4})/);
        if (hijriMatch) {
            hijri = dateStr;
            // تحويل هجري إلى ميلادي (تقريبي)
            gregorian = this.hijriToGregorian(parseInt(hijriMatch[1]), hijriMatch[2], parseInt(hijriMatch[3]));
        }
        // محاولة التاريخ الميلادي
        if (!gregorian) {
            // صيغ متعددة: DD/MM/YYYY, DD-MM-YYYY, YYYY-MM-DD
            const datePatterns = [
                /(\d{4})-(\d{1,2})-(\d{1,2})/,
                /(\d{1,2})\/(\d{1,2})\/(\d{4})/,
                /(\d{1,2})-(\d{1,2})-(\d{4})/,
            ];
            for (const pattern of datePatterns) {
                const match = dateStr.match(pattern);
                if (match) {
                    try {
                        if (pattern === datePatterns[0]) {
                            // YYYY-MM-DD
                            gregorian = new Date(parseInt(match[1]), parseInt(match[2]) - 1, parseInt(match[3]));
                        }
                        else {
                            // DD/MM/YYYY أو DD-MM-YYYY
                            gregorian = new Date(parseInt(match[3]), parseInt(match[2]) - 1, parseInt(match[1]));
                        }
                        break;
                    }
                    catch (e) {
                        // تابع للنمط التالي
                    }
                }
            }
        }
        return {
            gregorian: gregorian && !isNaN(gregorian.getTime()) ? gregorian : null,
            hijri,
        };
    }
    /**
     * تحويل تاريخ هجري إلى ميلادي (تقريبي)
     */
    hijriToGregorian(day, monthName, year) {
        const months = {
            محرم: 1,
            صفر: 2,
            ربيع: 3,
            'ربيع الأول': 3,
            'ربيع الثاني': 4,
            جمادى: 5,
            'جمادى الأولى': 5,
            'جمادى الثانية': 6,
            رجب: 7,
            شعبان: 8,
            رمضان: 9,
            شوال: 10,
            'ذو القعدة': 11,
            'ذو الحجة': 12,
        };
        const month = months[monthName];
        if (!month)
            return null;
        // تقريب: كل 33 سنة هجري ≈ 32 سنة ميلادي
        const gregorianYear = Math.floor(year * 0.970224 + 622 - 1.33);
        return new Date(gregorianYear, month - 1, day);
    }
    /**
     * معالجة الروابط النسبية
     */
    resolveUrl(url) {
        if (url.startsWith('http'))
            return url;
        if (url.startsWith('/'))
            return `https://uqn.gov.sa${url}`;
        return `https://uqn.gov.sa/${url}`;
    }
    /**
     * التحقق من صحة المقالة
     */
    isValidArticle(article) {
        return (article.id?.length > 0 &&
            article.title?.length > 5 &&
            article.url?.length > 0);
    }
    /**
     * الحصول على معرفات المقالات الموجودة
     */
    async getExistingArticleIds(sourceKey) {
        try {
            const snapshot = await this.firestore
                .collection('articles')
                .where('source_key', '==', sourceKey)
                .where('is_archive', '==', true)
                .select('id')
                .get();
            return new Set(snapshot.docs.map((doc) => doc.id));
        }
        catch (error) {
            console.warn('خطأ في جلب المقالات الموجودة:', error);
            return new Set();
        }
    }
    /**
     * حفظ المقالة في Firestore
     */
    async saveArticle(article) {
        try {
            await this.firestore.collection('articles').doc(article.id).set({
                ...article,
                crawled_at: new Date(),
                updated_at: new Date(),
            }, { merge: true });
        }
        catch (error) {
            console.error(`خطأ في حفظ ${article.id}:`, error);
        }
    }
    /**
     * تأخير التنفيذ
     */
    delay(ms) {
        return new Promise((resolve) => setTimeout(resolve, ms));
    }
    /**
     * جلب الأرشيف الكامل لجميع المصادر
     */
    async archiveAllSources(sourceConfigs) {
        const results = {};
        for (const source of sourceConfigs) {
            try {
                results[source.id] = await this.archiveSource(source.id, source.name_ar, source.url, source.name_ar, 100 // ابدأ بـ 100 صفحة
                );
            }
            catch (error) {
                console.error(`خطأ في أرشفة ${source.id}:`, error);
                results[source.id] = {
                    total: 0,
                    newArticles: 0,
                    errors: [String(error)],
                };
            }
        }
        return results;
    }
}
exports.HistoricalArchiveScraper = HistoricalArchiveScraper;
exports.default = HistoricalArchiveScraper;
//# sourceMappingURL=historical_archive.js.map