# ─── Build stage ─────────────────────────────────────────────────────────────
FROM rust:1.76-slim AS builder

WORKDIR /build

RUN apt-get update && apt-get install -y pkg-config libssl-dev && rm -rf /var/lib/apt/lists/*

# Copy only what relay needs
COPY Cargo.toml ./
COPY common/    ./common/
COPY relay/     ./relay/

# Build only relay
RUN cargo build --release -p relay

# ─── Runtime stage ───────────────────────────────────────────────────────────
FROM debian:bookworm-slim

RUN apt-get update && \
    apt-get install -y ca-certificates libssl3 && \
    rm -rf /var/lib/apt/lists/*

COPY --from=builder /build/target/release/relay /usr/local/bin/anbu-relay

ENV PORT=8080
EXPOSE 8080

CMD ["sh", "-c", "anbu-relay --bind 0.0.0.0:${PORT}"]
