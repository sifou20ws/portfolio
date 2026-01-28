// Replaces the caching service worker that earlier versions of the site
// installed. Browsers re-check this file on every visit; when a returning
// visitor gets it, it takes over immediately, deletes Flutter's caches,
// unregisters itself and reloads open tabs once, so they load the latest
// deploy straight from the network from then on.
self.addEventListener('install', () => self.skipWaiting());

self.addEventListener('activate', (event) => {
  event.waitUntil((async () => {
    const keys = await caches.keys();
    await Promise.all(
      keys.filter((k) => k.startsWith('flutter-')).map((k) => caches.delete(k)),
    );
    await self.registration.unregister();
    const clients = await self.clients.matchAll({ type: 'window' });
    clients.forEach((client) => client.navigate(client.url));
  })());
});
