# Immich server image tuned for a t3.medium (2 vCPU / 4 GiB).
#
# The official immich-server:release image already bundles the server API AND
# the web UI, both served on port 2283, so a single container replaces the
# classic server + web two-container deployment. This keeps memory usage low
# enough for a t3.medium.

FROM ghcr.io/immich-app/immich-server:release

# Resource tuning for t3.medium: cap workers and disable the resource-hungry
# machine-learning service so everything stays in one lightweight container.
ENV IMMICH_WORKERS=2 \
    IMMICH_MACHINE_LEARNING_ENABLED=false \
    NODE_OPTIONS=--max-old-space-size=1536

EXPOSE 2283