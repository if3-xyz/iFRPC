# iFRPC

iFRPC is a forked version of [eRPC](https://github.com/erpc/erpc) that provides a production-ready RPC gateway for any EVM-compatible chain. Simply provide an EVM ChainID and iFRPC will automatically configure and run the RPC service for that chain with integrated monitoring, caching, and observability.

## Quick Start

Provide an EVM ChainID and iFRPC will automatically discover RPC endpoints and configure the service:

```bash
# Configure for your chain by providing the ChainID
make configure  # Enter EVM ChainID when prompted

# Or configure directly
./configure.sh <chainID>

# Build and start all services
make all
```

iFRPC automatically discovers and adds RPC endpoints from [chainlist.org](https://chainlist.org) for the specified chain. RPC endpoints are automatically refreshed every hour to ensure you always have the latest available endpoints. Optionally set `ETH_RPC_URL` to prioritize a specific endpoint.

## Services & Ports

| Service      | Port | Description                    |
|--------------|------|--------------------------------|
| iFRPC        | 4000 | JSON-RPC endpoint              |
| iFRPC        | 4001 | Metrics endpoint               |
| Grafana      | 4002 | Monitoring dashboards          |
| Prometheus   | 4091 | Metrics database               |
| Redis        | 6379 | Cache store                    |
| RPC Updater  | -    | Hourly RPC endpoint updates   |

**Grafana**: `admin` / `admin` (change in production!)

## Configuration

iFRPC takes an EVM ChainID and automatically configures the RPC service for that chain:

```bash
make configure  # Enter EVM ChainID when prompted
./configure.sh <chainID>  # Or manually
```

The configuration script automatically:
- Takes your EVM ChainID as input
- Queries [chainlist.org/rpcs.json](https://chainlist.org/rpcs.json) for available RPC endpoints
- Automatically adds discovered endpoints to the configuration
- Falls back to thirdweb and Ankr if needed
- Prioritizes `ETH_RPC_URL` if set (optional)
- Updates `erpc.yaml` with discovered endpoints and chain configuration

**Automatic Updates**: RPC endpoints are automatically refreshed every hour from chainlist.org to ensure you always have the latest available endpoints. The updater service runs in the background and restarts iFRPC when new endpoints are discovered.

Edit `erpc.yaml` directly for advanced configuration (cache policies, timeouts, etc.).

## Makefile Commands

| Command      | Description                          |
|--------------|--------------------------------------|
| `make all`   | Full setup (network, clean, build, up) |
| `make up`    | Start all services                   |
| `make down`  | Stop all services                    |
| `make clean` | Stop and remove volumes              |
| `make logs`  | Follow logs                          |

## Network

All services run on `shared-network`. Access iFRPC from other containers at `http://erpc:4000`.

## Monitoring

- **Prometheus**: `http://localhost:4091`
- **Grafana**: `http://localhost:4002` (admin/admin)
- **iFRPC Metrics**: `http://localhost:4001/metrics`
- **Health Check**: `http://localhost:4001/health`

## Cache Strategy

- **Memory**: 2s TTL (realtime data)
- **Redis**: 10s TTL (unfinalized), 5m TTL (finalized)

## Usage Example

```bash
curl -X POST http://localhost:4000 \
  -H "Content-Type: application/json" \
  -d '{"jsonrpc":"2.0","method":"eth_blockNumber","params":[],"id":1}'
```

## Troubleshooting

```bash
# Check network
docker network ls | grep shared-network

# View logs
make logs
docker compose logs -f erpc

# Check RPC updater logs
docker compose logs -f rpc-updater

# Manually update RPC endpoints
./update-rpcs.sh
```

## Prerequisites

- Docker & Docker Compose
- `jq` and `curl` (for configure script)

RPC endpoints are automatically discovered - no manual configuration required!
