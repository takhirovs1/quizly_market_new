# QuizlyMarket — Landing

Talabalar uchun testlar marketplace platformasining landing sahifasi.
Vite + vanilla JS (ES modules), Clean Architecture tamoyillari asosida.

## Ishga tushirish

```bash
npm install
npm run dev        # http://localhost:5173
npm run build      # dist/ ga production build
npm run preview    # build ni lokal ko'rish
```

## Firebase'ga deploy

```bash
npm i -g firebase-tools     # bir marta
firebase login
npm run deploy              # build + deploy (.firebaserc dagi "test-9cf8b" loyihasiga)
```

`firebase.json` → `dist/` papkasini hosting qiladi, SPA rewrite yoqilgan.

## Loyiha tuzilmasi (Clean Architecture)

```
src/
  core/                 # konfiguratsiya va konstantalar (DOM yo'q, logika yo'q)
    config.js           #   tashqi linklar (web app, store, social)
    constants.js        #   til ro'yxati, taymerlar, brend ranglar
  domain/               # biznes qatlam (toza, DOMga bog'liq emas)
    models/             #   Language, Question entity'lari
    usecases/           #   LanguageService, QuizEngine (holat mashinasi)
  data/                 # ma'lumot manbalari va repozitoriylar
    i18n/               #   uz/ru/en/kk lug'atlari + heroTitle + index
    quiz/               #   quiz.data.js (manba) + quiz.repository.js (mapper)
    repositories/       #   LanguagePreferenceRepository (localStorage)
  presentation/         # UI qatlam (DOM)
    controllers/        #   i18n, nav, reveal, counters, quiz
    effects/            #   cursorFx, dotField
    styles/             #   tokens/base/layout/phone/sections/... (cascade tartibi saqlangan)
  main.js               # composition root: data → domain → presentation
index.html              # view (data-i18n bilan belgilangan)
public/assets/          # logo.png, mascot.png, iphone-mockup.png
```

### Bog'liqlik yo'nalishi
`presentation → domain ← data`, `core` hammaga ochiq.
Domain qatlami (`QuizEngine`, `LanguageService`) DOM yoki localStorage'ni
bilmaydi — ular interfeyslar (repository, getQuestions) orqali ulanadi.

## Sozlash
- Store / social linklar: `src/core/config.js`
- Tillar ro'yxati / taymer: `src/core/constants.js`
- Tarjimalar: `src/data/i18n/<lang>.js`
- Test savollari: `src/data/quiz/quiz.data.js`
