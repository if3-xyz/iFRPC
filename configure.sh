#!/bin/bash
set -e
CHAIN_ID=$1
[ -z "$CHAIN_ID" ] && { echo "Usage: $0 <chainID>"; exit 1; }
RPCS=($(curl -s "https://chainid.network/chains.json" | jq -r ".[] | select(.chainId==${CHAIN_ID}) | .rpc[]? | select(. | startswith(\"http\"))" | grep -v "$ETH_RPC_URL" | head -3))
[ ${#RPCS[@]} -eq 0 ] && RPCS=("https://${CHAIN_ID}.rpc.thirdweb.com" "https://rpc.ankr.com/multichain/${CHAIN_ID}")
[ -n "$ETH_RPC_URL" ] && RPCS=("$ETH_RPC_URL" "${RPCS[@]}")
sed -i "s/chainId:.*/chainId: ${CHAIN_ID}/" erpc.yaml
sed -i '/^      - endpoint:/d' erpc.yaml
printf '      - endpoint: %s\n' "${RPCS[@]}" | sed -i '/^    upstreams:/r /dev/stdin' erpc.yaml