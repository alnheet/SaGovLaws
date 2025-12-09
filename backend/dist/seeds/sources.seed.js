"use strict";
/**
 * Firestore Sources Seed Data
 * Contains configuration for all 7 official government document categories
 */
Object.defineProperty(exports, "__esModule", { value: true });
exports.SOURCES_CONFIG = void 0;
exports.seedSources = seedSources;
exports.verifySources = verifySources;
exports.SOURCES_CONFIG = [
    {
        id: "cabinet_decisions",
        name_ar: "قرارات مجلس الوزراء",
        name_en: "Cabinet Decisions",
        cat_id: 9,
        url: "https://uqn.gov.sa/category?cat=9",
        enabled: true,
        icon: "gavel",
        color: "#1976D2",
        order: 1,
        last_sync_at: null,
        article_count: 0,
        last_error: null
    },
    {
        id: "royal_orders",
        name_ar: "أوامر ملكية",
        name_en: "Royal Orders",
        cat_id: 7,
        url: "https://uqn.gov.sa/category?cat=7",
        enabled: true,
        icon: "crown",
        color: "#D32F2F",
        order: 2,
        last_sync_at: null,
        article_count: 0,
        last_error: null
    },
    {
        id: "royal_decrees",
        name_ar: "مراسيم ملكية",
        name_en: "Royal Decrees",
        cat_id: 8,
        url: "https://uqn.gov.sa/category?cat=8",
        enabled: true,
        icon: "description",
        color: "#F57C00",
        order: 3,
        last_sync_at: null,
        article_count: 0,
        last_error: null
    },
    {
        id: "decisions_regulations",
        name_ar: "قرارات وأنظمة",
        name_en: "Decisions & Regulations",
        cat_id: 6,
        url: "https://uqn.gov.sa/category?cat=6",
        enabled: true,
        icon: "rule",
        color: "#388E3C",
        order: 4,
        last_sync_at: null,
        article_count: 0,
        last_error: null
    },
    {
        id: "laws_regulations",
        name_ar: "لوائح وأنظمة",
        name_en: "Laws & Regulations",
        cat_id: 11,
        url: "https://uqn.gov.sa/category?cat=11",
        enabled: true,
        icon: "policy",
        color: "#7B1FA2",
        order: 5,
        last_sync_at: null,
        article_count: 0,
        last_error: null
    },
    {
        id: "ministerial_decisions",
        name_ar: "قرارات وزارية",
        name_en: "Ministerial Decisions",
        cat_id: 10,
        url: "https://uqn.gov.sa/category?cat=10",
        enabled: true,
        icon: "business",
        color: "#0097A7",
        order: 6,
        last_sync_at: null,
        article_count: 0,
        last_error: null
    },
    {
        id: "authorities",
        name_ar: "هيئات",
        name_en: "Authorities",
        cat_id: 12,
        url: "https://uqn.gov.sa/category?cat=12",
        enabled: true,
        icon: "verified_user",
        color: "#455A64",
        order: 7,
        last_sync_at: null,
        article_count: 0,
        last_error: null
    }
];
/**
 * Seed function to populate Firestore with source configurations
 * Usage: Run this script once to initialize sources in Firestore
 *
 * firestore.collection('sources').doc(source.id).set(source)
 */
async function seedSources(firestore) {
    console.log("🌱 Starting sources seed...");
    let successCount = 0;
    let errorCount = 0;
    for (const source of exports.SOURCES_CONFIG) {
        try {
            await firestore.collection("sources").doc(source.id).set({
                ...source,
                last_sync_at: null,
                article_count: 0,
                last_error: null,
                created_at: new Date(),
                updated_at: new Date()
            });
            console.log(`✅ Seeded: ${source.name_ar}`);
            successCount++;
        }
        catch (error) {
            console.error(`❌ Failed to seed ${source.name_ar}:`, error);
            errorCount++;
        }
    }
    console.log(`\n✅ Seed completed: ${successCount} succeeded, ${errorCount} failed`);
}
/**
 * Verification function to check if sources are properly seeded
 * Usage: Run this to verify all sources exist in Firestore
 */
async function verifySources(firestore) {
    console.log("🔍 Verifying sources in Firestore...\n");
    const snapshot = await firestore.collection("sources").get();
    const sources = snapshot.docs.map((doc) => ({
        id: doc.id,
        ...doc.data()
    }));
    if (sources.length === 0) {
        console.error("❌ No sources found in Firestore!");
        return;
    }
    console.log(`📊 Found ${sources.length} sources:\n`);
    sources.forEach((source, index) => {
        console.log(`${index + 1}. ${source.name_ar} (${source.name_en})`);
        console.log(`   ID: ${source.id}`);
        console.log(`   Category: ${source.cat_id}`);
        console.log(`   URL: ${source.url}`);
        console.log(`   Status: ${source.enabled ? "✅ Enabled" : "❌ Disabled"}`);
        console.log(`   Articles: ${source.article_count}\n`);
    });
    console.log(`✅ All ${sources.length} sources verified!`);
}
//# sourceMappingURL=sources.seed.js.map