/**
 * Firestore Sources Seed Data
 * Contains configuration for all 7 official government document categories
 */
export interface SourceConfig {
    id: string;
    name_ar: string;
    name_en: string;
    cat_id: number;
    url: string;
    enabled: boolean;
    icon: string;
    color: string;
    order: number;
    last_sync_at: null | Date;
    article_count: number;
    last_error: null | string;
}
export declare const SOURCES_CONFIG: SourceConfig[];
/**
 * Seed function to populate Firestore with source configurations
 * Usage: Run this script once to initialize sources in Firestore
 *
 * firestore.collection('sources').doc(source.id).set(source)
 */
export declare function seedSources(firestore: any): Promise<void>;
/**
 * Verification function to check if sources are properly seeded
 * Usage: Run this to verify all sources exist in Firestore
 */
export declare function verifySources(firestore: any): Promise<void>;
//# sourceMappingURL=sources.seed.d.ts.map