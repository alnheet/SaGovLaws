# راصد جريدة أم القرى
# Rasid UQN - Umm Al-Qura News App

تطبيق Flutter متعدد المصادر لرصد ومتابعة جريدة أم القرى الرسمية.

**Firebase Project:** `sagovlaws`  
**Live Demo:** https://sagovlaws.web.app  
**GitHub:** https://github.com/YOUR_USERNAME/UmAlqura

## 🏗️ هيكل المشروع

```
UmAlqura/
├── .github/
│   └── workflows/     # GitHub Actions CI/CD
├── backend/           # Node.js + Puppeteer Scraper
│   ├── src/           # كود المصدر
│   ├── functions/     # Firebase Cloud Functions
│   └── Dockerfile     # للنشر على Cloud Run
├── flutter_app/       # تطبيق Flutter (Clean Architecture)
│   ├── lib/
│   │   ├── core/      # البنية الأساسية (Theme, Router, DI)
│   │   └── features/  # الميزات (Articles, Auth, Search...)
│   └── test/          # الاختبارات
├── firebase.json      # إعدادات Firebase
├── firestore.rules    # قواعد أمان Firestore
└── storage.rules      # قواعد أمان Storage
```

## 📱 المميزات

✅ **متعدد المصادر** - 7 مصادر حكومية رسمية  
✅ **Search & Filter** - بحث سريع في المقالات  
✅ **Favorites** - حفظ المقالات المفضلة محلياً  
✅ **PDF Viewer** - عرض ملفات PDF  
✅ **Real-time** - تحديثات يومية تلقائية  
✅ **Responsive Design** - واجهة متجاوبة (Web, Mobile)  
✅ **Dark Mode** - دعم المظهر الداكن  
✅ **RTL Support** - دعم كامل للعربية  

## 🔐 Firebase Services

| الخدمة | الاستخدام |
|--------|----------|
| **Firestore** | تخزين المقالات والبيانات |
| **Authentication** | تسجيل المستخدمين |
| **Storage** | تخزين الصور والملفات |
| **Cloud Functions** | معالجة البيانات |
| **Cloud Messaging** | الإشعارات |
| **Hosting** | نشر الويب |
| **Analytics** | تحليل الاستخدام |

## 🚀 الإعداد السريع

### 1. تثبيت الأدوات

```bash
# Flutter SDK
https://flutter.dev/docs/get-started/install

# Firebase CLI
npm install -g firebase-tools

# Node.js 18+
https://nodejs.org
```

### 2. استنساخ المشروع

```bash
git clone https://github.com/YOUR_USERNAME/UmAlqura.git
cd UmAlqura
```

### 3. إعداد Firebase

```bash
firebase login
firebase use sagovlaws

# في flutter_app
flutterfire configure --project=sagovlaws
```

### 4. تثبيت الاعتمادات

```bash
# Backend
cd backend
npm install

cd functions
npm install

# Flutter App
cd ../../flutter_app
flutter pub get
```

## 💻 التطوير المحلي

### تشغيل التطبيق

```bash
cd flutter_app

# على المتصفح
flutter run -d chrome

# على Android
flutter run

# على iOS
flutter run -d ios
```

### اختبار Firestore محلياً

```bash
firebase emulators:start
```

### تشغيل Backend

```bash
cd backend
npm run dev
# يعمل على http://localhost:3000
```

## 📦 النشر

### النشر التلقائي (GitHub Actions)

تم الإعداد لتحديث Firebase Hosting تلقائياً عند كل push إلى `main`:

```bash
# فقط اعمل push
git add .
git commit -m "تحسينات جديدة"
git push origin main

# سيتم النشر تلقائياً ✅
```

### النشر اليدوي

**Flutter Web:**
```bash
cd flutter_app
flutter build web --release
firebase deploy --only hosting
```

**Firestore Rules:**
```bash
firebase deploy --only firestore:rules
```

**Cloud Functions:**
```bash
cd backend/functions
npm run deploy
```

## 🔑 GitHub Secrets المطلوبة

أضف إلى GitHub Settings > Secrets:

```
FIREBASE_TOKEN=your_firebase_token_here
```

للحصول عليها:
```bash
firebase login:ci
```

## 📊 البنية المعمارية

```
Clean Architecture:
  - Presentation Layer (UI, BLoC)
  - Domain Layer (Entities, Use Cases)
  - Data Layer (Repositories, Data Sources)
```

## 🧪 الاختبارات

```bash
cd flutter_app
flutter test
```

## 📝 المسؤوليات

### Backend
- جلب البيانات من مصادر UQN الرسمية
- معالجة البيانات وتنظيفها
- حفظها في Firestore
- تشغيل يومي تلقائي

### Frontend
- عرض البيانات بطريقة جميلة وسهلة الاستخدام
- إدارة الحالة (State Management)
- البحث والفلترة المحلية
- التخزين المحلي (Local Storage)

## 🐛 الأخطاء الشائعة

### Firebase API Key غير صحيح
```
✅ تم الإصلاح: تحديث firebase_options.dart
```

### Missing Articles
```
✅ الحل: تأكد من تشغيل Backend Scraper
firebase emulators:start
```

## 📞 الدعم

لأي مشاكل أو أسئلة:
1. تحقق من الـ Issues على GitHub
2. اقرأ الـ Documentation
3. اطلب مساعدة في المشروع

## 📄 الترخيص

MIT License - انظر LICENSE.md

## 👥 المساهمون

تم إنشاء هذا المشروع بواسطة:
- **Developer**: محمد أحمد
- **UI/UX**: Google AI Studio Design System

---

**آخر تحديث:** ديسمبر 2024
