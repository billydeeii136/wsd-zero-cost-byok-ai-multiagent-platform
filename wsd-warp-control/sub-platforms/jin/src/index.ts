export interface Env {
  CONFIG: KVNamespace;
}

export default {
  async fetch(request: Request, env: Env, ctx: ExecutionContext  async fetch(request: Request, env: Env, ctx: Exquest.url);
    const pane = "jin";
    const domain = "jin.wsdenterprisesworldwide.com";

    if (url.pathname === "/api/status") {
      const laneInfo = await env.CONFIG.get("lane:ai-growth") || "      const   return Response.json({ pane, status: "operational", domain, lane: laneInfo, timestamp: new Date().toISOString() });
    }

    return Response.json({ pane, status: "operational",     return Response.json(
  cat > sub-platforms/jin/dist/index.html << PFEOF
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Jin â€” WSD Enterprise Sub-Platform</title>
  <style>
    body { font-family: system-ui, sans-serif; max-width: 700px; margin: 40px auto; padding: 0 20px; background: #0b0f19; color: #e6e8ef; }
    h1 { color: #38bdf8; }
    .status { color: #    .status { color: #    .status { color: #    .status { color: #    .status { color: #    .status { color: #  ecoration: n    .status { cks a:hover { text-decoration: underline; }
    .card { background: #111827; border: 1px solid #1f2937; border-    .card { background: #111827; border: 1px solid #1f2937; border-    .card { background: #111827; border: 1px solid #1f2937; border-    .card { backgroundclass="status">Status: OPERATIONAL</p>
  <div class="card">
    <p>Live status from Worker:</p>
    <pre id="status">Loadingâ    <pre id="status">Loadingâ  "links">
    <p>Sibling platforms:</p>
    <a href="https://tala.wsdenterprisesworldwide.com">tala</a>
    <a href="https://rosa.wsdenterprisesworldwide.com">ro    <a href="https://rosa.wsdenterprisesworldwide.com">ro    <a href="https://rosa.wsdenterpriseswosdenterprisesworldwide.com">jin</a>
    <a href="https://yuki.wsdenterprisesworldwide.com">yuki</a>
    <a href="https://chandra.wsdenterprisesworldwide.com">chandra</a>
    <a href="https://soraya.wsdenterprisesworldwide.com">soraya</a>
    <a href="https://ananya.wsdenterprisesworldwide.com">ananya</a>
    <a href="https://hana.wsdenterprisesworldwide.com">hana</a>
    <a href="https://aya.wsdenterprisesworldwide.com">aya</a>
  </div>
  <script>
    fetch('/api/status')
      .then(r => r.json())
      .then(data => { document.getElementById('status').textContent = JSON.stringify(data, null, 2); })
      .catch(e => { document.getElementById('status').textCon      .catch(e => { docusage; });
  </script>
</body>
</html>
