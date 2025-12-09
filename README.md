# راصد جريدة أم القرى
# Rasid UQN - Umm Al-Qura News App

تطبيق Flutter متعدد المصادر لرصد ومتابعة جريدة أم القرى الرسمية.

## 🏗️ هيكل المشروع

```
UmAlqura/
├── backend/           # Cloud Run Scraper + Express API
│   ├── src/           # كود المصدر
│   ├── functions/     # Firebase Functions
│   └── Dockerfile     # للنشر على Cloud Run
├── flutter_app/       # تطبيق Flutter
│   └── lib/
│       ├── core/      # البنية الأساسية
│       └── features/  # الميزات (Clean Architecture)
├── firebase.json      # إعدادات Firebase
├── firestore.rules    # قواعد أمان Firestore
└── storage.rules      # قواعد أمان Storage
```

## 📱 المصادر السبعة

| المصدر | الوصف |
|--------|-------|
| قرارات مجلس الوزراء | Cabinet Decisions |
| الأوامر الملكية | Royal Orders |
| المراسيم الملكية | Royal Decrees |
| القرارات واللوائح | Decisions & Regulations |
| الأنظمة واللوائح | Laws & Regulations |
| القرارات الوزارية | Ministerial Decisions |
| الهيئات والمؤسسات | Authorities |

## 🚀 التشغيل

### Backend

```bash
cd backend
npm install
cp .env.example .env
# أضف مفاتيح Firebase إلى .env
npm run dev
```

### Firebase Functions

```bash
cd backend/functions
npm install
npm run build
firebase deploy --only functions
```

### Flutter App

```bash
cd flutter_app
flutter pub get
# قم بتشغيل FlutterFire CLI لإعداد Firebase
flutterfire configure
flutter run
```

## ⚙️ إعداد Firebase

1. أنشئ مشروع Firebase جديد
2. فعّل Authentication (Email/Password + Anonymous)
3. فعّل Firestore Database
4. فعّل Cloud Storage
5. فعّل Cloud Messaging
6. شغّل FlutterFire CLI:

```bash
dart pub global activate flutterfire_cli
flutterfire configure
```

## 🐳 نشر Backend على Cloud Run

```bash
cd backend
gcloud builds submit --tag gcr.io/PROJECT_ID/uqn-scraper
gcloud run deploy uqn-scraper \
  --image gcr.io/PROJECT_ID/uqn-scraper \
  --platform managed \
  --region me-central1 \
  --allow-unauthenticated
```

## 📋 Cloud Scheduler

قم بإعداد Cloud Scheduler لتشغيل الـ scraper:

```bash
# جلب كامل يومياً الساعة 6 صباحاً بتوقيت السعودية
gcloud scheduler jobs create http uqn-full-scrape \
  --schedule="0 6 * * *" \
  --uri="https://YOUR_CLOUD_RUN_URL/scrape/full" \
  --http-method=POST \
  --time-zone="Asia/Riyadh"

# جلب تزايدي كل ساعة
gcloud scheduler jobs create http uqn-incremental-scrape \
  --schedule="0 * * * *" \
  --uri="https://YOUR_CLOUD_RUN_URL/scrape/incremental" \
  --http-method=POST \
  --time-zone="Asia/Riyadh"
```

## 🔧 المتطلبات

### Backend
- Node.js >= 18
- npm >= 9

### Flutter
- Flutter SDK >= 3.2.0
- Dart >= 3.2.0

## 📄 الترخيص

هذا المشروع مرخص للاستخدام الخاص فقط.
