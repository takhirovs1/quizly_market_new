import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:ui/ui.dart';

import '../../../common/extension/context_extension.dart';
import '../screen/app_documents_screen.dart';

abstract class AppDocumentsState extends State<AppDocumentsScreen> {
  @override
  void initState() {
    context.setupTelegramBackButton();
    super.initState();
  }

  @override
  void dispose() {
    context.teardownTelegramBackButton();
    super.dispose();
  }

  MarkdownStyleSheet markdownStyle(BuildContext context) => MarkdownStyleSheet(
    p: context.x.textStyle.sfW400s14.copyWith(color: context.x.colors.text, height: 1.5),
    h1: context.x.textStyle.sfW700s18.copyWith(color: context.x.colors.text),
    h2: context.x.textStyle.sfW700s16.copyWith(color: context.x.colors.text),
    h3: context.x.textStyle.sfW600s16.copyWith(color: context.x.colors.text),
    strong: context.x.textStyle.sfW600s16.copyWith(color: context.x.colors.text),
    em: context.x.textStyle.sfW400s14.copyWith(color: context.x.colors.text, fontStyle: .italic),
    listBullet: context.x.textStyle.sfW400s14.copyWith(color: context.x.colors.text),
    a: context.x.textStyle.sfW400s14.copyWith(color: context.x.colors.primary, decoration: .underline),
    blockquote: context.x.textStyle.sfW400s14.copyWith(color: context.x.colors.gray),
    blockSpacing: 12,
    listIndent: 24,
  );

