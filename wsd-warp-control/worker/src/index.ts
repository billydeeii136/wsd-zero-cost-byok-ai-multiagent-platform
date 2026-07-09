import type { KVNamespace } from "@cloudflare/workers-types";

export interface Env {
	WARP_CONFIG: KVNamespace;
}

export default {
	async fetch(request: Request, env: Env): Promise<Response> {
		const url = new URL(request.url);
		const path = url.pathname;

		// CORS headers for isolated subdomain usage
		const headers = {
			"Content-Type": "application/json",
			"Access-Control-Allow-Origin": "https://wsdenterprisesworldwide.com",
			"Access-Control-Allow-Methods": "GET, OPTIONS",
		};

		if (request.method === "OPTIONS") {
			return new Response(null, { status: 204, headers });
		}

		if (path === "/" || path === "/status") {
			// Health / gatekeeper status
			const body = JSON.stringify({
				platform: "WARP Isolation Control",
				domain: "warp.wsdenterprisesworldwide.com",
				owner: "William Scott Davis II",
				phase: 6,
				registry_gate: "closed",
				quarantine: "active",
				cumseeme_live_isolation: "jailed",
				timestamp: new Date().toISOString(),
			});
			return new Response(body, { status: 200, headers });
		}

		if (path === "/config") {
			// Low-frequency KV read only
			let config = null;
			try {
				config = await env.WARP_CONFIG.get("platform_config", { type: "json" });
			} catch {
				config = null;
			}
			const body = JSON.stringify({
				config_present: config !== null,
				config: config ?? {},
			});
			return new Response(body, { status: 200, headers });
		}

		return new Response(JSON.stringify({ error: "Not found" }), { status: 404, headers });
	},
} as ExportedHandler<Env>;
