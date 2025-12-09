"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.ArticleStorage = void 0;
const firestore_1 = require("firebase-admin/firestore");
const config_1 = require("../config");
const parser_1 = require("./parser");
/**
 * Firestore operations for scraper
 */
class ArticleStorage {
    constructor() {
        this.db = (0, config_1.getDb)();
    }
    /**
     * Get all enabled sources
     */
    async getEnabledSources() {
        const snapshot = await this.db
            .collection(config_1.COLLECTIONS.SOURCES)
            .where('enabled', '==', true)
            .orderBy('order')
            .get();
        return snapshot.docs.map(doc => doc.data());
    }
    /**
     * Get existing article IDs for a source
     */
    async getExistingArticleIds(sourceKey) {
        const snapshot = await this.db
            .collection(config_1.COLLECTIONS.ARTICLES)
            .where('source_key', '==', sourceKey)
            .select('id')
            .get();
        return new Set(snapshot.docs.map(doc => doc.id));
    }
    /**
     * Upsert articles to Firestore
     * @returns Number of new and updated articles
     */
    async upsertArticles(articles, source) {
        let newCount = 0;
        let updatedCount = 0;
        const batch = this.db.batch();
        const now = firestore_1.Timestamp.now();
        for (const article of articles) {
            const articleId = `${source.id}_${article.original_id}`;
            const docRef = this.db.collection(config_1.COLLECTIONS.ARTICLES).doc(articleId);
            const existingDoc = await docRef.get();
            const articleData = {
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
                articleData.content_html = (0, parser_1.sanitizeHtml)(article.content_html);
                articleData.content_plain = article.content_html.replace(/<[^>]*>/g, ' ').replace(/\s+/g, ' ').trim();
                articleData.excerpt = (0, parser_1.generateExcerpt)(articleData.content_plain);
            }
            if (existingDoc.exists) {
                batch.update(docRef, articleData);
                updatedCount++;
            }
            else {
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
    async updateSourceMeta(sourceKey, data) {
        const docRef = this.db.collection(config_1.COLLECTIONS.SOURCES).doc(sourceKey);
        await docRef.update({
            ...data,
            last_sync_at: firestore_1.FieldValue.serverTimestamp(),
        });
    }
    /**
     * Get article count for a source
     */
    async getArticleCount(sourceKey) {
        const snapshot = await this.db
            .collection(config_1.COLLECTIONS.ARTICLES)
            .where('source_key', '==', sourceKey)
            .count()
            .get();
        return snapshot.data().count;
    }
    /**
     * Initialize sources collection with default data
     */
    async initializeSources(sources) {
        const batch = this.db.batch();
        for (const source of sources) {
            const docRef = this.db.collection(config_1.COLLECTIONS.SOURCES).doc(source.id);
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
exports.ArticleStorage = ArticleStorage;
//# sourceMappingURL=storage.js.map