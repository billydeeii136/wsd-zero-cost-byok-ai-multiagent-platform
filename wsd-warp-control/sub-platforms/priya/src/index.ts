export interface Env {
  CONFIG: KVNamespace;
}

export default {
  async fetch(request: Request, env: Env, ctx: ExecutionContext): Promise<Response> {
    const url = new URL(request.url);
    if (url.pathname === "/api/status") {
      const lane = await env.CONFIG.get("lane").catch(() => "codex-wsd-control");
      return new Response(JSON.stringify({ pane: "priya", status: "operational", domain: "priya.wsdenterprisesworldwide.com", lane }), {
        headers: { "Content-Type": "application/json" },
      });
    }
    return new Response("Not Found", { status: 404 });
  },
};
