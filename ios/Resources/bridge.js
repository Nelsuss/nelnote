// NEL NOTE 아이폰 앱(WKWebView)용 연결 코드
// 안드로이드 앱의 window.DojangNative 와 같은 이름·같은 동작으로,
// 화면(index.html)이 기록·배경 사진·설정을 앱 안 파일에 저장하고 불러오게 해 준다.
// 앱이 시작할 때 저장된 값을 window.__NEL_INIT 으로 미리 넣어 주므로 불러오기는 바로 답한다.
(function () {
  'use strict';
  var init = window.__NEL_INIT || {};
  var handler = window.webkit && window.webkit.messageHandlers && window.webkit.messageHandlers.nel;
  if (!handler) return; // 앱 밖(일반 브라우저)이면 아무것도 하지 않는다

  var state = {
    data: typeof init.data === 'string' ? init.data : '',
    bg: init.bg || {},
    prefs: init.prefs || {}
  };
  function send(msg) {
    try { handler.postMessage(msg); } catch (e) {}
  }

  window.DojangNative = {
    webToast: true, // 복사 같은 알림은 화면이 직접 띄운다
    load: function () { return state.data; },
    save: function (json) { state.data = String(json); send({ t: 'save', v: state.data }); },
    isDark: function () { return !!init.dark; },
    share: function (text) { send({ t: 'share', v: String(text) }); },
    copy: function (text) { send({ t: 'copy', v: String(text) }); },
    loadBg: function (slot) { return state.bg[slot] || ''; },
    saveBg: function (slot, dataUrl) {
      state.bg[slot] = dataUrl ? String(dataUrl) : '';
      send({ t: 'bg', slot: String(slot), v: state.bg[slot] });
      return true;
    },
    getPref: function (key) { return state.prefs[key] || ''; },
    setPref: function (key, value) {
      state.prefs[key] = String(value);
      send({ t: 'pref', k: String(key), v: String(value) });
    }
  };
})();
