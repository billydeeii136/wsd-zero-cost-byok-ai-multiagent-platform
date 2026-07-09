# WSD Enterprise Architecture — 7-Domain Pyramid

## Overview

This document defines the domain hierarchy, isolation model, and Cloudflare deployment strategy for all WSD enterprises properties.

## Layer 1 — Apex Domain

**Domain:** `wsdenterprisesworldwide.com`
**Role:** Primary enterprise apex. All sub-platforms and control layers originate here.
**Sub-platforms:**
- `warp.wsdenterprisesworldwide.com` — WARP Isolation Control Platform (this project)
- Future: API gateway, admin dashboard, registry control

**Infrastructure:**
- Registrar: Porkbun
- DNS: Cloudflare Free
- Hosting: Cloudflare Pages (static) + Cloudflare Workers (dynamic/control)
- Tunnel: Cloudflare Tunnel for local dev/admin recovery
- TLS: 1.3 + post-quantum encryption via Cloudflare edge

## Layer 2 — Satellite Domains

| Domain | Tier | Status | Worker / Pages |
|---|---|---|---|
| `wsdenterpirsesworldwidecloudservices.cloud` | Layer 2 | Active | TBD |
| `lebeautiful-botanicals.us.com` | Layer 2 | Active | TBD |
| `acwyatt.com` | Layer 2 | Active | TBD |
| `neighborhoodcarspa.us.com` | Layer 2 | Active | TBD |
| `vokdesigngarage.com` | Layer 2 | Active | TBD |
| `cumseeme.live` | **Jailed** | Isolated | Separate Cloudflare zone/account |

## Isolation Rules

### cumseeme.live Stigma Jail

`cumseeme.live` is an adult entertainment platform. Due to platform stigma and risk of cross-contamination:
- **Separate Cloudflare zone** or account-level isolation
- **No shared Workers, KV, D1, or R2** with other 6 domains
- **No cross-origin references** from apex or layer-2 to `cumseeme.live`
- **Tunnel** used only for local admin, never for public routing
- All AI model registry, gatekeeping, and scoring logic from `cumseeme.live` is quarantined in its own control lane

### WARP Isolation Platform Jail

This repository (`wsd-warp-control`) is:
- **GitHub-private** and disconnected from all other repos
- **WARP-only** — no non-WARP code, issues, or workflows
- **AI-agent-centric** — all Warp panes in this project are agent tabs
- **Manual sync** — AI does not own an auto-push loop; the user pushes via Mac Terminal

## Traffic Flow

```
Internet
  → Cloudflare Edge (TLS 1.3 + post-quantum)
    → Tunnel (outbound-only from MacBook Air)
      → Local WARP instances
    → Pages (static)
    → Workers (dynamic / control / API)
    → KV (config/status only, low-frequency)
```

## Cost Constraints

- **Zero paid Cloudflare upgrades**
- **No high-frequency KV reads/writes**
- **Workers used only for dynamic/admin/API logic**, never for static pages
- **No Workers for simple static content** — use Pages instead
- **No SMS/email automation** without explicit credential and purpose audit
- **No new tools** unless replacing more expensive ones

## Deployment Lanes

| Lane | Tool | Purpose |
|---|---|---|
| Primary Execution | Mac Terminal | Shell, git, local scripts |
| Deployment / Control | Wrangler | Workers, KV, DNS, Tunnel config |
| Secure Remote Admin | WARP + Tunnel + SSH | Private access to edge/local |

## Current WARP Lane Context

| Scope | Path |
|---|---|
| Shared shell entry point | `/Users/billydeeii136` |
| WARP control repo | `/Users/billydeeii136/wsd-warp-control` |
| WARP orchestrator repo | `/Users/billydeeii136/wsd-warp-ai-orchestrator` |
| Current WARP lane context | `/Users/billydeeii136/WSD_AI_AGENT_LANES/programs/warp/projects/wsd-warp-ai-orchestrator/lanes/warp` |
| Compatibility WARP lane memory | `/Users/billydeeii136/WSD_AI_AGENT_LANES/warp` |

Normal Terminal is authoritative for Keychain/keyring-backed auth checks. Sandboxed agents may reference latest effective reports but must not treat sandbox Keychain misses as credential loss.

## Model Control Context

The user is building a private open-source AI systems control platform (Phase 6, targeting Phase 7). This architecture supports:
- Registry isolation per domain layer
- Quarantine lanes for adult-entertainment-adjacent models
- Hardware-fit selection for MacBook Air capacity
- Strict gatekeeping: no download, execution, or public deployment until approval

## Version

v1.1 — 2026-06-05

Co-Authored-By: Oz <oz-agent@warp.dev>
