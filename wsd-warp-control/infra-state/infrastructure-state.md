# WSD Enterprises Infrastructure State
**Generated:** 2026-06-05T22:09:31Z  
**Project:** WSD_ENTERPRISES_MULTI_CLOUD  
**Apex Domain:** wsdenterprisesworldwide.com  
**Branch:** WSD (isolated from all other repos)

## Overview

This repository documents the complete infrastructure state, lane structure, provider registry, and authentication status for the WSD Enterprises multi-cloud platform. All secrets are stored in local SQLite vaults and are **NOT committed** to this repository.

## Infrastructure Verification

| Check | Status |
|---|---|
| Total verification checks | 22 |
| Passed | 22 |
| Failed | 0 |
| Pass rate | 100% |

## Domain Architecture

| Domain | Layer | Local Port | Service |
|---|---|---|---|
| wsdenterprisesworldwide.com | 1 (Apex) | 3006 | Apex Domain |
| wsdenterpirsesworldwidecloudservices.cloud | 2 | 3005 | Cloud Services |
| lebeautiful-botanicals.us.com | 2 | 3002 | Botanicals |
| acwyatt.com | 2 | 3001 | A.C. Wyatt |
| neighborhoodcarspa.us.com | 2 | 3003 | Car Spa |
| vokdesigngarage.com | 2 | 3004 | VOK Design |
| cumseeme.live | 2 (Jailed) | 3000 | Adult Platform |

## Provider Registry (16 Services)

| Provider | Category | Auth Status | CLI Status | Notes |
|---|---|---|---|---|
| Cloudflare | CDN/DNS/Workers | Normal Terminal Keychain stored | Installed | Wrangler 4.98.0; WARP Worker dry-run passes; WARP_CONFIG assigned to WARP-specific KV namespaces |
| GitHub | Git Repository | Authenticated | Installed | Normal Terminal keyring/GH_TOKEN repaired for `billydeeii136`; SSH git protocol |
| Google Cloud | Compute/Storage/IAM | Credentials present | Installed | 4 VMs tracked |
| OpenAI/Codex | AI API | Token present | Installed | Expiry tracked in vault |
| Docker Hub | Container Registry | Daemon running | Installed | Hub login needed |
| Rclone | Cloud Storage Sync | Encrypted config | Installed | v1.73.3, password-protected |
| NPM | Package Registry | Not authenticated | Installed | Login needed |
| AWS | Compute/Storage/IAM | Not installed | Not installed | Install: `brew install awscli` |
| Azure | Compute/Storage/IAM | Not installed | Not installed | Install: `brew install azure-cli` |
| Porkbun | Domain Registrar | No API config | N/A | 7 domains, add API keys to env |
| Vercel | Serverless | Not installed | Not installed | Install if needed |
| Netlify | Static Hosting | Not installed | Not installed | Install if needed |
| Heroku | PaaS | Not installed | Not installed | Install if needed |
| Firebase | Backend-as-a-Service | Not installed | Not installed | Install if needed |
| Supabase | Backend-as-a-Service | Not installed | Not installed | Install if needed |
| Git SSH | Secure Transport | Keys loaded | Installed | 3 keys in agent |

## Local Runtime Lanes

```
~/WSD_RUNTIME_LANES/
├── 01_APEX_DOMAIN/
├── 02_SUBDOMAIN_SERVICES/
├── 03_JAILED_ADULT/
├── 04_INFRA_CORE/          ← Symlinks to active configs
├── 05_DEV_BUILD/
├── 06_VAULT_SECURE/        ← Symlinks to vaults
├── 07_ARCHIVE_SYMLINKS/
└── 08_RUNTIME_LOGS/
```

## Cloud Offload Lanes (Google Drive)

