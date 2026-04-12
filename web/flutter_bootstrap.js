{{flutter_js}}
{{flutter_build_config}}

_flutter.loader.load({
  serviceWorker: {
    serviceWorkerVersion: {{flutter_service_worker_version}},
  },
  onEntrypointLoaded: async function(engineInitializer) {
    const appRunner = await engineInitializer.initializeEngine();
    await appRunner.runApp();
  },
});

// Auto-reload when a new service worker version takes control,
// ensuring users always run the latest deployed build.
if ('serviceWorker' in navigator) {
  let reloading = false;
  navigator.serviceWorker.addEventListener('controllerchange', () => {
    if (!reloading) {
      reloading = true;
      window.location.reload();
    }
  });

  const triggerSkipWaiting = (worker) => {
    if (worker) {
      worker.postMessage({ type: 'SKIP_WAITING' });
    }
  };

  navigator.serviceWorker.ready.then((registration) => {
    // Activate any already-waiting worker immediately
    triggerSkipWaiting(registration.waiting);

    registration.addEventListener('updatefound', () => {
      const newWorker = registration.installing;
      if (!newWorker) return;
      newWorker.addEventListener('statechange', () => {
        if (newWorker.state === 'installed' && registration.active) {
          triggerSkipWaiting(newWorker);
        }
      });
    });
  });
}
