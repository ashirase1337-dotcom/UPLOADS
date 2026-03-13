# Build stage
FROM rust:1.76-slim AS builder

WORKDIR /build
RUN apt-get update && apt-get install -y pkg-config libssl-dev && rm -rf /var/lib/apt/lists/*

# Copy workspace
COPY . .

# Build only the relay
RUN cargo build --release -p relay

# Runtime stage — minimal image
FROM debian:bookworm-slim
RUN apt-get update && apt-get install -y ca-certificates libssl3 && rm -rf /var/lib/apt/lists/*

COPY --from=builder /build/target/release/relay /usr/local/bin/anbu-relay

# fly.io uses PORT env var
ENV PORT=8080
EXPOSE 8080

CMD ["sh", "-c", "anbu-relay --bind 0.0.0.0:${PORT}"]
