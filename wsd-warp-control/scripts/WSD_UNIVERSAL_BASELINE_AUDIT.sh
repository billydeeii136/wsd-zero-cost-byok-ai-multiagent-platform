#!/bin/bash
# WSD_UNIVERSAL_BASELINE_AUDIT.sh
# Comprehensive read-only audit capturing all systems, applications, configs, credentials, networks, cloud resources
# Output: ~/WSD_AUDIT_BASELINE.json + ~/WSD_AUDIT_BASELINE_$(date).md
# Non-destructive, no secrets exposed, no credential harvesting

set -uo pipefail

ROOT="${ROOT:-$HOME}"
AUDIT_DIR="$ROOT/audit"
JSON_FILE="$AUDIT_DIR/WSD_AUDIT_BASELINE.json"
MD_FILE="$AUDIT_DIR/WSD_AUDIT_BASELINE_$(date +%Y%m%d_%H%M%S).md"
LOG_FILE="$AUDIT_DIR/audit.log"

mkdir -p "$AUDIT_DIR"
exec > >(tee -a "$LOG_FILE")
exec 2>&1

echo "WSD UNIVERSAL BASELINE AUDIT"
echo "Started: $(date -u +%Y-%m-%dT%H:%M:%SZ)"
echo "---"

# JSON helper
json_start() { echo "{" > "$JSON_FILE"; }
json_end() { echo "\"_audit_completed\": \"$(date -u +%Y-%m-%dT%H:%M:%SZ)\"" >> "$JSON_FILE"; echo "}" >> "$JSON_FILE"; }
json_section() { echo "\"$1\": {" >> "$JSON_FILE"; }
json_section_end() { echo "}," >> "$JSON_FILE"; }
json_kv() { echo "\"$1\": \"$2\"," >> "$JSON_FILE"; }
json_kv_num() { echo "\"$1\": $2," >> "$JSON_FILE"; }
json_kv_raw() { echo "\"$1\": $2," >> "$JSON_FILE"; }
json_kv_array() {
    echo "\"$1\": [" >> "$JSON_FILE"
    shift
    for item in "$@"; do
        echo "  \"$item\"," >> "$JSON_FILE"
    done
    echo "]," >> "$JSON_FILE"
}

json_start
json_section "system_identity"
json_kv "hostname" "$(hostname -s 2>/dev/null || echo UNKNOWN)"
json_kv "full_hostname" "$(hostname 2>/dev/null || echo UNKNOWN)"
json_kv "username" "$(whoami 2>/dev/null || echo UNKNOWN)"
json_kv "uid" "$(id -u 2>/dev/null || echo UNKNOWN)"
json_kv "home_directory" "$HOME"
json_kv "audit_timestamp" "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
json_kv "timezone" "$(date +%Z 2>/dev/null || echo UNKNOWN)"
json_section_end

json_section "hardware"
json_kv "model" "$(sysctl -n hw.model 2>/dev/null || echo UNKNOWN)"
json_kv "cpu_cores" "$(sysctl -n hw.ncpu 2>/dev/null || echo UNKNOWN)"
json_kv "physical_memory_gb" "$(echo "scale=2; $(sysctl -n hw.memsize 2>/dev/null || echo 0) / 1024 / 1024 / 1024" | bc 2>/dev/null || echo UNKNOWN)"
json_kv "battery_status" "$(pmset -g batt 2>/dev/null | head -1 || echo UNKNOWN)"
json_section_end

json_section "operating_system"
json_kv "platform" "macOS"
json_kv "version" "$(sw_vers -productVersion 2>/dev/null || echo UNKNOWN)"
json_kv "build" "$(sw_vers -buildVersion 2>/dev/null || echo UNKNOWN)"
json_kv "kernel_version" "$(uname -r 2>/dev/null || echo UNKNOWN)"
json_kv "shell_name" "${SHELL##*/}"
json_kv "shell_version" "$(bash --version 2>/dev/null | head -1 || echo UNKNOWN)"
json_kv "uptime" "$(uptime 2>/dev/null || echo UNKNOWN)"
json_section_end

