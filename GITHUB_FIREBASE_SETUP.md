# 🚀 دليل الربط بين GitHub و Firebase

## الخطوة 1️⃣: إعداد GitHub Repository

### 1. إنشاء مستودع جديد على GitHub
```bash
# اذهب إلى https://github.com/new
# الاسم: UmAlqura
# الوصف: Rasid UQN - Umm Al-Qura News App
# Public
```

### 2. ربط المشروع المحلي

```bash
cd d:\codes\UmAlqura

# إذا لم يكن git مهيأ بعد
git init

# إضافة جميع الملفات
git add .

# أول commit
git commit -m "Initial commit: UmAlqura Flutter app"

# ربط remote
git remote add origin https://github.com/YOUR_USERNAME/UmAlqura.git

# رفع إلى GitHub
git branch -M main
git push -u origin main
```

## الخطوة 2️⃣: إعداد Firebase Token

### 1. إنشاء Firebase Token

```bash
firebase login:ci
```

هذا سيفتح متصفح لتسجيل الدخول، ثم سيعطيك token طويل.

### 2. حفظ Token في GitHub Secrets

```
https://github.com/YOUR_USERNAME/UmAlqura/settings/secrets/actions
```

**أضف Secret جديد:**
- **Name**: `FIREBASE_TOKEN`
- **Value**: الـ token الذي حصلت عليه

## الخطوة 3️⃣: تفعيل GitHub Actions

```bash
# تأكد من وجود ملف workflow
# .github/workflows/deploy.yml

git status
# يجب أن تشاهد:
# .github/workflows/deploy.yml
# .firebaserc
# .gitignore
# firebase.json
```

## الخطوة 4️⃣: اختبار النشر التلقائي

```bash
# عمل تغيير صغير
echo "# Deployed successfully!" >> DEPLOY_LOG.md

# Push لـ GitHub
git add .
git commit -m "Test automated deployment"
git push origin main

# اذهب إلى:
# https://github.com/YOUR_USERNAME/UmAlqura/actions
# شاهد الـ workflow يعمل ✨
```

## الخطوة 5️⃣: التحقق من النشر

```bash
# بعد انتهاء GitHub Actions، افتح:
https://sagovlaws.web.app
```

يجب أن ترى التطبيق مباشرة!

## 📊 ماذا يحدث عند كل Push؟

```
1. GitHub Actions يستقبل الـ push
   ↓
2. اختبار التطبيق
   ↓
3. بناء Flutter Web
   ↓
4. بناء Cloud Functions
   ↓
5. نشر إلى Firebase Hosting ✅
```

## 🔧 الأوامر المفيدة

### فحص الـ Workflows
```bash
# عرض جميع الـ workflows
ls .github/workflows/

# عرض تاريخ النشر
firebase hosting:releases
```

### إيقاف النشر التلقائي (إذا أردت)
```bash
# عطل الـ workflow من GitHub
# Settings > Actions > Disable
```

### النشر اليدوي

```bash
# Flutter Web
cd flutter_app
flutter build web --release
firebase deploy --only hosting

# Cloud Functions فقط
cd ../backend/functions
npm run deploy

# Firestore Rules فقط
cd ../..
firebase deploy --only firestore:rules
```

## ⚠️ المشاكل الشائعة

### مشكلة: "Failed to deploy"
```
✅ تحقق من FIREBASE_TOKEN في GitHub Secrets
✅ تأكد من أن pubspec.yaml موجود
✅ تحقق من أن Node.js مثبت في الـ runner
```

### مشكلة: "Out of quota"
```
✅ انتظر قليلاً وأعد المحاولة
✅ يمكنك النشر يدوياً بدون انتظار
```

### مشكلة: الملفات الكبيرة
```
✅ أضف مسارات إلى .gitignore
✅ استخدم git lfs للملفات الكبيرة
```

## 📝 الملفات المهمة

| الملف | الغرض |
|------|-------|
| `.github/workflows/deploy.yml` | تكوين CI/CD |
| `.firebaserc` | إعدادات Firebase |
| `firebase.json` | تكوين Hosting |
| `.gitignore` | ملفات المراد تجاهلها |
| `pubspec.yaml` | اعتمادات Flutter |
| `package.json` | اعتمادات Node.js |

## 🎉 النتيجة النهائية

بعد الانتهاء من هذه الخطوات:

✅ يمكنك الـ push إلى GitHub  
✅ سيتم البناء والاختبار تلقائياً  
✅ سيتم النشر إلى Firebase تلقائياً  
✅ الموقع متوفر على https://sagovlaws.web.app  

## 📞 للمزيد من المساعدة

- [Firebase Documentation](https://firebase.google.com/docs)
- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Flutter Web Documentation](https://flutter.dev/docs/deployment/web)

---

**تم الإعداد بنجاح! 🚀**
