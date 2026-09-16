# تحرير الفواتير — النور (تطبيق أندرويد / Flutter)

نسخة أندرويد من تطبيق سطح المكتب الأصلي (C# / WPF)، مبنية بـ Flutter بنفس
المزايا: تسجيل دخول، فاتورة جديدة، سجل الفواتير، الزبائن، الممونون،
السلع والمخزون، معلومات الشركة، تصدير PDF، طباعة، ومشاركة عبر واتساب/جيميل
أو أي تطبيق آخر مثبت على الجهاز (عبر قائمة المشاركة الأصلية لأندرويد).

بيانات الدخول الافتراضية (يمكن تغييرها في `lib/screens/login_screen.dart`):
- اسم المستخدم: `admin`
- كلمة المرور: `tam12123`

## المتطلبات

* [Flutter SDK](https://docs.flutter.dev/get-started/install) (قناة stable، إصدار 3.22 فما فوق)
* Android Studio (لأدوات Android SDK) أو أدوات سطر الأوامر command-line tools فقط
* جهاز أندرويد أو محاكي للتجربة

## خطوات البناء (مهم: نفّذها بالترتيب)

هذا المجلد يحتوي على كود Dart فقط (`lib/`, `pubspec.yaml`, `assets/`).
مجلدات المنصّة (`android/`, `ios/`...) تُولَّد تلقائيًا بأمر Flutter نفسه،
لأنها تعتمد على إصدار أدوات جهازك — لذلك اتبع الخطوات التالية بالحرف:

```bash
# 1) داخل هذا المجلد (الذي يحوي pubspec.yaml)، ولّد مجلدات المنصة:
flutter create --project-name nour_invoicing --org com.nour .

# 2) نزّل الحزم:
flutter pub get

# 3) أضف خط عربي (اقرأ القسم التالي "الخط العربي") ثم:
flutter pub get

# 4) جرّب التطبيق على جهاز/محاكي متصل:
flutter run

# 5) لبناء ملف APK جاهز للتثبيت:
flutter build apk --release
# الملف الناتج في: build/app/outputs/flutter-apk/app-release.apk
```

> أمر `flutter create .` لا يحذف أو يستبدل `lib/` أو `pubspec.yaml` أو
> `assets/` الموجودة — فقط يضيف مجلدات `android/` و`ios/` وغيرها الناقصة.

## الخط العربي (ضروري لجودة ملف PDF)

واجهة التطبيق نفسها تعرض العربية بشكل صحيح تلقائيًا (أندرويد يوفر خطًا
احتياطيًا). لكن توليد ملف PDF يحتاج خطًا عربيًا حقيقيًا مضمّنًا:

1. نزّل خط **Noto Naskh Arabic** من Google Fonts:
   https://fonts.google.com/noto/specimen/Noto+Naskh+Arabic
2. من الملف المضغوط، انسخ:
   - `NotoNaskhArabic-Regular.ttf`
   - `NotoNaskhArabic-Bold.ttf` (أو `NotoNaskhArabic-SemiBold.ttf` وأعد تسميته)
3. ضعهما داخل `assets/fonts/` بنفس هذين الاسمين بالضبط.
4. أعد تشغيل `flutter pub get` ثم `flutter run` / `flutter build apk`.

بدون هذا الخط سيعمل التطبيق بشكل طبيعي، لكن النص العربي داخل ملفات PDF
المُصدَّرة (الفاتورة) لن يظهر بشكل صحيح.

## البناء عبر GitHub Actions (بدون تثبيت Flutter على حاسوبك)

هذا المستودع يحتوي على ملف جاهز `.github/workflows/build-apk.yml` يبني
ملف APK تلقائيًا على خوادم GitHub. الخطوات:

1. أنشئ مستودع (repository) جديد على GitHub — عام أو خاص، كلاهما يعمل.
2. ارفع محتوى هذا المجلد بالكامل إليه (بما في ذلك مجلد `.github/`).
   عبر الموقع مباشرة (Add file → Upload files) أو عبر git:
   ```bash
   git init
   git add .
   git commit -m "النور - نسخة أندرويد"
   git branch -M main
   git remote add origin <رابط-المستودع>
   git push -u origin main
   ```
3. (اختياري لكن يُنصح به) قبل الرفع، أضف الخط العربي إلى `assets/fonts/`
   كما في القسم السابق، حتى يظهر النص العربي بشكل صحيح داخل ملف PDF.
4. اذهب إلى تبويب **Actions** في صفحة المستودع على GitHub. سيبدأ البناء
   تلقائيًا بعد الرفع (أو اضغط "Run workflow" لتشغيله يدويًا).
5. انتظر حتى تكتمل العملية (رمز ✅ أخضر، تستغرق عادة 5-10 دقائق).
6. افتح التشغيل (run) المكتمل، وفي أسفل الصفحة تحت **Artifacts** ستجد
   ملف `NourInvoicing-apk` — حمّله (سيأتي كملف zip يحتوي على `app-release.apk`).
7. انقل `app-release.apk` إلى هاتفك وثبّته (قد يطلب أندرويد السماح
   بـ"التثبيت من مصادر غير معروفة" في المرة الأولى).

بهذه الطريقة لا تحتاج تثبيت Flutter أو Android SDK على جهازك إطلاقًا —
كل البناء يتم على خوادم GitHub مجانًا.

## أين تُحفظ البيانات؟

محليًا على الجهاز فقط (بصيغة JSON، بدون إنترنت ولا خادم)، داخل مجلد بيانات
التطبيق الخاص:
```
customers.json
suppliers.json
products.json
invoices.json
company.json
```

## الفرق عن نسخة سطح المكتب

* **المشاركة**: بدل حيلة "انسخ الملف ثم الصق بـ Ctrl+V" في نسخة ويندوز،
  تطبيق أندرويد يفتح قائمة المشاركة الأصلية لأندرويد (Share Sheet) مباشرة
  مع ملف PDF جاهزًا كمرفق — يعمل مع واتساب وجيميل وأي تطبيق آخر تلقائيًا.
* **الطباعة**: تفتح نافذة طباعة أندرويد القياسية (تدعم الطابعات اللاسلكية
  وحفظ PDF كطابعة افتراضية).

## هيكل المشروع

```
lib/
├── main.dart                  نقطة الانطلاق وإعداد الثيم/اللغة
├── models/                    Customer, Supplier, Product, Invoice, InvoiceLine, CompanyInfo
├── services/
│   ├── data_store.dart        حفظ/تحميل JSON محليًا
│   ├── number_to_arabic_words.dart  تحويل المبلغ إلى حروف عربية
│   └── pdf_exporter.dart      بناء وتصدير فاتورة PDF بنفس تصميم نسخة سطح المكتب
└── screens/
    ├── login_screen.dart
    ├── main_menu_screen.dart
    ├── customers_screen.dart / suppliers_screen.dart / products_screen.dart
    ├── new_invoice_screen.dart
    ├── invoice_list_screen.dart
    ├── invoice_preview_screen.dart   معاينة + طباعة + مشاركة
    └── settings_screen.dart
```

## تخصيص أيقونة التطبيق واسمه

بعد تنفيذ `flutter create .`:
* اسم التطبيق المعروض: عدّل `android/app/src/main/AndroidManifest.xml` → `android:label`.
* الأيقونة: أسهل طريقة هي إضافة حزمة `flutter_launcher_icons` إلى `pubspec.yaml`
  وتوليد الأيقونة من صورة الشعار (دائرة بحرف "ن") تلقائيًا.
