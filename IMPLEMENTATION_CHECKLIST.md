# عناصر البرمجة المطلوبة لاكتمال الخطة

## 1. تكوين المصادر الـ 7 الرسمية ⚠️

### ملف Firestore seed data مطلوب:
```typescript
// backend/src/seeds/sources.seed.ts

export const SOURCES_CONFIG = [
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
    icon: "groups",
    color: "#E64A19",
    order: 7,
    last_sync_at: null,
    article_count: 0,
    last_error: null
  }
];
```

### الأوامر المطلوبة:
```bash
# تحميل البيانات إلى Firestore
npm run seed:sources
```

---

## 2. تحسين Cloud Run Scraper 🔧

### ملفات يجب تحسينها:

#### A. `backend/src/scraper/parser.ts` - محسّن استخراج المقالات
```typescript
import * as cheerio from 'cheerio';
import axios from 'axios';

export interface ParsedArticle {
  original_id: string;
  title: string;
  excerpt?: string;
  publish_date_raw: string;
  publish_date_gregorian?: string;
  url: string;
  pdf_url?: string;
  has_pdf: boolean;
}

export async function parseArticlesFromHTML(
  html: string,
  sourceKey: string,
  baseUrl: string
): Promise<ParsedArticle[]> {
  const $ = cheerio.load(html);
  const articles: ParsedArticle[] = [];

  // استخراج من DOM - يتطلب فحص موقع UQN الفعلي
  const articleElements = $('.article-item, .post-item, [data-article-id]');

  articleElements.each((_, element) => {
    try {
      const $el = $(element);
      
      // استخراج المعرف الأصلي
      const href = $el.find('a').attr('href') || '';
      const originalId = extractIdFromUrl(href);
      
      if (!originalId) return; // تخطي إذا لم نتمكن من استخراج المعرف
      
      const article: ParsedArticle = {
        original_id: originalId,
        title: $el.find('.post-title, .title, h3').text().trim(),
        excerpt: $el.find('.excerpt, .summary, p').text().trim().slice(0, 200),
        publish_date_raw: $el.find('.date, .publish-date').text().trim(),
        url: resolveUrl(href, baseUrl),
        pdf_url: extractPdfUrl($el),
        has_pdf: !!extractPdfUrl($el),
      };
      
      articles.push(article);
    } catch (error) {
      console.error('Error parsing article element:', error);
    }
  });

  return articles;
}

function extractIdFromUrl(url: string): string | null {
  // استخراج من: ?p=28661 أو /details?p=28661
  const match = url.match(/[?&]p=(\d+)/);
  return match ? match[1] : null;
}

function resolveUrl(url: string, baseUrl: string): string {
  if (url.startsWith('http')) return url;
  if (url.startsWith('/')) return `${new URL(baseUrl).origin}${url}`;
  return `${baseUrl}/${url}`;
}

function extractPdfUrl(element: Cheerio<Element>): string | null {
  // البحث عن رابط PDF
  const pdfLink = element.find('a[href$=".pdf"], .pdf-link');
  if (pdfLink.length) {
    return pdfLink.attr('href') || null;
  }
  return null;
}
```

#### B. `backend/src/scraper/browser.ts` - تحسين Puppeteer
```typescript
import puppeteer from 'puppeteer';
import { delay } from '../utils/helpers';

export interface BrowserSession {
  browser: puppeteer.Browser;
  page: puppeteer.Page;
  close: () => Promise<void>;
}

export async function createBrowserSession(): Promise<BrowserSession> {
  const browser = await puppeteer.launch({
    args: [
      '--no-sandbox',
      '--disable-setuid-sandbox',
      '--disable-dev-shm-usage',
      '--disable-gpu',
    ],
    headless: true,
    timeout: 30000,
  });

  const page = await browser.newPage();
  
  // تعيين User-Agent محترم
  await page.setUserAgent(
    'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36'
  );
  
  // تعيين Viewport
  await page.setViewport({ width: 1920, height: 1080 });
  
  return {
    browser,
    page,
    close: async () => {
      await page.close();
      await browser.close();
    },
  };
}

export async function loadMoreArticles(
  page: puppeteer.Page,
  maxClicks: number = 10
): Promise<boolean> {
  let clickCount = 0;

  while (clickCount < maxClicks) {
    try {
      // ابحث عن زر "المزيد" - يتطلب فحص الموقع الفعلي
      const loadMoreSelector = 
        '.load-more-btn, .more-btn, button.load-more, [data-action="load-more"]';
      
      const exists = await page.$(loadMoreSelector);
      if (!exists) {
        console.log('No more load button found');
        return false;
      }

      await page.click(loadMoreSelector);
      await delay(2000); // انتظر تحميل المقالات الجديدة
      
      clickCount++;
      console.log(`Clicked load more ${clickCount} times`);
    } catch (error) {
      console.error('Error clicking load more:', error);
      return false;
    }
  }

  return true;
}

export async function checkForExistingIds(
  page: puppeteer.Page,
  existingIds: Set<string>
): Promise<boolean> {
  // استخراج جميع المعرفات من الصفحة الحالية
  const ids = await page.evaluate(() => {
    return Array.from(document.querySelectorAll('a[href*="?p="], a[href*="?id="]'))
      .map(el => {
        const href = el.getAttribute('href') || '';
        const match = href.match(/[?&]p=(\d+)/);
        return match ? match[1] : null;
      })
      .filter(Boolean);
  });

  // تحقق إذا وجدنا معرفات موجودة بالفعل
  return ids.some(id => existingIds.has(id));
}
```