```
~/Library/CloudStorage/GoogleDrive-williamscottdavis136@gmail.com/My Drive/WSD_CLOUD_OFFLOAD/
├── 01_APEX_DOMAIN_LAYER/
├── 02_SUBDOMAIN_LAYER/
├── 03_JAILED_LAYER/
├── ARCHIVE_LANE/
│   ├── Logs/
│   ├── Backups/
│   ├── Installers/
│   ├── Reports/
│   ├── Duplicates/
│   └── Old_Configs/
├── DEV_LANE/
│   ├── Scripts/
│   ├── Workers/
│   └── Repos/
├── INFRA_LANE/
│   ├── Tunnels/
│   ├── SSH_Keys/
│   ├── Credentials/
│   └── Config_Matrix/
└── VAULT_LANE/
    ├── AI_Vaults/
    ├── Credentials/
    └── Registry/
```

## Databases (Local, Not Committed)

| Database | Location | Records |
|---|---|---|
| Credentials Vault | `~/.ai_universal_vault/credentials_vault.db` | 24 credentials, 7 domains, 7 SSH hosts |
| Runtime Registry | `~/WSD_RUNTIME_LANES/.runtime_registry.db` | 23 lanes, 48 files, 19 infra components |
| Ticket System | `~/WSD_TICKET_SYSTEM.db` | 26 alignment matrix items |

## Key File Paths (Local)

| File | Purpose |
|---|---|
| `~/.cloudflared/config.yml` | Cloudflare Tunnel config (7 domains + SSH) |
| `~/.wrangler/config/default.toml` | Wrangler OAuth token storage |
| `~/.ssh/config` | SSH host configuration |
| `~/.ssh/id_ed25519` | SSH key (Ed25519) |
| `~/.ssh/id_rsa` | SSH key (RSA) |
| `~/.ssh/google_compute_engine` | GCloud VM SSH key |
| `~/.bash_profile` | Shell config with auto-start hooks |
| `~/.env` | Local environment variables |
| `~/wrangler.toml` | WSD Enterprises Worker config |
| `~/wrangler.deploy.jsonc` | WSD Memory Worker config |
| `~/WSD_AI_AGENT_LANES/programs/warp/projects/wsd-warp-ai-orchestrator/lanes/warp` | Current WARP program/project/lane context |
| `~/WSD_AI_AGENT_LANES/warp` | WARP compatibility lane memory |

## Query Commands

```bash
# Verify vault integrity
sqlite3 ~/.ai_universal_vault/credentials_vault.db 'PRAGMA integrity_check;'
sqlite3 ~/WSD_RUNTIME_LANES/.runtime_registry.db 'PRAGMA integrity_check;'

# List all credentials
sqlite3 ~/.ai_universal_vault/credentials_vault.db 'SELECT provider, service, key_name, status FROM credentials;'

# List infrastructure state
sqlite3 ~/WSD_RUNTIME_LANES/.runtime_registry.db 'SELECT component, auth_status, notes FROM infra_state;'

# List offloaded files
sqlite3 ~/WSD_RUNTIME_LANES/.runtime_registry.db 'SELECT filename, lane, size_bytes FROM file_registry WHERE status="active";'

# Cloudflare tunnel status
cloudflared tunnel list

# WARP Worker non-deploying validation
cd ~/wsd-warp-control/worker && wrangler deploy --dry-run

# SSH agent status
ssh-add -l

# GitHub auth status
gh auth status
```

## Scripts in This Repository

| Script | Purpose |
|---|---|
| `scripts/WSD_TOKEN_REFRESH.command` | One-shot re-authentication for all providers |
| `scripts/WSD_FINAL_SYNCHRONIZATION_VERIFICATION.command` | Full infrastructure verification suite |
| `scripts/WSD_CLOUD_AUTH_ACCESS.sh` | Cloud auth status checker |

## Security Notes

- All credential files have **600 permissions** (owner read/write only)
- SSH keys are **permanent** until explicitly deleted
- OAuth tokens **auto-refresh** via Wrangler and GitHub CLI keyring
- OpenAI/Codex tokens **expire periodically** and require re-auth
- `WARP_CONFIG` in `worker/wrangler.toml` is assigned to WARP-specific production and preview KV namespaces.
- No actual secrets, tokens, or passwords are stored in this repository
- Run `~/WSD_TOKEN_REFRESH.command` when any token expires

## Co-Authored-By

Co-Authored-By: Oz <oz-agent@warp.dev>
