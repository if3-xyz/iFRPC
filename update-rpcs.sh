#!/bin/bash
set -e

# Get current chain ID from erpc.yaml
ERPC_YAML="${ERPC_YAML:-./erpc.yaml}"
CHAIN_ID=$(grep -E "^\s+chainId:" "$ERPC_YAML" | awk '{print $2}')

if [ -z "$CHAIN_ID" ]; then
    echo "Error: Could not find chainId in $ERPC_YAML"
    exit 1
fi

echo "[$(date)] Updating RPC endpoints for chain ID: $CHAIN_ID"

# Download chainlist RPCs
RPCS=($(curl -s "https://chainlist.org/rpcs.json" | jq -r ".[] | select(.chainId==${CHAIN_ID}) | .rpc[]?.url? | select(. != null and startswith(\"http\"))" | grep -v "$ETH_RPC_URL" | head -10))

# Fallback to thirdweb and Ankr if no endpoints found
[ ${#RPCS[@]} -eq 0 ] && RPCS=("https://${CHAIN_ID}.rpc.thirdweb.com" "https://rpc.ankr.com/multichain/${CHAIN_ID}")

# Prioritize ETH_RPC_URL if set
[ -n "$ETH_RPC_URL" ] && RPCS=("$ETH_RPC_URL" "${RPCS[@]}")

# Update erpc.yaml
sed -i '/^      - endpoint:/d' "$ERPC_YAML"
printf '      - endpoint: %s\n' "${RPCS[@]}" | sed -i '/^    upstreams:/r /dev/stdin' "$ERPC_YAML"

echo "[$(date)] Updated ${#RPCS[@]} RPC endpoints"

# Restart erpc container to apply changes (if docker is available)
if command -v docker >/dev/null 2>&1 && docker ps | grep -q "erpc$"; then
    echo "[$(date)] Restarting erpc container to apply new RPC endpoints..."
    docker restart erpc
fi

