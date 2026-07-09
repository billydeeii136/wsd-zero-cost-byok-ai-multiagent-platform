#!/bin/bash
# Cycle through all 20 WARP pane names as cloud agent runs

ENV="EJInLBQZTYgFMpsfxqwYPf"
PROMPT="Pane '{PANE}' cloud agent operational check. Confirm Linux environment is running and echo hostname."
# Completed: priya, aisha. mei is running. Remaining 17 panes:
PANE_LIST=(amara zara nia fatima keiko lena maya tala rosa imani jin yuki chandra soraya ananya hana aya)

for pane in "${PANE_LIST[@]}"; do
    prompt="${PROMPT//\{PANE\}/$pane}"
    echo "=== Launching pane: $pane ==="
    output=$(oz agent run-cloud --name "$pane" --environment "$ENV" --prompt "$prompt" 2>&1)
    run_id=$(echo "$output" | grep -oE 'run ID: [^[:space:]]+' | cut -d' ' -f3)
    echo "Run ID: $run_id"
    echo "Waiting for completion..."

    # Poll until completed (max 120 seconds)
    for i in {1..40}; do
        status=$(oz run get "$run_id" --output-format json 2>/dev/null | grep -oE '"state":"[^"]+"' | head -1 | cut -d'"' -f4)
        if [[ "$status" == "Succeeded" || "$status" == "Failed" || "$status" == "Blocked" ]]; then
            echo "Status: $status"
            break
        fi
        sleep 3
    done
    echo
    sleep 1
done

echo "All 20 pane cloud agent runs complete."
