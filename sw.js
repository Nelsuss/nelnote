// NEL NOTE 오프라인 저장
// 앱 파일을 휴대폰에 저장해 두고 먼저 그걸로 연다. 인터넷이 되면 뒤에서 새 파일을 받아 두었다가 다음에 열 때 쓴다.
var CACHE = 'nelnote-v1';
var FILES = [
  './',
  'index.html',
  'nel.webp',
  'manifest.webmanifest',
  'apple-touch-icon.png',
  'icon-192.png',
  'icon-512.png',
  'icon-maskable-512.png'
];

self.addEventListener('install', function (event) {
  event.waitUntil(
    caches.open(CACHE)
      .then(function (cache) { return cache.addAll(FILES); })
      .then(function () { return self.skipWaiting(); })
  );
});

self.addEventListener('activate', function (event) {
  event.waitUntil(
    caches.keys()
      .then(function (keys) {
        return Promise.all(keys.filter(function (k) { return k !== CACHE; }).map(function (k) { return caches.delete(k); }));
      })
      .then(function () { return self.clients.claim(); })
  );
});

self.addEventListener('fetch', function (event) {
  var req = event.request;
  if (req.method !== 'GET' || new URL(req.url).origin !== self.location.origin) return;

  var fresh = fetch(req.url, { cache: 'no-cache' }).then(function (res) {
    if (res && res.ok) {
      var copy = res.clone();
      caches.open(CACHE).then(function (cache) { return cache.put(req, copy); });
    }
    return res;
  });

  event.respondWith(
    caches.match(req, { ignoreSearch: true })
      .then(function (hit) { return hit || fresh; })
      .catch(function () { return fresh; })
  );
  event.waitUntil(fresh.then(function () {}, function () {}));
});
