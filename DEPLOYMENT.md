# A. Prerequisites
## Minimum Local Hardware Requirements
- CPU: 4core / 8core
- RAM: 8GB / 16GB / 32GB
- DISK: 120gb or 500GB NVME SSD or Standard SSD
- OS: Linux, MacOS

## Software Dependencies
Refer to [official docs](https://docs.blockscout.com/for-developers/deployment/manual-deployment-guide#software-dependencies). Use asdf for Erlang and Elixir.
### Versions
- Erlang/OTP 25
- Elixir 1.14.x
- Postgres 14
- Node.js 18.x.x

## Prepare
```bash
cd blockscout-backend
# Update the following command using correct username, password and database name
export DATABASE_URL=postgresql://username:password@localhost:5432/blockscout
# Install dependencies & compile
mix do deps.get, local.rebar --force, deps.compile
# Generate new private key 
mix phx.gen.secret
# Update the following command using generated private key
export SECRET_KEY_BASE=VTIB3uHDNbvrY0+60ZWgUoUBKDn9ppLR8MI4CpRz4/qLyEFs54ktJfaNT6Z221No
```

```bash
# ENV Variables
export ETHEREUM_JSONRPC_VARIANT=geth
export ETHEREUM_JSONRPC_HTTP_URL=https://blockchain.ngrok.dev
export ETHEREUM_JSONRPC_TRACE_URL=https://blockchain.ngrok.dev
export API_V2_ENABLED=true
export PORT=3002
export COIN_NAME=ZeroXToken
export COIN=ZXT
```

```bash
# compile
mix compile
# CREATE & MIGRATE
mix do ecto.create, ecto.migrate
```

```bash
# Prepare assets
cd apps/block_scout_web/assets; npm install && node_modules/webpack/bin/webpack.js --mode production; cd -

# Prepare npm dependencies
cd apps/explorer && npm install; cd -

# Build assets
mix phx.digest

# Enable HTTPS in development. The Phoenix server only runs with HTTPS
cd apps/block_scout_web; mix phx.gen.cert blockscout blockscout.local; cd -
```

Replace /etc/hosts to
```
   127.0.0.1       localhost blockscout blockscout.local

   255.255.255.255 broadcasthost

   ::1             localhost blockscout blockscout.local
```

Enable `chrome://flags/#allow-insecure-localhost`, restart browser

## Microservices
### Prerequisites
- Docker v26.0.0(Mac)
- Docker-compose v2.26.1(Mac)

```bash
cd ./blockscout-backend/docker-compose
docker compose -f microservices.yml up -d
```

## More ENV Variables
```bash
export MICROSERVICE_SC_VERIFIER_ENABLED=true                  
export MICROSERVICE_SC_VERIFIER_URL=http://localhost:8082/
export MICROSERVICE_VISUALIZE_SOL2UML_ENABLED=true
export MICROSERVICE_VISUALIZE_SOL2UML_URL=http://localhost:8081/
export MICROSERVICE_SIG_PROVIDER_ENABLED=true
export MICROSERVICE_SIG_PROVIDER_URL=http://localhost:8083/
```

## Run
```
cd blockscout-backend
mix phx.server
```