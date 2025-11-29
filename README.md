# eRPC - Base Mainnet

[eRPC](https://github.com/erpc/erpc) on Base with Prometheus & Grafana.

## Setup

```bash
export ETH_RPC_URL="https://your-rpc-url"
make all
```

## Ports

`:4000` JSON-RPC | `:4001` Metrics | `:4002` Grafana (admin/admin) | `:4091` Prometheus

## Network

All services run on `shared-network`. Access eRPC from other containers at `http://erpc:4000`.

