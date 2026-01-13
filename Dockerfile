FROM docker.n8n.io/n8nio/n8n:latest

USER root

# Update & install base deps (Alpine packages)
RUN apk update && apk upgrade && \
    apk add --no-cache \
        python3 \
        py3-pip \
        ffmpeg \
        curl \
        unzip \
        ca-certificates \
        build-base \
        python3-dev \
        libffi-dev \
        openssl-dev

# Create venv to avoid externally-managed Python issues on Alpine
ENV VIRTUAL_ENV=/opt/venv
RUN python3 -m venv $VIRTUAL_ENV
ENV PATH="$VIRTUAL_ENV/bin:$PATH"

# Install yt-dlp with default extras (signature handling etc.)
# curl_cffi often fails on musl/Alpine → we try but continue if not
RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir "yt-dlp[default]" && \
    (pip install --no-cache-dir curl_cffi || echo "curl_cffi install skipped - impersonate may be limited on Alpine/musl")

# Install Deno (official multi-stage copy - reliable on Alpine, no install script issues)
COPY --from=denoland/deno:alpine-2 /deno /usr/local/bin/deno

# Ensure Deno is in PATH
ENV PATH="/usr/local/bin:$PATH"

# Your original npm globals (kept as-is)
RUN npm install -g npm@latest
RUN npm install -g --unsafe-perm twilio @sendgrid/client @sendgrid/mail axios@1.7.7

ENV NODE_PATH=/usr/local/lib/node_modules

# Optional: Add community nodes if you want them baked in
# RUN npm install -g @endcycles/n8n-nodes-youtube-transcript

# Back to non-root
USER node

# Optional debug (uncomment during testing - shows in build logs)
# RUN yt-dlp --version && deno --version && yt-dlp --list-impersonate-targets || echo "Some impersonate targets unavailable"
