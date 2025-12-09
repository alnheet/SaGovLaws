# دليل إصلاح مزامنة Git مع GitHub

## المشكلة
تم تغيير اسم المستودع من `UMalqura` إلى `SaGovLaws` ولا يوجد remote مرتبط بالمستودع المحلي.

## الحل

### الخطوة 1: إضافة المستودع البعيد (Remote)

استبدل `YOUR_USERNAME` باسم المستخدم الخاص بك على GitHub:

```powershell
git remote add origin https://github.com/YOUR_USERNAME/SaGovLaws.git
```

أو إذا كنت تستخدم SSH:
```powershell
git remote add origin git@github.com:YOUR_USERNAME/SaGovLaws.git
```

### الخطوة 2: التحقق من إضافة الـ remote

```powershell
git remote -v
```

يجب أن ترى:
```
origin  https://github.com/YOUR_USERNAME/SaGovLaws.git (fetch)
origin  https://github.com/YOUR_USERNAME/SaGovLaws.git (push)
```

### الخطوة 3: دفع التغييرات إلى GitHub

```powershell
git push -u origin main
```

إذا كان الفرع الرئيسي اسمه `master` بدلاً من `main`:
```powershell
git push -u origin master
```

### الخطوة 4 (اختياري): إذا كان المستودع البعيد يحتوي على ملفات

إذا كان المستودع البعيد يحتوي على ملفات (مثل README.md):

```powershell
# جلب البيانات من المستودع البعيد
git fetch origin

# دمج التغييرات مع السماح بتاريخ غير مرتبط
git merge origin/main --allow-unrelated-histories

# أو استخدام rebase
git rebase origin/main

# ثم دفع التغييرات
git push -u origin main
```

### الخطوة 5: التحقق من المزامنة

```powershell
git status
```

## إصلاح المشاكل الشائعة

### 1. إذا كان الـ remote موجود بالفعل ويشير إلى المستودع القديم

```powershell
# حذف الـ remote القديم
git remote remove origin

# إضافة الـ remote الجديد
git remote add origin https://github.com/YOUR_USERNAME/SaGovLaws.git
```

### 2. إذا كنت تريد تغيير عنوان الـ remote الموجود

```powershell
git remote set-url origin https://github.com/YOUR_USERNAME/SaGovLaws.git
```

### 3. إذا كان لديك ملفات كثيرة في node_modules

يُنصح بإضافة ملف `.gitignore` لتجاهل المجلدات الكبيرة:

```powershell
# إنشاء أو تحديث .gitignore
@"
# Node modules
backend/node_modules/
flutter_app/node_modules/

# Build directories
flutter_app/build/
backend/lib/
backend/dist/

# IDE
.vscode/
.idea/
*.iml

# OS
.DS_Store
Thumbs.db
"@ | Out-File -FilePath .gitignore -Encoding UTF8

# إزالة الملفات من التتبع
git rm -r --cached backend/node_modules
git commit -m "Remove node_modules from tracking"
git push
```

## ملاحظات مهمة

1. **احفظ بياناتك**: تأكد من عمل نسخة احتياطية قبل تنفيذ أي أمر
2. **اسم المستخدم**: استبدل `YOUR_USERNAME` باسم المستخدم الفعلي على GitHub
3. **الفرع الرئيسي**: تأكد من اسم الفرع الرئيسي (main أو master)
4. **المصادقة**: قد تحتاج إلى إدخال اسم المستخدم وكلمة المرور أو Personal Access Token

## للمساعدة

إذا واجهت أي مشاكل، يمكنك:
- التحقق من حالة Git: `git status`
- عرض السجل: `git log --oneline`
- عرض الـ remotes: `git remote -v`
