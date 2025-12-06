// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails";
import "controllers";

// TODO: Remove this
function registerServiceWorker() {
    console.log("Registering service worker");

    window.addEventListener("load", () => {
        navigator.serviceWorker.register("/service-worker.js").then((register) => {
            console.log("Service worker registered:", registration);
        }).catch((error) => {
            console.error("Service worker registration failed:", error);
        });
    });
}

if ("serviceWorker" in navigator) {
    registerServiceWorker();
}