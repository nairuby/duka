// Invoke service worker
// self.addEventListener("install", async (event) => {
//   event.waitUntil(caches.open("v1").then((cache) => cache.addAll(["/", "/offline"])))
// })
//
// self.addEventListener("fetch", (event) => {
//   event.respondWith(
//     caches.match(event.request).then((response) => {
//       return response || fetch(event.request).catch(() => caches.match("/offline"))
//     })
//   )
// })

const CACHE_NAME = "duka-v1";
const OFFLINE_URL = "/offline";
const ASSETS_TO_CACHE = [
  OFFLINE_URL,
  "/icon.png",
  "/icon.svg",
  "https://cdn.tailwindcss.com",
  "https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css"
];

self.addEventListener("install", (event) => {
  event.waitUntil(
    (async () => {
      const cache = await caches.open(CACHE_NAME);
      await cache.addAll(ASSETS_TO_CACHE);
    })()
  );
  // Force the waiting service worker to become the active service worker.
  self.skipWaiting();
});

self.addEventListener("activate", (event) => {
  event.waitUntil(
    (async () => {
      // Enable navigation preload if it's supported.
      if ("navigationPreload" in self.registration) {
        await self.registration.navigationPreload.enable();
      }
      // Delete old caches
      const cacheNames = await caches.keys();
      await Promise.all(
          cacheNames.map((cacheName) => {
              if (cacheName !== CACHE_NAME) {
                  return caches.delete(cacheName);
              }
          })
      );
    })()
  );
  // Tell the active service worker to take control of the page immediately.
  self.clients.claim();
});

self.addEventListener("fetch", (event) => {
  // We only want to handle requests if they are navigations or critical assets
  if (event.request.mode === "navigate") {
    event.respondWith(
      (async () => {
        try {
          // First, try to use the navigation preload response if it's supported.
          const preloadResponse = await event.preloadResponse;
          if (preloadResponse) {
            return preloadResponse;
          }

          // Always try the network first.
          const networkResponse = await fetch(event.request);
          return networkResponse;
        } catch (error) {
          // catch is only triggered if an exception is thrown, which is likely
          // due to a network error.
          // If fetch() returns a valid HTTP response with an error code (e.g., 404),
          // it does NOT fall into the catch() block.
          console.log("Fetch failed; returning offline page instead.", error);

          const cache = await caches.open(CACHE_NAME);
          const cachedResponse = await cache.match(OFFLINE_URL);
          return cachedResponse;
        }
      })()
    );
  }
});
