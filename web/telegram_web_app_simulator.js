/* eslint-disable no-console */
(function telegramWebAppSimulator(global) {
  'use strict';

  /**
   * Default `initData` query string (same shape as Telegram WebApp `Telegram.WebApp.initData` / `raw`).
   * Override with `?tgUser=...` or `localStorage tgDebugUser` (JSON user only); then `initData` is rebuilt
   * using `auth_date` / `hash` from this default string.
   */

  const DEFAULT_TELEGRAM_INIT_DATA =
    "user=%7B%22id%22%3A1251798314%2C%22first_name%22%3A%22Takhirov%22%2C%22last_name%22%3A%22%22%2C%22username%22%3A%22Takhirovs%22%2C%22language_code%22%3A%22en%22%2C%22allows_write_to_pm%22%3Atrue%2C%22photo_url%22%3A%22https%3A%5C%2F%5C%2Ft.me%5C%2Fi%5C%2Fuserpic%5C%2F320%5C%2FPv8sJMzN7dZuMSud-i2sgBEsm1XHx-1alxOrHEO5BX8.svg%22%7D&chat_instance=995270295019096179&chat_type=sender&auth_date=1775315100&signature=FZ5zb4-mXM3vckCWS7KppcvFnRsJfMkBOos6Due45Hlp7j1wYlXTvroFUA_nOuJe8nr5MbsNsGtW2dSD-eQsCg&hash=846a31496ceef73c9177f36c840875454900319a5def44226aa4efe3e8404cce";


  const parseDefaultInitData = (raw) => {
    const sp = new URLSearchParams(raw);
    return {
      authDate: sp.get('auth_date'),
      hash: sp.get('hash'),
      signature: sp.get('signature'),
      chatInstance: sp.get('chat_instance'),
      chatType: sp.get('chat_type'),
      userParam: sp.get('user'),
    };
  };

  const defaultInitParts = parseDefaultInitData(DEFAULT_TELEGRAM_INIT_DATA);

  /** WebApp `user` object (snake_case + flags Telegram sends). */
  const webAppUserFromParsed = (u) => ({
    ...u,
    is_bot: false,
    is_premium: false,
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

  const defaultUserParsed = () =>
    webAppUserFromParsed(JSON.parse(decodeURIComponent(defaultInitParts.userParam)));

  const defaultUserJson = JSON.stringify(defaultUserParsed());

  const fromQueryUser = parseUser(params.get('tgUser'));
  const storedUserRaw = readStorage('tgDebugUser');
  const fromStorageUser = parseUser(storedUserRaw);

  const mockUser = fromQueryUser ?? fromStorageUser ?? defaultUserParsed();

  // Rebuild `initData` only when user differs from default (URL `tgUser` or persisted custom `tgDebugUser`).
  const storedDiffersFromDefault = Boolean(storedUserRaw && storedUserRaw !== defaultUserJson);
  const hasUserOverride = Boolean(fromQueryUser) || storedDiffersFromDefault;

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

  // Must match Telegram format: `user` = URL-encoded JSON, plus `auth_date`, `hash`, optional `signature`, etc.
  // `telegram_web_app` parses this in TelegramInitData.fromRawString (see package source).
  const userJson = JSON.stringify(mockUser);
  const userQueryValue = encodeURIComponent(userJson);
  const initDataQueryString = hasUserOverride
    ? `user=${userQueryValue}&auth_date=${defaultInitParts.authDate}&hash=${defaultInitParts.hash}`
    : DEFAULT_TELEGRAM_INIT_DATA;

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
      auth_date: String(defaultInitParts.authDate),
      hash: defaultInitParts.hash,
      signature: defaultInitParts.signature,
      chat_instance: defaultInitParts.chatInstance,
      chat_type: defaultInitParts.chatType,
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

