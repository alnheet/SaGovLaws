import { FieldValue, Firestore, Timestamp } from 'firebase-admin/firestore';
import { COLLECTIONS, getDb } from '../config';
import { ArticleDoc, ParsedArticle, SourceDoc } from '../interfaces';
import { generateExcerpt, sanitizeHtml } from './parser';

/**
 * Firestore operations for scraper
 */
export class ArticleStorage {
    private db: Firestore;

    constructor() {
        this.db = getDb();
    }

    /**
     * Get all enabled sources
     */
    async getEnabledSources(): Promise<SourceDoc[]> {
        const snapshot = await this.db
            .collection(COLLECTIONS.SOURCES)
            .where('enabled', '==', true)
            .orderBy('order')
            .get();

        return snapshot.docs.map(doc => doc.data() as SourceDoc);
    }

    /**
     * Get existing article IDs for a source
     */
    async getExistingArticleIds(sourceKey: string): Promise<Set<string>> {
        const snapshot = await this.db
            .collection(COLLECTIONS.ARTICLES)
            .where('source_key', '==', sourceKey)
            .select('id')
            .get();

        return new Set(snapshot.docs.map(doc => doc.id));
    }

    /**
     * Upsert articles to Firestore
     * @returns Number of new and updated articles
     */
    async upsertArticles(
        articles: ParsedArticle[],
        source: SourceDoc
    ): Promise<{ newCount: number; updatedCount: number }> {
        let newCount = 0;
        let updatedCount = 0;

        const batch = this.db.batch();
        const now = Timestamp.now();

        for (const article of articles) {
            const articleId = `${source.id}_${article.original_id}`;
            const docRef = this.db.collection(COLLECTIONS.ARTICLES).doc(articleId);

            const existingDoc = await docRef.get();

            const articleData: Partial<ArticleDoc> = {
                id: articleId,
                original_id: article.original_id,
                source_key: source.id,
                source_name_ar: source.name_ar,
                cat_id: source.cat_id,
                title: article.title,
                url: article.url,
                publish_date_raw: article.publish_date_raw,
                publish_date_gregorian: article.publish_date_gregorian || null,
                pdf_url: article.pdf_url || null,
                has_pdf: !!article.pdf_url,
                updated_at: now,
            };

            if (article.content_html) {
                articleData.content_html = sanitizeHtml(article.content_html);
                articleData.content_plain = article.content_html.replace(/<[^>]*>/g, ' ').replace(/\s+/g, ' ').trim();
                articleData.excerpt = generateExcerpt(articleData.content_plain);
            }

            if (existingDoc.exists) {
                batch.update(docRef, articleData);
                updatedCount++;
            } else {
                articleData.scraped_at = now;
                batch.set(docRef, articleData);
                newCount++;
            }
        }

        // Commit in batches of 500 (Firestore limit)
        await batch.commit();

        return { newCount, updatedCount };
    }

    /**
     * Update source sync metadata
     */
    async updateSourceMeta(
        sourceKey: string,
        data: {
            article_count?: number;
            last_error?: string | null;
        }
    ): Promise<void> {
        const docRef = this.db.collection(COLLECTIONS.SOURCES).doc(sourceKey);

        await docRef.update({
            ...data,
            last_sync_at: FieldValue.serverTimestamp(),
        });
    }

    /**
     * Get article count for a source
     */
    async getArticleCount(sourceKey: string): Promise<number> {
        const snapshot = await this.db
            .collection(COLLECTIONS.ARTICLES)
            .where('source_key', '==', sourceKey)
            .count()
            .get();

        return snapshot.data().count;
    }

    /**
     * Initialize sources collection with default data
     */
    async initializeSources(sources: Omit<SourceDoc, 'last_sync_at' | 'article_count' | 'last_error'>[]): Promise<void> {
        const batch = this.db.batch();

        for (const source of sources) {
            const docRef = this.db.collection(COLLECTIONS.SOURCES).doc(source.id);
            const existing = await docRef.get();

            if (!existing.exists) {
                batch.set(docRef, {
                    ...source,
                    last_sync_at: null,
                    article_count: 0,
                    last_error: null,
                });
            }
        }

        await batch.commit();
    }
}
