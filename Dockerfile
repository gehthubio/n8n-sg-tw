FROM docker.n8n.io/n8nio/n8n:latest

USER root

# Step 1: Reinstall apk-tools (required because n8n:latest removes it for hardening)
RUN ARCH=$(uname -m) && \
    wget -qO- "https://dl-cdn.alpinelinux.org/alpine/latest-stable/main/${ARCH}/" | \
    grep -o 'href="apk-tools-static-[^"]*\.apk"' | head -1 | cut -d'"' -f2 | \
    xargs -I {} wget -q "https://dl-cdn.alpinelinux.org/alpine/latest-stable/main/${ARCH}/{}" && \
    tar -xzf apk-tools-static-*.apk && \
    ./sbin/apk.static -X https://dl-cdn.alpinelinux.org/alpine/latest-stable/main \
        -U --allow-untrusted add apk-tools && \
    rm -rf sbin apk-tools-static-*.apk

# Step 2: Now apk is available – install everything we need
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

# Create venv for Python packages (avoids conflicts)
ENV VIRTUAL_ENV=/opt/venv
RUN python3 -m venv $VIRTUAL_ENV
ENV PATH="$VIRTUAL_ENV/bin:$PATH"

# Install yt-dlp with default extras
# curl_cffi often fails on musl/Alpine, so we try but continue if it can't install
RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir "yt-dlp[default]" && \
    (pip install --no-cache-dir curl_cffi || echo "curl_cffi skipped – impersonate may be limited")

# Install Deno using the official install script (most reliable on Alpine)
RUN curl -fsSL https://deno.land/install.sh | sh && \
    mv /root/.deno/bin/deno /usr/local/bin/deno && \
    rm -rf /root/.deno

ENV PATH="/usr/local/bin:$PATH"

# Your original npm globals
RUN npm install -g npm@latest
RUN npm install -g --unsafe-perm twilio @sendgrid/client @sendgrid/mail axios@1.7.7

ENV NODE_PATH=/usr/local/lib/node_modules

# Optional community nodes (uncomment if you want them)
# RUN npm install -g @endcycles/n8n-nodes-youtube-transcript

# Switch back to non-root user
USER node

# Optional debug (uncomment to verify during build)
# RUN deno --version && yt-dlp --version && yt-dlp --list-impersonate-targets || echo "Impersonate limited"