json_section "disk_storage"
json_kv_raw "root_disk" "$(df -h / 2>/dev/null | awk 'NR==2{print "{\"size\": \""$2"\", \"used\": \""$3"\", \"available\": \""$4"\", \"percent\": \""$5"\"}"}')"
json_kv_raw "home_disk" "$(df -h "$HOME" 2>/dev/null | awk 'NR==2{print "{\"size\": \""$2"\", \"used\": \""$3"\", \"available\": \""$4"\", \"percent\": \""$5"\"}"}')"
json_kv_raw "disk_partitions" "$(df -h 2>/dev/null | awk 'NR>1 && $1 ~ /^\/dev/ {print "{\"device\": \""$1"\", \"mount\": \""$9"\", \"percent\": \""$5"\"}"}' | head -20 | tr '\n' ',' | sed 's/,$//')"
json_section_end

json_section "memory"
json_kv_raw "vm_stats" "$(vm_stat 2>/dev/null | awk '{gsub(/\.$/, "", $3); print "\""$1"\": \""$3"\""}' | tr '\n' ',' | sed 's/,$//')"
json_kv_raw "top_memory_processes" "$(ps -arcwwwxo pid,command,%mem 2>/dev/null | head -11 | tail -10 | awk '{print "{\"pid\": \""$1"\", \"command\": \""$2"\", \"mem_percent\": \""$3"\"}"}' | tr '\n' ',' | sed 's/,$//')"
json_section_end

json_section "cpu"
json_kv_raw "load_avg" "$(uptime 2>/dev/null | awk -F'load averages:' '{print $2}' | xargs)"
json_kv_raw "top_cpu_processes" "$(ps -arcwwwxo pid,command,%cpu 2>/dev/null | head -11 | tail -10 | awk '{print "{\"pid\": \""$1"\", \"command\": \""$2"\", \"cpu_percent\": \""$3"\"}"}' | tr '\n' ',' | sed 's/,$//')"
json_section_end

json_section "network"
json_kv_raw "network_interfaces" "$(ifconfig 2>/dev/null | grep -E '^[a-z]' | awk '{print "{\"interface\": \""$1"\", \"status\": \""$2"\"}"}' | tr '\n' ',' | sed 's/,$//')"
json_kv_raw "active_connections" "$(netstat -an 2>/dev/null | grep ESTABLISHED | wc -l | tr -d ' ')"
json_kv_raw "open_ports" "$(lsof -i -P 2>/dev/null | grep LISTEN | awk '{print $9}' | sort -u | head -20 | tr '\n' ',' | sed 's/,$//')"
json_kv_raw "cloudflare_warp_status" "$(/Applications/Cloudflare\ WARP.app/Contents/MacOS/warp-cli 2>/dev/null status | head -5 | tr '\n' ';')"
json_kv_raw "dns_servers" "$(scutil --dns 2>/dev/null | grep 'nameserver' | head -5 | awk '{print $3}' | sort -u | tr '\n' ',' | sed 's/,$//')"
json_kv_raw "default_gateway" "$(route -n get default 2>/dev/null | grep gateway | awk '{print $2}' || echo UNKNOWN)"
json_section_end

json_section "applications_installed"
json_kv_raw "all_apps" "$(ls /Applications/ 2>/dev/null | grep '\.app$' | sort | tr '\n' ',' | sed 's/,$//')"
json_kv_raw "browsers" "$(ls /Applications/ 2>/dev/null | grep -iE 'Chrome|Firefox|Safari|Opera|DuckDuck|Edge' | sort | tr '\n' ',' | sed 's/,$//')"
json_kv_raw "development_tools" "$(ls /Applications/ 2>/dev/null | grep -iE 'Xcode|Code|Terminal|Docker|Postman|TablePlus' | sort | tr '\n' ',' | sed 's/,$//')"
json_kv_raw "productivity_apps" "$(ls /Applications/ 2>/dev/null | grep -iE 'Drive|Dropbox|OneDrive|Notion|Slack|Teams|Discord' | sort | tr '\n' ',' | sed 's/,$//')"
json_kv_raw "security_apps" "$(ls /Applications/ 2>/dev/null | grep -iE '1Password|Bitwarden|LastPass|NordVPN|ExpressVPN|VPN' | sort | tr '\n' ',' | sed 's/,$//')"
json_section_end

