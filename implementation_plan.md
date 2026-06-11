# Yangi tillar qo'shish va intl_kk.arb ni to'g'rilash

Hozirgi `intl_kk.arb` fayl O'zbek Kirill (Ўзбек) sifatida ishlatilmoqda lekin `kk` Qozoq til kodi. Uni to'g'ri Qozoq tiliga o'zgartiramiz va O'zbek Kirill uchun alohida fayl yaratamiz.

## Proposed Changes

### 1. ARB fayllar

#### [NEW] [intl_uz_Cyrl.arb](file:///Users/samandar/Documents/Private/quizly_market_new/packages/localization/lib/src/l10n/app/intl_uz_Cyrl.arb)
- O'zbek Kirill alifbosida (Ўзбек) — hozirgi `intl_kk.arb` mazmuni asosida to'g'ri to'ldiriladi
- `@@locale: uz_Cyrl` — Flutter `Locale.fromSubtags(languageCode: 'uz', scriptCode: 'Cyrl')` sifatida ishlaydi

#### [MODIFY] [intl_kk.arb](file:///Users/samandar/Documents/Private/quizly_market_new/packages/localization/lib/src/l10n/app/intl_kk.arb)
- To'liq qayta yoziladi — haqiqiy **Qozoq tilida** (Қазақ тілі, Kirill yozuvida)
- Barcha keylar `intl_en.arb` bilan bir xil

#### [NEW] [intl_tg.arb](file:///Users/samandar/Documents/Private/quizly_market_new/packages/localization/lib/src/l10n/app/intl_tg.arb)
- **Tojik tili** (Тоҷикӣ, Kirill yozuvida)
- Barcha keylar `intl_en.arb` bilan bir xil

#### [NEW] [intl_ky.arb](file:///Users/samandar/Documents/Private/quizly_market_new/packages/localization/lib/src/l10n/app/intl_ky.arb)
- **Qirg'iz tili** (Кыргызча, Kirill yozuvida)
- Barcha keylar `intl_en.arb` bilan bir xil

---

### 2. Til nomlari — `intl_en.arb` (template) ga qo'shish

Barcha ARB fayllarga quyidagi yangi keylar qo'shiladi:
- `kazakh` → "Қазақ"
- `tajik` → "Тоҷикӣ"  
- `kyrgyz` → "Кыргызча"

---

### 3. Til tanlash UI

#### [MODIFY] [profile_screen_state.dart](file:///Users/samandar/Documents/Private/quizly_market_new/lib/src/feature/profile/state/profile_screen_state.dart)
- Uzbek Kirill uchun `Locale('kk')` → `Locale.fromSubtags(languageCode: 'uz', scriptCode: 'Cyrl')` ga o'zgartiriladi
- Qozoq, Tojik, Qirg'iz tillarini qo'shish (yangi `SelectionPillButton`lar)
- `maxHeightFactor` ni kattalashtirish (7 ta til bo'lganligi uchun)

---

### 4. Code generation

- `flutter gen-l10n` buyrug'i bilan localization kodni regenerate qilish

## Open Questions

> [!IMPORTANT]
> `intl_kk.arb` hozir `uzbekKril` label sifatida ishlatilgan va `Locale('kk')` bilan saqlangan. Agar foydalanuvchilar oldin `kk` tilini tanlab saqlagan bo'lsa, yangi versiyada ularga Qozoq tili ko'rsatiladi. Bu eski foydalanuvchilar uchun muammo bo'ladimi? Yoki bu acceptable?

## Verification Plan

### Automated Tests
- `flutter gen-l10n` muvaffaqiyatli ishlashi
- `flutter analyze` xatolarsiz o'tishi
