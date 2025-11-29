#!/bin/bash
set -e
CHAIN_ID=$1
[ -z "$CHAIN_ID" ] && { echo "Usage: $0 <chainID>"; exit 1; }

# Download chainlist RPCs
echo "Fetching RPC endpoints from chainlist.org..."
RPCS=($(curl -s "https://chainlist.org/rpcs.json" | jq -r ".[] | select(.chainId==${CHAIN_ID}) | .rpc[]?.url? | select(. != null and startswith(\"http\"))" | grep -v "$ETH_RPC_URL" | head -10))

# Fallback to thirdweb and Ankr if no endpoints found
[ ${#RPCS[@]} -eq 0 ] && RPCS=("https://${CHAIN_ID}.rpc.thirdweb.com" "https://rpc.ankr.com/multichain/${CHAIN_ID}")

# Prioritize ETH_RPC_URL if set
[ -n "$ETH_RPC_URL" ] && RPCS=("$ETH_RPC_URL" "${RPCS[@]}")

# Update erpc.yaml
sed -i "s/chainId:.*/chainId: ${CHAIN_ID}/" erpc.yaml
sed -i '/^      - endpoint:/d' erpc.yaml
printf '      - endpoint: %s\n' "${RPCS[@]}" | sed -i '/^    upstreams:/r /dev/stdin' erpc.yaml

echo "Configured ${#RPCS[@]} RPC endpoints for chain ID ${CHAIN_ID}"