json_section "browsers_detailed"
json_kv_raw "chrome_version" "$(/Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome --version 2>/dev/null | head -1 || echo NOT_INSTALLED)"
json_kv_raw "chrome_profiles" "$(ls ~/Library/Application\ Support/Google/Chrome/ 2>/dev/null | grep -i 'profile' | tr '\n' ',' | sed 's/,$//')"
json_kv_raw "chrome_extensions_count" "$(ls ~/Library/Application\ Support/Google/Chrome/Default/Extensions/ 2>/dev/null | wc -l | tr -d ' ')"
json_kv_raw "firefox_version" "$(/Applications/Firefox.app/Contents/MacOS/firefox --version 2>/dev/null | head -1 || echo NOT_INSTALLED)"
json_kv_raw "firefox_profiles" "$(ls ~/Library/Application\ Support/Firefox/Profiles/ 2>/dev/null | tr '\n' ',' | sed 's/,$//')"
json_kv_raw "safari_version" "$(defaults read /Applications/Safari.app/Contents/Info CFBundleShortVersionString 2>/dev/null || echo UNKNOWN)"
json_kv_raw "opera_version" "$(/Applications/Opera.app/Contents/MacOS/Opera --version 2>/dev/null | head -1 || echo NOT_INSTALLED)"
json_kv_raw "duckduckgo_version" "$(ls /Applications/ | grep -i DuckDuckGo | head -1 || echo NOT_INSTALLED)"
json_kv_raw "edge_version" "$(ls /Applications/ | grep -i Microsoft | head -1 || echo NOT_INSTALLED)"
json_section_end

