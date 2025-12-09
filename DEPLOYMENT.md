# 📦 دليل النشر الكامل

## 🎯 النشر على Firebase

### المتطلبات
- ✅ حساب Firebase (sagovlaws)
- ✅ Firebase CLI مثبت
- ✅ GitHub Repository
- ✅ GitHub Token

---

## 1️⃣ نشر Firestore Rules

### القواعس الحالية
```
- Articles: public read, backend write only
- Sources: public read, backend write only  
- Users: private (owner only)
- Favorites: private subcollection
```

### الأمر

```bash
cd d:\codes\UmAlqura
firebase deploy --only firestore:rules
```

### التحقق

```bash
# من Firebase Console
# Firestore > Rules
# يجب أن ترى الـ rules محدثة
```

---

## 2️⃣ نشر Firestore Indexes

### الفهارس المطلوبة

```json
{
  "articles": [
    { "sourceKey": "ASC", "publish_date_iso": "DESC" },
    { "sourceKey": "ASC", "created_at": "DESC" },
    { "category": "ASC", "publish_date_iso": "DESC" }
  ],
  "users/favorites": [
    { "userId": "ASC", "saved_at": "DESC" }
  ]
}
```

### الأمر

```bash
firebase deploy --only firestore:indexes
```

---

## 3️⃣ نشر Cloud Functions

### المتطلبات

```bash
# في backend/functions
npm install
npm run build  # TypeScript compilation
```

### الأمر

```bash
cd d:\codes\UmAlqura\backend\functions
firebase deploy --only functions
```

### الدوال المتوفرة

- `onArticleCreated` - معالج عند إنشاء مقالة
- `dailyScraper` - جلب البيانات يومياً
- `searchArticles` - البحث المتقدم

---

## 4️⃣ نشر Firebase Storage

### القواعس

```
- Images: public read, authenticated write
- PDFs: public read, authenticated write
- Temp: cleanup after 7 days
```

### الأمر

```bash
firebase deploy --only storage
```

---

## 5️⃣ نشر Flutter Web

### البناء

```bash
cd flutter_app
flutter clean
flutter pub get
flutter build web --release
```

### النشر

```bash
firebase deploy --only hosting:flutter-app
```

### التحقق

```
https://sagovlaws.web.app
```

---

## 6️⃣ نشر متكامل (All-in-One)

```bash
# نشر كل شيء
firebase deploy --project=sagovlaws

# نشر محدد
firebase deploy --only \
  hosting,\
  firestore:rules,\
  firestore:indexes,\
  functions,\
  storage
```

---

## 🤖 النشر التلقائي (GitHub Actions)

### الإعداد

1. **أنشئ Firebase Token**
   ```bash
   firebase login:ci
   ```

2. **أضفه إلى GitHub Secrets**
   ```
   https://github.com/YOUR_USERNAME/UmAlqura/settings/secrets/actions
   ```
   - Name: `FIREBASE_TOKEN`
   - Value: الـ token

3. **تحقق من Workflow**
   ```
   .github/workflows/deploy.yml موجود ✅
   ```

### الاستخدام

```bash
git push origin main
# سيتم النشر تلقائياً ✨
```

---

## 🧪 اختبار ما بعد النشر

### 1. التحقق من Hosting

```bash
# افتح الموقع
https://sagovlaws.web.app

# تحقق من:
✅ الصفحة الرئيسية تعمل
✅ الملفات الثابتة تُحمل
✅ Firebase متصل
```

### 2. التحقق من Firestore

```bash
# Firebase Console > Firestore
✅ Collections موجودة
✅ البيانات محدثة
✅ الفهارس نشطة
```

### 3. التحقق من Functions

```bash
# Firebase Console > Functions
✅ جميع الدوال موجودة
✅ لا توجد أخطاء
✅ Logs نظيفة
```

### 4. اختبار المستخدم

```
- زيارة الموقع
- البحث عن مقالة
- فتح مقالة
- حفظ كمفضلة
- تحميل PDF
```

---

## 🔄 التحديث المستقبلي

### للتطبيق

```bash
# عمل تغيير
# ...

# Push
git add .
git commit -m "تحسينات جديدة"
git push origin main

# أو نشر يدوي
flutter build web --release
firebase deploy --only hosting
```

### لقواعد Firestore

```bash
# تحرير firestore.rules
# ...

firebase deploy --only firestore:rules
```

### لـ Cloud Functions

```bash
cd backend/functions
# تحرير الكود
# ...

npm run build
firebase deploy --only functions
```

---

## ⚠️ نصائح أمان

### Firebase Keys
- ✅ لا تضع keys في Git
- ✅ استخدم `.env` و `.gitignore`
- ✅ استخدم Secrets في GitHub Actions

### Firestore Rules
- ✅ فعّل authentication
- ✅ تحقق من الصلاحيات
- ✅ قيّد الكتابة للـ backend

### Storage
- ✅ تحقق من حدود الملفات
- ✅ نظف الملفات القديمة
- ✅ استخدم Cloud Storage permissions

---

## 📊 مراقبة النشر

### Firebase Console

```
https://console.firebase.google.com/project/sagovlaws
```

الأقسام المهمة:
- **Hosting** > Deployments
- **Functions** > Logs
- **Firestore** > Data & Rules
- **Analytics** > Dashboard

### GitHub Actions

```
https://github.com/YOUR_USERNAME/UmAlqura/actions
```

عرض:
- Workflow runs
- Build logs
- Deploy status

---

## 🚨 التعامل مع الأخطاء

### Firebase Authentication Error
```bash
firebase logout
firebase login
firebase deploy
```

### Out of Storage Quota
```bash
# نظف الملفات القديمة من Storage
# أو upgrade الـ plan
```

### Build Failed
```bash
cd flutter_app
flutter clean
flutter pub get
flutter build web --release
```

### Deployment Timeout
```bash
# حاول مرة أخرى
firebase deploy --debug
```

---

## 📞 الدعم

- [Firebase Docs](https://firebase.google.com/docs)
- [GitHub Actions Docs](https://docs.github.com/en/actions)
- [Flutter Deployment Docs](https://flutter.dev/docs/deployment)

---

**تم الإعداد بنجاح! 🎉**
