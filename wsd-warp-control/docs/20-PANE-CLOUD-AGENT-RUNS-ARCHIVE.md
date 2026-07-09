# Cloud Agent Operational Check — 20 Pane Runs Archive
## Date: 2026-06-06
## Environment: WSD_CCOS_WARP (EJInLBQZTYgFMpsfxqwYPf)
## Docker Image: python:3.11
## Status: ALL SUCCEEDED ✅

| Pane | Run ID | Status | Oz URL |
|------|--------|--------|--------|
| aisha | 019e9ad0-5072-783d-b652-4c220db212c8 | SUCCEEDED | https://oz.warp.dev/runs/019e9ad0-5072-783d-b652-4c220db212c8 |
| amara | 019e9ad2-dafc-76ee-b96e-df2fdb06e976 | SUCCEEDED | https://oz.warp.dev/runs/019e9ad2-dafc-76ee-b96e-df2fdb06e976 |
| ananya | 019e9b0b-e55b-792d-b3f2-62374301b741 | SUCCEEDED | https://oz.warp.dev/runs/019e9b0b-e55b-792d-b3f2-62374301b741 |
| aya | 019e9b13-f29a-7cf5-9d26-0e2e91d3c3ce | SUCCEEDED | https://oz.warp.dev/runs/019e9b13-f29a-7cf5-9d26-0e2e91d3c3ce |
| chandra | 019e9b04-38ef-7a06-bd04-94ffe52e4f7d | SUCCEEDED | https://oz.warp.dev/runs/019e9b04-38ef-7a06-bd04-94ffe52e4f7d |
| fatima | 019e9adf-db20-75b7-bf9d-480c5cad7987 | SUCCEEDED | https://oz.warp.dev/runs/019e9adf-db20-75b7-bf9d-480c5cad7987 |
| hana | 019e9b0f-e37f-7661-af8f-e925d3f62944 | SUCCEEDED | https://oz.warp.dev/runs/019e9b0f-e37f-7661-af8f-e925d3f62944 |
| imani | 019e9af8-90d6-78d0-897b-daa625d732d4 | SUCCEEDED | https://oz.warp.dev/runs/019e9af8-90d6-78d0-897b-daa625d732d4 |
| jin | 019e9afc-676b-74b7-8033-09421cc43d07 | SUCCEEDED | https://oz.warp.dev/runs/019e9afc-676b-74b7-8033-09421cc43d07 |
| keiko | 019e9ae3-fba2-7119-862c-4a35e9bb0b46 | SUCCEEDED | https://oz.warp.dev/runs/019e9ae3-fba2-7119-862c-4a35e9bb0b46 |
| lena | 019e9ae8-0f96-73de-bd21-9b00d5e473c9 | SUCCEEDED | https://oz.warp.dev/runs/019e9ae8-0f96-73de-bd21-9b00d5e473c9 |
| maya | 019e9aeb-fbf0-7aaa-8a80-fcdc7a7cda75 | SUCCEEDED | https://oz.warp.dev/runs/019e9aeb-fbf0-7aaa-8a80-fcdc7a7cda75 |
| mei | 019e9ad2-1be1-725e-9e7b-3ede2abe6806 | SUCCEEDED | https://oz.warp.dev/runs/019e9ad2-1be1-725e-9e7b-3ede2abe6806 |
| nia | 019e9adb-c8ca-70c2-8e84-b2379792976a | SUCCEEDED | https://oz.warp.dev/runs/019e9adb-c8ca-70c2-8e84-b2379792976a |
| priya | 019e9acc-d570-73f5-b39b-398e5f430b1f | SUCCEEDED | https://oz.warp.dev/runs/019e9acc-d570-73f5-b39b-398e5f430b1f |
| rosa | 019e9af4-4ec6-72c6-974d-fa9fb3e0eb85 | SUCCEEDED | https://oz.warp.dev/runs/019e9af4-4ec6-72c6-974d-fa9fb3e0eb85 |
| soraya | 019e9b07-fb91-78e8-a476-a3eef5702112 | SUCCEEDED | https://oz.warp.dev/runs/019e9b07-fb91-78e8-a476-a3eef5702112 |
| tala | 019e9aef-e2c0-7057-b6b4-2c3cdabd4e12 | SUCCEEDED | https://oz.warp.dev/runs/019e9aef-e2c0-7057-b6b4-2c3cdabd4e12 |
| yuki | 019e9b00-5b48-7e5b-a820-f29e682fa31c | SUCCEEDED | https://oz.warp.dev/runs/019e9b00-5b48-7e5b-a820-f29e682fa31c |
| zara | 019e9ad7-9682-7e8e-b741-505997933c9a | SUCCEEDED | https://oz.warp.dev/runs/019e9ad7-9682-7e8e-b741-505997933c9a |

## Environment Details
- **OS:** Debian GNU/Linux 13 (trixie)
- **Kernel:** Linux 7.0.1 x86_64
- **User:** root
- **Working Directory:** /workspace
- **Status:** All 20 cloud agent panes confirmed OPERATIONAL

## Notes
- Single persistent agent profile (`priya`) used with `--name` flag per run for each pane identity.
- Cloud agent runs execute in isolated sandbox; local Mac directories are not directly accessible.
- To access project code from cloud agents, add Git repositories to the environment via `oz environment update <env> -r owner/repo`.

## Script Reference
- Sequential cycling script: `scripts/cycle-all-20-panes.sh`
- Workaround script: `scripts/warp-cloud-agent-workaround.sh`
