export interface Env {
  CONFIG: KVNamespace;
}

export default {
  async fetch(request: Request, env: Env, ctx: ExecutionContext): Promise<Response> {
    const url = new URL(request.url);
    const pane = "rosa";
    const domain = "rosa.wsdenterprisesworldwide.com";

    if (url.pathname === "/api/status") {
      const laneInfo = await env.CONFIG.get("lane:TCAR") || "TCAR";
      return Response.json({ pane, status:       return Response.json({ pane, status:       return Response.json({ pane, status:       rurn Response.json({ pane, stat  : "operational", domain });
  },
};