  /// Markdown for **Terms of Use** tab — o‘zingizning matningizni shu yerga yozing.
  final String kTermsOfUseMarkdown = '''
# QuizlyMarket Foydalanish shartlari

**Oxirgi yangilangan sana:** [04.04.2026]

Ushbu Foydalanish shartlari QuizlyMarket platformasidan foydalanish tartibini belgilaydi. Platformadan foydalanish, ro‘yxatdan o‘tish, kontent yuklash, test sotib olish yoki sotish orqali foydalanuvchi mazkur shartlarga rozilik bildiradi.

QuizlyMarket — foydalanuvchilarga test va quizlarni yuklash, sotish, sotib olish, qulay tarzda yechish, o‘rganish va yodlash imkonini beruvchi platformadir. Platformada testlardan foydalanish uchun turli rejimlar mavjud bo‘lishi mumkin, jumladan **Custom**, **University**, **Flashcard** va **Playground** rejimlari. Kelgusida sun’iy intellektga asoslangan qo‘shimcha funksiyalar, shu jumladan AI yordamida test yaratish imkoniyati ham joriy etilishi mumkin.

## 1. Umumiy qoidalar

QuizlyMarket barcha foydalanuvchilar uchun ochiq platforma hisoblanadi. Platformadan foydalanayotgan har bir shaxs undan qonuniy maqsadlarda, halol va vijdonli tarzda foydalanishi shart.

Foydalanuvchi QuizlyMarket’dan foydalanish orqali:
- ushbu shartlarga rioya qilishini;
- platformadan noqonuniy maqsadlarda foydalanmasligini;
- boshqa foydalanuvchilarning huquq va manfaatlariga zarar yetkazmasligini;
- platformaga joylashtirilgan kontent uchun shaxsan javobgar ekanini tasdiqlaydi.

## 2. Ro‘yxatdan o‘tish va akkaunt

QuizlyMarket’ga kirish bir necha usullar orqali amalga oshirilishi mumkin. Jumladan:
- Telegram orqali avtomatik login;
- Google akkaunti orqali kirish;
- Apple akkaunti orqali kirish;
- ushbu akkauntlarni Telegram bilan bog‘lash imkoniyati.

Foydalanuvchi o‘z akkauntidan foydalanish uchun javobgar hisoblanadi. Akkaunt xavfsizligini ta’minlash, bog‘langan akkauntlar ustidan nazoratni saqlash va uchinchi shaxslarga ruxsatsiz foydalanish imkonini bermaslik foydalanuvchining o‘z zimmasidadir.

QuizlyMarket platforma xavfsizligi, qoidabuzarlik holatlari, noqonuniy faoliyat, soxta ma’lumotlar yoki boshqa foydalanuvchilarga zarar yetkazuvchi harakatlar aniqlangan taqdirda akkauntni cheklash, vaqtincha to‘xtatish yoki butunlay bloklash huquqini saqlab qoladi.

## 3. Platformadagi xizmatlar

QuizlyMarket platformasi foydalanuvchilarga quyidagi imkoniyatlarni taqdim etadi:
- test va quizlarni yuklash;
- test va quizlarni sotish;
- test va quizlarni sotib olish;
- testlarni qulay shaklda yechish;
- o‘rganish va yodlash uchun maxsus rejimlardan foydalanish;
- reklama joylashtirish yoki reklama xizmatlaridan foydalanish;
- kelgusida AI asosidagi premium imkoniyatlardan foydalanish uchun obuna xizmatlaridan foydalanish.

Platformadagi ayrim funksiyalar hozir mavjud bo‘lishi, ayrimlari esa keyinchalik joriy etilishi mumkin. QuizlyMarket istalgan vaqtda xizmatlarni yangilash, o‘zgartirish, kengaytirish yoki cheklash huquqiga ega.

## 4. Foydalanuvchi kontenti

QuizlyMarket’da joylashtiriladigan testlar, quizlar va boshqa materiallar foydalanuvchilarning o‘zlari tomonidan yuklanadi. Shu sababli foydalanuvchi platformaga kontent joylashtirish orqali quyidagilarni tasdiqlaydi:
- yuklangan material uning o‘ziga tegishli yoki undan foydalanish uchun yetarli huquqqa ega;
- kontent uchinchi shaxslarning mualliflik huquqi, intellektual mulk huquqi yoki boshqa qonuniy manfaatlarini buzmaydi;
- kontent noqonuniy, haqoratli, chalg‘ituvchi, zararli yoki taqiqlangan materiallardan iborat emas.

QuizlyMarket foydalanuvchilar tomonidan yuklangan har bir materialni oldindan tekshirish majburiyatini olmaydi. Biroq platforma o‘z xohishiga ko‘ra istalgan kontentni tekshirish, yashirish, o‘chirish yoki unga kirishni cheklash ҳуқуқига ega.

Kontent uchun asosiy javobgarlik uni joylashtirgan foydalanuvchining zimmasida bo‘ladi.

## 5. Taqiqlangan harakatlar

QuizlyMarket’dan foydalanishda quyidagi harakatlarga yo‘l qo‘yilmaydi:
- noqonuniy, yolg‘on yoki chalg‘ituvchi kontent joylashtirish;
- boshqa shaxs nomidan o‘zini tanishtirish;
- mualliflik huquqi bilan himoyalangan materiallarni ruxsatsiz yuklash, sotish yoki tarqatish;
- platforma ishiga xalaqit berish;
- zararli kodlar, viruslar yoki boshqa texnik tahdidlarni joylashtirish;
- boshqa akkauntlarga ruxsatsiz kirishga urinish;
- platformaning moliyaviy yoki texnik mexanizmlaridan suiiste’mol qilish;
- spam, firibgarlik yoki manipulyativ faoliyat olib borish.

Bunday holat aniqlangan taqdirda QuizlyMarket tegishli akkauntni cheklash, kontentni o‘chirish, balansni vaqtincha muzlatish yoki boshqa zarur choralarni ko‘rish huquqiga ega.

## 6. To‘lovlar va hisob-kitoblar

QuizlyMarket’da test va quizlarni sotib olish yoki boshqa pullik xizmatlardan foydalanish uchun to‘lov tizimi mavjud. Hozirgi vaqtda to‘lovlar O‘zbekistondagi to‘lov provayderlari, jumladan **Click** va **Payme** orqali amalga oshiriladi.

Platforma foydalanuvchidan qo‘shimcha foiz ushlab qolmaydi. Belgilangan summa to‘liq foydalanuvchi balansiga tushirilishi nazarda tutiladi.

QuizlyMarket foydalanuvchining bank kartasi yoki to‘lov ma’lumotlarini o‘zida saqlamaydi. To‘lov bilan bog‘liq jarayonlar tegishli uchinchi tomon provayderlari orqali amalga oshiriladi. Shu sababli ayrim to‘lov operatsiyalariga nisbatan tegishli provayderlarning qoidalari va texnik shartlari ham amal qilishi mumkin.

Agar firibgarlik, shubhali tranzaksiya, texnik xato yoki qoidabuzarlik holati aniqlansa, QuizlyMarket tegishli mablag‘lar bo‘yicha tekshiruv o‘tkazish huquqini saqlab qoladi.

## 7. Obuna va kelajakdagi AI funksiyalar

QuizlyMarket’da kelgusida AI asosidagi funksiyalar yoki qo‘shimcha premium imkoniyatlar uchun obuna tizimi joriy etilishi mumkin. Bunday xizmatlar ishga tushirilgan taqdirda ularning narxi, muddati, amal qilish tartibi va cheklovlari alohida ko‘rsatiladi.

Foydalanuvchi pullik obuna yoki AI xizmatlaridan foydalanishni tanlagan taqdirda, ushbu xizmatlarga tegishli qo‘shimcha qoidalar ham qo‘llanilishi mumkin.

## 8. Reklama

QuizlyMarket platformasida reklama xizmatlari yoki reklama materiallari mavjud bo‘lishi mumkin. Platformada ko‘rsatilgan reklama materiallari, homiylik asosidagi takliflar yoki uchinchi tomon xizmatlariga oid havolalar bo‘yicha QuizlyMarket har doim ham ularning mazmuni, aniqligi yoki natijasi uchun javobgar bo‘lavermaydi.

Uchinchi tomon xizmatlaridan foydalanish foydalanuvchining o‘z xavfi ostida amalga oshiriladi.

## 9. Intellektual mulk

QuizlyMarket platformasining o‘zi, uning nomi, brendi, dizayni, funksional tuzilmasi va dasturiy yechimlari **FlutterBro**ga yoki tegishli huquq egalariga tegishli bo‘lishi mumkin.

Foydalanuvchi platformaga kontent joylashtirish orqali QuizlyMarket’ga ushbu kontentni platformada saqlash, ko‘rsatish, qayta formatlash va xizmatni ishlatish uchun zarur hajmda foydalanish huquqini beradi. Bu huquq platforma xizmatlarini taqdim etish bilan cheklanadi.

Agar foydalanuvchi joylashtirilgan kontent uchinchi shaxs huquqlarini buzayotgan bo‘lsa, bu bo‘yicha to‘liq javobgarlik o‘sha foydalanuvchining zimmasida bo‘ladi.

## 10. Maxfiylik

QuizlyMarket foydalanuvchi ma’lumotlariga ehtiyotkorona munosabatda bo‘lishga intiladi. Platformaga kirish, akkauntlarni bog‘lash, xizmatlardan foydalanish va texnik ishlashni ta’minlash uchun ayrim ma’lumotlar qayta ishlanishi mumkin.

To‘lovga oid nozik ma’lumotlar QuizlyMarket tomonidan saqlanmaydi. Bunday ma’lumotlar to‘lov provayderlari tomonidan qayta ishlanishi mumkin.

Foydalanuvchi platformadan foydalanish orqali xizmatni ko‘rsatish uchun zarur bo‘lgan ma’lumotlarni qayta ishlashga rozilik bildiradi.

## 11. Kafolatlarning cheklanishi

QuizlyMarket xizmatlari mavjud holatda taqdim etiladi. Platforma xizmatlarning har doim uzluksiz, xatosiz yoki barcha foydalanuvchilar kutgan natijada ishlashiga kafolat bermaydi.

Platformadagi testlar, quizlar va boshqa o‘quv materiallari o‘rganish va yodlashga ko‘maklashish maqsadida taqdim etiladi. QuizlyMarket foydalanuvchilar tomonidan joylashtirilgan materiallarning to‘liqligi, to‘g‘riligi yoki muayyan maqsadga mosligi uchun javob bermaydi.

## 12. Javobgarlikning cheklanishi

Qonunda ruxsat etilgan darajada QuizlyMarket, FlutterBro va ular bilan bog‘liq shaxslar quyidagilar uchun javobgar bo‘lmaydi:
- foydalanuvchi kontenti sababli yuzaga kelgan zararlar;
- texnik nosozliklar yoki xizmat uzilishlari;
- ma’lumotlar yo‘qolishi;
- uchinchi tomon xizmatlari bilan bog‘liq muammolar;
- foydalanuvchilar o‘rtasidagi nizolar;
- bilvosita yoki kutilmagan zararlar.

Foydalanuvchi platformadan o‘z xavfi ostida foydalanadi.

## 13. Xizmatlarni o‘zgartirish yoki to‘xtatish

QuizlyMarket istalgan vaqtda platformaning istalgan qismini o‘zgartirish, yangilash, vaqtincha to‘xtatish yoki butunlay yopish huquqiga ega. Bu holat yangi funksiyalar, texnik ishlar, xavfsizlik sabablari yoki biznes ehtiyojlari bilan bog‘liq bo‘lishi mumkin.

## 14. Shartlarga o‘zgartirish kiritish

QuizlyMarket ushbu Foydalanish shartlarini istalgan vaqtda yangilashi mumkin. Yangilangan tahrir platformada e’lon qilingan paytdan boshlab kuchga kiradi.

Platformadan foydalanishda davom etish foydalanuvchining yangilangan shartlarga roziligini anglatadi.

## 15. Qo‘llaniladigan huquq

QuizlyMarket butun dunyo bo‘ylab foydalanish uchun ochiq bo‘lishi mumkin. Shu bilan birga, platformadan foydalanish bilan bog‘liq nizolar tegishli amaldagi qonunchilik normalari asosida ko‘rib chiqiladi.

## 16. Aloqa ma’lumotlari

Ushbu Foydalanish shartlari bo‘yicha savollar, murojaatlar yoki takliflar uchun quyidagi aloqa manziliga yozishingiz mumkin:

**Operator / Brend:** FlutterBro  
**Email:** quizlymarket@gmail.com

''';

