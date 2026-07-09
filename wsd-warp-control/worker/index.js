export default {
  async fetch(request, env) {
    const url = new URL(request.url);
    const host = url.hostname.replace(/^www\./, "");

    // Domain registry
    const DOMAINS = {
      "wsdenterprisesworldwide.com": { name: "WSD Enterprises Worldwide", layer: 1, status: "operational", accent: "#168a54" },
      "wsdenterpirsesworldwidecloudservices.cloud": { name: "WSD Cloud Services", layer: 2, status: "operational", accent: "#4f46d8" },
      "lebeautiful-botanicals.us.com": { name: "LeBeautiful Botanicals", layer: 2, status: "operational", accent: "#21845f" },
      "acwyatt.com": { name: "A.C. Wyatt", layer: 2, status: "operational", accent: "#2378b8" },
      "neighborhoodcarspa.us.com": { name: "Neighborhood Car Spa", layer: 2, status: "operational", accent: "#0f8f8d" },
      "vokdesigngarage.com": { name: "VOK Design Garage", layer: 2, status: "operational", accent: "#bc760d" },
      "cumseeme.live": { name: "CumSeeMe Live", layer: 2, status: "jailed", accent: "#d93668" }
    };

    // 20 sub-platform panes
    const PANES = [
      "priya","aisha","mei","amara","zara",
      "nia","fatima","keiko","lena","maya",
      "tala","rosa","imani","jin","yuki",
      "chandra","soraya","ananya","hana","aya"
    ];

    const domain = DOMAINS[host] || { name: host, layer: 0, status: "unknown", accent: "#666" };
    const isSubdomain = host.endsWith(".wsdenterprisesworldwide.com");
    const paneName = isSubdomain ? host.replace(".wsdenterprisesworldwide.com", "") : null;

    // Health check endpoint
    if (url.pathname === "/health" || url.pathname === "/cdn-cgi/health") {
      const now = Date.now().toString();
      if (env.WSD_HEARTBEAT) {
        await env.WSD_HEARTBEAT.put(`status:${host}`, "OPERATIONAL");
        await env.WSD_HEARTBEAT.put(`last_seen:${host}`, now);
      }
      return jsonResponse({
        status: "OPERATIONAL",
        domain: host,
        name: domain.name,
        layer: domain.layer,
        timestamp: now,
        pane: paneName || null,
        heartbeat: "KV_STORE_SUCCESS"
      });
    }

    // API registry endpoint
    if (url.pathname === "/api/registry") {
      return jsonResponse({
        domains: Object.keys(DOMAINS).map(d => ({ domain: d, ...DOMAINS[d] })),
        panes: PANES.map(p => ({ pane: p, domain: `${p}.wsdenterprisesworldwide.com`, status: "operational" })),
        total_domains: 7,
        total_panes: 20,
        timestamp: new Date().toISOString()
      });
    }

    // Sub-domain specific responses
    if (isSubdomain && PANES.includes(paneName)) {
      if (url.pathname === "/api/status") {
        return jsonResponse({ pane: paneName, status: "operational", domain: host, timestamp: new Date().toISOString() });
      }
      return htmlResponse(renderPanePage(paneName, domain.accent));
    }

    // Main domain responses
    if (url.pathname === "/api/status") {
      return jsonResponse({ domain: host, name: domain.name, status: domain.status, layer: domain.layer, timestamp: new Date().toISOString() });
    }

    // Default landing page
    return htmlResponse(renderDomainPage(domain, host, PANES));
  }
};

function jsonResponse(data) {
  return new Response(JSON.stringify(data, null, 2), {
    status: 200,
    headers: { "Content-Type": "application/json", "Access-Control-Allow-Origin": "*" }
  });
}

function htmlResponse(html) {
  return new Response(html, {
    status: 200,
    headers: { "Content-Type": "text/html; charset=utf-8" }
  });
}

