FROM node:22.19.0-bookworm-slim

ARG PNPM_VERSION=11.25.0
ARG VCS_REF=""

ENV NODE_ENV=production \
    DSH_HOME=/home/node/.dsh \
    DSH_TAVERN_PORT=3081

WORKDIR /app

COPY config/dsh-compatibility.json /tmp/dsh-compatibility.json
RUN DSH_VERSION="$(node -p "require('/tmp/dsh-compatibility.json').adaptedDshVersion")" \
    && npm install --global "pnpm@${PNPM_VERSION}" "@deepseek-ai/dsh@${DSH_VERSION}" \
    && npm cache clean --force \
    && rm /tmp/dsh-compatibility.json

COPY --chown=node:node . .
RUN mkdir -p /home/node/.dsh \
    && chown -R node:node /home/node/.dsh

USER node

RUN if echo "${VCS_REF}" | grep -Eq '^[0-9a-fA-F]{40}$'; then \
      printf '{"commit":"%s","installedAt":"image-build"}\n' "${VCS_REF}" > .dsh-tavern-release.json; \
    fi \
    && pnpm install --frozen-lockfile

EXPOSE 3081

ENTRYPOINT ["/bin/sh", "/app/docker-entrypoint.sh"]
