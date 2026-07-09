#!/bin/bash
# Create 20 cloud agents matching WARP left pane tab names
# Each agent uses the WSD_CCOS_WARP environment

ENV="EJInLBQZTYgFMpsfxqwYPf"
AGENTS=(
  priya aisha mei amara zara
  nia fatima keiko lena maya
  tala rosa imani jin yuki
  chandra soraya ananya hana aya
)

for name in "${AGENTS[@]}"; do
  echo "Creating agent: $name"
  oz agent create --name "$name" --description "Cloud agent for WARP tab pane $name" --environment "$ENV"
  sleep 2
done

echo "All 20 cloud agents created."
