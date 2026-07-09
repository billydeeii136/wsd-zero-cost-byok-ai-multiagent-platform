export interface Env {
  CONFIG: KVNamespace;
}

export default {
  async fetch(request: Request, env: Env, ctx: ExecutionContext): Promise<Response> {
    const url = new URL(request.url);
    const pane = "tala";
    const domain = "tala.wsdenterprisesworldwide.com";

    if (url.pathname === "/api/status") {
      const laneInfo = await env.CONFIG.get("lane:helpdesk_ai") || "helpdesk_ai";
      return Response.json({ pane, status: "operational", domain, lane: laneInfo, timestamp: new Date().toISOString() });
    }

    return Response.json({ pane, status: "operational", domain });
  },
};