#### C. `backend/src/scraper/storage.ts` - تحسين حفظ البيانات
```typescript
import * as admin from 'firebase-admin';
import { ArticleDoc, SourceDoc } from '../interfaces';

const db = admin.firestore();

export async function upsertArticles(
  articles: any[],
  sourceKey: string,
  sourceDoc: SourceDoc
): Promise<{ created: number; updated: number; failed: number }> {
  let created = 0;
  let updated = 0;
  let failed = 0;

  // معالجة دفعية
  const batch = db.batch();
  let batchSize = 0;
  const BATCH_SIZE = 500;

  for (const article of articles) {
    try {
      const articleId = `${sourceKey}_${article.original_id}`;
      const articleRef = db.collection('articles').doc(articleId);
      
      const articleData: Partial<ArticleDoc> = {
        id: articleId,
        original_id: article.original_id,
        source_key: sourceKey,
        source_name_ar: sourceDoc.name_ar,
        cat_id: sourceDoc.cat_id,
        title: article.title,
        excerpt: article.excerpt,
        publish_date_raw: article.publish_date_raw,
        url: article.url,
        pdf_url: article.pdf_url || null,
        has_pdf: article.has_pdf,
        updated_at: admin.firestore.FieldValue.serverTimestamp(),
      };

      // تحقق إذا كانت المقالة موجودة
      const existing = await articleRef.get();
      if (existing.exists) {
        batch.update(articleRef, articleData);
        updated++;
      } else {
        batch.set(articleRef, {
          ...articleData,
          scraped_at: admin.firestore.FieldValue.serverTimestamp(),
        });
        created++;
      }

      batchSize++;

      // قم بالكتابة الدفعية كل 500 وثيقة
      if (batchSize === BATCH_SIZE) {
        await batch.commit();
        batchSize = 0;
      }
    } catch (error) {
      console.error(`Error upserting article ${article.original_id}:`, error);
      failed++;
    }
  }

  // قم بكتابة الدفعة المتبقية
  if (batchSize > 0) {
    await batch.commit();
  }

  return { created, updated, failed };
}

export async function updateSourceMetadata(
  sourceKey: string,
  metadata: Partial<SourceDoc>
): Promise<void> {
  const sourceRef = db.collection('sources').doc(sourceKey);
  
  await sourceRef.update({
    ...metadata,
    last_sync_at: admin.firestore.FieldValue.serverTimestamp(),
  });
}
```

---

## 3. Cloud Function - نظام الإشعارات 📬

### ملف جديد مطلوب:
```typescript
// backend/functions/src/triggers/onArticleCreated.ts

import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';

const db = admin.firestore();
const messaging = admin.messaging();

export const onArticleCreated = functions.firestore
  .document('articles/{articleId}')
  .onCreate(async (snap, context) => {
    const article = snap.data();

    try {
      // استخراج ملخص المقالة
      const summary = {
        source_key: article.source_key,
        source_name_ar: article.source_name_ar,
        title: article.title.substring(0, 100),
        article_id: article.id,
        timestamp: admin.firestore.Timestamp.now(),
      };

      // إرسال رسالة بيانات عبر FCM
      // (بدون إشعار - التطبيق سيتعامل مع الإشعار المحلي)
      await messaging.sendToTopic('news_updates', {
        data: {
          type: 'article_created',
          source_key: article.source_key,
          article_id: article.id,
          title: article.title,
          timestamp: Date.now().toString(),
        },
      });

      console.log('FCM message sent for article:', article.id);
    } catch (error) {
      console.error('Error sending FCM message:', error);
    }
  });
```

---

## 4. Flutter - معالج الإشعارات المتقدم 📱

### ملف يجب تحسينه:
```dart
// flutter_app/lib/core/services/notification_handler.dart

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/foundation.dart';

class NotificationHandler {
  static final instance = NotificationHandler._();
  
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  
  NotificationHandler._();

  Future<void> initialize() async {
    // تهيئة إشعارات محلية
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    
    const DarwinInitializationSettings iOSSettings =
        DarwinInitializationSettings();
    
    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iOSSettings,
    );
    
    await _localNotifications.initialize(initSettings);
    
    // الاشتراك في الموضوع الرئيسي
    await FirebaseMessaging.instance.subscribeToTopic('news_updates');
  }

  // معالج الرسائل الخلفية
  @pragma('vm:entry-point')
  static Future<void> backgroundMessageHandler(RemoteMessage message) async {
    // هذا يعمل في الخلفية
    if (message.data['type'] == 'article_created') {
      // حفظ البيانات أو إرسال إشعار محلي
      await instance.showLocalNotification(
        title: 'مقالة جديدة',
        body: message.data['title'] ?? 'عنوان جديد',
        payload: message.data['article_id'],
      );
    }
  }

  Future<void> showLocalNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'news_channel',
      'أخبار جريدة أم القرى',
      channelDescription: 'إشعارات المقالات الجديدة',
      importance: Importance.max,
      priority: Priority.high,
    );
    
    const DarwinNotificationDetails iOSDetails =
        DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    
    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iOSDetails,
    );
    
    await _localNotifications.show(
      DateTime.now().millisecond,
      title,
      body,
      notificationDetails,
      payload: payload,
    );
  }
}
```

