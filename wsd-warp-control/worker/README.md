# WARP Isolation Worker

This is the Cloudflare Worker serving as the control layer for the WARP Isolation Platform at `warp.wsdenterprisesworldwide.com`.

## Purpose
- Gatekeeper for AI model registry state
- WARP instance heartbeat and status
- Minimal KV config storage (low-frequency only)
- Phase 6/7 AI systems control platform scaffold

## Cost Constraints
- Zero paid Cloudflare upgrades
- KV used only for config/status, never high-frequency
- Workers used for dynamic/admin/API logic only

## Deployment

```bash
cd worker
wrangler deploy
```

Current non-deploying validation:

```bash
wrangler deploy --dry-run
```

The custom-domain route is configured as `warp.wsdenterprisesworldwide.com` because current Wrangler rejects wildcard paths on `custom_domain = true` routes.

`WARP_CONFIG` is assigned to WARP-specific production and preview KV namespaces in `wrangler.toml`.

Type checking:

```bash
npm run typecheck
```

When local npm dependencies are installed, this runs `tsc --noEmit`. If npm registry access is unavailable and `tsc` is not installed, it falls back to `wrangler deploy --dry-run` so Worker syntax, bindings, and deploy config are still validated.

Current shared repair helpers:

```bash
cloudflare-kv-namespace-fix
key-token-status
github-auth-status
```

Run those from normal Terminal when validating WARP auth state. Do not store raw token values in this repo or in Worker source.

## Routes

| Route | Method | Purpose |
|---|---|---|
| `/` | GET | Health check / platform status |
| `/status` | GET | Registry gate state |
| `/config` | GET | KV-stored platform config (low-frequency) |

Co-Authored-By: Oz <oz-agent@warp.dev>