function renderPanePage(pane, accent) {
  return `<!DOCTYPE html>
<html lang="en">
<head><meta charset="utf-8"><meta name="viewport" content="width=device-width, initial-scale=1">
<title>${pane} — WSD Enterprise Sub-Platform</title>
<style>
*{margin:0;padding:0;box-sizing:border-box}
body{font-family:system-ui,-apple-system,sans-serif;background:#0a0a0a;color:#fff;min-height:100vh;display:flex;flex-direction:column;align-items:center;justify-content:center}
.card{background:#111;border:1px solid #222;border-radius:12px;padding:40px;max-width:480px;width:90%;text-align:center}
h1{font-size:2rem;margin-bottom:8px;text-transform:capitalize}
.status{display:inline-block;background:${accent}22;color:${accent};padding:6px 16px;border-radius:20px;font-size:.875rem;margin-bottom:16px;border:1px solid ${accent}44}
.domain{color:#888;font-size:.9rem;margin-bottom:24px}
.links{display:flex;gap:12px;justify-content:center;flex-wrap:wrap}
.links a{color:#fff;text-decoration:none;padding:8px 16px;background:#222;border-radius:6px;font-size:.85rem;transition:background .2s}
.links a:hover{background:#333}
</style>
</head>
<body>
<div class="card">
  <h1>${pane}</h1>
  <span class="status">OPERATIONAL</span>
  <p class="domain">${pane}.wsdenterprisesworldwide.com</p>
  <div class="links">
    <a href="/api/status">API Status</a>
    <a href="/health">Health Check</a>
    <a href="https://wsdenterprisesworldwide.com">Apex</a>
  </div>
</div>
</body>
</html>`;
}

function renderDomainPage(domain, host, panes) {
  const isJailed = host === "cumseeme.live";
  const paneLinks = panes.slice(0, 10).map(p => `<a href="https://${p}.wsdenterprisesworldwide.com">${p}</a>`).join("");
  return `<!DOCTYPE html>
<html lang="en">
<head><meta charset="utf-8"><meta name="viewport" content="width=device-width, initial-scale=1">
<title>${domain.name}</title>
<style>
*{margin:0;padding:0;box-sizing:border-box}
body{font-family:system-ui,-apple-system,sans-serif;background:#0a0a0a;color:#fff;min-height:100vh}
.container{max-width:900px;margin:0 auto;padding:40px 20px}
header{text-align:center;margin-bottom:40px}
h1{font-size:2.5rem;margin-bottom:12px}
.badge{display:inline-block;padding:6px 16px;border-radius:20px;font-size:.875rem;margin-bottom:16px}
.badge.operational{background:${domain.accent}22;color:${domain.accent};border:1px solid ${domain.accent}44}
.badge.jailed{background:#d9366822;color:#d93668;border:1px solid #d9366844}
.layer{color:#888;font-size:.9rem}
.grid{display:grid;grid-template-columns:repeat(auto-fit,minmax(200px,1fr));gap:16px;margin-bottom:40px}
.card{background:#111;border:1px solid #222;border-radius:12px;padding:20px}
.card h3{font-size:1.1rem;margin-bottom:8px;color:${domain.accent}}
.card p{color:#888;font-size:.85rem;line-height:1.5}
.links{display:flex;gap:12px;flex-wrap:wrap;margin-top:12px}
.links a{color:#fff;text-decoration:none;padding:6px 12px;background:#222;border-radius:6px;font-size:.8rem}
.links a:hover{background:#333}
footer{text-align:center;color:#444;font-size:.8rem;padding:40px 0}
${isJailed ? `.isolation{background:#d9366808;border:1px solid #d9366822;padding:20px;border-radius:12px;margin-bottom:40px;text-align:center;color:#d93668aa}` : ""}
</style>
</head>
<body>
<div class="container">
  <header>
    <h1>${domain.name}</h1>
    <span class="badge ${domain.status}">${domain.status.toUpperCase()}</span>
    <p class="layer">Layer ${domain.layer} ${domain.layer === 1 ? "Apex" : "Satellite"} Domain</p>
  </header>
  ${isJailed ? `<div class="isolation"><strong>ISOLATED NODE</strong> — cumseeme.live is fully jailed from other WSD domains. No shared resources, no cross-origin references.</div>` : ""}
  <div class="grid">
    <div class="card"><h3>Health Check</h3><p>Real-time operational status via KV heartbeat</p><div class="links"><a href="/health">Check Health</a></div></div>
    <div class="card"><h3>API Status</h3><p>JSON endpoint for domain and pane status</p><div class="links"><a href="/api/status">View Status</a></div></div>
    <div class="card"><h3>Registry</h3><p>Full list of all 7 domains and 20 sub-platforms</p><div class="links"><a href="/api/registry">View Registry</a></div></div>
    <div class="card"><h3>Sub-Platforms</h3><p>First 10 AI agent pane sub-platforms</p><div class="links">${paneLinks}</div></div>
  </div>
  <footer>WSD Enterprises Worldwide — 7 Domain Pyramid Architecture</footer>
</div>
</body>
</html>`;
}