---

## 5. قوانين الأمان المحسّنة 🔒

```firestore
// firestore.rules - إصدار محسّن

rules_version = '2';

service cloud.firestore {
  match /databases/{database}/documents {
    // Helper functions
    function isAuthenticated() {
      return request.auth != null;
    }
    
    function isAdmin() {
      return request.auth.token.admin == true;
    }
    
    function isOwner(uid) {
      return request.auth.uid == uid;
    }

    // Sources collection - read only for users
    match /sources/{sourceId} {
      allow read: if isAuthenticated();
      allow write: if isAdmin();
      allow create: if isAdmin();
      allow update: if isAdmin();
      allow delete: if isAdmin();
    }

    // Articles collection - read only for users
    match /articles/{articleId} {
      allow read: if isAuthenticated();
      allow write, create, update, delete: if isAdmin();
    }

    // Users collection - personal data
    match /users/{uid} {
      allow read, write: if isOwner(uid);
      
      // Favorites subcollection
      match /favorites/{favoriteId} {
        allow read, write: if isOwner(uid);
      }
    }

    // Deny all other access
    match /{document=**} {
      allow read, write: if false;
    }
  }
}
```

---

## 6. صيغ البيانات النهائية 📊

```typescript
// Complete Firestore document models

// Article
interface ArticleDoc {
  id: string;                              // "cabinet_decisions_28661"
  original_id: string;                     // "28661"
  source_key: string;                      // "cabinet_decisions"
  source_name_ar: string;                  // "قرارات مجلس الوزراء"
  cat_id: number;                          // 9
  
  title: string;                           // العنوان الكامل
  content_html?: string | null;            // محتوى HTML كامل
  content_plain?: string | null;           // نص مستخرج للبحث
  excerpt?: string | null;                 // الخلاصة الأولى
  
  publish_date_raw: string;                // "15 ربيع الثاني 1447 هـ"
  publish_date_gregorian?: string | null;  // "2025-11-28"
  publish_date_iso?: FirebaseTimestamp;    // للفرز
  
  url: string;                             // رابط المقالة
  pdf_url?: string | null;                 // رابط PDF
  pdf_storage_path?: string | null;        // مسار Firebase Storage
  has_pdf: boolean;                        // هل يوجد PDF
  
  scraped_at: FirebaseTimestamp;           // وقت الاستخراج
  updated_at: FirebaseTimestamp;           // آخر تحديث
  
  tags?: string[];                         // وسوم للبحث
  related_archive_id?: string | null;      // مرجع أرشيفي
}

// Source
interface SourceDoc {
  id: string;                              // "cabinet_decisions"
  name_ar: string;                         // "قرارات مجلس الوزراء"
  name_en: string;                         // "Cabinet Decisions"
  cat_id: number;                          // 9
  url: string;                             // URL الفئة
  enabled: boolean;                        // مفعّل؟
  icon: string;                            // اسم الأيقونة
  color: string;                           // اللون (hex)
  order: number;                           // ترتيب العرض
  last_sync_at?: FirebaseTimestamp;        // آخر مزامنة
  article_count?: number;                  // عدد المقالات
  last_error?: string | null;              // آخر خطأ
}

// User
interface UserDoc {
  uid: string;                             // Firebase Auth UID
  email?: string | null;
  display_name?: string | null;
  
  notification_enabled: boolean;
  subscribed_sources: string[];            // ["all"] أو ["cabinet_decisions", ...]
  
  theme: "light" | "dark" | "system";
  font_size: "small" | "medium" | "large";
  
  fcm_tokens: string[];
  created_at: FirebaseTimestamp;
  updated_at: FirebaseTimestamp;
}

// Favorite
interface FavoriteDoc {
  article_id: string;
  source_key: string;
  added_at: FirebaseTimestamp;
}
```

---

## 📋 قائمة التحقق النهائية

- [ ] تحميل بيانات المصادر الـ 7
- [ ] اختبار استخراج مصدر واحد بنجاح
- [ ] إعداد Cloud Run scheduler
- [ ] تفعيل Cloud Function للإشعارات
- [ ] اختبار FCM على جهاز حقيقي
- [ ] تحديث قوانين Firestore
- [ ] اختبار الأمان والأذونات
- [ ] اختبار النسخة الإنتاجية

---

**الحالة**: 📝 قائمة مفصلة للعناصر المطلوبة
**الأولوية**: الأسبوع الأول - العناصر 1-3، الأسبوع الثاني - العناصر 4-6
