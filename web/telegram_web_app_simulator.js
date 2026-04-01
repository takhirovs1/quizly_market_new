/* eslint-disable no-console */
(function telegramWebAppSimulator(global) {
  'use strict';

  /** Fixed init-data fields for local simulator (Telegram `auth_date` = Unix seconds, `hash` = HMAC). */
  const MOCK_AUTH_DATE = 1774935140;
  const MOCK_HASH =
    '938642aedb4c71827d51629bd425a2658bce5c9fed0030695b04e829d16dade3';

  /**
   * Default Telegram Mini App user for local / debug runs (matches
   * `LoginWithTelegramRequest` fields: id, first/last name, username, photo_url).
   * In real Telegram, `window.Telegram.WebApp.initDataUnsafe.user` is the live user;
   * this object is only used when simulating (localhost / ?tgDebug=1).
   *
   * Field names: snake_case — same as WebApp `user`
   * @see https://core.telegram.org/bots/webapps#user
   */
  const DEFAULT_TELEGRAM_MOCK_USER = Object.freeze({
    id: 1251798314,
    is_bot: false,
    first_name: 'Takhirov',
    last_name: '',
    username: 'Takhirovs',
    language_code: 'uz',
    is_premium: false,
    photo_url:
      'https://t.me/i/userpic/320/Pv8sJMzN7dZuMSud-i2sgBEsm1XHx-1alxOrHEO5BX8.svg',
    allows_write_to_pm: true,
    added_to_attachment_menu: false,
  });

  const telegram = global.Telegram;
  const hasRealTelegramUser = Boolean(telegram?.WebApp?.initDataUnsafe?.user);
  if (hasRealTelegramUser) return;

  const params = new URLSearchParams(global.location.search);
  const hostIsLocal = ['localhost', '127.0.0.1', '[::1]'].includes(global.location.hostname);

  const storage = (() => {
    try {
      return global.localStorage;
    } catch (_) {
      return null;
    }
  })();

  const readStorage = (key) => {
    if (!storage) return null;
    try {
      return storage.getItem(key);
    } catch (_) {
      return null;
    }
  };

  const writeStorage = (key, value) => {
    if (!storage) return;
    try {
      storage.setItem(key, value);
    } catch (_) { }
  };

  const removeStorage = (key) => {
    if (!storage) return;
    try {
      storage.removeItem(key);
    } catch (_) { }
  };

  const flagFromQuery = params.get('tgDebug');
  const storedFlag = readStorage('tgDebug');

  if (flagFromQuery === '0' || flagFromQuery?.toLowerCase() === 'false') {
    removeStorage('tgDebug');
    removeStorage('tgDebugUser');
    return;
  }

  if (flagFromQuery === '1' || flagFromQuery?.toLowerCase() === 'true') {
    writeStorage('tgDebug', 'true');
  }

  const shouldSimulate =
    hostIsLocal ||
    flagFromQuery === '1' ||
    flagFromQuery?.toLowerCase() === 'true' ||
    storedFlag === '1' ||
    storedFlag?.toLowerCase() === 'true';

  if (!shouldSimulate) return;

  const tryJson = (value) => {
    if (!value) return null;
    try {
      return JSON.parse(value);
    } catch (_) {
      return null;
    }
  };

  const tryBase64Json = (value) => {
    if (!value) return null;
    try {
      return tryJson(global.atob(value));
    } catch (_) {
      return null;
    }
  };

  const parseUser = (raw) => tryJson(raw) ?? tryBase64Json(raw);

  const mockUser =
    parseUser(params.get('tgUser')) ??
    parseUser(readStorage('tgDebugUser')) ?? { ...DEFAULT_TELEGRAM_MOCK_USER };

  console.log('mockUser', mockUser);

  writeStorage('tgDebugUser', JSON.stringify(mockUser));

  const buttonFactory = (name) => {
    const state = { text: name, isVisible: false, isActive: true };
    return {
      setText: (text) => {
        state.text = text;
        console.info(`[tg-sim] ${name}.setText(${text})`);
      },
      show: () => {
        state.isVisible = true;
        console.info(`[tg-sim] ${name}.show()`);
      },
      hide: () => {
        state.isVisible = false;
        console.info(`[tg-sim] ${name}.hide()`);
      },
      enable: () => {
        state.isActive = true;
        console.info(`[tg-sim] ${name}.enable()`);
      },
      disable: () => {
        state.isActive = false;
        console.info(`[tg-sim] ${name}.disable()`);
      },
      onClick: (callback) => {
        state.onClick = callback;
        console.info(`[tg-sim] ${name}.onClick(callback)`);
      },
      offClick: () => {
        state.onClick = undefined;
        console.info(`[tg-sim] ${name}.offClick()`);
      },
    };
  };

  // Must match Telegram format: `user` = URL-encoded JSON, plus `auth_date` and `hash`.
  // `telegram_web_app` parses this in TelegramInitData.fromRawString (see package source).
  const userJson = JSON.stringify(mockUser);
  const userQueryValue = encodeURIComponent(userJson);
  const initDataQueryString = `user=${userQueryValue}&auth_date=${MOCK_AUTH_DATE}&hash=${MOCK_HASH}`;

  const simulator = {
    version: '7.9',
    platform: params.get('tgPlatform') ?? 'tdesktop',
    colorScheme: global.matchMedia('(prefers-color-scheme: dark)').matches ? 'dark' : 'light',
    themeParams: {},
    initData: initDataQueryString,
    initDataUnsafe: {
      query_id: 'debug',
      user: mockUser,
      // String: `telegram_web_app` parses with int.tryParse(auth_date)
      auth_date: String(MOCK_AUTH_DATE),
      hash: MOCK_HASH,
      start_param: params.get('tgStartParam') ?? '',
    },
    isExpanded: true,
    isClosingConfirmationEnabled: false,
    isSupported: true,
    ready: () => console.info('[tg-sim] ready()'),
    expand: () => console.info('[tg-sim] expand()'),
    close: () => console.info('[tg-sim] close()'),
    disableVerticalSwipes: () => console.info('[tg-sim] disableVerticalSwipes()'),
    enableClosingConfirmation: () => console.info('[tg-sim] enableClosingConfirmation()'),
    disableClosingConfirmation: () => console.info('[tg-sim] disableClosingConfirmation()'),
    sendData: (data) => console.info('[tg-sim] sendData', data),
    onEvent: (event, handler) => console.info('[tg-sim] onEvent', event, handler),
    offEvent: (event, handler) => console.info('[tg-sim] offEvent', event, handler),
    isVersionAtLeast: () => true,
    MainButton: buttonFactory('MainButton'),
    BackButton: buttonFactory('BackButton'),
  };

  global.Telegram = telegram ?? {};
  global.Telegram.WebApp = { ...(telegram?.WebApp ?? {}), ...simulator };

  const fullName = [mockUser.first_name, mockUser.last_name].filter(Boolean).join(' ');
  console.info(
    '%cTelegram WebApp simulator enabled%c user=%s',
    'color:#30a4e6;font-weight:bold;',
    'color:inherit;font-weight:normal;',
    fullName || mockUser.username || mockUser.id,
  );
})(window);

