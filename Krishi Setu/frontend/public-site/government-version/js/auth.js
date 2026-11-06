/* ============================================================
   KRISHI SETU — PUBLIC SITE ⇄ PLATFORM AUTH BRIDGE
   ------------------------------------------------------------
   One product, one authentication system, one Supabase session.

   This file does NOT create a second auth system. It only READS
   the existing Supabase session that the Krishi Setu application
   (frontend/LAST_GOV_API_GRAPHS_FINAL.html) created, so:

     - A logged-in user sees "Go to Dashboard" and jumps straight
       into the app — no second login.
     - A guest sees "Open Platform" and lands on the existing
       login screen.

   It also rewrites every public → platform link from the single
   KS.platformUrl config in js/data.js, so there are no hardcoded
   platform paths anywhere else. Update that one value when
   deploying.

   The Supabase project config below is the SAME project the
   application uses. The anon (publishable) key is safe to embed
   in a public website by design — it is not a secret.
   ============================================================ */
(function () {
  'use strict';

  /* Same Supabase project as the application dashboard. */
  var CONFIG = {
    supabaseUrl: 'https://lryhcszcmhlrzrbrsces.supabase.co',
    supabaseAnonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImxyeWhjc3pjbWhscnpyYnJzY2VzIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODc3MjczMjIsImV4cCI6MjEwMzMwMzMyMn0.n-yN_Ag2o_9OccmwTtrjgQ4gGX0YM2P50M4W0lI-4GA',
    supabaseCdn: 'https://cdn.jsdelivr.net/npm/@supabase/supabase-js@2'
  };

  var AUTHED_LABEL = 'Go to Dashboard →';
  var links = [];

  /* Single source of truth for the platform destination (js/data.js).
     The ?intent=login param tells the app to show its existing login
     screen for guests (authenticated visitors skip it automatically).
     When running locally (file://, localhost, 127.0.0.1, or direct static paths),
     we navigate directly to the physical application file so the button works
     in standard local web servers (Python, Node, Live Server) and offline. */
  function platformUrl() {
    var isLocal = typeof window !== 'undefined' && (
      window.location.protocol === 'file:' ||
      window.location.hostname === 'localhost' ||
      window.location.hostname === '127.0.0.1' ||
      window.location.hostname === '' ||
      window.location.pathname.indexOf('government-version') !== -1
    );
    if (isLocal) {
      return '../../LAST_GOV_API_GRAPHS_FINAL.html';
    }
    var p = (window.KS && KS.platformUrl) || '/platform/';
    if (typeof p !== 'string') p = '/platform/';
    if (p.endsWith('.html')) return p;
    return p.endsWith('/') ? p : p + '/';
  }
  function platformHref(authed) {
    /* Authenticated visitors do NOT carry ?intent=login: the app's
       stored-session boot goes straight to the dashboard (and its
       pre-paint guard keeps the login screen from flashing). Guests
       need the intent param so the app shows its existing login. */
    if (authed) return platformUrl();
    var base = platformUrl();
    var sep = base.indexOf('?') === -1 ? '?' : '&';
    return base + sep + 'intent=login';
  }

  function collectLinks() {
    links = Array.prototype.slice.call(
      document.querySelectorAll('a[data-i18n-authed], a[href*="LAST_GOV_API_GRAPHS_FINAL.html"], a[href*="/platform/"]')
    );
    links.forEach(function (a) {
      if (!a.dataset.defaultLabel) a.dataset.defaultLabel = a.textContent.trim();
    });
  }

  function applyState(authed) {
    collectLinks();
    links.forEach(function (a) {
      a.href = platformHref(authed);
      a.dataset.authState = authed ? 'in' : 'out';
      if (authed) {
        /* Localize the authenticated CTA when the language module is loaded. */
        a.textContent = (window.KS_I18N && KS_I18N.t) ? KS_I18N.t('cta_authed', AUTHED_LABEL) : AUTHED_LABEL;
        a.setAttribute('aria-label', 'Go to your Krishi Setu dashboard');
      } else {
        a.textContent = a.dataset.defaultLabel;
        a.setAttribute('aria-label', 'Open the Krishi Setu platform');
      }
    });
  }

  function initClient() {
    if (!window.supabase || !window.supabase.createClient) return;
    var client;
    try {
      client = window.supabase.createClient(CONFIG.supabaseUrl, CONFIG.supabaseAnonKey);
    } catch (e) { return; }

    client.auth.getSession().then(function (res) {
      applyState(!!(res && res.data && res.data.session));
    }).catch(function () { /* offline — keep the guest "Open Platform" label */ });

    /* Live sync: log in/out in the app (another tab) updates this page too. */
    client.auth.onAuthStateChange(function (_evt, session) {
      applyState(!!session);
    });
    window.addEventListener('storage', function (e) {
      if (e.key && e.key.indexOf('sb-') === 0) {
        client.auth.getSession().then(function (res) {
          applyState(!!(res && res.data && res.data.session));
        }).catch(function () {});
      }
    });
  }

  function boot() {
    /* Immediately point every platform CTA at the single config value. */
    collectLinks();
    links.forEach(function (a) { a.href = platformHref(); });

    if (typeof window.supabase === 'undefined' || !window.supabase.createClient) {
      var s = document.createElement('script');
      s.src = CONFIG.supabaseCdn;
      s.onload = initClient;
      s.onerror = function () { /* CDN unreachable — keep default labels, links still work */ };
      document.head.appendChild(s);
    } else {
      initClient();
    }
  }

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', boot);
  } else {
    boot();
  }
})();