  /// Markdown for **Privacy Policy** tab — o‘zingizning matningizni shu yerga yozing.
  final String kPrivacyPolicyMarkdown = '''
# QuizlyMarket Maxfiylik siyosati

**Oxirgi yangilangan sana:** [04.04.2026]

Ushbu Maxfiylik siyosati QuizlyMarket platformasi foydalanuvchilarining ma’lumotlari qanday yig‘ilishi, qayta ishlanishi, saqlanishi va himoya qilinishini tushuntiradi. QuizlyMarket’dan foydalanish orqali foydalanuvchi ushbu siyosatda bayon qilingan qoidalarga rozilik bildiradi.

QuizlyMarket foydalanuvchilarga test va quizlarni yuklash, sotish, sotib olish, yechish, o‘rganish va yodlash imkonini beruvchi platformadir. Platformadan foydalanishda ayrim ma’lumotlar xizmatni taqdim etish, xavfsizlikni ta’minlash va foydalanuvchi tajribasini yaxshilash maqsadida qayta ishlanishi mumkin.

## 1. Biz qanday ma’lumotlarni yig‘amiz

QuizlyMarket foydalanuvchi akkauntini yaratish, xizmatlarni taqdim etish va platformani ishlatish uchun zarur bo‘lgan ayrim ma’lumotlarni yig‘ishi mumkin. Jumladan:

- ism;
- username;
- Telegram ID;
- email manzil;
- profil rasmi;
- qurilma yoki ilova bilan bog‘liq ayrim texnik ma’lumotlar;
- to‘lov holati;
- xaridlar tarixi;
- foydalanuvchi tomonidan yuklangan testlar va quizlar.

Ushbu ma’lumotlar asosan foydalanuvchiga xizmatlarni ko‘rsatish, uning akkauntini yuritish, xaridlarini ko‘rsatish, yuklangan testlarini boshqarish va platformadan foydalanishni qulaylashtirish uchun ishlatiladi.

## 2. Kirish usullari orqali olinadigan ma’lumotlar

### Telegram orqali kirishda
Agar foydalanuvchi Telegram orqali tizimga kirsa, QuizlyMarket quyidagi ma’lumotlarni olishi mumkin:

- Telegram user ID;
- ism;
- username;
- profil rasmi.

### Google va Apple orqali kirishda
Agar foydalanuvchi Google yoki Apple akkaunti orqali kirsa, QuizlyMarket quyidagi ma’lumotlarni olishi mumkin:

- email manzil;
- ism;
- avatar yoki profil rasmi.

Ushbu ma’lumotlar foydalanuvchi akkauntini yaratish va uni platforma bilan bog‘lash maqsadida ishlatiladi.

## 3. Foydalanuvchi kontenti va testlar

QuizlyMarket’da foydalanuvchilar o‘z testlari va quizlarini yuklashlari mumkin. Bu testlar foydalanuvchining tanloviga ko‘ra:

- **public** bo‘lishi mumkin, bunda boshqa foydalanuvchilar ularni ko‘rishi yoki sotib olishi mumkin;
- **private** bo‘lishi mumkin, bunda ular ommaga ochiq bo‘lmaydi.

Public qilingan testlar boshqa foydalanuvchilar tomonidan sotib olinishi mumkin. Bunday hollarda tegishli tushum yoki cashback foydalanuvchi balansiga qaytishi mumkin va ushbu balans QuizlyMarket ichidagi to‘lovlarda ishlatilishi mumkin.

Platformada rasmli testlar ham mavjud bo‘lishi mumkin. Foydalanuvchi tomonidan yuklangan testlar, jumladan private materiallar, maxfiy ma’lumot sifatida himoyalanishi kerak bo‘lgan ma’lumotlar qatoriga kiradi.

## 4. Ma’lumotlardan qanday foydalanamiz

QuizlyMarket foydalanuvchi ma’lumotlaridan quyidagi maqsadlarda foydalanishi mumkin:

- akkaunt yaratish va foydalanuvchini tizimga kiritish;
- foydalanuvchi profilini ko‘rsatish;
- testlarni yuklash, saqlash, sotish, sotib olish va yechish imkonini berish;
- to‘lovlar va ichki balans jarayonlarini yuritish;
- foydalanuvchining xaridlar va faoliyat tarixini ko‘rsatish;
- ilova va xizmatlar ishlashini yaxshilash;
- texnik nosozliklarni aniqlash va tuzatish;
- xavfsizlikni ta’minlash;
- foydalanuvchi tajribasini yaxshilash.

QuizlyMarket foydalanuvchilarga yanada qulaylik yaratish maqsadida analitika va texnik kuzatuv vositalaridan ham foydalanishi mumkin.

## 5. Analytics va texnik vositalar

QuizlyMarket platforma sifati va foydalanuvchi qulayligini oshirish maqsadida quyidagi xizmatlardan foydalanishi mumkin:

- **Firebase Analytics**
- **Crashlytics**
- **Google Analytics**
- **custom logs**

Bu vositalar ilovaning ishlashini tahlil qilish, xatolarni aniqlash, xizmat sifatini yaxshilash va foydalanuvchilarga yanada qulay tajriba yaratish uchun ishlatiladi.

## 6. Cookie fayllari

Hozirgi vaqtda QuizlyMarket cookie fayllardan foydalanmasligini bildiradi. Agar kelajakda web versiyada cookie yoki unga o‘xshash texnologiyalar joriy qilinsa, bu haqda mazkur Maxfiylik siyosatida alohida ma’lumot berilishi mumkin.

## 7. To‘lov ma’lumotlari

QuizlyMarket platformasida ayrim xizmatlar pullik bo‘lishi mumkin. To‘lovlar tegishli to‘lov provayderlari orqali amalga oshiriladi.

QuizlyMarket foydalanuvchining bank kartasi ma’lumotlarini to‘liq shaklda saqlamaydi. To‘lovni amalga oshirish uchun zarur bo‘lgan ayrim identifikatsion ma’lumotlar yoki to‘lovga oid texnik ma’lumotlar tegishli to‘lov provayderlariga yuborilishi mumkin.

QuizlyMarket to‘lovning o‘zi bilan bog‘liq zarur holatlarda quyidagi ma’lumotlarni qayta ishlashi mumkin:

- to‘lov holati;
- xaridlar tarixi;
- ichki balans bilan bog‘liq ma’lumotlar.

## 8. Ma’lumotlar qayerda saqlanadi

QuizlyMarket foydalanuvchi ma’lumotlarini o‘z serverlarida saqlaydi. Ma’lumotlar himoyalangan holda saqlanishi, ularga ruxsatsiz kirishning oldi olinishi va maxfiylikni ta’minlash uchun tegishli choralar ko‘rilishi ko‘zda tutiladi.

Siz taqdim etgan ma’lumotlarga ko‘ra, ma’lumotlar **Render** infratuzilmasi va **Yevropa serverlari** bilan bog‘liq muhitlarda saqlanishi mumkin.

## 9. Ma’lumotlarni ulashish

QuizlyMarket foydalanuvchi ma’lumotlarini sotmaydi va odatiy holatda uchinchi shaxslarga bermaydi.

Shu bilan birga, ayrim texnik yoki xizmat ko‘rsatish jarayonlari doirasida cheklangan hajmdagi ma’lumotlar quyidagi xizmatlar bilan bog‘liq tarzda qayta ishlanishi mumkin:

- autentifikatsiya xizmatlari;
- analytics xizmatlari;
- to‘lov provayderlari.

To‘lov jarayonida faqat zarur texnik yoki identifikatsion ma’lumotlar tegishli provayderga yuborilishi mumkin. QuizlyMarket foydalanuvchi ma’lumotlarini mustaqil tijoriy maqsadlarda uchinchi shaxslarga taqdim etmaydi.

## 10. Ma’lumotlarni himoya qilish

QuizlyMarket foydalanuvchi ma’lumotlarini himoya qilishga jiddiy yondashadi. Shu maqsadda texnik va tashkiliy xavfsizlik choralarini qo‘llashga intiladi. Jumladan:

- ma’lumotlarni ruxsatsiz kirishdan himoya qilish;
- private testlar va foydalanuvchi materiallarini maxfiy saqlash;
- tizim xavfsizligini kuzatib borish;
- texnik nosozliklar va zaifliklarni aniqlash.

Biroq, internet orqali uzatiladigan yoki elektron tarzda saqlanadigan har qanday ma’lumot uchun mutlaq xavfsizlikni kafolatlash imkonsiz bo‘lishi mumkin.

## 11. Akkaunt o‘chirilganda nima bo‘ladi

Agar foydalanuvchi o‘z akkauntini o‘chirsa, u bilan bog‘liq ma’lumotlar ham o‘chiriladi. Siz taqdim etgan ma’lumotlarga ko‘ra, akkaunt o‘chirilganda quyidagilar ham o‘chiriladi:

- akkaunt ma’lumotlari;
- testlar;
- to‘lovlar bilan bog‘liq ma’lumotlar;
- ichki balans.

Shuningdek, foydalanuvchiga tegishli saqlangan ma’lumotlar endilikda QuizlyMarket’da ushlab turilmasligi ko‘zda tutiladi.

## 12. Foydalanuvchi huquqlari

Hozirgi vaqtda foydalanuvchi ma’lumotlarini ilova ichida alohida tahrirlash funksiyasi mavjud bo‘lmasligi mumkin, chunki akkaunt asosan Telegram, Google yoki Apple orqali olingan asosiy ma’lumotlar asosida yaratiladi.

Shunga qaramay, foydalanuvchi maxfiylikka oid savollar yoki murojaatlar bilan QuizlyMarket bilan bog‘lanish huquqiga ega.

## 13. Voyaga yetmaganlar

QuizlyMarket’da yosh bo‘yicha qat’iy cheklov mavjud emas. Platforma test va o‘quv materiallariga yo‘naltirilgan bo‘lsa-da, foydalanuvchi voyaga yetmagan bo‘lsa, ota-ona yoki qonuniy vakil nazorati tavsiya etiladi, ayniqsa qanday turdagi testlar o‘rganilayotgani nuqtai nazaridan.

## 14. Bildirishnomalar va xabarlar

QuizlyMarket foydalanuvchilarga bildirishnomalar yuborishi mumkin. Bular quyidagilar bo‘lishi mumkin:

- bot orqali notification;
- ilova orqali custom notification;
- tizimga oid xabarlar.

Bunday bildirishnomalar foydalanuvchining ruxsati, qurilma sozlamalari yoki tegishli platforma ruxsatlariga bog‘liq holda yuborilishi mumkin.

## 15. Ushbu siyosatga o‘zgartirishlar

QuizlyMarket ushbu Maxfiylik siyosatini istalgan vaqtda yangilash huquqiga ega. Yangilangan talqin platformada e’lon qilingan paytdan boshlab kuchga kiradi, agar boshqacha tartib ko‘rsatilmagan bo‘lsa.

Foydalanuvchi platformadan foydalanishda davom etishi yangilangan Maxfiylik siyosatiga rozilik sifatida talqin qilinishi mumkin.

## 16. Aloqa

Mazkur Maxfiylik siyosati bo‘yicha savollar, murojaatlar yoki takliflar uchun quyidagi manzilga yozishingiz mumkin:

**Brend / operator:** FlutterBro  
**Email:** quizlymarket@gmail.com
''';
}
