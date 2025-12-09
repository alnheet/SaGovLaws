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

import * as cheerio from 'cheerio';
import { Firestore } from 'firebase-admin/firestore';

export interface HistoricalArticle {
    id: string; // يتم توليده من article_number + source
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
    is_archive: boolean; // true للأخبار القديمة
    crawled_at: Date;
    is_valid: boolean;
}

export class HistoricalArchiveScraper {
    constructor(private firestore: Firestore) { }

    /**
     * جلب الأخبار القديمة من مصدر واحد
     * يبدأ من أقدم صفحة وينتقل للأحدث
     */
    async archiveSource(
        sourceKey: string,
        sourceName: string,
        baseUrl: string,
        category: string,
        maxPages: number = 100
    ): Promise<{ total: number; newArticles: number; errors: string[] }> {
        console.log(`📚 بدء أرشفة ${sourceName} من ${maxPages} صفحة...`);

        const errors: string[] = [];
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

                const articles = await this.scrapePageArchive(
                    pageUrl,
                    sourceKey,
                    sourceName,
                    category
                );

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

                console.log(
                    `✓ الصفحة ${pageNum}: ${articles.length} مقالة (${newArticles} جديدة حتى الآن)`
                );

                // تأخير لعدم إجهاد الخادم
                await this.delay(500);
            } catch (error) {
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
    private async scrapePageArchive(
        pageUrl: string,
        sourceKey: string,
        sourceName: string,
        category: string
    ): Promise<HistoricalArticle[]> {
        const articles: HistoricalArticle[] = [];

        try {
            // جلب الصفحة
            const response = await fetch(pageUrl, {
                headers: {
                    'User-Agent':
                        'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
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
                        const article = this.parseArticleElement(
                            $(element),
                            sourceKey,
                            sourceName,
                            category
                        );
                        if (article && this.isValidArticle(article)) {
                            articles.push(article);
                        }
                    });

                    break; // توقف عند أول selector ينجح
                }
            }

            console.log(`  - استخرجنا ${itemCount} عنصر`);
        } catch (error) {
            console.error(`خطأ في جلب ${pageUrl}:`, error);
        }

        return articles;
    }

    /**
     * استخراج بيانات المقالة من عنصر DOM
     */
    private parseArticleElement(
        $element: cheerio.Cheerio<any>,
        sourceKey: string,
        sourceName: string,
        category: string
    ): HistoricalArticle | null {
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

            const article: HistoricalArticle = {
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
        } catch (error) {
            console.warn('خطأ في parsing:', error);
            return null;
        }
    }    /**
     * استخراج رقم المقالة الفريد
     */
    private extractArticleNumber(url: string, $element: cheerio.Cheerio<any>): string | null {
        // محاولة استخراج من URL
        let match = url.match(/[?&]p=(\d+)/);
        if (match) return match[1];

        match = url.match(/\/(\d+)\/?$/);
        if (match) return match[1];

        match = url.match(/article-(\d+)/i);
        if (match) return match[1];

        // محاولة استخراج من العنصر
        const dataId = $element.attr('data-id') || $element.attr('data-article-id');
        if (dataId) return dataId;

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
    private parseDate(
        dateStr: string
    ): { gregorian: Date | null; hijri: string | null } {
        if (!dateStr) {
            return { gregorian: null, hijri: null };
        }

        let gregorian: Date | null = null;
        let hijri: string | null = null;

        // محاولة التاريخ الهجري: "25 ذو الحجة 1445"
        const hijriMatch = dateStr.match(/(\d{1,2})\s+([\u0600-\u06FF]+)\s+(\d{4})/);
        if (hijriMatch) {
            hijri = dateStr;
            // تحويل هجري إلى ميلادي (تقريبي)
            gregorian = this.hijriToGregorian(
                parseInt(hijriMatch[1]),
                hijriMatch[2],
                parseInt(hijriMatch[3])
            );
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
                        } else {
                            // DD/MM/YYYY أو DD-MM-YYYY
                            gregorian = new Date(parseInt(match[3]), parseInt(match[2]) - 1, parseInt(match[1]));
                        }
                        break;
                    } catch (e) {
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
    private hijriToGregorian(day: number, monthName: string, year: number): Date | null {
        const months: { [key: string]: number } = {
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
        if (!month) return null;

        // تقريب: كل 33 سنة هجري ≈ 32 سنة ميلادي
        const gregorianYear = Math.floor(year * 0.970224 + 622 - 1.33);
        return new Date(gregorianYear, month - 1, day);
    }

    /**
     * معالجة الروابط النسبية
     */
    private resolveUrl(url: string): string {
        if (url.startsWith('http')) return url;
        if (url.startsWith('/')) return `https://uqn.gov.sa${url}`;
        return `https://uqn.gov.sa/${url}`;
    }

    /**
     * التحقق من صحة المقالة
     */
    private isValidArticle(article: HistoricalArticle): boolean {
        return (
            article.id?.length > 0 &&
            article.title?.length > 5 &&
            article.url?.length > 0
        );
    }

    /**
     * الحصول على معرفات المقالات الموجودة
     */
    private async getExistingArticleIds(sourceKey: string): Promise<Set<string>> {
        try {
            const snapshot = await this.firestore
                .collection('articles')
                .where('source_key', '==', sourceKey)
                .where('is_archive', '==', true)
                .select('id')
                .get();

            return new Set(snapshot.docs.map((doc) => doc.id));
        } catch (error) {
            console.warn('خطأ في جلب المقالات الموجودة:', error);
            return new Set();
        }
    }

    /**
     * حفظ المقالة في Firestore
     */
    private async saveArticle(article: HistoricalArticle): Promise<void> {
        try {
            await this.firestore.collection('articles').doc(article.id).set(
                {
                    ...article,
                    crawled_at: new Date(),
                    updated_at: new Date(),
                },
                { merge: true }
            );
        } catch (error) {
            console.error(`خطأ في حفظ ${article.id}:`, error);
        }
    }

    /**
     * تأخير التنفيذ
     */
    private delay(ms: number): Promise<void> {
        return new Promise((resolve) => setTimeout(resolve, ms));
    }

    /**
     * جلب الأرشيف الكامل لجميع المصادر
     */
    async archiveAllSources(sourceConfigs: Array<{
        id: string;
        name_ar: string;
        url: string;
    }>): Promise<{ [key: string]: { total: number; newArticles: number; errors: string[] } }> {
        const results: { [key: string]: any } = {};

        for (const source of sourceConfigs) {
            try {
                results[source.id] = await this.archiveSource(
                    source.id,
                    source.name_ar,
                    source.url,
                    source.name_ar,
                    100 // ابدأ بـ 100 صفحة
                );
            } catch (error) {
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

export default HistoricalArchiveScraper;
