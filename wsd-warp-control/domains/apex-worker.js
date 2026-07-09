// WSD Apex Domain Worker
// Routes requests to the correct sub-platform based on subdomain
// Serves /api/registry and /api/health endpoints
// Zero paid Cloudflare features — Free tier only
// KV used only for config/status — low-frequency reads

// Registry data is embedded statically to avoid KV dependency for read-only lists
// KV is used only for dynamic status overrides or config changes

const SUB_PLATFORMS = [
  { name: "priya", domain: "priya.wsdenterprisesworldwide.com", role: "Codex WSD Control lane" },
  { name: "aisha", domain: "aisha.wsdenterprisesworldwide.com", role: "Codex WSD Control lane backup" },
  { name: "mei", domain: "mei.wsdenterprisesworldwide.com", role: "Documents Codex lane" },
  { name: "amara", domain: "amara.wsdenterprisesworldwide.com", role: "WSD WARP Control primary lane" },
  { name: "zara", domain: "zara.wsdenterprisesworldwide.com", role: "WARP AI Orchestrator lane" },
  { name: "nia", domain: "nia.wsdenterprisesworldwide.com", role: "WSD enterprise lane" },
  { name: "fatima", domain: "fatima.wsdenterprisesworldwide.com", role: "WSD backups lane" },
  { name: "keiko", domain: "keiko.wsdenterprisesworldwide.com", role: "WSD build lane" },
  { name: "lena", domain: "lena.wsdenterprisesworldwide.com", role: "WSD jails / quarantine lane" },
  { name: "maya", domain: "maya.wsdenterprisesworldwide.com", role: "Cloudflare tunnel lane" },
  { name: "tala", domain: "tala.wsdenterprisesworldwide.com", role: "Helpdesk AI lane" },
  { name: "rosa", domain: "rosa.wsdenterprisesworldwide.com", role: "TCAR lane" },
  { name: "imani", domain: "imani.wsdenterprisesworldwide.com", role: "NEXGEN sync lane" },
  { name: "jin", domain: "jin.wsdenterprisesworldwide.com", role: "AI growth lane" },
  { name: "yuki", domain: "yuki.wsdenterprisesworldwide.com", role: "WSD production core lane" },
  { name: "chandra", domain: "chandra.wsdenterprisesworldwide.com", role: "WSD total infrastructure lane" },
  { name: "soraya", domain: "soraya.wsdenterprisesworldwide.com", role: "Codex worktree lane" },
  { name: "ananya", domain: "ananya.wsdenterprisesworldwide.com", role: "WARP tab configs lane" },
  { name: "hana", domain: "hana.wsdenterprisesworldwide.com", role: "Codex primary lane" },
  { name: "aya", domain: "aya.wsdenterprisesworldwide.com", role: "Documents general lane" },
];

const DOMAINS = [
  { domain: "wsdenterprisesworldwide.com", layer: 1, tier: "apex", repo: "wsd-warp-control", status: "live" },
  { domain: "wsdenterpirsesworldwidecloudservices.cloud", layer: 2, tier: "satellite", repo: "wsd-cloudservices-site", status: "live" },
  { domain: "lebeautiful-botanicals.us.com", layer: 2, tier: "satellite", repo: "lebeautiful-botanicals-site", status: "live" },
  { domain: "acwyatt.com", layer: 2, tier: "satellite", repo: "acwyatt-site", status: "live" },
  { domain: "neighborhoodcarspa.us.com", layer: 2, tier: "satellite", repo: "neighborhood-carspa-site", status: "live" },
  { domain: "vokdesigngarage.com", layer: 2, tier: "satellite", repo: "vok-design-garage-site", status: "live" },
  { domain: "cumseeme.live", layer: 2, tier: "satellite", repo: "cumseeme-live-jail", status: "live", isolation: "jailed" },
];

const CORS_HEADERS = {
  "Content-Type": "application/json",
  "Access-Control-Allow-Origin": "https://wsdenterprisesworldwide.com",
  "Access-Control-Allow-Methods": "GET, OPTIONS",
  "Cache-Control": "public, max-age=60",
};

function jsonResponse(body, status = 200) {
  return new Response(JSON.stringify(body, null, 2), { status, headers: CORS_HEADERS });
}

function notFound(path) {
  return jsonResponse({ error: "Not found", path }, 404);
}

function getSubdomain(hostname) {
  const apex = "wsdenterprisesworldwide.com";
  if (!hostname || !hostname.endsWith(apex)) return null;
  const prefix = hostname.slice(0, -(apex.length + 1)); // remove '.wsdenterprisesworldwide.com'
  if (!prefix || prefix.includes(".")) return null; // only single-level subdomains
  return prefix;
}

export default {
  async fetch(request, env) {
    const url = new URL(request.url);
    const path = url.pathname;
    const hostname = url.hostname;

    if (request.method === "OPTIONS") {
      return new Response(null, { status: 204, headers: CORS_HEADERS });
    }

    // Only handle GET requests for this static/dynamic hybrid worker
    if (request.method !== "GET") {
      return jsonResponse({ error: "Method not allowed" }, 405);
    }

    // API endpoints (served on any hostname or apex)
    if (path === "/api/registry") {
      // Check KV for any dynamic overrides (low-frequency read)
      let kvRegistry = null;
      try {
        if (env.WARP_CONFIG) {
          kvRegistry = await env.WARP_CONFIG.get("registry_override", { type: "json" });
        }
      } catch {
        kvRegistry = null;
      }

      return jsonResponse({
        meta: {
          platform: "WSD Enterprise Apex",
          owner: "William Scott Davis II",
          timestamp: new Date().toISOString(),
          registry_gate: "closed",
          quarantine: "active",
          cumseeme_live_isolation: "jailed",
        },
        sub_platforms: SUB_PLATFORMS.map(sp => ({
          ...sp,
          worker: `wsd-${sp.name}-platform`,
          status: "operational",
        })),
        domains: DOMAINS,
        kv_override_present: kvRegistry !== null,
      });
    }

    if (path === "/api/health") {
      return jsonResponse({
        status: "healthy",
        platform: "WSD Enterprise Apex",
        domain: "wsdenterprisesworldwide.com",
        timestamp: new Date().toISOString(),
        sub_platforms_total: SUB_PLATFORMS.length,
        domains_total: DOMAINS.length,
      });
    }

    // Subdomain routing
    const subdomain = getSubdomain(hostname);
    if (subdomain) {
      const platform = SUB_PLATFORMS.find(sp => sp.name === subdomain);
      if (platform) {
        // For a real routing scenario, this would proxy or redirect
        // In the free tier, we return a JSON response indicating the target
        return jsonResponse({
          routed: true,
          subdomain: platform.name,
          target_domain: platform.domain,
          worker: `wsd-${platform.name}-platform`,
          role: platform.role,
          status: "operational",
          note: "In production, this would proxy to the sub-platform worker. Deploy the target worker and bind a route to serve traffic directly.",
        });
      }
      return jsonResponse({ error: "Unknown subdomain", subdomain }, 404);
    }

    // Apex domain root
    if (hostname === "wsdenterprisesworldwide.com" && (path === "/" || path === "/status")) {
      return jsonResponse({
        platform: "WSD Enterprise Apex",
        domain: "wsdenterprisesworldwide.com",
        owner: "William Scott Davis II",
        phase: 6,
        registry_gate: "closed",
        quarantine: "active",
        cumseeme_live_isolation: "jailed",
        sub_platforms: SUB_PLATFORMS.length,
        domains: DOMAINS.length,
        timestamp: new Date().toISOString(),
      });
    }

    return notFound(path);
  },
};
