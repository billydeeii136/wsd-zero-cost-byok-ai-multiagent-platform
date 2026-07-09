export default {
  async fetch(request: Request, env: any, ctx: ExecutionContext): Promise<Response> {
    const url = new URL(request.url);
    if (url.pathname === "/api/status") {
      return new Response(
        JSON.stringify({ domain: "neighborhoodcarspa.us.com", status: "live" }),
        { headers: { "Content-Type": "application/json" } }
      );
    }
    return env.ASSETS.fetch(request);
  },
};