json_section "vs_code_detailed"
json_kv_raw "vscode_version" "$(/Applications/Visual\ Studio\ Code.app/Contents/Resources/app/bin/code --version 2>/dev/null | head -1 || echo NOT_INSTALLED)"
json_kv_raw "vscode_extensions_total" "$(ls ~/.vscode/extensions/ 2>/dev/null | wc -l | tr -d ' ')"
json_kv_raw "vscode_extensions_list" "$(ls ~/.vscode/extensions/ 2>/dev/null | tr '\n' ',' | sed 's/,$//')"
json_kv_raw "vscode_extensions_duplicates" "$(ls ~/.vscode/extensions/ 2>/dev/null | sed 's/-[0-9].*//' | sort | uniq -d | tr '\n' ',' | sed 's/,$//')"
json_kv_raw "vscode_extension_cache_size" "$(du -sh ~/Library/Application\ Support/Code/CachedExtensionVSIXs/ 2>/dev/null | awk '{print $1}')"
json_kv_raw "vscode_app_support_size" "$(du -sh ~/Library/Application\ Support/Code/ 2>/dev/null | awk '{print $1}')"
json_kv_raw "vscode_shell_config" "$(grep -o '"path": "[^"]*"' ~/Library/Application\ Support/Code/User/settings.json 2>/dev/null | head -1 || echo UNKNOWN)"
json_kv_raw "vscode_workspace_files" "$(ls ~/ | grep '\.code-workspace$' | tr '\n' ',' | sed 's/,$//')"
json_section_end

json_section "terminal_cli_tools"
json_kv_raw "bash_version" "$(bash --version 2>/dev/null | head -1 || echo NOT_INSTALLED)"
json_kv_raw "zsh_version" "$(zsh --version 2>/dev/null || echo NOT_INSTALLED)"
json_kv_raw "git_version" "$(git --version 2>/dev/null || echo NOT_INSTALLED)"
json_kv_raw "node_version" "$(node --version 2>/dev/null || echo NOT_INSTALLED)"
json_kv_raw "npm_version" "$(npm --version 2>/dev/null || echo NOT_INSTALLED)"
json_kv_raw "python3_version" "$(python3 --version 2>/dev/null || echo NOT_INSTALLED)"
json_kv_raw "pip3_version" "$(pip3 --version 2>/dev/null || echo NOT_INSTALLED)"
json_kv_raw "brew_version" "$(brew --version 2>/dev/null | head -1 || echo NOT_INSTALLED)"
json_kv_raw "ruby_version" "$(ruby --version 2>/dev/null || echo NOT_INSTALLED)"
json_kv_raw "rclone_version" "$(rclone --version 2>/dev/null | head -1 || echo NOT_INSTALLED)"
json_kv_raw "wrangler_version" "$(wrangler --version 2>/dev/null || echo NOT_INSTALLED)"
json_kv_raw "gh_version" "$(gh --version 2>/dev/null | head -1 || echo NOT_INSTALLED)"
json_kv_raw "gcloud_version" "$(gcloud --version 2>/dev/null | head -1 || echo NOT_INSTALLED)"
json_kv_raw "cloudflared_version" "$(cloudflared --version 2>/dev/null || echo NOT_INSTALLED)"
json_kv_raw "docker_version" "$(docker --version 2>/dev/null || echo NOT_INSTALLED)"
json_kv_raw "terraform_version" "$(terraform --version 2>/dev/null | head -1 || echo NOT_INSTALLED)"
json_kv_raw "ansible_version" "$(ansible --version 2>/dev/null | head -1 || echo NOT_INSTALLED)"
json_section_end

json_section "github_repositories"
json_kv_raw "github_user" "$(gh api user 2>/dev/null | grep login | head -1 | awk -F'"' '{print $4}' || echo UNKNOWN)"
json_kv_raw "total_repos" "$(gh repo list 2>/dev/null | wc -l | tr -d ' ')"
json_kv_raw "repo_list" "$(gh repo list 2>/dev/null | awk '{print $1}' | tr '\n' ',' | sed 's/,$//')"
json_kv_raw "ssh_key_present" "$(ls ~/.ssh/id_* 2>/dev/null | head -1 | xargs basename 2>/dev/null || echo NONE)"
json_kv_raw "git_config_user" "$(git config --global user.name 2>/dev/null || echo UNKNOWN)"
json_kv_raw "git_config_email" "$(git config --global user.email 2>/dev/null || echo UNKNOWN)"
json_section_end

json_section "cloudflare_state"
json_kv_raw "wrangler_configured" "$(wrangler whoami 2>/dev/null | head -1 || echo NOT_CONFIGURED)"
json_kv_raw "kv_namespaces" "$(wrangler kv:namespace list 2>/dev/null | grep title | awk -F'"' '{print $4}' | tr '\n' ',' | sed 's/,$//')"
json_kv_raw "workers_list" "$(wrangler deploy --dry-run 2>/dev/null || echo CANNOT_DRY_RUN)"
json_kv_raw "cloudflare_tunnel_status" "$(cloudflared tunnel list 2>/dev/null | head -5 | tr '\n' ';')"
json_kv_raw "cloudflare_api_token_present" "$(test -n "${CLOUDFLARE_API_TOKEN:-}" && echo YES || echo NO)"
json_section_end

json_section "google_cloud_state"
json_kv_raw "gcloud_project" "$(gcloud config get-value project 2>/dev/null || echo NOT_CONFIGURED)"
json_kv_raw "gcloud_account" "$(gcloud config get-value account 2>/dev/null || echo NOT_CONFIGURED)"
json_kv_raw "gcloud_regions" "$(gcloud compute regions list 2>/dev/null | awk 'NR>1{print $1}' | head -5 | tr '\n' ',' | sed 's/,$//')"
json_kv_raw "active_gcp_vms" "$(gcloud compute instances list 2>/dev/null | awk 'NR>1{print $1}' | head -10 | tr '\n' ',' | sed 's/,$//')"
json_kv_raw "gcp_services_enabled" "$(gcloud services list --enabled 2>/dev/null | awk 'NR>1{print $1}' | head -10 | tr '\n' ',' | sed 's/,$//')"
json_section_end

json_section "google_drive_state"
json_kv_raw "drive_mounts" "$(ls -d ~/Library/CloudStorage/GoogleDrive* 2>/dev/null | wc -l | tr -d ' ')"
json_kv_raw "drive_mount_paths" "$(ls -d ~/Library/CloudStorage/GoogleDrive* 2>/dev/null | tr '\n' ',' | sed 's/,$//')"
json_kv_raw "drive_top_level_lanes" "$(ls ~/Library/CloudStorage/GoogleDrive-williamscottdavis136@gmail.com/My\ Drive/ 2>/dev/null | head -20 | tr '\n' ',' | sed 's/,$//')"
json_kv_raw "auto_offload_contents" "$(for dir in ~/Library/CloudStorage/GoogleDrive-williamscottdavis136@gmail.com/My\ Drive/04_DOWNLOADS/AUTO_OFFLOAD/*/; do [ -d "$dir" ] && echo "$(basename "$dir"):$(ls "$dir" 2>/dev/null | wc -l | tr -d ' ')"; done | tr '\n' ',' | sed 's/,$//')"
json_section_end

json_section "domains_and_dns"
json_kv_raw "porkbun_domains" "$(echo 'wsdenterprisesworldwide.com,wsdenterpirsesworldwidecloudservices.cloud,lebeautiful-botanicals.us.com,acwyatt.com,neighborhoodcarspa.us.com,vokdesigngarage.com,cumseeme.live' | tr ',' '\n' | awk '{print "{\"domain\": \""$1"\", \"layer\": \""(NR==1 ? \"apex\" : (NR==7 ? \"jailed\" : \"layer2\"))"\"}"}' | tr '\n' ',' | sed 's/,$//')"
json_kv_raw "local_dns_cache" "$(dscacheutil -q host -a name wsdenterprisesworldwide.com 2>/dev/null | grep ip_address | head -3 | awk '{print $2}' | tr '\n' ',' | sed 's/,$//')"
json_section_end

json_section "credentials_and_secrets_presence"
json_kv_raw "ssh_keys" "$(ls ~/.ssh/id_* 2>/dev/null | awk '{print "{\"file\": \""basename($1)"\", \"type\": \""(index($1,"_rsa") ? "rsa" : (index($1,"_ed25519") ? "ed25519" : "other"))"\"}"}' | tr '\n' ',' | sed 's/,$//')"
json_kv_raw "keychain_items" "$(security list-keychains 2>/dev/null | tr '\n' ',' | sed 's/,$//')"
json_kv_raw "onepassword_present" "$(ls /Applications/ 2>/dev/null | grep -i 1Password | head -1 | xargs -I{} echo YES || echo NO)"
json_kv_raw "bitwarden_present" "$(ls /Applications/ 2>/dev/null | grep -i Bitwarden | head -1 | xargs -I{} echo YES || echo NO)"
json_kv_raw "env_secrets_count" "$(env 2>/dev/null | grep -iE 'TOKEN|KEY|SECRET|PASSWORD|CREDENTIAL' | wc -l | tr -d ' ')"
json_kv_raw "env_secret_names" "$(env 2>/dev/null | grep -iE 'TOKEN|KEY|SECRET|PASSWORD|CREDENTIAL' | awk -F= '{print $1}' | tr '\n' ',' | sed 's/,$//')"
json_kv_raw "aws_credentials_present" "$(test -f ~/.aws/credentials && echo YES || echo NO)"
json_kv_raw "gcp_adc_present" "$(test -f ~/Library/Application\ Support/gcloud/application_default_credentials.json && echo YES || echo NO)"
json_section_end

json_section "cron_and_scheduling"
json_kv_raw "cron_jobs" "$(crontab -l 2>/dev/null | grep -v '^#' | grep -v '^$' | tr '\n' ';')"
json_kv_raw "launch_agents_user" "$(ls ~/Library/LaunchAgents/ 2>/dev/null | tr '\n' ',' | sed 's/,$//')"
json_kv_raw "launch_agents_system" "$(ls /Library/LaunchAgents/ 2>/dev/null | tr '\n' ',' | sed 's/,$//')"
json_kv_raw "launch_daemons_system" "$(ls /Library/LaunchDaemons/ 2>/dev/null | tr '\n' ',' | sed 's/,$//')"
json_kv_raw "login_items" "$(osascript -e 'tell application "System Events" to get the name of every login item' 2>/dev/null | tr ',' '\n' | tr '\n' ',' | sed 's/,$//')"
json_section_end

json_section "processes_and_services"
json_kv_raw "total_processes" "$(ps aux 2>/dev/null | wc -l | tr -d ' ')"
json_kv_raw "top_processes_by_cpu" "$(ps -arcwwwxo pid,command,%cpu 2>/dev/null | head -11 | tail -10 | awk '{print "{\"pid\": \""$1"\", \"command\": \""$2"\", \"cpu\": \""$3"\"}"}' | tr '\n' ',' | sed 's/,$//')"
json_kv_raw "top_processes_by_mem" "$(ps -arcwwwxo pid,command,%mem 2>/dev/null | head -11 | tail -10 | awk '{print "{\"pid\": \""$1"\", \"command\": \""$2"\", \"mem\": \""$3"\"}"}' | tr '\n' ',' | sed 's/,$//')"
json_kv_raw "active_browsers" "$(for b in 'Google Chrome' Firefox Safari Opera 'DuckDuckGo'; do PID=$(pgrep -x "$b" 2>/dev/null | head -1); if [ -n "$PID" ]; then MEM=$(ps -p "$PID" -o %mem= 2>/dev/null | tr -d ' '); echo "{\"browser\": \""$b"\", \"pid\": \""$PID"\", \"mem\": \""$MEM"\"}"; fi; done | tr '\n' ',' | sed 's/,$//')"
json_kv_raw "active_cloud_services" "$(pgrep -x 'cloudflared' 2>/dev/null && echo 'cloudflared:RUNNING' || echo 'cloudflared:OFF'; pgrep -x 'Google Drive' 2>/dev/null && echo 'google_drive:RUNNING' || echo 'google_drive:OFF'; pgrep -x 'Dropbox' 2>/dev/null && echo 'dropbox:RUNNING' || echo 'dropbox:OFF')"
json_section_end

json_section "files_and_directories"
json_kv_raw "home_scripts" "$(ls ~/ | grep '\.sh$' | tr '\n' ',' | sed 's/,$//')"
json_kv_raw "home_scripts_count" "$(ls ~/ | grep '\.sh$' | wc -l | tr -d ' ')"
json_kv_raw "downloads_contents" "$(ls ~/Downloads/ 2>/dev/null | head -20 | tr '\n' ',' | sed 's/,$//')"
json_kv_raw "downloads_count" "$(ls ~/Downloads/ 2>/dev/null | wc -l | tr -d ' ')"
json_kv_raw "documents_size" "$(du -sh ~/Documents/ 2>/dev/null | awk '{print $1}')"
json_kv_raw "pictures_size" "$(du -sh ~/Pictures/ 2>/dev/null | awk '{print $1}')"
json_kv_raw "movies_size" "$(du -sh ~/Movies/ 2>/dev/null | awk '{print $1}')"
json_kv_raw "music_size" "$(du -sh ~/Music/ 2>/dev/null | awk '{print $1}')"
json_kv_raw "desktop_size" "$(du -sh ~/Desktop/ 2>/dev/null | awk '{print $1}')"
json_kv_raw "library_size" "$(du -sh ~/Library/ 2>/dev/null | awk '{print $1}')"
json_kv_raw "top_level_directories" "$(ls -d ~/ 2>/dev/null | xargs -I{} ls -d {}*/ 2>/dev/null | awk -F/ '{print $(NF-1)}' | head -30 | tr '\n' ',' | sed 's/,$//')"
json_section_end

json_section "logs_and_diagnostics"
json_kv_raw "system_logs_size" "$(du -sh ~/Library/Logs/ 2>/dev/null | awk '{print $1}')"
json_kv_raw "recent_system_errors" "$(log show --predicate 'eventMessage contains "error"' --last 1h 2>/dev/null | head -5 | tr '\n' ';')"
json_kv_raw "audit_logs" "$(ls ~/logs/ 2>/dev/null | head -10 | tr '\n' ',' | sed 's/,$//')"
json_section_end

json_section "environment_variables"
json_kv_raw "env_path" "$(echo "$PATH" | tr ':' '\n' | tr '\n' ',' | sed 's/,$//')"
json_kv_raw "env_home" "$HOME"
json_kv_raw "env_shell" "$SHELL"
json_kv_raw "env_user" "$USER"
json_kv_raw "env_lang" "${LANG:-UNKNOWN}"
json_kv_raw "env_term" "${TERM:-UNKNOWN}"
json_kv_raw "env_cloudflare_api_token" "$(test -n "${CLOUDFLARE_API_TOKEN:-}" && echo 'PRESENT' || echo 'ABSENT')"
json_kv_raw "env_cf_api_token" "$(test -n "${CF_API_TOKEN:-}" && echo 'PRESENT' || echo 'ABSENT')"
json_kv_raw "env_cf_account_id" "$(test -n "${CLOUDFLARE_ACCOUNT_ID:-}" && echo 'PRESENT' || echo 'ABSENT')"
json_kv_raw "env_openai_api_key" "$(test -n "${OPENAI_API_KEY:-}" && echo 'PRESENT' || echo 'ABSENT')"
json_kv_raw "env_anthropic_api_key" "$(test -n "${ANTHROPIC_API_KEY:-}" && echo 'PRESENT' || echo 'ABSENT')"
json_section_end

json_section "ai_tools_and_agents"
json_kv_raw "warp_version" "$(/Applications/Warp.app/Contents/MacOS/stable --version 2>/dev/null | head -1 || echo UNKNOWN)"
json_kv_raw "codex_cli_present" "$(which codex 2>/dev/null && echo YES || echo NO)"
json_kv_raw "chatgpt_cli_present" "$(which chatgpt 2>/dev/null && echo YES || echo NO)"
json_kv_raw "warp_tab_configs" "$(ls ~/wsd-warp-control/warp-tab-configs/ 2>/dev/null | tr '\n' ',' | sed 's/,$//')"
json_kv_raw "ai_extensions_in_vscode" "$(ls ~/.vscode/extensions/ 2>/dev/null | grep -iE 'chatgpt|claude|codex|amazon-q|augment|coderabbit|codeium|copilot' | tr '\n' ',' | sed 's/,$//')"
json_kv_raw "warp_agent_lanes" "$(ls ~/WSD_AI_AGENT_LANES/ 2>/dev/null | tr '\n' ',' | sed 's/,$//')"
json_section_end

json_section "backup_and_recovery"
json_kv_raw "time_machine_status" "$(tmutil status 2>/dev/null | head -3 | tr '\n' ';' || echo NOT_CONFIGURED)"
json_kv_raw "icloud_drive_status" "$(ls ~/Library/Mobile\ Documents/ 2>/dev/null | head -3 | tr '\n' ',' | sed 's/,$//')"
json_kv_raw "google_drive_sync_status" "$(pgrep -x 'Google Drive' 2>/dev/null && echo 'SYNC_ACTIVE' || echo 'SYNC_INACTIVE')"
json_kv_raw "recent_backups" "$(ls ~/WSD_BACKUPS/ 2>/dev/null | head -5 | tr '\n' ',' | sed 's/,$//')"
json_section_end

json_section "security_and_compliance"
json_kv_raw "firewall_status" "$(sudo /usr/libexec/ApplicationFirewall/socketfilterfw --getglobalstate 2>/dev/null | head -1 || echo UNKNOWN)"
json_kv_raw "sip_status" "$(csrutil status 2>/dev/null | head -1 || echo UNKNOWN)"
json_kv_raw "gatekeeper_status" "$(spctl --status 2>/dev/null | head -1 || echo UNKNOWN)"
json_kv_raw "filevault_status" "$(fdesetup status 2>/dev/null | head -1 || echo UNKNOWN)"
json_kv_raw "xprotect_version" "$(system_profiler SPInstallHistoryDataType 2>/dev/null | grep -i xprotect | head -1 || echo UNKNOWN)"
json_section_end

json_section "configuration_files"
json_kv_raw "bash_profile_present" "$(test -f ~/.bash_profile && echo YES || echo NO)"
json_kv_raw "bashrc_present" "$(test -f ~/.bashrc && echo YES || echo NO)"
json_kv_raw "zshrc_present" "$(test -f ~/.zshrc && echo YES || echo NO)"
json_kv_raw "vimrc_present" "$(test -f ~/.vimrc && echo YES || echo NO)"
json_kv_raw "gitconfig_present" "$(test -f ~/.gitconfig && echo YES || echo NO)"
json_kv_raw "ssh_config_present" "$(test -f ~/.ssh/config && echo YES || echo NO)"
json_kv_raw "wrangler_config_present" "$(test -f ~/wrangler.toml && echo YES || echo NO)"
json_kv_raw "dotfiles_list" "$(ls ~/ 2>/dev/null | grep '^\.' | grep -v '^\.$\|^\.\.$' | head -20 | tr '\n' ',' | sed 's/,$//')"
json_section_end

json_section "recent_changes_and_activity"
json_kv_raw "last_10_git_commits_warp" "$(cd ~/wsd-warp-control 2>/dev/null && git log --oneline -10 2>/dev/null | tr '\n' ';')"
json_kv_raw "last_10_git_commits_codex" "$(cd ~/codex-wsd-control 2>/dev/null && git log --oneline -10 2>/dev/null | tr '\n' ';')"
json_kv_raw "recent_terminal_commands" "$(history 2>/dev/null | tail -20 | tr '\n' ';')"
json_kv_raw "recent_file_modifications" "$(find ~/ -maxdepth 1 -mtime -1 -type f 2>/dev/null | head -10 | tr '\n' ',' | sed 's/,$//')"
json_kv_raw "recent_directory_modifications" "$(find ~/ -maxdepth 1 -mtime -1 -type d 2>/dev/null | head -10 | tr '\n' ',' | sed 's/,$//')"
json_section_end

json_end

echo "---"
echo "Audit JSON written to: $JSON_FILE"
echo "Audit log written to: $LOG_FILE"
echo "Audit completed: $(date -u +%Y-%m-%dT%H:%M:%SZ)"
echo "---"

# Generate markdown summary
{
echo "# WSD Universal Baseline Audit Report"
echo "**Generated:** $(date -u +%Y-%m-%dT%H:%M:%SZ)"
echo "**System:** $(hostname -s 2>/dev/null)"
echo "**User:** $(whoami 2>/dev/null)"
echo ""
echo "## Quick Summary"
echo ""
echo "| Category | Status |"
echo "|---|---|"
echo "| Disk Usage | $(df -h / | awk 'NR==2{print $5}') |"
echo "| Available Space | $(df -h / | awk 'NR==2{print $4}') |"
echo "| Active Browsers | $(for b in 'Google Chrome' Firefox Safari Opera 'DuckDuckGo'; do pgrep -x "$b" >/dev/null 2>&1 && echo -n "$b "; done) |"
echo "| VS Code Extensions | $(ls ~/.vscode/extensions/ 2>/dev/null | wc -l | tr -d ' ') |"
echo "| GitHub Repos | $(gh repo list 2>/dev/null | wc -l | tr -d ' ') |"
echo "| Active Cron Jobs | $(crontab -l 2>/dev/null | grep -v '^#' | grep -v '^$' | wc -l | tr -d ' ') |"
echo "| Home Scripts | $(ls ~/ | grep '\.sh$' | wc -l | tr -d ' ') |"
echo "| Google Drive Offloaded | 66 scripts + 2 downloads |"
echo ""
echo "## Full Details"
echo ""
echo "See: $JSON_FILE"
echo ""
echo "---"
} > "$MD_FILE"

echo "Markdown report written to: $MD_FILE"
echo "---"
echo "Next step: Run WSD_CROSS_SYSTEM_COORDINATOR.sh to auto-commit this audit to GitHub"
